`include "modules/headers/trap.vh"

module TrapController #(
    parameter XLEN = 32
)(
    input wire clk,
    input wire reset,
    input wire [XLEN-1:0] ID_pc,
    input wire [XLEN-1:0] EX_pc,
    input wire [XLEN-1:0] MEM_pc,
    input wire [XLEN-1:0] WB_pc,
    input wire [2:0] trap_status,      // indicates current trap type
    input wire [XLEN-1:0] csr_read_data,

    output reg [XLEN-1:0] trap_target,      // trap handler base address output
    output reg ic_clean,         // instruction cache reset signal for zifencei
    output reg debug_mode,       
    output reg csr_write_enable,
    output reg [11:0] csr_trap_address,
    output reg [XLEN-1:0] csr_trap_write_data,
    output reg trap_done,         // indicates whether PTH(Pre-Trap Hadling) FSM is done or not. if 0 = pc_stall
    output reg misaligned_instruction_flush,        // indicates whether the MISALIGNED INSTRUCTION pth is over and EX_MEM_Register should be flushed or not.
    output reg misaligned_memory_flush,
    output reg pth_done_flush,
    output reg standby_mode
);

// FSM States
localparam  IDLE          = 4'b0000,
            WRITE_MEPC    = 4'b0001,
            WRITE_MCAUSE  = 4'b0010,
            READ_MTVEC    = 4'b0011,
            READ_MEPC     = 4'b0100,
            GOTO_MTVEC    = 4'b0101,
            RETURN_MRET   = 4'b0110,

            MEM_STANDBY   = 4'b0111,
            WB_STANDBY    = 4'b1000,
            RTRE_STANDBY  = 4'b1001,
            ECALL_MEPC_WRITE    = 4'b1010;

// traditional FSM state architecture
reg [3:0] trap_handle_state, next_trap_handle_state;
reg debug_mode_reg; 

// FSM update logic and debug_mode register update
always @(posedge clk or posedge reset) begin
    if (reset) begin
        trap_handle_state <= IDLE;
        debug_mode_reg <= 1'b0; 
    end 
    else begin 
        trap_handle_state <= next_trap_handle_state;
        // debug_mode logics
        case (trap_status)
            `TRAP_MRET: begin
                if (trap_handle_state == IDLE) begin
                    debug_mode_reg <= 1'b0;
                end
            end
            `TRAP_EBREAK: begin
                if (trap_handle_state == WRITE_MCAUSE) begin
                    debug_mode_reg <= 1'b1;
                end
            end
            default: begin
                // keep debug_mode_reg
            end
        endcase
    end
end

// debug_mode register
always @(*) begin
    debug_mode = debug_mode_reg;
end

always @(*) begin
    // default outputs
    ic_clean             = 1'b0;
    csr_write_enable     = 1'b0;
    csr_trap_address     = 12'b0;
    csr_trap_write_data  = {XLEN{1'b0}};
    trap_target          = {XLEN{1'b0}};
    trap_done            = 1'b1;
    misaligned_instruction_flush = 1'b0;
    misaligned_memory_flush = 1'b0;
    pth_done_flush       = 1'b0;
    standby_mode = 1'b0;
    // default next state
    next_trap_handle_state = IDLE;

    case (trap_status)
        // traps that doesn't require multiple PTH FSM
        `TRAP_NONE: begin
            next_trap_handle_state = IDLE;
        end
        `TRAP_FENCEI: begin
            ic_clean = 1'b1;
            trap_done = 1'b1;
            next_trap_handle_state = IDLE;
        end

        // ────────── traps that require multiple PTH FSM ──────────
        default: begin
            case (trap_handle_state)
                IDLE: begin 
                    if (trap_status == `TRAP_MRET) begin
                        csr_trap_address = 12'h341; //mepc
                        trap_done = 1'b0;
                        next_trap_handle_state = READ_MEPC;

                    end else if (trap_status == `TRAP_ECALL) begin
                        standby_mode = 1'b1;
                        trap_done = 1'b0;
                        next_trap_handle_state = MEM_STANDBY;

                    end else begin
                        // write current pc value to mepc CSR
                        csr_write_enable = 1'b1;
                        csr_trap_address = 12'h341; //mepc
                        csr_trap_write_data = MEM_pc;
                        trap_done = 1'b0;
                        next_trap_handle_state = WRITE_MEPC;
                    end
                end

                MEM_STANDBY: begin
                    standby_mode = 1'b1;
                    trap_done = 1'b0;
                    next_trap_handle_state = WB_STANDBY;
                end

                WB_STANDBY: begin
                    standby_mode = 1'b1;
                    trap_done = 1'b0;
                    next_trap_handle_state = RTRE_STANDBY;
                end

                RTRE_STANDBY: begin
                    standby_mode = 1'b1;
                    trap_done = 1'b0;
                    next_trap_handle_state = ECALL_MEPC_WRITE;
                end

                ECALL_MEPC_WRITE: begin
                    standby_mode = 1'b0;
                    // write current pc value to mepc CSR
                    csr_write_enable = 1'b1;
                    csr_trap_address = 12'h341; //mepc
                    csr_trap_write_data = EX_pc;
                    trap_done = 1'b0;
                    next_trap_handle_state = WRITE_MEPC;
                end

                WRITE_MEPC: begin 
                    // write mcause code value for each trap type
                    csr_write_enable = 1'b1;
                    csr_trap_address = 12'h342; //mcause
                    if (trap_status == `TRAP_EBREAK)    csr_trap_write_data = 32'd3;
                    else if (trap_status == `TRAP_ECALL)    csr_trap_write_data = 32'd11;
                    else if (trap_status == `TRAP_MISALIGNED_LOAD) csr_trap_write_data = 32'd4;
                    else if (trap_status == `TRAP_MISALIGNED_STORE) csr_trap_write_data = 32'd6;
                    //else if (trap_status == `TRAP_ILLEGAL_INSTRUCTION) csr_trap_write_data = 32'd2; 
                    else csr_trap_write_data = 32'd0; // TRAP_MISALIGNED_INSTRUCTION
                    
                    trap_done = 1'b0;
                    next_trap_handle_state = WRITE_MCAUSE;
                end

                WRITE_MCAUSE: begin
                    // Enable debug mode for EBREAK and PTH escape
                    if (trap_status == `TRAP_EBREAK) begin
                        trap_done = 1'b1;
                        next_trap_handle_state = IDLE;
                    end
                    else begin
                        // ECALL, ILLEGAL/MISALIGNED_INSTRUCTION : read mtvec trap handler CSR value
                        csr_write_enable = 1'b0;
                        csr_trap_address = 12'h305; // mtvec
                        trap_target = csr_read_data;
                        trap_done = 1'b0;
                        next_trap_handle_state = READ_MTVEC;
                    end
                end

                READ_MTVEC: begin
                    // keep mtvec value output
                    csr_trap_address = 12'h305; // mtvec
                    trap_target = csr_read_data;
                    if (trap_status == `TRAP_MISALIGNED_INSTRUCTION) begin
                        misaligned_instruction_flush = 1'b1;
                    end else if (trap_status == `TRAP_MISALIGNED_STORE || trap_status == `TRAP_MISALIGNED_LOAD) begin
                        misaligned_memory_flush = 1'b1;
                    end
                    trap_done = 1'b1;
                    pth_done_flush = 1'b1;
                    next_trap_handle_state = GOTO_MTVEC;
                end

                GOTO_MTVEC: begin
                    // keep mtvec value output
                    csr_trap_address = 12'h305; // mtvec
                    trap_target = csr_read_data;
                    if (trap_status == `TRAP_MISALIGNED_INSTRUCTION) begin
                        misaligned_instruction_flush = 1'b1;
                    end else if (trap_status == `TRAP_MISALIGNED_STORE || trap_status == `TRAP_MISALIGNED_LOAD) begin
                        misaligned_memory_flush = 1'b1;
                    end
                    trap_done = 1'b1;
                    pth_done_flush = 1'b1;
                    next_trap_handle_state = IDLE;
                end

                READ_MEPC: begin
                    // keep mepc value output
                    csr_trap_address = 12'h341; // mepc
                    trap_target = ({csr_read_data[31:2], 2'b0} + 4);    // For preventing misaligned instruction address
                    trap_done = 1'b0;
                    next_trap_handle_state = RETURN_MRET;
                end

                RETURN_MRET: begin
                    // keep mepc value output
                    csr_trap_address = 12'h341; // mepc
                    trap_target = ({csr_read_data[31:2], 2'b0} + 4);    // For preventing misaligned instruction address
                    trap_done = 1'b1;
                    next_trap_handle_state = IDLE;
                end

                default: begin
                    next_trap_handle_state = IDLE;
                end
            endcase
        end
    endcase
end
endmodule
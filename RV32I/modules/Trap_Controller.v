`include "modules/headers/trap.vh"

module TrapController (
    input wire        clk,
    input wire        reset,
    input wire [31:0] ID_pc,
    input wire [31:0] EX_pc,
    input wire [2:0]  trap_status,      // indicates current trap type
    input wire [31:0] csr_read_data,

    output reg [31:0] trap_target,      // trap handler base address output
    output reg        ic_clean,         // instruction cache reset signal for zifencei
    output reg        debug_mode,       
    output reg        csr_write_enable,
    output reg [11:0] csr_trap_address,
    output reg [31:0] csr_trap_write_data,
    output reg        trap_done         // indicates whether PTH(Pre-Trap Hadling) FSM is done or not. if 0 = pc_stall
);

// FSM States
localparam  IDLE          = 2'b00,
            WRITE_MEPC    = 2'b01,
            WRITE_MCAUSE  = 2'b10,
            READ_MTVEC    = 2'b11;

// traditional FSM state architecture
reg [1:0] trap_handle_state, next_trap_handle_state;
reg debug_mode_enable;

// FSM update logic and debug_mode reset
always @(posedge clk or posedge reset) begin
    if (reset) begin
        trap_handle_state <= IDLE;
        debug_mode_enable <= 1'b0;
    end 
    else begin
        trap_handle_state <= next_trap_handle_state;
        debug_mode_enable <= debug_mode;
    end
end

always @(*) begin
    // default outputs
    ic_clean             = 1'b0;
    csr_write_enable     = 1'b0;
    csr_trap_address     = 12'b0;
    csr_trap_write_data  = 32'b0;
    trap_target          = 32'b0;
    trap_done            = 1'b1;
    // default next state
    next_trap_handle_state = IDLE;
    debug_mode = debug_mode_enable;
    
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
        `TRAP_MRET: begin
            debug_mode = 1'b0;
            csr_trap_address = 12'h341; //mepc
            trap_target = ({csr_read_data[31:2], 2'b0} + 4);    // For preventing misaligned instruction address
            trap_done = 1'b1;
            next_trap_handle_state = IDLE;
        end

        // ────────── traps that require multiple PTH FSM ──────────
        default: begin
            case (trap_handle_state)
                IDLE: begin 
                    // write current pc value to mepc CSR
                    csr_write_enable = 1'b1;
                    csr_trap_address = 12'h341; //mepc
                    if (trap_status == `TRAP_ECALL) begin
                    csr_trap_write_data = ID_pc;
                    end else csr_trap_write_data = EX_pc;
                    trap_done = 1'b0;
                    next_trap_handle_state = WRITE_MEPC;
                end

                WRITE_MEPC: begin 
                    // write mcause code value for each trap type
                    csr_write_enable = 1'b1;
                    csr_trap_address = 12'h342; //mcause
                    if (trap_status == `TRAP_EBREAK)    csr_trap_write_data = 32'd3;
                    else if (trap_status == `TRAP_ECALL)    csr_trap_write_data = 32'd11;
                    else // TRAP_MISALIGNED
                    csr_trap_write_data = 32'd0;
                    trap_done = 1'b0;
                    next_trap_handle_state = WRITE_MCAUSE;
                end

                WRITE_MCAUSE: begin
                    // Enable debug mode for EBREAK and PTH escape
                    if (trap_status == `TRAP_EBREAK) begin
                        debug_mode = 1'b1;
                        trap_done = 1'b1;
                        next_trap_handle_state = IDLE;
                    end
                    else begin
                        // ECALL, MISALIGNED : read mtvec trap handler CSR value
                        csr_write_enable = 1'b0;
                        trap_done = 1'b0;
                        next_trap_handle_state = READ_MTVEC;
                    end
                end

                READ_MTVEC: begin
                    // keep mtvec value output
                    csr_trap_address = 12'h305; // mtvec
                    trap_target = csr_read_data;
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
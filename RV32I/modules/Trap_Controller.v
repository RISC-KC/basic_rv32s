  `include "modules/headers/trap.vh"

module TrapController (
    input wire        clk,
    input wire        rst,
    input wire [31:0] pc,
    input wire [2:0]  trap_status,
    input wire [31:0] csr_read_data,

    output reg [31:0] trap_target,
    output reg        ic_clean,
    output reg        debug_mode,
    output reg [11:0] csr_trap_address,
    output reg [31:0] csr_trap_write_data
);

localparam  IDLE          = 2'b00,
            WRITE_MEPC    = 2'b01,
            WRITE_MCAUSE  = 2'b10;
            
reg [1:0] trap_handle_state;

always @(posedge clk or posedge rst) begin
    //reset
    if (rst) begin
        trap_handle_state    <= IDLE;
        debug_mode           <= 1'b0;
        ic_clean             <= 1'b0;
        trap_target          <= 32'b0;
        csr_trap_address     <= 12'b0;
        csr_trap_write_data  <= 32'b0;
    end else begin
    // prevent latch synthesis (default value allocation)
        debug_mode           <= 1'b0;
        ic_clean             <= 1'b0;
        csr_trap_address     <= 12'b0;
        csr_trap_write_data  <= 32'b0;
        trap_target          <= 32'b0;

    case (trap_status)
        `TRAP_EBREAK: begin
            debug_mode <= 1'b1;
            case (trap_handle_state)
            //Write mepc mode
                IDLE: begin
                    csr_trap_address    <= 12'h341;     //mepc
                    csr_trap_write_data <= pc;
                    trap_handle_state   <= WRITE_MEPC;
            end
            //Write mcause mode
                WRITE_MEPC: begin
                    csr_trap_address    <= 12'h342; //mcause
                    csr_trap_write_data <= 32'd3; //mcause value 3 = Breakpoint exception code
                    trap_handle_state   <= IDLE;
            end
            endcase
        end
        
        `TRAP_ECALL: begin
            case (trap_handle_state)
            //Write mepc mode
                IDLE: begin
                    csr_trap_address    <= 12'h341;     //mepc
                    csr_trap_write_data <= pc;
                    trap_handle_state   <= WRITE_MEPC;
            end
            //Write mcause mode
                WRITE_MEPC: begin
                    csr_trap_address    <= 12'h342; //mcause
                    csr_trap_write_data <= 32'd11; //mcause value 11 = Environment call from M-mode exception code
                    trap_handle_state   <= WRITE_MCAUSE;
            end
            //Read mtvec mode
                WRITE_MCAUSE: begin
                    csr_trap_address  <= 12'h305; //mtvec
                    trap_target       <= csr_read_data;
                    trap_handle_state <= IDLE;
                end
            endcase
        end

        `TRAP_MISALIGNED: begin
            case (trap_handle_state)
            //Write mepc mode
                IDLE: begin
                    csr_trap_address    <= 12'h341;     //mepc
                    csr_trap_write_data <= pc;
                    trap_handle_state   <= WRITE_MEPC;
            end
            //Write mcause mode
                WRITE_MEPC: begin
                    csr_trap_address    <= 12'h342; //mcause
                    csr_trap_write_data <= 32'd0; //mcause value 0 = Instruction address misaligned exception code
                    trap_handle_state   <= WRITE_MCAUSE;
            end
            //Read mtvec mode
                WRITE_MCAUSE: begin
                    csr_trap_address  <= 12'h305; //mtvec
                    trap_target       <= csr_read_data;
                    trap_handle_state <= IDLE;
                end
            endcase
        end

        `TRAP_FENCEI: begin
            ic_clean <= 1'b1;
        end

        `TRAP_MRET: begin
            csr_trap_address   <= 12'h341; //mepc
            trap_target        <= csr_read_data;
            debug_mode         <= 1'b0;
            trap_handle_state  <= IDLE;
        end

        `TRAP_NONE: begin
            ic_clean          <= 1'b0;
            debug_mode        <= 1'b0;
            trap_handle_state <= IDLE;
        end
    endcase
end
end

endmodule
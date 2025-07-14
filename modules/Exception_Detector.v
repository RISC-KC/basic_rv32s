`include "modules/headers/opcode.vh"
`include "modules/headers/trap.vh"

module ExceptionDetector (
	input [6:0] opcode,				// opcode
	input [2:0] funct3,				// funct3
	input imm_0,					// 0th index of imm to distinguish EBREAK or ECALL
	input [1:0] next_pc_lsbs,		// LSBs of next pc
	
    output reg trapped,				// signal indicating if trap has occurred
	output reg [1:0] trap_status	// current trap status
);
	
	always @(*) begin
		case (opcode)
			`OPCODE_ENVIRONMENT: begin // EBREAK, ECALL
				if (funct3 == 3'b0) begin
					trapped = 1;
				
					if (imm_0) begin
						trap_status = `TRAP_EBREAK;
					end
					else begin
						trap_status = `TRAP_ECALL;
					end
				end
				else begin
					trapped = 0;
					trap_status = `TRAP_NONE;
				end
			end
			`OPCODE_JAL, `OPCODE_JALR, `OPCODE_BRANCH: begin // Misaligned
				if (next_pc_lsbs == 2'b0) begin
					trapped = 0;
					trap_status = `TRAP_NONE;
				end
				else begin
					trapped = 1;
					trap_status = `TRAP_MISALIGNED;
				end
			end
			default: begin
				trapped = 0;
				trap_status = `TRAP_NONE;
			end
        endcase
	end
	
endmodule

`include "modules/headers/opcode.vh"
`include "modules/headers/trap.vh"

module ExceptionDetector (
	input [6:0] opcode,				// opcode
	input [2:0] funct3,				// funct3
	input imm_0,					// 0th index of imm
	input [1:0] jump_target_lsbs,	// LSBs of target address for jump
	input branch,					// signal indicating if branch has taken
	input [1:0] branch_target_lsbs,	// LSBs of target address for branch
	
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
				if (branch) begin
					if (branch_target_lsbs == 2'b0) begin
						trapped = 0;
						trap_status = `TRAP_NONE;
					end
					else begin
						trapped = 1;
						trap_status = `TRAP_MISALIGNED;
					end
				end
				else if (jump_target_lsbs == 2'b0) begin
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

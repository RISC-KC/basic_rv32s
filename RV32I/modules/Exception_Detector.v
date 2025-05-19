`include "modules/headers/opcode.vh"
`include "modules/headers/trap.vh"

module ExceptionDetector (
	input [6:0] opcode,				// opcode
	input [2:0] funct3,				// funct3
	input [11:0] funct12,			// raw_imm field to distinguish EBREAK, ECALL and MRET
	input [1:0] jump_target_lsbs,		// LSBs of jump target
	input [1:0] branch_target_lsbs,		// LSBs of branch target
	
    output reg trapped,				// signal indicating if trap has occurred
	output reg [2:0] trap_status	// current trap status
);
	
	always @(*) begin
		case (opcode)
			`OPCODE_FENCE: begin	// Zifence
				if (funct3 == 3'b001) begin
					trapped = 1'b1;
					trap_status = `TRAP_FENCEI;
				end
			end

			`OPCODE_ENVIRONMENT: begin // EBREAK, ECALL, MRET
				if (funct3 == 3'b0) begin
						trapped = 1;
					if (funct12 == 12'b0011_0000_0010) begin
						trap_status = `TRAP_MRET;
					end
					else if (funct12[0]) begin
						trap_status = `TRAP_EBREAK;
					end
					else if (funct12 == 12'b0) begin
						trap_status = `TRAP_ECALL;
					end
				end
				else begin
					trapped = 0;
					trap_status = `TRAP_NONE;
				end
			end
			`OPCODE_JAL, `OPCODE_JALR: begin // Misaligned
				if (jump_target_lsbs == 2'b0) begin
					trapped = 0;
					trap_status = `TRAP_NONE;
				end
				else begin
					trapped = 1;
					trap_status = `TRAP_MISALIGNED;
				end
			end

			`OPCODE_BRANCH: begin // Misaligned
				if (branch_target_lsbs == 2'b0) begin
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
`include "modules/headers/pcc_op.vh"

module PCController (
    input [2:0]  pcc_op,		// program counter operation code from Control Unit
	input [31:0] pc,			// current pc value
	input [31:0] jump_target,	// target address for jump
	input [31:0] branch_target,	// target address for branch
	input [31:0] trap_target,	// target address for trap

	output reg [31:0] next_pc	// next pc value
);

    always @(*) begin
		case (pcc_op)
			`PCC_NONE: begin
				next_pc = pc + 4;
			end
			`PCC_STALL: begin
				next_pc = pc;
			end
			`PCC_JUMP: begin
				if (jump_target[1:0] != 2'b0) begin
					next_pc = pc;
				end
				else begin
					next_pc = jump_target;
				end
			end
			`PCC_BTAKEN: begin
				if (branch_target[1:0] != 2'b0) begin
					next_pc = pc;
				end
				else begin
					next_pc = branch_target;
				end
			end
			`PCC_TRAPPED: begin
				next_pc = trap_target;
			end
		endcase
	end

endmodule

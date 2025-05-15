module PCController (
    input jump, 				// signal indicating if PC should jump
	input branch_taken,			// signal indicating if PC should take the branch
	input trapped,				// signal indicating if trap has occurred
	input [31:0] pc,			// current pc value
	input [31:0] jump_target,	// target address for jump
	input [31:0] imm,			// immediate value from Immediate Generator
	input [31:0] trap_target,	// target address for trap
	input pc_stall,				// signal indicating if pc update should be paused

	output reg [31:0] next_pc	// next pc value
);

    always @(*) begin
		if (pc_stall) begin
			next_pc = pc;
		end
		else if (jump && pc_stall == 0 && trapped == 0 && branch_taken == 0) begin
			next_pc = jump_target;
		end
		else if (branch_taken && jump == 0 && pc_stall == 0 && trapped == 0) begin
			next_pc = pc + imm;
		end
		else if (trapped && jump == 0 && pc_stall == 0 && branch_taken == 0) begin
			next_pc = trap_target;
		end
		else begin
			next_pc = pc + 4;
		end
	end

endmodule

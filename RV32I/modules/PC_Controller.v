module PCController (
    input jump, 				// signal indicating if PC should jump
	input branch_taken,			// = branch estimation. signal indicating if PC should take the branch
	input trapped,				// signal indicating if trap has occurred
	input [31:0] pc,			// current pc value
	input [31:0] jump_target,	// target address for jump
	input [31:0] branch_target, // target address for branch from branch predictor
	input [31:0] trap_target,	// target address for trap
	input pc_stall,				// signal indicating if pc update should be paused

	output reg [31:0] next_pc	// next pc value
);

    always @(*) begin
		if (!pc_stall) begin
			if (jump) begin
				next_pc = jump_target;
			end
			else if (branch_taken) begin
				next_pc = branch_target;
			end
			else if (trapped) begin
				next_pc = trap_target;
			end
			else begin
				next_pc = pc + 4;
			end
		end
		else begin
			next_pc = pc;
		end
    end

endmodule
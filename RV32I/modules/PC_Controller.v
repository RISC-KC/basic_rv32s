module PCController (
    input jump, 				// Signal indicating if PC should jump
	input branch_taken,			// Signal indicating if PC should take the branch
	input trapped,				// Signal indicating if trap has occurred
	input [31:0] pc,			// Current pc value
	input [31:0] jump_target,	// Target address for jumping
	input [31:0] branch_target,	// Target address for taking branch
	input [31:0] trap_target,	// Target address for trap
	
	output reg [31:0] next_pc	// Next pc value
);

    always @(*) begin
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

endmodule
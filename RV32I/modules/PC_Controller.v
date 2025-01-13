module PCController (
    input jump, 				// Signal indicating if we should jump
	input branch_taken,			// Singal indicating if we should take the branch
	input [31:0] pc,			// Current pc value
	input [31:0] jump_target,	// Target address for jumping
	input [31:0] branch_target,	// Target address for taking branch
	
	output reg [31:0] next_pc	// Next pc value
);

    always @(*) begin
		if (jump) begin
			next_pc = jump_target;
		end
		else if (branch_taken) begin
			next_pc = branch_target;
		end
		else begin
			next_pc = pc + 4;
		end
    end

endmodule
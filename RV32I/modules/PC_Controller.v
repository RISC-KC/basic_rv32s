module PCController (
    input jump, 				// signal indicating if PC should jump
	input branch_taken,			// signal indicating if PC should take the branch
	input trapped,				// signal indicating if trap has occurred
	input [31:0] pc,			// current pc value
	input [31:0] jump_target,	// target address for jump
	input [31:0] imm,			// immediate value from Immediate Generator
	input [31:0] trap_target,	// target address for trap
	input write_done,			// signal indicating if write is done
	input pc_stall,				// control signal for stalling pc value

	output reg [31:0] next_pc	// next pc value
);

    always @(*) begin
		if (pc_stall) begin
			next_pc = pc;
		end
		else if (write_done) begin
			if (jump) begin
				next_pc = jump_target;
			end
			else if (branch_taken) begin
				next_pc = pc + imm;
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

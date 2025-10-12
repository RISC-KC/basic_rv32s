module PCController (
    input jump,
	input branch_estimation,
	input branch_prediction_miss,	
	input trapped,
	input [31:0] pc,
	input [31:0] jump_target,
	input [31:0] branch_target,
	input [31:0] branch_target_actual,
	input [31:0] trap_target,
	input pc_stall,
	
	output reg [31:0] next_pc
);

    always @(*) begin
		if (!pc_stall) begin
			if (trapped) begin
				next_pc = trap_target;
			end else if (trapped == 1'b0 && jump) begin
				next_pc = jump_target;
			end else if (trapped == 1'b0 && branch_prediction_miss) begin
				next_pc = branch_target_actual;
			end else if (trapped == 1'b0 && branch_estimation) begin
				next_pc = branch_target;
			end else begin
				next_pc = pc + 4;
			end
		end else begin
			next_pc = pc;
		end
    end
endmodule
`include "modules/headers/branch.vh"

module BranchLogic (
    input branch,             		// signal indicating that the instruction is about branch
	input branch_estimation,			// EX_Phase signal; signal from branch predictor to compare whether the prediction is right or wrong
    input alu_zero,					// if ALU operation result is zero
    input [2:0] funct3,             // funct3
    
    output reg branch_taken, 		// determines if branch has taken
	output reg branch_prediction_miss
);
	wire branch_prediction;
	assign branch_prediction = branch_estimation;

    always @(*) begin
        if (branch) begin
			case (funct3)
				`BRANCH_BEQ: branch_taken = alu_zero;
				`BRANCH_BNE: branch_taken = ~alu_zero;
				`BRANCH_BLT: branch_taken = ~alu_zero;
				`BRANCH_BGE: branch_taken = alu_zero;
				`BRANCH_BLTU: branch_taken = ~alu_zero;
				`BRANCH_BGEU: branch_taken = alu_zero;
				default: branch_taken = 1'b0;
			endcase
			branch_prediction_miss = (branch_estimation != branch_taken);
		end
		else begin
			branch_taken = 0;
			branch_prediction_miss = 1'b0;
		end
    end

endmodule
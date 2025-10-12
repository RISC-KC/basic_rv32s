`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/branch.vh"

module BranchLogic (
    input branch,
	input branch_estimation,
    input alu_zero,
    input [2:0] funct3,
	input [31:0] pc,
	input [31:0] imm,

    output reg branch_taken,
	output reg [31:0] branch_target_actual,
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
			branch_target_actual = pc + imm;
			branch_prediction_miss = (branch_estimation != branch_taken);
		end
		else begin
			branch_taken = 1'b0;
			branch_target_actual = 32'b0;
			branch_prediction_miss = 1'b0;
		end
    end

endmodule
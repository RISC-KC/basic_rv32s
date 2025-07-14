`include "modules/headers/branch.vh"

module BranchLogic (
    input branch,             		// signal indicating that the instruction is about branch
    input [2:0] funct3,             // funct3
    input alu_zero,					// if ALU operation result is zero
    
    output reg branch_taken 		// determines if branch has taken
);

    always @(*) begin
        if (branch) begin
			case (funct3)
				`BRANCH_BEQ: begin
					branch_taken = alu_zero;
				end
				`BRANCH_BNE: begin
					branch_taken = ~alu_zero;
				end
				`BRANCH_BLT: begin
					branch_taken = ~alu_zero;
				end
				`BRANCH_BGE: begin
					branch_taken = alu_zero;
				end
				`BRANCH_BLTU: begin
					branch_taken = ~alu_zero;
				end
				`BRANCH_BGEU: begin
					branch_taken = alu_zero;
				end
				default: begin
					branch_taken = 0;
				end
			endcase
		end
		else begin
			branch_taken = 0;
		end
    end

endmodule

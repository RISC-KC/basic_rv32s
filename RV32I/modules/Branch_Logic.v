`include "modules/headers/branch.vh"

module BranchLogic (
    input branch,             		// signal indicating that the instruction is about branch
    input alu_zero,					// if ALU operation result is zero
    input [2:0] funct3,             // funct3
	input [31:0] pc,				// pc for branch target address calculation (pc + imm)
	input [31:0] imm,				// imm for branch target address calculation (pc + imm)
    
    output reg branch_taken, 		// determines if branch has taken
	output reg [31:0] branch_target	// branch target address
);

    always @(*) begin
        if (branch) begin
			case (funct3)
				`BRANCH_BEQ: begin
					branch_taken = alu_zero;
					if (branch_taken) branch_target = pc + imm;
				end
				`BRANCH_BNE: begin
					branch_taken = ~alu_zero;
					if (branch_taken) branch_target = pc + imm;
				end
				`BRANCH_BLT: begin
					branch_taken = ~alu_zero;
					if (branch_taken) branch_target = pc + imm;
				end
				`BRANCH_BGE: begin
					branch_taken = alu_zero;
					if (branch_taken) branch_target = pc + imm;
				end
				`BRANCH_BLTU: begin
					branch_taken = ~alu_zero;
					if (branch_taken) branch_target = pc + imm;
				end
				`BRANCH_BGEU: begin
					branch_taken = alu_zero;
					if (branch_taken) branch_target = pc + imm;
				end
				default: begin
					branch_taken = 0;
					branch_target = 0;
				end
			endcase
			
		end
		else begin
			branch_taken = 0;
			branch_target = 0;
		end
    end

endmodule
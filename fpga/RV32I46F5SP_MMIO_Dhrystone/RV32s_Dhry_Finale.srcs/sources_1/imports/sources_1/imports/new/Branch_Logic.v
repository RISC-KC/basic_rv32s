`include "./branch.vh"

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

    always @(*) begin
        if (branch) begin
            case (funct3)
                `BRANCH_BEQ:  branch_taken = alu_zero;
                `BRANCH_BNE:  branch_taken = ~alu_zero;
                `BRANCH_BLT:  branch_taken = ~alu_zero;
                `BRANCH_BGE:  branch_taken = alu_zero;
                `BRANCH_BLTU: branch_taken = ~alu_zero;
                `BRANCH_BGEU: branch_taken = alu_zero;
                default:      branch_taken = 1'b0;
            endcase
            
            branch_prediction_miss = (branch_estimation != branch_taken);
            
            if (branch_taken) begin
                branch_target_actual = pc + imm;
            end else begin
                branch_target_actual = pc + 4;
            end
        end
        else begin
            branch_taken = 1'b0;
            branch_target_actual = 32'b0;
            branch_prediction_miss = 1'b0;
        end
    end

endmodule
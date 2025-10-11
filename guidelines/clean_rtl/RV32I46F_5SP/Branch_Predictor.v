`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/opcode.vh"

module BranchPredictor #(
    parameter XLEN = 32
) (
    input wire clk,
    input wire clk_enable,
    input wire reset,
    input wire [6:0] IF_opcode,
    input wire [XLEN-1:0] IF_pc,
    input wire [XLEN-1:0] IF_imm,
    input wire EX_branch,
    input wire EX_branch_taken,
    
    output reg branch_estimation,
    output reg [XLEN-1:0] branch_target
);
    reg [1:0] prediction_counter;
    reg branch_prediction;
    wire [XLEN-1:0] prediction_target = branch_estimation ? (IF_pc + IF_imm) : (IF_pc + {{XLEN-3{1'b0}},3'd4});

    always @(*) begin
        if (IF_opcode == `OPCODE_BRANCH) begin
            branch_estimation = prediction_counter[1];
            branch_target = prediction_target;
        end else begin
            branch_estimation = 1'b0;
            branch_target = {XLEN{1'b0}};
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            branch_prediction <= 1'b0;
            prediction_counter <= 2'b00;
        end else if (clk_enable) begin
            if (IF_opcode == `OPCODE_BRANCH) begin
                branch_prediction <= branch_estimation;
            end
        if (EX_branch && (EX_branch_taken == 1'b1 || EX_branch_taken == 1'b0)) begin
                case ({EX_branch_taken, prediction_counter})
                    3'b0_00: prediction_counter <= 2'b00;
                    3'b0_01: prediction_counter <= 2'b00;
                    3'b0_10: prediction_counter <= 2'b01;
                    3'b0_11: prediction_counter <= 2'b10;
                    3'b1_00: prediction_counter <= 2'b01;
                    3'b1_01: prediction_counter <= 2'b10;
                    3'b1_10: prediction_counter <= 2'b11;
                    3'b1_11: prediction_counter <= 2'b11;
            endcase
            end
        end
    end
endmodule
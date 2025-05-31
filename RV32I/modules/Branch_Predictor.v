`include "modules/headers/opcode.vh"

module BranchPredictor #(
    parameter XLEN = 32
) (
    input wire clk,
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
        end
        else begin
            branch_estimation = 1'b0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            branch_prediction <= 1'b0;
            prediction_counter <= 2'b00;
            branch_target <= {XLEN{1'b0}};
        end else begin
            if (IF_opcode == `OPCODE_BRANCH) begin
                branch_prediction <= branch_estimation;
            end
        
        if (EX_branch && (EX_branch_taken !== 1'bx)) begin
                case ({EX_branch_taken, prediction_counter})
                // Not Taken 0, prediction_counter 00
                    3'b0_00: prediction_counter <= 2'b00; // Strongly Not Taken <- if not taken again, still 00.
                    3'b0_01: prediction_counter <= 2'b00; // Weakly Not Taken <- if not taken again, 00.
                    3'b0_10: prediction_counter <= 2'b01; // Weakly Taken <- if not taken, 01.
                    3'b0_11: prediction_counter <= 2'b10; // Strongly Taken <- if not taken, 10.
                // Taken 1, prediction_counter 00
                    3'b1_00: prediction_counter <= 2'b01; // Strongly Not Taken <- if taken, 01.
                    3'b1_01: prediction_counter <= 2'b10; // Weakly Not Taken <- if taken, 10.
                    3'b1_10: prediction_counter <= 2'b11; // Weakly Taken <- if taken again, 11.
                    3'b1_11: prediction_counter <= 2'b11; // Strongly Taken <- if taken again, still 11.
            endcase
            end
        end
    end

    
endmodule
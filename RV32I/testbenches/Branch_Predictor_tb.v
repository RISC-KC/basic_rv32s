`timescale 1ns/1ps
`include "modules/headers/opcode.vh"

module BranchPredictor_tb #(
    parameter XLEN = 32
);
    reg clk = 0;
    reg reset = 0;

    reg [6:0] IF_opcode;
    reg [XLEN-1:0] IF_pc;
    reg [XLEN-1:0] IF_imm;
    reg EX_branch;
    reg EX_branch_taken;
    
    wire branch_estimation;
    wire [XLEN-1:0] branch_target;

    BranchPredictor #(.XLEN(XLEN)) branch_predictor(
        .clk(clk),
        .reset(reset),
        .IF_opcode(IF_opcode),
        .IF_pc (IF_pc),
        .IF_imm (IF_imm),
        .EX_branch(EX_branch),
        .EX_branch_taken (EX_branch_taken),

        .branch_estimation (branch_estimation),
        .branch_target (branch_target)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/BranchPredictor_tb.vcd");
        $dumpvars(0, branch_predictor);

        // Test sequence
        $display("==================== Branch Predictor Test START ====================");

        // reset
        reset = 1'b1;
        #30;
        reset = 1'b0;

        IF_opcode = 7'b0;
        IF_pc = {XLEN{1'b0}};
        IF_imm = {XLEN{1'b0}};
        EX_branch = 1'b0;
        EX_branch_taken = 1'bx;
        // ---------------------------------------------------------------
        // Test 1: Prediction = NT, Actual = Taken (misprediction)
        @(negedge clk);
        IF_opcode = `OPCODE_BRANCH;
        IF_pc = 32'h0000_0000;
        IF_imm = 32'd8;
        repeat (2) @(negedge clk);

        // misprediction, prediction counter is now Weakly Not Taken.
        EX_branch_taken = 1'b1;
        EX_branch = 1'b1;
        #10;
        // ---------------------------------------------------------------
        // Test 2: Prediction = NT, Actual = Not Taken (well predicted)
        @(negedge clk);
        IF_pc = 32'h0000_0008;
        IF_imm = 32'd12;
        EX_branch = 1'b0;
        repeat (2) @(negedge clk);

        // well predicted, prediction counter is now Strongly Not Taken.
        EX_branch = 1'b1;
        EX_branch_taken = 1'b0; // Target address = 0x0000_000C (PC+4)
        #10;
        // ---------------------------------------------------------------
        // Test 3: Prediction = NT, Actual = Taken (misprediction)
        @(negedge clk);
        IF_pc = 32'h0000_000C;
        IF_imm = 32'd8;
        EX_branch = 1'b0;
        repeat (2) @(negedge clk);

        // misprediction, prediction counter is now Weakly Not Taken.
        EX_branch = 1'b1;
        EX_branch_taken = 1'b1; 
        #10;
        // ---------------------------------------------------------------
        // Test 4: Prediction = NT, Actual = Taken (mispredicted)
        @(negedge clk);
        IF_pc = 32'h0000_0014;
        IF_imm = 32'd12;
        EX_branch = 1'b0;
        repeat (2) @(negedge clk);

        // mispredicted, prediction counter is now Weakly Taken.
        EX_branch = 1'b1;
        EX_branch_taken = 1'b1; // Target address = 0x0000_0020
        #10;
        // ---------------------------------------------------------------
        // Test 5: Prediction = T, Actual = Taken (well predicted)
        @(negedge clk);
        IF_pc = 32'h0000_0020;
        IF_imm = 32'd8;
        EX_branch = 1'b0;
        repeat (2) @(negedge clk);

        // well predicted, prediction counter is now Strongly Taken.
        EX_branch = 1'b1;
        EX_branch_taken = 1'b1; // Target address = 0x0000_0028
        #10;
        // ---------------------------------------------------------------
        $display("==================== Branch Predictor Test FINISH ====================");
        #40;
        $finish;
    end
endmodule
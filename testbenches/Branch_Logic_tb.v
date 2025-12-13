`timescale 1ns/1ps

`include "modules/headers/branch.vh"

module BranchLogic_tb;
    reg branch;
    reg branch_estimation;
    reg [2:0] funct3;
    reg alu_zero;
    reg [31:0] pc;
    reg [31:0] imm;
    
    wire branch_taken;
    wire [31:0] branch_target_actual;
    wire branch_prediction_miss;

    BranchLogic branch_logic (
        .branch(branch),
        .branch_estimation(branch_estimation),
        .funct3(funct3),
        .alu_zero(alu_zero),
        .pc(pc),
        .imm(imm),

        .branch_taken(branch_taken),
        .branch_target_actual(branch_target_actual),
        .branch_prediction_miss(branch_prediction_miss)
    );

    initial begin
        // Test sequence
        $display("==================== Branch Logic Test START ====================");

        // Initialize signals
        branch = 1'b0;
        branch_estimation = 1'b0;
        funct3 = 3'b0;
        alu_zero = 0;
        pc = 32'h00001000;
        imm = 32'h00000100;
        
        // Test 1: Branch disabled (should output zero)
        $display("\n[Test 1: Branch Disabled]");
        $display("  should be: taken=0, miss=0, target=00000000");
        $display("  result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);
        
        funct3 = 3'b111;
        alu_zero = 1;
        #10;
        $display("  should be: taken=0, miss=0, target=00000000");
        $display("  result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);
        
        // Enable branch for all following tests
        branch = 1;

        // Test 2: BEQ (Branch if Equal)
        $display("\n[Test 2: BEQ - Branch if Equal]");
        $display("PC=%h, IMM=%h (taken target=%h, not-taken target=%h)", 
                 pc, imm, pc + imm, pc + 4);
        
        funct3 = `BRANCH_BEQ;
        
        // Case 1: Predict Not Taken, Actually Taken (MISS)
        branch_estimation = 1'b0;
        alu_zero = 1; // BEQ taken when alu_zero=1
        #10;
        $display("  [Predict NT, Actual T] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=1, miss=1, target=%h (PC+IMM)", pc + imm);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);
        
        // Case 2: Predict Not Taken, Actually Not Taken (HIT)
        branch_estimation = 1'b0;
        alu_zero = 0; // BEQ not taken when alu_zero=0
        #10;
        $display("  [Predict NT, Actual NT] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=0, miss=0, target=%h (PC+4)", pc + 4);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);
        
        // Case 3: Predict Taken, Actually Taken (HIT)
        branch_estimation = 1'b1;
        alu_zero = 1; // BEQ taken when alu_zero=1
        #10;
        $display("  [Predict T, Actual T] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=1, miss=0, target=%h (PC+IMM)", pc + imm);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);
        
        // Case 4: Predict Taken, Actually Not Taken (MISS)
        branch_estimation = 1'b1;
        alu_zero = 0; // BEQ not taken when alu_zero=0
        #10;
        $display("  [Predict T, Actual NT] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=0, miss=1, target=%h (PC+4)", pc + 4);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);

        // Test 3: BNE (Branch if Not Equal)
        $display("\n[Test 3: BNE - Branch if Not Equal]");
        
        funct3 = `BRANCH_BNE;
        
        // Case 1: Predict Not Taken, Actually Taken (MISS)
        branch_estimation = 1'b0;
        alu_zero = 0; // BNE taken when alu_zero=0
        #10;
        $display("  [Predict NT, Actual T] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=1, miss=1, target=%h (PC+IMM)", pc + imm);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);
        
        // Case 2: Predict Taken, Actually Not Taken (MISS)
        branch_estimation = 1'b1;
        alu_zero = 1; // BNE not taken when alu_zero=1
        #10;
        $display("  [Predict T, Actual NT] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=0, miss=1, target=%h (PC+4)", pc + 4);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);

        // Test 4: BLT (Branch if Less Than)
        $display("\n[Test 4: BLT - Branch if Less Than]");
        
        funct3 = `BRANCH_BLT;
        
        // Case 1: Predict Not Taken, Actually Taken (MISS)
        branch_estimation = 1'b0;
        alu_zero = 0; // BLT taken when alu_zero=0
        #10;
        $display("  [Predict NT, Actual T] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=1, miss=1, target=%h (PC+IMM)", pc + imm);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);
        
        // Case 2: Predict Taken, Actually Not Taken (MISS)
        branch_estimation = 1'b1;
        alu_zero = 1; // BLT not taken when alu_zero=1
        #10;
        $display("  [Predict T, Actual NT] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=0, miss=1, target=%h (PC+4)", pc + 4);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);

        // Test 5: BGE (Branch if Greater or Equal)
        $display("\n[Test 5: BGE - Branch if Greater or Equal]");
        
        funct3 = `BRANCH_BGE;
        
        // Case 1: Predict Not Taken, Actually Taken (MISS)
        branch_estimation = 1'b0;
        alu_zero = 1; // BGE taken when alu_zero=1
        #10;
        $display("  [Predict NT, Actual T] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=1, miss=1, target=%h (PC+IMM)", pc + imm);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);
        
        // Case 2: Predict Taken, Actually Not Taken (MISS)
        branch_estimation = 1'b1;
        alu_zero = 0; // BGE not taken when alu_zero=0
        #10;
        $display("  [Predict T, Actual NT] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=0, miss=1, target=%h (PC+4)", pc + 4);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);

        // Test 6: BLTU (Branch if Less Than Unsigned)
        $display("\n[Test 6: BLTU - Branch if Less Than Unsigned]");
        
        funct3 = `BRANCH_BLTU;
        
        // Case 1: Predict Not Taken, Actually Taken (MISS)
        branch_estimation = 1'b0;
        alu_zero = 0; // BLTU taken when alu_zero=0
        #10;
        $display("  [Predict NT, Actual T] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=1, miss=1, target=%h (PC+IMM)", pc + imm);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);
        
        // Case 2: Predict Taken, Actually Not Taken (MISS)
        branch_estimation = 1'b1;
        alu_zero = 1; // BLTU not taken when alu_zero=1
        #10;
        $display("  [Predict T, Actual NT] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=0, miss=1, target=%h (PC+4)", pc + 4);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);

        // Test 7: BGEU (Branch if Greater or Equal Unsigned)
        $display("\n[Test 7: BGEU - Branch if Greater or Equal Unsigned]");
        
        funct3 = `BRANCH_BGEU;
        
        // Case 1: Predict Not Taken, Actually Taken (MISS)
        branch_estimation = 1'b0;
        alu_zero = 1; // BGEU taken when alu_zero=1
        #10;
        $display("  [Predict NT, Actual T] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=1, miss=1, target=%h (PC+IMM)", pc + imm);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);
        
        // Case 2: Predict Taken, Actually Not Taken (MISS)
        branch_estimation = 1'b1;
        alu_zero = 0; // BGEU not taken when alu_zero=0
        #10;
        $display("  [Predict T, Actual NT] est=%b alu_zero=%b", branch_estimation, alu_zero);
        $display("    should be: taken=0, miss=1, target=%h (PC+4)", pc + 4);
        $display("    result:    taken=%b, miss=%b, target=%h", 
                 branch_taken, branch_prediction_miss, branch_target_actual);

        $display("\n====================  Branch Logic Test END  ====================");
        
        $stop;
    end

endmodule
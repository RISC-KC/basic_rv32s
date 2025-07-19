`timescale 1ns/1ps

`include "modules/headers/branch.vh"

module BranchLogic_tb;
	reg branch;
	reg branch_estimation;
    reg [2:0] funct3;
    reg alu_zero;
    
    wire branch_taken;
	wire branch_prediction_miss;

    BranchLogic branch_logic (
        .branch(branch),
		.branch_estimation(branch_estimation),
        .funct3(funct3),
        .alu_zero(alu_zero),

        .branch_taken(branch_taken),
		.branch_prediction_miss(branch_prediction_miss)
    );

    initial begin
        // Test sequence
        $display("==================== Branch Logic Test START ====================");

        branch = 1'b0;
		branch_estimation = 1'b0;
		funct3 = 3'b0;
		alu_zero = 0;
		
        // Test 1: Branch disabled
		$display("[Idle] branch=%b, est=%b -> taken=%b, miss=%b", branch, branch_estimation, branch_taken, branch_prediction_miss);
		
		funct3 = 3'b111;
		alu_zero = 1;
		
		#10;
        $display("[Idle] branch=%b, est=%b -> taken=%b, miss=%b", branch, branch_estimation, branch_taken, branch_prediction_miss);
		
		branch = 1;
		branch_estimation = 1'b0;

		// Test 2: BEQ
		$display("\nBEQ: ");
		
		funct3 = `BRANCH_BEQ;
		
		alu_zero = 1; #10;
        $display("[BEQ miss] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		alu_zero = 0; #10;
        $display("[BEQ hit] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		// Test 2: BNE
		$display("\nBNE: ");
		
		funct3 = `BRANCH_BNE;
		branch_estimation = 1'b1;
		
		alu_zero = 0; #10;
        $display("[BNE hit] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		alu_zero = 1; #10;
        $display("[BNE miss] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		// Test 3: BLT
		$display("\nBLT: ");
		
		funct3 = `BRANCH_BLT;
		
		alu_zero = 1; #10;
        $display("[BNE miss] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		alu_zero = 0; #10;
        $display("[BLT hit] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		// Test 4: BGE
		$display("\nBGE: ");
		
		funct3 = `BRANCH_BGE;
		
		alu_zero = 0; #10;
        $display("[BGE miss] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		alu_zero = 1; #10;
        $display("[BGE hit] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		// Test 5: BLTU
		$display("\nBLTU: ");
		
		funct3 = `BRANCH_BLTU;
		
		alu_zero = 1; #10;
        $display("[BLTU miss] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		alu_zero = 0; #10;
        $display("[BLTU hit] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		// Test 6: BGEU
		$display("\nBGEU: ");
		
		funct3 = `BRANCH_BGEU;
		
		alu_zero = 0; #10;
        $display("[BGEU miss] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		alu_zero = 1; #10;
        $display("[BGEU hit] est=%b alu_zero=%b -> taken=%b, miss=%b", branch_estimation, alu_zero, branch_taken, branch_prediction_miss);
		
		$display("\n====================  Branch Logic Test END  ====================");
		
		$stop;
    end

endmodule
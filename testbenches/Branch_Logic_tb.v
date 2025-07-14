`timescale 1ns/1ps

`include "modules/headers/branch.vh"

module BranchLogic_tb;
	reg branch;
    reg [2:0] funct3;
    reg alu_zero;
    
    wire branch_taken;

    BranchLogic branch_logic (
        .branch(branch),
        .funct3(funct3),
        .alu_zero(alu_zero),

        .branch_taken(branch_taken)
    );

    initial begin
        // Test sequence
        $display("==================== Branch Logic Test START ====================");

        branch = 0;
		funct3 = 3'b0;
		alu_zero = 0;
		
        // Test 1: Branch disabled
		$display("\nBranch disabled: ");
		
		funct3 = 3'b111;
		alu_zero = 1;
		
		#10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		branch = 1;
		
		// Test 2: BEQ
		$display("\nBEQ: ");
		
		funct3 = `BRANCH_BEQ;
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		// Test 2: BNE
		$display("\nBNE: ");
		
		funct3 = `BRANCH_BNE;
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		// Test 3: BLT
		$display("\nBLT: ");
		
		funct3 = `BRANCH_BLT;
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		// Test 4: BGE
		$display("\nBGE: ");
		
		funct3 = `BRANCH_BGE;
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		// Test 5: BLTU
		$display("\nBLTU: ");
		
		funct3 = `BRANCH_BLTU;
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		// Test 6: BGEU
		$display("\nBGEU: ");
		
		funct3 = `BRANCH_BGEU;
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, branch_taken: %b", branch, funct3, alu_zero, branch_taken);
		
		$display("\n====================  Branch Logic Test END  ====================");
		
		$stop;
    end

endmodule

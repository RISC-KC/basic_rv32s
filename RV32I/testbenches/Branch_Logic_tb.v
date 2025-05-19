`timescale 1ns/1ps

`include "modules/headers/branch.vh"

module BranchLogic_tb;
	reg branch;
    reg [2:0] funct3;
    reg alu_zero;
	reg [31:0] pc;
	reg [31:0] imm;
    
    wire branch_taken;
	wire [31:0] branch_target;

    BranchLogic branch_logic (
        .branch(branch),
        .funct3(funct3),
        .alu_zero(alu_zero),
		.pc(pc),
		.imm(imm),

        .branch_taken(branch_taken),
		.branch_target(branch_target)
    );

    initial begin
        // Test sequence
        $display("==================== Branch Logic Test START ====================");

        branch = 0;
		funct3 = 3'b0;
		alu_zero = 0;
		pc = 32'h0;
		imm = 32'h0;
		
        // Test 1: Branch disabled
		$display("\nBranch disabled: ");
		
		funct3 = 3'b111;
		alu_zero = 1;
		
		#10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		branch = 1;
		pc = 32'hDEAD_0000;
		imm = 32'h0000_BEE8;

		// Test 2: BEQ
		$display("\nBEQ: ");
		
		funct3 = `BRANCH_BEQ;
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		// Test 2: BNE
		$display("\nBNE: ");
		
		funct3 = `BRANCH_BNE;
		pc = 32'h1111_0000;
		imm = 32'h0000_BEE8;
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		// Test 3: BLT
		$display("\nBLT: ");
		
		funct3 = `BRANCH_BLT;
		pc = 32'h1111_0000;
		imm = 32'h0000_2220;
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		// Test 4: BGE
		$display("\nBGE: ");
		
		funct3 = `BRANCH_BGE;
		pc = 32'hAAAA_0000;
		imm = 32'h0000_BBBC;
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		// Test 5: BLTU
		$display("\nBLTU: ");
		
		funct3 = `BRANCH_BLTU;
		pc = 32'hCAFE_0000;
		imm = 32'h0000_BEEF;
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		// Test 6: BGEU
		$display("\nBGEU: ");
		
		funct3 = `BRANCH_BGEU;
		pc = 32'hAABB_0000;
		imm = 32'h0000_CCCC;
		
		alu_zero = 0; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		alu_zero = 1; #10;
        $display("branch: %b, funct3: %b, alu_zero: %b, pc: %h, imm: %h, \nbranch_taken: %b, branch_target: %h\n", branch, funct3, alu_zero, pc, imm, branch_taken, branch_target);
		
		$display("\n====================  Branch Logic Test END  ====================");
		
		$stop;
    end

endmodule

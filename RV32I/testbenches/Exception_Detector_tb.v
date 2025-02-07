`timescale 1ns/1ps
`include "modules/headers/opcode.vh"

module ExceptionDetector_tb;
    reg [6:0] opcode;
	reg [2:0] funct3;
	reg [11:0] imm;
	reg [31:0] jump_target;
	reg branch;
	reg [31:0] branch_target;
	
    wire trapped;
	wire [1:0] trap_status;

    ExceptionDetector exception_detector (
        .opcode(opcode),
		.funct3(funct3),
		.imm_0(imm[0]),
		.jump_target_lsbs(jump_target[1:0]),
		.branch(branch),
		.branch_target_lsbs(branch_target[1:0]),
		
    	.trapped(trapped),
		.trap_status(trap_status)
    );

    initial begin
        // Test sequence
        $display("==================== Exception Detector Test START ====================");

        opcode = 7'b0;
		funct3 = 3'b0;
		imm = 12'b0;
		jump_target = 32'b0;
		branch = 0;
		branch_target = 32'b0;

        // Test 1: No exception
		$display("\nNo exception: ");
		
		opcode = `OPCODE_RTYPE;

        #1;
        $display("opcode: %b, trapped: %b, trap_status: %b", opcode, trapped, trap_status);
		
		// Test 2: EBREAK/ECALL
		$display("\nEBREAK/ECALL: ");
		
		opcode = `OPCODE_ENVIRONMENT;
		funct3 = 3'b000;
		
		imm = 12'b000000000001; #1;
        $display("opcode: %b, imm_0: %b, trapped: %b, trap_status: %b", opcode, imm[0], trapped, trap_status);
		
		imm = 12'b000000000000; #1;
        $display("opcode: %b, imm_0: %b, trapped: %b, trap_status: %b", opcode, imm[0], trapped, trap_status);
		
        // Test 3: Address misaligned
		$display("\nAddress misaligned: ");
		
		opcode = `OPCODE_BRANCH;
		
		branch = 0;
		branch_target = 32'h000000F0; #1;
        $display("opcode: %b, branch: %b, branch_target: %h, trapped: %b, trap_status: %b", opcode, branch, branch_target, trapped, trap_status);

        branch_target = 32'h000000F1; #1;
        $display("opcode: %b, branch: %b, branch_target: %h, trapped: %b, trap_status: %b", opcode, branch, branch_target, trapped, trap_status);
		
		branch = 1;
		branch_target = 32'h000000F0; #1;
        $display("opcode: %b, branch: %b, branch_target: %h, trapped: %b, trap_status: %b", opcode, branch, branch_target, trapped, trap_status);

        branch_target = 32'h000000F1; #1;
        $display("opcode: %b, branch: %b, branch_target: %h, trapped: %b, trap_status: %b\n", opcode, branch, branch_target, trapped, trap_status);
		
		branch = 0;
		opcode = `OPCODE_JAL;
		
		jump_target = 32'h000000F0; #1;
        $display("opcode: %b, jump_target: %h, trapped: %b, trap_status: %b", opcode, jump_target, trapped, trap_status);

        jump_target = 32'h000000F1; #1;
        $display("opcode: %b, jump_target: %h, trapped: %b, trap_status: %b", opcode, jump_target, trapped, trap_status);

        opcode = `OPCODE_JALR;
		
		jump_target = 32'h000000F0; #1;
        $display("opcode: %b, jump_target: %h, trapped: %b, trap_status: %b", opcode, jump_target, trapped, trap_status);

        jump_target = 32'h000000F1; #1;
        $display("opcode: %b, jump_target: %h, trapped: %b, trap_status: %b", opcode, jump_target, trapped, trap_status);

        $display("\n====================  Exception Detector Test END  ====================");

        $stop;
    end

endmodule

`timescale 1ns/1ps
`include "modules/headers/opcode.vh"

module ExceptionDetector_tb;
    reg [6:0] opcode;
	reg [2:0] funct3;
    reg [11:0] funct12;         // funct12 12-bit
	reg [31:0] branch_target;   // branch target address
	reg [31:0] alu_result;      // jump target address
	
    wire trapped;
	wire [2:0] trap_status;

    ExceptionDetector exception_detector (
        .opcode(opcode),
		.funct3(funct3),
		.funct12(funct12),
        .branch_target_lsbs(branch_target[1:0]),
		.jump_target_lsbs(alu_result[1:0]),
		
    	.trapped(trapped),
		.trap_status(trap_status)
    );

    initial begin
        // Test sequence
        $display("==================== Exception Detector Test START ====================");

        opcode = 7'b0;
		funct3 = 3'b0;
		funct12 = 12'b0;
		alu_result = 32'b0;

        // Test 1: No exception
		$display("\nNo exception: ");
		
		opcode = `OPCODE_RTYPE;

        #1;
        $display("opcode: %b, trapped: %b, trap_status: %b", opcode, trapped, trap_status);
		
		// Test 2: EBREAK/ECALL
		$display("\nEBREAK/ECALL/MRET: ");
		
		opcode = `OPCODE_ENVIRONMENT;
		funct3 = 3'b000;
		
		funct12 = 12'b000000000001; #1;
        $display("opcode: %b, funct12[0]: %b, trapped: %b, trap_status: %b", opcode, funct12[0], trapped, trap_status);
		
		funct12 = 12'b000000000000; #1;
        $display("opcode: %b, funct12[0]: %b, trapped: %b, trap_status: %b", opcode, funct12[0], trapped, trap_status);
		
        funct12 = 12'b001100000010; #1;
        $display("opcode: %b, funct12: %b, trapped: %b, trap_status: %b", opcode, funct12, trapped, trap_status);

        // Test 3: Address misaligned
		$display("\nAddress misaligned: ");
		
		opcode = `OPCODE_BRANCH;
		
        $display("\nAligned Branch: ");
		branch_target = 32'h000000F0; #1;
        $display("opcode: %b, branch_target: %h, trapped: %b, trap_status: %b", opcode, branch_target, trapped, trap_status);

        $display("\nMisaligned Branch: ");
        branch_target = 32'h000000F1; #1;
        $display("opcode: %b, branch_target: %h, trapped: %b, trap_status: %b", opcode, branch_target, trapped, trap_status);
		
		opcode = `OPCODE_JAL;
		
        $display("\nAligned Jump: ");
		alu_result = 32'h000000F0; #1;
        $display("opcode: %b, alu_result: %h, trapped: %b, trap_status: %b", opcode, alu_result, trapped, trap_status);

        $display("\nMisaligned Jump: ");
        alu_result = 32'h000000F1; #1;
        $display("opcode: %b, alu_result: %h, trapped: %b, trap_status: %b\n", opcode, alu_result, trapped, trap_status);

        opcode = `OPCODE_JALR;
		
        $display("\nAligned Jump: ");
		alu_result = 32'h000000F0; #1;
        $display("opcode: %b, alu_result: %h, trapped: %b, trap_status: %b", opcode, alu_result, trapped, trap_status);

        $display("\nMisaligned Jump: ");
        alu_result = 32'h000000F1; #1;
        $display("opcode: %b, alu_result: %h, trapped: %b, trap_status: %b", opcode, alu_result, trapped, trap_status);

        $display("\n====================  Exception Detector Test END  ====================");

        $stop;
    end

endmodule

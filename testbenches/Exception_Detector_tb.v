`timescale 1ns/1ps
`include "modules/headers/opcode.vh"

module ExceptionDetector_tb;
    reg [6:0] opcode;
	reg [2:0] funct3;
	reg [11:0] imm;
	reg [31:0] next_pc;
	
    wire trapped;
	wire [1:0] trap_status;

    ExceptionDetector exception_detector (
        .opcode(opcode),
		.funct3(funct3),
		.imm_0(imm[0]),
		.next_pc_lsbs(next_pc[1:0]),
		
    	.trapped(trapped),
		.trap_status(trap_status)
    );

    initial begin
        // Test sequence
        $display("==================== Exception Detector Test START ====================");

        opcode = 7'b0;
		funct3 = 3'b0;
		imm = 12'b0;
		next_pc = 32'b0;

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
		
		next_pc = 32'h000000F0; #1;
        $display("opcode: %b, next_pc: %h, trapped: %b, trap_status: %b", opcode, next_pc, trapped, trap_status);

        next_pc = 32'h000000F1; #1;
        $display("opcode: %b, next_pc: %h, trapped: %b, trap_status: %b\n", opcode, next_pc, trapped, trap_status);
		
		opcode = `OPCODE_JAL;
		
		next_pc = 32'h000000F0; #1;
        $display("opcode: %b, next_pc: %h, trapped: %b, trap_status: %b", opcode, next_pc, trapped, trap_status);

        next_pc = 32'h000000F1; #1;
        $display("opcode: %b, next_pc: %h, trapped: %b, trap_status: %b\n", opcode, next_pc, trapped, trap_status);

        opcode = `OPCODE_JALR;
		
		next_pc = 32'h000000F0; #1;
        $display("opcode: %b, next_pc: %h, trapped: %b, trap_status: %b", opcode, next_pc, trapped, trap_status);

        next_pc = 32'h000000F1; #1;
        $display("opcode: %b, next_pc: %h, trapped: %b, trap_status: %b", opcode, next_pc, trapped, trap_status);

        $display("\n====================  Exception Detector Test END  ====================");

        $stop;
    end

endmodule

`timescale 1ns/1ps

`include "modules/headers/branch.vh"
`include "modules/headers/opcode.vh"
`include "modules/headers/rtype.vh"

module ALUController_tb;
	reg [6:0] opcode;
	reg [2:0] funct3;
    reg [6:0] funct7;
    reg [31:0] imm;
	
    wire [3:0] alu_op;

    ALUController alu_controller (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7[5]),
		.imm_10(imm[10]),

        .alu_op(alu_op)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/ALU_Controller_tb_result.vcd");
        $dumpvars(0, ALUController_tb.alu_controller);

        // Test sequence
        $display("==================== ALU Controller Test START ====================");

        // Test 1: R-type
		$display("\nR-type instructions: ");
		
		opcode = `OPCODE_RTYPE;
		imm = 32'h00000000;

		funct3 = `RTYPE_ADDSUB;
		funct7 = 7'b0000000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
        
		funct7 = 7'b0100000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = 3'b001;
		funct7 = 7'b0000000;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = 3'b010; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = 3'b011; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = 3'b100; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = 3'b101; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct7 = 7'b0100000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = 3'b110;
		funct7 = 7'b0000000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = 3'b111; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);

		// Test 2: I-type
        $display("\nI-type instructions: ");
		
		opcode = `OPCODE_ITYPE;
		imm = 32'h00000000;

        funct3 = 3'b000;
		funct7 = 7'b0000000; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		funct3 = 3'b001; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		funct3 = 3'b010; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		funct3 = 3'b011; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);

        funct3 = 3'b100; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);

		funct3 = 3'b101; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		imm = 32'h00000400; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		funct3 = 3'b110;
		imm = 32'h00000000; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		funct3 = 3'b111; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		// Test 3: I-type load
        $display("\nI-type load instructions: ");
		
		opcode = `OPCODE_LOAD;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        funct3 = 3'b000; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = 3'b001; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = 3'b010; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = 3'b100; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = 3'b101; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		// Test 4: I-type jump
        $display("\nI-type jump instruction: ");
		
		opcode = 7'b1100111;
        funct3 = 3'b000;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		// Test 5: S-type
        $display("\nS-type instructions: ");
		
		opcode = `OPCODE_STORE;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        funct3 = 3'b000; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
        funct3 = 3'b001; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
        funct3 = 3'b010; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		// Test 6: B-type
        $display("\nB-type instruction: ");
		
		opcode = `OPCODE_BRANCH;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        funct3 = `BRANCH_BEQ; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `BRANCH_BNE; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `BRANCH_BLT; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `BRANCH_BGE; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `BRANCH_BLTU; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `BRANCH_BGEU; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		// Test 7: I-type CSR
        $display("\nI-type CSR instructions: ");
		
		opcode = `OPCODE_ENVIRONMENT;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        funct3 = 3'b001; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = 3'b010; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = 3'b011; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = 3'b101; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = 3'b110; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = 3'b111; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		// Test 8: Invalid
        $display("\nInvalid instruction: ");
			
		opcode = 7'b0101010; // Doesn't exist!
        funct3 = 3'b000;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		$display("\n====================  ALU Controller Test END  ====================");
		
		$stop;
    end

endmodule

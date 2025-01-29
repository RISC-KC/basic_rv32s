`timescale 1ns/1ps

module ALU_control_tb;
	reg [6:0] opcode;
	reg [2:0] funct3;
    reg [6:0] funct7;
    reg [31:0] imm;
	
    wire [3:0] alu_op;

    ALUControl alu_control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7[5]),
		.imm_10(imm[10]),

        .alu_op(alu_op)
    );

    initial begin
        // Test sequence
        $display("==================== ALU Control Test START ====================");

        // Test 1: R-type
		$display("\nR-type instructions: ");
		
		opcode = 7'b0110011;
        funct3 = 3'b000;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
        
		opcode = 7'b0110011;
        funct3 = 3'b000;
		funct7 = 7'b0100000;
		imm = 32'h00000000;

        #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		opcode = 7'b0110011;
        funct3 = 3'b001;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		opcode = 7'b0110011;
        funct3 = 3'b010;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		opcode = 7'b0110011;
        funct3 = 3'b011;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		opcode = 7'b0110011;
        funct3 = 3'b100;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		opcode = 7'b0110011;
        funct3 = 3'b101;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		opcode = 7'b0110011;
        funct3 = 3'b101;
		funct7 = 7'b0100000;
		imm = 32'h00000000;

        #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		opcode = 7'b0110011;
        funct3 = 3'b110;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		opcode = 7'b0110011;
        funct3 = 3'b111;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);

		// Test 2: I-type
        $display("\nI-type instructions: ");
		
		opcode = 7'b0010011;
        funct3 = 3'b000;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		opcode = 7'b0010011;
        funct3 = 3'b001;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		opcode = 7'b0010011;
        funct3 = 3'b010;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		opcode = 7'b0010011;
        funct3 = 3'b011;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);

        opcode = 7'b0010011;
        funct3 = 3'b100;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);

		opcode = 7'b0010011;
        funct3 = 3'b101;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		opcode = 7'b0010011;
        funct3 = 3'b101;
		funct7 = 7'b0000000;
		imm = 32'h00000400;

        #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		opcode = 7'b0010011;
        funct3 = 3'b110;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		opcode = 7'b0010011;
        funct3 = 3'b111;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		// Test 3: I-type load
        $display("\nI-type load instructions: ");
		
		opcode = 7'b0000011;
        funct3 = 3'b000;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b0000011;
        funct3 = 3'b001;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b0000011;
        funct3 = 3'b010;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b0000011;
        funct3 = 3'b100;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b0000011;
        funct3 = 3'b101;
		funct7 = 7'b0000000;
		imm = 32'h00000000;
		
		// Test 3: I-type jump
        $display("\nI-type jump instruction: ");

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1100111;
        funct3 = 3'b000;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		// Test 4: B-type
        $display("\nB-type instruction: ");
		
		opcode = 7'b1100011;
        funct3 = 3'b000;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1100011;
        funct3 = 3'b001;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1100011;
        funct3 = 3'b100;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1100011;
        funct3 = 3'b101;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1100011;
        funct3 = 3'b110;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1100011;
        funct3 = 3'b111;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		// Test 5: I-type CSR
        $display("\nI-type CSR instructions: ");
		
		opcode = 7'b1110011;
        funct3 = 3'b001;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1110011;
        funct3 = 3'b010;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1110011;
        funct3 = 3'b011;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1110011;
        funct3 = 3'b101;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1110011;
        funct3 = 3'b110;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1110011;
        funct3 = 3'b111;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		opcode = 7'b1110011;
        funct3 = 3'b000; // Doesn't exist!
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		// Test 6: Invalid
        $display("\nInvalid instruction: ");
			
		opcode = 7'b0101010; // Doesn't exist!
        funct3 = 3'b000;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		$display("\n====================  ALU Control Test END  ====================");
		
		$stop;
    end

endmodule

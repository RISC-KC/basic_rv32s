module InstructionDecoder_tb;

    reg [31:0] instr;

    wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;
	wire [31:0] imm;

    InstructionDecoder instruction_decoder (
        .instr(instr),
    
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.imm(imm)
    );

    initial begin
        // Test sequence
        $display("==================== Instruction Decoder Test START ====================");

        // Test 1: R-type
		$display("\nR-type instruction: ");
        instr = 32'b0100000_10101_01010_000_10001_0110011;

 		#10;
        $display("Instruction: %b", instr);
		$display("R: funct7: %b rs2: %b rs1: %b funct3: %b rd: %b opcode: %b", funct7, rs2, rs1, funct3, rd, opcode);

        // Test 2: U-type
		$display("\nU-type instruction: ");
        instr = 32'b11100011111110100010_10101_0010111;

        #10;
        $display("Instruction: %b", instr);
		$display("I: imm: %b rs1: %b funct3: %b rd: %b opcode: %b", imm, rs1, funct3, rd, opcode);
		
		// Test 3: S-type
		$display("\nS-type instruction: ");
        instr = 32'b1000001_11111_10100_010_01110_0100011;

        #10;
        $display("Instruction: %b", instr);
		$display("S: imm[11:5]: %b rs2: %b rs1: %b funct3: %b imm[4:0]: %b opcode: %b", imm[11:5], rs2, rs1, funct3, imm[4:0], opcode);
		
		// Test 4: B-type
		$display("\nB-type instruction: ");
        instr = 32'b1001001_01101_00101_110_11001_1100011;

        #10;
        $display("Instruction: %b", instr);
		$display("B: imm[12|10:5]: %b rs2: %b rs1: %b funct3: %b imm[4:1|11]: %b opcode: %b", {imm[12], imm[10:5]}, rs2, rs1, funct3, {imm[4:1], imm[11]}, opcode);
		
		// Test 5: U-type
		$display("\nU-type instruction: ");
        instr = 32'b00011001110111001010_11100_0010111;

        #10;
        $display("Instruction: %b", instr);
		$display("U: imm[31:12]: %b rd: %b opcode: %b", imm[31:12], rd, opcode);
		
		// Test 6: J-type
		$display("\nJ-type instruction: ");
        instr = 32'b11010001110111001110_00111_1101111;

        #10;
        $display("Instruction: %b", instr);
		$display("J: imm[20|10:1|11|19:12]: %b rd: %b opcode: %b", {imm[20], imm[10:1], imm[11], imm[19:12]}, rd, opcode);

        $display("\n====================  Instruction Decoder Test END  ====================");

        $stop;
    end

endmodule

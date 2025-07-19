`timescale 1ns/1ps

module InstructionDecoder_tb;
    reg [31:0] instruction;

    wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;
	wire [19:0] raw_imm;

    InstructionDecoder instruction_decoder (
        .instruction(instruction),
    
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.raw_imm(raw_imm)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/Instruction_Decoder_tb_result.vcd");
        $dumpvars(0, instruction_decoder);

        // Test sequence
        $display("==================== Instruction Decoder Test START ====================");

        // Test 1: R-type
		$display("\nR-type instruction: ");
        instruction = 32'b0100000_10101_01010_000_10001_0110011;

 		#10;
        $display("Instruction: %b", instruction);
		$display("R: funct7: %b rs2: %b rs1: %b funct3: %b rd: %b opcode: %b", funct7, rs2, rs1, funct3, rd, opcode);
        $display("Reconstruct: %b", {funct7, rs2, rs1, funct3, rd, opcode});

        // Test 2: U-type
		$display("\nU-type instruction: ");
        instruction = 32'b11100011111110100010_10101_0010111;

        #10;
        $display("Instruction: %b", instruction);
		$display("I: raw_imm: %b rs1: %b funct3: %b rd: %b opcode: %b", raw_imm, rs1, funct3, rd, opcode);
        $display("Reconstruct: %b", {raw_imm, rs1, funct3, rd, opcode});
		
		// Test 3: S-type
		$display("\nS-type instruction: ");
        instruction = 32'b1000001_11111_10100_010_01110_0100011;

        #10;
        $display("Instruction: %b", instruction);
		$display("S: raw_imm[11:5]: %b rs2: %b rs1: %b funct3: %b raw_imm[4:0]: %b opcode: %b", raw_imm[11:5], rs2, rs1, funct3, raw_imm[4:0], opcode);
        $display("Reconstruct: %b", {raw_imm[11:5], rs2, rs1, funct3, raw_imm[4:0], opcode});
		
		// Test 4: B-type
		$display("\nB-type instruction: ");
        instruction = 32'b1001001_01101_00101_110_11001_1100011;

        #10;
        $display("Instruction: %b", instruction);
		$display("B: raw_imm[11|9:4]: %b rs2: %b rs1: %b funct3: %b raw_imm[3:0|10]: %b opcode: %b", {raw_imm[11], raw_imm[9:4]}, rs2, rs1, funct3, {raw_imm[3:0], raw_imm[10]}, opcode);
        $display("Reconstruct: %b", {{raw_imm[11], raw_imm[9:4]}, rs2, rs1, funct3, {raw_imm[3:0], raw_imm[10]}, opcode});
		
		// Test 5: U-type
		$display("\nU-type instruction: ");
        instruction = 32'b00011001110111001010_11100_0010111;

        #10;
        $display("Instruction: %b", instruction);
		$display("U: raw_imm[19:0]: %b rd: %b opcode: %b", raw_imm[19:0], rd, opcode);
        $display("Reconstruct: %b", {raw_imm[19:0], rd, opcode});
		
		// Test 6: J-type
		$display("\nJ-type instruction: ");
        instruction = 32'b11010001110111001110_00111_1101111;

        #10;
        $display("Instruction: %b", instruction);
		$display("J: raw_imm[19|9:0|10|18:11]: %b rd: %b opcode: %b", {raw_imm[19], raw_imm[9:0], raw_imm[10], raw_imm[18:11]}, rd, opcode);
        $display("Reconstruct: %b", {{raw_imm[19], raw_imm[9:0], raw_imm[10], raw_imm[18:11]}, rd, opcode});

        $display("\n====================  Instruction Decoder Test END  ====================");

        $stop;
    end

endmodule

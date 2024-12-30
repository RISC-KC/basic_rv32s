module InstructionDecoder_tb;

    reg [31:0] instr;

    wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;
	wire [19:0] imm;

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
        $display("Starting Instruction Decoder Test...");

        // Test 1: U, J type
        instr = 32'b00000000000000000000101010010111;

        #10;
        $display("Instruction: %b, opcode: %b, rd: %b, funct3: %b, rs1: %b, rs2: %b, funct7: %b, imm: %b", instr, opcode, rd, funct3, rs1, rs2, funct7, imm);

        // WIP

        $stop;
    end

endmodule

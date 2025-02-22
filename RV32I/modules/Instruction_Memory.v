`include "modules/headers/opcode.vh"

module InstructionMemory (
    input  [31:0] pc,
    output reg [31:0] instruction
);

	// 총 39개의 명령어를 저장 (인덱스 0 ~ 38)
	reg [31:0] data [0:38];
	
	initial begin
        data[0] = {-12'd2, 5'd0, 3'b000, 5'd1, `OPCODE_ITYPE}; // x1 = -2
        data[1] = {12'd3, 5'd0, 3'b000, 5'd2, `OPCODE_ITYPE}; // x2 = 3
		// ──────────────────────────────────────────────
		// R‑타입 명령어 (10개)
		// {funct7, rs2, rs1, funct3, rd, OPCODE_RTYPE}
		data[2] = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3,  `OPCODE_RTYPE}; // ADD: x3 = x1 + x2 = 1
		data[3] = {7'b0100000, 5'd2, 5'd1, 3'b000, 5'd4,  `OPCODE_RTYPE}; // SUB: x4 = x1 - x2 = -1
		data[4] = {7'b0000000, 5'd2, 5'd1, 3'b001, 5'd5,  `OPCODE_RTYPE}; // SLL: x5 = x1 << x2 = -16
		data[5] = {7'b0000000, 5'd2, 5'd1, 3'b010, 5'd6,  `OPCODE_RTYPE}; // SLT: x6 = (x1 < x2) ? 1 : 0 = 1
		data[6] = {7'b0000000, 5'd2, 5'd1, 3'b011, 5'd7,  `OPCODE_RTYPE}; // SLTU: x7 = (x1 < x2 unsigned) ? 1 : 0 = 0
		data[7] = {7'b0000000, 5'd2, 5'd1, 3'b100, 5'd8,  `OPCODE_RTYPE}; // XOR: x8 = x1 XOR x2 = 
		data[8] = {7'b0000000, 5'd2, 5'd1, 3'b101, 5'd9,  `OPCODE_RTYPE}; // SRL: x9 = x1 >> x2 (논리적)
		data[9] = {7'b0100000, 5'd2, 5'd1, 3'b101, 5'd10, `OPCODE_RTYPE}; // SRA: x10 = x1 >> x2 (산술적)
		data[10] = {7'b0000000, 5'd2, 5'd1, 3'b110, 5'd11, `OPCODE_RTYPE}; // OR:  x11 = x1 OR x2
		data[11] = {7'b0000000, 5'd2, 5'd1, 3'b111, 5'd12, `OPCODE_RTYPE}; // AND: x12 = x1 AND x2

		// ──────────────────────────────────────────────
		// S‑타입 명령어 (스토어) (3개)
		// {imm[11:5], rs2, rs1, funct3, imm[4:0], OPCODE_STORE}
		data[12] = {7'd0, 5'd3, 5'd0, 3'b000, 5'd1, `OPCODE_STORE}; // SB: mem[x0+1] = x3
		data[13] = {7'd0, 5'd4, 5'd0, 3'b001, 5'd2, `OPCODE_STORE}; // SH: mem[x0+2] = x4
		data[14] = {7'd0, 5'd5, 5'd0, 3'b010, 5'd4, `OPCODE_STORE}; // SW: mem[x0+4] = x5

		// ──────────────────────────────────────────────
		// I‑타입 ALU 명령어 (9개)
		// {imm[11:0], rs1, funct3, rd, OPCODE_ITYPE}
		data[15] = {12'd10, 5'd1, 3'b000, 5'd13, `OPCODE_ITYPE};         // ADDI: x13 = x1 + 10
		data[16] = {12'd3,  5'd1, 3'b001, 5'd14, `OPCODE_ITYPE};          // SLLI: x14 = x1 << 3
		data[17] = {12'd5,  5'd1, 3'b010, 5'd15, `OPCODE_ITYPE};          // SLTI: x15 = (x1 < 5) ? 1 : 0
		data[18] = {12'd6,  5'd1, 3'b011, 5'd16, `OPCODE_ITYPE};          // SLTIU: x16 = (x1 < 6) ? 1 : 0
		data[19] = {12'd7,  5'd1, 3'b100, 5'd17, `OPCODE_ITYPE};          // XORI: x17 = x1 XOR 7
		data[20] = {12'd2,  5'd1, 3'b101, 5'd18, `OPCODE_ITYPE};          // SRLI: x18 = x1 >> 2 (논리적)
		data[21] = {12'b010000000010, 5'd1, 3'b101, 5'd19, `OPCODE_ITYPE}; // SRAI: x19 = x1 >> 2 (산술적)
		data[22] = {12'd3,  5'd1, 3'b110, 5'd20, `OPCODE_ITYPE};          // ORI:  x20 = x1 OR 3
		data[23] = {12'd1,  5'd1, 3'b111, 5'd21, `OPCODE_ITYPE};          // ANDI: x21 = x1 AND 1

		// ──────────────────────────────────────────────
		// I‑타입 로드 명령어 (5개)
		// {imm[11:0], rs1, funct3, rd, OPCODE_LOAD}
		data[24] = {12'd0, 5'd5, 3'b010, 5'd22, `OPCODE_LOAD}; // LW:  x22 = mem[x5 + 0]
		data[25] = {12'd4, 5'd4, 3'b001, 5'd23, `OPCODE_LOAD}; // LH:  x23 = mem[x4 + 4]
		data[26] = {12'd6, 5'd3, 3'b000, 5'd24, `OPCODE_LOAD}; // LB:  x24 = mem[x3 + 6]
		data[27] = {12'd6, 5'd4, 3'b100, 5'd25, `OPCODE_LOAD}; // LBU: x25 = mem[x4 + 6]
		data[28] = {12'd4, 5'd5, 3'b101, 5'd26, `OPCODE_LOAD}; // LHU: x26 = mem[x5 + 4]

		// ──────────────────────────────────────────────
		// I‑타입 점프 (JALR) 명령어 (1개)
		// {imm[11:0], rs1, funct3, rd, OPCODE_JALR}
		data[29] = {12'd0, 5'd3, 3'b000, 5'd1, `OPCODE_JALR}; // JALR: x1 = PC+4; 점프 대상: x3+0

		// ──────────────────────────────────────────────
		// B‑타입 명령어 (분기) (6개)
		// {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], OPCODE_BRANCH}
		data[30] = {1'b0, 6'd0, 5'd2, 5'd1, 3'b000, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BEQ: if(x1==x2) branch offset = 8
		data[31] = {1'b0, 6'd0, 5'd2, 5'd1, 3'b001, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BNE: if(x1!=x2) branch offset = 8
		data[32] = {1'b0, 6'd0, 5'd2, 5'd1, 3'b100, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BLT: if(x1 < x2) branch offset = 8
		data[33] = {1'b0, 6'd0, 5'd2, 5'd1, 3'b101, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BGE: if(x1 >= x2) branch offset = 8
		data[34] = {1'b0, 6'd0, 5'd2, 5'd1, 3'b110, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BLTU: if(x1 < x2 unsigned) branch offset = 8
		data[35] = {1'b0, 6'd0, 5'd2, 5'd1, 3'b111, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BGEU: if(x1 >= x2 unsigned) branch offset = 8

		// ──────────────────────────────────────────────
		// U‑타입 명령어 (2개)
		// {imm[31:12], rd, OPCODE_LUI 또는 OPCODE_AUIPC}
		data[36] = {20'd1000, 5'd3, `OPCODE_LUI};    // LUI: x3 = 1000 << 12
		data[37] = {20'd2000, 5'd4, `OPCODE_AUIPC};  // AUIPC: x4 = PC + (2000 << 12)

		// ──────────────────────────────────────────────
		// J‑타입 명령어 (1개)
		// {imm[20|10:1|11|19:12] (직접 20비트 상수로 처리), rd, OPCODE_JAL}
		data[38] = {20'd1, 5'd1, `OPCODE_JAL};       // JAL: jump offset = 1, rd = x1
	end
	
	always @(*) begin
		if (pc[31:2] < 39) begin
			instruction = data[pc[31:2]];
		end
		else begin
			instruction = 32'b0;
		end
	end

endmodule

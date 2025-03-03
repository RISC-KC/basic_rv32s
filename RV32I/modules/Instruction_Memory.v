`include "modules/headers/branch.vh"
`include "modules/headers/itype.vh"
`include "modules/headers/load.vh"
`include "modules/headers/rtype.vh"
`include "modules/headers/store.vh"
`include "modules/headers/opcode.vh"

module InstructionMemory (
    input  [31:0] pc,
    output reg [31:0] instruction
);

	reg [31:0] data [0:1023];
	
	initial begin
		$readmemb("modules/initial_data.mem", data);

		// ──────────────────────────────────────────────
		// I‑타입 ALU 명령어 (9개)
		// {imm[11:0], rs1, funct3, rd, OPCODE_ITYPE}
		data[0] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd1, `OPCODE_ITYPE};				// ADDI:  x1 = x0 + 2BC = 000002BC
		data[1] = {12'd24,  5'd1, `ITYPE_SLLI, 5'd2, `OPCODE_ITYPE};				// SLLI:  x2 = x1 << 24 = BC000000
		data[2] = {12'd0,  5'd2, `ITYPE_SLTI, 5'd3, `OPCODE_ITYPE};					// SLTI:  x3 = (x2(-1140850688d) < 0) ? 1 : 0 = 00000001
		data[3] = {12'd0,  5'd2, `ITYPE_SLTIU, 5'd4, `OPCODE_ITYPE};				// SLTIU: x4 = (x2(3154116608d) < 0) ? 1 : 0 = 00000000
		data[4] = {12'h653,  5'd1, `ITYPE_XORI, 5'd5, `OPCODE_ITYPE};				// XORI:  x5 = x1 XOR 653 = 000004EF
		data[5] = {7'b0000000, 5'd4, 5'd2, `ITYPE_SRXI, 5'd6, `OPCODE_ITYPE};		// SRLI:  x6 = x2 >> 4 = 0BC00000
		data[6] = {7'b0100000, 5'd4, 5'd2, `ITYPE_SRXI, 5'd7, `OPCODE_ITYPE};		// SRAI:  x7 = x2 >>> 4 = FBC00000
		data[7] = {12'h0BC, 5'd2, `ITYPE_ORI, 5'd8, `OPCODE_ITYPE};					// ORI:   x8 = x2 OR BC = BC0000BC
		data[8] = {12'h0EC, 5'd5, `ITYPE_ANDI, 5'd9, `OPCODE_ITYPE};				// ANDI:  x9 = x5 AND 0EC = 000000EC

		// ──────────────────────────────────────────────
		// R‑타입 명령어 (10개)
		// {funct7, rs2, rs1, funct3, rd, OPCODE_RTYPE}
		data[9]  = {7'b0000000, 5'd9, 5'd1, `RTYPE_ADDSUB, 5'd10, `OPCODE_RTYPE};	// ADD: x10 = x1 + x9 = 000003A8
		data[10] = {7'b0100000, 5'd5, 5'd6, `RTYPE_ADDSUB, 5'd11, `OPCODE_RTYPE};	// SUB: x11 = x6 - x5 = 0BBFFB11
		data[11] = {7'b0000000, 5'd3, 5'd7, `RTYPE_SLL, 5'd12, `OPCODE_RTYPE};		// SLL: x12 = x7 << x3 = F7800000
		data[12] = {7'b0000000, 5'd2, 5'd1, `RTYPE_SLT, 5'd13, `OPCODE_RTYPE};		// SLT: x13 = (x1 < x2) ? 1 : 0 = 00000000
		data[13] = {7'b0000000, 5'd2, 5'd1, `RTYPE_SLTU, 5'd14, `OPCODE_RTYPE};		// SLTU: x14 = (x1 < x2 unsigned) ? 1 : 0 = 00000001
		data[14] = {7'b0000000, 5'd8, 5'd12, `RTYPE_XOR, 5'd15, `OPCODE_RTYPE};		// XOR: x15 = x12 XOR x8 = 4B8000BC
		data[15] = {7'b0000000, 5'd3, 5'd12, `RTYPE_SR, 5'd16, `OPCODE_RTYPE};		// SRL: x16 = x12 >> x3 = 7BC00000
		data[16] = {7'b0100000, 5'd3, 5'd12, `RTYPE_SR, 5'd17, `OPCODE_RTYPE};		// SRA: x17 = x12 >>> x3 = FBC0000
		data[17] = {7'b0000000, 5'd7, 5'd11, `RTYPE_OR, 5'd18, `OPCODE_RTYPE};		// OR:  x18 = x11 OR x7 = FBFFFB11
		data[18] = {7'b0000000, 5'd11, 5'd7, `RTYPE_AND, 5'd19, `OPCODE_RTYPE};		// AND: x19 = x7 AND x11 = 0B800000

		// ──────────────────────────────────────────────
		// S‑타입 명령어 (스토어) (3개)
		// {imm[11:5], rs2, rs1, funct3, imm[4:0], OPCODE_STORE}
		data[19] = {7'd0, 5'd11, 5'd1, `STORE_SW, 5'd4, `OPCODE_STORE};				// SW: mem[x1+4 = 2C0] = (x11 = 0BBFFB11) -> 0BBFFB11
		data[20] = {7'd0, 5'd10, 5'd1, `STORE_SH, 5'd7, `OPCODE_STORE};				// SH: mem[x1+7 = 2C3 (write nothing)] = (x10[15:0] = 03A8) -> 0BBFFB11
		data[21] = {7'd0, 5'd15, 5'd1, `STORE_SB, 5'd4, `OPCODE_STORE};				// SB: mem[x1+4 = 2C0] = (x15[7:0] = BC) -> 0BBFFBBC

		// ──────────────────────────────────────────────
		// I‑타입 로드 명령어 (5개)
		// {imm[11:0], rs1, funct3, rd, OPCODE_LOAD}
		data[22] = {12'd5, 5'd1, `LOAD_LW, 5'd20, `OPCODE_LOAD};					// LW:  x20 = mem[x1+5 = 2C1 (but read from 2C0)] = 0BBFFBBC
		data[23] = {12'd4, 5'd1, `LOAD_LH, 5'd21, `OPCODE_LOAD};					// LH:  x21 = (mem[x1+4 = 2C0])[15:0] = FBBC (FFFFFBBC)
		data[24] = {12'd4, 5'd1, `LOAD_LB, 5'd22, `OPCODE_LOAD};					// LB:  x22 = (mem[x1+4 = 2C0])[7:0] = BC (FFFFFFBC)
		data[25] = {12'd4, 5'd1, `LOAD_LHU, 5'd23, `OPCODE_LOAD};					// LHU: x23 = (mem[x1+4 = 2C0])[15:0] = FBBC (0000FBBC)
		data[26] = {12'd4, 5'd1, `LOAD_LBU, 5'd24, `OPCODE_LOAD};					// LBU: x24 = (mem[x1+4 = 2C0])[7:0] = BC (000000BC)

		// ──────────────────────────────────────────────
		// U‑타입 명령어 (2개)
		// {imm[31:12], rd, OPCODE_LUI/OPCODE_AUIPC}
		data[27] = {20'd1, 5'd25, `OPCODE_LUI};										// LUI: x25 = 00001000
		data[28] = {20'd1, 5'd26, `OPCODE_AUIPC};									// AUIPC: x26 = 00000070 + 00001000 = 00001070

		// ──────────────────────────────────────────────
		// J‑타입 명령어 (1개)
		// {imm[20|10:1|11|19:12], rd, OPCODE_JAL}
		data[29] = {20'b0_0000001111_0_00000000, 5'd27, `OPCODE_JAL};				// JAL: PC + 0000001E = 00000092 (but jump to 00000090), x27 = PC + 4 = 00000078

		// ──────────────────────────────────────────────
		// I‑타입 점프 (JALR) 명령어 (1개)
		// {imm[11:0], rs1, funct3, rd, OPCODE_JALR}
		data[36] = {12'd0, 5'd27, 3'b000, 5'd28, `OPCODE_JALR}; 					// JALR: x28 = PC + 4 = 00000094; PC = x27 + 00000000 = 00000078

		// ──────────────────────────────────────────────
		// B‑타입 명령어 (분기) (6개)
		// {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], OPCODE_BRANCH}
		data[30] = {1'b0, 6'd0, 5'd2, 5'd1, `BRANCH_BEQ, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BEQ: if(x1 == x2) branch offset = 8
		data[31] = {1'b0, 6'd0, 5'd17, 5'd7, `BRANCH_BNE, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BNE: if(x7 != x17) branch offset = 8
		data[32] = {1'b0, 6'd0, 5'd2, 5'd1, `BRANCH_BLT, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BLT: if(x1 < x2) branch offset = 8
		data[33] = {1'b0, 6'd0, 5'd1, 5'd2, `BRANCH_BGE, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BGE: if(x2 >= x1) branch offset = 8
		data[34] = {1'b0, 6'd0, 5'd1, 5'd2, `BRANCH_BLTU, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BLTU: if(x2 < x1 unsigned) branch offset = 8
		data[35] = {1'b0, 6'd0, 5'd1, 5'd2, `BRANCH_BGEU, 4'b0100, 1'b0, `OPCODE_BRANCH}; // BGEU: if(x2 >= x1 unsigned) branch offset = 8
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

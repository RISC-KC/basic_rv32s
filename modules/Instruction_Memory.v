`include "modules/headers/branch.vh"
`include "modules/headers/itype.vh"
`include "modules/headers/load.vh"
`include "modules/headers/rtype.vh"
`include "modules/headers/store.vh"
`include "modules/headers/opcode.vh"
`include "modules/headers/csr.vh"

module InstructionMemory (
    input [31:0] pc,
    output reg [31:0] instruction,

	input [31:0] rom_address,
	output reg [31:0] rom_read_data
);

	reg [31:0] data [0:2047];	// in FPGA, 16384.
	integer i;
	initial begin
		// $readmemh("./dhrystone.mem", data);
		for (i=0; i<2048; i=i+1) begin
			data[i] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};
		end
		// ──────────────────────────────────────────────
		// I-타입 ALU 명령어 (9개)
		// {imm[11:0], rs1, funct3, rd, OPCODE_ITYPE}
		data[0] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd1, `OPCODE_ITYPE};				// ADDI:  x1 = x0 + 2BC = 000002BC
		data[1] = {12'd24,  5'd1, `ITYPE_SLLI, 5'd2, `OPCODE_ITYPE};				// SLLI:  x2 = x1 << 24 = BC000000
		data[2] = {12'd0,  5'd2, `ITYPE_SLTI, 5'd3, `OPCODE_ITYPE};				// SLTI:  x3 = (x2(-1140850688d) < 0) ? 1 : 0 = 00000001
		data[3] = {12'd0,  5'd2, `ITYPE_SLTIU, 5'd4, `OPCODE_ITYPE};				// SLTIU: x4 = (x2(3154116608d) < 0) ? 1 : 0 = 00000000
		data[4] = {12'h653,  5'd1, `ITYPE_XORI, 5'd5, `OPCODE_ITYPE};			// XORI:  x5 = x1 XOR 653 = 000004EF
		data[5] = {7'b0000000, 5'd4, 5'd2, `ITYPE_SRXI, 5'd6, `OPCODE_ITYPE};	// SRLI:  x6 = x2 >> 4 = 0BC00000
		data[6] = {7'b0100000, 5'd4, 5'd2, `ITYPE_SRXI, 5'd7, `OPCODE_ITYPE};	// SRAI:  x7 = x2 >>> 4 = FBC00000
		data[7] = {12'h0BC, 5'd2, `ITYPE_ORI, 5'd8, `OPCODE_ITYPE};				// ORI:   x8 = x2 OR BC = BC0000BC
		data[8] = {12'h0EC, 5'd5, `ITYPE_ANDI, 5'd9, `OPCODE_ITYPE};				// ANDI:  x9 = x5 AND 0EC = 000000EC

		// ──────────────────────────────────────────────
		// R-타입 명령어 (10개)
		// {funct7, rs2, rs1, funct3, rd, OPCODE_RTYPE}
		data[9]  = {7'b0000000, 5'd9, 5'd1, `RTYPE_ADDSUB, 5'd10, `OPCODE_RTYPE};	// ADD: x10 = x1 + x9 = 000003A8
		data[10] = {7'b0100000, 5'd5, 5'd6, `RTYPE_ADDSUB, 5'd11, `OPCODE_RTYPE};	// SUB: x11 = x6 - x5 = 0BBFFB11
		data[11] = {7'b0000000, 5'd3, 5'd7, `RTYPE_SLL, 5'd12, `OPCODE_RTYPE};		// SLL: x12 = x7 << x3 = F7800000
		data[12] = {7'b0000000, 5'd2, 5'd1, `RTYPE_SLT, 5'd13, `OPCODE_RTYPE};		// SLT: x13 = (x1 < x2) ? 1 : 0 = 00000000
		data[13] = {7'b0000000, 5'd2, 5'd1, `RTYPE_SLTU, 5'd14, `OPCODE_RTYPE};		// SLTU: x14 = (x1 < x2 unsigned) ? 1 : 0 = 00000001
		data[14] = {7'b0000000, 5'd8, 5'd12, `RTYPE_XOR, 5'd15, `OPCODE_RTYPE};		// XOR: x15 = x12 XOR x8 = 4B8000BC
		data[15] = {7'b0000000, 5'd3, 5'd12, `RTYPE_SR, 5'd16, `OPCODE_RTYPE};		// SRL: x16 = x12 >> x3 = 7BC00000
		data[16] = {7'b0100000, 5'd3, 5'd12, `RTYPE_SR, 5'd17, `OPCODE_RTYPE};		// SRA: x17 = x12 >>> x3 = FBC00000
		data[17] = {7'b0000000, 5'd7, 5'd11, `RTYPE_OR, 5'd18, `OPCODE_RTYPE};		// OR:  x18 = x11 OR x7 = FBFFFB11
		data[18] = {7'b0000000, 5'd11, 5'd7, `RTYPE_AND, 5'd19, `OPCODE_RTYPE};		// AND: x19 = x7 AND x11 = 0B800000

		// ──────────────────────────────────────────────
		// S-타입 명령어 (스토어) (3개)
		// {imm[11:5], rs2, rs1, funct3, imm[4:0], OPCODE_STORE}
		data[19] = {7'd0, 5'd11, 5'd1, `STORE_SW, 5'd4, `OPCODE_STORE};				// SW: mem[x1+4 = 2C0] = (x11 = 0BBFFB11) -> 0BBFFB11	
		data[20] = {7'd0, 5'd10, 5'd1, `STORE_SH, 5'd7, `OPCODE_STORE};				// SH: mem[x1+7 = 2C3 (write nothing)] = (x10[15:0] = 03A8) -> 0BBFFB11 // Misaligned Memory exception. NOPs and goes to Trap Handler.
		data[21] = {7'd0, 5'd15, 5'd1, `STORE_SB, 5'd4, `OPCODE_STORE};				// SB: mem[x1+4 = 2C0] = (x15[7:0] = BC) -> 0BBFFBBC	

		// ──────────────────────────────────────────────
		// I-타입 로드 명령어 (5개) - RAM 접근을 위해 x1 주소 변경
		// {imm[11:0], rs1, funct3, rd, OPCODE_LOAD}
		
		// x1을 1000_02BC로 변경 (RAM 영역 접근용)
		data[22] = {20'h10000, 5'd31, `OPCODE_LUI};									// LUI: x31 = 0x10000000
		data[23] = {7'b0000000, 5'd31, 5'd1, `RTYPE_OR, 5'd1, `OPCODE_RTYPE};		// OR:  x1 = x1 | x31 = 0x100002BC

		data[24] = {12'd5, 5'd1, `LOAD_LW, 5'd20, `OPCODE_LOAD};						// LW:  x20 = mem[x1+5 = 100002C1] = misaligned exception
		data[25] = {12'd4, 5'd1, `LOAD_LH, 5'd21, `OPCODE_LOAD};						// LH:  x21 = mem[x1+4 = 100002C0][15:0]
		data[26] = {12'd4, 5'd1, `LOAD_LB, 5'd22, `OPCODE_LOAD};						// LB:  x22 = mem[x1+4 = 100002C0][7:0]
		data[27] = {12'd4, 5'd1, `LOAD_LHU, 5'd23, `OPCODE_LOAD};					// LHU: x23 = mem[x1+4 = 100002C0][15:0]
		data[28] = {12'd4, 5'd1, `LOAD_LBU, 5'd24, `OPCODE_LOAD};					// LBU: x24 = mem[x1+4 = 100002C0][7:0]

		// x1을 다시 0000_02BC로 복원
		data[29] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd1, `OPCODE_ITYPE};				// ADDI: x1 = 0x000002BC

		// ──────────────────────────────────────────────
		// U-타입 명령어 (2개)
		// {imm[31:12], rd, OPCODE_LUI/OPCODE_AUIPC}
		data[30] = {20'd1, 5'd25, `OPCODE_LUI};										// LUI: x25 = 00001000		
		data[31] = {20'd1, 5'd26, `OPCODE_AUIPC};									// AUIPC: x26 = 0000007C + 00001000 = 0000107C

		// ──────────────────────────────────────────────
		// J-타입 명령어 (1개)
		// {imm[20|10:1|11|19:12], rd, OPCODE_JAL}
		data[32] = {20'b0_0000001111_0_00000000, 5'd27, `OPCODE_JAL};				// JAL: PC(0x80) + 0x1E = 0x9E (misaligned), x27 = PC + 4 = 0x84
		// But since this instruction occurs exception, It's handled as NOP.

		// ──────────────────────────────────────────────
		// B-타입 명령어 (분기) (6개)
		// {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], OPCODE_BRANCH}
		data[33] = {1'b0, 6'd0, 5'd2, 5'd1, `BRANCH_BEQ, 4'b0100, 1'b0, `OPCODE_BRANCH}; 	// BEQ: if(x1 == x2) branch offset = 8		Not Taken	
		data[34] = {1'b0, 6'd0, 5'd13, 5'd0, `BRANCH_BNE, 4'b0100, 1'b0, `OPCODE_BRANCH}; 	// BNE: if(x0 != x13) branch offset = 8		Not Taken
		data[35] = {1'b0, 6'd0, 5'd2, 5'd1, `BRANCH_BLT, 4'b0100, 1'b0, `OPCODE_BRANCH}; 	// BLT: if(x1 < x2) branch offset = 8		Not Taken (x2 = signed negative)
		data[36] = {1'b0, 6'd0, 5'd1, 5'd2, `BRANCH_BGE, 4'b0100, 1'b0, `OPCODE_BRANCH}; 	// BGE: if(x2 >= x1) branch offset = 8		Not Taken (x2 = signed negative)
		data[37] = {1'b0, 6'd0, 5'd1, 5'd2, `BRANCH_BLTU, 4'b0100, 1'b0, `OPCODE_BRANCH}; 	// BLTU: if(x2 < x1 unsigned) branch offset = 8		Not Taken 
		data[38] = {1'b0, 6'd0, 5'd1, 5'd2, `BRANCH_BGEU, 4'b0100, 1'b0, `OPCODE_BRANCH}; 	// BGEU: if(x2 >= x1 unsigned) branch offset = 8	Taken -> data[40]

		// ──────────────────────────────────────────────
		// I-타입 점프 (JALR) 명령어 (1개)
		// {imm[11:0], rs1, funct3, rd, OPCODE_JALR}
		data[39] = {12'd0, 5'd27, 3'b000, 5'd28, `OPCODE_JALR}; 						// JALR: x28 = PC + 4 = 0xA0; PC = x27 + 0 = 0x84

		// ──────────────────────────────────────────────
		// I-타입 Zicsr 확장 명령어 (6개)	[F11] == mvendorid, [341] = mepc, [342] = mcause, [305] = mtvec
		// {imm[11:0], rs1(uimm), funct3, rd, OPCODE_ENVIRONMENT}
		data[40] = {12'hF11, 5'd28, `CSR_CSRRW, 5'd20, `OPCODE_ENVIRONMENT}; 		// CSRRW : x28 = 0000_0000; x20 = 5256_4B43 <= CSR[F11] = 5256_4B43 // R[x20] = 5256_4B43.
		data[41] = {12'h341, 5'd1, `CSR_CSRRS, 5'd21, `OPCODE_ENVIRONMENT}; 			// CSRRS: x1 = 0000_02BC; CSR[341] = 0000_0074. 					// R[x21] = 0000_0074, CSR[341] = 0000_02fc
		data[42] = {12'h341, 5'd20, `CSR_CSRRC, 5'd21, `OPCODE_ENVIRONMENT}; 		// CSRRC: x21 = 0000_0074, x20 = 5256_4B43, CSR[341] = 0000_02fc. 	// R[x21] = 0000_02fc, CSR[341] = 0000_00BC 
		data[43] = {12'h342, 5'd3, `CSR_CSRRWI, 5'd22, `OPCODE_ENVIRONMENT}; 		// CSRRWI: x22 = FFFF_FFBC, CSR[342] = 0000_0000; 					// R[x22] = 0000_0000, CSR[342] = 0000_0003
		data[44] = {12'h305, 5'd7, `CSR_CSRRSI, 5'd22, `OPCODE_ENVIRONMENT}; 		// CSRRSI: x22 = 0000_0000, CSR[305] = 0000_1000; 					// R[x22] = 0000_1000, CSR[305] = 0000_1007
		data[45] = {12'h305, 5'b11111, `CSR_CSRRCI, 5'd23, `OPCODE_ENVIRONMENT}; 	// CSRRCI: uimm = 11111, CSR[305] = 0000_1007; 						// R[x23] = 0000_1007, CSR[305] = 0000_1000

		// ──────────────────────────────────────────────
		// I-타입 HINT 명령어 (CSR 동작 확인)
		// {imm[11:0], rs1, funct3, rd, OPCODE_ITYPE}
		data[46] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};				// ADDI:  x0 = x0 + 2BC = 0000_0000

		// ──────────────────────────────────────────────
		// ECALL 명령어, Misaligned Instruction address exception 발생 JALR 명령어, Misaligned Memory Address access exception 발생 SH 명령어
		data[47] = {12'd0, 5'd0, 3'd0, 5'd0, `OPCODE_ENVIRONMENT}; 					// ECALL: PC = CSR[mtvec] = 0000_1000 = data[1024]
		data[48] = {12'd1, 5'd27, 3'b000, 5'd28, `OPCODE_JALR}; 						// JALR: x28 = PC + 4 = 0xC4; PC = x27 + 1 = 0x85 -> misaligned
		data[49] = {7'b0, 5'd5, 5'd1, `STORE_SH, 5'd1, `OPCODE_STORE};				// SH: mem[x1+1 = 2BD, misaligned] = (x5[15:0] = 04EF) misaligned exception..

		// ──────────────────────────────────────────────
		// Debug Interface 명령어 수행을 위한 전초 작업. 기존 x22 값 FFFF_FFBC 값을 더하는 ADD 명령어를 DI에서 수행할 예정
		data[50] = {20'd0, 5'd22, `OPCODE_LUI};										// LUI: x22 = 0000_0000
		data[51] = {12'hFBC, 5'd22, `ITYPE_ADDI, 5'd22, `OPCODE_ITYPE};				// ADDI x22 = x22 - 0x44 = FFFF_FFBC
		data[52] = {20'hABADC, 5'd23, `OPCODE_LUI};									// LUI: x23 = ABAD_C000
		data[53] = {12'hB02, 5'd23, `ITYPE_ADDI, 5'd23, `OPCODE_ITYPE};				// ADDI:  x23 = x23 + -4FE = ABAD_BB02

		// ──────────────────────────────────────────────
		// printf 수행을 위한 MMIO Interface 테스트벤치 명령어. SB to 0x10010000, store "ABADBEBE" = UART로 출력
		data[54] = {1'b0, 10'b0000000110, 1'b0, 8'b0, 5'd0, `OPCODE_JAL};			// JAL x0, +12: data[57]로 분기

		data[55] = {12'd1, 5'd0, 3'd0, 5'd0, `OPCODE_ENVIRONMENT};					// EBREAK: 
																					// └ADD: x22 = x22 + x23. FFFF_FFBC(x22) + ABAD_BB02(x23) = ABAD_BABE(x22)

		// HINT; NOP for 'x' signal after EBREAK in pipeline
		data[56] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};				// ADDI:  x0 = x0 + 2BC = 0000_0000
		
		// ──────────────────────────────────────────────
		// UART MMIO 테스트: 0x10010000에 "ABADBEBE" 출력 (Polling 추가)
		data[57] = {20'h10010, 5'd29, `OPCODE_LUI};									// LUI: x29 = 0x10010000 (UART TX Data 주소)
		data[58] = {12'h004, 5'd29, `ITYPE_ADDI, 5'd28, `OPCODE_ITYPE};				// ADDI: x28 = x29 + 4 = 0x10010004 (UART Status 주소)

		// 'A' 전송
		data[59] = {12'h041, 5'd0, `ITYPE_ADDI, 5'd31, `OPCODE_ITYPE};				// ADDI: x31 = 'A' (0x41)
		data[60] = {12'd0, 5'd28, `LOAD_LW, 5'd30, `OPCODE_LOAD};					// LW x30, 0(x28): Status 레지스터 읽기
		data[61] = {12'd1, 5'd30, `ITYPE_ANDI, 5'd30, `OPCODE_ITYPE};				// ANDI x30, x30, 1: busy bit 마스킹
		data[62] = {1'b1, 6'b111111, 5'd0, 5'd30, `BRANCH_BNE, 4'b1100, 1'b1, `OPCODE_BRANCH}; // BNE x30, x0, -8: busy이면 data[60]로 재시도
		data[63] = {7'd0, 5'd31, 5'd29, `STORE_SB, 5'd0, `OPCODE_STORE};				// SB: mem[x29+0] = 'A'

		// 'B' 전송
		data[64] = {12'h042, 5'd0, `ITYPE_ADDI, 5'd31, `OPCODE_ITYPE};				// ADDI: x31 = 'B' (0x42)
		data[65] = {12'd0, 5'd28, `LOAD_LW, 5'd30, `OPCODE_LOAD};					// LW x30, 0(x28): Status 레지스터 읽기
		data[66] = {12'd1, 5'd30, `ITYPE_ANDI, 5'd30, `OPCODE_ITYPE};				// ANDI x30, x30, 1: busy bit 마스킹
		data[67] = {1'b1, 6'b111111, 5'd0, 5'd30, `BRANCH_BNE, 4'b1100, 1'b1, `OPCODE_BRANCH}; // BNE x30, x0, -8: busy이면 data[65]로 재시도
		data[68] = {7'd0, 5'd31, 5'd29, `STORE_SB, 5'd0, `OPCODE_STORE};				// SB: mem[x29+0] = 'B'

		// 'A' 전송
		data[69] = {12'h041, 5'd0, `ITYPE_ADDI, 5'd31, `OPCODE_ITYPE};				// ADDI: x31 = 'A' (0x41)
		data[70] = {12'd0, 5'd28, `LOAD_LW, 5'd30, `OPCODE_LOAD};					// LW x30, 0(x28): Status 레지스터 읽기
		data[71] = {12'd1, 5'd30, `ITYPE_ANDI, 5'd30, `OPCODE_ITYPE};				// ANDI x30, x30, 1: busy bit 마스킹
		data[72] = {1'b1, 6'b111111, 5'd0, 5'd30, `BRANCH_BNE, 4'b1100, 1'b1, `OPCODE_BRANCH}; // BNE x30, x0, -8: busy이면 data[70]로 재시도
		data[73] = {7'd0, 5'd31, 5'd29, `STORE_SB, 5'd0, `OPCODE_STORE};				// SB: mem[x29+0] = 'A'

		// 'D' 전송
		data[74] = {12'h044, 5'd0, `ITYPE_ADDI, 5'd31, `OPCODE_ITYPE};				// ADDI: x31 = 'D' (0x44)
		data[75] = {12'd0, 5'd28, `LOAD_LW, 5'd30, `OPCODE_LOAD};					// LW x30, 0(x28): Status 레지스터 읽기
		data[76] = {12'd1, 5'd30, `ITYPE_ANDI, 5'd30, `OPCODE_ITYPE};				// ANDI x30, x30, 1: busy bit 마스킹
		data[77] = {1'b1, 6'b111111, 5'd0, 5'd30, `BRANCH_BNE, 4'b1100, 1'b1, `OPCODE_BRANCH}; // BNE x30, x0, -8: busy이면 data[75]로 재시도
		data[78] = {7'd0, 5'd31, 5'd29, `STORE_SB, 5'd0, `OPCODE_STORE};				// SB: mem[x29+0] = 'D'

		// 'B' 전송
		data[79] = {12'h042, 5'd0, `ITYPE_ADDI, 5'd31, `OPCODE_ITYPE};				// ADDI: x31 = 'B' (0x42)
		data[80] = {12'd0, 5'd28, `LOAD_LW, 5'd30, `OPCODE_LOAD};					// LW x30, 0(x28): Status 레지스터 읽기
		data[81] = {12'd1, 5'd30, `ITYPE_ANDI, 5'd30, `OPCODE_ITYPE};				// ANDI x30, x30, 1: busy bit 마스킹
		data[82] = {1'b1, 6'b111111, 5'd0, 5'd30, `BRANCH_BNE, 4'b1100, 1'b1, `OPCODE_BRANCH}; // BNE x30, x0, -8: busy이면 data[80]로 재시도
		data[83] = {7'd0, 5'd31, 5'd29, `STORE_SB, 5'd0, `OPCODE_STORE};				// SB: mem[x29+0] = 'B'

		// 'E' 전송
		data[84] = {12'h045, 5'd0, `ITYPE_ADDI, 5'd31, `OPCODE_ITYPE};				// ADDI: x31 = 'E' (0x45)
		data[85] = {12'd0, 5'd28, `LOAD_LW, 5'd30, `OPCODE_LOAD};					// LW x30, 0(x28): Status 레지스터 읽기
		data[86] = {12'd1, 5'd30, `ITYPE_ANDI, 5'd30, `OPCODE_ITYPE};				// ANDI x30, x30, 1: busy bit 마스킹
		data[87] = {1'b1, 6'b111111, 5'd0, 5'd30, `BRANCH_BNE, 4'b1100, 1'b1, `OPCODE_BRANCH}; // BNE x30, x0, -8: busy이면 data[85]로 재시도
		data[88] = {7'd0, 5'd31, 5'd29, `STORE_SB, 5'd0, `OPCODE_STORE};				// SB: mem[x29+0] = 'E'

		// 'B' 전송
		data[89] = {12'h042, 5'd0, `ITYPE_ADDI, 5'd31, `OPCODE_ITYPE};				// ADDI: x31 = 'B' (0x42)
		data[90] = {12'd0, 5'd28, `LOAD_LW, 5'd30, `OPCODE_LOAD};					// LW x30, 0(x28): Status 레지스터 읽기
		data[91] = {12'd1, 5'd30, `ITYPE_ANDI, 5'd30, `OPCODE_ITYPE};				// ANDI x30, x30, 1: busy bit 마스킹
		data[92] = {1'b1, 6'b111111, 5'd0, 5'd30, `BRANCH_BNE, 4'b1100, 1'b1, `OPCODE_BRANCH}; // BNE x30, x0, -8: busy이면 data[90]로 재시도
		data[93] = {7'd0, 5'd31, 5'd29, `STORE_SB, 5'd0, `OPCODE_STORE};				// SB: mem[x29+0] = 'B'

		// 'E' 전송
		data[94] = {12'h045, 5'd0, `ITYPE_ADDI, 5'd31, `OPCODE_ITYPE};				// ADDI: x31 = 'E' (0x45)
		data[95] = {12'd0, 5'd28, `LOAD_LW, 5'd30, `OPCODE_LOAD};					// LW x30, 0(x28): Status 레지스터 읽기
		data[96] = {12'd1, 5'd30, `ITYPE_ANDI, 5'd30, `OPCODE_ITYPE};				// ANDI x30, x30, 1: busy bit 마스킹
		data[97] = {1'b1, 6'b111111, 5'd0, 5'd30, `BRANCH_BNE, 4'b1100, 1'b1, `OPCODE_BRANCH}; // BNE x30, x0, -8: busy이면 data[95]로 재시도
		data[98] = {7'd0, 5'd31, 5'd29, `STORE_SB, 5'd0, `OPCODE_STORE};				// SB: mem[x29+0] = 'E'

		data[99] = {1'b1, 10'b1110101000, 1'b1, 8'b11111111, 5'd0, `OPCODE_JAL};		// JAL x0, -176: data[55]로 분기 (EBREAK로 돌아가기)

		// ──────────────────────────────────────────────
		// Trap Handler 시작 주소. mtvec = 0000_1000 = 4096 ÷ 4 Byte = 1024
		// Trap Handler 진입 시 기존 GPR의 레지스터 내용들을 별도의 메모리 Heap 구역에 store하고 수행해야하지만, 현재 단계에서는 생략함.
		// CSR mcause 확인해서 ecall이면 x1 = 0000_0000으로 만들기, misaligned면 x2에 FF더하기
		// 조건 분기; 비교문 작성을 위한 적재 작업
		data[1024] = {12'h342, 5'd0, 3'b010, 5'd6, `OPCODE_ENVIRONMENT}; 					// csrrs x6, mcause, x0:	레지스터 x6에 mcause값 적재
		data[1025] = {12'd11, 5'd0, `ITYPE_ADDI, 5'd7, `OPCODE_ITYPE};						// addi x7, x0, 11: 		레지스터 x7에 ECALL 코드 값 11 적재
		data[1026] = {12'd2, 5'd0, `ITYPE_ADDI, 5'd8, `OPCODE_ITYPE};						// addi x8, x0, 2: 			레지스터 x8에 ILLEGAL INSTRUCTION 코드 값 2 적재
		data[1027] = {12'd4, 5'd0, `ITYPE_ADDI, 5'd9, `OPCODE_ITYPE};						// addi x9, x0, 4: 			레지스터 x9에 MISALIGNED LOAD 코드 값 4 적재
		data[1028] = {12'd6, 5'd0, `ITYPE_ADDI, 5'd10, `OPCODE_ITYPE};						// addi x10, x0, 6: 		레지스터 x10에 MISALIGNED STORE 코드 값 6 적재

		// mcause 분석해서 해당하는 Trap Handler 주소로 분기
		data[1029] = {1'b0, 6'b0, 5'd7, 5'd6, `BRANCH_BEQ, 4'b1100, 1'b0, `OPCODE_BRANCH};	// beq x6, x7, +24: 		ECALL; x6과 x7이 같다면 24바이트 이후 주솟값으로 분기 = data[1035]
		data[1030] = {1'b0, 6'd0, 5'd0, 5'd6, `BRANCH_BEQ, 4'b1110, 1'b0, `OPCODE_BRANCH};	// beq x6, x0, +28: 		MISALIGNED INSTRUCTION; x6값이 0과 같다면 28바이트 이후 주솟값으로 분기 = data[1037]
		data[1031] = {1'b0, 6'd0, 5'd10, 5'd6, `BRANCH_BEQ, 4'b1100, 1'b0, `OPCODE_BRANCH};	// beq x6, x10, +24: 		MISALIGNED STORE; x6값이 x10과 같다면 24바이트 이후 주솟값으로 분기 = data[1037]
		data[1032] = {1'b0, 6'd0, 5'd9, 5'd6, `BRANCH_BEQ, 4'b1010, 1'b0, `OPCODE_BRANCH};	// beq x6, x9, +20: 		MISALIGNED LOAD; x6값이 x9와 같다면 20바이트 이후 주솟값으로 분기 = data[1037]
		data[1033] = {1'b0, 6'd0, 5'd8, 5'd6, `BRANCH_BEQ, 4'b1000, 1'b0, `OPCODE_BRANCH};	// beq x6, x8, +16: 		ILLEGAL; x6값이 x8과 같다면 16바이트 이후 주솟값으로 분기 = data[1037]
		data[1034] = {1'b0, 10'b000_0001_000, 1'b0, 8'b0, 5'd0, `OPCODE_JAL};				// jal x0, +16: 			TH 끝내기 (mret 명령어 주소로 가기)
		
		// ECALL Trap Handler @ data[1035]
		data[1035] = {12'd0, 5'd0, `ITYPE_ADDI, 5'd1, `OPCODE_ITYPE};						// addi x1, x0, 0: 			레지스터 x1 값 0으로 비우기
		data[1036] = {1'b0, 10'b000_0000_100, 1'b0, 8'b0, 5'd0, `OPCODE_JAL};				// jal x0, +8:				TH 끝내기 (mret 명령어 주소로 가기)

		// ILLEGAL / MISALIGNED Trap Handler @ data[1037]
		data[1037] = {12'hFF, 5'd2, `ITYPE_ADDI, 5'd30, `OPCODE_ITYPE};						// addi x30, x2, 255: 		x30 레지스터에 x2(BC00_0000) + 0xFF = bc00_00ff

		// ESCAPE Trap Handler @ data[1038]
		data[1038] = {12'b001100000010, 5'b0, 3'b0, 5'b0, `OPCODE_ENVIRONMENT};				// MRET: PC = CSR[mepc]

		// HINT; NOP for 'x' signal after MRET in pipeline
		data[1039] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};						// ADDI:  x0 = x0 + 2BC = 0000_0000
		data[1040] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};						// ADDI:  x0 = x0 + 2BC = 0000_0000
		data[1041] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};						// ADDI:  x0 = x0 + 2BC = 0000_0000
		data[1042] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};						// ADDI:  x0 = x0 + 2BC = 0000_0000
	end
	
	always @(*) begin
		instruction = data[pc[31:2]];
	end

	wire rom_access = (rom_address[31:16] == 16'h0000);
	always @(*) begin
		if (rom_access) begin
			rom_read_data = data[rom_address[15:2]];
		end else begin
			rom_read_data = 32'b0;
		end
	end
endmodule
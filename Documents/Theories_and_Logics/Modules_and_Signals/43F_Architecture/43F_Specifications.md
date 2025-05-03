# 43F Architecture
ISA : RISC-V RV32I (except fence, environment instructions)
(RV32I except FENCE, FENCE.TSO, PAUSE, EBREAK, ECALL)

- [Modules]
Format : Name 			(Acronyms)	[Inputs / Outputs] ; 												In + Out = Signals count

- Program Control
Program Counter 		(PC)		[NextPC, CLK, rst / PC];											3 + 1 = 4 Signals
PC Controller			(PCC)	 	[Jump, BTaken, PC, imm, J_Target / U_NextPC];						5 + 1 = 7 Signals
PC Aligner							[U_NextPC / NextPC]													1 + 1 = 2 Signals

- Memory Units
Instruction Memory		(IM)		[PC / IM_RD];														1 + 1 = 2 Signals
Instruction Decoder		(ID)		[I_RD(IM_RD) / opcode, funct3, funct7, rs1, rs2, rd, raw_imm];		1 + 7 = 8 Signals
Register File			(RegF)		[RA1(rs1), RA2(rs2), RegWrite, RF_WA(rd), RF_WD, CLK / RD1, RD2];	6 + 2 = 8 Signals
Data Memory				(DM)		[MemWrite, DM_WD(BEDM_WD), ByteMask, DM_Addr, CLK / DM_RD];			5 + 1 = 6 Signals
+ CSR File				(CSRF)		[CSRwrite, CSR_Addr(raw_imm), CSR_WD(ALUresult), CLK, RST 
									/ CSR_RD];															5 + 1 = 6 Signals

- Controls
Control Unit			(CU)		[opcode, funct3 / Jump, Branch, ALUsrcA, ALUsrcB,
									RegWDsrc, MemRead, MemWrite, RegWrite, CSRwrite];					2 + 8 = 10 Signals
ALU Controller			(ALUcon)	[opcode, funct3, funct7, raw_imm / ALUop];							4 + 1 = 5 Signals

- Executions
Arithmetic Logic Unit	(ALU)		[ALUop, srcA, srcB / ALUzero, ALUresult];							3 + 2 = 5 Signals
Branch Logic						[Branch, funct3, ALUzero / B_Taken];								3 + 1 = 4 Signals
Byte Enable Logic		(BE_Logic)	[RF2DM_RD, DM2RF_RD, MemWrite, MemRead, funct3, address(ALUresult)
									/ BEDM_WD, BERF_WD, WriteMask];										6 + 3 = 9 Signals
Immediate Generator		(imm_get)	[opcode, raw_imm / imm];											2 + 1 = 3 Signals
PCplus4					(PC+4)		[PC, 4 / PC+4];														2 + 1 = 3 Signals

- MUXs
+ ALUsrcMUX_A					[ALUsrcA, RD1, PC, rs1 / srcA];												4 + 1 = 5 Signals
+ ALUsrcMUX_B					[ALUsrcB, RD2, imm, shamt(imm[4:0]), CSR(CSR_RD) / srcB];					5 + 1 = 6 Signals
+ RegF_WD_MUX					[RegWDsrc, D_RD(DM_RD), ALUresult, CSR_RD, imm, PC+4 / RF_WD];				6 + 1 = 7 Signals
# 46F Architecture
Based on 43F Architecture
Now supports Environment instructions (ECALL, EBREAK) with mret SYSTEM instruction for trap handling

ISA : RISC-V RV32I, Zicsr, mret
(RV32I except FENCE, FENCE.TSO, PAUSE)

- [Modules]
Format : Name 			(Acronyms)	[Inputs / Outputs] ; 												In + Out = Signals count

- Program Control
Program Counter 		(PC)		[NextPC, CLK, RST / PC];											3 + 1 = 4 Signals
+ PC Controller			(PCC)	 	[PCC_op, PC, B_Target, J_Target, T_Target 
									/ NextPC];															5 + 1 = 6 Signals
+ Debug Interface		(DI)		[DBG.instr];														0 + 1 = 1 Signals
+ Exception Detector	(ED)		[funct12, opcode, funct3, J_Target, B_Target 
									/ Trapped, Trap_Status];											5 + 2 = 7 Signals
+ Trap Controller		(TC)		[Trap_Status, PC, CSR_RD, CLK, RST
									/ T_Target, Trap_Done, Dbg.Mode, CSR_WE, CSR_T.Addr, CSR_T.WD];		5 + 6 = 11 Signals

- Memory Units
Instruction Memory		(IM)		[PC / IM_RD];														1 + 1 = 2 Signals
Instruction Decoder		(ID)		[I_RD(IM_RD) / opcode, funct3, funct7, rs1, rs2, rd, raw_imm];		1 + 7 = 8 Signals
Register File			(RegF)		[RA1(rs1), RA2(rs2), RegWrite, RF_WA(rd), RF_WD, CLK / RD1, RD2];	6 + 2 = 8 Signals
CSR File				(CSRF)		[CSRwrite, CSR_Addr(raw_imm), CSR_WD(ALUresult), CLK, RST 
									/ CSR_RD];															5 + 1 = 6 Signals
Data Memory				(DM)		[MemWrite, DM_WD(BEDM_WD), ByteMask, DM_Addr, CLK / DM_RD];			5 + 1 = 6 Signals

- Controls
+ Control Unit			(CU)		[opcode, funct3, B_Taken, Trapped, Trap_Done,  
									/ PCC_op, Branch, ALUsrcA, ALUsrcB,
									RegWDsrc, MemRead, MemWrite, RegWrite, CSRwrite];					5 + 9 = 14 Signals
ALU Controller			(ALUcon)	[opcode, funct3, funct7, raw_imm / ALUop];							4 + 1 = 5 Signals

- Executions
Arithmetic Logic Unit	(ALU)		[ALUop, srcA, srcB / ALUzero, ALUresult];							3 + 2 = 5 Signals
+ Branch Logic						[Branch, funct3, ALUzero, PC, imm / B_Taken, B_Target];				5 + 2 = 7 Signals
Byte Enable Logic		(BE_Logic)	[RF2DM_RD, DM2RF_RD, MemWrite, MemRead, funct3, address(ALUresult)
									/ BEDM_WD, BERF_WD, WriteMask];										6 + 3 = 9 Signals
Immediate Generator		(imm_get)	[opcode, raw_imm / imm];											2 + 1 = 3 Signals
PCplus4					(PC+4)		[PC, 4 / PC+4];														2 + 1 = 3 Signals

- MUXs
ALUsrcMUX_A					[ALUsrcA, RD1, PC, rs1 / srcA];											4 + 1 = 5 Signals
ALUsrcMUX_B					[ALUsrcB, RD2, imm, shamt(imm[4:0]), CSR(CSR_RD) / srcB];				5 + 1 = 6 Signals
RegF_WD_MUX					[RegWDsrc, D_RD, ALUresult, CSR_RD, imm, PC+4 / RF_WD];					6 + 1 = 7 Signals

+ CSR_Addr_MUX				[Trapped, raw_imm, CSR_T.Addr / CSR_Addr];								3 + 1 = 4 Signals
+ CSR_WD_MUX				[Trapped, CSR_T.WD, ALUresult / CSR_WD];								3 + 1 = 4 Signals
+ DBG_RD_MUX				[Dbg.Mode, IA_RD, DBG.instr / I_RD];									3 + 1 = 4 Signals

+ CSR_Write_Enable_OR		[CSR_Write(Control Unit), CSR_WE(Trap Controller) / CSR_Write]			2 + 1 = 3 Signals
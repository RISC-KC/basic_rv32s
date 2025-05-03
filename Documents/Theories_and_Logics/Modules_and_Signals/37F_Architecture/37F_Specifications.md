# 37F Architecture
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

- Controls
Control Unit			(CU)		[opcode, funct3 / Jump, Branch, ALUsrcA, ALUsrcB,
									RegWDsrc, MemRead, MemWrite, RegWrite];								2 + 8 = 10 Signals
ALU Controller			(ALUcon)	[opcode, funct3, funct7, raw_imm / ALUop];							4 + 1 = 5 Signals

- Executions
Arithmetic Logic Unit	(ALU)		[ALUop, srcA, srcB / ALUzero, ALUresult];							3 + 2 = 5 Signals
Branch Logic						[Branch, funct3, ALUzero / B_Taken];								3 + 1 = 4 Signals
Byte Enable Logic		(BE_Logic)	[RF2DM_RD, DM2RF_RD, MemWrite, MemRead, funct3, address(ALUresult)
									/ BEDM_WD, BERF_WD, WriteMask];										6 + 3 = 9 Signals
Immediate Generator		(imm_get)	[opcode, raw_imm / imm];											2 + 1 = 3 Signals
PCplus4					(PC+4)		[PC, 4 / PC+4];														2 + 1 = 3 Signals

- MUXs
ALUsrcMUX_A					[ALUsrcA, RD1, PC / srcA];													3 + 1 = 5 Signals
ALUsrcMUX_B					[ALUsrcB, RD2, imm, shamt(imm[4:0]) / srcB];								4 + 1 = 5 Signals
RegF_WD_MUX					[RegWDsrc, D_RD(DM_RD), ALUresult, imm, PC+4 / RF_WD];						5 + 1 = 6 Signals
 
Register File (Reg, RegF)
└레지스터들로 이루어진 집합. RISC-V의 약속에 따른 레지스터 가이드라인이 있다.
 x0~x31까지 어떤 레지스터들로 이뤄져야하는지에 대한 내용. 꼭 참조할 것.
 무튼 RA1, RA2로 각각 rs1, rs2에 해당하는 주솟값들을 받아 그 주솟값에 해당하는 데이터 값을 RD1, RD2로 출력한다.
 WA는 Write Address로 쓰기 작업을 실행할 주솟값을 받고, RF_WD는 쓸 데이터를 받는 입력신호이다.
 
Data Memory (DM)
└하버드 구조에 따라 이원화된 메모리 중 데이터를 담당하는 메모리이다. 명령어가 아닌 데이터들이 저장된다.
 Memwrite 신호를 받아 쓰기를 활성화하고, MemRead는 구버전 설계에 있었지만 현재는 비동기식 읽기를 지원하는 Asynchronous Memory (비동기식 메모리) 로 구현하기로 했기에 없앴다. 
 ByteMask는 BE_Logic에서 출력한 '어디에 쓰기를 해야하는지'에 대한 지점의 주소 정보 값이다. 이를 토대로 쓰기를 진행하게 된다. 
 DM_Addr에서 읽기 쓰기 주소를 모두 받아옵니다.
 Memory의 접근은 무조건 rs값 + imm의 간접 주소 지정방식이기에 ALUresult에서 받아온다.
 
Control Unit (CU)
└opcode 신호를 입력받아 그에 해당하는 모듈들에 제어 신호를 보내는 모듈이다.

ALU Controller (ALUcon)
└CU에서 ALUop신호를 받고, funct3, funct7신호를 ID에서 받아 어떤 형식의 ALU연산인지 판단하고,
 연산의 종류를 ALUcontrol에게 보내는 방식이다. 이걸 CU에서 물론 처리할 수 있지만,
 차후 여러 명령어 확장이 더해졌을 때 유지보수 및 복잡성 증가로 인해 ALU관련 Control을 별도 모듈로 이원화한 것이다. 
 이러면 유지보수가 쉬워지고 직관성이 뚜렷해진다.
 
Arithmetic Logic Unit (ALU)
└ALUcontrol 신호를 ALUControl모듈에게서 받아 srcA, srcB를 그에 맞게 처리하여 ALUresult로 출력한다.
 ALUzero신호로 0인지 0이 아닌지를 구별하여 Branch Logic에 출력한다.
 B타입 명령어는 비교연산을 통해 분기의 유무를 판단하므로 ALUzero신호가 필요하다.
 ALUresult는 37F에서 DM의 Address신호, Register File의 RF_WD신호, BE_Logic 모듈로 마스킹하기위한 주소 신호(address), PCC의 J_Target으로 출력된다. 
 
Branch Logic
└분기를 결정하는 로직 모듈이다.
 Branch 활성화 신호를 CU(Control Unit)에서 받고, funct3의 값을 보고 어떤 분기인지 확인하며
 그 조건식이 충족됐는지를 ALUzero의 값을 보고 판단한다. 
 충족됐으면 BTaken신호를 PCC로 출력하고, 충족, 미충족인지를 PCC가 판단하여 프로그램의 진행을 판단한다. 
 
Byte Enable Logic (BE_Logic)
└비트 정렬 로직.
 Load(적재; Register File에서 Memory로) 명령어나 Store(저장; Memory에서 Register로) 명령어를 보면, 워드 단위가 아니라 하프워드(2바이트), 바이트(8비트)단위로 쪼개지기도 한다. 
 그에 맞게 명령어에서 지정한 위치에 데이터를 쓰기 위한 로직 처리 모듈이다.
 RF에서 DM으로, DM에서 RF로. 쓰기 작업시엔 해당 데이터가 무조건 BE_Logic을 거친다.
 워드단위면 ByteMask가 0000, 즉 원본 데이터가 그대로 통과한다.
 하프워드나 바이트 단위가 되면 그 위치를 BE_Logic이 Bit Masking 로직을 통해 처리하여 출력한다.
 판단 식별 신호는 funct3의 값을 받아서 명령어의 유형(워드, 하프 워드, 바이트)을 확인하여 처리한다.

 [예시]
 기존 값 : 0xDEAD_BEEF, 쓰려는 값 0x1111_1111
 Mask : 0000 (word) -> 결과 : 0x1111_1111
 Mask : 1100 (half-word) -> 결과 : 0x1111_BEEF
 Mask : 0110 (half-word) -> 결과 : 0xDE11_11EF
 Mask : 0011 (half-word) -> 결과 : 0xDEAD_1111
 Mask : 1000 (byte) -> 결과 : 0x11AD_BEEF
 Mask : 0100 (byte) -> 결과 : 0xDE11_BEEF
 Mask : 0010 (byte) -> 결과 : 0xDEAD_11EF
 Mask : 0001 (byte) -> 결과 : 0xDEAD_BE11

 이런 식이다. 

Immediate Generator (imm_gen)
└상수 생성기. 명령어에는 immediate 즉 상수 값이 12~20비트로 인코딩되어있다. 
 이처럼 명령어에 인코딩된 12~20비트의 순수 상수값을 본 아키텍처에서 raw_imm 칭한다.
 이 raw_imm을 처리 가능한 규격인 32-bit로 Sign-Extension해서 imm이라는 신호로 출력한다. 
 
PCplus4 (PC+4)
└jalr 명령어는 jump 이후 현재 PC값에서 +4한 값을 레지스터에 저장한다. 
 이를 위해 PCplus4모듈을 따로 넣고 이걸 RegF_WD_MUX에 연결하였다. 
 PCC에 있는 PC+4로직을 응용하려 했는데 별도 모듈로 빼는 것이 구조적 직관성이 좋아 그렇게 했고, 필요하다면 PCC에 내장할 수 있다. 

ALUsrcA_MUX
└ALU의 srcA에 들어갈 신호를 선택하는 2:1 MUX. 
 제어신호 : ALUsrcA ( from Control Unit )
 입력신호 : RD1, PC 
 두 가지 입력신호들 중 제어 신호에 따라 출력신호 선택.
 이 경우, 1-bit MUX로 설계한다. 
 0 = RD1, 1 = PC

ALUsrcB_MUX
└ALU의 srcB에 들어갈 신호를 선택하는 3:1 MUX. 
 제어신호 : ALUsrcB ( from Control Unit )
 입력신호 : RD2, imm, shamt(imm[4:0])
 세 가지 입력신호들 중 제어신호에 따라 출력신호 선택.
 이 경우, 2-bit MUX로 설계한다.
 00 = RD2
 01 = imm
 10 = shamt(imm[4:0])

RegF_WD_MUX
└RF에 쓸 데이터를 정하는 MUX. 
 제어신호 : RegWDsrc ( Register Write Data srouce; from Control Unit )
 입력신호 : ALUresult, D_RD( DM_RD, Data Memory Read Data; BERF_WD from Data Memory through BE_Logic ), imm( directrly from imm_gen only for LUI instruction ), PC+4
 네 가지 입력신호들 중 제어신호에 따라 출력신호 선택. 
 이 경우, 3-bit MUX로 설계한다. 
 000 = DM_RD
 001 = ALUresult
 010 = reserved for Zicsr extension
 011 = imm
 100 = PC+4
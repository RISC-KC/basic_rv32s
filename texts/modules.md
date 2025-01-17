- [Modules]
Format : Name 				[Inputs, Outputs] ; 											In + Out = Signals count

Program Counter 			[NextPC, CLK, rst, PC];											3 + 1 = 4 Signals
Program Counter Controller 	[PC, Jump, BTaken, J_Target, B_Target, NextPC];					5 + 1 = 6 Signals
Instruction Memory			[PC, IM_RD];													1 + 1 = 2 Signals
Instruction Decoder			[IM_RD, opcode, funct3, funct7, rs1, rs2, rd, imm, CSR_addr];	1 + 8 = 9 Signals
Register File				[RA1, RA2, RW, WA, RF_WD, CLK, RD1, RD2];						6 + 2 = 8 Signals
CSR Register File			[CSR_enable, CSRop, CSR_addr, CSR_WD, CLK, RST, CSR_RD];		6 + 1 = 7 Signals
Data Memory					[MemWrite, MemRead, DM_WriteData, ALUresult(address),
							ByteMask(WriteMask), CLK, rst, DM_RD];							7 + 1 = 8 Signals
Control Unit				[opcode, funct3, ALUsrcA, ALUsrcB, ALUop, CSRop, Branch, 
							Jump, MemWrite, MemRead, Memory2Reg, RegWrite, CSRenable];		2 + 11 = 13 Signals
ALU Controller				[ALUop, funct3, funct7, ALUcontrol];							3 + 1 = 4 Signals
Arithmetic Logic Unit		[ALUcontrol, srcA, srcB, ALUzero, ALUresult];					3 + 2 = 5 Signals
Branch Logic				[Branch, ALUzero, funct3, B_Taken];								3 + 1 = 4 Signals
BE_Logic					[MemWrite, MemRead, DM2RF_RD, RF2DM_RD, BEaddress, funct3, 
							BERF_WD, BEDM_WD, WriteMask];									6 + 3 = 9 Signals
J_Aligner					[ALUresult, J_Target];											1 + 1 = 2 Signals
PCplus4						[PC, 4, PC+4];													2 + 1 = 3 Signals
Immediate Generator			[imm, ex_imm];													1 + 1 = 2 Signals
CSR_WD_MUX					[CSRsrc, ALUresult, ex_imm, CSR_WD];							3 + 1 = 4 Signals
ALUsrcMUX_A					[ALUsrcA, RD1, PC, CSR_RD, srcA];								4 + 1 = 5 Signals
ALUsrcMUX_B					[ALUsrcB, RD2, ex_imm, CSR_RD, srcB];							4 + 1 = 5 Signals
RegF_WD_MUX					[Mem2Reg, ALUresult, DM_RD, PC+4, CSR_RD, RF_WD];				5 + 1 = 6 Signals


Program Counter
└현재 실행할 명령어의 주소를 Instruction Memory로 출력한다.
PCController
└PC모듈을 컨트롤한다. 다음 PC가 가르킬 주소 신호인 NextPC를 PC에 출력한다.
 Branch시 B_Target의 주솟값을 NextPC로, Jump시 J_Target의 주솟값을 NextPC로.
 둘 다 아닐 경우 PC에서 +4 한 값을 NextPC로 출력한다.
 (RV32I의 명령어 길이 32bit = 4Byte.)
Instruction Memory
└명령어들이 담아져 있는 메모리. PC로 부터 받은 주소에 해당하는 명령어를
 Instruction Decoder에 출력한다. 
Instruction Decoder
└IM에서 받은 명령어의 비트 체계에 따라 각 모듈로 신호를 전달한다.
 opcode를 기반하여 무슨 타입의 명령어인지 판별하고, 그에 맞게 해당하는 모듈들에 신호를 출력한다.
Control Unit
└opcode 신호를 입력받아 그에 해당하는 모듈들에 제어 신호를 보내는 모듈이다.
ALU Control
└CU에서 ALUop신호를 받고, funct3, funct7신호를 ID에서 받아 어떤 형식의 ALU연산인지 판단하고,
 연산의 종류를 ALUcontrol에게 보내는 방식이다. 이걸 CU에서 물론 처리할 수 있지만,
 차후 여러 명령어 확장이 더해졌을 때 유지보수 및 복잡성 증가로 인해 ALU관련 Control을 별도 모듈로 이원화한 것이다. 
 이러면 유지보수가 쉬워지고 직관성이 뚜렷해진다.
ALU
└예. ALU입니다. ALUcontrol 신호를 ALUControl모듈에게서 받아 srcA, srcB를 그에 맞게 처리하여 ALUresult로 출력합니다. 
 ALUzero신호로 0인지 0이 아닌지를 구별하여 Branch Logic에 출력하기도 합니다.
 B타입 명령어는 보통 비교연산을 통해 분기의 유무를 정하기에 필요한 출력입니다.
 ALUresult는 DM의 Address신호나 CSR의 addr 등등 많은 곳에 연결되어있습니다.
Register File
└레지스터들로 이루어진 집합. RISC-V의 약속에 따른 레지스터 가이드라인이 있다.
 x0~x31까지 어떤 레지스터들로 이뤄져야하는지에 대한 내용. 꼭 참조할 것.
 무튼 RA1, RA2로 각각 rs1, rs2에 해당하는 주솟값들을 받아 그 주솟값에 해당하는
 데이터 값을 RD1, RD2로 출력한다.
 WA는 Write Address로 쓰기 작업을 실행할 주솟값을 받고, RF_WD는 쓸 데이터를
 받는 입력신호이다.
- CSR File *추가설명예정*
└Control and Status Register File. Zicsr 확장의 명령어들을 지원하기 위한 별도의 레지스터 파일입니다.
 인터럽트나 등등 시스템 연산에 주로 응용되는데,, 지금은 일단 구현만 해두고 실제 응용은 나중에 하지 않을까 싶네요. 
 Register File과 대다수 비슷합니다. CSR_enable로 쓰기를 활성화하고, CSRop를 통해
 어떤 값을 읽을지 정합니다. 명령어 관련 문서를 참조해주세요.
Data Memory
└레지스터가 아닌, 메모리입니다. 명령어가 아닌 데이터들이 저장되는 메모리입니다. 
 Memwrite 신호를 받아 쓰기를 활성화하고, MemRead는 읽기 활성화 신호입니다. 어? RF랑 다르게 별도로 Read활성화 신호가 있네요?
 네. 명령어상 RF는 읽기랑 쓰기가 동시에 생길 일이 없지만, DM은 러쉬가 날 수 있어요. 그래서 별도로 갖춰야 합니다. 
 ByteMask는 BE_Logic에서 출력한 '어디에 쓰기를 해야하는지'에 대한 지점의 주소 정보값을 갖고온겁니다.
 그걸 토대로 쓰기를 진행하게 되는 것. Address에서 읽기 쓰기 주소를 모두 받아옵니다.
 Memory의 접근은 무조건 rs값 + imm의 간접주소지정방식이라서요. ALUresult에서 받아옵니다. 
Immediate Generator
└상수 생성기. imm이 보통 작은 비트들로 ID에서 나오는데, 이걸 처리 가능한 규격인
 32bit로 Sign-Extension해서 ex_imm이라는 신호로 출력한다. 
Branch Logic
└분기를 결정하는 로직 모듈입니다. 
 Branch 활성화 신호를 CU에서 받고, funct3의 값을 보고 어떤 분기인지 확인하며
 그 조건식이 충족됐는지를 ALUzero의 값을 보고 판단합니다. 충족됐으면 BTaken신호를 출력.
 PCC에 전달해서 NextPC값을 B_Target의 주솟값으로 바꾸게 되겠죠?
- BE_Logic *추가 설명 예정*
└비트 정렬 로직입니다. 로드 명령어나 스토어 명령어를 보면, 워드 단위가 아니라
 하프워드(2바이트), 바이트(8비트)단위로 쪼개지기도 하는데, 그걸 제대로된 자리에 삽입하여 쓰기 위한 로직이에요.
 RF에서 DM으로, DM에서 RF로. 쓰기 작업시엔 해당 데이터가 무조건 BE_Logic을 거친다 생각하시면 됩니다.
 워드단위면 그냥 그대로 가게 되는거고, 하프워드나 바이트 단위가 되면 그 위치를 BE_Logic이 정렬해서 보내주게 되는거에요.
 funct3의 값을 받아서 명령어의 유형(워드, 하프, 바이트)확인하여 처리합니다.
J_Aligner
└jalr 명령어 때문에 J_Target에 들어갈 주소의 LSB 2비트를 00으로 강제 정렬할 모듈이 추가로 구성되어야 합니다.
 그게 이 J_Aligner. & ~1연산하면 되어요
ALUsrcA_MUX
└ALU의 srcA에 들어갈 신호를 선택하는 MUX. CU의 통제를 받으며, 
 RD1, PC, CSR_RD 중에 고르게 됩니다.
ALUsrcB_MUX
└ALU의 srcB에 들어갈 신호를 선택하는 MUX. CU의 통제를 받으며, 
 RD2, imm, CSR_RD 중에 고르게 됩니다.
CSR_WD_MUX
└CSR에 쓸 데이터를 정할 MUX. CU의 통제를 받으며(CSRsrc 신호)
 ex_imm과 ALUresult중에 고르게 됩니다.
RegF_WD_MUX
└RF에 쓸 데이터를 정하는 MUX. CU의 통제를 받으며(Mem2Reg)
 ALUresult, DataMemory의 DM_RD(BE_L을 거쳤으니 BERF_WD신호), CSR_RD, PC+4.
 총 4가지 신호 중에 고르게 됩니다. 
PCplus4
└jalr같은 명령어에선 jump이후 현재PC값에서 +4한 값을 레지스터에 저장하는 기능이 있습니다. 
 이를 위해 PCplus4모듈을 따로 넣고 이걸 RegF_WD_MUX에 연결하였습니다.
 PCC에 있는 PC+4로직을 응용하려 했는데 별도 모듈로 빼는게 적합하고 더 직관성이 좋아 그렇게 했습니다. 

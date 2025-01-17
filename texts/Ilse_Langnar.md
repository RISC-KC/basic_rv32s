2024.12.08. 
PowerISA를 기반으로 기초적인 싱글사이클 사칙연산 CPU의 기본 형태를 구상, 설계.
EDA_Playground로 개발하던걸 goorm ide에 옮겨 프로젝트화.

해야할 것 : 신호이름 체계화, 탑모듈 테스트벤치.

2024.12.09.
공부. ALU와 Control Unit의 코드를 재정비.
ALU에 있던 논리연산자를 CU에 적용하지 않았어서 그대로 만듦.
프로젝트의 로드라인을 정립함. PowerISA로서의 구현 가능성을 보았고, 성능 분기점까지 설계수준이 도달한다면 꽤나 의미 있는 연구활동이 될 것이라 판단.
RV32I의 기능을 수행하는 정도에서는 PowerISA와 RISC-V의 큰 성능적 차이를 보기 힘들 것이라는 생각.
RV32G정도라면 설계 목적 차제가 고성능인 PowerISA에 맞게 차이가 클 것.
일단 초심으로 돌아가 RV32I CPU를 개발하는 것에 초점을 둠.

2024.12.10.
공부. PowerISA를 기반으로 작성한 코드들이고, RV32I로의 전환은 간단할 것으로 생각했으나 아니었다.
PowerISA와 RISC-V는 비트의 체계가 생각보다 달랐다. 모듈들 각 각 자체는 괜찮았지만 모두가 함께 움직여야하는 탑 모듈 단에서는 부족함이 많음을 발견.
각 모듈별 정립은 완료단계에 접어들었으니, draw.io를 활용해 기초적인 block diagram을 그리는 중.
choicube84의 ALU 뜯어 맛보기. RISC-V이식을 위해 RV32I 기능을 하도록 불필요한 연산들을 삭제하고 비트 체계 수정 및 tb로 확인함.

해야할 것  :
신호 이름 체계화, 각 모듈 RISC-V 이식. 부족한 기능들 추가 구현(e.g. PC를 증가시키는 로직이 CU에서 구현되어있어야 했는데 빠져있었다.)
블럭다이어그램 만들기

2024.12.14.
ChoiCube84의 Program_Counter 제작. 

2024.12.15.
강현우 드디어 back to back.
컨트롤유닛 ISA 비트체계 뜯어고치기 시작.(15:57)
R-Type의 opcode를 기반으로 ISA 이해. CU 구현 시작. (17:05)

CU에 R-Type, I-Type, B-Type 명령어의 aluOp 코드를 정의했다. (20:14)
CU의 동작을 검증하기 위한 테스트 벤치를 작성해야 한다.
일단 오늘은 여기까지. 다음 단계로 CU의 테스트 벤치를 완성하고, ALU에도 추가한 뒤, 각 명령어의 동작을 검증할 예정이다.

어... 구현하다보니 Control Unit부터 만드는 것이 꽤 난해하다는 것을 직감.
IDEC에서 배운대로 필요한 기초모듈을 구상하고, 명령어를 수행하기 위한 각 Datapath를 짚어가며 기본 모듈들의 데이터패스들을 만든 뒤에
Control Unit을 추가하여 그 모듈들을 제어할 컨트롤패스를 만드는 정공법으로 가려한다. 

2024.12.21.
블럭다이어그램의 모듈 설계가 어느정도 끝났다. 신호들만 연결하면 CPU의 설계도는 완성이다. 
이 일련의 과정 자체가 이해를 많이 돕는다. choicube84는., 그대로 RV32I 모듈 구현 하면 될 듯하다...

2024.12.22.
신호체계를 블럭 다이어그램에 담는 중, Immediate Generator랑 Branch Logic 유닛의 구현이 누락됐다는걸 발견.
아고., 더 추가되네 할게., 신호체계 80%는 된듯. Branch Logic 이해랑 구성 하면 진짜 거의 끝났다.

2024.12.23.
당직 잘 섰다. 일단 ALUdec은 다이어그램에선 ALU Control Unit으로 되었고,.. 분기 구현이 살짝 어렵네. 이해가 살짝 안되는건가 표현하기 어려운건가..

2025.01.04. 
초안 다 만들었다. 설계도가 드디어.. 초안이 설계되었다..

- [Modules]
Format : Name 				[Inputs, Outputs] ; 											In + Out = Signals count

Program Counter 			[NextPC, CLK, rst, PC];											3 + 1 = 4 Signals
Program Counter Controller 	[PC, Jump, BTaken, J_Target, B_Target, NextPC];					5 + 1 = 6 Signals
Instruction Memory			[PC, IM_RD];													1 + 1 = 2 Signals
Instruction Decoder			[IM_RD, opcode, funct3, funct7, rs1, rs2, rd, imm];				1 + 7 = 8 Signals
Register File				[RA1, RA2, RW, WA, RF_WD, CLK, RD1, RD2];						6 + 2 = 8 Signals
Data Memory					[MemWrite, MemRead, DM_WriteData, ALUresult, CLK, rst, DM_RD];	6 + 1 = 7 Signals
Control Unit				[opcode, ALUsrcA, ALUsrcB, ALUop, Branch, 
							Jump, MemWrite, MemRead, Memory2Reg, RegWrite];					1 + 9 = 10 Signals
ALU Controller				[ALUop, funct3, funct7, ALUcontrol];							3 + 1 = 4 Signals
Arithmetic Logic Unit		[ALUcontrol, srcA, srcB, NZCV, ALUresult];						3 + 2 = 5 Signals
Branch Logic				[Branch, NZCV, funct3, B_Taken];								3 + 1 = 4 Signals
PC + 4						[PC, 4, PC+4];													2 + 1 = 3 Signals
Immediate Generator			[imm, ex_imm];													1 + 1 = 2 Signals
ALUsrcMUX_A					[ALUsrcA, RD1, PC, srcA];										3 + 1 = 4 Signals
ALUsrcMUX_B					[ALUsrcB, RD2, ex_imm, srcB];									3 + 1 = 4 Signals
RegF_WD_MUX					[Mem2Reg, ALUresult, DM_RD, PC+4, RF_WD];						4 + 1 = 5 Signals

Total 15 Modules, 40 Signals.
Total 76 Connections. 45 Inputs, 31 Outputs. 


2025.01.05.
각 신호에 대한 설명
CLK, rst
PC, NextPC, PC+4
Jump, Branch, BTaken, J_Target, B_Target, 
IM_RD, 
opcode, funct3, funct7, rs1, rs2, rd, imm, 
RA1, RA2, RW, WA, RF_WD, RD1, RD2, 
MW, MR, DM_WD, ALUresult, DM_RD, 
ALUsrcA, ALUsrcB, ALUop, M2R, 
ALUcontrol, srcA, srcB, NZCV, ALUresult
ex_imm

CLK = CLocK
rst = reset
PC = Program Counter address (32-bit)
NextPC = Next PC address (32-bit)
PC+4 = PC address + 4 (32-bit)
Jump = 	Wether Jump(J-Type) Instruction is operating or not.
		Decides PCC to select which signal should be NextPC. If true, NextPC = J_Target
Branch = Wether Branch(B-Type) Instruction is operating or not.
		Enables Branch Logic's calculation.
BTaken = Wether Branch(B-Type) Instruction's condition is satisfied or not.
		Decides PCC to select which signal should be NextPC. If true, NextPC = B_Target
J_Target = If Jump is true, NextPC Address. NextPC = PC + imm(32-bit)
B_Target = If Branch is true, NextPC Address NextPC = PC + imm(32-bit)
IM_RD = Instruction Memory_Read Data.
		32-bit Instruction read from Instruction Memory, recognized with PC.
opcode = opcode from IM_RD
funct3 = additional opcode domain. specifies calculation variation. (If I-Type, add, sub..etc is decided by funct3 domain.)
funct7 = additional opcode domain. If funct3 are same, funct7 does the distinction.
rs1 = register source 1. The data that came from 32-bit instruction.
rs2 = register source 2. same as rs1.
rd = register destination. The destination address of register. 
imm = immediate value. Varies by the type of Instruction. Usually used after extension by Immediate Generator Module.
ex_imm = 32-bit sign-extended immediate value.
RA1 = Read Address to Register File. 
RA2 = same as RA1.
RW = Register Write;RegWrite. Enables Register's write operation.
WA = Write Address. Destination address of Register's write operation.
RF_WD = Register File_Write Data. A data to write in Register File. 
		Usually selected between ALUresult, DM_RD, PC+4. By RegF_WD_MUX.
RD1 = Data that has read from Register File. 
RD2 = Same as RD1.
MW = Memory Write;MemWrite. Enables Memory's write operation.
MR = Memory Read;MemRead.Enables Memory's Read operation. Unlike Register File, Data Memory's Read operation should be conditioned. Due to Load store operation. They should not crash each other.
DM_WD = Data Memory_Write Data. The data that's going to write in Data Memory. Usually from the Register File.
ALUresult = ALU's calculation result data. Usually goes to PCC for the Branch/Jump operation, or DataMemory or Register File to store data.
DM_RD = Data Memory_Read Data. The data that has read from Data Memory.
ALUop = ALU's base operation code from Control Unit. Inputs ALU controller Module.
ALUcontrol = ALU's actual operation signal. From the ALU Control Module, decides which operation should ALU do.
ALUsrcA = ALU's calculation source A. Decided by the ALUsrcMUX_A between RD1 and PC.
ALUsrcB = Same as ALUsrcA. Decided by the ALUsrcMUX_B between RD2 and ex-imm.
srcA = Decided ALUsrcMUX_A's data.
srcB = Decided ALUsrcMUX_B's data.
M2R = Memory to Register. A signal that decides which data should be written in Register File by RegF_WD_MUX. 
NZCV = Negative, Zero, Carry, oVerflow. Flag signal.
		Usually outputs zero signal to Branch Logic to check if the branch condition is satisfied.
---
생각해보니 수정해도 되는 부분. 
1. RV32I 자체는 Zero Flag말고는 없다. NZCV기능 말고 일단 Zero만 구현해 놓아도 될 것 같다. 
-완료
2. jalr 명령어 때문에 J_Target에 들어갈 주소의 LSB 2비트를 00으로 강제 정렬할 모듈이 추가로 구성되어야 한다. 
-완료
3. rst신호와 CLK신호를 어느 모듈들에서 써야하는지 기준이 구체화 되어야 한다.
4. 레지스터 쓰기 작업 때 sw, sh, sb 와 같은 명령어에서 비트가 4바이트 뿐만 아니라 2바이트, 1바이트도 저장된다. 
 보통은 32비트의 데이터 길이를 가지기에, 그 32비트 공간에서 2바이트 쓰기를 하게 되면 비트가 중간에 바뀌게 되는데 이 위치를 통제할 기능이 필요하다.
  예를 들어, 0x12345678이 있고, sb를 통해 1바이트 데이터 0xAA를 (한 바이트당 8비트. 한 칸당 4비트.)입력한다고 하자. 그럼 0x12345678의 어디에 AA가 들어가야할까? 이걸 WriteMask신호가 결정한다.
  0x12AA5678이렇게 쓰기가 되도록. 이걸 위한 BE_Logic.
5. 마찬가지로 읽기 작업 때도 lw (4바이트)가 아니라 lh, lb가 있다. 이걸 위한 J_Aligner.
-완료

2025.01.06.
휴가 나왔다. 다이어그램 신호 체계 점검했다. 해야할게... 이제 
BE_Logic 완전히 이해하는 것과 CSR, Debug 기능 추가..
깃헙 push pull도 해야하는디 이건 어떻게 하지

2025.01.11. 
신호들의 최적화와 CSR의 구현이 완료되었다.
남은건 FENCE, ECALL, EBREAK, FENCE.i 명령어의 구현. 
현재 이 4개의 명령어를 제외하고 43 out of 47 Instr.s. 가 구현 및 연산 가능하여야 한다. 
BE_Logic도 마쳤으니 4번 항목도 완료.
그럼 이제 rst신호랑 clk 신호의 정립을 하면 4개의 명령어를 제외한 RV32I의 기본적인 형태가 완성된다. 구현과 검증의 시간.

2025.01.12
현재 난관은 이 상황.
완전한 RV32I를 구현하는 것이 초기 목표였으나, 거의 완성 단계에 다다라서 FENCE, FENCE.i, EBREAK, ECALL 이 4가지 명령어가
시스템 명령어라는 것을 알게 됨. 별도의 메모리 및 캐시의 구현이 필요하며 이는 곧 시스템 개발로 노선이 확장된다..
아직 프로그래밍 구현과 검증을 해보지 않은 상황에서 이 것 까지 범위를 확장하기엔 마일스톤이 너무나 커진다. 
때문에, 47가지 명령어중 4가지 명령어를 제외한 43가지 명령어로 1차 개발을 마친다. 신호 최적화까지 마친 이 설계도의 이름은
RV32I43O 로 명명한다. RV32I 중 43개의 명령어, Optimized signals.
구현을 위하여 ChoiCube84가 모듈과 신호의 역할에 대해 충분한 이해를 하고 있어야 하므로 
ISA의 각 명령어별 의미와 작동 방식을 문서화하고, 모듈에 대한 내용 문서화, 신호에 대한 내용 문서화를 해야한다.
나에게도 복습이 되며 이걸 알아야 Verilog로 구현하는 의미가 있으니까. 

이대로 검증을 마치고,, 아마 내가 설명 자료를 먼저 만들고 CC84가 마저 구현하고 있을 것인데, 남는 시간동안엔 
Core Unit과 Memory Units, Interface의 Top Module 시점에서의 설계도를 구상하는 것을 시도해보아야 겠다.
결국 RV32G를 만드는 것이 목표인데, FENCE, FENCE.i, EBREAK, ECALL 명령어의 구현은 필수이다. 
얼추 검증이 끝나면 그 설계도를 기반하여 구현 시도를 해보고, 안되면 그 상태 그대로 5단계 파이프라이닝으로 넘어간다. 
Modules문서를 만들고 모듈들에 대한 전반적인 설명을 모두 마쳤다.

2025.01.17
4일간의 혹한기 훈련을 마치고 여태 작업한 docs들을 push했다.
github을 처음 쓰면서 인터페이스가 아직 익숙치 않은데, docs브랜치의 변경사항을 저장하려다가 예전에 push안해둔 코드들이 겹치면서 조금 꼬였다.
ALU가 없어지는걸로 git에 기록이 남았는데, 뭐 아쉬운거죠. 나중에 CC84가 어차피 모듈을 추가할텐데 그 때 다시 돌아갈 예정.
오늘은 Core유닛과 메모리 유닛의 이원화를 통한 Top Module 수준 다이어그램을 그려야한다. FENCE 명령어 및 ECALL EBREAK 와 같은 명령어의 구현 때문.
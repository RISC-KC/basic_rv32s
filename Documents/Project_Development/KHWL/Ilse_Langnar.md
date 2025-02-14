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

2025.01.18
Cache 구현 중. 메모리 계층 구조에 따라 메모리의 최상위 접근 모듈은 Cache가 된다.
Cache메모리 조회하고, 없으면 Memory 조회하는 걸로.
[의문 1.]
신호체계를 보다 보니, Cache Miss가 났을 때, IM에 IC가 IMRead라는 신호를 보내서 IM에서 명령어를 요청하는데, 일개 메모리가 이러한 요청 제어 신호를 보내는 것이 맞는 지
[의문 2.]
nstruction Decoder에 그럼 기존에는 Instruction Memory의 데이터가 들어갔는데, 
I.Cache가 추가됐으니 Instruction Memory에 두개의 Input이 주어지고 MUX와 제어신호로 통제하는건지 
or 메모리 계층구조론에 입각하여 Cache Miss시 결국 IM에서 찾은 정보는 다시 사용되기 빈번할 수 있도록 I.Cache에 갱신하여 이점을 도모하는건지. 
[의문 3.]
그럼 Cache Miss시 IM의 데이터를 IC로 갱신하는 데에 있어서 추가적인 제어 로직이 추가되어야하는 것은 아닌지. 
(예: Cache Miss시 IM에서 나온 데이터를 IC의 몇 번째 주소에 무슨 알고리즘을 따라 저장할건지.)
맹점. RV32I에는 Cache메모리를 별도로 제어하는 ISA자체가 마련되어있지 않다. 별도 확장의 명령어들을 일일히 찾아보거나 해야한다.
└아마 이건 따로 우리가 구현해야할 가능성이 다분함.

+ IC에서 IM으로 Cache miss일 때 IC와 IM의 구조가 다를테니 요청 주솟값도 다를테고, 그에 맞는 주소도 요청해야하니 주소 변경 로직을 처리할 모듈과 주소 신호, 읽기 제어 신호 이런 것들이 추가로 필요할 것 같다는 생각
알게된거. 의문 2는 후자가 맞음. 의문1은 MemCon에서 해결 가능. 
메모리-캐시 사이 주소 매핑 방식은 3가지 있음. Direct Mapping, Fully Associative, Set Associative. 이건 CC84도 잘 생각해서 구현해야함. 로직의 부분임니다.

1. 캐시 미스시 메모리로 MemCon이 주소를 변환하여 주소를 넘기고 나온 데이터를 멤컨이 받아 ID로 넘김(그냥 넘길수도 있지 않나 싶긴함. MemC안거치고.) 
2. 1에서 나온 데이터를 캐시에다가도 갱신해줘야하니까 MemC가 계산한 주소와 그에 저장할 데이터를 입력함. 쓰기 활성화도 같이하나..? MemC가 주소를 어떻게 계산하지

2025.01.19
여전히 Cache 구현중. 구현하면서 부족했던 지식을 쌓아가며 성장하고 있다.
1. Cache와 Memory의 주소체계는 다르다.
기존의 IM은 32비트 그대로 4블럭씩 데이터를 저장했지만 Cache는 다르게 잡아야 한다. (이를 Cache Line 단위를 사용한다고 함.) 
때문에 캐시 미스시 가지고 있던 캐시의 주소를 MC에 보내서 IM에 맞는 주소 체계로 변환하고 그걸로 MC가 IM에 데이터 요청, 그리고 그 데이터를 IM이 MemC로 반환. 
MemC가 그걸 ID에 넘겨주며 IC에다가도 넘겨 로직을 기준으로 계산된 캐시의 주소에 해당 데이터를 저장하여 캐시를 갱신한다.
Cache Line 구조.
기존의 PC단위는 IM에서 구현된 대로인데, Cache의 의의는 자주 사용될 것 같은 명령어들을 뭉탱이로 가지고 있다가 바로바로 꺼내쓰는 호주머니같은 용도임. 
그래서 PC값을 기준으로 하면, 0x00을 PC로 꺼내가면 캐시에는 0x00, 0x04, 0x08, 0x0C(연속된 4개의 명령어)가 한번에 캐시에 저장된다. 
이러면 캐시 라인의 크기가 16바이트인 것. 이러면 다음 명령어 실행할때 캐시 히트되니까 메모리 접근을 줄이고 훨씬 빨라진다. 그리고 기존 IM주소체계 그대로 IC를 구현하는 것 보다 캐시 미스 빈도를 줄이게 되니까 성능도 올라간다. 

그 일련의 과정은 아래와 같다.
PC값을 IC에 가져온다.
거기서 Index값을 추출해 캐시의 라인을 선택한다.
그 라인 속에 있는 Tag를 사용해서 원하는 데이터를 식별해 출력한다. 
캐시 미스 발생 시, 캐시 라인단위로 IM에서 뭉탱이로 갖고와서 캐시를 갱신한다.

아마 물성 때문에 멤이랑 캐시랑 나눈게 아닐까 싶기도 하다.
둘이 서로 같은 메모리 구조에 같은 물성이면(소자) 굳이 나눌 필요 없이 주소-데이터 바로 직접연관주소방식 사용하는거랑 다를게 없을테니까. 오히려 직접이 나을 수도 있다. 
근데 다르고, 캐시가 일반 메모리보다 빠르기에 그렇게 하는 듯 하다.

[의문 추가.]
OS를 굴린다는건 처리할 명령어들이 속속 달라진다는건데 그럼 IM이나 IC가 ROM이 아니어야 하는 것 아닌가?

//////////
[2025.01.19 회의; 네이버챗]
CC84와 메모리 계층구조에 대한 기본 이론 설명과 이해.
캐시 구조, 정책에 대한 자료.
https://velog.io/@khsfun0312/%EC%BA%90%EC%8B%9C-%EC%A0%95%EC%B1%85%EC%95%8C%EA%B3%A0%EB%A6%AC%EC%A6%98
Instruction Cache / Memory의 부팅 시 운용방식에 대한 안건.
처음에는 IC에 아무것도 없는 상태로 제로 콜드스타트 이후 알아서 Cache Miss 난 뒤 사용하며 갱신을 반복하게끔 설계하자.
마지막 개발 단계가 끝난 뒤에, 이 로직을 변경해본다. IM의 명령어들을 순차적으로 IC에 꽉 채워 미리 로드를 시켜두는 것.
이 두가지에서 어느 정도의 성능 변화가 있을지를 관찰하면 이 또한 논문감 또 다른 탐구 과제가 된다. 

지금 해야할거 : 
1. Instruction 캐시의 신호 체계 정립
2. Data쪽의 캐시 구조 이해
3. 두가지 캐시구조의 이해를 바탕으로 MemC의 신호 체계 정립, 구현.
RV32I43O에 해당 블럭들을 추가하므로서 RV32I47F를 완성한다.
Core-Memory 분리된 Top Module 단위의 블럭 다이어그램 완성.

차후에 RV32G 확장시 참고할 레퍼런스 자료 탐색.
Rocket core, PicoRV, Riscy

RV32G 확장 이후 5단계 파이프라이닝으로 순서를 바꾸는 것이 어떤지에 대한 건 발의.
각자의 생각 끝에 복잡한 싱글 사이클 모듈을 그 때 가서 나누는게 더 어렵겠다는 판단. 기존 로드라인 유지로 결론.
(RV32I -> 5SP RV32I -> 5SP RV32G -> 7SP+ RV32G)

CC84에게 어차피 캐시 구조는 차후에 신호 조정 및 새 모듈 생성으로 그리 어려운 부분이 아니니까 RV32I43O부터 구현해달라고 했다. 

//////////

개발 일지.
Instruction Cache / Memory 구조 섭렵 완료.
Instruction Datapath.

1. Instruction Cache.
역할 : 주소를 받아 명령어를 ID에 반환한다.
주소를 갖고 있지 않을 경우, MemC에 Cache Miss신호를 출력한다.
IM와 MemC에 PC주소를 그대로 출력한다.
IM에서 찾은 데이터를 그대로 IC에 반환한다.(Up_data)
동시에 IM의 데이터를 ID에 직접출력한다.
MemC에서 PC값을 기반으로 IC의 어느 주소에 명령어를 저장할지 연산한다.
IC의 주소에 Up_data를 저장시킨다. (갱신완료)

[inputs]
PC(addr) - 당연
MemWrite - 쓰기 활성화 신호. CU에서 온다. MemRead도 마찬가지.
MemRead - 읽기 활성화 신호. 읽기/쓰기 작업이 충돌날 수 있어서 별도신호로 만듦.
Up_Data - 캐시 미스시 갱신을 위한 데이터. IM에서 옴.
Up_Addr - 캐시 미스시 갱신할 데이터의 주소. MemC에서 옴.
인데,, MemWrite, MemRead 솔직히 없어도 된다. PC가 들어오면 읽기고, 미스나면 Write니까. 
PC, Up_Data, Up_Addr. 입력 신호는 이 3개로 충분하다.

[outputs]
PC(addr) - 캐시 미스시 IM으로 주솟값 그대로 넘겨주기
IC_RD - 캐시 히트시 그대로 ID로 출력
IC_Status - 0일 때 hit, 1일 때 Miss. MemC로 출력됨.

★CC84에게 건의하는 사항.★
C_Status를 I.C_Hit, I.C_Miss로 신호를 이원화할지 고민중.
어차피 디폴트가 Hit고 미스일때만 추가 처리수행하면 되니까 Miss일 때 Status를 1로 잠깐 바꿔 인식하게 하는 방식이 더 나을 것 같은데, 만약 이원화가 더 나아보인다면 자유롭게 건의 바람.

2. Instruction Memory.
역할 : 캐시 미스가 났을 때 주소를 받아 명령어를 ID에 반환한다. 
주소는 IC에서 MemC로 출력되는 PC값을 그대로 받아온다.
데이터를 IC의 Up_Data로 출력하며 동시에 ID로 직접 반환한다.
(캐시 갱신을 위함.)

[inputs]
IM_Addr - PC값 그대로입니다. 
IM_RD - ID에 반환하며, IC로 출력하여 갱신시킬 데이터 신호입니다. 

3. IC.IM_MUX 
의의 : 캐시 미스가 나서 IM을 조회하면 이게 캐시를 거쳐서 ID로 가는게 아니라
곧장 ID로 IM의 데이터가 갈 수 있도록 하는 구조상 생긴 MUX.

역할 : IC_Status가 1로, Cache Miss가 났다는걸 MemC가 인식하면
IC.IM_MUX로 제어 신호를 보내어 IM의 데이터 신호인 IM_RD가 ID로 입력되도록 한다. 
Cache Hit이면 00으로 기존 유지. IC의 데이터 신호인 IC_RD가 ID로 입력되도록 한다. 

[inputs]
IM_RD, IC_RD
IC.IM_MUX - 00이면 Cache Hit일때니까, 그대로 IC_RD 선택되어 출력.
01이면 Cache Miss. IM_RD 선택되어 출력.

[outputs]
Found_Instruction
-IC_RD, IM_RD 둘 중 하나.

----------
하아 이제 Data 메모리 구조를 살펴야할 시간이다.
단순 ROM의 성질을 지니는 Instruction Memory였기에 그리 큰 변경점은 없었다.
하지만 Data Memory는 보낼부터 쓰기 읽기 활성화 신호, 
데이터 정렬을 위한 마스크신호와 쓰기 데이터/주소 신호, 출력하는 데이터신호
이렇게 많은 신호를 포함하기에 이게 D.Cache가 추가 되는 것으로 인하여
어떻게 달라져야하는지를 알아내야 한다. 
일단 TopModule 단위 블럭 다이어그램에서 Instruction Memory / Cache의 설계를 마쳤다.

2025.01.20
텐트회의 때 거론되었던 문제. CC84의 건의
"Instruction Decoder의 CSR_addr신호는 필요하지 않다."
검토해본 바, CSR명령어의 비트 체계는 I-Type로, Imm 비트 필드를 그대로 csr 주소값으로 CSR File 모듈에 넘기면 된다.
이를 반영하여 RV32I43O에서 CSR_addr신호를 제거하고 imm신호를 CSR File의 CSR_addr의 Input으로 연결했다.

추가적으로, CSR의 명령어들의 데이터패스를 검증하며 ALU의 로직에 대해 생각해보았다.
CSR은 레지스터파일로 CSR값을 반환하거나 그 반대를 수행하거나. 이에 imm을 넣거나의 수행을 하는데, 현재 설계 특성상 RD1, RD2는 무조건 ALU를 거치게 되어있다.(BE_Logic 제외)
때문에 CSR명령어중 rs1을 그냥 바로 CSR에 반환할 수 있도록 할까도 생각해 봤지만, 로직의 일관성이 떨어지며 오히려 효율이 떨어지게 된다는 결론을 내렸다. (복잡성도 증가한다.)
그렇다면 ALU에서 rs1을 srcA로 받아서 그대로 Bypass하거나 0과 연산하여 rs1값 그대로를 출력하도록 해야한다.
ALUsrcB MUX에 0입력을 추가로 만들어 선택할 수 있게 할까도 생각해봤지만, 차라리 ALU에 로직을 추가하여 Bypass하여 출력할 수 있도록 하는 것이 좋다는 결론을 내렸다.
추가 연산의 시간이 없어지니 딜레이가 감소하며 ALUop로 분리해둔 효용성을 같이 챙길 수 있게 된다. (ALU의 ISA동작 외 기능 수행).

오늘 할 것. Data진영 Memory Cache 정립. 
Instruction 진영 캐시 구조 RV32I43O에 반영하기. 

문득 든 궁금증. 
Cache가 미스나서 Memory를 참조해야할 때, 차라리 처음부터 주솟값을 두 모듈에
동시에 입력해서 미스나기 전에도 이미 Memory에서 찾고 있고, 미스가 나면 
그 때 주소를 주는게 아니라 이미 줬던 주소값에서 바로 찾은걸 Memory가 바로 반환하도록
하면 되는 것이 아닌가?

이러면 나중에 파이프라이닝에서 문제가 생기니까 폐기된 구조인가?
아니면 이걸 하이브리드로 어떻게 잘 개선하여 실제로 쓰이고 있는가?
레이턴시를 최대한 줄이고 병렬성을 극대화하는 특성상 이 구조가 논의되지 않았을리가 없을텐데.

찾아보니 이미 있던 구조다. 역시나.
이름은 "Cache-Memory Parallel Access"
하마터면 바퀴를 다시 만들 뻔했다.

이점과 단점 모두 예상했던 것들이 맞지만, 조금 더 다듬어서 답을 해보겠다.
Cache Miss가 발생하더라도 이미 Memory, 하위 계층에서 읽기가 진행중이므로
Miss Panalty가 크게 줄어든다.
또한, 당연하게도 병렬성이 증가한다.
문제점은 내가 언급한 파이프라이닝 단계에서 발생한다.
1. Cache와 Memory의 동기화가 복잡해진다.
2. 스톨 발생 가능성이 증가한다.
그 외의 새로 알게된 문제 가능성은 다음과 같다.
3. 메모리 대역폭을 효율적으로 쓰지 못한다. 다중 코어에서는 이가 병목을 불러올 수 있다.
4. Cache Hit시 불필요한 작업을 수행했으므로 그에 따른 에너지 손실이 생긴다.
- 불필요한 메모리 접근은 전력 소모를 크게 증가시킨다.

이를 보완하여 조건부로 병렬접근을 이용하는 경우가 있다.
1. Critical Word가 Cache Line의 일부일 경우에만 Memory와 병렬접근을 허용한다.
2. Prefetching.
- Branch Prediction과 유사한 방식으로 Cache Miss 예측 알고리즘을 구축하여
 Cache Miss를 예측해 메모리에서 데이터를 미리 가져온다. 이러면 병렬접근이 아니고
 그와 비슷한 효과를 가질 수 있다.

나중에 Prefetching 로직도 고려해보면 좋을 것 같다. RV32"G"확장 때 Branch Prediction이 있을텐데
그 때 같이 구현해보아도 좋을 것 같다.

22:45
기존 RV32I43O에 Instruction Cache / Memory 모듈 구조를 설계구현했다.
또한 CSR 모듈이름과 신호를 개선했다. 

23:17
기존 DataCacheMem250119 Top-Moduel 레벨 시스템 다이어그램에서
캐시구조가 접목된 RV32I47F 코어 기반 시스템 다이어그램을 설계구현했다.
RV32I의 47가지 모든 명령어를 지원한다. 4개의 단계 중 1단계 완성에 가까워졌다.
Top-Module 레벨 시스템 다이어그램의 이름은 다음과 같이 명명한다.
Basic_RV32-S1. 
각 단계에 도달할 때 마다 S 단계가 올라간다. 하하. 가보자.

RV32I47F 거의 완성. 아.. 내일은 완성이다. 신호 하나만 연결하고 최적화하면된다.
하하하!

2025.01.21.
RV32I47Prototype 완성. 19:58. 본래 Cache-Memory 구조를 염두하고 만든 다이어그램이 아니다보니 꽤나 신호도가 복잡해졌지만 어찌저찌 구현했다.
그와 동시에 Basic_RV32_S1의 신호체계를 보기좋게 최적화했다. 파일명은 Basic_RV32_S1_o. 이건 20:24.
이렇게보니 당장 굳이 탑모듈의 코어 - 메모리 분리도로 다이어그램을 만들 필요는 없던 것 같지만, 이걸 만듦으로서 생각을 파편화해 조금 더 캐시 메모리 구조 구현이라는 데에 집중할 수 있었던 것 같다. 
나중에 FPGA 검증을 위해 기타 I/O 인터페이스 및 버스 구조를 구현해야할 때가 올텐데, 그 때를 위한 초석이라고 보면 좋을 것 같다. 
이로서 47가지의 모든 RV32I 명령어를 지원하는 프로세서의 설계도 "초안"이 완성되었다.
이제 이걸 토대로 구현하여 각 명령어별 검증 절차를 거치면 완성이다. 

향후엔 캐시, 분기 예측도 구현해봐야할 것 같은데..

오늘은 이 프로세서의 특징을 정리해보고, Cache 구조의 기초 검증과 모듈 설명들을 적어보겠다. 

- 특징 1.
[Conditional Direct Memory Fetch.]

Cache Miss시 기존 구조.
Memory 조회, 데이터 인출 -> 인출된 데이터로 Cache 갱신 -> 갱신된 Cache에서 데이터 출력.

변경된 구조
Memory 조회, 데이터 인출 -> 데이터 출력
					   -> 인출된 데이터로 Cache 갱신

메모리의 데이터를 캐시에 갱신한 뒤, 캐시가 데이터를 출력하던 기존 구조와 달리,
메모리에서 데이터를 찾아 메모리가 인출할 때, 그 데이터를 캐시와 목적지에 같이 출력하여 캐시의 쓰기 동작과 데이터 출력을 동시에 하여 과정을 병렬화해 레이턴시를 줄이는 것. 

목적지의 앞에 데이터 입력 근원지를 선택하는 MUX가 추가되었고, Memory Controller에서 해당 MUX들을 제어한다. (Instruction 진영, Data 진영 각 1개, 총 2개. )
MemC가 Status 신호에서 Miss를 받게 되면 자동으로 MUX를 01로, 즉 Memory에서 인출되도록 신호를 선택한다. 타이밍의 조율이 잘 되어야할 것이다.
미스신호 이후 메모리에서 해당 주소에서 찾는데 까지의 시간이 있을 것이니, MUX에 01신호가 들어가기까지 딜레이를 주거나, 신호유지시간을 조절하여 제대로된 값이 MUX로 입력될 수 있어야 한다.

- 특징 2.
[ALU Controller]

ALU Controller, 즉 ALU의 동작만을 제어하는 별도의 Control Unit을 만들어 설계의 직관성과 유지보수성을 높였고, ISA 명령어 기반 동작 외, 설계 단계에서 
개발자가 직접 별도의 처리를 할 수 있도록 제어 신호를 프로그래밍 할 수 있게 해두었다.
이를 통해 본 코어 구조에서 CSR명령어를 위해 ALU연산을 거칠 때, 0과 add연산을 하는 것이 아니라 RD1값을 그대로 Bypass하도록 별도의 Bypass에 해당하는 ALUop코드를 프로그래밍하여
Bypass를 수행하도록 했다. 

- 특징 3.
[J_Aligner]

RV32I 명령어들 중 J타입 명령어인 jalr을 위한 비트 정렬 로직이 하나의 단독 모듈로서 구현되어있다. 
PCC에 로직을 추가할 수도 있었으나, 이를 통해 설계의 직관성을 높이고 단순화하였다. 

- 특징 4.
[Cache Status Signal]
Cache Hit / Miss 신호를 이원화 하지 않고 하나의 신호체계로 두었다. 0이면 Hit, 1이면 Miss이다. 

- 특징 5.
CSR File의 address 신호를 Instruction Decoder에서 별도의 CSR_addr신호를 사용하지 않고 I Type 명령어 구조를 그대로 채용할 수 있을 것 같아 imm의 신호를 그대로 CSR_Addr로 출력하도록 했다.

- 특징 6.
Instruction Decoder 로직을 단독 모듈로 구현하였다. 
설계의 직관성과 유지보수성을 높이는 것을 목적으로 했다. 

23:47.
캐시구조를 접목하는데 있어 지적 이해 부분을 제외한 가장 큰 걸림돌이었던 모듈과 신호들의 배치구조를 최적화했다.
불필요한 면적은 줄이고, 신호들의 배치를 더 보기 쉽게 바꾸었다.

내일 할 것들 : 캐시 구조 이해 (매핑방식, 컴퓨터 구조론.), 메모리 모듈 없는 Core 유닛 다이어그램 제작.
명령어별 캐시 구조 기초 검증, 파이프라인 구조 구현 시작.
아. 파이프라인 전에 모듈 설명 및 신호들 설명을 적어야한다.

documents 폴더 하위
/legacy blocks 폴더 생성
	//draw.io 파일 폴더 생성
	//png 파일 폴더 생성
	//pdf 파일 폴더 생성

/Current Design 폴더 생성

/Theories and Logics 폴더 생성
	//Modules and Signals 폴더 생성
	//ISA 폴더 생성
/Project Development 폴더 생성

하 쉣 맞네 ECALL, EBREAK 구현 위해선 Trap Handler의 설계도 필요하구나 하 김칫국마셨네
그래도 거의 다 와간다 화이팅!!!!
내일 할거 추가 + Trap Handler 이해 및 설계 구현.

2025.01.22.
20:25. Trap Handler, Exception Detector을 구현했다. 
A4 사이즈에 다 구현하려니 꽤 힘들어지기 시작했다. 기존에 모듈들을 생각보다 촘촘히 배치한 상태였고 신호들도 하단부에 얽힐대로 얽힌 것 같다.. 이것들도 풀어야하는데..
일단 다음과 같이 구현했다.

Trap Handler
[inputs]
Trap_Status
PC
CauseCode
mtvec
[outputs]
mepc
mcause
T_Target

Exception Detector
[inputs]
I_RD

[outputs]
Trap_Status (ECALL enable, EBREAK enable 신호를 하나의 신호로 일원화 했다. )
Cause Code.

허허허. Privileged ISA라는 추가적으로 공부할게 생겼다. 물론 Zicsr 확장이 필요한 지금 시점에서는 '전부'를 알 필요는 없지만 차차 알아가게 될 조각을 보았다.
Privileged Mode, CSR 의 구조.. 등등..
일단 ECALL을 위한 TH와 ED의 기본 구현은 마친 것 같다. FENCE.i와 FENCE, EBREAK에 대한 구현이 이제 필요하고 각각에 대한 명령어를 공부하고 있다.
구현중에 사고, 개선한 점.
mepc, mcause라는 CSR 레지스터에 값을 저장하기 위해 별도의 신호를 넣었었는데, 생각해보니까 CSR에 대한 쓰기 작업이므로 CSR_addr과 CSR_WD를 TH에 넣기로 했다.
이렇게 함으로서 구현의 직관성이 높아졌다. 
이에 따라 CSR_addr에는 2to1 MUX가 추가됐고, CSR_WD에는 3to1 MUX로 바뀌었다.
CU에서 opcode를 보고 어떤 예외명령어인지 충분히 파악 가능하므로 각 MUX의 제어신호는 CU에서 맡는다. 
RV32I47TH_ongoing으로 최신화했다.

ECALL인지 EBREAK인지에 대한 신호 식별을 원래 별도의 신호로 마련하려 하였지만 이를 Trap_Status의 신호로 일원화 하였다.
오늘 연등시간 대부분을 Zicsr, Zifence, Privileged ISA 공부, 모듈 최적화, 신호 최적화, 구현하는데 보내었다. 오늘은 여기까지..

2025.01.23.
---회의록---
ALUop에 대한 건.
CC84의 발의. ALU control 신호가 꼭 필요한가?
-맞다. ALUcontrol : opcode가 연산이 필요한 타입임을 감지했을 때 이를 ALU에 맞게 디코딩해주는 유닛

명령어의 연산 식별자 : funct3, funct 7. 
이 세가지 입력 신호를 가지고, 어떤 연산자인지 확인.

이를 더 간단한 코드로 인코딩. 
e.g.)	0001 - add
		0010 - sub

그리고 이 코드를 ALUcontrol 이라 명하며, ALU에 입력됨.
ALU는 이걸 토대로 바로 srcA, srcB값을 가지고 연산을 실행한다.

ALUop신호의 역할은 무엇인가? ALU의 enable 및 Bypass 신호에 불과한가?
-ALUop신호는 opcode에 따른 명령어의 타입을 받아 타입별 연산을 하기 위한 식별 코드이다. 

그럼 명령어 타입 해봤자 6타입인데(R, I, S, U, J, B) 다 쓴다고 해도 3비트면 충분하지 않은가? 왜 4비트인가?
-추후 G확장 까지 다루며 다른 명령어 타입이 들어갈 줄 알았는데, 그걸 감안해도 3비트면 충분한게 맞는 것 같다. mret같은 시스템명령어도 비트의 사용처가 다를 뿐 체계 자체는 R타입을 따르는 것 처럼.

ALUop가 명령어의 타입을 식별하는 신호라면 ALUop보다 Instruction_Type으로 신호 이름을 바꾸는 것을 건의. 더 직관적임.
-모듈 내에서 해당 신호를 그렇게 하는 것은 찬성. 하지만 블럭 다이어그램의 주소 이름은 신호를 트래킹 하지 않고도 이름만 보고 타깃모듈과 역할을 알 수 있도록 해야함. 그런 정책으로 이름이 정해져있는데 얘만 그러면 안됨.
무엇보다 이름이 너무 긺.

흠, ALUresult처럼 신호의 시작단에 타깃 모듈 달면 해결되는거 아닌가?
-아 맞네. 생각해보니 나도 같은 한계에 부딪혀서 그렇게 개선했었지. 알겠다. 그렇게 하겠다. 이름은 조금 줄이겠다. Instr. Type으로. 

혹시나 2비트로도 줄일 수 있지 않을까? 4가지 명령어 타입으로 압축해도 f3, f7보고 잘 구분할 수 있게 로직 짜면 될 것 같은데.
-알겠다 한번 가능성에 대해 찾아보겠다.
---회의 끝---

RV32I47TH -> RV32I47Fenced.
- 변경사항
1. TrapHandler - Instruction Cache : Fence.i, 즉 IC 무효화를 위한 신호 추가. 
└IC_Clean 명명.

2. Data Cache - Data Memory 구조.
Data Cache의 버퍼 구조 채택.
캐시 쓰기 정책 Write Through 선 구현, Write Back 후 구현 채택.
Data Cache의 버퍼 to Data Memory 쓰기 작업 신호 추가
=캐시-메모리 동기화 작업. 
└Buffer to Memory → B2M = B2M_Addr, B2M_Data.
Data Cache에서 B2M 신호 출력, 그게 Data Memory로 입력된다. 

3. Data 영역의 쓰기작업 데이터패스 수정
기존 : RF → BE_L → DataMemory : 메모리 직접 접근 저장.
└ 캐시에는 요청시에만 쓰여지는 구조. 즉, 캐시 미스가 나야 일일히 갱신되는 단순한 구조였다.
변경 : RF → BE_L → Data Cache Buffer → Data Cache →→→ Data Memory. 
└ 이 때, Data Cache에서 Data Memory로 Flush는 캐시 갱신 직후 즉시 수행되는 것이 아니라 지연되어 한번에 진행된다. Burst 구조.
변경 사유 : RF에서 Memory로 직접 접근시 소요시간이 Cache보다 느리다. 

변경 반영점 : Data Cache에 DC_WD 신호 추가, Data Memory의 DM_WD신호가 B2M_Data로 Replace되었다.
DC_WD로 들어온 데이터는 Data Cache의 버퍼에 우선 입력된다. 
DM_WD신호는 어차피 캐시 및 캐시버퍼구조가 도입된 이상 직접 쓰기 작업을 실행할 일은 없으므로 Replace 된 것이다.
(하아.. 이러면 Cache의 구조가 단일 로직 구조가 아닌 Module-in-Module 구조를 띄게 되어 별도 다이어그램을 그려야한다.. 물론 다른 모듈들도 그래야하겠지.. 잊고 있었다...)

 - !할일 Cache Write 작업 활성화 신호가 Data Cache에 추가되었는데, 꼭 필요한 신호가 맞는지 검토가 필요하다. 일단은 DC_Write신호로 명명해두었긴 하다. (Control Unit → Data Cache.)
 
4. FENCE 명령어의 구현; Data Cache의 Write_Done 신호 생성.
Data Cache 구조, 그 안의 Buffer구조. Buffer-Cache-Memory 순서의 데이터패스는 FENCE 명령어에 필수적이다. 
캐시-메모리 Flush 수행이 끝나면 FENCE의 끝, 즉 쓰기 작업의 끝을 알릴 신호가 필요하다.
때문에 Write_Done 신호를 추가했다. (Data Cache → Control Unit)
 - !할일 이 신호의 의의 및 처리 과정, 체계, 사례를 비롯한 검증이 필요하다. FENCE 명령어면 Trap일텐데 Control Unit이 아니라 Trap_Handler에 신호가 가야하는게 아닐지.. 연구가 필요하다.
 
오늘 한 것 : FENCE, FENCE.i, ECALL, EBREAK 4가지 명령어의 기초 이해.
Data Cache - Memory 데이터 패스 변경, 버퍼 구조 추가, 정책 설정.
└ 그에 따른 신호 추가 구현
 - !할일 EBREAK에 대한 명령어 구현(물론 검증 및 데이터패스 시뮬이 필요하다.)을 했지만, MNEMONICS 및 명령어 매뉴얼에 서술된 RISC-V의 Debug모드 및, 디버거, Debugging 인터페이스 이해, 탐구가 필요하다.

2025.01.24.
어.. 어제 압도적인 방대함을 견뎌내며 개발하느라 일지를 최신화 못했다. 
사지방에서 마지막으로 만든 KHWL_RV32I47Fence 도면을 출력하고, 연등시간 끝나고 생활관에서 그 도면 뒤, 빈 페이지에 어제(25.01.23) 작업 내용을 수기로 적고 취침했다.
그리고 그에 대한 내용들을 정리하여 지금 최신화 했다. (20:36)
오늘은 많이 힘들다. 밀렸던 연구 조금 하고 연등 시간 70%를 기타공부하는데 썼다.
연구한 내용은 다음과 같다.
1. mret의 명령어 타입이 System 명령어라는 것은 비트 사용법에 대한 내용일 뿐 비트 체계(영역할당) 자체는 R타입과 동일하다.
때문에 ALUop시 별도의 System Instruction 타입을 아직까지는 추가할 필요 없다.

2. ALUop의 명령어 타입 식별은 6가지 전타입을 대상으로 하지 않아도 된다. R, I, S타입으로 충분하다.
ALU의 연산은 두가지 종류로 분류된다. 
A. 레지스터간 연산.
B. 레지스터와 상수값(imm) 연산
B는 또, 그 연산값이 데이터로 쓰일 건지, 주솟값으로 쓰일건지로 용도가 나뉘게 된다. 

이를 명령어 타입에 대입하여,
R은 레지스터간 연산
I는 레지스터와 상수값(imm) 연산 (데이터)
S는 레지스터와 상수값(imm) 연산 (주소값)  으로 정리할 수 있다.

R, I, S를 제외한 나머지 명령어 타입인 B, U, J타입이 이에 합승될 수 있는지 보자. 

B-Type은 레지스터간 비교 연산이므로 R타입에 해당하는 경우의 수. 
U-Type은 AUIPC 명령어; PC+imm 연산. 주솟값. S타입에 해당한다.
J-Type도 마찬가지로 S타입에 해당하는 PC+imm, 주솟값 연산이다. 

이러면 결국 3가지 명령어 타입으로 ALUcontrol 신호의 유형을 압축할 수 있다. 이러면 결과적으로,
 - ALUop코드, 지금의 Instr.Type 신호는 2비트 체제로 충분하다.
 
3. Data Cache의 Cache_Write, 즉 쓰기 활성화 신호는 필요하다. 
이러한 쓰기 활성화 제어 신호가 없으면 의도하지 않은 순간에 쓰기 작업이 실행되어 문제를 야기시킬 수 있다. 타이밍의 혼선을 방지하기 위해서라도 꼭 필요한 신호이다. 
(25.01.23. 할일 1번.)

4. 캐시에 버퍼 메모리 구조가 들어간 이상, 버퍼 및 캐시를 Flush하기 위한 제어 신호가 추가되어야 한다.
Flush enable 신호, Flush 로 저장할 데이터 주소 및 데이터 값 신호. (Flush_Addr, Flush_Data) 
  +++ 할일 추가
  Dirty Bit관련 로직연구 필요,. (아직 캐시 구조에 대한 이해가 목표 수준에 도달하지 않았음.)

버퍼 to 캐시 플러시는 우선 구현해야하지만 캐시 to 메모리 플러시는 아직 구현하지 않아도 된다. 지금은 Write-Through 방식이기에, 차후에 변경하면 된다. 

5. Write_Done 신호의 의의. 및 연결 대상.
FENCE 명령어가 모든 쓰기 작업이 끝날 때까지 대기하는 성질을 지니는데, 때문에 쓰기 작업을 다 마쳤다는 신호인 Write_Done 신호는 필수적이다.
예상했던 대로이다. 그리고 FENCE명령어로 메모리의 작업이 끝난 뒤 PC의 갱신으로 다음 명령어가 실행된다.
그리고 이는 예외처리 상황이 아니므로 Trap Handler와 관련 없이 Control Unit에서 처리한다. 
Write Done신호는 Control Unit의 입력으로 들어가, CU가 Data Cache의 쓰기/읽기 작업의 끝을 인지하면 PC값을 NextPC값으로 갱신하여 다음 명령어를 계속 실행하도록 한다. 

개선. 
생각해보면, FENCE는 메모리의 쓰기 작업의 완수로서 데이터 일관성을 보장하기 위한 명령어. 즉, FENCE시 추가적인 데이터 작업을 중지하고 현재의 메모리를 갱신하는데 의의가 있다.
때문에 FENCE 명령어 실행시 PC가 갱신되는 시점은 Write_Done신호가 출력된 이후여야하고, 이는 곧 PCC의 처리 영역이라 볼 수 있다.
신호 흐름을 더 명확히 하자. CU에서 opcode를 통해 FENCE명령어임을 확인하면, PCC에게 Fence_Enable신호를 출력해 NextPC값의 출력(PC갱신작업)을 멈추게 한다.
그리고 메모리 작업이 다 끝난 뒤, Write_Done신호가 PCC로 출력되면 그 후 NextPC를 출력하여 PC를 갱신하도록.

추가되는 신호체계
Control Unit 출력 신호
+FenceD
-Write_Done (removed to PCC)
PCC 입력 신호
+FenceD, Write_Done

(이를 통해 PCC는 차후 FENCE 명령어 외에도 TrapHandler에서 PC갱신을 제어할 수 있도록 할 수 있을지도 모른다. 비슷한 개념으로 구현 가능해보인다.)

6. EBREAK 명령어 시스템의 이해. 
자. 디버그가 무엇인지부터 이해를 해야한다.
디버그란? EBREAK 명령어와 같은 것을 실행하여 작동중이던 프로그램 시퀀스를 중단하고, 기존의 프로그램 흐름을 정지한 뒤, 해당 정지 지점을 기점으로 별도의 작업을 수행하는 것이다. 
EBREAK 명령어가 실행되면, 현재 PC에 있던 본래 프로그램의 흐름을 중단한다. 
이 말인 즉슨, 현재 PC값을 CSR파일의 mepc레지스터에 저장하고, PC의 자동 갱신을 중단하는 것이다.
그로 하여금, EBREAK를 실행한 기점의 CPU 상태는 정지되어 사용자가 별도의 명령어를 입력하기까지 대기하고 있게 된다. 
이 때, 사용자는 디버깅 툴을 이용하여 CPU를 제어할 수 있다. 
이 디버깅 툴과 CPU를 상호작용할 수 있게 하기 위한 중간 다리인 디버그 인터페이스가 필요하고, 디버그 작업의 제어를 위한 디버그 컨트롤 유닛이 필요하다. 

디버그 모드가 활성화되면, PC값은 멈추고, 사용자가 프로그램 흐름상 예정에 없던 연산을 수행하여 데이터 값을 변경시키거나 읽을 수 있다. 
만약, EBREAK 이후 add x6, x7, x10 이라면 이 명령어는 PC나 Instruction Cache-Memory를 거치지 않고 그대로 Instruction Decoder로 입력되어 수행된다.
이와 같은 디버깅 작업이 끝난 뒤, 원래의 프로그램 실행 흐름으로 다시 오기 위해 mret 명령어를 실행하여 mepc의 값을 PCC에서 NextPC 값으로 출력한다.
이로서 디버그 모드를 종료하고 원래의 프로그램 흐름으로 돌아올 수 있게 된다. 

[EBREAK 감지.]
I_RD 신호 Instruction Decoder 및 Exception Detector 입력.
Exception Detector EBREAK 감지. Trap_Status를 10으로 출력. 
Trap Handler, Trap_Status를 통해 EBREAK 감지. CSR_Addr, CSR_Data 신호를 통해 mepc와 mcause 값을 CSR파일로 출력.

[PC 갱신 정지 시퀀스]
디버그 모드 활성화. PCC의 NextPC 출력 중지. 

[디버깅]
외부 디버거가 add x7, x5, x6 명령어를 디버거 인터페이스로 전달.
디버거 인터페이스에서 Instruction Decoder로 해당 명령어 출력.
CPU가 해당 명령어 실행. 레지스터 및 메모리 값들이 디버깅에 따라 변화.

[디버그 탈출]
디버거가 작업을 완료하고 mret 명령어를 실행.
Trap Handler에서 mepc값을 
하.. 거의 다 왔다 싶었더니 mtvec 레지스터는 또 뭐야...

---긴급회의---
또 다시 지적 수용 한계에 부딪혀 머리를 정리하기 위해 생활관으로 올라가 CC84와 긴급 회의를 하고 왔다.
mtvec이라는 레지스터가 뭔지 알아보니, TrapHandler의 시작 주소값을 담은 CSR이라 한다. 
"시작 주소값"???? Trap Handler는 모듈이 아니었단 말인가???
그러하다.. 전말을 알아보니, 예외 상황이 발생하면 그를 처리할 루틴이 필요하고, 그 루틴을 별도로 처리하기 위한 예외 처리 모듈이 당연히 필요하다. 
하지만 나는 이걸 하나의 모듈에 할당된 로직으로 이해했고, Trap Handler 그 자체가 루틴이라는 것을 인지하지 못하고 있었다. 
Trap Handler를 프로그래밍하여 예외 호출 시 시작 동작을 바꿀 수 있다는 것을 CC84로부터 소프트웨어 디버깅 관련 정보를 들으며 알게되었다. 
털렸던 멘탈을 충분히 회복했다. 해당 정보를 반영하여 마저 적어보겠다.
---긴급회의 끝---

Trap Handler 루틴은 디버그 모드로 전환된 후, 외부 디버거와 상호작용 시작 전 실행된다.
이는 소프트웨어 루틴이므로, CPU가 Trap_Control 모듈이 지정한 mtvec주소로 점프해 Trap_Handler 코드를 실행하게 된다. 
 - !할일 (이 Trap_Handler 루틴의 코드를 직접 작성해야할 듯 싶다.)
Trap_Handler이 수행하는 역할은 다음과 같다.
0. CSR 갱신.
Trap Control 모듈이 CPU의 현재 상태;mepc, mcause 등을 CSR에 저장.
이 CSR의 갱신 과정은 Trap Handler 실행 전 Trap_Control 모듈이 수행한다.

1. Trap Handler 진입.
Trap_Control 모듈이 CSR의 mtvec값을 PC값으로 지정한다. (PCC에 NextPC값을 mtvec 값으로 출력하게끔 한다.)
CPU가 mtvec주소값으로 점프하여 Trap Handler 루틴을 실행한다.

2. 상태 분석 및 초기화
Trap Handler 루틴을 통해 CSR값을 읽어 mcause(예외 원인)과 발생지점(mepc)를 분석.
디버거와의 상호작용 준비를 위해 필요한 초기화 작업 수행.
이게 실제 수행 역할인데, 이에 대한 연구가 조금 더 필요하다. 
 
- [EBREAK의 처리 과정]

1. [EBREAK 감지.]
I_RD 신호 Instruction Decoder 및 Exception Detector 입력.
Exception Detector가 EBREAK 감지. Trap_Status를 10으로 출력. 
Trap Control가 Trap_Status를 통해 EBREAK 감지. 디버그 모드 활성화 준비.

2. [디버그 모드 활성화 준비.]
Trap_Control모듈, CSR_Addr, CSR_Data 신호를 통해 mepc와 mcause를 CSR에 기록. (mcause; EBREAK code = 3)

3. [Trap Handler 수행]
Trap_Control 모듈이 PC를 CSR의 mtvec 값으로 설정. 
CPU, Trap Handler 루틴으로 점프하여 디버그 모드 준비.
Trap Handler 루틴은 CSR에서 mcause와 mepc를 읽어 디버거와 상호작용 준비.

4. [PC 갱신 정지 시퀀스]
Trap Control이 디버그 모드 활성화. PCC의 NextPC 출력 중지. 

5. [디버깅]
외부 디버거가 add x7, x5, x6 명령어를 디버거 인터페이스로 전달.
디버거 인터페이스에서 Instruction Decoder로 해당 명령어 출력.
CPU가 해당 명령어 실행. 레지스터 및 메모리 값들이 디버깅에 따라 변화.

6. [디버그 탈출]
디버거가 작업을 완료하고 mret 명령어를 실행.
Trap_Control 모듈에서 mepc값을 불러와 해당 값을 PCC로 출력해 NextPC값을 mepc의 값으로 PCC가 출력할 수 있게 한다.

7. 종료.

일단 여기까지. 원래 다이어그램을 지금 만든 변경사항대로 반영해야하나, 오늘 당직근무가 예정되어있어 그럴 수 없다. 
수행해야할 것들을 인쇄하여 마저 진행해야겠다. (17:30)



2025.01.26
아.. 수면 패턴 박살나고 피로가 상접하며 정서가 장난아니다.. 힘들다..
그래도 해야한다..
17:27

자... 디버깅 이전 TrapHandler루틴이 실행되어야 한다. PC에 TH 주소값이 입력되어야한다. T_Target으로 
Trap_Control에서 출력되도록 하면 될 것 같은데. 

그럼 데이터 패스가 이렇게 된다.

PC - I.C - EBREAK - ED가 TrapStatus를 EBREAK로 선택해서 TC로 출력. NextPC를 T_Target으로 출력하기 위해
Trapped신호를 PCC에 출력. 
TC - CSR_Addr,Data를 통해 mepc,mcause를 CSR에 기록.
CSR에서 출력받는 mtvec 주소를 기반으로 TH의 시작위치를 계산. T_Target으로 해당 주소값을 출력. 
PCC에서 앞서 Trapped신호를 입력받아 T_Target을 입력받고 NextPC를 TrapHandler 루틴의 시작 주소값으로 출력. 
IC-IM을 거쳐 TrapHandler 수행.

이제 디버거가 직접 명령어를 입력해 수행하는데, ID에 그럼 ..
아니 정확히는 디버깅시 Instruction Cache나 Memory에 대한 접근 및 수정도 가능한게 아닌가? 
오직 명령어 수행만 가능한것인가? 메모리 구조는 읽기 및 명령어 수행을 통한 쓰기? 아니면 그냥 다 명령어만으로 가능한거구나..
그럼 IC.IM_MUX의 출력 신호 I_RD 이전에 Dbg.Instr 신호사이에 선택하는 MUX가 추가로 하나 있어야할 것 같다. 
그렇게 함으로서 Debug 모드 진입했을 때 I_RD와 Dbg.Instr사이에 선택하여 명령어들을 제어할 수 있을테니까.
이 때 이 I_RD.DbgInstr_MUX의 제어 신호는 어느 모듈이 담당해야하는거지? Debug Interface인가? Trap Control인가?
아니면 Control Unit인가?

밥먹고 오자.. 다이어그램을 또 수정해야할 것 같은데 IC-ID 사이 공간이 많이 부족해서 또 대공사를 해야할 것 같다.
19:01
밥먹으면서 생각에 잠기며 쓸데 없는 망상에 빠졌었다
겨우 헤엄쳐 나와, ide를 켜고, 컨테이너 로딩을 기다리며 주임원사실 앞 정수기에 따뜻한 물을 받았다.
코코아를 타마시려고 했는데, 스테인레스로 된 머그잔의 내부가 너무 차가워서 금방 식는 것이라 생각했다.
그래서 물을 먼저 넣고 휘저으며 잔이 따뜻해질 때 까지를 기다리고, 물을 버리고, 안에서 김이 모락모락 나는 것을 바라보았다.
옆에서 인호가 걸어왔다. 복장을 보니 근무는 아닌 것 같다. 생활복에 후리스를 입고 있었다.
'안녕' 인사를 건네본다. 시선은 컵에 가면서.
'~~강' 잘못 들었나 했다.
'어?'
'젠슨 강.'
ㅋㅋㅋ. . 음. 맞아. 난 그렇게 될거야. 내가 지금 바라보는 미래가 그가 바라보았던 미래의 흐름과 다를 것이 무엇인가. 나도 할 수 있어.
머지않은 미래에 젠슨 강 이라는 이름처럼 불릴 나의 이름을 되짚어보았다.
'어디가?'
'노래방 키 가지러'
'잘 놀다와'
'그래'

밥 먹으면서 고뇌에 빠졌을 때, 그로부터 막 헤쳐나왔을 때 건너편 자리의 의자에 적힌 문구가 내 눈을 잡았다.
'인내하는 자만이 원하는 바를 이룰 수 있다.'
인내하는 바를 이룰 수 있다.
인내하는 자만이 이룰 수 있다.
원하는 바를 인내하는 자만이 이룰 수 있다.
이룰 수 있다. 원하는 바를. 인내하는 자만이.
하면 된다. 사실이다.
하면 된다. 사실이다.
하면 된다. 사실이다.
인내하는 자만이 원하는 바를 이룰 수 있다.
인내하는 자만이 원하는 바를 이룰 수 있다.
인내하는 자만이 원하는 바를 이룰 수 있다.

RV32I47F 코어 디자인이 끝나면, 난 바로 VerilogHDL로 넘어간다. 애초에 처음에 목표했던 '40가지의 기본 모듈 구조를 백지에서 적을 수 있을 정도의 소양'을 갖추지도 못했는데 그에게 맡기기만 하고 편하게 있을 수 없는 노릇이다. 
계속 나아가자.

---
IC.IM - ID 사이 Dbg.Instr MUX 모듈을 추가하기 위해 신호를 최적화 하고 기존 모듈들을 오른쪽으로 밀던 와중, 신호 오류를 발견했다.
무슨 생각이었는지 모르겠지만, CSR_Addr의 src 제어 신호와 CSR_WD의 src 제어신호가 공유된다. 이를 고치기 위해 Control Unit의 CSRsrc신호를 CSR.Addr.src, CSR.Data.src 신호로 쪼개려고 한다.
이를 위해 Control Unit의 신호 위치들을 조정하고 있다.(19:50)
RV32I47EBpush 이름으로 중간저장. 20:40.
슬슬 다이어그램 툴을 더 찾아봐야할 것 같다. draw.io 외의 다른 프로그램으로.

연등시간.
CC84의 건의. 
기존 ALUcontrol 모듈의 코드를 보았을 때, srli, srai의 구분자가 I타입이기에 funct7값을 식별자로 사용하는 것이 아닌,
imm값을 식별자로 가진다. srl, sra는 funct7을 가지며, register에 담긴 값 만큼 shift를 하고, srli, srai는 입력된 shamt영역 imm값 만큼 shift한다.

I 타입의 비트 체계는 
imm[31:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | opcode[6:0]
이 imm의 영역 중 [31:25]가 funct7같이 srli, srai를 식별하고, [24:20]이 shamt영역으로 shift를 얼마나 할 건지를 나타내게 된다.

때문에 ALUcontrol 모듈에서 식별을 위한 imm값의 입력신호가 추가로 필요하다. 추가했다. 

CC84의 건의2. 
slli, lh 명령어. 둘 다 ALU 연산을 사용하고, 그 둘의 식별은 opcode로 밖에 안된다.
같은 I 타입이고, funct3값도 같은데 opcode로 구분하자니 ALUcontrol에 opcode신호가 없다.
Instr.Type을 별도로 CU에서 인코딩하여 ALUcontrol 모듈로 올게 아니라 opcode 자체를 ALUcontrol 모듈에 입력하도록 하는 것이 더 합리적이다.

때문에 Instr.Type 신호를 opcode로 replace했다. 

또한, ALUcontrol 모듈에서 ALUcontrol 신호를 내보내면 혼란이 있을 수도 있고, ALU의 동작 코드를 담은 신호이며 기존의 ALUop라는 신호를 없앴으니
차라리 ALUcontrol에서 ALU로 주는 동작 명령 신호를 ALUop로 하자 건의했다.
CC84 승인. 그렇게 바꿨다.

모듈을 다 옮기고 I_RD.DbgInstr_MUX를 추가했다. 
이 것에 대한 제어 신호의 질문. 위에서 했던 것.
----------
- 이제 디버거가 직접 명령어를 입력해 수행하는데, ID에 그럼 ..
아니 정확히는 디버깅시 Instruction Cache나 Memory에 대한 접근 및 수정도 가능한게 아닌가? 
오직 명령어 수행만 가능한것인가? 메모리 구조는 읽기 및 명령어 수행을 통한 쓰기? 아니면 그냥 다 명령어만으로 가능한거구나..
그럼 IC.IM_MUX의 출력 신호 I_RD 이전에 Dbg.Instr 신호사이에 선택하는 MUX가 추가로 하나 있어야할 것 같다. 
그렇게 함으로서 Debug 모드 진입했을 때 I_RD와 Dbg.Instr사이에 선택하여 명령어들을 제어할 수 있을테니까.
이 때 이 I_RD.DbgInstr_MUX의 제어 신호는 어느 모듈이 담당해야하는거지? Debug Interface인가? Trap Control인가?
아니면 Control Unit인가?
----------
이것에 대한 답을 알아야한다. 일단 여기까지 하고 중간 저장.
틑ㅁ틈히 위에 있는 변경사항 반영하고 신호 최적화도 같이 했다. (23:54)

해야할 것 들.
Debug시 어느 모듈들에 영향을 끼치게 되는지.
이에 따라 각 모듈별로 디버깅시 제어 및 수정을 할 수 있도록 필요하게되는 신호들의 파악.

아. I_RD.DbgInstr_MUX의 신호는 Debug모드 진입시 ID의 I_RD값을 조정해야하므로 Trap_Control 모듈에서 제어하는 것으로 했다. 오늘은 여기까지.


------
2025.01.27
오늘은 개발 환경의 개선을 위해 여러 시도를 해봤다.
오전 동안에는 새로운 다이어그램 툴로 사용가능한지 보려고 d2 language를 기반한 툴을 사용해봤고, 지금과 같은 개발 환경에서는 부적합하다는 결정을 내렸다.
또한 새로운 AI툴인 딥시크 AI를 통하여 새로운 어시스트로 활용할 수 있는지 기존 개발 과정을 Import해서 사용해보았으나 읽기 데이터 양의 한계가 있어 사용하지 않기로 했다.
Diagram을 어느정도 고쳤다. 신호를 최신화 하고 등등.

이제 다시 시작이다. (14:07)

디버그 모드에 필요한 유닛들을 구성하다가 그럼 도대체 어디까지 설계해야하는 것인가. 디버깅 로직들을 준비하기 위해서는 디버거에 대한 정보가 필요하다.
어떤 명령어들을 쓰고, 그 디버깅이 어떻게 이루어지는지. 근데 이건 또 별도의 프로세서 즉 디버깅 유닛을 설계하는 셈이 되어버려 "지금 할 것은 아니다" 라는 결론에 도달했다.
지금은 그저 EBREAK시 디버그 모드 진입 준비, 디버그 진입. 디버그 명령어가 Instruction Decoder에 제대로 들어가는지, Debug Mode가 제대로 활성화 되는지. mret으로 기존 프로그램 흐름으로 돌아갈 수 있는지
이 EBREAK 명령어의 흐름만 구현하면 된다. 

탑코어 모듈 다이어그램에 디버그 인터페이스를 추가해두고, 일단 이렇게 RV32I47F 1차 코어 디자인이 끝나는 것 같다.
(사실 2차이긴 한데, 그 때는 EBREAK 및 FENCE 명령어들에 대한 지원을 누락하고 있었으니.. 진정한 의미로는 이번이 1차가 맞다.)

---아래는 신호 배선 최적화 과정 중 진행된 것이다.---
CSR의 주소 연산이나 데이터 값 연산에 imm값이 포함되는 경우가 있나? 만약 있다면, 이 경우 imm의 값은 32비트 Sign-extended된 ex-imm값인가 아니면 명령어 타입별 비트체계 그대로의 imm값인가?
- 비트 체계 그대로의 imm 값이다. ex-imm은 ALU연산에서 주솟값 연산 혹은 I-Type 명령어 처리를 위해 쓰인다. 

CSR에 Write나 Read 신호는 필요 없나? Register File은 입력이 항시로 되어있어 읽기가 주로 되어있는 유닛이니 그렇다 쳐도, CSR File은 조금 다른 생각이 들었다.
특정 상황에서 쓰고 읽는 연관이 깊은 순간이 꽤 생기는데 (Exception, Trap이라던가) 이 경우 쓰기와 읽기의 명확한 제어 신호가 없으면 타이밍이 꼬이거나 의도치 않은 값을 읽거나 쓸 수 있을 것 같았다.
때문에 기존에 있던 CSRenable 신호를 분리했다. 
- CSRenable → CSR_Read, CSR_Write

RV32I47F 코어 디자인 적용도 마쳤다..
신호들과 모듈들을 정렬했다. 16:32..

이제 탑 모듈 다이어그램 수정해야한다.
김용우 교수님께 설날 인사도 드릴 겸 혹시 산업계나 이 쪽 분야에서 사용하는 블럭 다이어그램 툴이 따로 있는지 여쭤봤다.
별도로 없다고 하셨다. 마이크로소프트 비지오나 파워포인트에서 일일히 그린다고 하신다... 그럼 뭐.. draw.io에서 설계하던게 혹시나 손해보고 있는 걸 줄 알았는데 아니니 다행이다.
오히려 더 편한 툴이 없다는데에 절망을 해야하나...

Top Module Design에서 각 모듈별 누락된 신호체계는 없는지 확인하다가 문득 생각난 질문.

현재 데이터 캐시의 구조와 정책은 이러하다.
캐시 쓰기의 경우, 캐시의 버퍼에 빠르게 먼저 쓰기를 진행한다.
나중에, 버퍼를 캐시에 동기화하며 그와 동시에 메모리에도 동기화를 진행한다. 즉, 버퍼에서 메모리로 주소와 데이터값이 넘어가는데, 이 Flush 작업을 하라는 것을 알릴 제어신호가 없다는 것을 알아차렸다.
 - B2M_Flush 명령어 추가. Memory Controller에서 나오는 신호이다. 
이 경우, Data Memroy에서도 쓰기 작업이 활성화 되어야하니 FENCE 명령어를 식별했을 때, Control Unit에서 같이 Memory_Write 신호를 활성화해야한다.
RISC-V ISA에 캐시의 버퍼를 캐시와 메모리에 Flush 하는 것에 대한 관련한 별도의 규정된 명령어는 없다. 
보통 캐시의 동기화 작업은 FENCE 명령어로 처리되는데, 이 때문에 Control Unit에서 FENCE시 MemWrite를 활성화하는 것으로 한 것이다. 
근데, 지금처럼 캐시의 버퍼에 저장하는 것과 캐시 자체에 저장하고 나중에 Flush로 메모리에 동기화하는 것의 동작상 차이는 없는 것 같은데..
추가 연구가 필요하다.
 - !추가 할일.
 
밥먹고 오자.. 17:26.. 점심도 걸러서 배고프다..

허허 Top Module Design 위에서 했던 것들이 없어졌다. 클라우드에 업로드하는 과정 중 구버전을 그대로 올려버리고 갱신했다 생각한 것 같다...
modules.md나 업데이트해야지..

23:51. 모듈 문서 신호 체계 및 신규 모듈들 추가 완료. 
모듈 하나하나 점검하며 RV32I47F의 신호들의 이름도 같이 최적화하여 반영했다.
다이어그램에 색깔을 추가했다. 3단계의 색깔로 나뉜다. 
파란색은 Verilog 구현 완료 모듈
초록색은 구현 작업 중인 모듈
빨간색은 미구현, 더미 모듈.
RV32I47F.R2로 명명한다.
--------
- 내일 할 일
클럭이랑 리셋 신호 들어가야할 모듈 확정짓기.
TopModule 다이어그램 다시 만들기..
 - 레포지토리 Docs 폴더 계획대로 재구성하고 최신화하기..
documents 폴더 하위
/legacy blocks 폴더 생성
	//draw.io 파일 폴더 생성
	//png 파일 폴더 생성
	//pdf 파일 폴더 생성

/Current Design 폴더 생성

/Theories and Logics 폴더 생성
	//Modules and Signals 폴더 생성
	//ISA 폴더 생성
/Project Development 폴더 생성

commit, push하기. 

1. Documents 폴더 구성 완료. 기존 네이버 클라우드에 올려둔 파일들 모두 이전했고, 각 파일별 생성날자 들을 담은 Development History 파일 생성 예정.
└ 나중에 언젠가 Documents 폴더 내 파일들 생성 날자 적어둔 History파일 만들어두기.

2. 클럭 리셋 신호 인입 모듈 확정완료.
RV32I47F.R3로 업데이트.
17:18.
16시 초 정도에 분명 했었는데 잠시 졸도했더니 컴퓨터는 꺼져있고 작업물 날라가있었다. 다시 작업함..

 - Instruction Decoder
1. imm이 원값 그대로 나오고, 필요에 따라 Sign-Extension을 통해 ALU로 전달되는 형식이었음.

CC84
[문제 제기]
기존의 체계에서 Imm가 12비트 체계. 
Reason : U타입 명령어에 imm길이가 20비트짜리였기 때문.
현재의 ID에서 나오는 imm신호는 CSR, ALUcontroller(연산 종류 판단)같은 연산을 제외하고는 무조건 Sign-Extension하여 ALU로 꽂히게 되어있었다.
여기서 문제 발생.

현재 Imm_gen에서는 입력 imm값의 몇 번째 비트가 MSB인지를 알 수 없었음.

-> 0000111010 -> 5비트째를 MSB로 보고 extens
-> 0001111001010-> 어 이것도 위엣건가? 5비트에서 할게 ㅎㅎ ^^7
이러면 망한다.

무조건 12비트라 간주를 하고 쓰는데, 그렇게 되면 20비트인 U타입의 경우 20비트에다가 12비트인 줄 알고 MSB를 착각해 데이터가 망가져버릴 우려가 있다.
때문에 Imm_gen이라는 간단한 역할을 수행하는 로직에 별도의 구분자 및 컨트롤 신호를 부여하는 것이 오히려 직관성을 떨어뜨리니, Instruction Decoder단에서 해결하기로 결정.

- 해결 방안: ID에서 기존에 나오던 RAW Imm비트 값을 32비트 확장 (Zero-Extension.) 
U타입 AUIPC의 경우(20비트 imm체제) Extension을 거치지 않고 이 Zero-Extension된 imm값을 바로 이용하도록 설계. (Bypassing)

나머지의 경우(12비트 imm체제) imm_gen을 거쳐 12비트 기준으로 Sign-Extension된 ex-imm값을 ALU로 넘겨 연산.

모듈 변경 사항. ALUsrcB에 소스 추가... 일반 imm신호.. 4:1 MUX...
그러면 Control Unit에서도 U타입을 인지했을 때 ALUsrcB를 imm으로 해야함.

19:14 RV32I47F.R4 리비전 완료.
위의 imm문제 반영(4:1 ALUsrcB MUX)됨. 신호체계 최적화도 같이 함.

이제 Docs작업한거 commit하고 푸쉬해야할 때가 됐다..

19시 45분경 완료.
이제 남은게.. Top Moduel Re-design하는거랑...
명령어 데이터패스 검증인가..
ChoiCube84가 구현하며 가져오는 문제점들 일부가 데이터패스의 검증 과정에서 충분히 발견될 수 있는 것들이었다.
(물론 구현 과정에서 신호의 최적화 및 로직만을 다루는 CC84의 입장에서 더 잘보이며 그가 하고있는 작업에서만 보이는 문제점들도 있다.)
설계도면을 코팅해서 하나하나 따라가봐야겠다. 
MNEMONICS랑 비트 체계를 같이 통합해놓은 문서가 있으면 좋을 것 같은데, 직접 만들어야하나..

아 이것도 CC84의 건의인데, 
최신판 RISC-V 매뉴얼이랑 우리가 직접 갖고 하고 있는 컴퓨터 설계 및 구조 RISC-V Edition 및 참고 문헌에 적혀있는 ISA가 살짝 다르다.
최신판을 기준으로 하여 매뉴얼을 기반하여야하는데, 그런 입장에서 FENCE.TSO라는 명령어가 등장하고 UJ,SB 명령어가 명시되어있지 않다.
그냥 SB는 B타입으로 통칭되고, UJ는 J타입으로 통칭된다. 
FENCE.TSO는 뭐지? 확실히 FENCE.i가 없고 FENCE.TSO가 있다. RV32I Instruction Listings에서.

비상... FENCE.i는 Zifence.i 확장의 명령어일 뿐 RV32I의 기본 명령어가 아니다... 삽질했다...
다행히도., 덕분에 플랫폼을 어느정도 갖춰서 괜찮긴한데.. 아,..,.,.,
뭐 좋은 것 아니겠는가... 더 큰 무언가를 만들게 된건데..
실질적으로 추가해야할 건, FENCE.TSO명령어와 PAUSE명령어이다..
관련해서 어떤 역할을 하는지, 어떤 모듈에서 어떤 신호체계로 구현이 가능한지 더 연구해봐야한다..;. 일단 여기까지..
20:27
-------

어우 몸살 목감기다... 많이 피곤하지만 일단 그래도 연등했고.. 알아낸거 정리..
FENCE.TSO는 FENCE의 하위호환 FENCE 명령어. FENCE에서 제어하는건 I, O, R, W 이 네가지 신호인데,,
일반 FENCE는 4가지에 대하여 혹시나 동작 충돌이 날 수 있으니 그 직전 4가지 타입중 어떠한 연산이라도 다 끝낸 다음 다음 명령어를 수행하게끔하는
메모리 일관성에 대한 명령어이다.
TSO는 Total Store Order의 약자로, 메모리 접근 순서에 따른 메모리 일관성 오류의 해결 정책 중 하나인데, R, W에 한정하여 이전 명령을 다 끝내고 다음 명령어를 실행하도록 한다.
실제 명령어도 비트 체계에서 구분자만 가져다 두고 rs1값이나 다른 필드는 무시(ignore)하라고 나온다..

PAUSE도 마찬가지.. 얘는 사실상 언급으로도 나오지만 NOP취급하면 되는 것 같다.. 얘는 더 알아봐야함..

내일할거...

2025.01.29
아니 저장이 안되어있었네
열 38도 죽을 것 같다.
그럼에도 공부한 내용 정리
FENCE명령어 및 PAUSE, HINT명령어, Hart 등등.
FENCE명령어는 기본적으로 Memory Ordering에 해당하는 명령어.
다중 코어나 다중 스레드 연산시 메모리 참조에서 순서 위반이 나올 수 있기 때문에 이 오류를 해결하기 위한 명령어.
FENCE 기본 명령어를 기반으로 비트 식별자를 다르게 하여 파생되는 명령어들이 나온다. 
FENCE.TSO, PAUSE가 그러하다. 

FENCE - 메모리 및 입출력에 대한 order를 제공.
successor가 작업을 수행하기 전에 모든 메모리 작업을 완료하는 것.

FENCE.TSO - Successor가 어떤 메모리 operation이든 수행하기 전에
predecessor가 load수행을 다 마치는 것.
그와 동시에, Successor가 어떤 Store operation이든 수행하기 전에
predecessor가 모든 Store 수행을 다 마치는 것.

PAUSE - 이 명령어를 알기 전에, RISC-V에서 규정하는 HINT명령어가 무엇인지 알아야한다. 
일단 여기까지.. 밥먹고 약 먹고 오자.. (17:26)

I'm so back. 약 먹고 좀 많이 괜찮아졌다. 열은 있지만 몸살이 많이 나아졌다.
HINT명령어는 RISC-V에서 아무런 영향을 끼치지 않는 명령어를 뜻한다. 실행은 되는데, 아무런 영향을 못 끼치는.
예를 들어, ADD 명령어에 x0주소에 행하는 명령을 실행하면 이 명령어는 아무런 의미가 없다. x0 레지스터는 0값이 고정이기 때문이다. 
이러한 개념적 행동을 하는 명령어를 HINT라고 한다. PAUSE가 그러하다. 
PAUSE명령어는 Zihintpause 확장에 포함되는 명령어이다. 
현재 hart의 명령어 폐기율이 일시적으로 줄이거나 일시적으로 중지해야함을 나타낼 뿐이다.
아키텍처적으로 아무런 영향이 없다. 멀티스레드 또는 멀티 코어 환경에ㅓㅅ 메모리 참조할 때 일관성 위반으로 다른 코어/스레드에게 역할을 넘겨주거나 쉬는.
결국 우리 구조에서는 nop로 처리하면 된다.
hart는 RISC-V 를 사용하는 완전한 컴퓨팅 시스템 유닛을 뜻한다.
(20:58)

데이터 패스 검증의 시간
이건 별도의 Datapath 문서에서 진행하겠다.

RISC-V, The RISC-V Instruction Set Manual Volume I
Unprivileged Architecture
Version 20240411기준. 

Chapter 34. RV32G/64G Instruction Set Listings | Page 555 참조한다.

lui 명령어부터 차례대로 검증해보겠다. 명령어 타입별로 하는게 맞는 것 같긴한데.. 일단은.

Register File에 Write되는 정보는 4가지 분류로 하고, 그 데이터패스는 일관되게 한다.
Data Memory로부터 옮겨지는 LOAD 데이터들.
rs값 혹은 imm값을 기반으로 어떠한 연산을 거친 ALU 데이터들.
CSR File로부터 옮겨지는 CSR LOAD 데이터들.
PC+4 값.

LUI는 현재 아키텍처상 ID에서 Zero-extension이 이미 이루어진 채로 imm신호가 출력되니 그대로 Register에 저장하면 되지만,,
ALU를 거치는 것이 데이터패스 일관성에 기여하기 때문에 RegF_WD_MUX를 거쳐 가는 것으로 한다.

생각해보니 항상 Zero-Extension을 하는게 무언가 좀 찜찜하다.. 차차리 Immgen에서 명령어 타입을 받아 적절히 Sign-Extension하는 것이 맞지 않을까?
얼핏 어디서 본 것으로 기억하자면 RISC-V는 Sign-Extension을 전제로 이루어진다고 본 것 같은데.. 항시 Extension이 비효율적으로 보이기도하고...

2025.01.30
Confliction.
내 주장 : 모든 명령어의 imm값을 Zero-Extension하여 출력하는 것은 비효율적이다.
imm값을 32비트로 Zero-Extension하여 쓰이는 명령어는 U, J타입에 국한될 뿐더러, 나머지 imm값을 포함하는 명령어(I, S, B)는 Sign-Extension을 무조건 거쳐서 사용하게 되어있다.
불필요한 Extension을 하여 추가적인 산술논리 연산을 거치는 것
데이터패스에 불필요한 만큼의 비트크기를 가지게 된다는 것.

상황 : J 타입의 명령어 비트 체계를 보면, imm[20|10:1|11|19:12] | rd[11:7] | opcode[6:0].
U타입은 [31:12]. CC84는 이 점이 캥긴다 했고, 컴퓨터 구조 및 설계 RISC-V 에디션의 4장, 그림 4.16, 4.17을 근거로 사용되는 MUX를 줄이기 위해
U와 J타입의 상수값은 raw값을 그대로 보낼 것이 아니라, 32비트로 Zero-Extension된 값을 Instruction Decoder에서 imm값을 내보내고
그걸 imm_gen에서 sign-extension변환을 해야한다 했다. (31:12비트라는 서술 자체가 extension된 값을 전제로 하고, 그것이 zero-extension된 값일거라 주장.)
하지만 근거로 든 4.16과 4.17에서 시사하는 바의 타당성이 모호해지며 불확정성에 비트를 소모시키기 보단, 개선방안을 택하기로 했다.

 - 개선안
Instruction Decoder의 imm 비트폭은 20비트. 
12비트 imm쓰는 값은 그대로 12비트를 내보낸다. 남는 8비트는 don't care. 어차피 가져다 쓰는 imm_gen에서 필요한 비트만큼 slice해서 쓰면 된다.
20비트 imm값은 그대로 20비트를 imm_gen으로 내보낸다.

imm_gen에 opcode입력을 추가하여 명령어 타입에 따라 적절한 sign-extension을 진행할 수 있도록 한다.

개선된 데이터패스 적용안.

U타입 : 명령어 2개
-auipc, lui
-lui는 {imm,12b'0}을 rd주소 Register에 저장. 즉 imm을 zero-fill한 것을 rd에 저장.
-auipc는 PC + {imm,12b'0}을 rd 주소 Register에 저장. 즉 PC에 zero-fill된 imm값이 덧셈되어야 함.
ALU를 덧셈으로 써야하므로 zero-fill자체를 ALU에서 처리하는 것은 적합하지 않음.
-> imm_gen에서 처리하자.
U타입은 imm_gen에서 zero-fill된 32비트로 나간다. 

J타입 : 명령어 2개
-jal, jalr
-jal은 R[rd] = PC + 4; PC = PC + {imm, 1b'0}
-jalr은 R[rd] = PC + 4; PC = R[rs1]+imm.

-jalr은 별도의 R[rs1]값과 덧셈을 해야하므로 imm이 sign-extension되어야함.
(ALU에서 처리되는 모든 데이터는 32비트이다. )
-jal은 PC값과 {imm, 1b'0}값을 덧셈해야한다. 
J타입 명령어의 imm필드에 대한 설명을 Unprivileged Manual에서 참조하자면, 
"The offset is sign-extended and added to the address of the jump instruction to form the jump target address. Jumps can therefore target ±1 MiB range."
해당 imm필드 값을 sign-extension을 수행한 뒤 1비트 쉬프팅.

허허 이제 알게되는거. shamt의미는,, shift amount.. 즉 i타입 명령어에서 shift 연산 명령어는 imm값을 sign-extension하지 않는다. 
또한 csr레지스터의 주소 필드 자체가 12비트 필드이기 때문에 별도의 확장 필요 없다.

하지만 csr명령어 중 imm가 들어가는나머지 명령어들은 imm이 연산값이기에 zero-extension이 필요하다. 

ALU에서 바이패스할 신호.. 어라 오류. 333번째 줄에서 언급한 CSR을 Register로 저장하는 명령어는 csrrw;CSR Read&Write이다.
R[rd] = CSR ; CSR = R[rd]. 
그래서 이걸 몇 번째 설계도였는지 기억나지는 않지만 RegF_WD_MUX에서 Input중에 하나로 이미 넣었었다...?
이러면 ALU Bypass 로직이 딱히 필요가 없어지는데..?
U-Type인 LUI 명령어도 결국 12'b0 제로필 값을 R[rd]에 저장하는 것이고, 그게 그 전부라서 딱히 ALU연산을 거치지 않는다..
이건 Imm_gen에서 담당해줄 명령어 같은데.. ALU에서 처리를 하지 않는 이유는 같은 타입인 AUIPC에서 imm, 12b'0이 별도연산이라 가정하면 ALU는 두 사이클을 소모해야하기 때문에 모순되기 때문이다. 

이 경우엔 Bypassing이 필요할지도..? 아니면.. 상수 확장 처리 후 그걸 바로 레지스터에 넣는 경우가 많은가? 많다면 imm_gen에서 Register File로 향하는 다이렉트 신호를 추가하고,
아니면 ALU Bypass를 이용하도록 한다. 없다. Bypass하자. 그러므로서 CSR_RD 다이렉트 신호도 없앤다. 이걸 계속 이렇게 넣다보면 저 MUX가 너무 커진다.
막 큰차이는 없는 것 같은데.. 다이렉트 신호가 성능상 더 나은가? 그렇다 .다이렉트가 더 낫다. 설계원칙인 모듈의 역할을 명확히 하는 것에도 부합하니 별도의 MUX를 두자.

ID에서 나오는 값은 20비트이며, 12비트와 20비트 중 나오게 된다.
12비트 값은 있는 그대로 보내지며, zero-extension은 명령어에 맞게 imm_gen에서 이루어진다.
zero-fill도 동일(LUI, AUIPC). Sign-extension 이하 동문.

지금하 ALU src에서 불필요한 신호 없는지 보는 중.
Direct 신호 체계 도입했으니 저건 변화하는게 맞다. 

이왕 검토하는거 모든 ALU의 소스들을 조사했다.
그 결과, ALUsrcB는 RD2와 ex-imm만을 갖는다.
RegF_WD_MUX에는 CSR_RD값과 ex-imm값이 추가됐다.

jal 명령어에서 PC= PC+{imm, 1b'0}인데, NextPC값이 PC+{imm, 1b'0}이 되는건가? 흠.... 그런 것 같다. Jump니까.

2025.01.31
오전 일과 시간 회의 때 B-Type 명령어의 작동 구조에 대해 이야기를 나눴다.
B타입은 조건문의 계산과, PC값의 분기 주소 계산 두가지 연산을 한번에 처리해야한다.
비교문은 rs1 rs2 값을 각각 비교를 하니 ALU에서 두가지 src를 받아 처리하는 것이 타당해보이는 구조이다. 
그럼 이제 분기 주소 계산을 어디서 처리할 것이냐가 문제이다. Branch Logic인가, PCC인가, 아니면 별도의 계산 모듈을 만들 것인가.
Branch Logic에서 하기로 했다. 
참고로 PC = PC + {imm, 1b'0}인데, 1b'0은 imm_gen에서 처리한다.
그리고 상대주소지정 방식의 비트 정렬 알고리즘 정책에 따라
imm을 extension을 먼저 진행한 뒤 1b'0쉬프팅을 진행한다. 1b'0이 해당 정렬을 담당하는 로직이다.

따라서 Branch Logic에서는 PC+확장쉬프팅된 imm 값 연산을 진행하여 B-Target신호를 출력한다.
B_Target신호를 Branch Logic으로 이전했다. 사실 이건 PCC에서 진행하는게 맞아보이긴 하는데..
PC + ?? 형태의 것이면...

그렇게 하기로 했다. Branch Logic은 어디까지나 분기 조건 충족 판단의 유닛이지 PC주소 계산 유닛이 아니다
ALU에서 하기엔 리소스를 추가적으로 잡아먹으며 복잡도가 증가한다.
PC 전용 모듈을 만들기엔 추가적인 하드웨어를 낭비시키는 느낌이다.
NextPC신호를 계산하는 PCC에서 만드는 것이 설계 철학에도 부합하고, PC 연산을 전담하는 모듈에서 처리하면 파이프라이닝때도 수월할 것 같다. 
이러면.. PCC에 ex-imm신호가 추가되고, B_Target신호는 없어진다. 내부에서 조건부에 따라 계산되어 NextPC로 출력되기 때문.
그리고 ALUresult가 PCC로 출력하는 신호는 Jump시 PC 값 외엔 없는데,, 이걸 역할 통일을 하면 더 좋을까?

아니다. 추후 G 확장까지 다룰 때 J타입의 명령어가 추가되며 ALU에서 처리하는 기존 데이터패스 일관 방식이 더 좋을 수도 있다. 이건 그대로 남겨둔다. 

 - ! 할일 : CC84한테 PCC의 CLK신호 필요성 설명하기
 			BE_Logic에 address신호가 왜 있는거지? Load할 때, 즉 DM에서 RF갈 때 RF 대상지의 주소는 이미 명령어의 rd에 담아져 있고, 소스 주소는 rs1+imm인데>? 있을 이유가 없어보인다.
오늘은 여기까지. lb까지 데이터패스 검증을 마쳤다!!!! (23:57)

2025.02.01.
외박나와서 대부분의 시간을 밖에서 보냈다.
설날 인사 및 차례를 간소하게 지내고, CPU설계도를 함께 기도를 올렸다. 
꼭 해내어 보겠노라고. 우리나라의 반도체 대장이 되어보겠노라고. 지켜봐달라고.
작업으로 한 것이라고는 늦은 밤에 되돌아와 Memory Aligner, RV32I47F.R8에 대한 구현을 한 것이다. 
CC84의 건의로 되돌아보니, BE_Logic과 데이터메모리의 address값에는 무조건 미정렬된 주소가 들어갈 가능성을 내포하고 있다는 것을 발견. Jump의 Jalr도 마찬가지니까 이 주소 정렬 통합 로직 모듈을 설계하기로 했다.
그리고 어느정도 초안을 마치고, RV32I47F.R8_temp파일로 업로드했다.

2025.02.02.
외박 복귀. 그리고 WriteMask와 BE_Logic에 들어가는 Address 의 효용성을 알아냈다.
쓸 시간 없어서 압축하자면,
메모리의 블럭 단위 액세스가 address 11:2 비트 값을 기반으로 이루어진다는 것을 알아냈고,
정렬이 필요한게 아닌, word, halfword, byte단위로 쓰거나 읽을 일이 있기 때문에 정렬되지 않은 주소값 그대로 받되
명령어에 부합하지 않는 기준의 주솟값이 들어오면 별도의 예외를 발생시켜야한다는 것이었다.
그리고 WriteMask는 Bit Mask의 개념이었다. 고로, Mem_Aligner 모듈은 없어졌고, 기존의 신호체계를 그대로 사용한다.

2025.02.03.
2025.02.03.

BE_Logic에 대한 최종 회의
대부분의 시간은 Write Mask의 처리와 그에 대한 모듈-로직 이해에 시간을 할애했다.
추구하는 철학은, 메모리에서의 연산은 최소화하는 것. 그걸 위한 BE_Logic.
WriteMask에서 필요한 데이터는 대상데이터, 원본데이터, 마스크
마스크를 이용해 원본 데이터에 마스킹하여 DEADBEEF가 있으면 00ADBEEF로 만든다.

대상 데이터도 마스크를 이용해 CAFEBEBE가 있으면 CA000000로 만든다.
그리고 이에 대한 마스크는 FF000000과 연산이 이뤄지는데, 이걸 BE_Logic에서 DataMemory로
32비트 값 그대로 보내는 것은 하드웨어 설계 철학 중 하나인, 입출력 신호의 최소, 간소화에 어긋나기에 기술적 사실상 표준에 가까운 4비트로 인코딩하여 보내기로 했다.

그리고, 이 때 BE_Logic에서 보내는 BEDM_WD는 CACACACA로 간다.
사실상 WriteMask가 가기 때문에, &처리 하여 디코딩을 해야하니 그대로 CA000000값을
DM에서 생성하여 그걸로 데이터 저장처리를 한번에 하도록 설계하기로 했다.
CC84의 건의로 비공식 표준을 사용하지만 계산은 훨씬 줄어들었다.

2025.02.04.
당직이었는데, 일단 그래도 할 건 했다.
RV32I Essentials Cheat Sheet를 4시간에 걸쳐 만들었다.
명령어와 명령어의 Description, Mnemonics, 비트 체계를 한 페이지에 모두 담았다.
하도 제대로 된 자료 없거나 유료자료들 뿐이라 직접 만들었다. 다만 국방망에서 만든거라 파일을 어떻게 반출하냐가 문제..

그리고 CC84와 J_Align관련해서도 이야기를 좀 나눴다.
CC84의 발의.
프로그래머가 잘못 코딩하지 않는 이상 Jump시 Misalign은 일어나지 않을 것 같다.
KHWL.
아니다. 주소의 계산은 상수값과 참조되는 레지스터 값을 기반으로 이루어지기 때문에 가능성을 배제할 수 없다. 이는 매뉴얼에서도 언급된 내용이다.
CC84. 
관련된 내용을 그럼 한번 보자.
"will generate instruction-address-misalinged exception." 
exception이라는데, 이것을 J_Aligner에서 처리할 것이 아니라, 하드웨어 단순화를 위해 Trap_Handler에서 따로 처리하는 것이 어떠한가?
KHWL.
흠. 일리 있다. 하지만 성능의 차이또한 염두해두어야 한다.
Exception 발생 없이 자동으로 단순 로직 모듈을 거쳐 실행되는 편이 나을수도 있으니까. 
그래도 이렇게 J_Target의 ALUresult가 무조건 J_Aligner 모듈 로직 처리를 거치게 된다면, 조건 미발생에도 불필요한 연산으로 인한 딜레이가 생길 수 있으려나.
예외처리로 하는 것이 확실히 괜찮아보이긴 한다.

2025.02.05.
사실 Misalign이 발생했는지 안했는지 알기 위한 if문은 J_Aligner가 없더라도 어딘가에선 한번 즈음은 거쳐야할 로직이고, 그리고 이게 다른 곳에서 구현된다고 한들 큰 성능적 이점을 도모하긴 힘들어보인다.
차라리 Exception으로 별도의 처리 루틴을 불러오는 것이 추후 파이프라인 확장에도 타이밍 관련 발목을 잡을 수도 있어보이고, Misalign을 계속 모니터링 할 것이라면, 그리고 어차피 그 처리 자체는
하위 2비트를 날리는 정렬 로직이라면, 그냥 J_Aligner가 지금도, 향후에도 더 나을 것 같다는 생각. 
그래도 Trap Controller 및 Exception Detector같은 Exception 핸들링의 처리가 제대로 되는지 보기 위해서 지금은 Exception으로 구현을 해두자. 
이건 추후에라도 PCC에 별도 로직으로 자리잡는 편이 나아보인다. Exception은 너무 과한 리소스를 부여한다.
매뉴얼에서도 전문을 발췌하면, 
"The JAL and JALR instructions will generate an instruction-address-misaligned exception if the target address is not aligned to a four byte boundary."이다.
결국 Target address, 즉 J_Target신호가 PCC로 꽂힐 때 정렬이 되어있으면 Exception은 발생하지 않고, Exception 발생 전, 그 상황 발현시 Exception Detect이전에 정렬을 시켜버리면
exception generate는 필수가 아니게 된다. 
일단 지금 구현 자체는 모듈 구현으로는 없는걸로. ALUresult가 PCC의 J_Target으로 향할 때, 같이 Exception Detector로 신호를 넣어서 Misalign시 별도의 Trap_Handler를 수행하도록 한다. 
벌써부터 그 타이밍의 꼬임이 느껴지는데, 나중에 생각할 점을 지금 미리 생각한다 보면 나쁘지 않다. 
해당 다이어그램은 RV32I47F.R8v1으로 명명한다. 여태까지 R8로의 수정 시도가 여럿 있었지만, 논박으로 무산된 것들이 많다.
일단 지금까지 정식으로 채택된 R8은 v1이 붙은 다이어그램이다. 
(20:44)

하긴, 00으로 강제정렬시 의도되지 않은대로 프로그램이 흘러갈 수 있다. 이건 misconception이다. 
간단하거나 임베디드 시스템에서는 사용될 법 한 방법이지만, 범용 프로세서를 생각하는 입장에서는 타당하지 않다.
결국 Exception 처리인데, TrapHandler를 우리가 직접 구성하여 그렇게 작동하도록 해야한다.
어차피 범용을 목적할거, 해당 Exception시 처리는 디버그모드로 가거나 강종을 하게 하거나 어떻게든 처리하기로 했고, J_Aligner는 일단 없어졌다.
오늘 연등시간은 해당 Misalign address의 처리 표준 및 사례들, 그리고 구현 방식 및 타당성을 탐구하는데 다 썼다. 

2025.02.06. 
당직근무. 논문의 초안을 한번 잡아보았다. RV32I; Essentials Cheat Sheet v2 제작완료.
그리고 매뉴얼 문서를 정식작성해보았다.

2025.02.07
오늘 할 거 : Exception Detector에 B_Target(NextPC)의 주소 입력값을 추가하기. -> RV32I50F.R1 리비전하기.
Docs push하기
모듈 설명 Manual 마저 적기
명령어 데이터패스 검증

CC84 CSR 구현중 건의. CSRop로 그 동작이 결정될 것이라면 Read Write가 왜 신호가 각각 필요한가? 어차피 CSR 명령어는 해당 명령어 두개가 동시에 일어난다. 
맞네. 두개 삭제하고 CSRop로 두자.
그럼 CSRop도 사실 funct3값만 받고 수행하게 하면 되는거 아니냐?
ㄴㄴ 아니지. 동작하지 않는 Enable로서의 목적은 필요하니까. 데이터패스의 관리를 위해서 미작동 opcode가 필요하니 CSRop로 관리하는게 좋을 것 같다.
ㅇㅋ

수정할거. Exception Detector 코드에 맞게 해당 모듈 입력신호 변경
DC_Write 신호 메모리 컨트롤러로 옮기기.
(캐시 미스의 경우에만 캐시에 쓰기 작업이 진행되는데, 이 경우 본래 설계대로라면 캐시 미스라는 것을 Control Unit에서는 알 수 가 없음. 그러니까 이 신호는 멤컨에 들어가야함.)
Control Unit의 opcode 출력은 사실 의미가 없음. 그냥 Instruction Decoder에서 나오는 opcode신호 그대로 꽂으면 되는건데. 
그래서 그렇게 ALU controller의 신호를 수정함.

+ mem2reg 신호 이름 변경. reg_wd-src

2025.02.09.

Exception Detector의 development 브랜치의 approve된 ㅁ머지 코드대로 수정해야한다.
ECALL, EBREAK의 구분자가 imm필드(funct12)의 0번째 비트가 0이냐 1이냐에 따르는데, 그걸 구분하기 위한 것이라면
raw_imm값이 들어가도 될 것 같아서 그렇게 했다.

Branch Target값을 들어가게 해야하는데, 이는 PCC에서 계산되는 값이므로 NextPC의 값을 그대로 입력신호로 사용하기로 했다.
완료.

Misalign 예외는 Jump와 Branch때에서만 발생.
Jump는 Jump Target 주솟값인 ALUresult를 바로 꽂아서 판단하면 된다.
Branch는 B_Target 주소가 B_Taken시에 PCC에서 계산되어 NextPC로 출력되는데, 
그럴거면 NextPC값만 Exception Detector에 넣고, B_Taken의 신호가 안들어가도 되는게 아닌가?
꼭 Branch가 아니더라도, 이렇게 되면 PC에 들어가는 주소의 목적대로 4바이트 정렬이 이뤄지지 않았을 때의 Exception 발동을
할 수 있게 된다. 이러면 사실 J_Target은 NextPC보다 이전에 받는다는 레이턴시 이득 말고는 없어지는데,,
사실 이러면 NextPC만 받으면 될 것 같은데? CC84에게 건의해봐야겠다.

예아. 사실 이 Misalignd Address exception은 NextPC에서 PC에 가르키게 되는 주솟값이
오정렬된 값으로 되어 명령어 실행에 차질이 생기는 것을 위한 Exception이었다. 그래서 B_Taken, Jump라던가(Jump는 없긴했다 원래)
J_Target, B_Target을 따로 특정할 이유 따위 없이 그대로 NextPC값을 Exception Detector 모듈이 모니터링하여
상황발생시 처리할 수 있도록 하는 것이 최적이다. 이렇게 되면 그 두가지 이유가 아닌 모종의 다른 이유로 미정렬되었을 때도
예외처리를 할 수 있게 된다. CC84도 동의하여 그렇게 수정하기로 했다. 아이고 코드 수정해야할텐데.. 화이팅..
funct3는 그럼 뭐지 하다보니 CSR이랑 Environment 명령어들이 opcode를 공유하기에 f3가 000일 때만 environ이니 이걸 
구분하기 위해서 같이 받는다. 그냥 CSR명령어인데 Exception나면 안되니까.

오늘 할 것들.

1. Exception Detector 를 Github 코드에 맞게 입력신호 개정.
Done. (22:54)
2. DC_Write가 CU에 가있는데, 이걸 Memory Controller에 옮기기.
Done. (23:04)
3. 모듈 설명 Manual 작성

4. 각 명령어 데이터패스 검증

5. RF2DM_RD의 신호는 R[rs2]여야하는데, 지금 rs1값임. 수정해야함.
Done. (23:07)
6. FENCE 데이터패스 정립. e.g.) Write_Done 신호 오기 이전에
PC의 업데이트를 홀드해야하는데, 어떻게 구현할건지.

7. RV32I; Essentials Cheat Sheet 문서화. 
v3로 개정하며 12b'0을 12'b0으로 수정하기.
- 서식만 만들었음.

8. 논문 문서화.
매뉴얼은 거기다가도 적고, 그걸 토대로 IDE 파일도 작성하기.
모듈, 시그널, 모듈의의를 종합해서 하나의 엑셀파일(표)로 만들어도
괜찮을 것 같다.
- 서식만 만들었음.

9. 관련 작업 다 끝내고 Docs push하기. 

---저녁점호회의---
Control Unit의 구현 과정 중, 문제 발견. CSR.Addr.src, CSR.Data.src가 Control Unit에 있어야 하는가에 대해 CC84가 고찰을 했던 것 같다.
A. CSR.Addr.src의 의의는 아래와 같다.
일반적인 상황의 경우 CSR명령어 중 csr영역의 12비트 주소값인지, TrapHandler 수행시, 즉 Exception 상황에서의 Trap Controller가 지정해주는 CSR의 주소값인지를 구분하는 것.
때문에 이는 Control Unit에서 하는 것이 아니라, Exception Detector의 Trapped 신호를 MUX의 제어신호로 두어, Trap발생 상황으로 플래그 1이 올라가면, 그와 동시에 MUX의 값을 CSR_T.Addr로 전환하게 하면 된다.
따라서 CSR.Addr.src_Select신호는 Control Unit(CU)에서 없어지고, 대신 Exception Detector(ED)의 Trapped 신호를 받아 쓰는 것으로 변경되었다.

B. CSR.Data.src의 경우.

Done. (23:48)

2025.02.10.
자. CSR의 향연이다. 
우리의 목표는 현재 RV32I CPU를 만드는 것.
그리고 그 과정 중, RV32I의 모든 명령어가 의미있게 하기 위해서 캐시-메모리 구조를 접목하고, csr확장을 접목했다.
Zicsr확장은 ECALL, EBREAK와 같은 환경호출 명령어를 의미있게 하기 위한 확장이었고, 이를 통해 Debug Mode의 간이 구현을 하게 되었다.
Zifencei확장은 구버전 RISC-V 매뉴얼을 보던 중 fence.i 명령어가 RV32I Base Instruction Set에 포함된 줄 알고 착각한데서 비롯되었다.
그 결과, fence.i명령어를 위한 캐시 구조를 만들게 되었다.
fence와 fence.tso, pause (fence variation)명령어가 그 덕분인지는 명확하지 않지만, 이 명령어들의 작동 유무를 볼 수 있게 되었다.

다이어그램상 거의 모든 모듈들의 verilogHDL 구현이 각개 완성되어간다.
CC84가 그 최종장으로 Control Unit을 구현하는 중이고, 남은 것은 Control Unit이후 RV32I37F의 탑모듈 DUT 테스트벤치 이후
나머지 4가지 명령어 지원을 위한 추가 확장을 기반한 캐시 및 CSR 구현이다.

CC84가 이 CSR에 대한 연구를 요청했다. CSR을 정확히 어떻게 구현해야하는지. 일반 레지스터로 취급하기엔 하드웨어가 자동으로 업데이트해야하는 영역의 머신레벨 레지스터도 있는 것 같고,
그리고 그 CSR 레지스터들에 대한 목록과 그걸 지금 다 구현해야하는지에 대한 여부.

또한 캐시 구조 접목을 앞에 두고 이에 대한 로직의 심화 연구또한 이뤄져야한다. 현재 우리의 캐시 정책은 Write-Through방식인데, 
정확히는 Cache에 읽기 쓰기 버퍼가 있으며 FENCE 명령어일 때만 밀려있던 메모리들을 Flush하는 구조였다. 
하지만 그로서는 쓰기작업이 밀릴 때 같은 라인을 공유하는 캐시메모리의 데이터 손실이 일어날 수 있는 문제가 있어 컴퓨터 구조론에 따라
"*인용구*"
쓰기 작업을 다 할 때까지 잠시 작업을 멈춰야할 필요가 있다는 것을 다시 한번 알게 되었다. 
문제점의 결이 파이프라이닝과 비슷한데, 이에서부터 착안하여 컴퓨터 구조론을 인용해 그 해결방안으로 R-Type이나 다른 명령어들을 수행할 때.
즉, Data Cache-Memory쪽을 사용하지 않을 때 Flush 같은 작업을 같이 병행토록 하는 방안이 모색되었다. 물론 발상은 단순하지만 그 구현은 타이밍이라는 미뤄둔 큰 파도가 곧 덮쳐올 것이기에
개념적인 발상만 해둔 상태이다. 그리고 그에 맞는 Control 신호를 Write Done신호를 이용해 파생할 계획이다.
이와 같은 탐색은 CC84의 Control Unit 구현 중 Write Done신호의 필요성과 이 신호가 단순 FENCE 명령어 상황 외 사용 가능성이 있을 것인가에 대한 탐구를 기점으로 이루어졌다.
역시 개념적인 구현과 실제 구현에서 오는 괴리가 분명 존재하며 그 둘을 적절히 메꾸어가며 완성시키는 것 같다.

그 5년이라는 시간 후, 쇄신의 시간들을 경험하며 얻은 통찰이 교훈으로서 완성되어가는 것 또한 함께 느낀다.
분업이라는 것은, 그 업무의 영역이 명확할 때가 아니라, 그 서로가 맞물리는 지점이 명확했을 때 비로소 빛나는 것이다.
두 집합의 구분점이 아니라, 교집합의 명확성에 집중할 때 비로소 자유로이 한없이 생산적으로 나아갈 수 있다. 

무튼, 개인정비시간 17:30부터 밥을 먹고, 달려와서 CSR관련 연구를 진행해보았다.
한국어로는 거의 자료가 없음에 가깝다. 티스토리 글 하나와 우리의 reference 중 하나인 "FPGA를 이용한 32-Bit RISC-V 프로세서 설계 및 평가"라는 논문 뿐.
해당 논문에서도 csr을 이용하여 privileged isa를 부분적으로 필요에 맞춰 구현하였다.  
'M 모드에서의 트랩 처리를 위한 특권 명령어 집합 및 CSR을 구현'한 것. 

본론으로 돌아와서, CSR 자체는 하드웨어가 명령어 실행과는 무관하게 자동으로 처리를 해야하는 레지스터가 '존재'한다.
하지만 모든 레지스터를 한번에 구현할 필요는 없다. The RISC-V Instruction Set Manual: Volume II, Privileged Architecture를 인용하여,
Privilege Mode는 총 3가지 단계가 있다.
1단계/ M(Machine level). Simple Embedded System용.
2단계/ M, U(User level). Secure Embedded System용.
3단계/ M, S(Supervisor mode), u. Systems running Unix-like operating systems용.

결국, 3단계 구현을 위해서는 CSR 및 현재 프로세서의 구동 체계를 각 Privileged Hierarchy의 구조에 맞춰서 개선해야할 수 있다.
지금은 모든 CSR 레지스터를 구현할 필요는 없으며, 현재 우리가 원하는 스펙내에서 필요한 레지스터들을 구현하되 필요한 Machine Level 로직이 있으면
추가 구현해야하는 것이다. 

22:15 연등시간.
Privileged Architecture, ISA 매뉴얼을 읽으며 csr 이전 Introduction에서 거의 메인으로 강조되는 것이 secure.
동작단계의 보안이다. 머신 모드만 지원하는 기초적 설계에서는 잘못되거나 악의적인 applicatoin code에 대한 보안을 갖출 수 없다는 것이
csr에 대한 발단 중 하나인 것 같다. 
(optional PMP facility의 lock 기능이 M-mode만 구현되었더라도 부분적인 보안을 지원할 수 있다고 하는데,,
PMP가 뭔지 모르겠다..)

어차피 G확장까지 구현하기 위해서는 Privileged Architecture에 대한 제대로된 이해가 필요하다.
이렇게 된 거, 한국어로 RISC-V Privileged Architecture ISA Manual을 번역해보겠다. 172페이지가 뭐 대수라고.

지금부터의 내용은 Privileged_ISA.Korean.md 파일에서 계속된다.
CSR Listings에 레지스터 설명으로 낑겨 있는 설명에서 PMP에 대한 의미를 찾을 수 있었다.
Physical Memory Protection의 약자이다.

[Supervisor Trap Setup]
별도 표기가 없으면 분류의 앞 단어에 따른 privilege level에 따르며, RW; Read/Write; 읽기쓰기 레지스터이다.
중요한 것만 따로 Name 적는다.
sstatus
sie
stvec
scounteren
아니 다 필요하네. 기계적 업데이트가 필요한 것들만.. 아니 조졌다 그냥 이거 다 하나하나 순서대로 구현하는게 맞다.

일단 Hypervisor단계는 단순 OS만 올릴 지금 시점에서는 필요가 없으니 제외.
총 CSR들의 갯수를 세어보고, 그 중 RV32I50F에서 구현이 필요한 명려어들만 추산해보자.
총 CSR들의 갯수는 Manual 기준 Currently allocated RISC-V CSR addresses를 따른다.

fflages, frm, fcsr, cycle, time, instret, hpmcounter3 ~ hpmcounter31(29), h명령어 cycle부터해서 32개
총 64개 + 3(FP CSRs) = 67개의 Unprivileged CSRs.

sstatus, sie, stvec, scounteren, senvcfg, scountinhibit, sscratch, sepc, scause, stval, sip, scountovf, satp
scontext, sstateen0, sstateen1, sstateen2, sstateen3 
18개의 Supervisor CSRs

mvendorid, marchid, mimpid, mhartid, mconfigptr, mstatus, misa, medeleg, mideleg, mie, mtvec, mcounteren, 
mstatush, medelegh, mscratch, mepc, mcause, mtval, mip, mtinst, mtval2, menvcfg, menvcfgh, mseccfg, mseccfgh,
pmpcfg0,.. PMP?? 아!!! 복선 회수!! Physical Memory Protection이란다..
pmpcfg는15까지.. pmpaddr이 0부터 63까지. mstateen0부터 3, h값 포함.
그럼 총 25개 + 16개 + 64개 + 8개 = 113개
mnscratch, mnepc, mncause, mnstatus, mcycle, minstret, mhpmcounter3~31, h포함 ×2.
mcounthibit, phpmevent3~31, h포함. tselect, tdata1~3, mcontext, dcsr, dpc, dscratch0, 1.
4+62+59+5+4 = 134개..

하이퍼바이저..
7+5+2+1+1+2+8+9 = 35개..

총 367개의 Allocated CSRs.. 그 중 우리가 구현해야할 것들을 추산해보자..

- RISC-V Unprivileged CSRs (64) [URO]
cycle, time, instret, hpmcounter3~31, cycleh~hpmcounter31h. 총 64개

- Supervisor-level CSRs (18)
sstatus, sie, stvec, scounteren, 
senvcfg, scountinhibit, 
sscratch, sepc, scause, stval, sip, scountovf(SRO), 
satp, scontext, sstateen0, sstateen1, sstateen2, sstateen3

- Machine-level CSRs ( 163 out of 134)
mvendorid, marchid, mimpid, mhartid, mconfigptr (Machine Information Registers) 5개
mstatus, misa, medeleg, mideleg, mie, mtvec, mcounteren, mstatush, medelegh (Machine Trap Setup) 9개
mscratch, mcpc, mcause, mtval, mip, mtinst, mtval2 (Machine Trap Handling) 7개
menvcfg, menvcfgh, mseccfg, mseccfgh (Machine Configuration) 4개

pmp는 생각해보아야함.. 80개..

mstateen0~3, mstateen0h~3h (Machine State Enable Registers) 8개.

NMI가 뭐지..

Machine Counter/Timers (62)
Machine Counter Setup (59)
Debug/Trace Registers (shared with Debug Mode) (5)
Debug Mode Registers (4)

허허.. 그럼 총 245개.. 대략 400개중 245개 구현을 해야한다. 오늘은 여기까지.. 갈 길이 멀다.. 멀진 않고 높은 건가...
화이팅하자..
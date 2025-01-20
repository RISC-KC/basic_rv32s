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
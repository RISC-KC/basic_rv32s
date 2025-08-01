# [2024.12.08.]
PowerISA를 기반으로 기초적인 싱글사이클 사칙연산 CPU의 기본 형태를 구상, 설계.
EDA_Playground로 개발하던걸 goorm ide에 옮겨 프로젝트화.

해야할 것 : 신호이름 체계화, 탑모듈 테스트벤치.

# [2024.12.09.]
공부. ALU와 Control Unit의 코드를 재정비.
ALU에 있던 논리연산자를 CU에 적용하지 않았어서 그대로 만듦.
프로젝트의 로드라인을 정립함. PowerISA로서의 구현 가능성을 보았고, 성능 분기점까지 설계수준이 도달한다면 꽤나 의미 있는 연구활동이 될 것이라 판단.
RV32I의 기능을 수행하는 정도에서는 PowerISA와 RISC-V의 큰 성능적 차이를 보기 힘들 것이라는 생각.
RV32G정도라면 설계 목적 차제가 고성능인 PowerISA에 맞게 차이가 클 것.
일단 초심으로 돌아가 RV32I CPU를 개발하는 것에 초점을 둠.

# [2024.12.10.]
공부. PowerISA를 기반으로 작성한 코드들이고, RV32I로의 전환은 간단할 것으로 생각했으나 아니었다.
PowerISA와 RISC-V는 비트의 체계가 생각보다 달랐다. 모듈들 각 각 자체는 괜찮았지만 모두가 함께 움직여야하는 탑 모듈 단에서는 부족함이 많음을 발견.
각 모듈별 정립은 완료단계에 접어들었으니, draw.io를 활용해 기초적인 block diagram을 그리는 중.
choicube84의 ALU 뜯어 맛보기. RISC-V이식을 위해 RV32I 기능을 하도록 불필요한 연산들을 삭제하고 비트 체계 수정 및 tb로 확인함.

해야할 것  :
신호 이름 체계화, 각 모듈 RISC-V 이식. 부족한 기능들 추가 구현(e.g. PC를 증가시키는 로직이 CU에서 구현되어있어야 했는데 빠져있었다.)
블럭다이어그램 만들기

# [2024.12.14.]
ChoiCube84의 Program_Counter 제작. 

# [2024.12.15.]
강현우 드디어 back to back.
컨트롤유닛 ISA 비트체계 뜯어고치기 시작.(15:57)
R-Type의 opcode를 기반으로 ISA 이해. CU 구현 시작. (17:05)

CU에 R-Type, I-Type, B-Type 명령어의 aluOp 코드를 정의했다. (20:14)
CU의 동작을 검증하기 위한 테스트 벤치를 작성해야 한다.
일단 오늘은 여기까지. 다음 단계로 CU의 테스트 벤치를 완성하고, ALU에도 추가한 뒤, 각 명령어의 동작을 검증할 예정이다.

어... 구현하다보니 Control Unit부터 만드는 것이 꽤 난해하다는 것을 직감.
IDEC에서 배운대로 필요한 기초모듈을 구상하고, 명령어를 수행하기 위한 각 Datapath를 짚어가며 기본 모듈들의 데이터패스들을 만든 뒤에
Control Unit을 추가하여 그 모듈들을 제어할 컨트롤패스를 만드는 정공법으로 가려한다. 

# [2024.12.21.]
블럭다이어그램의 모듈 설계가 어느정도 끝났다. 신호들만 연결하면 CPU의 설계도는 완성이다. 
이 일련의 과정 자체가 이해를 많이 돕는다. choicube84는., 그대로 RV32I 모듈 구현 하면 될 듯하다...

# [2024.12.22.]
신호체계를 블럭 다이어그램에 담는 중, Immediate Generator랑 Branch Logic 유닛의 구현이 누락됐다는걸 발견.
아고., 더 추가되네 할게., 신호체계 80%는 된듯. Branch Logic 이해랑 구성 하면 진짜 거의 끝났다.

# [2024.12.23.]
당직 잘 섰다. 일단 ALUdec은 다이어그램에선 ALU Control Unit으로 되었고,.. 분기 구현이 살짝 어렵네. 이해가 살짝 안되는건가 표현하기 어려운건가..

# [2025.01.04.]
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


# [2025.01.05.]
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

# [2025.01.06.]
휴가 나왔다. 다이어그램 신호 체계 점검했다. 해야할게... 이제 
BE_Logic 완전히 이해하는 것과 CSR, Debug 기능 추가..
깃헙 push pull도 해야하는디 이건 어떻게 하지

# [2025.01.11.]
신호들의 최적화와 CSR의 구현이 완료되었다.
남은건 FENCE, ECALL, EBREAK, FENCE.i 명령어의 구현. 
현재 이 4개의 명령어를 제외하고 43 out of 47 Instr.s. 가 구현 및 연산 가능하여야 한다. 
BE_Logic도 마쳤으니 4번 항목도 완료.
그럼 이제 rst신호랑 clk 신호의 정립을 하면 4개의 명령어를 제외한 RV32I의 기본적인 형태가 완성된다. 구현과 검증의 시간.

# [2025.01.12.]
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

# [2025.01.17]
4일간의 혹한기 훈련을 마치고 여태 작업한 docs들을 push했다.
github을 처음 쓰면서 인터페이스가 아직 익숙치 않은데, docs브랜치의 변경사항을 저장하려다가 예전에 push안해둔 코드들이 겹치면서 조금 꼬였다.
ALU가 없어지는걸로 git에 기록이 남았는데, 뭐 아쉬운거죠. 나중에 CC84가 어차피 모듈을 추가할텐데 그 때 다시 돌아갈 예정.
오늘은 Core유닛과 메모리 유닛의 이원화를 통한 Top Module 수준 다이어그램을 그려야한다. FENCE 명령어 및 ECALL EBREAK 와 같은 명령어의 구현 때문.

# [2025.01.18]
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

# [2025.01.19]
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
## [2025.01.19 회의; 네이버챗]
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

# [2025.01.20]
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

# [2025.01.21.]
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

# [2025.01.22.]
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

# [2025.01.23.]
## ---회의록---
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
## - 변경사항
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

# [2025.01.24.]
어.. 어제 압도적인 방대함을 견뎌내며 개발하느라 일지를 최신화 못했다. 
사지방에서 마지막으로 만든 KHWL_RV32I47Fence 도면을 출력하고, 연등시간 끝나고 생활관에서 그 도면 뒤, 빈 페이지에 어제(25.01.23) 작업 내용을 수기로 적고 취침했다.
그리고 그에 대한 내용들을 정리하여 지금 최신화 했다. (20:36)
오늘은 많이 힘들다. 밀렸던 연구 조금 하고 연등 시간 70%를 기타공부하는데 썼다.
## 연구한 내용은 다음과 같다.
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

## ---긴급회의---
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
## Trap_Handler이 수행하는 역할은 다음과 같다.
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
 
## - [EBREAK의 처리 과정]

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



# [2025.01.26]
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
틈틈히 위에 있는 변경사항 반영하고 신호 최적화도 같이 했다. (23:54)

해야할 것 들.
Debug시 어느 모듈들에 영향을 끼치게 되는지.
이에 따라 각 모듈별로 디버깅시 제어 및 수정을 할 수 있도록 필요하게되는 신호들의 파악.

아. I_RD.DbgInstr_MUX의 신호는 Debug모드 진입시 ID의 I_RD값을 조정해야하므로 Trap_Control 모듈에서 제어하는 것으로 했다. 오늘은 여기까지.


------
# [2025.01.27]
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

## ---아래는 신호 배선 최적화 과정 중 진행된 것이다.---
CSR의 주소 연산이나 데이터 값 연산에 imm값이 포함되는 경우가 있나? 만약 있다면, 이 경우 imm의 값은 32비트 Sign-extended된 ex-imm값인가 아니면 명령어 타입별 비트체계 그대로의 imm값인가?
- 비트 체계 그대로의 imm 값이다. ex-imm은 ALU연산에서 주솟값 연산 혹은 I-Type 명령어 처리를 위해 쓰인다. 

CSR에 Write나 Read 신호는 필요 없나? Register File은 입력이 항시로 되어있어 읽기가 주로 되어있는 유닛이니 그렇다 쳐도, CSR File은 조금 다른 생각이 들었다.
특정 상황에서 쓰고 읽는 연관이 깊은 순간이 꽤 생기는데 (Exception, Trap이라던가) 이 경우 쓰기와 읽기의 명확한 제어 신호가 없으면 타이밍이 꼬이거나 의도치 않은 값을 읽거나 쓸 수 있을 것 같았다.
때문에 기존에 있던 CSRenable 신호를 분리했다. 
- CSRenable → CSR_Read, CSR_Write

RV32I47F 코어 디자인 적용도 마쳤다..
신호들과 모듈들을 정렬했다. 16:32..

이제 탑 모듈 다이어그램 수정해야한다.
교수님께 설날 인사도 드릴 겸 혹시 산업계나 이 쪽 분야에서 사용하는 블럭 다이어그램 툴이 따로 있는지 여쭤봤다.
별도로 없다고 하셨다. 마이크로소프트 비지오나 파워포인트에서 일일히 그린다고 하신다... 그럼 뭐.. draw.io에서 설계하던게 혹시나 손해보고 있는 걸 줄 알았는데 아니니 다행이다.
오히려 더 편한 툴이 없다는데에 절망을 해야하나...

## Top Module Design에서 각 모듈별 누락된 신호체계는 없는지 확인하다가 문득 생각난 질문.

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
## [문제 제기]
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

# [2025.01.29]
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

# [2025.01.30]
## Confliction.
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

# [2025.01.31]
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

# [2025.02.01.]
외박나와서 대부분의 시간을 밖에서 보냈다.
설날 인사 및 차례를 간소하게 지내고, CPU설계도를 함께 기도를 올렸다. 
꼭 해내어 보겠노라고. 우리나라의 반도체 대장이 되어보겠노라고. 지켜봐달라고.
작업으로 한 것이라고는 늦은 밤에 되돌아와 Memory Aligner, RV32I47F.R8에 대한 구현을 한 것이다. 
CC84의 건의로 되돌아보니, BE_Logic과 데이터메모리의 address값에는 무조건 미정렬된 주소가 들어갈 가능성을 내포하고 있다는 것을 발견. Jump의 Jalr도 마찬가지니까 이 주소 정렬 통합 로직 모듈을 설계하기로 했다.
그리고 어느정도 초안을 마치고, RV32I47F.R8_temp파일로 업로드했다.

# [2025.02.02.]
외박 복귀. 그리고 WriteMask와 BE_Logic에 들어가는 Address 의 효용성을 알아냈다.
쓸 시간 없어서 압축하자면,
메모리의 블럭 단위 액세스가 address 11:2 비트 값을 기반으로 이루어진다는 것을 알아냈고,
정렬이 필요한게 아닌, word, halfword, byte단위로 쓰거나 읽을 일이 있기 때문에 정렬되지 않은 주소값 그대로 받되
명령어에 부합하지 않는 기준의 주솟값이 들어오면 별도의 예외를 발생시켜야한다는 것이었다.
그리고 WriteMask는 Bit Mask의 개념이었다. 고로, Mem_Aligner 모듈은 없어졌고, 기존의 신호체계를 그대로 사용한다.

# [2025.02.03.]

## BE_Logic에 대한 최종 회의
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

# [2025.02.04.]
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

# [2025.02.05.]
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

# [2025.02.06.]
당직근무. 논문의 초안을 한번 잡아보았다. RV32I; Essentials Cheat Sheet v2 제작완료.
그리고 매뉴얼 문서를 정식작성해보았다.

# [2025.02.07]
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

# [2025.02.09.]

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

## ---저녁점호회의---
Control Unit의 구현 과정 중, 문제 발견. CSR.Addr.src, CSR.Data.src가 Control Unit에 있어야 하는가에 대해 CC84가 고찰을 했던 것 같다.
A. CSR.Addr.src의 의의는 아래와 같다.
일반적인 상황의 경우 CSR명령어 중 csr영역의 12비트 주소값인지, TrapHandler 수행시, 즉 Exception 상황에서의 Trap Controller가 지정해주는 CSR의 주소값인지를 구분하는 것.
때문에 이는 Control Unit에서 하는 것이 아니라, Exception Detector의 Trapped 신호를 MUX의 제어신호로 두어, Trap발생 상황으로 플래그 1이 올라가면, 그와 동시에 MUX의 값을 CSR_T.Addr로 전환하게 하면 된다.
따라서 CSR.Addr.src_Select신호는 Control Unit(CU)에서 없어지고, 대신 Exception Detector(ED)의 Trapped 신호를 받아 쓰는 것으로 변경되었다.

B. CSR.Data.src의 경우.

Done. (23:48)

# [2025.02.10.]
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

# [2025.02.11.]
오늘 할 거.
(Diagram)
1. PCC에 Write_Done 신호 추가하기 
(FENCE시 명령어 갱신을 중지하여야하는데, 이를 위해 필요한 신호.)
Done. 20:39. RV32I50F.R1v3_temp.draw.io

2. Simplified Core Diagram 만들기.
RV32I37? 기준인가... CSR제외, Cache구조 제외 다이어그램.
현재 RV32I50F 기준 간략화 다이어그램. 이렇게 총 두 개 만들어야한다.

3. CSR File에 구현할 CSR들을 정리하고, 그에 맞는 로직 모듈 및 CSR File 모듈 수정.

---연등시간---

4. Control Unit 동작 결과 검증

5. 추후 추가될 명령어 확장인 RV32G(IMAFD, Zicsr, Zifencei)에서 PC계산 및 점프하는 명령어가 RV32I Base Instruction Set 말고 더 있는지 확인.

5번을 하다가, 각 명령어별 수행자의 순서를 규정해둔 장을 발견하였다.
108페이지, Source and Destination Register Listings.

5번에 대한 것이 사실 4번을 검증하던 중, JAL의 데이터패스에 대한 생각이 문득 떠올라서 발의된 것이다.
JAL이 결국 PC = PC+{imm, 1'b0}인데, 이 PC + {imm, 1'b0}이 Branch에서도 동일하게 연산된다. 
이에 대한 연산은 Branch의 비교연산을 ALU에서 처리하며, 분기 명령어에 두 사이클을 소요하지 않고 한 사이클 안에 하기 위해 PCC에 PC + {imm, 1'b0}을 구현했었다.
때문에 JAL의 PC 연산을 그대로 ALU까지 가기 보다는 PCC의 로직을 재활용하여 최적화를 이룰 수 있지 않을까 싶었다. 
그러던 중 발생한 문제. 그럼 PCC에서 JAL인지 JALR인지를 식별하여 따로 작동할 수 있어야 하는데, (JALR의 경우 ALUresult = NextPC, JAL의 경우 PC + {imm,1'b0}) 
그걸 위해서는 Control Unit에서 PCC로 출력하는 Jump 신호를 2비트로 만들어 식별하게 만들어야 한다. 
그리하여, ALU를 통하지 않고 PCC에서 해당 로직을 재사용하는 것에 대한 효용성을 생각해보게 되었다. 
데이터패스를 비교해본 결과, MUX하나 차이인데, PCC의 덧셈기능을 구현하는데 성능 좋은 큰 크기의 가산기를 구현할 것도 아니고, (물론 추후에 성능 개선을 명분으로 진행할 수도 있다.)
ALU는 어차피 성능 좋은 가산기에 MUX 하나 차이로서 큰 성능의 개선을 도모하기도 힘들다 판단하여 기존 체제를 유지하기로 결정했다. 
여태 그랬던 대로, ALU에서 PC = PC + {imm, 1'b0}을 계산하여 J_Target으로 입력한다. 

Control Unit의 검증이 끝났다.
결과. 

A. csrrw, csrrwi에서. CSR = R[rs1]인 csrrw는 RD1값을 ALU에서 bypass해서 들어가야하는데, ALUsrcB가 왜 11로 CSR이 선택되어있는지.
csrrwi에서도 마찬가지로, CSR = imm인데, ALUsrcB가 imm이고 이게 bypass되어야하는데 왜 ALUsrcA가 11인지.

-> Bypass시 사용하지 않는 src는 00으로 선택하기로 한다. 사용하지 않는 MUX의 컨트롤신호가 0인 것과 같은 이치로 일관적 설계를 유지한다.

B. FENCE명령어.
FENCE명령어의 출력이 모든 Control Unit의 출력 신호를 0으로 하는 것으로 일괄 구현되어있는데, 이러면 안된다. 
FENCE란 그 의의가, 리소스의 레이스 및 순서위반을 방지하기 위해 어떤 이유서든지 간에 다른 명령어들의 수행을 잠시 정지하고(NextPC의 값 갱신 중단..인가? 같은 맥락의 명령어들은 수행되어야하는 것이 아닌가?)
수행중이던 명령어가 완료 될 때까지 대기하는 것이다. 즉, Memwrite작업이 일어나고 있을 경우, 해당 Memwrite작업의 제어 신호는 활성화 되어있어야 할 것이다.
또한 이 '수행중이던 명령어'의 포함 관계에 따라 FENCE의 종류가 다양해지는 것이다. 
FENCE는 그 기본 전제가 리소스의 레이스 및 순서위반. 즉 타 hart가 전제된다. 즉 predecessor의 수행과 successor의 수행이 정해지는 것. 그리고 그 수행의 종류는 Input, Output, Read, Write로 구분된다.
이건 아직 연구가 필요하긴 한데... 하 쉽지 않다.
무튼. FENCE의 기본형인 fence는  IORW를 모두 포함하는 명령어이다. 이 4가지 중 해당되는 작업 수행중이었을 경우 해당 수행중인 작업의 수행은 계속되어야한다.
인풋 신호 처리를 끝날 때 까지 한다던가, 쓰기 처리를 그렇게 한다던가.
FENCE.TSO는 Read와 Write에 한하여 수행한다. 참고로 fm비트필드는 해당 fence명령어의 의미를 뜻한다. fence 타입이니까 뭐 fence의 op코드같은 느낌이랄까. 
PAUSE는 predecessor의 Write에 한하여 수행한다. 
관련한건 해당 매뉴얼 참조. 더 연구해서 확실히 말할 수준으로 올려두겠다. (내일까지)
제안하는 개선 방향은 이 것이다. 
FENCE명령어 수행 시 그 직전 수행되었던 FENCE해당 수행의 명령어가 다 완료되었는지를 알아야하는데...
이건 복잡하네... CU를 0으로 했으면 물론 모든 수행의 명령어를 완료까지 기다리는 fence는 충족하지만 fence.tso와 pause의 구현이 부정확해진다.. 
이에 대한 방안을 생각해보아야한다...
여기까지.

# [2025.02.12.]
어제 연등 끝나고 01시 20분까지 화장실 회의를 하였다.
그 결과 FENCE의 처리에 대한 단서 및 아이디어를 얻을 수 있었고, FENCE의 처리는 지금과 같은 0 제어 신호로 구현하기로 하였다.
정확한 FENCE의 구현 기법은 버퍼를 이용한 Cache의 Write Done 신호를 통한 PCC의 명령어 업데이트 제어이다. 
버퍼는 실시간으로 해당 메모리의 접근이 없을 때 하드웨어단에서 계속 버퍼의 Flush를 통한 Buffer to Cache 쓰기를 한다. 
이 방법을, Simultanious Buffer Flush Model로 정의한다. SBF Model. 

Load 나 Store 관련해서 발생할 수 있는 문제에는 2가지 정도가 있음. 하나는 쓰기 명령어가 과도하게 많이 호출되어 버퍼가 꽉차는 경우, 하나는 동시성 프로그래밍을 이용하는 과정에서 유저가 race 컨디션을 만드는 경우.

첫 번째는 우리가 write_done 신호를 이용하여 해결해줄 수 있지만, 두 번째의 경우에서 모든 경우를 상정하여 하드웨어적으로 해결해줄 수는 없음. 
그래서 FENCE 명령어들을 프로그래머가 사용할 수 있게끔하여 그런 상황을 스스로 해결하게 하려는 것. 

무튼 버퍼 구조가 핵심이다.

오늘 해야할거
Simplified Core 다이어그램 제작
CSR 개선된 다이어그램 제작. = RV32I50F.R2

RV32I37F 제작 (No cache, no CSR, no Debug)
Done. 23:45.

RV32I43F 제작 (Yes CSR, No cache, no debug)

RV32I47F 제작 (Yes CSR, Yes Cache, no debug)

RV32I50F 제작 (Yes CSR, Cache, Debug)

# [2025.02.13.]
RV32I43F 제작 done. 20:50

RV32I47F 제작 done. 23:59

# [2025.02.14.]
일과시간에는 RVWMO에 대한 매뉴얼을 읽었다. 기존에 구어체를 기반으로 대부분의 문학적 책들만 읽던 것과 다르게 기술적 문헌을 그것도 수백 페이지에 달하는 분량을 읽기란 상당히 다른 경험을 선사해줬다.
무엇보다 어휘가 많이 부족했다. 문학은 문맥상 흐름을 유추하여 그 뜻을 추측할 수 있지만 정확한 뜻으로만 짜여져있는 이렇나 기술적 문헌은 그런 것으로 부족할 뿐더러 그래서는 아니된다.
내일, 토요일은 당직근무인데 오전 08시 30분부터 익일 오전 08시 30분까지 폰을 사용할 수 없는 풀타임 근무로 최근에 바뀌어서 그 안에 RISC-V의 매뉴얼을 싹 읽어보기로 했다. 
그리하여.. 약 651페이지에 달하는 문서를 프린트하였다.. 그리고 얼추 훑어보며 대강 공부 루트를 파악했다. 
현재 시간은 23:24. 지금부터는 사용할 CSR명령어들을 특정하며 현 RV32I50F의 CSR 구조를 검토한 뒤, VerilogHDL을 이용하여 CSR 모듈을 구현해볼 것이다.
그리고 매뉴얼을 읽다가 정말 정말 많은 사실을 알게 되었다. 여태 추측하며 머리가 띵해지는 경험을 많이 하였고, 물론 그로부터 얻게된 사고의 값진 산물들이 있었지만, 그에 대한 기본적인 가이드 매뉴얼 및 따라야할 표준이
'이미' 매뉴얼에서 다뤄져 있었다는 것. 우리가 구현한 캐시 구조는 상당히 원시적인 구조를 따르며, 현대의 고성능 컴퓨팅구조와는 사뭇 다른 구조를 가지고 있다. 
매뉴얼을 보면, RISC-V의 "Q" Extension까지 RISC-V "G" Extension을 구현하는 하나의 큰 흐름으로 목차가 이루어져 있음을 알 수 있는데, (G = IMAFD + Zicsr + Zifencei Extensions)
이에 따라 부동소수점 확장 전 까지의 목차 중 하나로 편성되어있는 캐시관리 ISA에 대한 이해가 우리의 코어 구조에 현대 컴퓨팅을 따르는 캐시 구조를 갖추기 위하여 필요할 것이다.
"CMO" Extensions for Base Cache Management Operation ISA, Version 1.0.0
그리고 아무래도, FENCE명령어의 의미론적 완전한 구현을 위해서는 다중 hart, 즉 멀티쓰레딩 환경이 있어야한다. predecessor와 successor가 전제되는 이상, 하이퍼쓰레딩이든 듀얼 코어 구조든 어떻게든 해야한다..
때문에, 아직은 안타깝게도. FENCE명령어의 구현은 NOP로 대체될 가능성이 높다. 실제 하드웨어적 가능한 수준에서 완전한 구현을 취지로 만들어볼테지만 그 결과는 실제 출력값에는 아무런 영향을 줄 수 없을 것이다. 
우리가 레퍼런스로 삼았던, *<FPGA를 이용한 32-bit RISC-V 5단계 파이프라인 프로세서 설계 및 구현>* 이라는 논문에서 싱글코어 프로세서로 설계함으로 인한 FENCE명령어의 NOP처리를 그대로 따르는 모양이 된다. 
결과론적으로는 아무런 진전이 없었지만 그 과정을 통해 잘못된 오해도 해보면서 캐시구조에 대한 자체적인 구조를 구상해보고, 관련한 메모리 구조에 대해 고찰해 볼 수 있는 좋은 기회였다. (SBF Model 등.) 

자. 매뉴얼 탐색의 시간이다. 기존에 어느정도 색인 작업을 마쳐두었던 터라, 꽤 빠른 진행이 될 것이다.
23:36. 시작. 

이런. Zicsr에서 행해지는 총 6가지의 명령어들은 Atomic 명령어다.
uimm은 명령어의 5비트 rs1값을 zero-extension한게 맞다. (46-47페이지)
CSRRSI, CSRRCI일 때, uimm필드의 값이 0으로 명령어가 주어지면 다음을 따라야한다.
1. CSR에 쓰여지지 않는다.
2. CSR write시 발생할 수 있는 부작용을 초래하지 않는다. 
3. 읽기 전용(RO) CSR에 대한 illegal-instruction-exception을 제기하지 않는다.

CSRRWI 명령어에서 rd=x0일 때.
1. 명령어는 CSR을 읽어서는 안된다.
2. CSR read시 발생할 수 있는 어떠한 부작용도 초래해서는 안된다. 

CSRRSI, CSRRCI는 언제나 CSR을 읽고 read의 부작용 중 아무거나 일으킬 수 있다. rd, rs1값에 무관하게.

RISC-V Unprivileged Architecture 매뉴얼의 Zicsr확장에 대한 대부분의 내용을 읽었다. 정독은 내일 하겠지만, 일단 CSR의 구현보다는 명령어의 지원에 대한 내용이 메인이다.
기본적으로 CSR은 읽기 쓰기가 동시에 이루어지는 명령어로 이루어져있는데, 그에 대한 psuedo 명령어, 즉 CSRW, CSRR같은 건 해당 쓰기나 읽기값을 0으로 처리하여
위에 명시한 uimm | rd가 0일 때 동작하는 로직에 따라 CSR의 정식명령어로 해독되어 수행된다. 

Privileged Manual도 인쇄하여야겠다. 오늘은 여기까지. 23:57.
항상 무언가의 연구중간에 끝날 때 마다 뭔가 시원한 기분이 안든다. 다이어그램이라도 확실히 만든다면 기분이 좋은데..

그리고 FENCE의 의미론적 완전 구현은 멀티스레딩 환경이 조성되어야하므로, 파이프라이닝 다음의 과정은 G의 확장 이후 듀얼코어 프로세서 구현일 것이다.
공유 캐시의 설계와, 두 hart간 타이밍 조율 및 로직들을 구현할 생각을 하니 벌써부터 머리가 어지럽다...

# [2025.02.15]
당직근무했고, The RISC-V Instruction Set Manual: Volume I; Unprivileged Architecture의 1장과 2장을 모두 정독했다. 
어휘가 꽤 많이 어려웠고, 기술문서 특성상 기존의 읽는 방식이 도전되어 꽤 많이 새로운 해석법을 얻을 수 있게 되었다.
서류 정리도 같이 하여 각 파트별 읽어야할 분량을 정리하고, 내용도 정리했다.
Unprilvileged에서 읽어야할 것은 약 123페이지. 그 중 37페이지를 읽은 것이다. 

# [2025.02.16]
당직을 다 서고 잤다가 일어났다. 약 16시경. 개발 환경을 구축하니 CC84가 ALU의 Vivado 합성 RTL Schematic을 보여주었다. 
꽤나 복잡해보이는 배선들과 이렇게 큰 무언가였나 싶을정도로 빽빽한 배선들이 보였다. 그래서 다른 VerilogHDL기반 스키매틱 툴이 없나 찾아보며 꽤 괜찮은 툴을 찾았다.
산업 표준의 RTL 스키매틱 방식은 아니지만, DigitalJS라고, 베릴로그 파일을 업로드하면 RTL레벨의 회로도를 보여주며 실시간으로 값을 입력하여 테스트를 할 수 있다.
아직 테스트 벤치를 돌릴 방법은 못 찾았지만 꽤 좋은 툴 같다. Vivado에서 Schematic 합성 레벨을 어떻게 했는지는 모르겠지만 얼추 그 대략적인 형태는 비슷하여 괜찮은 것 같았다. 
그렇게 DigitalJS에서 ALU의 테스트를 하던 도중, SUB명령어가 제대로 동작하지 않는 것을 발견하였다. 무슨 일인지, SUB일 때 MUX신호로 해당 SUB의 계산회로는 선택이 되지만 SUB의 출력이 xxxx로 표기가 되었다.
이에 관해 CC84에게 건의 했고, 외박에서 오늘 돌아오는데 시간나면 다시 봐보겠다고 했다. 
생각해보니 뺄셈 했을 때의 값이 음수일 경우 어떻게 처리할지 따로 코드에 명시가 안되어있어서 살짝 당황했지만, 애초에 ALU의 입력데이터는 32비트 "Sign-extended"라..
어 아니지. 맞네. 뺄셈의 결과값이 음수일 경우 2의 보수로 나타낸 Sign-Extended값이 나와야하는데 관련 로직이 없는 것 같다. 
음수와 음수를 계산할 경우 음수가 Sign된 값들의 계산이라 어차피 결과는 Sign되어 나오니 문제가 없는데,
양수와 음수, 양수와 양수의 결과값이 음수일 경우 ALUresult의 출력값의 로직을 검토할 필요가 있는 것 같다. 

다시 한번 상기하는 내가 해야할 것들 :
1. 구현할 CSR들의 확립
2. 1번을 기반한 CSR 모듈의 설계 검토 및 다이어그램 수정
3. 2번에서 만약 필요한 경우 다른 모듈들의 로직 수정.
4. 2번을 기반으로 CSR_File의 VerilogHDL 코드 작성. 

현재 시점 가장 큰 로드라인
RV32I37F의 Top-Module VerilogHDL 구축. Testbench로 검증. 
RV32I43F CSR
RV32I47F Cache
RV32I50F Debug

5단계 파이프라인 확장
G 확장
OS탑재, DOOM 실행.

필연적으로 확장 인터페이스에 대한 구현도 필요해질 것 같다. 

RISC-V의 OS 탑재에 대하여 Linux Kernel의 RISC-V 관련 문서를 보고 각종 프로젝트들이랑 내용들을 확인해보았다. 
또한 고성능 RISC-V 프로세서에 대해서도 찾아봤는데, 2022년에 중국에서 개발한 XiangShan NH 프로세서가 눈에 띄었다.
RISC-V 프로세서의 실제 설계 판매 업계 최선두주자인 Si-Five는 여러 경영적인 부분과 기술/가격적 부분의 한계가 명확하여 RISC-V의 가능성을 완전히 다루지는 못했지만
NH프로세서는 2코어 구조의 상당히 진보된 코어 구조를 가져 적어도 옛 x86 인텔 하스웰 수준의 성능은 가져오는 것으로 보인다. 
해당 논문에서 눈여겨볼 부분은, 전통적인 프로세서 설계/검증 방식에 얽히지 않고 효율적인 칩 생산 프로시져를 구축해내어 약 10개월만에 기반 프로세서를 테이프아웃 하였고 그걸 2세대로 성능개선(NH프로세서)해내었다는 것이다.
저자는 37명으로, 확실히 단 몇 명에서 이뤄낼 수 있는 성과물은 아닌 것 같다. 

결국 G 확장을 만드려는 목적은 OS의 탑재에서 비롯된 것인데,. 빠른 프로젝트 진행을 위하여 G 확장을 메인으로 보는 것이 아닌 OS의 탑재를 메인으로 보는 것이 좋을 것 같다.

---연등시간---
CSR 구현 목록의 확립.
## 현재 RV32I50F, OS없이 Bare Metal에 가까운 수준에서의 CSR 구현 목록

--Unprilvileged CSRs. --
- Counter / Timers
cycle (h)
time (h)
instret (h)
hpmcounter 3~31 (h)

--Machine-level CSRs.--
- Machine Information Registers
mvendorid
marchid
mhartid
- Machine Trap Setup
mstatus
misa
mie
mtvec
- Machine Trap Handling
mscratch
mepc
mcause
mtval
mip
- Machine Counter/Timers
mcycle (h)
minstret (h)
mhpmcounter3~31 (h)
mhpmevent3~31 (h)
mcountinhibit

# [2025.02.17]
전투휴무다..
14:36까지의 실적.
아 오늘은 특히 집중이 안되네.. 
일단 64비트 확장을 확정했다. CSR도 그렇고 64비트로 전향했을 때의 이점이 매우 강력하다.
(CSR의 구현이 쉬워진다. Linux의 탑재도 수월해진다. Memory Misalign Exception을 고려하지 않아도 된다.)
때문에 이를 RV32I 의 이후 RV64의 비트 확장 후 5단계 파이프라이닝을 하기로 했다.
그리고 최대한 프로젝트의 진행도를 올리기 위해서 "G"확장이 아닌, OS의 탑재에 초점을 맞춰서 
"5단계 파이프라인 RV64IMA_Zicsr_Zifencei + 가상메모리 프로세서"를 만드려고 한다.
그리고 그 마일스톤으로 RV32I 프로젝트에서는 총 4가지의 코어 구조가 나온다.
싱글사이클, Machine-Level 기준으로.
RV32I37F - 기본 RV32I 명령어 지원. FENCE를 비롯한 명령어들은 NOP처리가 되어있다.
RV32I43F - RV32I + CSR
RV32I47F - RV32I + CSR + Cache
RV32I50F - RV32I + CSR + Debug

## 현재 RV32I50F의 기준으로 CSR 파일들을 정의하려고 한다.
어제 정했었던 CSR들에서 mcycle과 같은 RV32기반에서 h로 [63:32], [31:0] 로직 분할 구현 및 매핑을 해야하는 것은 64bit확장에서 필요 없어지므로 이와 관련된 레지스터파일들은 모두 0처리할 것이다.
때문에 RV32I50F의 재정립된 CSR 파일들 목록은 다음과 같다. 
카운터 및 사이클 / 명령어 카운터는 64비트 확장시 추가 구현할 것이다. 

--Machine-level CSRs.--
- Machine Information Registers
mvendorid
marchid
mhartid
mimpid
- Machine Trap Setup
mstatus
misa
mie
mtvec
- Machine Trap Handling
mscratch
mepc
mcause
mtval
mip

위 13가지 CSR File을 위한 로직을 설계하고, CSR File을 구현하자. 

CSR은 거대한 문이었구나.. 각 레지스터별로 Interrupt나 Trap들, Status를 나타낼 수 있는 필드가 지정되어있는데,
이 말인 즉슨 각 필드가 의미하는 값들을 적을 수 있게끔 조건문 별개 구현을 해야한다는 것이다. 
또한, 두 개 이상의 CSR들이 상호작용하여 동작을 수행하는 경우가 있어 이 또한 함께 구현해야한다. 
현재 레지스터의 이해와 로직의 구상을 완료한것들 : Machine Information Registers, Machine Trap Setup.

# [2025.02.18.]
구현할 13개의 CSR에 대한 내용 조사 및 연구.

# [2025.02.19.]
23:42. CSR의 구현 방안에 대해 연구하던 중에 RV32I37F의 테스트벤치 소식이 들려와 바로 다가갔다.
뭔가 실패한듯 보여 툴의 문제로 생각하고 웨이브폼 파일을 둘러보던 찰나. 23:42분 즈음 뭔 바람인지 그냥 ChoiCube84한테 갔더니 뭔가 열심히 치고 있었다.
그렇게 웨이브폼이 뜨고, 우리는 확신의 성공을 목격했다.
RV32I37F. 완성. 
그 시작의 명령어는 간단헀다. x0에 10 더한 값을 A로, x0에 20 더한 값을 B로. A+B를 C로. 완전한 성공. 모든게 제대로 작동했다.
지금부터다. 이제부터 시작이다. 37가지의 명령어를 각각 시험하기 위한 테스트 벤치를 만들어야한다.
기존에 UC Berkeley 대학에서 있는 EECS fa22의 skeleton benchmark 코드를 사용하려고 하였으나, 코어 디자인이 상이한 관계로 해당 벤치마크를 인용한 별도의 테스트벤치를 만들기로 했다. 
갈매기는 멈추지 않는다. 하나의 성공은 또 하나의 위대한 시작이다. 계속해 나아가자.

# [2025.02.20.]
CSR의 확립이 끝났다. xlsx파일로 정리된 내용은 RV32I50F_CSR_Listings에서 확인할 수 있다. 
구현되는 최종 리스트는 다음과 같다.

아 진짜.. mtvec writable하게 하냐 Read Only로 하냐를 30분동안 날림. 제발.
Machine 수준의 CSR 동작이라 일개 User가 컨트롤하는게 말이 안될 뿐더러 그걸 구현한다고 해도 어떠한 이점 조차 생각할 수 없고
만약 BASE주소를 바뀌는 명령어가 일어난다고 한들 그건 Vectored 모드를 구현할 것이라 그런 큰 bit의 소요는 필요 없어진다고 설명했음.
이 두가지 내용을 갖고 30분이나 같은 맒만 함.
내가 말하는 방식이 못난건가? 왜 화가 나지.
굳이 이런걸로 화 낼게 아닐텐데.. 아직 덜 성장했나보다. mscratch의 로직 구상만 남겨둔 상황에서 이렇게 끝맺음을 못내고 시간을 마쳐야 하는 것이 통한스럽다.
무튼 오늘은 여기까지. 웬만한 내용은 셀에 나와있다. 참조하시길.

# [2025.02.22.]
02.21에 당직서면서 CSR의 초깃값들을 모두 정의하고 캐시 메모리 구조와 CSR의 로직 구조를 모두 RV32I50F Core Architecture Manual 문서에 기록하였다. 
그리고 CSR파일의 구현이 시작되었다. 프로젝트에서 지금까지 나는 로직들과 다이어그램 및 동작의 설계를 전담하였고, Verilog를 이용한 구현은 ChoiCube84가 도맡았었다. 
하지만 이 학습적인 프로젝트에서 Verilog를 거치지 않고 그대로 가는 것은 목적에 부합하지 않는다 생각하였기에 CSR파일만큼은 내가 처음부터 구현하겠다고 했다.
물론 CSR 자체의 로직들 공부하고 고찰할게 꽤 있어서 CC84도 따로 회의를 요청했을 것 같긴 하지만.. 이번 구현이 끝나면 곧장 RV32I43F의 TB를 만들어 검증하면 된다.
현재 CC84는 RV32I37F의 웨이브폼 생성 및 테스트벤치의 환경 구성(각 명령어에 따른 모듈별 의도된 출력 신호들 정의)을 하고 있다. 
우리의 목표는 2월달까지 RV32I50F 코어의 구현 및 검증을 1차적으로 끝마치는 것.
그 이후엔 64비트 확장과 5단계 파이프라이닝, IMA 확장, OS 탑재가 있다.
3월~4월 중순. 64비트 확장 및 5단계 파이프라인
4월 중순~ 5월 중순. IMA 확장
5월 중순~7월 RISC-V Linux 탑재를 위한 Kernel 프로그래밍
7월~ 논문작성(CC84 전역...), 8월 중순 Arxiv 투고.
8월 이후 KAIST 자기소개서 작성
9월 입시...

후.. 할 수 있다. 잘 해보자.

# [2025.02.23.]
오늘은 CSR의 로직을 실질적으로 구현하였다.
거의 반나절동안 한 것들이 삽질이 되었는데 그 과정 중 Verilog 문법에 대해 배운 것이 감흥이 더 커서 딱히 상심은 없었다. 
CSR에서 CSR의 산술 논리 연산(Set, Clear)가 같이 이뤄질 줄 알고 구현하고 있었다. 
하지만 이렇게 되게 된다면 CSR_File은 더 이상 CSR_File이 아니라 CSR_Unit에 가까워진다고 생각해서 이 연산을 ALU에 넘겨야하나를 고민했다.
CC84한테 말했더니 놀라며 내게 와서 설명을 요구했다. 그렇게 설명하며, 가만히 다이어그램을 들여다보니 컨디션이 좋았던 과거의 내가 이미 ALU를 통해 CSR 연산을 수행하여
CSR_File은 말 그대로 데이터만 저장하고 반환하는 단순 File에 맞게 설계가 되어있음을 확인했다.
그렇게 원래 구현할 CSR마다 별도의 모듈화를 시켜 파생시키는 구현을 하고 있었는데 모두 리타이어 시키고, CSR_File이라는 단독 모듈에 주솟값과 CSRop, 클럭에 따른
단순 읽기 쓰기 동작으로 정리되었다. 그러면서 CSR이 CSR명령어 뿐만 아니라 TRAP시 값이 필요한 경우를 CC84가 지적했고, 난 다시 다이어그램을 보았다.
생각해보니 TC에서 그냥 T.Addr로 어드레스를 요청해서 CSRFile이 그걸 받아 단순히 RD로 내보내기만 하면 되는 것이었다.
그럼 결국 csr_op가 0이면 CSR의 전체 미동작을 이야기하니 0이 아니면 안되지 않냐라고 하였고,
난 어차피 읽기 자체는 비동기로 always * 때려버리고 중요한 명령어 구현은 어차피 쓰기가 함께 일어나는 작업이니 CSR_NONE과는 상관 없이 읽기 자체는
일반 레지스터 파일처럼 항시로 값을 반환하면 된다고 설명했다. 그리고 이렇게 되면 출력되는 RD들도 결국 CU가 선택하지 않는 한 동작에 문제는 없을 거라고 했다.
CC84가 생각하더니, 그럼 CSR_Write 신호로만 쓰면 될 것 같다고 했다. 그렇게 3비트나 먹던 CSRop 신호가 퇴역하고, CSR_Write 1비트 신호로 대체되며 최적화되었다.
CSR파일을 그렇게 15분만에 만들어내고,, (연구시간이 구현시간보다 긴건 언제나 그랬던...) 이제 내일은 tb를 만들어서 검증하면 된다.
내일 월요일은 금요일 당직에 대한 보상으로 전투휴무인데 CC84는 일반 일과라 조금 불편하긴 할테지만 잘 해보자.
아자아자!!!

# [2025.02.24]
CSRFile 구현 완료.
금요일 당직근무에 대한 전투휴무를 써서 거의 한 나절동안 Verilog만 만졌다.
복습하며 문법이나 이것저것 많이 익혔고, 조금 번거롭긴하지만 사지방 컴퓨터의 제한을 어느정도 푸는 방법을 마련했다.
안전모드에서 드라이버 깔고 하는거.. 이러면 GTKwave도 돌릴 수 있다. 하하.
무튼 CSR 구현하면서 검증이 문제였는데, TB를 짰는데 TB에서 원래의 값과 쓰기 이후의 값이 따로 다른 값으로 나와야하는데
원래의 값, 즉 RESET 직후의 값이 설계된 0이 아니라 직전에 썼던 출력신호의 값이 그대로 들어갔다.
그래서 딜레이를 넣고 삽질을 하다가 맞게 이루어져서 그걸 최종안으로 만들었다.
그렇게 저녁 식사를 하고, 내가 짠 CSR의 verilog 파일을 CC84의 기존 verilog 설계에 맞게 서식을 조정했다.
남는 시간은 당직PC에서 작성한 RV32I50F Core Architecture Manual을 손수 재작성하며 내용을 수정했다.
그 이후 찾아온 연등시간.
마저 CSR 파일의 서식을 조정하고 다 끝나가던 중, CC84가 탑모듈 벤치에서 치명적인 문제를 발견했다.
탑모듈 벤치의 진가가 나오기 시작한 것!
문제는, ALUop에는 명령어 타입 식별자가 없기 때문에 I타입 SRAI와 R타입 SRA를 구분할 방법이 없단 것이다.
I타입 명령어의 imm필드가 shift 명령어에 한정하여 funct7 값과 shamt값으로 구분을 해 두었는데 이걸
슬라이싱 하는 것이 관건이다. 
만약 그냥 인풋 소스의 데이터를 슬라이싱해버리면 R타입 SRA인지 I타입 SRAI인지 ALU는 모르므로
SRA라는 ALUop의 코드를 따라 RD2의 값에서 f7과 shamt를 슬라이싱 해버릴 수도 있게 된다.
ALUop에 명령어 타입의 정보를 포함해야한다는 기존 설계의 의의가 기억나서 회의록을 찾아보니 관련 내용이 있었다. 
## 2025.01.23. 회의록.
ALUop신호의 역할은 무엇인가? ALU의 enable 및 Bypass 신호에 불과한가?
-ALUop신호는 opcode에 따른 명령어의 타입을 받아 타입별 연산을 하기 위한 식별 코드이다.
애초에 ALUop에서 Type을 내포하도록 하는게 원래 목적이었는데..
아무래도 개발 중 그것보다도 ALU의 연산 종류 자체를 규정하는 것이 더 중요했기에 그렇게 노선을 튼 것으로 보인다. 
난 그래서 ALUop에 명령어 타입을 추가하거나.. 아니면 타입 신호를 ALU에게 알리는 용도로 별도의 신호를 주자
하는 느낌이었는데 CC84는 다른 생각을 하고 있다.
imm값의 [4:0]을 슬라이싱해서 ALUsrcB에 넣자는 것. 이렇게 하면 shamt -> imm[24:20] -> SRA 연산자. imm[24:20]만큼 shift한다
근데 여기서 생기는 고찰.. 그렇게 해서 되는 건 맞지만, 추후에 I타입이고 뭐고 명령어 늘어날텐데..
타입을 추가하는 판단이 향후 범용성을 생각해서라도 맞는 판단이 아닐지.. 이건 너무 본 SRA문제에 한정한 솔루션 같다는 느낌이다..
범용적인 솔루션의 의미도 포함되는 의미에선 차라리 타입 식별 신호를 넣는게 좋지 않을까 하는 생각.
연등시간 종료다. 이건 따로 회의해야겠다. 오늘은 여기까지.

# [2025.02.25.]
평일 외출... 어제의 건은 결국 imm을 따로 빼어 ALUsrcB에 4:1 MUX로 선택지를 하나 더 넣는 것으로 결정되었다. 
타입을 굳이 식별한다고 해서 추후 명령어 확장을 생각한다 하여도 지금 설계를 바꿈으로서 생기는 이렇다 할 적합한 신호의 효용성은 찾지 못했기 때문이다. 
연등에 와서, 본격적인 메모리-캐시 동작 로직 구조를 체계화 해서 문서로 작성하며 구체화 하려 했는데, MUX의 비트 관련 Conflict가 CC84와 생겼다.
나는 설계에 있어 최대한 보수적인 입장으로, 선택되지 않는 경우에는 비활성화 신호를 보내야한다고 생각한다. 설계된 하드웨어의 복잡성은 갈 수록 늘어나는데, 모든 동작을 완전히 보장하는 것은 지금 규모에서는 힘들겠지만
그래도 가능한 선에서 최대한 보장할 수 있도록 하는 것이 좋다고 생각하기 때문이다. 때문에 모든 MUX에 있어서 초창기 RV32I43O 기준만 하여도 MUX 선택 신호 비트에 00을 포함했었지만, 47F로 넘어오며 아예 00신호를 쓰지 않고
01신호부터 쓰도록 했었다. 00신호는 비활성화로, 아무런 값도 MUX에서 선택되지 않으며 어떠한 값도 출력되지 않음을 명시적으로 표현하기 위함이었다. 이러면 디버깅이나 신호처리에서도 확실하게 볼 수 있을테니까.
하지만 CC84의 설계철학은 달랐다. 최대한의 최적화와 단순화. 회로를 최대한 단순화하고, 어차피 안 쓰는 모듈엔 0이나 다른 기본값을 흘려도 문제없다면 셀렉트를 1비트(또는 꼭 필요한 최소 비트)로만 두고,
"비활성화"같은 신호는 없애도 동작엔 무관하니 '최적화'라는 이름하에 그렇게 하고 싶다고 한다. 
정말 그냥 둘의 설계 철학 차이로 생기는 Confliction이었다. 불필요한 신호의 흘림으로 인한 불필요한 동작들의 결과를 보여주었음에도 뭐가 문제인지 모르겠다고 하였다. 그 마저도 일단 결국 수행 결과에 영향을 끼치지 못하니까
문제가 되어 보이지 않는다는 감안의 답변인 것 같았다. (RV32I50F.R2_B-Type 참조) 
오랜 고민 끝에, 어차피 향후 문제가 될 수 있는 가능성을 염두하여 비활성화 신호를 둔 것이었으니, 나중에 문제가 생기면 그 때 가서 비활성화 신호를 넣는 방식으로 하자고 했다.
CC84는 그냥 3비트로 말한대로 일단 진행 했으니 나중에 최적화 세션을 가질 때 다시 보자고 했다. 하..
이렇게 연등시간동안 아무것도 못했다 또 5분 남짓 남았다.. 통한스럽다. 원래 2월 안에 RV32I50F 까지의 설계 및 검증을 마치고 64비트 확장으로 3월에 넘어가려고 했는데 더더욱 멀어지는 것 같다.
그래도 하는데 까지 해봐야하지 않겠는가. 

# [2025.02.26.]
무려 딥 리서치의 등장. 바로 논문 써줘 on. 정리만 해둔 최소한의 정보, 우리 프로세서에 대한 모든 정보를 주지 않았음에도 정말 가공할만한 결과물이 나왔다.
오늘은 취사지원이라 오전 내내 피로 회복을 CC84와 같이 하였고, 오후에는 캐시 구조에 대한 공부를 하였다.
드디어 Tag, Index, Offset이 운용되는 방식을 이해하여 여러 캐시 사상방식을 익혔다. 당연하게도 Set-Associatve 방식을 채용할 것이다.
어느정도 베이스가 탄탄히 다져져 있고, 개발한 기반 프로세서가 있고 여력이 된다면 또 다른 여러 캐시 사상 방식이나 저장 로직들을 고민해보고 싶지만 그럴 여유는 지금 없다. 
캐시의 데이터 배열 구성은 Set과 Way로 이루어져있다. 각 Set의 집합인 Way가 있고, 그 Way의 열이 많아질수록 크기가 커진다. 캐시의 구성요소인 Tag는 데이터와 함께 저장되어있다. 먼저 Index를 통해 어떤 Set에 있는 데이터인지 파악한다.
그리고 Tag를 통해 어느 Way에 있는 데이터인지 파악한다. 그리고 그 Way의 Tag된 데이터. 즉 Cache의 데이터는 하나의 메모리의 데이터만 저장하고 있는 것이 아니라 설계에 따라 여러 데이터를 저장하고 있다.
그 여러 데이터들 중 현재 필요한 메모리의 데이터를 찾기 위해서 Offset을 이용한다. 이게 캐시의 기본적인 작동 방식이다. (Set Associative)
캐시 갱신 로직은 LRU를 탑재할 예정이고, 이와 관련된 로직의 실질적인 구현을 알아보아야한다. 
오늘은 여기까지. 

# [2025.02.27.]
당직 근무. RISC-KC Processer Design Manual 작성. 향후 로드라인들과 현재 개발 상황들, 그리고 서식을 체계화했다. 차후 딥 리서치를 돌리기 위한 발판.

# [2025.02.28.]
벌써 2월의 마지막날. 원래같았으면 RV32I50F까지 검증을 마치는 마감기한이었지만, RV32I37F가 고작일 것 같다. 사실 이렇게 해도, 원래 로드라인의 기간에 얼추 맞긴해서 큰 문제는 없지만
그래도 아쉬운 것은 사실이다. 원래대로였으면 매뉴얼을 최대한 달리려했지만 오늘은 같이 검증을 마쳐 RV32I37F의 검증을 끝내기로 했다.
이렇게 되다간 3월 되서도 전역할 때 되서도 RV32I50F 검증하고 있을 것 같은 느낌이 들었기 때문이다. 
함께 검증을 하며 연등시간이 끝나는 참에, 나는 BE_Logic을 검증하며 데이터메모리의 Read에서 뭔가가 이상함을 발견했었다. CC84는 같은 시각에 Data Memory를 검증하고 있었는데, 
서로 LW라는 작업에서 다음 클럭사이클에 Data Memmory의 Read된 데이터가 출력되는 것을 확인하였다. 조사를 거쳐본 결과, Read Enable신호를 지닌 동기식 Data Memory는 읽기 신호를 보낸 다음 사이클에 데이터를 출력한다고 한다.
그게 일어나는 원리는 우리의 로직구조에선 조금 달랐던 것 같다. 현재 RV32I37F의 테스트벤치에서는 Store (S-Type) 명령어 3가지를 거친 이후 바로 6가지 I-Type의 Load 명령어를 수행하게끔 설계되어있는데,
즉 Memory_Write 신호의 Falling Edge와 동시에 Memory_Read 신호의 Rising Edge가 겹치고 그 안에 Clock의 Rising Edge가 솟아 모종의 상태가 발생하여 그 어떠한 활성화 신호도 받지 않은 case의 default 구문이 수행된 것이다.
이게 그 정황이고, default값을 CC84가 DEADBEEF로 수정해보면서 그게 맞음을 검증했다. 이러면 메모리의 Read신호를 두 사이클을 배치하는 방법을 고안하던가, 한 사이클 안에 어떻게 되도록 하는 방법을 고안해야한다. 
오늘은 여기까지.

# [2025.03.01.]
오늘은 주말 외출 나가서 삶의 활력을 찾고 왔다.
강철의 연금술사 전시전을 CC84와 같이 봤고, 블리치 전시전도 보았다. 거기에 세상에서 가장 맛있는 카레까지 먹었다. 피로했지만 행복감은 충만해졌다.
오늘 돌아와서 한건 모듈들의 신호 검증.
25.03.01 Verified Module List
ALU
ALUcon
Branch Logic
Control Unit
Instruction Decoder
Instruction Memory
PC Controller
PC + 4
Program Counter

Queued Module verification list
BE_Logic
Data_Memory
Immediate_generator
Register File

신호들 raw_imm 값이랑 imm값 분리 작업을 이번 기회에 해두지 않으면 안될 것 같아서 하자고 했다.
사실 Data_Memory에서 동기식 구조의 한계로 추정되는 읽기 신호시 즉시 기댓값 출력이 아니라 다음 사이클에서 값 출력이 나오는 것에 대해 어떻게 처리를 할지 아직 해결되지 않았다.
그래도 확실히 새로운 문제들이 생기고 각각 해결해나가는 모습을 체감하니 나아가는 감은 든다. 다행이다. 
계속 잘해보자. 항상 감사한다 CC84.
+DM의 사이클 문제를 Memory_Read 즉, Read의 활성화 신호를 없애는 것으로 해결방향을 설정했다. 
Read 활성화 신호를 없애고 클럭에만 맞게 항시 읽는 로직으로 전환될 예정. 허나 이렇게 Read Enable을 없앴을 때 생기는 문제점이 생길 수 있기 때문에 관련해서 찾아보고 적용하기로 했다.
일단은 이렇게 하여 한 사이클에 바로 데이터 출력을 할 수 있도록 하고, 이로인해 생기는 리소스의 손해는 추후 최적화 과정에서 개선을 도모하기로 했다. 

# [2025.03.02.]
금일 취사지원 과업에 더불어 오전은 피로를 처리하기 위해 휴식을 취했다. 
그리고 이어진 검증.
Data Memory도 결국 그 사이클 문제 구간 외 검증을 해도 되는 부분이라 해당 Load 부분을 제외하고 검증을 시작했다.
BE_Logic, Data Memory를 검증하면서 알게 된 것이, 일단 LW만 무시되고 다른 LH, LB같은 명령어는 모두 정상 작동한다는 것이다. 
그렇게 두 모듈의 LW 명령어를 제외한 검증을 모두 마쳤고, Immediate_generator와 Register File만이 남게 되었다. 
Immediate_Generator는 현재 raw_imm 신호체계 수정작업 중이라 검증을 하여도 또 다시 재 검증하며 값이 변화할 가능성이 크기에 그대로 Queue된 상태이다. 
Register File은 Data Memory의 완전성이 검증되어야 의미가 있어지기에 마찬가지로 Queue된 상태이다. 

Read Enable신호를 없애는 방향에 대해 조사를 했고, 대부분 구현을 검증하는 FPGA를 비롯해서 일반적인 시스템에서도 SDRAM, 즉 동기식 메모리를 사용하며 이 표준에도 Read Enable신호를 사용하기에
안정성과 표준이 내포하는 의미를 함께하여 Read Enable신호를 그대로 쓰기로 하였다. 이제 문제는 그걸 어떻게 하냐는 것.
명령어 실행 과정 5단계, FETCH, DECODE, EXECUTION, MEMORY, Write Back. 여기서 제대로된 출력이 되기 전까지는 현재 PC값이 유지되며 FETCH와 DECODE단계를 하지 않아야한다. 
Data Memory에서 Read시에 Memory[address]가 나올 때 동시에 Read Done신호를 1로 바꾸는 걸로 하고, 만약 그게 아닌 경우엔 0으로 하는 걸로 하면 FSM이 Read가 제대로 이뤄졌는지 아닌지를 알 수 있게된다.
기존에 고안했던 Write Done신호와 비슷하게 입각하여 PC Controller에 Read Done신호를 입력으로 하고, Read Done 신호가 0일 때 NextPC=PC로 해두면 될 것 같은 느낌이..
근데 이렇게 되면 메모리 접근이 일어나지 않을 경우 Read Done 자체는 모두 1로 처리해야하는가... 이 것도 CC84와 논의가 필요할 것 같다. 

일단 CC84가 raw_imm 수정 작업과 오타 수정작업을 마치고 rv32i37f의 tb 2번째 버전을 주었다.
이걸 기반으로 신호들을 다시 추가 검증하고 관련 문제에 대해 생각하고 5단계 파이프라이닝에 대해 설계를 하고 있어야겠다. 

RV32I37F Top-Module testbench;
Module Verification Listings.

=25.03.01=
ALU
ALUcon
Branch Logic
Control Unit
Instruction Decoder
Instruction Memory
PC Controller
PC + 4
Program Counter

=25.03.02 =
Data Memory (Except LW.)
BE_Logic (Except LW.)

[Queued]
Immediate_generator
Register File

CC84와 Data Memory의 Read 관련 토의를 해보았다. Read Done 신호를 채용하는 것이 최선 같은데, 그 이전에 SDRAM 같은 현대 컴퓨터 구조에서 이 구조를 갖고 있는지를 먼저 보자고 했다.
SDRAM은 그러한 신호는 가지고 있지 않다. 이에 나는 CC84에게 현재 우리가 설계중인 RV32I50F 까지의 프로세서는 해봤자 메모리 내장형 SoC이며 이러한 구조의 경우
아키텍처에 따른 특수한 디자인을 가지게 되어있다고 했다. 현재 Instruction Memory가 ROM으로 기초 구현되어있는 것도 그렇고, 아직 I/O도 구현 안되어있으며 RV32I외의 표준 I/O 및 메모리 구조를 구현하기 위해서는
지금 하는 것이 아니라 충분한 하드웨어 백그라운드의 개발 이후, OS를 탑재하기 전에 하여도 늦지 않을 것 같다고 말했다. 그리하여, Read Done 신호를 추가하여 PCC에게 전달해,
Data Memory의 Read가 끝났을 때만 다음 명령어로 진행할 수 있도록 했다. 어라. 이걸 위한 FENCE가 아니었나. 모르겠다. 
생각해보면 파이프라이닝이나 듀얼코어화를 한 이후 SDRAM, DDR4 같은 메모리 계층 구조를 접목시키기엔 수정소요가 너무 클 것 같은데.. 명확한 시기를 어떻게 잡으면 좋을까? 
일단 RV32I37F를 R2.v2로 개정하며 Read Done신호를 Data Memory와 PC Controller에 포함했다. 
이제 수정된 tb를 기반으로 검증하러 가봐야겠다. 

raw_imm 검증 완. 검증하는데 상호 확증성으로 이용한 모듈은 아래 세가지이다. 
Instruction Decoder
Immediate Generator
ALU Controller
오늘 기준 Instruction Memory의 예상값 오탈자를 제외하면, (LHU, LBU, LUI) 모든 모듈에서 raw_imm과 imm은 잘 작동한다 .

그리고 Data Memory의 Read 로직에 대해서 확정안을 내리게 되었다. 
저녁 점호시간동안 고민한 끝에 연등시간에 내려와 CC84의 근샤 동안 만든 로직이다. 
이에 대해 CC84와 논의를 거쳤고, 이렇게 하기로 했다. 

**Data Memory의 로직은 그대로 유지하되, Read Done 신호를 출력하도록 한다.**
목적 : 별도의 중복 명령어 없이 Read 신호를 받아 해당 값이 나오도록 하는 것. 

[Load 명령어]
Load 명령어임을 Control Unit에서 탐지한다. 
read_done 신호 1인지 확인, 0일 경우 PCC에게 PC=PC로 업데이트를 막음.
PC의 업데이트 신호를 막는 신호가 Control Unit에서 출력되는 PC_Stall 신호이다. 
Stall된 뒤, 다음 사이클에 read data가 나오면서 read_done이 동시에 1이 된다.
PC_Stall 신호가 비활성화 되고, 그대로 PC = NextPC가 된다.

[다음 명령어가 같은 load 명령어일 경우.]
memory read는 마찬가지로 1인 상황. 
이제는 마찬가지로 read_done이 즉시 1이 되고, 다음 명령어로 넘어가게 된다.

[다음 명령어가 load 명령어가 아닐 경우]
memory read가 0으로 떨어진다.
read_done도 0이지만, load 명령어가 아니기 때문에 이는 무시된다.
그렇기에 PC_Stall은 활성화 되지 않고, 다음 명령어가 진행 된다. 

PC Stall 신호의 데이터패스는 이러하다. 
Read Done신호가 Data Memory에서 Control Unit에게로 전해진다. 
Control Unit은 Read Done 신호의 조건에 맞게 PC Controller로 PC Stall 신호를 출력한다. 
PC Stall을 받은 PC Controller는 Next PC값을 현재 PC값으로 고정하여 추가적인 명령어의 수행을 막는다. 
Read Done이 Control Unit에게 1로 전해지면, Control Unit이 PC Stall 신호를 비활성화한다.
그렇게 다음 명령어 수행으로 재개된다. 

이제 Data Memory의 Read 수행을 위한 ReadDone, PC Stall의 신호 추가 이후,
최종적으로 RV32I37F의 검증절차가 마무리될 것으로 보인다. 
부디 Testbench에서 문제 없기를.

이제 해당 구현들 (Data Memory Read Procedure Revision, Register File Verification)이 끝날 때 까지 해야할 것.
5단계 파이프라이닝 구상... 
Fetch, Decode, Execution, Memory, Writeback.
이 각 단계 사이별 단계의 내용을 담아두기 위한 레지스터가 필요하다.
Fetch/Decode 레지스터 (IF/ID 레지스터)
Decode/Execution 레지스터 (ID/EX 레지스터)
Execution/Memory 레지스터 (EX/MEM 레지스터)
Memory/Writeback 레지스터 (MEM/WB 레지스터)
총 4개. 

각각, 어느 모듈들 사이에 넣어야할지가 문제다.
새로 생길 모듈은 Hazard 처리 유닛. Hazard Unit으로 부르도록 하자. 
IF/ID 레지스터는 IC와 ID사이에 두면 되겠고
ID/EX 레지스터는 ALUcontroller와 ALU 사이..? 더 찾아보고 연구해보자.
오늘은 여기까지. 벌써 CC84가 PC controller의 PC Stall 의 검증을 완료했다고 한다.
하루하루 진척이 크다. 계속 나아가자.


# [2025.03.03.]
5단계 파이프라이닝을 구상하며 다이어그램 설계 중.
파이프라인은 5단계로 구성된다.
Instructoin Fetch ; 명령어 인출
Instruction Decode ; 명령어 해독
Execution ; 명령어 수행
Memory access ; 메모리 접근
Write Back ; 메모리 Write Back.
IF / ID / EX / MEM / WB.

파이프라인은 하나의 명령어에 제한되지 않고 각 명령어 수행의 단계별로 모듈들의 순서들을 개체화 시켜서 병렬화를 도모하는 것에 의의가 있다. 
결국 한 명령어 사이클에 다중 명령어를 수행하기 위해서 필요한 데이터들을 저장해두는 곳이 파이프라인 레지스터인 것.
이 때 파이프라인 레지스터는 클럭 신호에 따라 움직이는 D 플립플롭이며, 다음 클럭 신호에 바로 저장된 값을 출력하고 또 저장하는 방식의 단순 레지스터이다. 
별도의 주소지정 접근 방식이 아니다. 
그리고 이러한 파이프라인 레지스터는 각 파이프라인 단계 사이마다 필요한 상태와 데이터 (이를 하드웨어 설계에서는 context, 문맥이라고 하는 것 같다.)를 저장해두는 곳이다. 
5단계 파이프라인에서 필요한 파이프라인 레지스터는 4개.
IF/ID 레지스터, ID/EX 레지스터, EX/MEM 레지스터, MEM/WB 레지스터. 
지금부터 각각 레지스터를 블럭 다이어그램에 구현하며 신호 체계와 파이프라인 구조들을 학습해나갈 차례이다. 

우선 IF/ID 레지스터는 Instruction Memory 진영과 Instruction Decoder사이에 배치한다.
받는 신호는 PC와 I_RD 신호. 이 외에는 파이프라인과 상관없이 전역적으로 즉시 영향을 목적으로하는 신호들이라 파이프라인 외부로 한다.
IC_Status나 Exception Detector로 출력되는 NextPC의 경우엔 파이프라인과 관계 없이 전역적으로 통제되고 어느 단계던 즉각적으로 수행되어야하는 로직을 담고 있으니까 IF/ID 파이프라인 레지스터에는 필요 없다고 생각했다. 

이제 ID/EX 레지스터.
기본적으로 Instruction Decoder에서 쪼개진 신호들이 각 모듈별로 연결되어있다. opcode, funct3, funct7, imm 같은 신호들. 
이제 이 신호들을 ID/EX레지스터를 거쳐 해당 모듈들로 연결시켜주는 작업을 해주면 된다. 
그 중에서도, 독립적으로 동작하는 모듈이 있으므로 비슷한 경로에 겹치는 J_Target 같은 신호를 건들이지 않도록 조심한다. 
파이프라인을 고안하며 ID/EX레지스터가 있다면 Instruction Decoder가 필요 없어지는 것이 아닌가 생각해보았지만 그건 아니고, 여전히 그걸 디코딩해줄 별도의 모듈이 있는게 맞다라는 결론을 내렸다. 
그렇게 2단계 파이프라인 레지스터인 ID/EX레지스터를 배치했다. 

CPU는 A4용지 한 페이지에 담길 수 있는 첨단의 블럭 다이어그램이다 라고 했던가.. 슬슬 A4용지 한 장에 담기 어려워지고 있는 것 을 느끼고 있다. 
데이터 패스를 최대한 명확하게 하기 위해 현재 신호들을 각 모듈별로 이름과 목적지를 명시적으로 표시하기에 생기는 한계점인 것 같지만, 일단 이번 5SP(5-Stage Pipeline)구현까지만 A4용지 한 장에 담아보고,
레이아웃 크기를 늘릴 규격을 생각해보아야할 것 같다. RV32I37F의 Data Memory; Read timing issue를 개선한 tb 웨이브폼 파일을 CC84가 올렸다.
아직 보진 않았지만 CC84가 잘 작동하는 것 같다고 한다. 역시., 다행이다. 오히려 안됐다면 시간은 더 걸리게 될 것이라 마음 아팠을 수도 있지만 더 재밌었을 수도 있을 것 같다.
어차피 이 앞길에 이 것과 같거나 더 심한 문제들이 도사리고 있겠지. 하하하. 아쉬워 할 것 없는 것 같다. 일단 이쯤하고 PX다녀왔다가 신호 검증을 시작해야겠다.
잘 하면 오늘안에 RV32I37F의 검증이 끝날 수도 있을 것 같다.

검증 중...

이야. Read Done과 PC_Stall 신호가 모두 잘 작동한다. Read 신호의 첫 시작에만 Read가 끝날 때 까지 새 명령어를 시작하지 않고 stall하는 로직도 잘 동작한다.
의도한 대로, 첫 read만 두사이클이 걸리면서 정상 값을 출력한 이후로 나머지 읽기 명령어들은 한 사이클에 거쳐 바로 출력된다. 
추후에 파이프라이닝 과정에서 이 PC Controller의 PC_Stall 신호도 Hazard 해결을 위해 요긴하게 쓰이겠지. 휴.. 다행이다. 의도된 대로 해결됐다. 

16:14. Data Memory의 WriteMask, 그리고 그 32비트 확장인 Extended Mask 신호가 한 사이클 더딘 것을 발견했다.
이상하게 저장은 또 잘 된다. 이를 CC84에게 피드백하여 수정했다. 
클럭신호에 맞춰서 extended mask 가 업데이트가 되어서 그랬었다. 그래서 extended_mask 를 wire 로 선언하여 해결했다.


2025년 3월 3일, 17시 06분. (♪ : 한로로 - 입춘)
RV32I37F 완성. (할 뻔)
Data Memory의 변경된 Read Logic을 반영한 테스트벤치와 더불어 Register File의 검증 끝에
마침내, 모든 모듈과 모든 신호의 검증이 끝났다. 
정말 수고했다. 기반이 탄탄해졌으니 이제 무엇이든 할 수 있을 것이다. 
다음은 CSR(43F), 그 다음은 Cache 구조(47F), 그 다음은 Debugger(50F)
자. 가보자!!!

이제 내가 만든 CSR 모듈을 CC84가 RV32I43F 탑 모듈로 구현하는 동안 파이프라이닝을 마저 작업해야한다. 
오늘 이 파이프라인 초안까지 완성되면 정말정말 더할 나위 없을 것 같다!!

앗. RV32I37F의 Misalign에 대한 검증이 tb에 포함되어있지 않았음을 발견. 급하게 CC84에게 요청했고, 
점프 주소 미정렬
분기 주소 미정렬
레지스터 주소 미정렬
데이터 메모리 주소 미정렬
이 4가지에 대해서 테스트를 요청했지만 1개만 하면 안되냐고 하여서 PC값 미정렬 경우의 수 1개, 데이터 메모리 주소 미정렬 경우의 수 1개 이렇게 두개만 부탁했다.
쓰읍.. 싹 하는게 맞는데.. 꽤 힘든가보다. 그래도 고생하셨으니까 일단 그렇게라도 해달라고 했다. 그냥 내가 해도 될 것.. 가틍ㄴ데..
rv32s 레포짓토리 운용에 있어서 파일 시스템 구조에 대한 개선안이 오갔다. 
그리고 그 일환으로, 각 RV32I37F~50F 까지 별도의 폴더들을 만들어서 그 수준에 맞게 구현하게 되면 중복되는 파일들을 너무 많이 만들게 된다는 결론에 도달했다. 
그래서 쓰일 PC_Aligner를 만들고, 데이터 메모리 주소 미정렬에 대해서 이야기를 나누었다.
메모리 읽기 주소 미정렬은 애초에 메모리 읽기 접근 자체가 하위 2비트가 00으로 고정되는 로직이라 misalign이 날 일이 없다 판단해서 추가 변동 사항은 없었다.
문제는 메모리 쓰기 주소 미정렬인데, 여기서 CC84와 나(KHWL)과 Confliction이 났다. 
CC84는 쓰기 명령어는 수행되되 주소 접근만 되고 실제로 쓰는 작업은 없게끔 하자고 했다.
나는 쓰기 명령어 주소의 하위 2비트 정렬을 강제로 하여 Error correction code 느낌으로 고쳐서 작업이 수행되도록 하자고 했다. 
설전이 오가다가, CC84의 보안관련 이슈가 될 수도 있다는 데에 입각하여 HINT처럼 작동하게 하자는 점으로 결정되었다.

그리하여, RV32I37F의 최종 다이어그램 RV32I37F.R3를 만들었다. 
PC_Aligner의 구현과 Data Memory의 Misalign의 구현이 다 마쳐졌나보다. 검증의 시간.

검증 끝. 
JAL과 LW의 주솟값만을 CC84가 바꿨다. 기존 벤치에선 잘 작동했으니 추가 벤치마킹에선 그냥 값만 수정한 셈.
lw에서 misalign이 정렬된 값을 볼 수 있는 신호는 없다.
때문에 address입력 자체는 0000_02c1으로 오입력 난걸 확인했고,
(address신호의 출력은 없으니) 해당 명령어로 불러와야될 제대로 된 값이 load가 된걸 확인했다.

misalign시 스킵되는 시나리오가 포함되어있지 않아 포함해서 다시 vcd를 받았다.
그리고 misalign시 아무 처리도 없이 그냥 스킵, HINT 명령어처럼 동작하는 것을 추가적으로 검증했다. 
Store시 misalign 발생이라 BE_Logic의 misaligned 플래그가 활성화 되는 것 또한 확인했다. 

이로서.. RV32I37F의 검증이 모두 끝났다.. 2025.03.03. 23시 34분.. RV32I37F의 완성이다..

남은 연등시간 9분.. 파이프라이닝 구상이나 하다가 끝내야겠다.
계속., 나아가자. 

# [2025.03.04.]

오늘은 2단계 파이프라인 설계에 더불어 EX/MEM 레지스터의 배치를 하려고 했다.
일과시간에 컴퓨터 구조 및 설계 개정 5판의 파이프라이닝 부분을 다시 정독했는데, 역시 교과서라 그런지 참조할 내용이 굉장히 많았다. 
개인정비시간엔 개발을 못했고, 연등시간이 되어 시작하려고 했다.
CC84가 마침 e러닝 수강을 해야한다고 해서 혹시 RV32I43F의 구현을 내가 해보겠냐고 물어왔다.
난 파이프라인 설계가 우선인 것 같아 안될 것 같다고 했지만, 이내 CSR 파일의 구현도 내가 했으니 아싸리 RV32I43F의 구현도 내가 하는 게 꽤 괜찮을 것 같다는 결론에 도달했다.
그렇게 RV32I43F 탑모듈 설계를 시작하게 되었다.
RV32I37F의 코드를 기반으로 CSR 모듈의 신호를 새롭게 선언하고, CSR File의 인스턴스화를 했다. 그러면서 csr_op가 csr_write_enable 신호로 개선되면서 퇴역했었는데,
이에 대한 수정 사항이 Control Unit에 반영되어있지 않음을 발견했다.
그래서 Control Unit의 csr_op 신호 관련 변경을 CC84에게 요청했고, 허가를 받아 수정했다. 이제 내일 할거.
Control Unit의 csr_write_enable 신호 testbench.
RV32I43F의 CSR 파생 및 데이터패스 구문 검토
Insturction Memory 내 CSR 관련 명령어 추가 및 RV32I43F DUT 수행.
파형 분석, 검증.

오늘은 여기까지. 

# [2025.03.05.]
당직. RISC-KC Processor Design Manual I 의 작성만 했다. 30분 졸았던 시간과 업무를 처리하는 시간 외에는 진짜 거의 수 시간을 이 문서작업에만 갈아넣은 듯 하다. 
3.2장 Main Modules의 내용들의 초안을 모두 만들었고, Extension Modules도 Memory Controller, Exception Detector, Trap Controller 이 세 가지만 더 적으면 된다.
앞으로 당직 2~3번이면 모두 다 작성하지 않을까 싶다. 어찌저찌 보니 벌써 매뉴얼의 페이지가 18페이지 분량이 되었다. 아직 초안이기도 하고 담지 못한 내용이 많다보니 더 분량이 많아지겠지..
크하하하. 화이팅!!!

# [2025.03.06.]
근무자 취침을 하고, 16시 정도에 일어났다. 이발을 하려고 했지만 사람이 너무 많은 관계로 하지 못했고, 저녁식사를 한 뒤 바로 개발에 임했다. 
해야할 일은 다음과 같다. 
1. 37F 아키텍처 기반 상위 아키텍처 변경사항 적용.
먼저 다이어그램이다. 37F 아키텍처 구현에서 추가된 Read Done신호와 PC_Stall을 적용하고, 43F의 다이어그램에는 PC_Aligner까지 같이 구현해서 37F의 아키텍처를 완전계승시켰다.
RV32I43F.R2로 명명했다. 

2. RV32I43F 만들기
└CSRop를 CSR_Write Enable로 변경한 CU의 테스트벤치
└탑모듈 합성, 테스트벤치
csr_op로 되어있던 걸 csr_write_enable로 바꾸고 Control Unit의 Testbench를 돌려 정상작동함을 확인했다. OPCODE_INVIRONMENT일 때 funct3가 0이 아닌 값이면 CSR 명령어밖에 없는데, 기존 CSRop신호는
각 funct3별로 동작을 할당해두었지만, 단순 Write Enable로 최적화 된 이상 그러한 로직은 필요없어져 funct3 != 0 일 때 csr_write_enable를 1로 하게끔했다. 
RV32I43F의 top module에서도 구현을 착수하여 모듈과 신호를 파생시켰다. 생각해보니 어제인가 그제인가 탑 모듈에서 신호르 파생할 때, CSR_Write Data를 별도의 CSR Write Data 로 wire 해뒀는데,
사실 아키텍처상 CSR File에 들어가는 쓰기 데이터(Write Data)는 ALU의 연산 결과인 ALUresult신호 그대로가 들어가는거라 csr_write_data 신호를 없애고, csr_write_data(ALUresult)로 신호 파생을 해두었다. 
오늘은 여기까지. 가자가자!!

# [2025.03.07.]
오늘은 전투휴무를 썼던 날이었지만 전혀 개발을 하지 못했다.
오전에는 당직사령의 통제로... 갑자기 사지방의 제한이 일어났고, 그렇게 오후에 개발하려고 했더니 동원훈련 조교였던 내가 인수인계를 받아야한다고 전투휴무임에도 불구하고
동원훈련장으로 끌려가서 인수인계를 받고 왔다. 차라리 어떻게 해야하고 그 지형 파악하고 그런 '인수인계'였으면 차라리 나았겠지만 그런건 간부님들이나하고 역시나 그냥 단순 노동만했다. 
그렇게 착잡하고 화나는 마음을 억누르고, 차분히 개인정비시간이 되어 (그 복귀도 개인정비시간 시작 직전에 복귀했다. 내가 폰을 받으려고 전투휴무를 썼었나. 아닌데.) 사지방의 문을 열고, 개발을 시작했다.
원래대로였다면 RV32I43F의 코드 개발을 구현해야했지만, 머리도 좀 식히고 마음도 가라앉힐겸 파이프라인의 설계로 착수했다. 
파이프라이닝을 하면서 든 생각이지만, 이 파이프라인의 본질은 싱글사이클, 즉 한 사이클에 처리될 수 있는 명령어를 다섯 사이클로(설계하고자하는 파이프라인의 단계만큼) 쪼개는 데에 있다.
그리고 그 쪼갠 신호들을 각각 어느 단계에서 배치를 할 것이며, 파이프라이닝에 포함되지 않는 전역 신호와 파이프라인에 속하게 되는 지역신호, 그리고 해당 단계에서 쓰이거나 쓰이지 않을 신호들까지 명확하게 구분하고 판단하여야한다. 
때문에 기존에는 필요한 로직을 떠올리고, 로직을 기반으로 모듈을 고안하고, 고안한 모듈을 그대로 블럭 다이어그램에 설계를 하면 되었는데 이제는 해당 파이프라이닝이 실제로 실행되며 타이밍에 맞는 제대로된 신호가 입력되어야하는
각 단계별 신호의 지역성과 전역 신호의 타이밍까지 고려하고 판단해야해서 난이도가 꽤나 올라가게 되었다. 
RV32I50F 5SP 다이어그램 설계 중. IF, ID, EX 까지는 모두 파이프라이닝했다!, EX/MEM 레지스터의 배치가 문제이다.. Execution은 ALU Controller, ALU, Branch Logic 이 세 모듈의 작동 단계인데,
A4 용지 한 장의 분량에 이 모듈들을 다 담으려고 하니까 쉽지 않다. 물론, 현재 다이어그램에서 입출력 신호들의 이름표기를 생략하면 모듈 블럭 자체의 크기가 줄어들면서 훨씬 편해지지만, 
학습적인 목적을 띄는 본 프로젝트의 특성상 그렇게 하기는 많이 아쉬워질 것 같다. 최대한 신호들을 압축시키고, 최대한 모듈들을 붙여둬야한다. 우리 프로세서의 집적도(?)가 올라간다 ㅋㅋㅋㅋ 
슬슬 시간이다. 오늘은 여기까지! 내일은 5단계 파이프라인의 초안 완성을 목표로 해야겠다. 

# [2025.03.08.]
RV32I43F의 탑모듈 설계를 하고, Instruction Memory에 Zicsr 확장 명령어를 입력했다
어랍쇼 문제. 왜 Write가 한 사이클 뒤로갔지. 큰일났다. 

# [2025.03.09.]
사실, 웨이브폼의 처리 문제일 수도 있다고 생각하고 그 예상값이 정확하게 나왔는지를 검증했더니 연속된 쓰기나 읽기, 참조에서 
웨이브폼에서 보이는 것 처럼 다음 사이클에 적혔다는 표기와는 다르게 원활하게 해당 값이 잘 읽혀서 예상값이 잘 나오는 것을 보고 검증완료했다. 
사실 여기까지 검증과정에서 헤쳐오는데 적지 않은 문제들이 있었다. CSR의 write enable신호가 활성화가 안된다던지, csr명령어가 제대로 웨이브폼에 표기되지 않는다던지, 
명령어의 끝 사이클 결과를 확인하기 위해서 HINT명령어를 마지막에 추가했는데 새 명령어가 안들어간다던지.. Register의 Write source가 CSR로 제대로 선택이 안된다던지..
대부분은 RV32I43F를 RV32I37F 아키텍처에 접목하는데 확장 또는 수정이 필요했던 MUX와 모듈 및 신호의 파생문제였고, 치명적인 로직 오류나 모듈의 수정소요는 없었다. 
원래 바로바로 기록을 했어야 했는데 그럴 겨를이 없이 2일이 바로 지나가버리는 바람에 많이 축약했다.
FPGA보드가 슬슬 구현 검증을 위해 필요해지고 있다. 그래서 그 보드들을 고르는데 시간을 꽤 썼고, 덤으로 우리나라 CPU개발 기업중에 에이디칩스 라는 곳의 EISC 구조 ARK코어 아키텍처를 접하게 되었다.
국내에서 유일하게 범용 CPU를 설계하는 곳 같은데, 나중에 한번 찾아봐도 좋을 것 같다. 
원래 DE0-115나 Z7 20 같은 메이저한 FPGA 보드가 처음부터 고려 제품군이었지만, 시대가 많이 지났으니 더 괜찮은 보드들이 비슷한 가격에 꽤 나왔을 줄 알고 삽질을 많이 했다. 하지만 없었다..
가장 적합한게 Z7 20같다. 그래픽 출력 단자 인터페이스도 있고, Xillinx 계열이라 AMD의 관련 FPGA 강의들 및 사후지원을 볼 수 있다. 또한, 프로그램 라이센스가... 많이 자유롭다.!

# [2025.03.10.]
군 입대 1주년. 동원 예비군 조교로 아침부터 끌려가 딱히 이렇다 할 성과도 못내고, 돌아와서 쉬다가 20시 30분에 개인정비 시간이 끝난다는걸 보고 부랴부랴 밀린 Devlog 쓰려고 왔다. 
8일 9일의 Devlog는 방금 다 쓴 것이다.. 하물며 지금 시간은 20:26. 슬슬 가야한다... Z7 20을 사려했는데 개인 구매일 경우 6~70만원에 육박하는 돈이 필요하다... 또한 그걸 군대에서 굴리려면 로컬 시스템은 필수고,,
X300 Deskmini를 반입한다고 한들 그에 필요한 추가비용도 만만치 않다.... 내일은 컴퓨터구조및 설계 교재와 현재 아키텍처 구조가 담긴 사진을 갖고가서 남는 시간마다 파이프라인을 마저 설계하고 듀얼코어 구조에 대해서 연구해보아야겠다. 
It is what it is. 잘 헤쳐나가보자. (ChoiCube84는 오늘부로 휴가다... 하 오늘 훈련 전날이라 연등도 없는데...)

# [2025.03.13.]
2박 3일간의 동원훈련이 끝이 났다. 내일은 정리하러 가고, 오늘은 개인정비시간을 보장받았다. 많이 피곤했던 건지, 개발을 못해서 답답했던건지 정서적 고갈이 꽤 심해서 초췌했다. 
그간 3단계까지 (EX/MEM) 파이프라이닝을 해둔 다이어그램을 보며 어떻게 듀얼코어 및 멀티쓰레드 상황에서의 구현을 어떻게 해야할지 생각을 이어갔다. 
결국 멀티hart, 멀티스레딩, 다중 코어 환경에서는 각 코어의 구조적 차이보단 같은 메모리 공간을 공유해서 쓸 때 어떻게 리소스를 분배할 것이며, 스케줄링을 어떻게 분산구현을 할 것인가.
명령어 수행 절차를 하드웨어적으로 통제를 하여야하는데, 이 부분을 어떻게 구현할 수 있는가.에 대한 방안을 찾아야 할 것 같았다. 
그래서 혹여나 관련한 실마리를 찾을 수 있을 것 같아 RISC-V 매뉴얼 I의 17장 RVWMO부분과 Rtso 부분을 매뉴얼에서 발췌하여 훈련소에 들고갔었다. 관련해서 틈틈히 읽었지만 아직 완전히 이해가 된 상황은 아니다. 
파이프라이닝에서 EX/MEM 단계에서 약간의 고찰이 필요했던 것이, 메모리의 통제신호였다. 
50F 아키텍처에서는 Exception처럼 파이프라인을 무시하고 바로 관리되어야할 신호는 이미 Exception Detector와 Trap Controller에서 관리하고 있으니
그에 직접 연결되는 신호를 제외하고 남은 메모리 제어 신호들은 파이프라인 레지스터에 전달하여 타이밍에 맞는 적확한 명령어 수행을 할 수 있도록 해야한다라는 결론을 내렸다. 
그래서 지금 이 연등 시간안에 RV32I50F_5SP의 다이어그램 초안 완성본을 만드는 것을 목표로 한다. 

Memory Controller의 IC_Status, IC.IM_MUX신호는 명령어의 Fetch단계에서 Cache의 동작을 제어하는 신호이므로 파이프라이닝 레지스터에 연결되지 않는다. 
또한 파이프라이닝을 고안하며 현재 47F 아키텍처의 캐시 구조 확립에 있어서 캐시와 메모리는 같은 주소 입력값을 가진다는 설계 조건이 있다는 것을 기억했다. 
때문에 기존에 다른 주소 체계를 가진다는 지적한계의 전제를 기반으로 Instruction Fetch 단계에서 캐시 실패 시 해당 주소를 변환하여 캐시에 입력할 수 있도록 Memory Controller의 로직을 구현했었는데, 
이를 철회하며 Memory Controller의 PC와 I.Up_Addr 신호를 삭제하였다. 그리고 Instruction Area에서 Cache에서 Memory로 PC신호를 출력하는 기존의 다이어그램 설계에서
Program Counter 레지스터 모듈에서 나오는 PC 신호를 그대로 가져와 STAA 구조를 그대로 살리기로 하였다. 굳이 기존 설계처럼 Instruction Cache에서 PC를 별도로 출력해야 하는 이유를 현재 아키텍처에서 찾지 못했기 때문이다. 
와 근데 여전히 Read Done신호는 어떻게 해야할지 모르겠네. 이건 그냥 직접 해보면서 추후에 검증해야할 것 같다. 여기서 이론적 배경과 근거를 찾고 처음부터 완벽한 아키텍처를 구상하기에는 시간 소요가 너무 커진다. 
진행중. 아 삽질해버림. MEM/WB 레지스터 거의 다 만들었는데 공간 한계로 옆으로 옮겨야함. ㅁㄴㅇㄹ

# [2025.03.14.]
ChoiCube84의 Instruction Cache 구현. 로직에 대한 검증을 했다. 
ChoiCube84의 모듈 설계가 다이어그램상 설계와 상이하다는 것을 발견, 관련하여 의논하기 시작했다. 
FENCE.i 명령어를 위해 IC_Clean 신호를 다이어그램 설계에 넣었는데 코드에는 없었다. 이에 대해 reset 먹이면 될 것 같다는 말에 수긍했다. 
현재 코드를 FSM 개념을 들여 Update Mode와 일반 동작 모드를 별개로 구조화 하여 설계하였는데, 이에 대해 굳이 그렇게까지 할 필요는 없을 것 같다고 했다. 
그저 Cache Miss시 업데이트는 단순 쓰기 작업일 뿐이라고 했고, 47F의 캐시 구조 구상 당시 정리했던 내용을 인용했다. 

1. 캐시에서 miss를 알고 있으니까 내부 레지스터를 두고, 그걸 이용해 조건문을 써서 충족시, 메모리에서 인출된 데이터가 현재 캐시로 일단 들어오고 있으니 그 값을 Write 한다

2. 명확한 역할 분리와 설계철학에 따라, Hit/Miss신호를 MC로 보내고, MC가 그에 대한 제어 신호를 Cache에 보낸다. 
 이게 Cache에게 있어서 Write Enable 신호가 되고, 이 활성화에 따라 캐시는 입력되고 있는 메모리의 데이터 값을 지정된 주소에 쓰기 한다
 
저렇게 두가지 방법론을 생각했었고, 현재 다이어그램에 반영된 구조는 2번이다. 
Hit Miss 신호를 Memory Controller에 보내고, MC는 이를 인식하여 Write Enable 신호를 Cache에 보내 입력중인 데이터 메모리의 인출된 데이터를 쓰기하여 업데이트하는 것.
지금 잘 살펴보니 현재 다이어그램에 해당 Write Enable신호가 없는 것을 발견. 해야할일 추가. 

5단계 파이프라이닝 중 마지막 고비인 Read Done, Write Done, BTaken 신호를 어느 파이프라인 단계에서 해당하는 모듈로 연결시켜야하는 지에 대한 고찰이 끝났다. 
파이프라이닝은 한 사이클로 걸리는 단일 사이클 명령어들을 각 단계별 수행으로 변환하여 5사이클로 늘리지만 그 구조상 처리량을 늘리는데 의의가 있다.
하지만 꼭 모든 명령어를 파이프라인 사이클만큼 나눌 필요는 없는 것이었다. 필요한 단계에서 신호를 해당하는 모듈에 방출하고, 나머지 사이클은 NOP로 그냥 무시해도 되는 느낌이다. 
그래서 Read Done과 Write Done 신호를 MEM 단계에서 바로 Control Unit으로 연결했고, BTaken 신호를 EX단계에서 PC Controller로 연결했다. 

Write Done 신호에 대해서 확립하는 과정 중, 버퍼-캐시-메모리 구조에 대하여 서로가 상이한 이해를 하고 있다는 것을 알아냈다. 
내가 이해하고 있던 바는 아래와 같았다. 
우리의 데이터 캐시 유닛에는 버퍼 공간이 있다. 
캐시 쓰기 작업을 할 때 바로 적어둘 공간으로 버퍼가 있고, 이 버퍼는 메모리 쓰기 및 읽기 같은 접근 명령어가 수행되지 않을 때 바로바로 캐시로 Flush하게 된다. 
만약, 연속된 쓰기로 버퍼가 가득차게 된다면, 이를 Cache가 인지하고, DC_Stats 신호를 Memory Controller로 보내어 Flush가 필요함을 알린다.
Memory Controller는 이를 인식하고, B2M_Flush 신호를 Data Cache에 보내에 Buffer에 쓰여진 데이터들을 메모리로 바로 Flush 한다.
데이터 흐름 구조가, Buffer -> Cache -> Memory인데, Buffer가 가득 찰 경우, Buffer에서 Memory로 한번에 Flush 하는 것이다.

ChoiCube84는 내가 위에서 설명한 버퍼 - 캐시 - 메모리의 흐름이 아니라 캐시 - 버퍼 - 메모리로 설명하고 있었다. 
어쩐지 좀 기이하다 생각하고는 있었다. 이게 사실 컴퓨터 구조론적으로도 더 적합한 구조라 생각했다.
때문에 더 상위 설계로 보이는 Write Back 방식의 캐시 구조 설계로 고정하고, 앞서 고안했던 캐시 버퍼 구조는 devlog에 남겨두기로만 했다. 
Write Done 신호는 여전히 Write Back 또는 FENCE에 있어서 사용되어야하는 신호이기에 그대로 있다. 단, 이제는 Write Done신호가 사실상
Write Back의 수행 이후 데이터 메모리에 다 썼으므로 다음 데이터 메모리에 접근하는 명령어를 수행할 수 있다는 것을 알리는 신호가 되었다. 

그리고 43F 아키텍처를 설계하고 검증하며 추가된 로직이었던 PC_Stall 신호를 47F 기반 아키텍처에도 적용하는데, 이에 따라 PC Controller로 향하는 Write Done 신호를 없애도 되게 되었다.
Write Done신호는 Control Unit에게만 입력되고, CU에서는 이를 기반으로 PC_Stall 신호를 조정하면 되는 것이다. 

# [2025.03.15.]
생각해보니 FENCE.i를 Instruction Cache로 알리고 invalidate하기 위해선 그 식별 신호가 당연히 필요하다. IC_Clean 신호는 있어야하는 것이 맞다. 
Trap Controller에서 FENCE.i에 대한 명령어 식별 신호를 받아서 Instruction Cache가 Invalidate를 수행해야한다. 다만, Trap Controller에서 보내는 신호를 Instruction Cache에서 
별도의 IC_Clean 신호로 받아 처리하는 것이 아니라, 이를 RST(reset)신호로 처리하는 것으로 구현하면 된다. 

캐시의 쓰기 정책을 Write Back으로 하게 되어, 이에 필요한 캐시-메모리간 신호에 대해 ChoiCube84가 질문했다.
'캐시에서 메모리로 Write Back 저장할 때, 새 데이터 값만 전달하면 될 것인지, 주소도 보내줘야할 것인지.'
이에 답변했다. 
Write Back의 발동 조건은 다음과 같다. 
캐시에 변경사항을 기록하다 해당 라인에 다른 태그를 가진 메모리를 불러와야 할 때 데이터 메모리에 값을 되돌려 놓는 것.
이 Write Back은 데이터 area의 읽기 및 쓰기 모두에서 발생할 수 있다. 
읽기일 때는 Miss시 캐시에 테이블 올려놓아야하니까 필요해지고
쓰기일 때는 캐시의 해당 테이블에 써야하는데 그 테이블에 있던 변경사항을 메모리에 적용해줘야하니까 필요해진다. 

STAA 때문에 어차피 같은 값이 일단 읽기 때는 들어간다.
WriteBack의 안건은 현재 수행되는 대상 주소가 아니라, Memory로 WB되어야하는 데이터의 주소가 따로 있다는 것이고,
그럼 별도의 Address 주소를 전달해주는 것이 맞는 것 같다는 결론을 내렸다. 
어차피 데이터 area에서 입력되는 주소 체계 및 값은 같기에 Cache에서 바로 Memory로 가면 된다. 
기존에 버퍼 구조로 인하여 잔류되어있는 B2M Data, Addr 신호를 WB_Data, WB_Addr로 수정하였다. 

이렇게 캐시구조에 대한 최신 설계안을 탑재한 파이프라이닝이 완료되었다. 
하지만 이게 파이프라인 프로세서 설계의 끝이 아니다. 사실 이 파이프라인 레지스터를 배치하는 것은 그 전초작업의 성격이다.
정말로 시작하는 것은 파이프라이닝으로 발생하는 Hazard들을 처리하는 Hazard Unit의 배치와 설계이다. 

일단 파이프라인의 각 모듈 수행별 단계 배치 및 레지스터 배치는 완료했으니, 당장 시급한 47F 아키텍처의 다이어그램 갱신을 하여 ChoiCube84에게 넘겨주어야 한다. 
자 드가자!

18:56 RV32I47F.R10 완료. 43F 아키텍처에서 생긴 변경사항들을 적용하고, 50F5SP 아키텍처 설계중 새롭게 개정된 캐시 구조를 적용하여 갱신했다. 
덤으로 Mybox의 파일 구조도 단순화했다. 

이제 Hazard Unit의 디자인을 해봐야겠다. 

컴퓨터 구조론에 입각하여, [컴퓨터 구조 및 설계, David. A. Patterson. 2015]
컴퓨터의 파이프라이닝에서 발생할 수 있는 해저드는 다음과 같다. 

해저드의 정의 : 다음 명령어가 다음 클럭 사이클에 실행될 수 없는 상황이 있다. 이러한 사건을 해저드(hazard)라 부르는데, 세 가지 종류가 있다.

1. 구조적 해저드 (structual hazard)
-같은 클럭 사이클에 실행하기를 원하는 명령어의 조합을 하드웨어가 지원할 수 없다는 것을 의미한다. 

2. 데이터 해저드 (data hazard)
-어떤 단계가 다른 단계가 끝나기를 기다려야 하기 때문에 파이프라인이 지연되어야하는 경우 일어난다. 
-컴퓨터 파이프라인에서는 어떤 명령어가 아직 파이프라인에 있는 앞선 명령어에 종속성을 가질 때 데이터 해저드가 일어난다. 
!

3. 제어 해저드

아 연등은 파이프라이닝 공부만 했다. 파이프라인을 개관함에 있어서 데이터 신호와 제어 신호를 별도로 취급하여 정해진 단계 내에서의 수행에서 해당되는 모듈에 입력해야했었고,
이게 제일 큰 고찰이었는데 그에 대한 가이드라인이 이미 책에 나와있었다. 얼떨결에 문제를 풀고 답을 내버렸는데 생각지도 못하게 친절한 답지까지 확인해서 설계한게 맞다는 검증을 하게 된 셈.
하하 다행이다. 문제가 생겼다. 파이프라이닝은 아니고, 우리가 설계하는 rv32s 가 lw 명령어의 구현을 기점으로 더 이상 싱글사이클 프로세서가 아니게 되어버렸다는 것. 그리고 캐시를 하면서 더더욱 한 사이클 이내에 모든 동작을 넣기가 힘들어졌다는 것.
한 사이클 안에 동작을 할 수 있도록 클럭 유지 시간을 늘리는 것은 근본적인 해답이 되질 않는다. 대부분의 로직이 clk의 posedge를 기반하기 때문. 

# [2025.03.16.]
오늘은 아침에 RV32I50F.5SP.R1 다이어그램의 신호들 배선을 최적화했다.
어제 컴퓨터 구조 및 설계 책을 읽다보니 신호들이 지나가는 경로를 하나로 묶어 설계를 하는 경향이 보이고, 그 전부터 그렇게 하는게 깔끔할 것 같다는 생각에 이참에 그렇게 한번 최적화를 했다. 
그리고 그 다음부턴 데이터 메모리의 한 사이클 밀린 것에 대해 연구를 계속했다. 
어제 연등을 끝내며 화장실 회의에서 이야기가 나온, read enable 신호의 posedge화를 실험해보았고, 무참하게도 syntax error가 떴다.. 하하..,
지금 이러한 문제가 클럭 사이클이 1로 오르는 rising edge에서 read enable이 0으로 잡히고, 
설계특성상 그 이후에 read enable이 여러 조건문을 거쳐 1로 활성화되기 때문에 바로 read를 실행하지 못하는 것 같은데.. 
이를 타계할 방법이 없을까? 클럭의 edge만 잡아서 하기 때문에 타이밍상 놓치는거면, posedge clk라고만 적지 않고 데이터 메모리의 read 동작 자체를 posedge clk or clk 로 해서 clk가 1일 때도 동작을 수행하게끔 하면 해결할 수 있지 않을까?
라고 생각해보았지만, 동기식 설계 원칙을 위반하기도하고 여러 예상치못한 오류들을 불러일으킬 것 같아서 폐기했다. 
IDEC에서 교육받은 자료를 살펴보았고, 여기서 보이는 데이터 메모리의 코드는 우리가 현재 구현하고 있는 데이터 메모리 코드와 많이 달랐다. 
이와 관련해서 ChoiCube84에게 추가적인 연구를 요청한 상태이고, 해당 코드가 우리와 같은 테스트벤치 환경에서 문제상황을 개선하게 된다면 37F부터 작성해온 데이터메모리의 구조를 수정할 예정이다.
만약 같은 한 사이클 밀리는 현상이 발생한다면 현재 데이터 메모리의 설계를 고수한다. 
RV32I50F의 구현 및 검증이 완료된 이후 64비트 확장을 하여 새 레포지토리를 만들 예정인데, RV64I에서부터는 FPGA에 탑재된 DDR3 SDRAM의 사용을 같이 할 것이기에 그 때 가서 데이터메모리의 구조를 개변할 예정이다. 

--

47F 아키텍처를 ChoiCube84가 구현하던 중, fence.i의 구현에 대하여 issue를 제기했다. fence.i가 50F 아키텍처에서는 Exception Detector- Trap Controller에서 담당하는데, 
47F에서는 Instruction Cache에 rst신호를 줄 모듈과 신호가 없다는 것. 본래 47F 아키텍처가 47가지 명령어를 지원하고, 43F에서 오는데 추가된 명령어가 FENCE, FENCE.tso, PAUSE, FENCE.i였다.
허나 이 fence.i를 지금 구현하기 위해서는 Memory Controller와 Control Unit에 추가적인 신호 설계를 해야하는데 이 경우 다른 아키텍처와의 상호 호환성이 아니라 47F에만 국한되는 구조가 생기며
이마저도 다른 아키텍처에서 재활용할 수 없게된다는 문제가 생겼다. 때문에 Zifencei확장을 50F에서 추가하기로 했고, 47F 아키텍처의 이름을 46F로 정정했다. 

10+15+3+6+3+6+2+1 = 46
47F Architecture supports Total 46 Instructions.

Thus, the naming of 47F Architecture renamed to 46F Architecture. 
(Originally 47F Architecture includes fence.i instruction with Memory Controller. 
However considering the module's Interoperability, we decided to remove zifencei extension to 50F Architecture. )

--

IDEC의 레퍼런스 Data Memory의 코드를 우리의 테스트벤치로 동작시켜보니 한 사이클 내에 정상동작하는 것을 발견.
이제 해당 코드를 참조하여 기존의 Data Memory 코드를 수정할 예정. 

RV64I에서 추가되고 변경되는 명령어들을 종합하고 정리하는 중.

--

연등시간
uhh., RV64I 명령어들 종합 끝냄.
FENCE 명령어시 Writeback인 현재 캐시 정책상 밀린 쓰기를 Data Memory에 쓰도록 할 것임.
이에 따라 Flush 작업이 다 끝났는지를 Cache가 알기 때문에 Write Done을 데이터 캐시에게 줬고, 추후 Pipeline에서도 PC_Stall 신호는 쓰일 가능성이 농후하니 그대로 뒀다.
아직 레퍼런스 코드를 이용한 수정 후 동작 확인 안한 상태. 

어 됐다.. verilog 에서 =의 문제.. 
다행이다. 뭔가 더 큰 무언가를 놓치고 있던게 아니라, verilog를 숙달하지 못한 점에서 온 실수 였다. 
이렇게 read done신호는 없어진다. 그리고 원래 PCC에 PC_Stall이 들어가면 Write Done신호는 PCC에 필요가 없는데, 그게 다이어그램에 남아있어 없앴다. 
그리고 read enable도 없앴다 사실 이게 핵심인 것 같기도 하다. 이제 이 수정 소요를 각 다이어그램 파이널 버전을 리비전하여야 한다. 
오늘은 여기까지. 내일은 1박 2일 휴가라 개발환경을 모두 압축 저장해서 업로드해야겠다. 

# [2025.03.17.]
PR했다. 1박 2일 휴가라 그리 많은 건 하지 못했다. 

# [2025.03.18.]
캐시 구조와 FENCE 명령어에 대한 ChoiCube84의 제언.
캐시의 WriteBack 동작을 FENCE로 할 수 있게 하는 것은 큰 당위성을 제시하지 못한다. 
굳이 할 이유가 없을 뿐더러, multi-hart 상황에서의 용도와 그 취지에도 어긋난다. 
듣고보니, WriteBack을 일괄로 Flush할 이유는 single-hart에선 필요 없기도하고, 의견을 수용했다. 
43F 아키텍처에서 46F 아키텍처로 (FENCE, FENCE.TSO, PAUSE 지원) 확장되는 것이 아니라,
43F 아키텍처에서 44F 아키텍처로, FENCE 류 명령어들을 제외하고 Zifencei 명령어 지원만 확장된다. 
이를 위해 Instruction Cache가 생기고, Data Cache도 일단 설계하고 구현에 착수했으니 RV32I44F부터 캐시 구조를 가지게 된다. 
G확장 또는 추후 Linux Kernel을 올리기 위해서 Zifencei는 필요하다. 

A확장와 CMO에 대해서 공부했다. 

# [2025.03.19.]
로드라인 및 아키텍처를 기확하고 계획안을 수정하며 구체화하였다. 

## 수정된 로드라인은 다음과 같다. 

[basic_rv32s]
-----
RV32I37F : 	Base Architecture that supports 37 Instructions.
			Which is an amount that excluded EBREAK, ECALL, FENCE, FENCE.TSO, PAUSE instructions.
			└ Partial RV32I (RV32I except FENCE, FENCE.TSO, PAUSE, ECALL, EBREAK)
RV32I43F
└ P.RV32I + Zicsr

RV32I44F_C
├ P.RV32I + Zicsr + Zifencei
└ + Cache Structure (Instruction Cache, Data Cache)

RV32I47F : 	Supports EBREAK, ECALL, mret from RV32I & Privileged Architecture.
			Final version of basic_rv32s repository
			├ P.RV32I + Zicsr + Zifencei + ECALL + EBREAK + mret
			└ + Debug Interface, Debugger

[RV64s]
-----
RV64I59F : RV64I Extension
└ 47F + RV64I

RV64I59F_5SP
└ 59F + 5-Stage Pipeline

RV64IM72F : M extension supported. Maybe Grapchics Interface from this architecture. 
└ 59F5SP + RV64M

[Final]
RV32IMA104_CMO_RVWMO : A extension supported.
└ Full RV64I + RV64M + RV64A + Zicsr + Zifencei + mret + CMO + RVWMO

▶ Fully supports RV32I. Including FENCE, FENCE.TSO, PAUSE after all.
▶ Complies RVWMO memory consistancy model. 
▶ Dual-Core (multi-hart) processing system.
▶ Improved Cache structure
 ├ Two separate L1 Cache 	; Instruction Cache, Data Cache respectively.
 ├ One integrated L2 Cache 	; Integrated Cache that contains Instructions and Datas.
 └ One shared L3 Cache		; A Cache that shared by each core(hart).
 
 L1$, L2$ for each core respectively, L3$ is shared cache that all the core can access.
▶ Supports DDR3 SDRAM integrated on FPGA board.

# [2025.03.20.]
이제 해야할 건, 파이프라이닝 레지스터의 배치는 완료 되었으니 Hazard Unit을 구상하고 제어헤저드, 데이터헤저드, 구조적 헤저드에 대한 대응 설계를 하는 것 하나.
그리고 그간 수정된 아키텍처를 rv32s 의 모든 Final 설계도에 revision하는 것이다. 

어어... 메모리를 한 사이클 안에 가능케 한게 비동기 읽기로 구현했기 때문이라고 했다... 그리고 이게 맞는지 찾아보니
대부분의 기초적인 컴퓨터 구조론에 입각한 싱글사이클 프로세서 예제의 데이터 메모리가 비동기 읽기, 동기 쓰기로 구현되는 것을 알아냈다. 
그렇기에 메모리는 5단계 파이프라이닝 이전까지는 비동기식으로 하기로 했고, 37F, 43F 아키텍처 다이어그램을 Revise했다. 
RV32I50F가 FENCE류 명령어가 제외됨으로 인하여 RV32I47F가 되게 되었는데, 기존 다이어그램 설계와 이름이 비슷하여, RV32I50F를 19일 부로 Archiving하고, RV32I47NF로 명하기로 했다.
그리고 기존의 RV32I47F는 마찬가지로 FENCE류 명령어가 제외되므로 RV32I44F가 되었다. 이는 별도의 중복된 아키텍처 이름이 없으므로 그대로 RV32I44F로 쓴다. 

RV32I47F는 R9에서 Archive. RV32I44F로 변경되어 revision되어야한다.
RV32I50F도 마찬가지로 Archive하고 RV32I47NF로 변경되어 revision되어야 한다. 
오늘 한 것은 여기까지. 내일은 개인정비시간까지 잘 활용해서 진도를 많이 나가야겠다.

FPGA는 교수님의 추천으로 Nexys Video 제품을 구매했다. 이제 로컬 시스템을 구매하기만 하면 된다. 

43F까지 리비전 완료. 

# [2025.03.21.]
생각해보니 250316 회의 때 Zifencei확장을 Trap Controller가 구현될 때 같이 하는 것으로 했기에, 44F도 아니고 43F에 캐시 구조를 접목한 구조가 된다. 
최종적으로 RV32I43FC (C for Cached)로 아키텍처 이름을 지었다. 

이러면 이제 37F, 43F, 43FC 까지 했으니 47F 아키텍처 (구 50F 아키텍처)를 리비전 할 시간이다. 

47F 아키텍처를 이전하면서 이전에 남아있던 Memory Controller를 현재 구조로 적용하며 생각이 들었다. 
Data Cache의 DC_Write 즉 WriteEnable신호가 Memory Controller에서온다. 멤컨이 그럼 명령어를 알고 이 동작을 지정해줘야하는데, 어찌되던 멤컨한테 명령어에 대한 정보가 가는게 맞는 것 같다는 생각.
이것마저 CU에서 해주게 되면, 메모리 컨트롤러의 의미가 단순히 STAA에서 Cache Miss시 메모리 출력 데이터로 MUX를 조정해주는 데이터패스 지정 모듈 말고는 되지 않는다. 

Control Unit 에서 Data Cache 에 바로주는게 아니라 Memory Controller 를 거쳐서 주자는 거지?
라고 ChoiCube가 답문했고, 그리 간단하게 생각할 문제가 아니라 사유가 필요한 시간이라고 생각했다. 
우리는 추후에 FPGA보드에 탑재된 외장 DRAM, DDR3 SDRAM을 쓰게 될 것이다. 
그럼 실질적으로 CPU 안에서 통제되는 메모리; 코어에서 통제하는 메모리는 L1, L2 처럼 각 코어별로 내장되어있는 메모리에 국한될 것이다. 
각 Core마다 독립적으로 있는 것이 아닌, 공유되는 성질을 띄는 L3$나 RAM을 각 코어의 Control Unit에서 다룰 수는 없는 노릇이니까. 
그 중간자로서 Memory Controller가 있고, 이 것이 L3$와 RAM을 다루면 될 것 같다.

이건 현대 CPU 구조를 한번 조사해보아야할 것 같다.
기억상, CPU에도 Memory Controller는 내장되어 있으며 
모듈러 다이, MCM;칩렛 방식인 AMD의 ZEN 아키텍처에서도 메모리 컨트롤러가 별도의 다이로 설계되어 있는 것으로 알고 있고,
모놀리식인 Intel의 아키텍처에서도 메모리 컨트롤러가 별도의 die는 아니지만 존재하는 것으로 알고 있기 때문이다. 

https://en.wikichip.org/wiki/File:zen_block_diagram.svg
zen 아키텍처의 블럭 다이어그램에 캐시 관련 데이터패스가 설명되어 있어 참조해볼만 한 것 같다.
이것 + 국방창업경진대회 신청을 오늘 안에 해야한다. 

밥먹고 와야지. (17:52)

캐시 계층 구조와 그 컨트롤러, DRAM쪽 컨트롤러. Ryzen ZEN 아키텍처를 기반으로 분석하였다. 일단 지금 rv32s의 경우 메모리는 외장 메모리가 아니라 SoC 내장 메모리로 구현될 것이고
FPGA는 파이프라이닝 이후에 구현할 것이기 때문에 코어 통합으로 하기로 했다. uncore 영역이라는 개념을 습득하게 되었다. 
(근데 비동기 읽기 / 동기식 쓰기 메모리가 FPGA에서 합성이 가능한지는 미지수인데,, 웬만하면 rv32s도 FPGA에서 검증하고 싶다. )
 --- 
ChoiCube와 상의하여 캐시 구조를 최적화하다 보니 Memory Controller를 없애게 되었다. 
캐시 실패와 적중에 따라 SAA에 따라 인출되는 명령어 및 데이터를 골라주는 MUX는 Cache에서 출력되는 Cache Status 신호를 통해(DC_Status, IC_Status) 선택할 수 있도록 하였고
Memory 모듈의 쓰기는 결국 WriteBack의 경우에 한정되기 때문에 Control Unit에서 보내는 MemRead, MemWrite는 모두 Cache로 가고, Data Memory의 Write Enable신호는
Cache의 DC_Status 신호를 NOT(반전) 한 신호로 제어하기로 했다. 현대의 컴퓨터 구조를 의식하며 Memory Controller가 있어야한다는 선입견으로 캐시 구조 설계 초창기에 Memory Controller를 포함하였는데, 
점점 배워가고 알아가며 현재 단계에서는 사용할 필요가 없다는 결론에 도달한 것이다. 
추후 L3$나 DDR3 SDRAM를 고려하고 설계를 하는 경우에, 코어별로 공유하는 메모리 공간임에 따라 일관성 로직의 관리를 위해서 별도의 Memory Controller가 생겨날 것이다. 
Zen Architecture를 참조하여 화면 출력용 GUI, DDR Memory Interface, USB같은 uncore 영역에 대해 별도의 통합처리 탑 모듈을 설계할 것이다. 
최종적인 캐시 구조가 확립되어 이제 구현하면된다. RV32I43F_C.R1과 RV32I47NF. 

# [2025.03.22.]
확정된 캐시 구조와 수정된 로드라인에 따른 rv32s 프로젝트의 아키텍처 완성본인 RV32I43FC.R1과 RV32I47NF를 완성했다. 
각각 14:58, 15:50에 완성했다. 자잘자잘한 신호 배치의 최적화까지 완료했고, 이제는 다음 레포지토리인 rv64s(가칭)에서 진행할 RV64I 확장을 생각하며 RV64I59의 초기 설계안을 만들어야한다.
아마 rv32s에서 더 이상 수정이 많지는 않겠지만 없지는 않을 것이라 생각한다. 사실상 나올게 다 나온 느낌이긴해도, 구현하는 과정에서 생각보다 많은 수정소요와 배울 거리들이 발생했기 때문에, 지금부터는 ChoiCube84의 몫이다. 
mybox에는 파일시스템 분류를 잘 했는데 이를 basic_rv32s 본 github 레포지토리에 업데이트 해야한다. 저녁식사 먹고 나서 해야겠다. 
RV64확장의 시작인 RV64I59F에서만 각 신호의 입력단에서 비트 크기를 명시해놓을 것이다. 
아, RV32 대비 차이를 보기 위해서 RV32I47NF에도 표기해놓는 것이 좋을 것 같다. 

# [2025.03.23.]
일요일 당직. 운영체제 책을 펴고 2장까지 공부했다.
운영체제의 개발 과정 및 그 뒷받침이 되는, 배경이 되는 하드웨어들의 기본 이론들.
CPU를 여기까지 개발하면서 알게된 것들이긴 하지만 꽤나 ㄹ현대 컴퓨터 구조에 맞게 잘 개발 해오고 있었다는 생각이 들었다. 
그리고 그 경험을 기반으로 책을 이해하게 되니 습득하는 속도도 많이 빨랐다. 
운여엧제의 종류들과 그 기반 기술들 발상과 그 해결점. 기초에 대해서 공부를 했다.
시분할 운영체제, 다중 프로세스 어쩌구 저쩌구. 
RV32I CheatSheet의 RV64버전 업데이트를 마쳐서 인쇄했다. 간부님께서 이런 파일 뺄 수 있는지
따로 여쭤봐주신다 하셨다. 정말 감사하다. 매뉴얼을 기반으로 읽으면서 재차 확인하니
대부분의 연산은 결과가 64비트가 되는 것이 아니라, word자체는 32비트인데 그걸 데이터구조에 맞게
64비트로 확장하는 식이었다. ALU에 이러한 확장 로직을 더해도 되긴 하는데, 구현 방식이 두가지로 갈릴 것 같다.
ALUop를 추가하여 해당 비트 확장을 연산에 포함하는 것과 (이 경우, ALUcontroller와 ALU의 수정소요가 발생한다. )
64-bit extender. opcode와 funct3, 7값을 별도로 받아 명령을 상황에 맞게 처리하는 방법.

# [2025.03.24.]
HCWcloud에 대한 육군창업경진대회 사업계획서를 쓰는데 시간을 꽤 갈아넣었다. 
ChoiCube84가 23시 49분경 Data Cache의 검증 완료 소식을 들려줬다. 이제 이를
내일부터 검증을 하면 될 것 같고, RV64I 기준 작업물들 압축파일을 mybox에 정리해서 goormide에 올리면 될 것 같다. 
파일 시스템 정리. 오늘은 여기까지. 

# [2025.03.25.]
어.,,..,..,., 운영체제 공부하고, 꽤나 괜찮은 논문을 찾았다. 
싱글사이클, 5단계~7단계 파이프라이닝, 캐시구조, 멀티코어 확장구조, 그리고 이것저것 거의 플랫폼에 준하는 하드웨어 설계를 해낸 논문이다.
스리랑카에 있는 대학에서 작성한 논문. BRISC-V: An Open-Source Architecture Design Space Exploration Toolbox. 
현재 우리의 로드라인과 많은 부분이 맞닿아있고, 꽤나 좋은 참고자료가 될 것이라 생각한다. 한번 연구해봐야겠다. 
그리고.,. 전역까지 5개월., 논문과 자소서 쓰는 2개월., 남은 3개월 안에 그 로드라인을 모두 끝낼 수 있을 것인가에 대해 상당히., 상당히 의심된다.
GPT o1에게 해당 논문이 어느정도 수준의 논문인지 물어봤고, 연구실 프로젝트거나 박사학위의 논문, 즉 몇 학기 내에 끝낼 수 없는 분량이라 한다.
여기까지 올라온게 그래도 잘 해낸거라고 봐야하나. 다시 생각해보면 아이디어 구상 및 설계 자체는 빨랐지만 그걸 가능케해준 ChoiCube84의 공이 상당히 큰 것 같다.
아무리 기초적인 구조라고해도 이는 빠른 속도가 맞는 것 같기도 하다. (아닐 수도. 프로젝트 착수일로부터 약 4개월이 지나고 5개월이 되어가고 있다.) 하루에 해봤자 3시간 남짓인 것에 비해
꽤나 좋은 성과물인 데는 변함이 없으려나. 이 논문으로 하여금 학계에 기여를 할 수 있는가. 내가 논문으로 보여주고 싶은 것은 무엇인가. 그리고 그 목적은 무엇인가. 
KAIST의 특기자 전형으로 학부생 입학하기 위함. 그냥 CPU를 만드는 것이 꿈이었으니까. 그리고 그걸로 AMD, Intel같은 기업을 만들고 싶으니까.,
솔직히 두렵기도하고, 많이 부담되고 걱정된다. 그래도 일단 이걸 하는 것 말고는 할 수 있는게 없으니까. 계속 나아가야한다. 

# [2025.03.26.]
BRISC-V 논문에 적힌 사이트에 들어가 플랫폼을 구경했다. 코드들에 대한 레퍼런스를 꽤 삼을 수 있을 것 같다. 

# [2025.03.27.]
오늘 외진 가서 예상치 못하게 파견간 ChoiCube84와 재회하여 가볍게 회의를 나눴다. 
Data Cache의 Masking 문제. 콜드스타트 상태에서, 메모리에 쓰기를 요청하고, 캐시에 쓰여진다. 그 값을 Flush할 때 Masking을 하지 않으면 캐시의 초기값이 들어가는 문제가 발생한다.
e.g.) Cache : 0000_0000, Mem : DEAD_BEEF. Cache : AAAA_0000, Mem : DEAD_BEEF -> Cache : 1242_AABE, Mem : AAAA_0000 (Expected AAAA_BEEF)
어라 근데 이러면 메모리랑 캐시의 초기값 자체를 0으로 통일해두면 되는 문제 아닐까? 굳이 캐시 Flush때의 마스킹 신호가 필요할까? 
Data Cache 쪽 라인의 무효화 경우가 있나..? 물론 있으면 좋을 것 같긴한데... 
RV64의 구현은 ALU와 ALUController, Instruction Decoder의 modding으로 구현하기로 했다. 
나머지 변경사항은 Data area와 Register File의 데이터 폭을 64비트로(XLEN)해야한다는 점. 
Instruction area는 RV64로 간다고 해도 instruction의 데이터는 32비트 폭 그대로라 변경사항은 없다. 
다만 Instruction area에서 주소로 가르킬 수 있는 범위가 64비트로 넓어졌으므로 데이터의 폭은 같되 깊이는 더 깊어진다. 
Instruction Decoder의 변경사항은 다음과 같다. 
"W" 접미사가 붙은 shifting 명령어들은 word, 즉 32-bit 단위 (RV64로 와도 한 명령어의 길이는 32-bit, 즉 word는 32-bit 단위이다. )를 처리한다. 
기존 RV32I에서 포함되어있는 SLL, SRA 같은 "W"접미사가 붙지 않은 명령어는 XLEN 만큼, 즉 RV64에서는 64비트 만큼 다루기에 shamt(Shift amount)가 6비트로 확장된다. 
하지만 기존 RV32I와 똑같이 32비트를 다루는 "W"접미사가 붙은 명령어는 RV32I 처럼 32비트를 다뤄야하기에 rs2는 기존과 같은 5비트로 제한된다. 
RV64I로 넘어오면서 새로이 생기는 명령어이기에 64비트를 다루는 명령어로 착각할 수 있지만, (내가 그랬다) 기존 32비트 처리 명령어가 있어야 하니까 그걸 W로 두고, 나머지 XLEN기반 명령어들은 
64-bit로 확장됨에 따라 특성이 변이하는 것이다. 

## RV64로 오면서 변하는 사항은 다음과 같다. 

[R-Type]
SLL, SRL, SRA : 최대 64비트 쉬프팅. rs2의 비트 영역이 6비트로 늘어나고, funct7이 대신 6비트로 줄어든다. (이름값 못하는 funct7이 된다. )

[I-Type]
SLLI, SRLI, SRAI : 최대 64비트 쉬프팅. imm값의 25:20을 shamt로 잡고, 31:26이 funct7으로 들어온다. (6비트)
LW : Load-word. 데이터 폭이 64비트로 바뀌었으므로 32비트를 로드하는데 나머지 남은 상위 32비트를 sign-extension한다.

신규 명령어.
[R-Type]
ADDW, SUBW, SLLW, SRLW, SRAW : 32비트 처리 명령어들. 덧셈, 뺄셈, 비트쉬프팅. 
각각 32비트로 계산하며, 그 결과의 상위 32비트를 sign-extension하여 쓰기한다. 

[I-Type]
ADDIW, SLLIW, SRLIW, SRAIW : 32비트 처리 상수 명령어들. 덧셈, 비트쉬프팅.
ADDIW는 마찬가지로 32비트 계산 후 sign-extension하여 쓰기한다. shifting은 위 설명대로. 

LWU, LD : Load(적재) 명령어. 
LWU - Load Word Unsigned. 32비트 데이터의 상위 32비트를 zero-extension하고 로드한다. 
LD - Load Double word. 64비트 데이터를 로드한다. 

이상이다. 

## 하드웨어 변경사항을 정리하면 다음과 같다.

1. Instruction Cache, Memory (Instruction Area)의 주소 폭 64비트. 

2. Instrcution Decoder : rs2의 비트 6비트로 확장, 'w'명령어일 때는 그에 맞는 비트 영역을 슬라이싱하도록 설계.

3. imm gen : 64비트 Sign-extension. (상황에 따라 zero-extension. U-Type)

4. Register File : 레지스터 데이터 폭 및 RD1, RD2 출력 비트 64비트. 

5. CSR File : CSR_RD 64비트. 나머지 CSR 레지스터는 그 규격에 맞게 32비트와 64비트를 병행. (설계 자체로서 데이터 폭은 64비트. 32비트 데이터 출력시 zero-extension)

6. ALU Controller : W명령어 (RV64-only instructions)전용 연산 ALUop코드 추가. (32비트 계산 후 64비트 확장)

7. ALU : ALUop코드에 따른 W명령어 연산 및 처리 추가

8. Data Cache, Memory (Data Area)의 주소 및 데이터 폭 64비트

## 그리고 캐시 구조를 구상하며 생각난 질문 하나. 
메모리를 결국 외부 DRAM으로 빼뒀을 때, 
명령어와 데이터가 같이 저장되는 통합 메모리로 생기게 된다. 이 떄 Instruction Cache쪽에 저장될 데이터인지 Data Cache 쪽에 저장될 데이터인지 어떻게 구분하고 저장하는건가? 
그리고 이에 대한 해답으로, 메모리 자체에는 명령어와 데이터가 함께 저장되지만, 운영체제는 페이지 테이블을 통해 각 메모리 페이지에 실행 가능(Executable) 속성이나 데이터 전용 속성을 부여할 수 있다는 것을 알게되었다. 
이 속성은 MMU에 의해 참조되며, 명령어 페치 시에는 실행 가능 페이지에서 데이터를 가져오게 되어 I‑cache에 적재되고, 데이터 접근 시에는 별도로 D‑cache로 처리된다. 

구체적으로는 운영체제의 MMU가 페이지 테이블 엔트리(PTE)를 통해 각 페이지에 대해 실행 가능(executable) 속성과 읽기/쓰기 권한을 지정하는 방식, 예를 들어 NX(No-eXecute) 비트와 같은 메커니즘을 뜻한다. 
이를 통해 소프트웨어는 특정 메모리 영역을 명령어 실행용(예: .text 섹션)으로, 나머지 영역은 데이터용으로 구분할 수 있게 된다. 

“Unified Memory” 환경에서도 CPU 내부에서는 명령어 페치와 데이터 접근 요청을 구분하여 각각 I‑cache와 D‑cache로 라우팅하게 되는데, 이는 파이프라인의 접근 유형
(명령어 페치 vs. 데이터 접근)과, MMU가 부여하는 페이지 속성(예, 실행 가능 여부)에 기반한다.

“Memory Protection and Page Attributes”
“NX bit and executable memory”
“Unified memory with separate instruction and data cache”
“MMU and cache management”
“Cache partitioning based on executable attribute”

RV64I59F의 윤곽은 이정도면 꽤 많이 들어낸 것 같다. 지금부터는 그 이후인 5SP, 5-Stage Pipeline을 구현하기 위해서 기존 RV32I50F 기반으로 되어있는 5SP 도안을 
RV32I47NF 기준으로 (RV64I59F는 모듈 설계 자체는 동일하므로) 적용하고 Hazard Unit을 설계해야겠다. 
내일 또 당직인데, 내일은 운영체제를 마저 공부하고. 

RV64I59F 기준 파이프라이닝 레지스터를 다시 배치하고 있다. 기존 RV32I50F_5SPH.R1에 그냥 그대로 하려 그랬는데, 배치가 잘 안맞기도하고, 기존에 있던 신호를 검토하는 겸했다.
그렇게 실수 하나 발견. Trap_Controller에 CSR_RD가 입력되는데, 이게 Instruction Decode단계에서 이뤄져야하는 것이 맞는가에 대해 생각해보아야한다. 
오늘은 여기까지. 

# [2025.03.31.]
HCWcloud 관련 문서 작성을 마쳤다. 다시 CPU 개발로 돌아왔다. RV64I59F의 파이프라이닝 배치를 거의 다 끝냈다. 아마 내일 오전 중에 파이프라인 레지스터를 모두 배치하고
해저드 유닛을 나머지 시간동안 구상할 것 같다. 

# [2025.04.01.]
11:59 파이프라인 레지스터들의 배치를 모두 마치고 신호들 또한 최적화 했다. 
이제 해저드 유닛을 배치해야하는데... 연구 시작이다. 
## 2025.03.14에서 시작했던 파이프라이닝에 대한 내용을 마저 정리해보자. 

컴퓨터 구조론에 입각하여, [컴퓨터 구조 및 설계, David. A. Patterson. 2015]
해저드의 정의 : 다음 명령어가 다음 클럭 사이클에 실행될 수 없는 상황이 있다. 이러한 사건을 해저드(hazard)라 부르는데, 세 가지 종류가 있다.

1. 구조적 해저드 (structual hazard)
-같은 클럭 사이클에 실행하기를 원하는 명령어의 조합을 하드웨어가 지원할 수 없다는 것을 의미한다. 
→아마 동기식 메모리에서 한 사이클에 데이터를 불러오는 것이 이와 같은 구조적 해저드에 해당하는 것이 아닐지. 

2. 데이터 해저드 (data hazard)
-어떤 단계가 다른 단계가 끝나기를 기다려야 하기 때문에 파이프라인이 지연되어야하는 경우 일어난다. 
-컴퓨터 파이프라인에서는 어떤 명령어가 아직 파이프라인에 있는 앞선 명령어에 종속성을 가질 때 데이터 해저드가 일어난다. 

유형 : RAW(Read After Write), WAR(Write After Read), WAW(Write After Write)

!해결책 1; forwarding, bypassing / 전방전달, 우회전달
별도의 하드웨어를 추가하여 정상적으로는 얻을 수 없는 값을 내부 자원으로부터 일찍 받아오는 것.

!해결책 2; CCC; Change Clock Cycle / 클럭 사이클 변경
클럭을 분할하여 한 클럭의 1/2에 쓰기 작업을 할당하고, 2/2에 읽기 작업을 하도록 하는 것이다. 

3. 제어 해저드
-다른 명령어들이 실행 중에 한 명령어의 결과 값에 기반을 둔 결정을 할 필요가 있을 때 일어난다. (분기 명령어)
!해결책 1; 지연

!해결책 2; branch prediction / 분기예측
Simple : 분기가 항상 실패한다고 예측하는 것. 실제로 분기가 일어날 때만 파이프라인 지연.

Advanced : 어떤 경우는 분기한다(taken)고 예측하고 어떤 경우는 분기하지 않는다고(untaken) 예측하는 것이다.
└ dynamic hardware predictor. 동적 하드웨어 예측기. 
개별 분기 명령어의 행동에 의존하는 예측. 프로그램이 진행되는 도중 예측을 바꿀 수 있다. 

-각 분기가 일어났는지 안 일어났는지 이력을 기록, 최근의 과거 이력을 사용하여 미래를 예측. 
 예측이 어긋났을 때는 잘 못 예측한 분기 명령어 뒤에 나오는 명령어들을 무효화하고 올바른 분기 주소로부터 파이프라인 다시 시작.

!해결책 3; delayed decision / 지연결정 (소프트웨어 로직) ; delayed branch / 지연분기
다음 순서의 명령어를 항상 실행하고, 실제 분기는 그 명령어를 파이프라인에 넣고 나서 한 사이클 늦게 일어난다. 

구조적 해저드는 하드웨어에서 지원할 수 없는 것에 대한 해저드를 분류하는 속성이기에 제외하고, 우리가 다뤄야할 해저드는 데이터 해저드와 제어 해저드이다. 

하드웨어에서 파이프라이닝 해저드를 해결하기 위해선 두가지 요소에 대한 로직이 필요하다. 
1.해저드가 발생했는지에 대한 검충 로직
2.발생한 해저드에 대한 처리 로직

## 해저드 검출 로직을 설계해보자.

먼저 데이터 해저드이다.
명령어들의 종속성에 따라 이전 명령어가 끝날 때 까지 현재 명령어를 중단시켜야하는 경우. 
그렇다면 파이프라인에서 수행하는 명령어들 끼리의 종속성을 알 수 있으면 된다.
기본적으로 프로세서는 레지스터를 기반으로 처리를 하기 때문에 과거 처리되어 변경되어야 할 레지스터 주솟값이 현재 수행하고자 하는 명령어에서 참조하는 레지스터인지 확인하면 된다.
A 명령어의 rd, register destination의 주솟값이 다음 B 명령어의 rs1, rs2 즉 register source의 주솟값과 같은지 비교하면 된다. 
단, x0은 변하지 않는 0 값이므로 이 경우에는 전방전달을 하지 않아도 된다. 
instruction fetch를 거쳐야 decoding단계에서 비로소 rd, rs1, rs2의 주솟값이 나온니까.. 이를 판단할 수 있는 가장 최초단계는 ID/EX이려나?

일단, ALU에서 사용할 데이터는 srcA, srcB.

srcA에는 RD1, PC, rs1
srcB에는 RD2, imm, imm(shamt), csrRD

레지스터의 데이터가 처리할 리소스로 사용되고, 파이프라인 특성상 이 레지스터의 데이터가 이전 명령어에 의해 달라질 수 있으니 이를 기다려야하는 경우가 생긴다. 
이 기다리는 단계를 최소화하고자, 전방전달, Forwarding 이라는 방법이 있고, 이를 통해 기존 1번 명령어의 데이터가 레지스터에 업데이트 되기 전, 해당 데이터를 현재 처리중인 2번 명령어의 ALUsrc로 적절히 전방으로 전달해주는 것이다.
이 경우, ALUsrc MUX에서 나온 데이터 or 포워딩된 데이터 중 하나를 선택하는 MUX가 추가로 필요하고 포워딩된 데이터는 레지스터에 저장될 5가지 소스인 D_RD, ALUresult, CSR_RD, imm(LUI), PC+4가 해당된다.
즉 포워딩 해 줄 때 이러한 레지스터에 쓰여질 데이터 소스 중 하나를 처리하는 명령어에 맞게 포워딩을 해줘야한다.

해저드 탐지 유닛, 포워딩 유닛 이렇게 두개로 모듈을 나눠서 디자인했다.
해저드 탐지 유닛은 Instruction Decoding 단계에서 받은 rs1.A, rs2.A, rd.A 값을 저장하고, 다음 명령어에서 주어지는 rs1.B, rs2.B, rd.B 값과 비교한다.
rd.A가 rs1.B, rs2.B 중에 하나라도 동일할 경우, 데이터 해저드가 발생함을 포워딩 유닛에 hazardop 신호로 알린다. 

포워딩 유닛은 hazardop로 데이터 해저드가 발생했음을 알고, 앞에서 처리 중인 명령어 A의 결과 (레지스터 파일에 결과적으로 쓰기되는)에 해당되는 데이터를 명령어 B의 유형에 맞게 EX 단계 ALUsrc중 하나로 적절히 전달한다.

이 때 포워딩 유닛에서 필요한 신호는

EX/MEM.imm(LUI)
EX/MEM.ALUresult
EX/MEM.CSR_RD
MEM.D_RD
EX.PC+4

그리고 명령어 식별 신호. 일단 이렇게 구성했다
Forward Unit에 명령어 식별 신호를 추가하여야한다. 일단 여기까지. 밥 먹고 오자. 18:09
명령어를 모두 식별할 필요는 없다. 그 레지스터에 쓰기되는 결과가  D_RD, ALUresult, CSR_RD, imm(LUI), PC+4가 되는 명령어들을 식별할 수 있으면 된다. 

아 이건 opcode로 식별해야겠다. 별도로 신호를 구성한다고 해도 파이프라이닝하면서 어느 시점에서 어떤게 신호를 만들고 언제 출력할 건지를 또 별도로 판단해야한다. 
포워딩 유닛 신호 추가.
+EX/MEM.opcode
ID에서 해저드 발생을 탐지하면 해당 해저드 명령어가 EX에 왔을 때 그 바로 앞에 있는 MEM 단계 수행중인 명령어의 타입을 알아야
어떤 명령어를 통해 무슨 결과 값이 rd에 저장되는지 알 수 있다. 그래서 EX/MEM 단계에서 신호를 받아왔다. 

이렇게,, 일단은 포워딩 구현 완료.... 19:49. 좀 쉬었다가., 다음 제어 해저드를 연구해보도록 하자. 

---연등시간----
## 제어 해저드를.. 해볼 차례

제어 해저드는 분기 처리에서 그 목적이 있다. 

조사를 해보니 제어 해저드를 위한 분기예측기의 종류가 꽤나 다양하고 이에 대한 보안 리스크도 같이 있는 것 같..다..
OoOE(비순차실행)프로세서 구조라면 모두 갖는 특성인 것 같지만, 일단 보안문제는 나중에 생각하고 분기 예측에 대해서만 정리해보겠다. 

먼저 책의 내용 요약.
### 분기 예측(Branch Prediction) ⊂ 추측 실행 (Speculation Execution)
1. 정적 분기 예측 (분기 부정 예측 순차 실행)
분기가 일어나지 않는다고 예측하고 명령어들을 순서대로 계속 실행한다. 
만약 분기가 일어난다면 인출, 해독된 명령어들을 버리고(flush) 분기 목적지에서 실행을 계속한다. 
반대의 경우도 마찬가지. 
[구현]
예측실패로 실행된 명령어들을 버려야할 경우 분기 명령어가 MEM 단계에 도달했을 때, 그 이전 단계에 있던 명령어들의 제어 값을 0으로 바꾼다. 

2. 분기 조기 판단 
기존에는 분기 명령어에서 다음 PC값 즉 분기가 일어났는지 일어나지 않았는지는 MEM단계에서 선정된다고 가정했다.
이를 더 앞당겨 그 이전 단계에서 판단할 수 있다면 그만큼 분기 예측 실패시의 손실을 줄일 수 있을 것이다. 
[구현]
우리의 RV32I37F 기반 구조는 분기의 판단을 ALU 즉 EX에서 처리한다. 이를 파이프라이닝한 RV64I59F_5SP에서는 EX/MEM레지스터 즉 MEM단계에서 선정된다 볼 수 있다. 
이 경우 분기만을 판단하는 별도의 계산 유닛을 두고 이 분기 판단 유닛을 앞으로., ID정도로 빼면., 음.,,.,.., 연구 필요.
 
3. 동적 분기 예측
프로그램 실행 중에 분기를 예측하는 방법이다. 
3.1. 분기 명령어가 지난번에 실행되었을 때, 분기가 일어났는지를 알아보기 위해 명령어 주소를 살펴본다.
     그리고 만약 분기가 일어났다면 지난번과 같은 주소에서 새로운 명령어를 가져오도록 한다. 
[구현] 
3.1.1.	1비트 예측 방법
		분기 예측 버퍼 (branch prediction buffer) 또는 분기 이력표 (branch history table)라고 하는 자료구조를 이용한다.
		BPB는 분기 명령어 주소의 하위 비트에 의해 인덱스되는 작은 메모리이다. 
		메모리는 분기가 최근에 일어났는지 그렇지 않은지를 나타내는 비트를 가지고 있다. 
3.1.2. 2비트 예측 방법
		작은 특수 버퍼로 구현된다. IF 파이프라인 단계에서 명령어 주소로 접근한다. 
		분기가 일어난다고 예측되면 PC값이 알려지자마자 목적지 주소로부터 명령어를 가져온다. (분기 조기 판단 설계로 ID 단계처럼 이른 시기에 일어날 수도 있다.)
		분기가 일어나지 않는다고 예측되면 순차 주소에서 명령어를 가져오고 실행을 계속한다. 예측이 잘못된 것으로 판명되면 예측 비트들 값이 바뀐다. 2비트이므로 두번 연속 바뀌어야 예측을 반대로 전환한다. 
3.1.3. 분기 목적지 버퍼 (Branch Target Buffer) 
		분기 명령어의 목적지 PC값이나 목적지 명령어를 캐시에 저장하고 있는 구조.
		보통 태그를 가지고 있는 캐시로 구성되며, 이를 사용하는 방법.
3.1.4. 연관 예측기 (Correlating Predictor)
		지역적 분기 명령어와 최근에 실행된 분기 명령어의 전역적 행동에 대한 정보를 같이 이용하면 같은 예측 비트들을 사용하면서도 매우 정확한 예측을 할 수 있다. 
		
# [2025.04.03.]
일단 마저 하자면, 
3.1.4. 연관 예측기 (Correlating Predictor)
		지역적 분기 명령어와 최근에 실행된 분기 명령어의 전역적 행동에 대한 정보를 같이 이용하면 같은 예측 비트들을 사용하면서도 매우 정확한 예측을 할 수 있다. 
		각 분기에 대해 두 개의 2비트 예측기를 사용. 직전에 실행된 분기 명령어가 분기를 했느냐 하지 않았느냐에 따라 두 예측기중 하나를 선택한다.
		= 전역적 분기 행동은 예측 값 조회에 사용할 인덱스 비트를 추가하는 것으로 생각할 수 있다.
3.1.5. 토너먼트 예측기 (Tournament Predictor)
		각각의 분기에 대해 다수의 예측기를 사용하여 어떤 예측기가 가장 좋은 결과를 내는지를 추적한다. 
		각각의 분기 인덱스에 대해 두 개의 예측을 한다. 
		A는 지역적 정보에 기인한 예측, B는 전역적 분기 행동에 기반한 예측.
		선택기는 어느 예측기를 사용할 것인지 결정한다. 
		1비트 예측기이든 2비트 예측기이든 똑같이 작용. 두 예측기 중에서 더 정확했던 예측기를 선택한다. 


여기서부턴 조사 자료.

## 분기 예측 기술의 2가지 방법.

A. 분기 방향 예측.
실행될 파이프라인 조건 분기문의 분기 여부를 예측한다.

A.1. 분기 방향 예측 기법
A.1.1. BHT 기반 예측
A.1.2. gshare 인덱스 기반 적응적 분기 예측
A.1.3. 2가지 이상의 기법을 병행하는 하이브리드 분기예측

B. 분기 목적지 예측
분기문이 어디로 분기할지 목적지(target) PC값을 예측한다.
무조건분기, 조건분기, 서브루린/함수 호출/복귀 의 경우가 이에 해당한다.

B.1. 분기 목적지 예측 기법
B.1.1. 직접 분기문의 분기목적지 예측
		분기 목적지가 명령어에 인코딩되어있어 Directed-mapped 형식의 예측
		BTB를 통한 분기목적지 예측
B.1.2. 간접 분기문의 분기목적지 예측
		분기 목적지가 레지스터 또는 메모리에 있어 한 번 더 참조
		RAS(Return Address Stack)를 이용하여 함수 리턴 목적지 예측
		콜백함수와 가상함수, jump table 등 다른 분기문의 실행이력기반 iBTB(Indirect Branch Target Buffer)을 통해 예측

분기 조기 판단에 있어서 SiFive의 E31 프로세서 분기 예측 방법을 보면 Instruction Fetch 단계에서., 동작한다는데... 
Branch Taken을 알기 위해서는 그 결과값의 계산이 필수일텐데 이걸 어떻게 Fetch 단계에서 한다는 걸까..
아 그냥 Branch 명령어인지는 opcode만 보고 판단 바로 가능하니까 그걸 기반으로 우선 판단한다는건가.? 그리고 그 Taken인지는 이후 파이프라인에서 피드백을 받아 상태를 조정하는거고?
흠.,,..,.,.,,어 이렇게 되면 분기 예측 성공했을 때 penalty없고 분기 예측 실패시 3 cycle penalty가 발생한다는 내용과 일맥상통한다. 
맞는 듯. 
IF이후 ID, EX에 거쳐 총 3사이클 째에 예측에 대한 피드백이 들어오게 되는데, 
만약 실패했다면 실패피드백과 동시에 해당 분기명령어가 MEM으로 밀리고 그간 동작한 3사이클의 명령어들이 Flush 되어야하기 때문.
(https://justdoprogram.blogspot.com/2021/12/real-cpu-branch-prediction-bht-btb-ras.html)
opcode 만을 따로 받으려면 Instruction Decoding 단계에서 Branch Predictor가 작동하게 될 테니, Instruction Fetch 단계로 앞당겨서 최대한 손해를 최소화하기 위해 I_RD자체를 Instruction Decoder 뿐만 아니라
Branch Predictor에 직접 입력신호로 주어야겠다. 

아 이러면 BTaken 신호도 PCController에 직접 연결이 아니라, 파이프라이닝을 해야하나..?
믕..,,.,..,

# [2025.04.04. ]
## ChoiCube84의 캐시 구현 질문.

[시작 상황]
Cache: AAAA_AAAA (tag: 00000)

Memory:
00000_00000: AAAA_AAAA
00001_00000: 0000_0000 

**SW, Address 00001_00000, write data = DEAD_BEEF**

[SW 이후 상황]
Cache : DEAD_BEEF (tag: 00001) (dirty)

00000_00000 : AAAA_AAAA
00001_00000 : 0000_0000

**SH, Address 00000_00000. write data = CAFECAFE, writemask = 0011**

[SH 이후 상황]
*Flush*
Cache : DEAD_BEEF (clean) (tag:00001)

00000_00000 : AAAA_AAAA
00001_00000 : DEAD_BEEF 

—input, Addr: 00000_00000, Data: CAFE_CAFE, Mask : 0011

! Tag difference, assuming that all block are full.
Cache must bring the new tag's data

Cache : AAAA_AAAA (clean) (tag:00000)

00000_00000 : AAAA_AAAA
00001_00000 : DEAD_BEEF

—
[Write]
Cache : AAAA_CAFE (dirty) (tag:00000)

00000_00000 : AAAA_AAAA
00001_00000 : DEAD_BEEF

즉, Memory -> Cache 동기화 필요.
캐시의 태그가 가득찬 상황에서 이를 교체하기 위해선 메모리의 기존 데이터를 불러와야하는데
최악의 경우엔 FSM으로 flush -> read -> write를 나타낼 비트를 valid 비트에 넣어야한다

내 답변 : 애초에 그럴 일이 있을까? 현대 CPU구조를 보면 캐시의 데이터 자체가 지금 우리처럼 캐시:메모리 1:1 이 아니라 캐시에 저장되는 데이터 자체가 64바이트이다.
offset을 지금 활용안하는 체제인데, 이걸 사용해야 set associative도 살리고 문제도 해결할 수 있을 것 같다. 

# [2025.04.05]
당직근무. 그 동안 한 것들 reminder.
당직근무였기에 해당 근무 시간동안 한 것들을 작성하는 지금은 2025.04.06.이다. 

일단.. 캐시 관련 문제 해결.

캐시에 대한 내용을 컴퓨터 구조 및 설계에서 모두 읽었다. 
그렇게 하여, 캐시에 대한 설계를 처음부터 명확한 Specification 정의를 통해 단순화하고 해결하고자 한다. 

현재 우리가 만들고 있는 캐시 구조는 훗날 L1$가 될 예정인 Instruction Cache와 Data Cache이다.

----------

## RV32I43FC 기반 캐시 구조 제원 정의
Specification (L1$)

L1 Cache

2-Way Set Associative
[Tag, Index, Offset]
Tag : Block Search in Set
Index : Set Search in Way
Offset : Data Search in Block

32KiB, respectively for each Instruction & Data Cache (Harvard Structure)
Total 64KiB of L1$

32B Data per Block ( 8 Word per Block; B for Byte )
(Block = 메모리 계층 간 최소 단위)

512 Sets, 1024 Blocks.

32-5(offset, log2 32 = 5.) = 27 bits for Tags
log2 512 = 9 bits for Indexs
27 - 9 = 18 bits for Tags.

32-bit Requested Address : 
Tag 18-bit
Index 9-bit
Offset 5-bit
Tag [31:14], Index [13:5], Offset[4:2]

Cache Block Replace Mechanism : LRU ( Least Recently Used )

----------

## RV32I43FC 기반 메모리 계층 구조 동작
[ Write Buffer, SAA(Simultaneous Address Access) 채택. ]

1. 적재 (Load)
[Cache Hit] (이 경우 Dirty Bit은 상관 없다.)

① 캐시로부터 해당 데이터 반환
[Cache Miss] 
① 메모리 접근 
② 해당 Index의 교체할 블럭 판단 (Dirty Bit Check)
.
	[if Clean]
	CLK 1
    ⑴ SAA 메모리 데이터 반환
    ⑵ 메모리의 반환 데이터 그대로 캐시에 덮어쓰기.
    ⑶ 덮어쓰여진 캐시 Dirty Bit Set
	
 	[if not SAA]
    CLK 2
    ⑷ 캐시의 해당 주소에 갱신된 Clean 블록 데이터 반환
	
—————
    [if Dirty]
    CLK 1
    ⑴ SAA 메모리 데이터 반환
    ⑵ 캐시의 Dirty 데이터 블럭을 해당 주솟값과 같이 Write-Buffer에 저장
    ⑶ 캐시 Dirty Bit 해소
	
    CLK 2
    [ SAA 이후 요청 주소는 계속 입력되고 있어야 함 ]
    ( 3번 과정을 위해 메모리 블록에서 인출될 데이터의 주솟값이 필요하기 때문 )
	
    ⑶ Clean된 해당 캐시 블록에 메모리 블록 덮어쓰기
    ⑷ Write Buffer에 저장된 주소와 데이터를 해당 메모리에 쓰기

	(혹시나, Write Buffer에 저장된 주소가 메모리의 갱신 주소랑은 겹칠 수 없음. 겹친다면 애초부터 Cache-Hit여야 함. )

	[if not SAA]
    CLK 3
    ⑸ 캐시의 해당 주소에 갱신된 Clean 블록 데이터 반환
	
2. 저장 (Store)

[Cache Hit] 
① 캐시에 해당 데이터 쓰기 (Dirty Bit Set)

[Cache Miss]
① 메모리 접근 
② 해당 Index 교체할 Block의 Dirty Bit 판단
.
    [if Clean]
    CLK 1
    ⑴ 메모리의 반환 데이터 덮어쓰기
    CLK 2
    ⑴ 덮어쓴(갱신된) 캐시 블럭에 쓰기작업
    ⑵ 해당 블럭 Dirty Bit Set
—————
    [if Dirty]
    CLK 1
    ⑴ 캐시의 Dirty 데이터 블록을 주솟값과 함께 Write-Buffer 저장

    (if not SAA; CLK 2)
    ⑵ 메모리 반환 데이터 덮어쓰기 ; Clean Block
( SAA Hazard 예상 가능. 메모리 반환 데이터가 덮어씌워질 주소 = Dirty Data Block. L1$가 가장 빠르니까 타이밍 상 맞을 수는 있는데, 우려는 충분. 만약 상황 발생 시 고찰 필요. )
.
    CLK 2  (if not SAA; CLK 3)
    ⑴ 갱신된 Clean 캐시에 새 값 쓰기
    ⑵ 새 값 쓰여진 해당 블록 Dirty Bit Set
    ⑶ Write-Buffer에서 메모리로 해당 데이터 출력, 메모리 갱신 (캐시-메모리 동기화)
	
32-bit ISA 구조에 2-way set associative Cache 구조를 가진 AMD K6-III CPU를 최대한 벤치마킹, 참조 연구할 것이다. 
Branch Prediction 또한 AMD기반 시스템을 벤치마킹할 것이기도 하다. 

캐시구조는 이렇게 정의하므로서 문제를 해결했다. 역시 Specification을 먼저 고려하고 개발에 착수해야한다...

Branch Prediction에 대한 연구 성과는 다음과 같다. 
(밥먹고 와야지. 2025.04.06. 17:43)

------연등시간------

## Branch Predictor에 대한 설명을 시작하겠다. 
우선, 본 RV64I59F 구조에 설계될 Branch Predictor의 제원은 다음과 같다. (Specification)

[동적 분기 예측]
Tournament Branch Predictor.

Global Branch Correlation predictor
Local Branch Correlation predictor 
Meta predictor

세 가지 2-bit 예측기로 구성된다. 

Cold-start에서는 모두 Weakly Not Taken (Correlation Predictor) / Weakly Local (Meta Predictor) 로 셋팅 되어있다.

# [2025.04.06. ]
Not Taken이 보통 많은 경향을 가지고, Local의 예측기가 전반적으로 높은 연관 예측 성능을 가지기 때문이다.
하지만 시간관계로, 본 프로젝트의 1차 완성을 위해 2-bit BHT predictor를 사용한다. 

나머지는 일단 책에 있는 대로인데, 내부 로직 보다도 이제 실제 CPU 내부의 배치를 위해서 신호들을 고려해야한다. 

할거. 신호들 뭐 필요한지 검증
mispredict 시 flush 해야하는데 이 flush 어디서 담당할건지 선택
writedone 신호 어떻게 처리할지 생각해볼 것.

Jump의 계산을 Branch Predictor 즉 IF단에서 할 수 있으면 Flush 손실이 줄어드는데, 어떻게 할지 정할것. 아마 OoOE 할 때 없어질 문제 같긴 한데, 
일단은... 속도가 지금 필요하니까 기존 체제 유지해서 EX단계에서 Jump신호랑 ALUresult 와서 해당 주소로 PCC가 NextPC 업데이트 하는 방식으로 해야겠다. 

오늘은 여기까지. 어서 파이프라이닝 끝내고, RV64IMA 치트시트만들면서 각 확장 공부들 하고, 듀얼코어 구조랑 TLB, 가상메모리 공부, 운영체제공부.,..,.,해야겠다.

# [2025.04.07. ]
Hazard Detector를 Hazard Unit으로 변경하고, Flush 신호를 추가하여 각 파이프라인 레지스터에 flush 신호를 추가했다. 
구분이 필요한 각 파이프라인 단계별 신호에 EX.D_RD 이런 식으로 어느 단계에서 파생된 신호인지 이름들을 구분했다. 

그리고 우리의 Branch Predictor에서는 BTB를 사용하는 게 좋을 것 같은데, 개발 시간이 많이 지연될 것으로 보여지면 그때그때마다 BP에서 목적지 계산을 같이 하는 것으로 해야겠다.

Branch Predictor의 로직을 최악의 경우를 산정해서 정리해보자. 

조건부 분기 명령어를 실행한다고 가정.

[IF단계]
Branch Predictor에서 현재의 PC값과 opcode를 입력 받는다.
opcode를 통해 분기 명령어임을 확인하고, 현재의 분기 시점 PC값을 저장해둔다. 

Prediction 결과는 Taken. 
PC Controller에 B.EST 신호를 통해 Take되었다는 예측값을 보낸다.
그와 동시에 입력된 IF.PC 값과 IF.imm 값을 연산해서 분기 목적지 주소를 계산해서 PCC에 보낸다. 
그리고 해당 IF.PC값을 저장해둔다. 

만약 BTB가 구현되어있다면 PC를 Tag로, Direct Mapped 방식으로 데이터는 분기 목적지로 저장한다. 
그리고 입력된 PC값과 BTB를 비교해서 해당한 분기 목적지를 바로 PCC로 보낸다. 

PCC에서 이를 통해 PC값을 분기할 목적지로 하여 NextPC 신호로 PC에 출력한다. 

[ID단계]
명령어 해독 단계

[EX단계]
Branch의 prediction 실제 계산값이 나온다.
결과는 Not Taken. 
Branch Predictor에 EX.BTaken 신호가 입력된다. 

BP는 이를 토대로 misprediction을 감지해서 BP_Miss 신호를 Hazard Unit에 보낸다. 
그와 동시에 아까 IF에서 저장해두었던 기존 PC값의 + 4 값을 PCC에 넘겨준다.

동시에 Hazard Unit에서는 BP_Miss 신호를 받아서 각 파이프라인 레지스터에 Flush 신호를 보내 무효화한다. 

---------- 반대의 경우 ----------

Prediction 결과는 Not Taken.
PC Controller에 B.EST 신호를 통해 Not Take라는 예측값을 보낸다.
그리고 해당 IF.PC값과 IF.imm값을 저장해둔다. 
PCC에선 그 신호를 받고 현재 IF.PC값에 + 4 한 값을 NextPC로 출력한다. 

이 경우, BTB는 쓰이지 않는다. 

[ID단계]
명령어 해독 단계

[EX단계]
Branch의 prediction 실제 계산값이 나온다.
결과는 Taken. 
Branch Predictor에 EX.BTaken 신호가 입력된다. 

BP는 이를 토대로 misprediction을 감지해서 BP_Miss 신호를 Hazard Unit에 보낸다. 
그와 동시에 아까 IF에서 저장해두었던 기존 PC값과 imm 값을 계산하여 목적지 주소를 도출한다. 
계산된 분기 목적지 주소를 PCC에 넘겨준다.
PCC는 해당 B_Target 주소 입력을 NextPC값으로 출력한다. 

이러면 문제. PCC에서는 BTaken 신호가 참일 때만 B_Target입력을 NextPC로 선택했는데, 이 경우 Not Taken 즉 BTaken 신호가 거짓일 때도 B_Target 을 NextPC로 출력할 수 있어야한다. 
음,, 하긴 애초에 BTaken 신호는 EX단계의 Branch Logic이 보내는 신호이고 기존의 PCC로 입력되는 BTaken 신호는 B.EST 즉 분기 예측값으로 바꿨으니 상관 없다.
2비트로 해서 00을 no prediction, 01을 Not Taken, 10을 Taken으로 신호체계를 만들면 될 것 같다. 

BTB를 사용하는 경우, BTB가 업데이트 된다.

동시에 Hazard Unit에서는 BP_Miss 신호를 받아서 각 파이프라인 레지스터에 Flush 신호를 보내 무효화한다. 

그리고 본 구조상 EX단계에서 Branch의 예측값이 맞는지 아닌지를 알 수 있는데, 그 동안 진행되는 명령어 2 + 1개의 (EX단계에서 Branch의 참 거짓을 판단하고 결과를 반영하면 해당 EX단계에 있는 분기 명령어의 주솟값이 필요하므로.)
정보들이 저장될 공간이 필요하다. 3개 명령어 분량의 PC값에 대응되는 imm값을 저장해둘 수 있어야 하고 이를 레지스터로 구현해두면 좋을 것 같다. 
아니지. 어차피 Misprediction 때에만 해당 Misprediction된 명령어의 다음 주솟값을 계산하면 되니까 Misprediction을 알 수 있는 EX단계의 파이프라인 레지스터에서 PC값과 imm값을 같이 받아서 이걸 Branch Predictor에 주면 된다.
이러면 내부 저장공간을 둘 필요 없이 필요한 때에만 정보를 받아서 주솟값을 계산해 B_Target을 출력할 수 있다. 

이러면,, 좋았어. 분기 예측기의 설계가 마쳐진다. 

필요한 신호체계를 정리해보고, 밥먹으러 가야겠다.

## Branch Predictor (BP)
[입력신호]
CLK - 클럭신호
IF.opcode - 조건부 분기 명령어인지 확인하기 위함
IF.PC - 현재 PC 값을 기반으로 예측값 Not Taken시 다음 PC 값을 계산해서 PCC에 주기 위함. (BTB의 경우 갱신을 위해서도 사용 됨.)
IF.imm - 현재 PC 값을 기반으로 예측값 Taken시 분기 목적지를 계산해서 PCC에 주기 위함. 
EX.PC - Misprediction 시 해당 분기 명령어의 분기 목적지 또는 다음 명령어 주소 계산을 위해 필요.
EX.imm - 조건 분기 명령어 Misprediction시 분기 목적지 주소를 계산하기 위함.
EX.BTaken - 분기예측한 내용이 실제로 적중했는지 아닌지를 피드백받기 위함.

[출력신호]
B.EST - 분기를 예측한 정보를 PCC에 넘겨주기 위함.
B_Target - 예측한 분기 목적지 또는 다음 PC값 계산 결과를 PCC에 주기 위함.
BP_Miss - Misprediction시 해당 내용을 Hazard Unit에게 보내서 파이프라인 레지스터들의 데이터를 Flush하기 위함.

마찬가지로 PCC가 간접적인 영향을 받았으니 로직 및 신호들에 대한 정리를 같이 해보자.

PC Controller (PCC)
[입력신호]
CLK - 클럭신호
Trapped - Exception 또는 Trap 상황에서 해당 주소를 NextPC를 선택하기 위함.
PC_Stall - 메모리 접근 명령어시 메모리 접근이 끝나기 전까지 다른 명령어들을 Stall 하기 위함. 
(MEM단계일 텐데, 이 단계를 사용하지 않는 다른 명령어들을 수행하고 있으면 되지 않을까?)
EX.Jump - EX 단계에서 Jump의 목적지 연산이 가능한데, 해당 목적지 주소를 NextPC로 택하기 위한 Jump 식별 신호
B.EST - Branch Predictor에서 출력한 분기 예측 정보를 받아 B_Target 주소를 NextPC로 택하기 위한 Branch 식별 신호

B_Target - Branch Predictor에서 계산한 분기 목적지 주소 또는 다음 PC주소
IF.PC - 현재의 PC값. NextPC를 PC+4해서 주기 위함.
IF.T_Target - Trap은 Instruction Fetch단계에서 결정되는데, 해당 목적지 주소값.
EX.J_Target - EX단계에서 계산된 Jump 명령어의 목적지 주소

[출력신호]
NextPC - 조건에 따른 다음 PC 값 출력신호. 

변경사항. BP_Miss를 물론 Branch Predictor에서 해도 되긴 하지만 Branch Predictor는 IF 단계에서 작동하는 로직의 일률성이 어느정도 잡혀있기 때문에
BP_Miss 를 EX단계에서 ALUzero값과 바로 비교할 수 있는 Branch Logic에서 판단할 수 있도록 할 것이다. 
Branch Logic 모듈에서 BTaken을 판단하여 Branch Predictor에 넘겨줌과 동시에 
Branch Predictor에서 B.EST신호를 파이프라이닝해서 온 EX.B.EST신호를 Branch Logic 모듈에 연결해서 해당 BTaken 값과 비교해 Misprediction인지 판단한다.
그리고 Misprediction인지 아닌지를 BP_Miss신호로 Branch Logic에서 출력하여 Hazard Unit에게 전하는 것으로 변경했다. 

이렇게.. Branch Predictor의 설계를 마쳤다. 구현은 ChoiCube84가 현재의 RV32I43FC의 캐시 구조를 구현하고 나면 구현.. 해주겠지
벌써부터 디버깅에 머리가 아프다. Forward Unit에 대한 지금 Branch Predictor 수준의 설명을 기술하고 싶은데 으윽,, 밥도 굶었고 오후 집합 하고 나서 진행해야겠다. 
아니다 설계의 가속을 위하여 그 때 가서 수정하는 걸로 하자. 지금은 구현 이전 초안을 작성하는 데에 가까우니 시간을 최대한 아껴서 다음 단계로 넘어가자. 

다시 돌아온 캐시 문제. 정확히는 파이프라이닝 때문에 다시 보게 된 문제인데,
기존의 싱글사이클 구조를 보면, Write Done신호는 Control Unit의 입력으로 들어가, CU가 Data Cache의 쓰기/읽기 작업의 끝을 인지하면 PC값을 NextPC값으로 갱신하여 다음 명령어를 계속 실행하도록 한다. 
하지만 캐시구조를 개선하고 지적한계가 높아진 시점에서 다시 돌이켜봤을 때, 메모리 접근시 캐시→메모리 로의 쓰기와 메모리→캐시 로의 쓰기 두가지 상황이 모두 발생하게 된다.
캐시를 갱신하는데 필요한 데이터는 메모리에서 반환됨 과 동시에 넣어지게 되고, 위에 서술한 순서에 따라 두번 째 클럭에서 캐시가 갱신되게 된다. 
때문에 두번째 일 때 명령어가 바뀌게 되면 안되는데, 이를 인식하기 위한 Cache 에서의 WriteDone 신호가 필요하다. (Cache Ready 신호)
마찬가지로, 메모리 갱신의 경우 Cache Clean (Dirty 비트 해소 시퀀스를 Cache Clean이라 하자.) 이후 메모리에 쓰여질 데이터가 Write Buffer에 전달되는데, 
이 Write Buffer에서 메모리로 넘기는 시점이 2번째 클럭이기 때문에 그 전까지 명령어를 바뀌지 않게 하기 위한 식별 신호로서 WriteDone이 하나 더 필요하다 (Memory Ready 신호)

문제는 이 신호들의 파이프라이닝...
MEM 단계로 가서야., stall할지 안할지를 알 수 있는데,, 이를 어떻게 갱신하지 않고 그대로 둘 수 있을까...
파이프라인 레지스터에 별도로 뭔가를 둬야하나?
일단 MEM 단계에서 지연이 필요하다는 것을 IF단계의 PCC에서 알아야 다음 명령어 인출을 잠시 정지하고 대기할 수 있으니까.,
기존 싱글사이클 구조에서는 Control Unit에서 WriteDone 신호를 받아서 해당 경우를 판단하여 PC_Stall 신호를 PCC로 줬었는데,
파이프라인 구조의 Control Unit은 ID단계에서 작동하는 타이밍 일률성이 있다. 물론 MEM단계의 신호를 받아서 IF단으로 넘길수야 있겠지만은...
아 그래. Cache Ready, Memory Ready 신호를 Control Unit에 보내서, Control Unit에서 항상 PC_Stall 신호를 판단하여 PCC에 보내는 것으로 하면 될 것 같다.
Control Unit 자체는 조합논리회로로 별도의 파이프라인 특정 단계에서만 작동하지 않으니까 이건 타이밍 일률성을 굳이 살리지 않더라도 이렇게 하는게 맞는 것 같다. 
PCC의 목적은 어디까지나 조건에 따른 PC 주소의 '선택'이 주 목적이 되어야한다. 때문에 이러한 Write Done 신호들을 모두 모니터링하게끔 하는 것보다 
해당 역할을 Control Unit에 맡기고 PC_Stall 신호만 단순히 받아서 할 수 있도록 하면 될 것 같다. 

파이프라인 레지스터는 갱신되지 않는 이상 같은 값을 계속 유지하니까 상관 없을 것이다. 

무조건 분기에 대해서도 '조금'은 짚어야할 것 같은데,
Jump 명령어에서 jump 목적지를 계산하기 위해선 EX 단계까지 가야한다. 
이 때 PCC로 Jump 신호와 동시에 J_Target을 주는데, 이와 동시에 해당 EX 단계 이전 IF, ID 단계까지 수행된 명령어들의 데이터를 Flush해야한다 (해당 파이프라인 레지스터들)
(OoOE의 경우 끝까지 명령어를 실행해서 해당 수행된 결과 값을 따로 캐싱해 두고, 비순차적으로 수행할 수도 있긴 할텐데... 이건 나중에.)
해당 Flush를 위해서는 Hazard Unit에서 해줘야하는데, EX단계까지 파이프라이닝된 Jump신호를 Hazard Unit으로 넘기면 될 것 같다. 

됐다.... 14:51부로 RV64I59F_5SPH_FW_BP 아키텍처를 완성했다. 
아마 실제 구현 및 디버깅을 하면서 여러 문제들에 부딪혀 여러 수정소요를 발생시킬테지만, 그래도 일단 지금으로서는 이게 최선의 결과이다. 
포워딩 유닛에 대한 로직 정리를 하고 이만 파이프라인은 패스하고 다음 단계를 살펴봐야겠다. 

위 4월 1일에 적은 내용을 기반으로 최종안을 적겠다. 

데이터 해저드, 명령어들의 종속성에 따라 이전 명령어가 끝날 때 까지 현재 명령어를 중단시켜야하는 경우.
그렇다면 파이프라인에서 수행하는 명령어들 끼리의 종속성을 알 수 있으면 된다.
기본적으로 프로세서는 레지스터를 기반으로 처리를 하기 때문에 과거 처리되어 변경되어야 할 레지스터 주솟값이 현재 수행하고자 하는 명령어에서 참조하는 레지스터인지 확인하면 된다.
A 명령어의 rd, register destination의 주솟값이 다음 B 명령어의 rs1, rs2 즉 register source의 주솟값과 같은지 비교하면 된다. 
단, x0은 변하지 않는 0 값이므로 이 경우에는 전방전달을 하지 않아도 된다. 
instruction fetch를 거쳐야 decoding단계에서 비로소 rd, rs1, rs2의 주솟값이 나온니까 적어도 ID 단계에서 해당 내용을 알 수 있다. 

ALU에서는 srcA, srcB를 연산을 위해 사용하고 

srcA에는 RD1, PC, rs1
srcB에는 RD2, imm, imm(shamt), csrRD

총 7개의 요소를 갖고 연산을 한다. 
레지스터의 데이터가 처리할 리소스로 사용되고, 파이프라인 특성상 이 레지스터의 데이터가 이전 명령어에 의해 달라질 수 있으니 이를 기다려야하는 경우가 생긴다. 

이 기다리는 단계를 최소화하고자, 전방전달, Forwarding 이라는 방법이 있는 것이다. 
이를 통해 기존 1번 명령어의 데이터가 레지스터에 업데이트 되기 전, 해당 데이터를 현재 처리중인 2번 명령어의 ALUsrc로 적절히 전방으로 전달해주는 것이다.
그렇게 ALU는 전방전달된 데이터를 연산에 사용할 수 있다. 
이러면 ALUsrc MUX에서 나온 데이터 or 포워딩된 데이터 중 하나를 선택하는 MUX가 추가로 필요하다. 
포워딩된 데이터는 레지스터에 저장될 5가지 소스인 D_RD, ALUresult, CSR_RD, imm(LUI), PC+4가 해당된다.
즉 포워딩 해 줄 때 이러한 레지스터에 쓰여질 데이터 소스 중 하나를 처리하는 명령어에 맞게 포워딩을 해줘야한다.
포워딩 유닛은 hazardop로 데이터 해저드가 발생했음을 안다.
이를 기반으로 앞에서 처리 중인 명령어 A의 결과 (레지스터 파일에 결과적으로 쓰기되는, 이 경우 EX 혹은 MEM 단계일 것.)에 해당되는 데이터를 명령어 B의 유형에 맞게 EX 단계 ALUsrc중 하나로 적절히 전달한다.

해저드 탐지 유닛, 포워딩 유닛 이렇게 두개로 모듈을 나눠서 디자인했다.
해저드 탐지 유닛은 Instruction Decoding 단계에서 받은 rs1.A, rs2.A, rd.A 값을 저장하고, 다음 명령어에서 주어지는 rs1.B, rs2.B, rd.B 값과 비교한다.
rd.A가 rs1.B, rs2.B 중에 하나라도 동일할 경우, 데이터 해저드가 발생함을 포워딩 유닛에 hazardop 신호로 알린다. 

이 때 포워딩 유닛에서 필요한 신호는 다음과 같다.

[입력신호]
MEM.imm(LUI) - 	레지스터에 쓰여질 이미 실행중인 명령어의 결과 소스 중 하나이다. 
MEM.ALUresult - 레지스터에 쓰여질 이미 실행중인 명령어의 결과 소스 중 하나이다. 

기존 4월 1일에는 EX로 적긴했는데, 생각해보니 선행 명령어(A)가 MEM으로 넘어가고 후행 명령어(B)가 EX로 오면서 필요한 데이터인데
A가 EX단계에서 계산을 거친 신호는 결국 MEM 파이프라인 레지스터의 데이터이기에 시점 분류 자체는 그게 맞다. 
그리고 모듈에서 내놓는 신호보단 레지스터에서 다음 클럭 신호에 확실하게 내보내는 경우가 구조적으로 직관적이라 생각해서 MEM으로 정정했다.

MEM.CSR_RD - 	레지스터에 쓰여질 이미 실행중인 명령어의 결과 소스 중 하나이다. 
MEM.D_RD - 		레지스터에 쓰여질 이미 실행중인 명령어의 결과 소스 중 하나이다. 
MEM.PC+4 -	 	레지스터에 쓰여질 이미 실행중인 명령어의 결과 소스 중 하나이다. 
(EX.PC+4)

이건 디버깅을 하면서 알아야할 것 같긴한데, 지금 현재 포워딩의 전제 자체가 MEM단계에 있는 선행명령어(A)의 결과 데이터를
후행명령어(B)가 사용하기 위해서 EX단계로 넘겨주는 역할인데, 사실 이 취지라면 EX.PC+4가 아니라 MEM.ALUresult 아래에 적은 설명과 같은 맥락으로
MEM단계에서 PC+4를 해주는 것이 올바르다. 일단 MEM.PC+4로 수정했다. 

MEM.opcode - MEM단계 즉 선행 명령어(A)가 어떤 명령어인지 식별하여 포워딩할 데이터 소스를 선택하기 위한 신호.

[출력신호]
aluFW.srcA - 포워딩하기로 선택된 소스의 데이터 출력 신호이다. aluFW_MUX.A에 입력된다. 
aluFW.srcB - 포워딩하기로 선택된 소스의 데이터 출력 신호이다. aluFW_MUX.B에 입력된다. 

aluFW.A - 	aluFW_MUX.A의 선택 제어 신호이다. Hazardop를 통해 Forwarding이 필요할 경우 
			MEM.opcode를 기반으로 판단하여 ALUsrcA에 해당되는 연산종류의 데이터일 경우 aluFW.A를 포워딩된 데이터로 넣는다. 
			(RD1, PC, rs1)
aluFW.A - 	aluFW_MUX.B의 선택 제어 신호이다. Hazardop를 통해 Forwarding이 필요할 경우 
			MEM.opcode를 기반으로 판단하여 ALUsrcB에 해당되는 연산종류의 데이터일 경우 aluFW.B를 포워딩된 데이터로 넣는다. 
			(RD2, imm, imm(shamt), CSR_RD)
			
이제 Hazard Unit의 구체화. 
[입력신호]
BP_Miss - 	Branch Predictor의 분기 예측이 실패했을 때 EX.Branch Logic으로부터 신호를 받아 flush를 결정한다.
EX.JMP 	- 	EX단계의 Jump신호를 받아 flush를 결정한다. 
ID.rs1	-	ID단계의 후행명령어(B)의 rs1 신호를 받아 기록해둔다.
ID.rs2	-	ID단계의 후행명령어(B)의 rs2 신호를 받아 기록해둔다. 
ID.rd	-	ID단계의 선행명령어(A)의 rd 신호를 받아 기록해둔다. 

[출력신호]
IF/ID.flush	-	IF/ID 파이프라인 레지스터를 flush(무효화, 클리어, 초기화)한다.
ID/EX.flush	-	ID/EX 파이프라인 레지스터를 flush(무효화, 클리어, 초기화)한다.
EX/MEM.flush -	EX/MEM 파이프라인 레지스터를 flush(무효화, 클리어, 초기화)한다.
MEM/WB.flush -	MEM/WB 파이프라인 레지스터를 flush(무효화, 클리어, 초기화)한다.
Hazardop	-	기록된 선행명령어(A)의 rd 신호의 값과 후행명령어(B)의 rs1, rs2값을 비교한다.
				rd.A의 레지스터 번호가 rs1.B, rs2.B와 같은지 판단한다. 
				같다면 종속성이 있다고 보고 Hazardop를 발생시켜 Forward Unit에 출력한다. 
				
좋았어. 이로서 파이프라인 구조의 기초적인 설계와 로직 고안을 마쳤다. 

다음은 M, A확장의 이해와 듀얼코어 확장, 운영체제를 올리기 위한 요건들 확인, GUI 구현 및 I/O 구현 이해이다.

지금은 여기까지. 이제 연등시간에 확장할 것들의 우선순위를 선정하고 그에 맞게 프로젝트 계획을 다시 정비해봐야겠다. 

수고했다 내 자신! 더 열심히 해보자! (20:40)

-----연등시간-----
쨔스. 연등시간.

현재 64비트 5단계 파이프라이닝까지 초안 설계를 마친 상황이다. 로드라인을 점검해보자.

RV32I (basic_rv32s)
RV32I37F, 43F, 43FC, 47NF ( 기본 RV32I 명령어 지원, 캐시 지원, 디버거 environment 명령어 지원, CSR 지원 )

RV64I
RV64I59F, RV64I59F_5SPH ( RV32I 기반 64-bit 확장, 5단계 파이프라인 지원, 분기 예측기 지원, 포워딩 지원 )

--여기까지--
## 이제 남은 확장들.
ⓐ "M"확장
ⓑ "A"확장
ⓒ 운영체제 준비
  ├ RISC-V Privileged Architecture Supervisor mode까지 구현 (Machine, User, Supervisor)
  ├ GUI 구현
  ├ GPIO, MMIO 구현 이해 
  ├ 가상메모리 구현
  └ RISC-V Linux 커널 구조 이해 및 이식
ⓓ 듀얼코어 구조
ⓔ 다층 캐시 구조
ⓕ DDR3 SDRAM 통합 메인 메모리 구현
ⓖ RVWMO 이해 및 구현
ⓗ CMO 구현
ⓘ FPGA 구현 및 검증

이게 사실 운영체제를 올릴 수 있는 RISC-V 프로세서를 만드는 것이 달성하고자 하는 목표라,,
AMD K6-III을 벤치마킹 했을 때 듀얼코어 구조 까지는 운영체제를 굴리는 데에 있어서는 필요하지 않다..

일단 해당목표 최단기간 달성을 위한 중요도를 기준으로 설계 순서를 배열해보자

------
단일 코어에서도 인터럽트나 데드락 방지 등 동시성 제어가 필요한 부분에서 원자적 연산을 활용하기 때문에 A 확장은 필요하다.

1. "A"확장
2. "M"확장
3. 운영체제 준비
   ├ Supervisor Privileged ISA 구현. (Supervisor mode, User Mode)
   ├ Trap/Exception/Interrupt 처리, CSR, 타이머, 인터럽트 컨트롤러 (PLIC/CLINT) 구현
   ├ Sv39, Sv48; 가상메모리, MMU 구현
   ├ GPIO, MMIO, 기본 디바이스 접근
   └ RISC-V Linux Kernel 구조 파악 및 이식 (커널 config, Device Tree, Boot loader, OpenSBI, )
4. DDR3 SDRAM 통합 메인 메모리 구현
5. FPGA 구현 및 검증 
6. GUI 구현

나머지 다층 캐시 구조, 듀얼코어, RVWMO, CMO는 추후 구현 과제로 남겨둬야한다. 
GUI도 빠듯하다. 시간이 여유있으면 가능한데,,

이제부터 할 것은 MA 확장을 더하고, 운영체제를 준비하는 것이다. 
이미 구매하여 도착했긴 했지만 FPGA보드를 이용하는 건 꽤나 뒤의 일일 듯.
아마 4월 후반기 즈음에 MA 설계하고 얼추 감 잡히지 않을까? 
FPGA구현을 마무리로 할지, 운영체제 구현하고 FPGA로 이식할지. 

뭐 어찌됐건 잘 해보자.
오늘은 여기까지.

# [2025.04.10. ]
IDEC에 Synopsys VCS/verdi 교육받으러 왔다. VCS는 킹이다.
여태까지 수기로 각각의 데이터패스들을 검증하고, 관련된 구조가 변경되면 변경된대로 또 처음부터 다시 하나하나 하고 그랬어야 했는데 이제는 그게 아니라 
단순히 모듈과 그 신호들을 기술한 Verilog 파일을 넣으면 시뮬레이션이랑 verdi를 이용한 디버깅을 모두 해낼 수 있다. 
와!

일단 계속해서 듣고 있다. 1교시는 끝났고,, 강의 노트도 따로 만들었다. 

# [2025.04.11. ]
VCS 강의가 끝나고 현재 만든 CPU 소스코드를 VCS, Verdi에 올려서 schematic이나 디버깅 이식을 해보고 싶었다. 
관련해서 솔직히 어떻게 해야할지 감조차 안잡혀서 강의해주신 Synopsys분께 여쭤봤고, 도와주셨다. 
몇 가지 알게 된 점이, 사용하는 컴파일러, 툴에 따라서 소스코드의 형태가 조금 달라진다.
여태 우리는 iVerilog를 사용해서 해당 폴더 안에서 명령어를 통해 한번에 tb까지 했는데, include문에서 VCS쪽은 경로 지정이 다른 것 같다.
이 문제로 컴파일링 오류가 계속 떠서 함께 고민해주셨고, 이게 문제라는 것을 알 때까진 시간이 조금 필요했다.
모듈파일과 tb파일 리스트를 한번에 작성하는데, 생각보다 많은 이식작업이 필요했다. iverilog에서는 컴파일에서 문법이라던가 문제 없는 최신본이었는데, 
VCS로 이식하니까 파일 경로 문제를 해결했더니 자세히는 보기 힘든 여러 에러들이 뜨기 시작했다. 
물론 iverilog도 나름 꽤 쓰이는 컴파일러이기도 하고, 제대로 작동하는 것을 vcd파일로 확인까지 했으니 코드에 큰 문제는 없겠지만 아마 VCS로 이식하는데에 있어서 상당한 시간이 소요될 것으로 보인다.
하지만 그럴 가치는 충분하다. 지금까지 수기로 해야하는 작업들을 자동화할 수 있고 훨씬 더 직관적인 환경에서 검증과 디버깅을 할 수 있는데, 매우 강력한 도구니까.

Synopsys 직원분이셨던 것 같은데, 진행중인 프로젝트에 대해서 꽤나 좋게 봐주신 것 같다. 
옛날 컴퓨터 구조론 책에서 제안하는 별도의 ISA를 기반으로 모사? 모아? 라는 CPU를 직접 설계해보신 적이 있다고 하신다.
지금 우리가 만드는 RISC-V 기반 범용 프로세서 타깃은 아니긴 하지만, 기특하게 봐주셨다. 
맘 같아서는 KAIST N26 IDEC 실습실에서 어느정도 이식을 해보고 스키매틱 생성까지 띄우고 가고 싶었는데, 시간 압박이 꽤 있던 관계로 거기까지만 하게 되었다.
정말 뜻 깊고 유익했던 강의였다. 

# [2025.04.12. ]
휴가에서 복귀했다... VCS를 위해서 local-system에 Fedora를 설치하고, 윈도우까지 해서 듀얼 OS로 했다.
웬만해서는 페도라 하나로 FPGA까지 다 하고 싶었는데, 사용하고자 하는 Xillinx 제품군의 Vivado가 Windows에 최적화되어있어 듀얼 OS를 선택했다.
한 가지 실수한 것이, 개발 툴이 잡아먹을 용량을 생각하지 않고 로컬 시스템을 256GB의 저장공간으로 맞추었다. 
OS 두개로 나눠서 각각 128GB씩 준 것 자체로도 용량이 조금 불안한데, Xillinx 개발 툴들 설치하는데 있어서 용량 제한이 많이 걸리는 것을 확인했다.
덕분에 쓸데 없는 옵션들까지 뭔지 하나하나 다 확인하고 정말 나에게 필요한 개발 키트만 선별해서 설치할 수 있었긴 했지만..
문제점이 생겼다.. VCS를 군대에서 local-system이 있다고 해도 못 돌릴 수 있다는 것...
교수님께 여쭤보니 Synopsys 라이센스를 학교에서 지원하지만, 이를 사용하기 위해서는 학교 안에서만 사용가능하다고 한다.
VCS의 설치를 위해서 solvnet 회원가입이라도 하려고 했더니 이마저도 별도의 ID키를 써야하는데 이게 라이센스와 관련이 있기도 하고 여쭤본 교수님께서는 답변이 조금 어려운 부분이라 하셔서 
일단은.,., VCS 사용은 보류되어야할 것 같다... POSTECH쪽에서는 라이센스 활용이 아마 VPN을 지원해주는 것으로 알고 있어서 가능할 수도 있을 것 같은데 한번 ChoiCube84한테 물어봐야겠다. 

내일부터 해야할 것들을 정리해보자. 
1, FPGA 검증 초기 셋팅 해보기
2, "A"확장 공부하기
3, 가상메모리 공부하기
이하 25.04.07 로드라인 예정과 동일

휴가 복귀 출발 전에 Xillinx 다 설치해뒀는데 듀얼 OS 부팅이 복귀 1시간 전에 꼬여서 아까 22:40분 경에 드라이버 설정이 겨우 끝났다.
USB모뎀이 150Mbps라는데 실제로는 5MB/s 나오면 다행인 수준.. 갑자기 인터넷은 왜 꼴아박았는지 속도도 이상하다
일단 Xllinx 설치 켜두고 내일 아침에 다시 와서 써야겠다.

오늘은 여기까지.

# [2025.04.13. ]
## "A" 확장에 대해서 살펴보았다. 
Zaamo AMO 명령어에 대한 것들인데 우려했던 것들 보단 A확장이 꽤 수월하게 이뤄질 것 같다. 약간 SIMD와 유사한 느낌들이다. 한 명령어에 여러 수행이 담겨있다. 
공통적으로 R[rd] <- R[rs1]  을 수행하며, 
R[rs1] <- Binary Operated R[rs1] and R[rs2] 가 동반된다.
여기서 Binary Operation은 Zaamo 명령어들을 살펴보면 단서를 찾을 수 있는데, 다음과 같다.
amo'swap'.W/D
amo'add'.W/D
amo'and'.W/D
amo'or'.W/D
amo'xor'.W/D
amo'max[u]'.W/D
amo'min[u]'.W/D

즉 swap, ADD, AND, OR, XOR, MAX, MAX_unsigned, MIN, MIN_unsigned 이 9가지의 이진 연산을 각 명령어가 쓰인 바에 따라 수행하는 것이다. 

AMOADD.W 명령어를 수행했다면, AMOADD.W rd, rs2, rs1 이렇게 사용된다.
그리고 이는 이러한 동작을 수행한다.
R[rd] <-  M[rs1]
M[rs1] <- M[rs1] + R[rs2]

R[rd]에 M[rs1]이 먼저 쓰여지고, 쓰여진 M[rs1]에 기존의 M[rs1]값 + R[rs2]값이 쓰여지는 순서를 따른다. 

RV64 기준 double word(64-bit data)가 가능하다. 
또한 RV64에서 32-bit AMO 명령어들은(word 단위) 항상 R[rd]에 쓰여지는 값(원래 M[rs1]에 해당되는 값)을 Sign-extension하고 R[rs2] 원본 값(M[rs1]과 이진 연산을 수행하는 값)의 상위 32를 무시한다. 

여전히 모르겠는 두 가지...
1. 이 AMO 연산이 어떻게 다중 코어 구조에서 역할을 맡길 때 중요한건지.
2. Load Reserved / Store Conditional 이 무슨 의미인지. 


# [2025.04.14. ]
"A" 확장에 대해 추가적인 공부.
## A 확장의 명령어는 두가지 종류로 구분된다. Zalrsc, Zaamo.
Zalrs는 Z, Atomic; Load Reserved, Store Conditional.
Zaamo는 Z, Atomic; Atomic Memory Operation.

Zalrsc확장에서 A 확장의 근간인 reservation에 대한 내용이 나온다. 
LR.W명령어와 SC.W 명령어 (RV64시 Double word 가능. LR.D, SC.D)로 나뉘는데,
## Load Reserved의 수행은 다음과 같다.

1.지정된 메모리 주소에서 워드를 읽어오면서, 해당 주소를 "예약(Reservation)" 상태로 표시해둔다.

2.R[rd] <- M[rs1]

3.동시에 앞서 1번에서 예약상태로 표시해둔 그 주소의 정보를 기록해둬 이후 SC.W 명령어가 나올 때 까지 해당 주소가 다른 hart에 의해 변경되지 않았는지 추적.

결론 : R[rd] = MEM[rs1], rs1 주소에 대해 "예약"표시

------

## Store Conditional의 수행은 다음과 같다.
앞서 LR.W로 예약한 주소에 새 값을 쓴다.

1.R[rs1] <- R[rs2] 이걸 수행하는데,
만약, LR.W이후 예약이 깨지지 않았다면 (해당 주소의 데이터가 다른 hart에 의해 변경되지 않았다면) 저장이 성공한다. 
만약, LR.W이후 예약이 깨졌다면 (해당 주소의 데이터가 다른 hart에 의해 변경, 갱신되었다면) 저장이 실패한다.
1.1 저장성공시 R[rd] <- 0
1.2 저장실패시 R[rd] <- 1 (이 경우 실제 메모리에 쓰기는 일어나지 않는다.)

그리고 이러한 예약을 위해서 보통 예약 주소에 대한 내용을 담는 레지스터를 구현해둔다. 또는 캐시에 연동해서 캐시 라인 단위로 추적할 수 있다. 

결론 : 
1. 예약 유효 검사
1.1. 유효시 : M[rs1] = R[rs2], R[rd] = 0
1.2. 무효시 : R[rd] = 1

-----

"A"확장의 명령어들은 26:25 각 1비트마다 각각 aq, rl 비트로서 사용된다. 
aq(aquire), rl(release). 두 비트는 메모리 순서(Memory Ordering)를 제어하기 위해 사용된다. 

aq 비트 set된 명령어는 그 명령어의 완료까지 hart가 기다리고 다음 명령어들을 수행할 수 있도록 해야한다. 

rl비트 set된 명령어는 그 명령어의 수행 이전까지 모든 메모리 접근 명령어가 완료될 때까지 hart가 기다리고, 이후에 해당 rl비트 set된 명령어를 수행할 수 있도록 해야한다. 

기존에 메모리에서 데이터를 읽어오기 위해 2사이클을 기다리며 읽기 완료 신호 전 까지 해당 명령어를 유지하도록 한 이 기능적인 구현이 어느정도 aq비트가 set됐을 때 해당 aq비트를 set한 명령어가 수행 완료되기 전까지 계속 수행해야한다는 점과 비슷하다. 이에 착안해서 비슷하게 구현하면 될 것 같다. 

-----

## ChoiCube84 와 데이터 캐시-메모리 구조에 대한 회의
1. 캐시보다 메모리 커야하지 않아요? 
 네 맞음. 

저희 FPGA 보드에서는 512MB DDR3 SDRAM 쓸거긴 한데, 1MB로 지금 당장 구현해도 상관 없음.
용량 상관 없이 일단 캐시보다 크게 구현해봅시다.

2. 주소 체계는 어떡하죠?
 지금은 메모리 용량만큼만합시다.

이 내용을 해당 아키텍처 specification에 명시 하고 추후 Excpetion Detector 만들어지면 별도의 Exception을 발생시켜야할 것 같아요.
그 안에 AMD K6-III나 비슷한 CPU들 메커니즘 레퍼런스잡아서 연구해볼게요. 걔네들도 이걸 고민했을거임.
결론적으로 현재 쓸 메모리 용량만큼만 주소 비트를 쓰면 됩니다. (지금만)

3. 캐시-메모리 블럭단위 통신?
해야함.

메모리→캐시 : 블럭단위
캐시→WriteBuffer→메모리 : 워드 단위
일단 캐시-메모리의 통신은 블럭단위로 되어야합니다. 

# [2025.04.15. ]
## ChoiChube84 Issue
01. Data Memory testbench에서 vvp 명령어하는데 프리징 걸리고 dead.
KHWL : 메모리 512MB로 한게 원인같다. 1MB로 줄여서 다시 해봐라.
CC84 : 그것보단 아마 출력 폭을 31:0에서 255:0으로 늘려서 그런 것 같다.
----일단 1MB로 줄여서 하라고 함----
CC84 : 1MB 줄이니까 됨!
KHWL : Nice.

02. 우리의 메모리가 SDR에서 32B 데이터를 갖고 오기 위해서 어떤 과정을 거쳐야하는가?
KHWL : 워드 데이터만큼 SDRAM에서 출력할 수 있다. 현재 32-bit word고, 32B를 위해서는 8번의 출력이 필요한 셈.
CC84 : 그럴거면 그냥 한 블록을 32-bit로 하면 안되나? 너무 비효율적인 것 같다. 
KHWL : 32비트 (4바이트) -> 32바이트 -> 8사이클 맞는데, 이렇게 사용될 수 있는 데이터들을 지역성의 원리에 따라 인접한 데이터들을 로드해두는거라 의미는 당연히 있다.
전체 수행시간은 우리가 정해진 프로그램이라면 (임베디드, ASIC) 동일하니 이런 구조를 하면 안되겠지만 여러 다른 프로그램들을 돌리는 범용 입장에서는 적어도 그 컴플레인에 의미가 크게 없다.
전체 수행시간이 프로그램별로 다르고 해당 프로그램이 지역성을 얼마나 쓰느냐도 다르기 때문. 
막말로 한 뱅크에 8개 담을 수 있는거랑 1개만 담을 수 있다고 하면 후자는 매번 갱신해야하는 반면 전자는 한번 로드 이후 계속 그 안에서 Cache hit이다. 

03. 그럼 Way 늘리는게 좋지 않을까?
KHWL : ㅎㅎ.. 맞긴 한데 우리는 일단 레퍼런스 삼은 AMD K6-III CPU를 벤치마킹해서 L1$를 2-way로 했다. L2로 가서 통합 캐시에서 더 늘리자.
당연히 way랑 용량 늘릴 수록 좋은데 그렇게 안하는 이유는 비용이랑 면적문제도 있겠지만 우리는 지금 학술 목적이기도 하고 그에 준하는 레퍼런스만 따라도 충분해서 그렇다. 

오늘은 일과가 19:30 언저리에 끝나서 별 다른 공부를 많이 하지 못했다.
하지만 그래도 유의미한 회의를 거치기도 헀고 A확장에 대해 쓰지 못한 로그들을 쓰면서 다시 한번 복습할 수 있었다. 

내일 할 거 : A확장 Zaamo 확장 정리 및 A 추가 명령어 확장들 살펴보기
컴퓨터 구조론 가상 메모리/ 페이징 공부하기.
Sv48 가상 메모리 관련 알아보기.

현재 로드라인 : 6월까지 최대한 로드라인 수행. 
5월 말 FPGA 이식 교육 후 6월 초 해당 시점 까지 개발된 것을 끝으로 해당 시점 설계를 기반하여 FPGA 이식을 시작.

사실, 운영체제 굴리는게 더 중요하지 않나? 맞긴 한데
논리 단계가 아니라 '실제로' 구현 가능한 구조인지가 더 큰 필수 과제여서 이렇게 잡았다. 뭐가 어찌되었던 프로젝트를 '완수'하는 것이 중요하기 때문이다. 그걸로 결과를 내어 목적을 이루는 것. 

## 남은 로드라인: 

~ RV32I43FC 구현 진행 중 (캐시 및 메모리 구조 구현 중)
~ RV32I47NF 구현 진행 중 (Exception Detector, Trap Controller, Debug Interface 설계 완료, 구현 대기 중)
~ RV64 확장 (설계 완료, 구현 대기 중)
~ 5 단계 파이프라인 확장 (설계 완료, 구현 대기 중)
① "A"확장 (설계 진행 중)
② "M"확장 (설계 완료(변경사항 없음) 구현 사실상 큰 시간 대기 없을 예정.)

③ 운영체제 준비
   ├ Supervisor Privileged ISA 구현. (Supervisor mode, User Mode)
   ├ Trap/Exception/Interrupt 처리, CSR, 타이머, 인터럽트 컨트롤러 (PLIC/CLINT) 구현
   ├ Sv39, Sv48; 가상메모리, MMU 구현 (공부중)
   ├ GPIO, MMIO, 기본 디바이스 접근
   └ RISC-V Linux Kernel 구조 파악 및 이식 (커널 config, Device Tree, Boot loader, OpenSBI, )
④ DDR3 SDRAM 통합 메인 메모리 구현
⑤ FPGA 구현 및 검증 
⑥ GUI 구현

RV64IMA109 및 가상메모리, MMIO 구현을 마치고 바로 백엔드로 투입 예정이다. 이 이상부터는 구현과 시간 거리가 너무 커지기도 하고 그 다음단계들을 위해 다른 계열의 공부를 여럿 해야하기 때문이다. 

오늘은 여기까지. 

# [2025.04.16. ]
오전에는 A확장에서 추가로 파생되는 Zawrs(Z; Atomic, Wait-on-Reservation-Set instructions), Zacas(Z; Atomic, Compare And Swap) 확장을 살펴보았다.
Zawrs는 저전력 모드에 들어가서 (대기 모드 비슷한..) 폴링 루프를 할 때 쓰이는 일종의 명령어를 위한 확장이고,
Zacas는 Quadward(128-bit)까지 지원하는 조건 스왑 명령어를 지원하는 확장이다.
Zawrs는 알아만 두면 될 것 같고, Zacas는 한번 매뉴얼을 정독해봐야겠다.

오후, 군대에서 중대 단결활동으로 영외 헤이리 마을에 나들이를 나갔다. 
차 안에서 읽기 위해 컴퓨터 구조 및 설계 책을 가져갔었는데, 카페에 장시간 있게 되어 정말 좋은 시간을 보낼 수 있었다. 
일단 가상 메모리에 대해서 어느정도 감을 잡았는데, 프로그램 메모리 관리 및 접근을 위한 일종의 캐시와도 같은 느낌이다.
차이점이라 함은 캐시는 직접적인 명령어, 데이터들의 물리적 접근 최적화 방식이라면, 가상 페이징;가상 메모리는 프로그램을 하드웨어와 운영체제에서 단순하고 원활하게 더 높은 성능으로 구동하기 위해서
캐시와 엇비슷한 무언가를 만들어냈다는 것이다. 그리고 가상페이징 방식에서 캐시 또한 같이 쓴다. 

1회독 느낌이라 정확하게 모든 내용을 이해하지는 못했지만 갈 수록 이해하게 될 것 같은 느낌이다. 
TLB.. 등등.. 일단 이 부분은 나중에 추가적으로 공부하도록 하고, A확장 구현에 먼저 힘써보자.

일단 연등시간이 시작되면 M확장이 현재 RV64I59F 설계에서 구조적 변경 없이 그대로 구현 가능한지 살펴보고 M확장을 확정 지어야한다.
그리고 A 확장 구현의 시작!

잘 해보자. 일단은 여기까지. 

--연등시간--

## 자. M 확장부터 확인해보자.

M instructions..
[R-Type]
mul, mulh, mulhsu, mulhu, div, divu, dviuw, remw, remuw

R-Type만 존재하는 것 같다. 각 instruciton 별로 MNEMONICS를 만들어보자. 

XLEN-bit × XLEN-bit
MUL : R[rd] = (R[rs1] × R[rs2]) [XLEN-1:0]
MULH : R[rd] = (R[rs1] × R[rs2]) [2×XLEN-1:XLEN] (Signed × Signed)
MULHU : R[rd] = (R[rs1] × R[rs2]) [2×XLEN-1:XLEN] (Unsigned × Unsigned)
MULHSU : R[rd] = (R[rs1] × R[rs2]) [2×XLEN-1:XLEN] (Signed × Unsigned)
MULW : R[rd] = {32'bM[](31), {R[rs1](31:0) × R[rs2](31:0)} [31:0]}

DIV : R[rd] = R[rs1] ÷ R[rs2] (Signed)
DIVU : R[rd] = R[rs1] ÷ R[rs2] (Unsigned)
DIVW(RV64) : R[rd] = (R[rs1](31:0) ÷ R[rs2](31:0)) 
└ 결과 32-bit 값을 64-bit 로 Sign-Extension하여 R[rd]에 쓰기.
DIVUW(RV64) : R[rd] = {32'b0, R[rs1](31:0) ÷ R[rs2](31:0)} 
└ 결과 32-bit 값을 64-bit로 zero-extension하여 R[rd]에 쓰기.

REM 연산은 modulo 연산으로, A % B = C 연산에 해당한다. 
A를 B로 나누어 나온 나머지 C이다.

REM : R[rd] = R[rs1] % R[rs2] (Signed)
REMU : R[rd] = R[rs1] % R[rs2] (Unsigned)
REMW(RV64) : R[rd] = {32'bM[](31), {R[rs1](31:0) % R[rs2](31:0)} [31:0]}
└ 결과 32-bit 값을 64-bit 로 Sign-Extension하여 R[rd]에 쓰기.
REMUW(RV64) : R[rd] = {32'b0, {R[rs1](31:0) % R[rs2](31:0)} [31:0]}
└ 결과 32-bit 값을 64-bit로 zero-extension하여 R[rd]에 쓰기.

전체적으로 ALU자체의 코드를 변경하고, ALU Controller에 있는 ALUop들을 손보기만 하면 될 것 같다.
M확장은 RV64I59F 설계에 구조적인 변경 없이 확장할 수 있다. 
## 좋아 이제 "A"확장을 설계해보자. 

------ A Extension MNEMONICS ------

Zalrsc Extension : Z, Atomic; Load Reserved / Store Conditional Extension
LR.W : R[rd] = M[R[rs1]], 
R[rs1] 데이터 값(1에서 쓰인 메모리의 주솟값임.)에 예약(reservation) 설정.

SC.W : 
if Reservation is valid, M[R[rs1]] = R[rs2], R[rd] = 0
if Reservation is invalid, R[rd] = 1

Zaamo Extension : Z, Atomic; Atomic Memory Operation

AMOSWAP.W : R[rd] = M[R[rs1]], M[R[rs1]] = R[rs2]
(기존 값 M[R[rs1]]을 R[rd]에 넣고, rs2를 메모리에 쓴다(교환))

AMOADD.W : R[rd] = M[R[rs1]], M[R[rs1]] = M[R[rs1]] + R[rs2]
(기존 값 M[R[rs1]]을 R[rd]에 넣고, rs2를 기존 값과 더하여 쓴다. )

AMOXOR.W : R[rd] = M[R[rs1]], M[R[rs1]] = M[R[rs1]] ^ R[rs2]
AMOAND.W : R[rd] = M[R[rs1]], M[R[rs1]] = M[R[rs1]] & R[rs2]
AMOOR.W : R[rd] = M[R[rs1]], M[R[rs1]] = M[R[rs1]] | R[rs2]

┌ 비교는 Signed로 진행한다.
AMOMIN.W : R[rd] = M[R[rs1]], 
if (M[R[rs1]] < R[rs2]), M[R[rs1]] = M[R[rs1]].
else M[R[rs1]] = R[rs2]

┌ 비교는 Signed로 진행한다.
AMOMAX.W : R[rd] = M[R[rs1]], 
if (M[R[rs1]] > R[rs2]), M[R[rs1]] = M[R[rs1]].
else M[R[rs1]] = R[rs2]

AMOMINU.W : R[rd] = M[R[rs1]], 
if ((Unsigned) M[R[rs1]] < (Unsigned)R[rs2]), M[R[rs1]] = M[R[rs1]].
else M[R[rs1]] = R[rs2]

AMOMAXU.W : R[rd] = M[R[rs1]], 
if ((Unsigned) M[R[rs1]] > (Unsigned)R[rs2]), M[R[rs1]] = M[R[rs1]].
else M[R[rs1]] = R[rs2]

오늘은 여기까지. 좀 더 고찰해봐야겠다. 아 내일은 당직인데.,. 믕... 가상페이징 공부해야겠다. 

# [2025.04.17.]
당직근무 간 공부하며 정리했던 내용을 기록하겠다. 

## **가상 메모리**

가상메모리를 사용하는 이유 
1. 다수의 프로그램 동시 수행 시 효과적인 메모리 공유
-> 제한된 크기의 메인 메모리에서 프로그래밍 해야하는 제약을 제거.

공유된 메모리를 사용하는 VM들이 있다고 가정 할 때.
가상머신이 각자의 프로세스가 보호될 수 있도록 보장하여야한다.
이 말인 즉슨 각 프로그램이 자신에게 할당된 메인 메모리의 부분에만 R/W (Read/Write ; 읽기 쓰기)가 보장되어야 한다는 것이다. 

가상메모리는, 프로그램 주소공간을 실제 주소(Physical Address)로 변환시켜준다.

> 메모리를 공유하는 VM은 VM들이 수행되는 동안 동적으로 변화한다.
>> 동적 상호작용 : 각 프로그램들만의 주소공간에서 컴파일 되어야한다. 
---> 해당 프로그램으로만 접근 가능한 분리된 메모리 영역이 있어야 한다.
= 변환 과정이 한 프로그램의 주소 공간을 다른 가상 머신으로부터 보호할 수 있다. 

2. 사용자 프로그램을 메인메모리의 크기보다 더 크게 작성할 수 있도록 해준다. 
-> 가상 메모리는 자동으로 메인 메모리와 2차 기억 장치로 구성되는 두 단계의 메모리 계층을 관리한다. 

캐시와 유사한 성질을 지니지만, 용어로서 구분 차이를 둔다.

[메모리 블록] : 메모리와 통신하는 규격
캐시		= 캐시 라인, 캐시 블록
가상메모리   = 페이지

가상메모리 실패는 페이지 부재 (Page Fault) 라고 부른다.

가상 메모리를 지원하는 프로세서는, 가상 주소(Virtual Address)를 생성한다.
그리고 이를 실제 주소(Physical Address)로 변환하는데, 이를 주소 사상(Address Mapping) 또는 주소 변환(Address Translation)이라고 부른다.
보통 Address Translation이라고 부르는 듯 하다. (Translation Lookaside Buffer; TLB 같은거)

이 "실제주소"는 HW, SW 조합에 의해서 메인 메모리 접근에 사용되는 주소이다. 

----------

가상메모리 - 재배치 (relocation) : 수행될 프로그램 Load를 단순화한다.
프로그램에 의해 사용되는 가상주소를 "메모리에 접근하는데 사용되기 이전에" 다른 실제 주소로 사상시켜준다.
-> 메인 메모리 내 어떤 위치에도 프로그램을 Load할 수 있게 해준다.

현대 에서는 프로그램을 고정된 크기로 이루어진 블록(페이지)의 집합으로 재배치한다.
= 프로그램을 할당하기 위해 메모리에서 연속적인 블록을 찾을 필요 없고, OS가 메인 메모리 내에 충분한 페이지가 있음만을 확인하면 된다. 

# [2025.04.18.]

## 캐시 구조에 대한 변경.

데이터 읽기, Cache Miss, Dirty Bit의 경우.

요청된 데이터는 SAA에 따라 메모리에서 인출되었지만,
캐시의 갱신을 위하여 여전히 메모리에서 데이터 출력이 이루어지고 있어야한다. 
캐시의 갱신에 사용될 주솟값 또한 계속 이루어지고 있어야하므로 PC_Stall 상황이 요구된다.

Dirty Bit를 CLK1에서 갱신하고, CLK2에서 Clean된 해당 블럭에 CLK1에서 인출된 데이터 메모리의 데이터로 갱신해야한다. 
즉, Cache에 쓰기가 다 될 때 까지 PC_Stall 되어야하는 것.
캐시에 쓰기 작업이 끝나는 것은 CLK2. 캐시만이 쓰기가 다 끝났다는 것을 제일 먼저 앎으로, Cache에서 Write_Done신호가 추가됐다.

RV32I43FC에서 Write Buffer에 대한 내용이 다이어그램에 누락되어있어 RV32I43FC.R2로 리비전하며 Write Buffer를 추가했다. 
동시에 위에 있던 변경사항인 DC_WriteDone신호도 Data Cache에 추가하였다. 

RV64I59F_5SP에도 반영했다.

A확장을 살펴보면서,, 

이미 두 사이클 이상 걸리는 명령어의 경우 Control Unit과 Cache 또는 Memory의 Ready 신호를 통해서 파이프라인을 정지시키거나 하여
현재 해당 메모리 수행이 완전히 마쳐질 때 까지 명령어 갱신을 하지 않고 기다리도록 설계했었다.

AMO연산 또한 이에 초점이 맞춰져있는데, 멀티 코어 구조가 아니고서야 이보다 더 복잡하게 구현해야할 내용은 없어보인다.

기존의 구조를 대부분 유지할 수 있을 것 같은데, 문제는 Zaamo가 아닌 Zalrsc.
이 Reservation이라는 내용에 대해서 아직 온전히 이해는 못했다.
각 명령어의 수행을 위해 aq비트, rl 비트 set시 필요한 동작들은 이해했지만 LR.w, SC.w 명령어가...

내일 할 거 : Reservation에 대한 내용 공부

# [2025.04.21.]
당직이었다. 19일 20일은 외박으로 절권도 세미나를 갔다 왔고, 21일은 당직이었던..
당직동안 원래 가상 메모리에 대해서 조금 더 연구를 해보려고 했지만 무릎 골절로 인해서 체력이 많이 바닥난 상태였기에 A 확장의 설계 구현을 다뤘다. 

이해하기 쉬운 Zaamo 확장의 구현부터 다뤘다. 

## Zaamo를 위한 추가 설계 요소
1. ALUresult가 Memory로 출력되는 데이터  패스가 없다.
Zaamo의 대다수 명령어 수행은 다음과 같은 형태를 따른다.
R[rd] ← M[R[rs1]]
M[R[rs1]] ← M[R[rs1]] bit operation with R[rs2]

이 경우, bit operation은 ALU에서 진행되는데, R[rs2]값인 RD2 는 ALUsrcB에 있지만
그와 연산을 해야하는 연산자 M[R[rs1]]은 ALUsrcA에 없다. 때문에 기존 ALUsrcA MUX를 3비트로 확장해서 
RD1, PC, rs1, D_RD(Data area Read Data)를 처리할 수 있어야 한다. 

2. ALUresult를 Data area의 Data Cache DC_WD(Data Cache Write Data) input으로 줄 수 있어야 한다.
기존에는 ALUresult가 데이터 진영에서 주소로서만 활용되었는데, A확장에서는 쓰여질 데이터로도 ALUresult가 쓰인다.
DC_WD의 input은 기존 Write Back을 위한 DM으로부터의 입력과 Register File로 부터의 입력 두가지 중 Cache Hit/miss에 따라 선택하는 구조였다.
하지만 위와 같은 추가 요소에 따라, 해당 MUX를 2-bit로 확장해서 CU의 신호 통제 하 input을 정하거나 1-bit MUX 두개로 해서 기존 MUX를 그대로 활용하고 그 후에 MUX를 하나 둬 이를 CU 통제 하에
ALUresult값으로 할건지 기존 WB/RegF 값으로 할건지를 선택할 수 있도록 해야한다. 

1번 적용 완료. 2번은 2안으로 적용 완료 (1-bit MUX 2개)
한 가지 우려스러운 점. 2안으로 하게 될 경우 WriteBack시 데이터 충돌이 생기진 않을까?
사고 실험을 진행해보자. 
AMOADD.W 
R[rd] = M[R[rs1]]
M[R[rs1]] = M[R[rs1]] + R[rs2]

[제어신호]
MemWrite = 1. 
RegWrite = 1.
Atomic = 1.

자, M[R[rs1]] 해당 주소 Miss. Data Memory로부터 가져와야한다. 
일단 SAA 때문에 먼저 M[R[rs1]]은 반환된다. 동시에 DM_RD가 DC_WD의 input으로 되어야 한다.
WB/Reg MUX는 Miss로 WB이 선택. DM_RD선택된다. Atomic 연산이기에, WB/Reg / Atomic MUX는 Atomic을 선택하고 있다. 
어라. Write Back 불가. 즉 Cache Miss의 경우엔 다음 사이클에 Cache 갱신이 이루어지니까 무조건 Atomic MUX가 WB/reg로 되어 있어야 한다...
즉 Cache Hit/Miss를 CU에서 판단할 수 있어야 하거나, DC_Ready 신호가 Not Ready인 경우에 DC_WD는 항상 WB/Reg로 되도록 해야한다. 
Miss = Not Ready. 캐시 M2C 갱신의 경우 Write_Done 신호를 대기해야하니까 Miss 경우 Not Ready의 의미를 내포하고 있다.

이렇게 하면 자연스럽게 Cache Miss 일 때 PC_Stall 되어 캐시 갱신이 이루어지고 

CLK 1. R[rd] = M[R[rs1]]

Data Cache 조회, M[R[rs1]]이 없음. 
Cache Miss. 캐시 갱신 시퀀스 시작. MemWrite 1로 활성화. 

[if Clean]
DC_Ready : not ready. 

SAA, Data Memory에서 M[R[rs1]] 출력. -> R[rd]에 쓰여짐.								M[R[rs1]] = M[R[rs1]] + R[rs2] 수행
동시에 Data Cache로도 출력됨. 해당 데이터를 현재 입력 중인 DC_Addr 즉 R[rs1]에 저장.	 

----------

[if Dirty]
DC_Ready : not ready. -> PC_Stall

SAA 메모리 반환 ; Data Memory에서 M[R[rs1]] 출력. -> R[rd]에 쓰여짐.				M[R[rs1]] = M[R[rs1]] + R[rs2], MemWrite = 1
캐시의 Dirty 데이터 블럭을 해당 주솟값과 같이 Write-Buffer에 저장						동시에... M[R[rs1]] 값과 R[rs2]값이 연산됨.
캐시 Dirty Bit 해소

CLK 2. CLK1에서 PC_Stall이었으므로 동일한 주솟값 DC_Addr로 입력 중.
Clean된 해당 캐시 블록에 메모리 블록 덮어쓰기
Write Buffer에 저장된 주소와 데이터를 해당 메모리에 쓰기..

# [2025.04.23.]
아.. A 확장 어떡하지.
일단 일과시간 중에는 가상메모리/ 페이징에 대한 이해도를 꽤나 높였다. 아직 TLB까지 포함해서 완벽한 이해는 아니지만 그 기초 까지는 알게 된 것 같다.
레지스터와 메모리 사이 버퍼가 캐시라면, 캐시와 메모리/2차 저장장치 사이 버퍼? 가 가상메모리; 페이지인 것 같다. 
완전 연관 방식의 유사 캐시.. 가상 페이지 넘버가 Tag 처럼 이용되고, 물리 페이지 번호가 곧 그에 대응된 데이터이다. 그와 별개로 Page offset(페이지 변위)가 있고..
페이지 변위가 곧 페이지의 개수, 크기를 결정한다. 페이지 번호 비트 수 × 페이지 변위 = 해당 페이징 메모리 크기 (가상 페이지 비트 수면 가상 페이징 크기, 물리 페이지 비트 수면 물리 메모리 크기이다.)
때문에 TLB나 가상메모리를 구현하기 위해서 물리 메모리 자체를 정해둬야할 것 같다.

TLB 실패 처리 중 하나는, 제어를 OS로 넘기는 것인데 가상 메모리를 지원한다는 것은 곧 메인 메모리 뿐만 아니라 2차 저장 장치까지 존재해야한다는 것을 내포한다. 
때문에 기존에 왜인지 모르겠지만 메인 메모리 DDR3 SDRAM만 구현하면 된다고 생각했는데 그게 아니라 외장 저장소까지 생각해야한다...

생각보다 할게 꽤 많다.. 파헤칠 수록 늘어나는 느낌이다..

어제 고민하던 문제는 FSM을 구현하는 것으로 어느정도 해결할 수 있을 것 같다.
다시 한번 사고 실험을 해보자. 

최악의 상황 가정인 Cache miss, block dirty 상황이다. 
명령어는 Zaamo; AMOADD.W

AMOADD.W 
R[rd] = M[R[rs1]]
M[R[rs1]] = M[R[rs1]] + R[rs2]

[제어신호]
MemWrite = 1. 
RegWrite = 1.
Atomic = 1.

**CLK1**
R[rd] 에 M[R[rs1]]을 해야한다.
SAA: Data Cache, Memory 조회, DC_Addr, DM_Addr로 주솟값이 입력된다.
Cache 색인, miss. 
Memory의 WB/ALUresult MUX가 Cache miss신호로 ALUresult로 전환되어 메모리에 해당 주소 읽기가 시작된다.

메모리에서 해당 주소 데이터 식별. 출력(DM_RD)
출력된 DM_RD는 레지스터의 RF_WD로 출력되고 레지스터의 RF_WA로 입력중인 R[rd]에 저장된다. 
R[rd] = M[R[rs1]] 수행 완료.

이와 동시에 DM_RD 출력된 것이 Data Cache에 갱신되어야하므로 DC_WD로 출력중이다.
1차 MUX인 WB/Reg MUX에서 cache miss 신호를 통해 WB가 선택되어 2차 MUX로 간다.

"2차 MUX에서 현재 Atomic이므로 WB가 아니라 ALUresult를 선택하게 된다."
이게 문제다. 

캐시 miss 이기에 WB되는게 Atomic 인 것보다 우선순위로 작용하여 WB이 이루어져야한다. 

아.. 더 써야하는데.. 시간 out.. 연등 오늘은 여기까지. 

# [2025.04.24.]
일과 시간동안 생각해봤다. 해당 문제를 해결할 방법.
2차 MUX에서 Atomic 제어 신호가 활성화 되어있어 WB가 되지 않는 문제.

Cache Miss시 DC_Ready를 not ready 상태로 전환하여 CU가 받는다.
CU에서는 always 조건문이나 다른 걸 통해 atomic 연산자 수행을 DC ready일 때만 수행할 수 있도록 한다.
이러면 해결.

이렇게 고쳤다 보고, 마저 사고 실험을 진행하면 다음과 같이 진행된다.

~~
1차 MUX인 WB/Reg MUX에서 cache miss 신호를 통해 WB가 선택되어 2차 MUX로 간다.

Cache miss, DC_not ready가 되어 Control Unit에서 PC_Stall을 보내고 다음 클럭 사이클로 간다. 

Data Cache not ready 이기에 Atomic은 = 0으로 비활성화 되어있다. 때문에 2차 MUX는 ALUresult가 아닌 WB을 선택하게 되고 메모리의 DM_RD가 DC_WD로 입력되고 있다.

하지만 현재 dirty 로 가정하였으므로 Cache에서는 Dirty 데이터 블록을 해당 블록의 주솟값과 같이 Write-Buffer에 저장한다.
캐시의 Dirty Bit는 해소되지만 아직 갱신이 안되었으므로 다음 사이클로 넘어가야한다. 

**CLK2**
PC_Stall로 인하여 같은 맥락의(문맥; Context) 명령어가 수행중이다. 
Clean된 해당 캐시 블록에 메모리의 DM_RD가 덮어씌워진다. 
WriteBuffer에 CLK1에서 저장한 주소와 데이터가 WB_Data로 입력되고.. DM_Addr MUX가 WB을 선택해야하는데, 이 CLK2에서는 DC_Status가 여전히 Miss여야하는건가?
이건 그럼 단순히 '현재' Hit/Miss를 다루는게 아닌 것 같은데.. 하물며 CLK2에서는 M[R[rs1]] = M[R[rs1]] + R[rs2]가 일어나야해서 Cache Hit이 되어야할 판이라...
이건 조정이 필요할 듯. DM_Addr MUX의 선택신호는 CU에서 캐시 FSM임을 인지하는 것 처럼 다뤄야할 것 같음. 여기에 Data Memory는 WriteEnable된 상태여야하는데.

무튼.

캐시 갱신완료, 메모리 WriteBack 완료. 
동시에 M[R[rs1]] = M[R[rs1]] + R[rs2]를 해야하는데,, 이건 시뮬에서 봐야할 것 같다.
보통 쓰기를 하고 나면 그걸 명시적으로 웨이브폼에서 확인 가능한게 다음 사이클 부터인데, 만약 이게 조율이 가능한 부분이라면 CLK2에서 Atomic 연산은 끝나지만
Cache 구조 때문에 최악의 상황에서는 CLK3 까지 넘어가야할 수도 있다.

(Perhaps CLK3)
M[R[rs1]] = M[R[rs1]] + R[rs2]. 
CLK1~2 과정을 거쳐 Cache가 갱신되었으므로 무조건 Hit.
DC_Addr로 ALU에서 bypass된 RD1 값이 Data Cache로 입력되어 해당 R[rs1]주솟값의 메모리 데이터가 DC_RD로 출력되어 D_RD로 ALU로 도?달?한다???
ALU를 두번 거쳐야하네??? 
이러면 DC_Addr에 R[rs1]이라는 주소를 주기 위해 ALU로 bypass하는게 아니라 어쩔 수 없이 ALUresult냐 RD1이냐 2 to 1; 1-bit MUX로 만들어야한다.
이래야 한 사이클 안에 해당 연산 수행 가능... 그리고 해당 MUX 선택 신호는 마찬가지로 CU에서 담당해야겠다. 
똑같이 Atomic 신호의 제어를 받으면 될 것 같다. 어차피 Write Back 중에는 비활성화되니까 문제 없고
DC Ready일 때는 어떤 작업을 해도 구조상 동작에 문제는 없으니.. 

오늘은 여기까지. 정리된 로직 자료와 추가 제어 내용들을 텔레그램 채널과 디스코드 서버에 업데이트 해두었다. 


# [2025.04.25.]
이제 남은 할 것들
aq, rl 비트 지원
Zalrsc 확장 지원

## aq, rl 비트 지원부터 설계해보자. 

------

## ~2025.04.16.~
"A"확장의 명령어들은 26:25 각 1비트마다 각각 aq, rl 비트로서 사용된다. 
aq(aquire), rl(release). 두 비트는 메모리 순서(Memory Ordering)를 제어하기 위해 사용된다. 

aq 비트 set된 명령어는 그 명령어의 완료까지 hart가 기다리고 다음 명령어들을 수행할 수 있도록 해야한다. 

rl비트 set된 명령어는 그 명령어의 수행 이전까지의 모든 메모리 접근 명령어가 완료될 때까지 hart가 기다리고, 이후에 해당 rl비트 set된 명령어를 수행할 수 있도록 해야한다. 

------

이건.. 별 다른 구조적 조정이 필요하진 않을 것 같다. Control Unit에서 aq, rl 비트를 보고 PC_Stall을 조건에 따라 수행할 수 있어야 하니 funct7에 해당하는 비트 범위를 입력 신호로 추가시켜야 한다.  
완료. RV64IM90_Zaamo_aqrl
남은 건 Zalrsc..Load Reserved, Store Conditional...

Zalrsc Extension : Z, Atomic; Load Reserved / Store Conditional Extension
LR.W : R[rd] = M[R[rs1]], 
R[rs1] 데이터 값(1에서 쓰인 메모리의 주솟값임.)에 예약(reservation) 설정.

SC.W : 
if Reservation is valid, M[R[rs1]] = R[rs2], R[rd] = 0
if Reservation is invalid, R[rd] = 1

Zalrsc 확장을 구현하기 위해서는 우선 Reservation이라는 개념부터 이해하여야 한다. 
자료를 많이 찾아보았지만 이에 대해 명확히 설명되어있는 자료는 없어서 매뉴얼에 전적으로 의지해서 이해해봐야겠다. 

A확장의 근간은 다수의 RISC-V hart들이 같은 메모리 공간에서 작동할 때 원자적으로 메모리를 읽고-변경하고-쓰고 하는 것을 동기화하기 위함이다. 
두 가지 형태의 atomic instruction이 있고, 하나는 'load-reserved/store-conditional instructions'. 나머지 하나는 'atomic fetch-and-op memory instructions'이다. 
둘 다 다양한 메모리 일관성 순서를 지원하는데, unordered, acquire, release 그리고 sequentially consistent semantics를 지원한다.
이러한 명령어들은 RISC-V가 RCsc 메모리 일관성 모델을 지원하도록 한다. 
(RCsc : release consistency with special accesses sequentially consistent; Memory consistency and event ordering in scalable shared-memory multiprocessors, Gharachorloo et al., 1990) 

숱한 토론 끝에, RISC-V에서는 rlease consistency를 표준 메모리 일관성 모델로 삼았다. 
그래서 RISC-V의 atomic support는 해당 모델을 기반으로 한다.
...

A Extension 챕터를 통으로 한국어로 번역하려다가 영 좋지 않은 선택 (물론 의향은 너무나도 크게 있지만 시간이 한 시가 모자란 상황이라.)임을 깨닫고 (Privileged_ISA.Korean.md 문서의 선례.. ㅋㅋ)
일단 'Reservation', 'Reservation set' 이라는 말이 포함된 문장을 해당 챕터에서 발췌해 정리했다. 이 과정을 거치며 단어 단위로 해당 챕터를 정독하게 되었는데, 얻어낸 단서는 다음과 같다.
(A_extension_Korean.md 문서 생성.)

결론적으로, Load-Reserved, Store Conditional은 하나의 쌍으로서 쓰이는 명령어이다. Load-Reserved, LR.W 명령어를 통해 reservation을 지정하게 되고 SC.W의 성공을 통해 해당 reservation이 무효화된다.
때문에 해당 reservation을 위한 '데이터 공간'이 필요하며 그 갯수는 단일 hart 시스템에서는 하나로 족하다. 문제는 그 데이터의 크기인데, 이에 대한 지정은 A 문서 자체에서는 직접적인 규정이 없다. 
다만 이와 같이 규정한다. 
"__The platform should provide a means to determine the size and shape of the reservation set.__"
"__A platform specificaiton may constrain the size and shape of the reservation set.__"
즉 크기와 형태를 플랫폼 설계의 재량으로 남겨두었고 이와 관련된 내용을 명시하게끔 정의되어있다. 

이게,, 만약 reserve된 데이터 그 자체가 표식이 필요할 경우 직설적으로 해당 데이터에 대해 reservation해야 한다는 묘사를 썼겠지만, 그게 아닌 '해당 데이터의 '바이트'가 포함되어야 한다' 라는 내용으로 봐서는 조금 유연한 구현 구조를 두고 있는 것 같다. 약간의 캐시 태그, 인덱스와 비슷한 느낌이랄까... 그렇게 구현할 수도 있을 것 같은데,,,, 어차피 해당 LR SC 내에서 쓰이는 데이터들은 지역성에 따라 어느정도 제한되는 편이기도 하고.. 하지만 이런 불확실하고 지적 한계에 따라 견문이 아예 달라질 수 있는 지점에서 실험적인 태도는 개발을 느리게 만들고 리스크를 짊어지게 한다.
물론!!! 너무 좋긴 하지만 현재 FPGA구현 일정 1달까지 포함하여 남은 논리적 설계 구현 시간이 1달 남짓이기에 (5월 28일 마감.) 안정적인 방향으로 가야겠다. 
메모리에서 데이터를 불러오는 것은 블록단위이고, offset을 통해서 해당 데이터를 블록 속에서 식별하여 이용하게 되는데,, 결국 reserve된 데이터의 크기만큼만 만들면 되지 않을까?
가장 단순히 구현할 수 있도록 그렇게 해야겠다. 이로서 '논리적'으로는 해당 명세를 위반하지 않으면서 가장 단순하게 Zalrsc를 구현할 수 있다. 
하나의 버퍼 레지스터, reservation register(RR) 추가하여 해당 레지스터에 주솟값과 데이터를 저장해둔다. 
그리고 해당 값과 앞으로 메모리 조회될 때마다 비교문을 통해서 RR의 값과 해당 주솟값의 데이터가 같은지 다른지를 판단하게 한다. 

Reservation이 깨지는 경우가 언제였더라.. 이걸 비교해서 뭘 판단해야했었지? Reservation이 유효한지?? 아 오늘은 여기까지 해야겠다. 마침 연등시간 종료.
내일이면 Zalrsc까지 구현할 수 있을 것 같다.
잘 하고 있다.. 잘.. 하고 있다.

# [2025.04.26.]
Reservation Set에 대한 크기는 캐시의 한 라인을 기준으로 하기로 했다. 
해당 바이트 영역이 참조될 때도 요긴하게 사용될 수 있고, 추후 I/O및 구조적 확장을 염두해두어 그만큼의 오버헤드를 둬도 나쁘지 않을 것이라는 생각.
Reservation Set은 32Byte 크기의 레지스터로 한다. 
SC.W의 발동은 LR.W에서 수행한 Reservation을 무효화 한다. 그리고 Reservation된 데이터는 각 hart마다 등록해두고 있으며 한 번에 하나의 Reservation Set만을 가진다.
SC.W의 실패 조건에 따라 다음과 같은 조건에서 Reservation set을 무효화한다.
reservation set에 대한 직접적인 연관성이 없더라도, 성공과 실패를 불문하고 SC.W 명령어의 실행은 reservation set을 invalidate 한다는 ISA의 규정을 준수하여야하기 때문에 Invalidate한다. 

0. SC.W 명령어가 가르킨 주소가 reservation set에 포함되어 있지 않을 경우 invalidate한다.
1. 다른 hart에서 reservation set에 해당하는 데이터에 쓰기를 했을 경우 reservation set을 invalidate한다. 
2. 다른 device에서 LR이 접근한 bytes에 대해 쓰기를 했을 경우 reservation set을 invalidate한다.
(LR이 접근한 byte 외 reservation set 내 다른 byte에 쓰기했다면 SC를 성공시킬 수도 있고 실패시킬 수도 있다. 단, 우리의 경우 단순화를 위해 라인단위 접근으로 실패 판정한다.)
3. 프로그램 순서에 따라 LR, SC 사이에 또 다른 SC(어느 주소든)가 있을 경우 invalidate한다. 

구현 방법은 다음과 같다.
0. SC.W 명령어를 수행할 때 (CU에서 funct7 비트 값으로 확인한다.)
실패와 성공을 판단하기 위해 Reservation Register에서 Reservation set의 유효 무효를 확인해야한다. R[rs2]데이터가 Reservation Set에 포함되어있는지를 확인해야하니
RD2 값을 Reservation Register의 입력 신호로 넣는다.
그리고 LR.W 명령어 수행시 Reservation 자체는 R[rs1] 데이터 값(M[R[rs1]]이므로 메모리에게는 주솟값이 됨)을 register하는 것이니 RD1 값을 Reservation Register의 입력 신호로 넣는다.
이 때, Reservation set이어야하므로, 
Reservation set을 invalidate 해야하는 경우 invalidate를 하는 제어 신호가 필요하므로 이를 Control Unit의 출력신호로 추가하고, Invalidate 신호를 Reservation Register의 입력 신호로 넣는다.
레지스터로 구현되므로, 클럭에 맞게 출력하기에 클럭 신호를 입력 신호로 넣는다.
입력된 신호 RD2가 RD1으로 register된 reservaiton set의 주소와 비교하여 Reservation이 Valid하여 성공했는지, 실패했는지를 알려주기 위한 출력신호가 필요하다.
Rsv_YN (Reservation_Yes_or_No)신호를 출력신호로 둔다. Rsv_YN을 Control Unit에 입력신호로 넣는다.

1. 예약된 메모리의 주소(R[rs1])에 쓰기가 있을 경우를 탐지해야하는데,, 이 쯤이면 Atomic Control 모듈을 따로 만드는게 좋을 것 같다. 
Atomic Control Unit
메모리 쓰기 시 해당 쓰기 될 주소가 Reservation Set의 주소인지 확인하여야 한다.
[입력 신호]
CLK, 
MemWrite, 
Rsv_Invalid, 
RD1, 
RD2, 
Data_Addr(ALUresult)

[출력 신호]
Rsv_YN

로직 : 
LR.W 명령어 실행 시, Data_Addr로 들어오는 입력받는다.
해당 입력 주솟값을 정렬하여 32B 블록 사이즈의 Reservation set을 만들고 Valid 처리 해둔다.

SC.W 명령어 실행 시, 입력되는 RD2값이 Reservation Set에 속하는지 비교한다.
Valid이고, Reservation set에 속한다면 Rsv_YN을 Yes(1)로 출력한다.
동시에 Reservation set을 invalidate한다.
CU에서는 SC의 success를 받아(Rsv_YN is Yes) DC_Atomic_MUX를 선택해 ALUresult로 하여 ALU에서 bypass된 RD2 값을 메모리 M[R[rs1]]에 저장한다.
동시에 RegWDsrc_MUX를 110로 선택하여 R[rd]에 0을 쓴다.

Valid인데, Reservation set에 속하지 않는다면, Rsv_YN을 No(0) 으로 출력한다.
이후 Reservation set을 invalidate한다. 동시에 RegWDsrc_MUX를 111로 선택하여 R[rd]에 1을 쓴다.

Invalid인 경우 어떤 상황이든 Rsv_YN이 No되고, RegWDsrc_MUX를 111로 선택하여 R[rd]에 1을 쓴다.

기타 명령어 실행시,
Memwrite신호가 활성화 되고 Data_Addr(ALUresult)가 현재 Reservation set에 포함되는 데이터면 
Reservation set을 invalidate 한다. 

---------- Zalrsc 총 정리 ----------

전제, Complex atomic memory operations ~~ are performed with the load-reserved(LR) and store-conditional (SC) instructions.
즉 Zalrsc에서 다루는 동작들은 memory operation들임을 가정하고 접근하여야 한다.

LR.W loads a word from the address in rs1, places the sign-extended value in rd, and registers a **reservation set** 
- a set of bytes that subsumes the bytes in the addressed word.
= LR.W는 rs1의 주소에서 word를 적재하고, 그의 sign-extended 값을 rd 주소에 둔 뒤, reservation set에 등록한다. 
__reservation set은 rs1의 주소에서 적재한 word의 byte를 포함하고 있는 byte의 집합이다.__

Load의 동작은, Memory의 값을 Register에 적재하는 것을 의미한다.
즉 word from the address in rs1은, M[R[rs1]]로 해석할 수 있다. 
M[R[rs1]] 값을 sign-extension하여 R[rd]에 적재한다. 그리고 reservation set에 등록한다. 
reservation set은 rs1의 주소에서 적재한 word의 byte를 포함하고 있는 byte의 집합이다.
즉 M[R[rs1]]값을 캐시 라인 단위로 Reservation set에 쓴다. (우리의 경우 32B)
0x8000_1234가 M[R[rs1]]이었다면 0x8000_1200~0x8000_123F까지를 reservation set으로 지정하는 것이다. 

따라서 해당 reservation set을 hold하고 있을 장소가 필요하고, 이걸 Reservation register라고 하며 
해당 reservation register를 제어를 통해 invalidate하고 갱신하고 해야하기 때문에 Atomic Unit 안에 Reservation register를 둔다.
다이어그램상 Atomic Unit = Reservation register라고 봐도 무방하다. 

----------

SC.W conditionally write a word in rs2 to the address in rs1: 
the SC.W succeeds only if the **reservation** is still valid and the **reservation set** contains the bytes being written.
= SC.W는 rs2의 word를 조건적으로 rs1에 쓴다. SC.W는 reservation이 여전히 유효하고, reservation set이 rs1에 쓰여질 바이트를 포함하고 있으면 성공한다.

SC.W가 rs2의 word를 조건적으로 rs1에 쓴다..
Store의 동작은 Register의 값을 Memory에 저장하는 것을 의미한다.
즉 rs2의 word는 R[rs2]로 해석할 수 있고, rs1에 쓴다는 것은 M[R[rs1]]에 데이터를 저장한다는 것이다.
즉, M[R[rs1]] = R[rs2]
그리고 rs1에 쓰여질 바이트 즉 M[R[rs1]]에 쓰여질 바이트는 R[rs2]이니까, 
SC.W는 LR.W와 하나의 쌍으로 작동하는데, 
앞서 LR.W에서 register한 Reserved Set의 bytes에 SC.W에서 rs1에 쓰여질 바이트를 포함하고 있어야 위와 같은 SC.W의 동작이 성공한다.

아., 오늘은 여기까지

# [2025.04.28.]
20:18 오늘 드디어. 우여곡절 끝에 어떻게 할지 정했다. 

LR.W 명령어 수행 시, rd에 sign-extension한 M[R[rs1]] 값을 place한다.
즉, R[rd]에 M[R[rs1]] 데이터가 쓰여지는 것이다. 
M[R[rs1]]의 주솟값, R[rs1]. 

_reservation set_ : a set of bytes that subsumes the bytes in the addressed word.
"_addressed word_"의 바이트들을 포함하는 바이트들 집합.

여기서 문제가 발생한다.
**addressed word**가 M[R[rs1]]의 주솟값, 즉 R[rs1]일까?
			아니면 	  M[R[rs1]]의 데이터 값, 즉 M[R[rs1]]자체일까?

경우의 수로 나눠서 한번 파악해보자.
What if addressed word meant Data itself?
-> SC.W에서 Reservation 검사를 위해 데이터 출력값 (D_RD)를 Reservation Set과 비교해야한다.
	모순 발생. 이 경우 데이터가 출력되며 Reservation Set과 비교되는데, D_RD의 출력은 곧장 BE_Logic과 RegWDmux를 통해 바로 Register File로 넘어간다. 
	이 때, Register Write Enable이 활성화 되어있었다면, 바로 Register에 입력되는데, 이걸 막고자 추가 로직을 구현하며 제어들을 두는 것은 극심한 구조적 비효율을 야기시킨다. 

What if address word meant Address?
-> SC.W에서 Reservation 검사를 위해 메모리 주솟값 (ALUresult)를 Reservation Set과 비교해야한다. 
위에서 발생한 모순점과 더불어, Store Conditional. 즉, 저장을 위해 데이터가 입력되기 전, reservation의 판단이 이루어져야한다. 
Store을 위한 주소 즉, RD1 값이 (Register File에 5비트 rs1이 입력되는 순간 그 비트를 주솟값으로 하는 레지스터에 쓰여져있는 데이터 출력) 인출되는 순간,
reservation set과 비교되며 조건문을 거쳐 동작의 수행이 이뤄지도록 하는 것이 자연스러우며 구조적으로 기능을 구현하기에 이상적이라 할 수 있다. 

기존의 로직을 그대로 따르긴 하지만, 조금더 명확한 스스로 납득할 만한 이유로 그렇게 하기로 했다. 

이렇게 될 때, 이제 단순히 쓸 수 있다. ㅎㅎ..

LR.W : R[rd] <- M[R[rs1]]
Reservation Set <- ( R[rs1]이 포함된 32B 블럭 주소 집합 )

SC.W : 조건 확인. 
if { ( R[rs2] ∈ Reservation set && Reservation set == valid )
	M[R[rs1]] = R[rs2],
	R[rd] = 0
}

else R[rd] = 1

끝!!! 핳하

Atomic Unit에서는 Reservation Set을 갖고 있으며, Zalrsc 명령어 실행 시 
SC.W가 success 해야하는지 fail 해야하는지를 Control Unit에게 알려줘서 
MemWrite 신호를 Enable하거나 Disable해야한다. 
이 경우 Register File R[rd]에 0, 1인지를 저장해야하니 CU에서는 RegWrite를 Enable한다. 

그리고 Reservation Set의 Valid 유무를 위에서 기술한 Fail 조건에 따라 Memory에 쓰여지는 작업을 할 때 해당 메모리의 주소값이 Reservaiton Set에 포함되는지를 확인하여야 한다.
즉, 데이터 메모리 주솟값 ALUresult값을 입력신호로 가져야한다.

동시에 메모리 읽기 때 해당 ALUresult값이 메모리에서 조회되었다고 Invalidate 하면 안되니까 MemWrite 즉 쓰기 작업일 때만 비교를 수행하도록
MemWrite 신호를 입력신호로 가져야 한다. 
그리고 SC.W 명령어를 수행하게 되면, 자동으로 Reservation Set을 Success, Fail 유무와 상관 없이 Invalidate해야한다.
해당 명령어의 정확한 수행 정보는 Control Unit에서 제일 먼저 알게 되고 제어문을 관리하는 모듈이니 Control Unit에서 SC.W 명령어 실행 시 Reservaiton Set을 Invalidate할 수 있도록
Rsv_Invalid 신호를 CU에서 Atomic Unit으로 보내야한다. 즉, Rsv_Invalid 신호를 입력신호로 가져야한다. 

그럼 Atomic Unit의 디자인을 이제 확정지을 수 있다. 

[입력신호]
Reservation Set을 등록하기 위한 R[rs1], 즉 Register File 로부터의 RD1 신호.
Reservation Set과 R[rs2], 즉 Register File 로부터의 RD2 신호.
ALUresult, SC외 Reservation set에 해당하는 주소 쓰기 접근이 발생했는지를 알기 위한 메모리의 주소 신호.

받아야하는 데이터 신호는 위 세 가지이다. 
나머지는 제어 신호.

MemWrite, SC외 Reservation set에 해당하는 주소 쓰기 접근이 발생했는지를 알기 위한 메모리의 쓰기 활성화 신호
Rsv_Invalid.

The theory only takes you so far.
나중에 검증 절차 및 Testbench에서 내 이해가 맞았는지 알아볼 수 있을 것이다. 

쨔스.

---연등시간---

아, Reservation set은 Register로 구현되어야 하니까 CLK 신호를 포함하여야 한다. 

출력신호로는 위에서 언급한 Atomic Unit에서 
Control Unit으로 가는 success, fail 유무를 위한 신호 Rsv_YN (Reservation Yes/No)신호를 갖는다. 

[출력신호]
Rsv_YN, Reservation Set에 대한 접근이 성공했는지, 실패했는지에 대한 내용.

-----

LR.W의 데이터패스 검증 중. 
Atomic Unit의 Reservation Set이 Register File과 비슷하게 Register로 구현되는 이상, 쓰기 활성화 신호는 필요할 것이다. 
입력신호에 Rsv_Write 신호 추가. 단, 이 신호는 DC_Atomic_MUX의 제어 신호를 파생하여 사용한다. 
DC_Atomic_MUX에서 Atomic 명령어일 때, Memory의 주소로 Atomic 연산에서만 RD1 값만을 쓰는데 이걸 위해 1로 MUX를 활성화 할 때, 마찬가지로 
해당 Atomic 연산에서 Reservation Set Register의 쓰기가 활성화 되면 될 것 같다.
라고,, 생각했는데 이러면 SC.W에서도 쓰기가 되겠구나. 어쩔 수 없이 별도의 신호를 CU에 추가해야한다.
Rsv_Write신호를 Control Unit과 Atomic Unit 둘 다에 각각 출력과 입력으로 추가한다. 

LR.W에서는,, Rsv_YN을 출력할 이유가 굳이 없다. 무슨 값을 출력해도 어차피 해당 명령어를 수행하는 동안 쓸 일이 없기 때문.

SC.W의 데이터패스 검증으로 넘어가자.
어. RD1은 별도로 MUX 신호로 넣었는데 RD2는 ALU bypass 해야하네? 하긴 bypass 해도 되긴 하는데,, 어차피 RD2를 메모리 주소로 사용하면서 연산을 수행하는 경우는 없으니까. Bypass로 하자. 

어.. 문제 발생. SC.W 즉 메모리에서 쓰기가 발생 할 때에만 비교를 하는데, SC는 store 명령어이므로 기본적으로 MemWrite를 이미 활성화 시켜버려서 조건에 따른 활성화를 할 수가 없는데..
Control Unit에서 opcode가 Zalrsc 확장에 해당하는 경우 MemWrite신호를 조건문으로 Rsv_YN의 값에 따라 내놓게 끔 해두면 해결. 
만약 이 방법이 안될 경우, 별도의 Control Unit의 .. 아니다. 이 방법 밖엔 없다. 

아니. Atomic Unit은 Atomic 연산임을 알아야한다.
기본적으로 reservation set에 해당하는 주소에 메모리 쓰기가 이뤄지는지를 보기 위해 MemWrite와 ALUresult값을 받는다.
MemWrite가 있을 때 ALUresult와 Reservation set을 비교하는 것이다. 

하지만 SC.W가 나올 때는
MemWrite가 기본적으로 비활성화 되어있다는 전제로, 이 경우 비교를 해야함을 알려주는 식별자가 없다. 
때문에, 이 경우 Atomic임을 알리는 신호를 통해 필연적으로 Reservation Set과 RD2가 비교되게 해야한다. 
이걸 위해, DC_Atomic_MUX를 Atomic이라는 신호로 Atomic Unit에 입력신호로 추가한다. 

완성.. A확장 구현 성공이다...
RV64IMA94F... 이제 이걸 5단계 파이프라이닝에 추가하면 된다... 하하하...
오늘은 여기까지!!!

수고했다 내 자신.

# [2025.04.29.]
5단계 파이프라이닝을 하면서 대부분의 Reservation set 등록과 SC.W 실행 시 Invalidation, RD2값과 Reservation set과의 비교 와 같은 동작들은
Instruction Decoding 단계에서 수행 가능했다. 인출 즉시 확인해서 SC.W시 MemWrite를 활성화할건지 말건지를 Control Unit에서 Atomic Unit의 Rsv_YN을 통해 제어해야하기 때문이다.
그리고 그 제어 신호가 파이프라이닝 되어서 MEM 단계에서 정상적으로 이뤄져야하기 때문이다. 
현재는 Zalrsc 의 동작을 파이프라이닝 하고 있는데, 문제점이 벌써 하나 생겼다.
이거 한 가지만 해결하면 될 것 같은데, Reservation Set에 등록된 주솟값들 범위 내에 별도의 Store 작업이 이뤄지면 해당 reservation set을 invalidate 해야한다.
즉 ALUresult(Data_Address값)을 Reservation Set과 비교해야하는데, Reservation 이후 부터 비교를 해야하는게 문제다.
MEM 단계에서 인출되는 ALUresult 값을 ...MemWrite 신호가 활성화 되어있을 때 비교한다면 Instruction Decoding 단계에서 이미 진행된 MEM 단계,
문맥상 LR, SC 내에 없지만 LR에 해당되는 주솟값 내에서 쓰기가 이뤄진다면 그 즉시 invalidation이 되게 된다. 이러면 안되는데. 

즉, Reservation Set에 대한 비교 유닛을 MEM 단계에서 별도로 둬야할 것 같다.
그리고,, 해당 비교 유닛은 Atomic Unit과 Reservation Set이 공유되어야 한다.
아. 그래. LR과 SC 즉 시작되었으니 비교하라는 플래그를 두면 되겠다. 시작과 끝을 알 수 있게 해주는 플래그 신호.
이러면 굳이 비교 유닛을 별도로 두는게 아니라, MEM 단계에서 출력되는 ALUresult를
싱글사이클 구현했듯이 그대로 Atomic Unit에 두고, Atomic 연산 중 LR, SC가 시작되고 끝이 되었다는 식별자를 주면 된다.
Atomic_MUX 신호를 사용하면 Zaamo에서도 쓰이게 되니 오인하게 되므로 쓰면 안되고, 별도의 플래그 신호를 CU에서 줘야할 것 같다.
아니면, opcode와 funct7을 줘도 되긴 하는데, 이러면 너무 난잡해지니까. Control Unit에서 별도의 신호를 추가하자. 
아.. 오늘은 여기까지.

# [2025.04.30.]

어제 말한 CU에 쓰일 LR.W, SC.W를 위한 플래그 신호는 LRSC_Flag라는 신호로 Control Unit과 Atomic Unit에 각각 추가했다. 

파이프라인에서는 aq, rl 비트에 대한 동작이 조금 달리 작동해야한다. 
aq 비트가 set 되었을 때는, 해당 aq비트가 set된 A확장 명령어가 끝날 때 까지 차기 명령어의 수행을 stall하고, 완료 이후 재개해야 한다.
rl 비트가 set 되었을 때는, 해당 rl비트 이전에 수행되고 있던 명령어들이 모두 끝내진 뒤, 마저 해당 rl비트가 set된 명령어가 수행 재개되어야 한다. 

Control Unit에서 aq 비트가 set 되었다는 것을 인식했을 때엔, WB단계에 가서 해당 aq_set 명령어가 수행 완료 되었다는 식별 신호를 Control Unit이 기다리며 PC_Stall을 출력하고 있어야 한다. 
마찬가지로, Control Unit에서 rl 비트가 set 되었다는 것을 인식했을 때엔, WB단계까지 그 이전에 수행중이었던 모든 명령어들이 수행되었는지, 
즉 rl_set 명령어 직전 명령어가 WB단계까지 수행 완료되었다는 식별 신호를 Control Unit이 기다리며 PC_Stall을 출력하고 있어야 한다. 버블을 삽입해야하는 셈. 

이 것을 어떻게 구현할 것이냐...
Atomic 신호를 파이프라이닝해서, WB단계까지 갖고 간다.
WB단계에 비교 모듈을 둬서, Atomic이 1이고, 해당 명령어가 도달하였을 경우 Control Unit에 aq_done 신호를 반환하여 PC_Stall을 멈추는 것.
아니지.? 이럴 거면 그냥 Atomic 신호를 WB까지 갖고 갔다가 그대로 Control Unit에 꽂으면 되는 일 아닌가?
그렇게 해야겠다. 

그럼 rl은 어떻게 할까?
버블을 어떻게 삽입하지.. Hazard Unit에서 어차피 각 파이프라인 레지스터별로 flush 기능을 갖고 있으니
Atomic 식별 비트, ID단계 rl 비트, WB단계 rl 비트를 입력받아 상황에 맞게 rl비트가 set되면 flush 기능을 통해 NOP를 하도록 구현하기로 했다.
WB단계 rl비트 배선 중.
오늘은 여기까지. 
2026 KAIST 입시전형 모집요강 나와서 읽느라 시간이 좀 걸렸다.

5월, 얼마 안남았다. 6월 부턴 FPGA. 
잘 마무리 지어보자.
화이팅!

# [2025.05.01.]
당직이었다. Zalrsc 파이프라이닝은 했고, aq, rl 비트 동작 수행을 위해 어제 만든 로직 배선도 진행 중이고.
이제 남은건 Zaamo 가 제대로 작동하는지에 대한 데이터패스 확인이다. 
이러면 A확장까지 끝나고, OS 탑재를 위한 준비작업에 나선다. 
적어도.. OS를 위해서는 가상 메모리랑 I/O 구현(GUI 포함.) 그리고 이 두 가지를 구현하다보면 자연스럽게 특권 계층도 구현될 거라고 생각하는데..
믕..

# [2025.05.02.]
현재 백엔드 개발 단에서 아직 RV32I47NF도 완성하지 못했기 때문에 이번 Zaamo 파이프라인 확인만 마치고 나서 백엔드로 다시 한번 뛰어들어 빠르게 진행할 계획이다. 
5월 이번 연휴 즉 5월 6일까지 basic_rv32s의 구현을 끝내는 것이 목표이다. 

자 시작!

아, 이런. 생각해보니까 Zaamo를 위해서 ALUsrcA에 D_RD 신호를 포함했었는데....
싱글사이클에서는 모든 유닛이 한 사이클에 동시 사용이 가능하니 문제가 없었지만
파이프라이닝에서는 MEM단계 이전 EX단계에서 메모리 인출 데이터를 연산 소스로 사용할 수 없다. EX단계에서 메모리 인출이 일어나야하는데.. 이러면 월권인데..

## ~2025.04.13~
AMOADD.W 명령어를 수행했다면, AMOADD.W rd, rs2, rs1 이렇게 사용된다.
그리고 이는 이러한 동작을 수행한다.
R[rd] <-  M[rs1]
M[rs1] <- M[rs1] + R[rs2]

R[rd]에 M[rs1]이 먼저 쓰여지고, 쓰여진 M[rs1]에 기존의 M[rs1]값 + R[rs2]값이 쓰여지는 순서를 따른다. 

별도의 MEM단계에 Atomic 연산; Zaamo 전용의 ALU를 배치할까도 생각해봤지만 한 클럭 사이클의 손해는 메꿀 수 없다는 결론을 내렸다. 
MEM단계에 ALU를 넣는건 사실 표면상 Zaamo 한정으로 EX단계를 MEM 이후로 배치하는 것이라 볼 수 있다 (혹은 두 단계의 병합). 즉 동적인 파이프라인 배치가 되는 것.
원래는 IF/ID/EX/MEM/WB인데, Zaamo에서는 그럼 중간의 EX단계에서 하는 일이 없으니 EX에서 그냥 넘어가는데 IF/ID/MEM/EX/WB가 된다.
하지만, 문제는 그렇게 파이프라인 '스킵'을 우리가 구현하지 않았다는 것. 
그럼 IF/ID/MEM/EX/WB와 같은 파이프라인의 동적 재배치가 아니라 IF/ID/버블/MEM/EX/WB 즉 한 사이클의 손해를 가져오게 된다.
파이프라인의 동적 재배치를 구현한다면 물론 이를 해결하고 성능적으로 기존 데이터패스보다 한 사이클을 단축 시킬 수 있으니 성능적인 이점을 취할 수 있겠지만, 
지금 그러한 새로운 타입의 비-정석적 구현을 시도하기엔 기간이 부족하다. 때문에, 다른 방안을 모색해본다.

PC_Stall을 활용하는 방안. 
Zaamo 명령어를 인식하면, EX단계에서 신호를 CU로 줘 PC_Stall한다. 
EX단계에 Zaamo가 그대로 멈춘 채 다음 클럭에서 MEM단계 속행. 
MEM에서 해당 메모리 source가 나오면 그걸 EX로 넣어주고 동시에 PC_Stall을 푼다. 
이러면 원래대로의 순서로 돌아와 EX단계 ALU에서 계산한 결과를 MEM단계로 넘겨주고 WB단계에서 커밋할 수 있다. 

즉, 파이프라인의 기본 원리에 입각하여 한 사이클 손해를 보지만 추가적인 하드웨어 리소스의 추가 없이 진행하는 것이다. 

이렇게 하기로 했다. 어차피 각 Register별 파이프라인 Stall 및 flush 로직은 구현해뒀으니까.

완성! RV64IMA94F_5SP.R1, 23:56; KHWL2025!!

# [2025.05.03.]
오늘은 RV32I47NF Verilog 개발 이전, 여태까지 만든 프로세서 디자인의 각 모듈별 로직과 설명을 정리할 것이다. 
끝나는 대로 백엔드 투입할 예정. 이걸 지금 구태여 해두는 이유는 명확하다.
나중에 가서 하면 '어라 이 신호가 왜 있더라'가 프로젝트를 진행하면서도 빈번하게 있었기 때문이다. 
RV32I37F부터 시작해서 추가할 예정이다.
각 아키텍처별로 모듈의 역할 추가 및 변경이 있었으니 이 부분을 주의해서 만들어야겠다.
시작! (10:23)

20:48 끝.. 10시간에 걸친 작업..

이제 이를 기반으로 43FC로 오면서 기존으로부터 변경된 모듈들에 관련 사항과 추가 모듈에 대한 문서를 만들면 된다.
아마.. 내일 오전에 문서화가 끝나고, 오후에 백엔드갈 것 같다. 

43F까지 어느정도 다 마쳤다. 아마 진짜로 내일 안에 끝낼 수... 있겠지.?
하하. 오늘은 여기까지. 23:59.

# [2025.05.04.]
43FC의 문서화까지 다 마쳤다. 하지만 문제를 발견하여 20시 경부터 회의에 들어갔다. 
Data Cache - Memory 구조에서 Data Cache Miss 신호를 DM_Addr_MUX의 제어신호로 설계한게 화근이었다. 
발생하는 문제는 다음과 같다. 

1. 읽기 시도 (0x1111_1111 주소)
데이터 캐시: 찾아보자
데이터 메모리 : 찾아보자

2. 캐시: 어라 캐시 미스임 
-> 자동으로 여태 메모리로 입력되던 주소가 WB_Addr로 바뀜. SAA 중도 차단됨

메모리 : 어?? 뭐야 뭐 어떡하라고 WB_Addr 인출하라고?
-> 그대로 WB_Addr에 해당되는 값 인출 됨

즉, SAA 이기에 발생하는 문제.
DM_Addr_MUX를 단순히 DC_Status의 Miss시 WB_Addr로 설정하게 되면
ALUresult를 주솟값으로 하는 데이터의 인출이 이뤄져야하는데 WB_Addr를 주솟값으로 하는 데이터의 인출이 생긴다. 

이에 대한 내 해결안 : 1비트 FSM을 데이터 메모리에 만드는 것.
Read.
Cache, Memory SAA로 주소 접근

Cache Miss!
->캐시 미스 신호를 D_RD_MUX랑 Data Memory에 보냄

D_RD 선택 MUX의 선택, DM_RD을 인출.

Data Memory access...주소접근중... complete! 
DM_RD fetched and Cache Miss detected! 
-> DM_RD를 인출했고, 캐시 미스가 탐지됨.
flag rise, Write back mode.
두 조건을 만족했으므로 Write Back 모드로 변경 (FSM 비트 1로 set.)

WB_Addr input, WB_Data wrote.
Data Memory의 Address MUX를 WB_Addr input으로 선택.
Data Memory의 Write Back 완료. (C2M)

Back to normal mode (FSM 비트 0으로 Set. DM_Addr_MUX는 다시 ALUresult 선택으로 바뀜.)

위 로직은 검토중이고, CC84가 방안을 생각해봤다.

CC84:
flush_address 에 해당되는 값이 인출된다고 해도
어짜피 control unit 은 pc 갱신을 멈춘 상태라 문제 없을 것이다.

KHWL:
LW 명령어. R[rd] = M[R[rs1]]

CLK1.

SAA. 캐시/메모리 동시 주소 접근
Cache miss, Not Ready, PC_Stall. 
D_RD는 DM_RD로 선택

Data Memory에서 정상 데이터가 나와야함
근데 DM_Addr이 Cache miss이기에 WB_Addr 기준으로 데이터가 출력됨
-> R[rd] = 잘못된 M[R[rs1]]
동시에 Cache로도 WB_Addr 주소를 기반한 잘못된 데이터 나감

데이터 캐시에서 WriteBack으로 DM으로 flush해야하는 데이터와 해당 주솟값을 Write Buffer로 출력

CLK2.
여전히 DC Status는 Miss.
Not Ready, PC_Stall 중.
DM_Addr은 여전히 WB_Addr을 받고 있음.
MemWrite가 되고, Data Cache에 잘못된 M[R[rs1]]의 갱신이 일어남. 
D_RD는 여전히 DM_RD고, WB_Addr기반 잘못된 주소의 데이터가 출력되고 있음.

DM_Not ready
Write Buffer에서 Data Memory로 WB_Addr과 WB_Data 출력. DM에서 WriteBack 일어남. 메모리로 Flush 끝.

CLK3.
DC_Ready, DM_Ready. PC_Stall 풀림. 명령어 갱신 재개.

이 논리 전개에 문제가 없다면, 문제가 발생하는 것이 맞다. 

CC84 방안 1 :
dm_address 신호 MUX를 제어할 때
hit/miss 신호만으로 제어하는 대신
cache_ready 랑 섞어서 MUX 제어.

hit | cache_ready | select
0 | 0 | flush_address
0 | 1 | alu_result
1 | 0 | x
1 | 1 | x


KHWL : Miss고 Not Ready가 초기 상황인데 그걸 flush_address로 갖고가면 일단 잘못된 메모리 데이터가 인출됨

두번째 사이클에서 그럼 캐시가 ready되는 경우가 있어야 함.  캐시의 갱신이 두번째 사이클에서 이뤄지니까 이 때 ALUresult값을 주소로 한 제대로된 메모리 데이터가 인출되어서 데이터 캐시에게 줘야하고 동시에 그게 레지스터에 쓰일 값으로 나가야 함. 

근데? 두번째 사이클에서 캐시가 ready되는 경우가 없음. 
갱신 이후 ready인데, 그럼 ready가 '실효성'을 가지는건 CLK3 부터임.

CLK3? DC,DM Ready임. 이 때 ALUresult로 풀린다고 한들, 해당 데이터가 데이터 메모리에서 안나감. 왜? PC_Stall 풀려서 명령어 갱신 재개됐거든

SAA를 살리기 위한 추가 로직의 도입으로 인한 시간 소요를 생각하여, SAA 기능의 드랍을 검토중이다. 위 내용은 1시간 10분에 걸친 회의록을 정리한 것이다.

일단 내일까지 하는 걸 보고, 어떻게 할지 정하기로 했다.
우선 로직과 같은 부분은 대부분 구현이 된 상태고, 기존에 캐시 구조를 10-bit 주소 구조로 했었는데 이를 제시한 specification대로 32-bit 체제로 바꾸기만 하면 얼추 되는 상태라고 한다.

# [2025.05.05.]


위 캐시 구조에 대한 문제를 제외하고 ([43FC]!!DM_Addr_MUX 로 수정해야할 문서 표기를 해두었다. )
RV32I47NF 까지의 구조 문서화를 모두 마쳤다. (17:27)

오늘 안에 RV64IMA94F까지 끝나지 않을까 싶다. 
연등시간에는 백엔드로 넘어가서 Exception Detector와 Trap Controller를 설계하는 것을 목표로 한다.

밥먹고 와야지.  

RV64I59F 까지 끝냈고..
RV64IM72F는 RV64I59F와 구조적 차이가 없다. 

# [2025.05.06.]
## Trap Controller를 설계하자..
ECALL, EBREAK이 각각 어떤 동작을 수행해야했었는지 기억이 안난다... 기록을 뒤져보자.

## - [EBREAK의 처리 과정]

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

단순화 하면, ECALL = PC stall 상태로 mret 수행 이전까지 대기
EBREAK = 디버그 인터페이스 명령어 수행인 것 같다.

---

아.. mret 구현..
mret시.. mepc를 가져와서 PCC에 보내 NextPC로 할 수 있어야 한다.. 
마찬가지로 T_Target 신호로 보내고 PC_Stall과 Trapped 를 끊으면 되지 않을까?

아 이런. 
mret을 위해서는 mepc에서 값을 읽어와 이를 PCC로 넘겨야하는데 SYSTEM 명령어와 CSR을 로직에 따라 제어한다는 특성상 Trap Controller가 담당하는게 타당해보인다. 
하지만 현재 Exception Detector에는 funct7 식별 신호를 input 받지 않고 있다. 
opcode와 funct3, raw_imm으로만 받는데, 이래서는 같은 opcode와 funct3를 갖고 있는 ECALL, EBREAK 명령어들과 mret을 구별할 수 없다. 
ECALL, EBREAK은 각자 I-Type으로, raw_imm값의 0번째 비트로 구분할 수 있지만 mret은 funct7의 29, 28번째 비트를 식별해야하기에 funct7 입력을 받아야 한다.

구현은 funct7을 포함시켰는데, 다이어그램 수정을 또 해야한다.

!할일 
다이어그램 Exception Detector에 funct7 추가하기

---

trap controller에서 misalign exception시 내부적으로 정렬해서 T_Target주는게 아니라.. 
Trap Handler에 align하는 로직의 주소로 분기시켜서 처리하고 오도록 하는게 좋을 것 같은데..
이러면.. mtvec이 어떻게 작동하더라? direct랑 vectored...
아니다 하나로 해도 되겠다.
일단 하나의 Trap Handler 로 진입하도록 하고
해당 프로그램 구문에서 zicsr 명령어를 통해 현재 mcause 값을 보고 어떤 exception 상황인지를 확인하고 그에 따른 처리를 할 수 있도록 코드를 짜면 되잖아?

Trap Controller Testbench Scenario

- Instruction Memory 10000번지부터 Trap Handling 명령어들이 있어야 한다.

- CSR mtvec이랑 현재 pc값을 입력해주고 있어야한다. (가정)

- $display에서 trap_handle_state 레지스터의 상태변화를 볼 수 있도록 선언해둘 것.

내일은 trap controller의 testbench를 구현해봐야겠다. 
코드를 꽤 정리되게 잘 짰고 의도한 로직들을 모두 구현한 것 같아 아마 내일 테스트를 한다고 해도 큰 문제는 없을 것만 같다.
오랜만에 verilog를 하니까 문법도 문법이고 여러모로 감회가 새롭다. 

캐시쪽은 testbench하며 검증하고 있는 것 같은데 일단 32-bit 확장 과정 자체는 잘 되고 있는 것 같다.
오늘을 기점으로, 캐시 구조는 잠시 미뤄두고 내일부터는 64-bit, M, A 확장의 구현으로 넘어간다.
다들 수정소요가 좀 있을 뿐이지 크게 어려운 내용들은 아니기도 하고,
로직 자체는 정립이 되어있으니 그대로 이해하고 따라 만든다는 가정 하에 64IMA 확장의 마감은 12일 까지로 잡았다.
그 이후로는 다시 캐시구조로 넘어와서 마저 구현하고, 나는 투 트랙으로 외부장치 interrupt나 파이프라이닝을 맡을 예정이다.
그리고 5월 말 27일부터 31일까지 IDEC에서 FPGA 구현 강의가 예정되어있다. 이를 듣고 기반하여 6월은 FPGA 구현에 힘쓸 예정.

오늘은 여기까지! 

# [2025.05.07.]
## 오늘은 테스트벤치 하는 날. 
야호 해보자.

어제까지 진행되던 캐시의 구현은 데이터캐시의 부분적 완성을 끝으로 일단 보류되었다. 
혹시 몰라 기록을 남기자면, 당면한 캐시 문제는 아래와 같다.
[Read, Cache miss, lines are full. all lines are clean]
3333_3333 읽기를 두 번 실행할 것이다. 

A: 1111_1111	LRU : old
B: CCCC_CCCC	LRU : recently used

첫번 째에서는 3333_3333이 캐시 실패한다. 고로 A가 교체된다.

교체 당시, old이자 miss였던 A 블럭이 교체되자마자 hit 상태가 된다. 
주소를 계속 입력하고 있기 때문..이라는데 이게 왜 문제가 되는거지?
솔직히 앞에서 MUX가 이미 제어하고 있기도 하고, miss시엔 SAA로 DM_RD가 이미 올바르게 의도한 데이터를 출력하기 때문에 큰 문제가 되어보이진 않는다.

일단 캐시의 완성과는 별개로 검증시간이 또 필요하니 일단 보류하고 64IMA 확장을 먼저 하기로 했다.
오늘 A확장 Zalrsc, aq:rl 비트, Zaamo 에 대해서 그간의 연구 내용들을 ChoiCube84에게 브리핑했다. 
오늘은 ChoiCube84가 64확장을 할거고 아마 이 내용은 또 다른 레포짓토리를 파면서 시작될 것 같다. 
일단 docs 작성은 여기까지하고 연등 종료시 까지 개발을 한 뒤에 다시 와서 push해야겠다.

## Trap Controller 테스트벤치 구현 시작!!

Trap_controller에서 봐야하는거: 
trap_handle_state의 변화 과정
csr_trap_address의 주소 변화
csr_trap_write_data의 값 변화

trap_target 주소의 변화

FENCE.I시 ic_clean 활성화 여부

MRET시 debug mode 0으로 돌아오는지
mepc값 t_target으로 정상 출력되는지

NONE시 ic_clean, debug_mode 0, trap handle state IDLE로 되는지

일단 얼추 tb자체는 동작한다. 시간이 없어서 waveform은 확인 못했지만
$display 명령어로 출력되는 결과는 의도된 값들이 나온 것 같다.
내일은 심층 검증을 할 예정. 
가자! 

# [2025.05.08.]
## Trap Controller의 testbench 시나리오를 일과시간 중에 구성했다.

Trap Handler 주소로 분기 하기 이전 전초작업을 하는 과정을 Pre-Trap Handling으로 칭한다.
이 Pre-Trap Handling에는 CSR mepc write와 CSR mcause write 작업을 포함한다.
이후 CSR mtvec read로 NextPC를 Trap Handler 주소로 하여 Trap Handler 주소로 분기하거나
Trap Controller 내부의 로직을 통해 처리한다.

보통 ECALL, EBREAK, MISALIGNED 같은 exception이나 trap은 TH(Trap Handler) 같은 곳에서 
mret을 마지막 구문으로 쓰기에 사실 MRET 명령어까지 쓰는 것이 하나의 묶음이라 생각할 수 있다. 

시나리오 구성은 아래와 같다.

ECALL - mret
MISALIGNED - mret
EBREAK - mret
zifencei
none

자세한 입력 주솟값과 예상 출력값에 대한 것은 Trap_Controller_tb.v 파일을 확인하라.
주석처리로 하나하나 모두 적어두었다.

Trap_Controller 직접 테스트벤치 재작성 해서 시나리오를 만들어 검증 중. 
기존에 FSM을 IDLE-WriteMEPC-WriteMCAUSE 이렇게 3개로만 뒀었다. 
어차피 IDLE에서 실행하고, 다음 게 mepc쓰기이고 이 때 wirte mepc로 하면 다음 if write mepc면 mcause의 쓰기를 진행하고, idle로 되돌아 간다 하면 됐었기 때문. 
하지만 연속된 Trap Controller 개입 상황시 이러면 FSM이 꼬인다.
그리고 계속 신호가 입력되고 있을 경우 현재 상황이 새롭게 인식되어 다시 FSM 사이클을 돌리는 현상을 vcd 검증 중 확인하였다.
때문에 끝난 상태인 READ_MTVEC 상태를 또 만들어서 다음 명령어 갱신 때 IDLE로 되돌아와 다시 처음부터 수행할 수 있도록 바꿨다.

그리고 이게 트랩 발생시 제어까지 총 3사이클이 발생하는데, 
이 동안 PC가 멈춰야할 것이며 CSR File의 쓰기 제어 또한 추가적으로 필요하다. 
하지만 언제 CSR File로의 쓰기가 벌어지는지는 Trap Controller만 알고 있으므로 TC에서 CSRF로 write enable신호를 하나 보내고, 
CU와 TC 의 쓰기 제어 신호를 OR처리해서 CSRF의 Write가 enable되도록 수정해야할 것 같다.

마찬가지로 Trap Controller가 Pre-Trap handling 진행 중에는 PC를 갱신할 수 없도록 CU에 Trap_Done 신호를 추가해야할 것 같다. 
아고. 파이프라이닝할 때 골치 꽤나 아프겠네.

23:43. 시나리오 테스트 케이스대로 전부 올바른 값으로 잘 작동한다.
위의 수정 요소를... 반영해야겠다.
!할일
Control Unit에 Trap_Done 로직 추가
Trap Controller에 CSR_WD (CSR Write Enable)신호 추가
곧 구현할 RV32I47NF의 탑 모듈에서 TC와 CU의 CSRF 쓰기 활성화 신호를 OR처리하여 CSR_Write 신호로 넣어주는 것 구현하기.

오늘은 여기까지! 이햐. 그래도 오랜만에 코딩한게 잘 작동하니 뿌듯하다.
내일 안에 RV32I47NF 만드는 것을 목표로 해야겠다. 
해보자. 화이팅!

# [2025.05.09.]
Pre-Trap Handling을 위한 Trap_Done신호를 언제 0으로 넣어야 할까... 
Trap status가 확인되었을 때?  
trap_Handle_state가 IDLE일 때? 
어차피 한번 PTH하고 나면 다시 MRET이나 NONE이 아니고서야 IDLE로 돌아가지 않는데.. 
마지막 mtvec read나 internal logic 처리 완료하면 다시 1로 하는거야. 
아니지. IDLE시에 Trap_Done 신호를 하게 되면 TRAP 상황이 아닐 때에도.. 
아 애초에 TRAP 확인 이후 case문이니까 TRAP 확인 이전에 IDLE이라 해도 문제는 없겠구나. 
IDLE: begin 문에 trap_done <= 1'b0; 하고 
WRITE_MCAUSE: begin 문에 trap_done <= 1'b1;로 먼저 구현해보고 tb를 돌려야겠다. 
만약 의도한 동작이 발생하지 않으면 trap_done <= 1'b1을 READ_MTVEC: begin 문을 새로 쓰고 거기에 포함시켜봐야겠다.

IDLE상황에서만 0되고, WRITE_MEPC, WRITE_MCAUSE, READ_MTVEC에서 모두 1이 되는 상황 발생..

trap_done <= 1'b1을 READ_MTVEC(또는 WRITE_MCAUSE (EBREAK의 경우)) 문에 새로 쓰고, 
trap_done <= 1'b0을 trap_status에 바로 썼다. trap handle state에 적는게 아니라. 
이렇게 했더니 해당 Pre-Trap Handling 상황에서 trap_done이 0으로, 그리고 다음 TRAP_NONE일 때 다시 1로 올라오는 것을 보아 의도한대로 작동하는 것을 확인했다. 

근데.. 이러면 사실상 PTH의 마지막 state에서는 다시 1로 올라와야 PC의 갱신이 이루어지지 않나? 
마지막까지 0이면 다음 명령어가 없기 때문에 진행이 안될 것 같은데.. 
지금이야 tb에서 다음 시나리오를 정해주고 있기 때문에 흘러가는 것 처럼 보이지 이러면 안될 것 같다. 역시 고쳐야겠다.

아니다. 
혹시 몰라 첫 ECALL 시나리오에서 ECALL에게 필요한 클럭 3CLK 보다 더 많은 5CLK를 부여했었는데, 
해결 이후 Trap_handle_state가 11로 유지되면서 그대로 Trap_Done도 1로 상승한다. 
문제는 EBREAK인데.. 파형에서는 THS가 10 즉 WRITE_MCAUSE에서 1이 되었다가 다시 0이된다. 왜일까.. 다시한번 돌려보고 판단해야겠다.

trap_done을 WRITE_MCAUSE에서 별도로 1'b1으로 넣으니까 된다. 
여유 클럭 한 사이클을 넣어도 정상적으로 1로 되고, 3사이클 딱 맞게 두어도 다음에서 trap_done이 1로 돌아온다.

어라 파형에서 MRET시 csr_write_enable이 1로 나온다.. 왜지?
-파형 파일이 옛날거였다...

TC의 Trap_Done, CSR_WE 출력 신호 추가 및 tb 완료
CU의 Trap_Done 입력 신호 추가(for PC_Stall) 및 tb 완료

내일은 당직이니.. 운영체제랑 가상페이징 구현 방안을 강구해봐야겠다.
일요일에는 RV32I47NF 탑 모듈 설계로 진입한다.
화이팅!!!

# [2025.05.10.]
이 날은 당직이었는데, 가상 페이징에 대한 하드웨어적 지원을 위한 가이드라인 실마리를 찾기 위해 컴퓨터 구조 및 설계 책을 들여다보며 연구가 시작되었다. 
아래는 노트에 적은 내용들을 옮겨 적은 것이다.

## -아키텍처 수정사항-
"M" Extension 확장 시 ALUresult의 대역폭이 128-bit[127:0]이어야 한다.
컴퓨터의 곱셈 알고리즘에서, '피승수(multiplicand)와 승수(multiplier)을 곱한 결과는 n-bit 피승수와 m-bit 승수에 대해 최대 n+m-bit를 가진다.
즉, RISC-V에서 묘사된 것 처럼, 그 결과가 2 × XLEN-bit 크기를 가진다는 것이다. 
-> 컴퓨터 구조 및 설계 5판에서는 부호비트가 무시된다면 n+m 비트의 크기를 가진다고 했지만, RISC-V Unprivileged Architecture Manual I 에서는 2 × XLEN-bit 길이를 가진다고만 명시되어있다.
"MUL performs an XLEN-bit × XLEN-bit multiplications of rs1 by rs2 and places the lower XLEN bits in the destination regitser. MULH, MULHU, MULHSU perform the same multiplication
but return the upper XLEN bits of the full 2 × XLEN-bit product.
그렇다면 부호비트에 대한 것은 설계의 재량인가?
ISA에서 이를 규정하고 있어야 마땅한데...
하긴, 컴퓨터 구조 및 설계 5판에서 참조하고 있는 MIPS ISA와 RISC-V ISA는 플래그 사용 유무부터 근원적으로 다른 ISA라고 보아도 무방하다.

그렇다면, 일단 ChoiCube84에게 두 가지 선택지로 물어보아야겠다. 
1. Multiplication (곱셈) 연산용 128-bit result 별도 신호 출력
2. 기존 ALUresult 신호를 128-bit로 확장. XLEN-bit 결과들을 쓰는 기존 명령들은 zero-extension하여 출력.

128-bit 데이터가 필요한 모듈들을 따로 보아야하고 각 용도에 맞는 명령어별로 별도의 식별자와 로직을 둬야하는 1번은 아무리 생각해도 맞지 않는다. 
2번으로 해야...

아 애초에 RISC-V ISA에서는 "M"확장에서 명령어를 쪼개서 XLEN 크기로 lower XLEN-bit, upper XLEN-bit을 필요에 따라 명령어를 통해 인출 할 수 있도록 설계되어있다...
이러면 처음에 생각했던 대로 별도의 구조적 변경 없이 그대로 ALUresult 신호는 64-bit(XLEN)로 유지하면 된다..

## -아키텍처 수정사항 2-
## Privileged Architecture Research.
특권 구조 연구 중...
정리 노트.

3개의 특권 단계 (level)
Machine level, Supervisor level, User level

4개의 특권 모드 (mode)
Debug mode > Machine mode > Supervisor mode > Hypervisor mode

level과 mode는 서로 통칭하기도 한다. 

---
Privileged Architecture의 확장(Extensions) 접두사 정리.
- Machine level : Sm
- Supervisor level : 
  - Supervisor level Virtual memory architecture : Sv
  - Supervisor level architecture : Ss
- Hypervisor level : Sh
---

### Machine level Privileged Extensions
- Sm state en	(Smstateen)	: State Enable extension
- Sm csr ind 	(Smcsrind) 	: Indirect CSR access
- Sm e pmp	 	(Smepmp)	: Enhance PMP(Physical Memory Protection)
- Sm cntr pmf 	(Smcntrpmf)	: Counter Privilege Mode Filtering
- Sm r n m i  	(Smrnmi)	: Resumable Non-Maskable Interrupts **Frozen Specifications**
- Sm c deleg  	(Smcdeleg)  : Counter Delegation

### Supervisor level Privileged Extensions
- Sv32, Sv39, Sv48, Sv57	: Page-Based 32, 39, 48, 57-bit Virtual Memory System
- Sv n a p o t	(Svnapot)	: Naturally Aligned Power Of Two translation Contiguity
- Sv p b m t	(Svpbmt)	: Page-Based Memory Types
- Sv inval		(Svinval)	: Fine-Grained Address-Translation Cache Invalidation
- Sv ad u		(Svadu)		: A/D Bits hardware Updating
- Sv v ptc		(Svvptc)	: Eliding Memory-Management Fences on making PTEs Valid

- Ss state en	(Ssstateen)	: State Enable
- Ss csr ind	(Sscsrind)	: Indirect CSR access
- Ss t c		(Sstc)		: Supervisor-mode Timer Interrupts
- Ss c of pmf	(Sscofpmf)	: Count OverFlow and Privilege Mode Filtering

---

### RISC-V Privileged Instruction Set Listings
- Trap-Return Instructions
  - SRET	: Supervisor - level trap-RETurn
  - MRET	: Machine - level trap-RETurn
  - MNRET	: Smrnmi's return instruction **Frozen Specifications**
- Interrupt-Management Instrucitons
  - WFI		: Wait For Interrupt
- Supervisor Memory Management Instructions
  - SFENCE.VMA

---

### RISC-V CSR Address Mapping Conventions

CSR = 12-bit [11:0]

[11:8]  : Read and Write accessibility according to privilege level
[11:10] : Whether register is read/write or read-only
[9:8]	: Lowest Privilege level that can access CSR.

---

확장에서 추가적인 명령어들을 요하는 Unprivilege Architecture와는 달리,
CSR 레지스터 각각의 데이터들을 규약하고, 지원해야하는 확장들을 Privileged Architecture에서 다루고 있다. 
Privileged Architecture의 명령어들은 SYSTEM opcode로 모두 인코딩되어있고, 이는 두 가지 계열의 명령어들로 나뉜다.
1. CSR을 "원자적으로 읽고-변경하고 쓰는(Atomically Read-Modify-Write) 명령어 계열. Zicsr

2. 나머지 Privileged Instrucitons
- Supervisor level 및 debugger단에서는 SRET, MRET, WFI, SFENCE.VMA 이렇게 총 4가지 명령어들이 있다. 

Privileged Architecture ISA라는게 CSR을 읽고 그에 따른 행동이나 동작을 수행하는건 OS나 Kernel이기에
그것들이 쓸 수 있도록 필요한 정보들을 확장이라는 규격으로 다루어 매핑해두는 것에 가깝다는 느낌을 받았다. 

만약 CSR 0FF 주소의 11번 비트가 set 되어있는데 A라는 명령어를 수행하려고 한다? 
비트 set이면 hypervisor 인데, 이 명령어는 machine 단계에서 수행되는 명령어. Access denied, excpetion 올리기
이런 느낌이랄까.

이해한게 올바르다면, 개념학적으로 어려운 건 아니지만 작업량 자체만 보면 마냥 쉽지만은 않은 것 같다.
각 확장들의 Exception 조건들을 확장들에 맞게 모두 해둬야 하고
CSR 레지스터들의 각 값들을 우리 specification에 맞게 셋팅해두고
WLRL, WARL 규약에 맞게 각 CSR들 로직 설정해두고... Privileged Architecture를 점검해봐야한다.

# [2025.05.11.]

오늘은 RV32I47NF 탑 모듈 설계 합성
설계 합성하고 다시 docs로 오겠다.

가 아니라, Trap Controller와 Exception Detector를 구현하면서 생긴 다이어그램상 변경사항을 먼저 반영해야한다. 
그리고 Cache 구조의 일시적 중단으로 현재 합성할 RV32I47NF.R1의 메모리 구조 변경 또한 반영해야한다.
어차피 Cache가 없어지면서 Zifencei도 지원 못하게 되니까, RV32I47NF_noCache 이렇게 보다 그냥 RV32I46F로 해두면 될 것 같다. 
1. funct7 ED에 추가 완료
2. Trap_Done CU에 추가 완료
3. CSR_WE TC에 추가 완료
4. TC, CU의 CSR_WE 신호 OR처리 완료

이렇게 변경사항이 있었다. 모두 반영했다. 

이제 RV32I46F 탑모듈 설계하러 branch를 바꿔보겠다. 
어... Trap Controller를 구현한 branch인 feat/exception_detector의 이름을 Trap Controller로 바꾸고 push, PR올렸다. develop branch에 merge.
RV32I46F를 새 브랜치에서 하기 위해서는 해당 변경사항이 반영된 develop branch에서 해야하는데,.. 일단 별도로 파일 파서 개발하고 있다. 
내일 아마 PR 해줄테니까 괜찮을 듯.
다이어그램 수정이랑 github 브랜치 수정, arxiv 가입 말곤 한게 없네...
아 어제 연구 기록 남긴거..? 믕..
내일 더 하고 싶은데 내일은 취사지원까지 있어서.,. 되는데 까지 해보는거지 뭐
최선을 다해보자.
오늘은 여기까지. 

# [2025.05.12.]
생각해보니 Exception Detector에 funct7을.. 따로 추가 안했네
다이어그램에는 추가했는데 실제 verilog 파일에 추가 구현을 놓쳤다. 이 것 까지 하고 merge 해야겠다. 

이후 RV32I46F 만들고... 잘 해보자.

알고보니 브랜치를 잘못봐서 ED에 funct7 추가를 안한 줄 착각했었다.
commit 기록을 보니까 제일 먼저 구현한 거였는데.. 하하..
rv32i46f 탑 모듈을 생성했고, 신호를 선언하던 도중 Trap Controller의 reset신호가 rst로 되어있는걸 발견했다. 얘 혼자 신호 선언이 다르면 안될 것 같아서 다시 feat/trap_controller를 파서 수정하고 다시 merge할 예정. 

지금보니 Debug Interface 모듈을 구현해두지 않았던 것을 확인했다.
CSR_Addr_MUX와 CSR_WD_MUX를 구현하고, CSR Write Enable 신호를 CU의 write enable신호와 TC의 write enable신호를 OR처리해서 input 하는 것도 구현했다.
그러던 중, Debug mode시 ID로의 Instruction으로 입력되는 신호의 출처를 Instruction Memory, Debug Interface 중에 골라야 한다.
즉 Debug Interface에서 출력되는 [31:0] 명령어 신호가 있어야 하고 그의 이름이 있어야 신호를 파생하고 설정하는데 이 부분이 누락된 것을 확인.
하고 와야겠다. 아마 오늘 연등 시간 전까지는 RV32I46F 탑 모듈 설계가 끝날 것 같다.!

?질문 Instruction Memory가 자동으로 하위 2비트를 00으로 정렬한 값 만을 PC 주소로 받고 있는 것을 확인했는데.. 

    always @(*) begin
    instruction = data[pc[31:2]];
  end

이제 RV32I47NF(RV32I46F) 구조에서는 misaligned exception을 정식으로 처리하는데, 이러한 구조를 없애야하는 것이 아닌지? 아니면 그냥 놔둬야하는지?

!기록

문제 발생... 
Debug Interface는 본 구조에서는 간이 구현으로 특정 명령어를 고정으로 인출해주는 단순한 출력장치의 형태로 (Core입장에서는 입력장치) 구현하려고 했으나, 
"0xABADBABE"라는 데이터를 레지스터에 쓰기 위해서는 먼저 해당 레지스터를 비우고.. (Shift 명령어) 통째로 덧셈 (ADDI)을 해야한다. 
물론, 기존 x22 레지스터의 testbench 값을 토대로 어느 값을 더하면 x22 레지스터의 값이 ABADBABE가 될지 계산하여 ADDI 명령어 하나로도 해결할 수 있으나, 
이래서는 내부의 상황을 처음에 모르고 일단 명령어를 주는 Debug Interface의 취지에 맞지 않는 다는 생각이 들어 그렇게 하지 않으려고 한다.

사실 하나의 명령어만 주는 것이라도 일단 문제는 생긴다.
두 명령어시 생기는 문제는 다음과 같다.
메모리 특성상, 입력을 토대로 값이 인출됨. 
즉, Debug 명령어의 실행을 인지하고 데이터를 차례로 인출해야함. CLK에 맞춰서. 
이마저도 PC_Stall 발생시 중도 중지 명령어를 포함해야한다. 
생각했던 것보다 모듈의 복잡도가 증가하는 편. 

이걸 어떻게 고정값을 주는 걸로 할 수 있을까..

아! 그냥 탑모듈에서 신호를 하나 선언하고, 그 신호의 내용을 고정된 상수값으로 해두면 되겠구나! 32-bit 명령어로 인코딩해서!
하하. 이리도 간단한 문제를. 
이러면 명령어 두 개를 차례로 실행은 못하지만.. 아 명령어 두개로 하고 싶은데...

어차피 SLLI나 ADDI 는 싱글사이클로 처리가 가능하니까.. CLK에 맞게 하나씩 차례대로 출력하도록 해야겠다.
FPGA 구현이었으면 버튼 눌러서 했을 듯 ㅋㅋ

always @ (posedge clk) begin
    instruction = data[pc[31:2]];
end

기존 Instruction Memory 코드는 이렇게 되어있었는데... 이를 어떻게 클럭에 따라 차례대로 바뀌도록 할까.. 카운터를 둬야겠다.

완료.

원래대로면 오늘 안에 끝냈어야 했는데... 
아... 내일 오전 중에 Debug Interface testbench까지 마치고
오후 중에 RV32I46F 탑 모듈 구현이랑 testbench까지 해야겠다.

# [2025.05.13]
이렇게 되면 Debug Interface가 안쓰일때도 계속 동작하게 되니까 그냥 단순하게.. 기존 x22값에 덧셈으로 구현하기로 했다... 탑모듈에서 신호 추가하는 방식으로..
하물며 ABADBABE를 위해서는 12비트 imm 으로 계속 덧셈을 해나가야해서 오히려 번거롭고 명령어의 갯수도 늘어난다.
여태 구현했던 Debug_Interface는 추후 재설계가 이루어질거라 모듈 설계를 잠정 중단하기로 했고, 일단은 feat/debug_interface는 여기서 마무리하는걸로.
develop branch에 굳이 merge 할 필요는 없는 것 같은데 이런 경우는 어떻게 해야할지 모르겠다. 어차피 형태가 많이 달라질거라 그냥 폐기하는게 맞을 것 같다.
혹시 모르니 일단 남겨두는 걸로. 

Trap Controller의 testbench에서 수행했던 테스트 시나리오 그대로 Instruction Memory에 작성을 완료했다.

## Trap_Handler
// Trap Handler 시작 주소. mtvec = 0000_1000 = 4096 ÷ 4 Byte = 1024
// Trap Handler 진입 시 기존 GPR의 레지스터 내용들을 별도의 메모리 Heap 구역에 store하고 수행해야하지만, 현재 단계에서는 생략한다. 
// CSR mcause 확인해서 ecall이면 x1 = 0000_0000으로 만들기, misaligned면 x2에 FF더하기
// mret하기

### 이걸 RISC-V 어셈블러로 코드를 짜고,..

// 조건 분기; 비교문 작성을 위한 적재 작업
csrrs x6, mcause, x0	// 레지스터 x6에 mcause값 적재
addi x7, x0, 11 		// 레지스터 x7에 ECALL 코드 값 11 적재 (mcause가 11인지 비교하기 위해서는 해당 11이라는 값을 레지스터 넣고 레지스터끼리 비교해야하므로)	

// mcause 분석해서 해당하는 Trap Handler 주소로 분기
beq x6, x7, +12			// ECALL; x6과 x7이 같다면 12바이트 이후 주솟값으로 분기 = data[1029]
beq x6, x0, +16			// MISALIGNED; x6값이 0과 같다면 16바이트 이후 주솟값으로 분기 = data[1032]
jal x0, +16 			// TH 끝내기 (mret 명령어 주소로 가기)

//ECALL Trap Handler @ data[1029]
addi x1, x0, 0 			// 레지스터 x1 값 0으로 비우기
jal x0, +8				// TH 끝내기 (mret 명령어 주소로 가기)

//MISALIGNED Trap Handler @ data[1031]
addi x2, x2, 255 		// x2 레지스터(BC00_0000)에 FF 값 더하기. x2 = BC00_00FF

//ESCAPE Trap Handler @ data[1032]
MRET					// PC = CSR[mepc]

### 해당 어셈블러 코드를 이진법으로 만들어서 Instruction Memory에 코드했다.
// 조건 분기; 비교문 작성을 위한 적재 작업
	data[1024] = {12'h343, 5'd0, 3'b010, 5'd6, `OPCODE_ENVIRONMENT};
	data[1025] = {12'd11, 5'd0, `ITYPE_ADDI, 5'd7, `OPCODE_ITYPE};					

// mcause 분석해서 해당하는 Trap Handler 주소로 분기	
	data[1026] = {1'b0, 6'd0, 5'd7, 5'd6, `BRANCH_BEQ, 4'b0110, 1'b0, `OPCODE_BRANCH};
	data[1027] = {1'b0, 6'd0, 5'd0, 5'd6, `BRANCH_BEQ, 4'b1000, 1'b0, `OPCODE_BRANCH};
	data[1028] = {1'b0, 10'b000_0001_000, 1'b0, 8'b0, 5'd0, `OPCODE_JAL};

//ECALL Trap Handler @ data[1029]
	data[1029] = {12'd0, 5'd0, `ITYPE_ADDI, 5'd1, `OPCODE_ITYPE};
	data[1030] = {1'b0, 10'b000_0000_100, 1'b0, 8'b0, 5'd0, `OPCODE_JAL};

//MISALIGNED Trap Handler @ data[1031]
	data[1031] = {12'hFF, 5'd2, `ITYPE_ADDI, 5'd2, `OPCODE_ITYPE};

//ESCAPE Trap Handler @ data[1032]
	data[1032] = {7'b0011000, 5'b0, 5'b0, 3'b0, 5'b0, `OPCODE_ENVIRONMENT};	

CSR 주소의 데이터를 읽기만 할 땐 CSRRS+rs1=x0 패턴을 쓰는 것이 관례라고 한다... 
csrr x5, mcause 라는 어셈블러가 자동으로 csrrs x5, mcause, x0 으로 인코딩 되기도 하고, csrrw 같은 명령어는 해당 rd의 값을 바꾸기도 하니까.

무튼 이렇게 구현했다. 생각해보니 명령어가 제대로 나오는지를 tb 안돌려봤네 한번 돌려보고, feat/rv32i46f branch를 새로 파서 tb 진행해봐야겠다.

생각해보니 Debug 명령어는 하나이기에 테스트벤치 시나리오의 맨 마지막에 있어야 한다.. 위치를 조정해야겠다.

아 좀 쉬어야하는 시간인가보다. 이미 그렇게 되어있었는데 이걸 또 까먹었다.
몇 시간 동안 연속으로 하고 있으니 그럴만도 하다. 잠깐 PX 다녀왔다가 ChoiCube84의 PR 승인을 받고
RV32I46F 탑모듈 테스트 벤치로 넘어가야겠다. (15:07)

## Verilog에 익숙해지는 중. 탑 모듈에서 신호를 선언하고.. 인스턴스화 하는데 약간의 고찰을 했다. 
모듈간 연결 신호는 wire, 값이 바뀔 수 있는 신호는 reg로 선언하는 것.

그리고 모듈의 파생 시 문법은 얼추 이렇게 된다는 것.

[파생할 모듈 이름]   [파생이름]   (
    .모듈 내부 신호 (탑모듈에서 쓸 신호 이름)
)

## RV32I46F Top module Debugging
왜 ECALL까지는 제대로 들어갔고, CSR341(mepc)에 현재 pc값 쓰기까지 잘 됐는데 다음 PC값이 멈추지 않고 0000_0000으로 갱신 됐을까...
pc_stall이.. 0000_00BC 즉 ECALL에서 생기지 않고 다음 사이클에 생겼다..? 이 것 때문인가?

기존 trap_done을 TRAP 발생시 해당 PTH에 있어서 trap_done을 0으로 했는데, 
어차피 TC에서 trap_status가 0이 아닌 순간 모든 명령어에 있어서 trap_done 자체는 0이 되어야하니까 trap_done을 각 case마다가 아니라 case문 자체에 넣어보아야겠다.

그렇게 하려고 했는데 case 문에서 case 조건 선언 이전에 무언가를 적는 건 문법 위반이라 안된다. 

각 case의 FSM마다 원래는 FSM 초기에만 trap_done을 0으로 해두고, 그게 유지된다 생각하고 FSM 끝에 trap_done을 1로 하도록 했었다. 
이걸 이제 마지막 FSM 단계를 제외하고 각 FSM 단계마다 모두 trap_done을 0으로 하는 코드를 모두 심었다. 
이전 vcd와 비교를 하며 어떤 차이가 있는지를 확인해야하는데..

두 파형이 차이가 없다.. 실제 탑 모듈에서 잘 작동하는지를 봐야겠다. 

역시 차이는 없다. 
Trap Controller에서 Latch 합성 가능성을 없애기 위해서 case(trap_status) 문 전에 trap_done을 1로 해두었는데, 
어차피 초기에 reset 신호 들어올거기도 하고.. 
모든 case 문의 조건에 따른 수행에서 trap_done 신호에 대한 내용을 모두 다루고 있으니 괜찮지 않을까? 
한번 이렇게 해서 TC 에 대한 테스트벤치를 해봐야겠다.

여전히 똑같지만 문제를 조금 다르게 보는 시각을 발견했다.

애초에 PTH의 발동 자체가 한 사이클 느리다.. 왜지? 
이걸 어떻게 한 사이클 땡겨서 trap_status가 들어오자마자 해당 status 값 대로 수행하도록 할 수 있을까?

값의 변화를 모니터링하여 PTH를 수행하는 것을 조합논리회로로 always(*)로 하고, 
FSM의 진행을 위한 내용은 always(posedge clk or posedge reset)로 해서 인식 즉시 PTH를 수행하도록 하긴 했는데.. 
이러면 라이징 엣지에 맞게 작동하도록 된 로직들이 작동 안할 수도 있지 않나..? 
어차피 PC_Stall이 되기만 하면 되니까.. 괜찮으려나.. RV32I46F 탑 모듈 돌려봐야겠다.

어우 잘 된다!!!! 근데 mtvec 주소로 분기를 해야하는데 안된 것 같다. 
Trapped도 됐고, trap_target도 잘 출력됐고, pc_stall도 잘 풀렸는데... PC_Controller의 신호를 봐야겠다. 이 쪽 문제일 수도.

이런. next_pc값이 trap_target으로 선택되지 않았다. 이 것도 디버깅 해야할 듯.

PCC의 로직을 봤으나 역시 문제는 없고.. 
혹시나 PC_Aligner가 남아서 생기는 문제인가 해서 없애봤다.

다시 시뮬을 돌려 파형을 잘 들여다보니 AUIPC 다음 명령어가 misaligned된 JAL 주소로 점프하는 명령어임을 확인했고, 이 때 freeze가 발생하는 것을 확인했다.  
즉, next_pc는 현재 pc가 수행중일 때 이미 나와있어야 한다... 이래야 ED에서 확인을 하는데. 
차라리 next_pc의 misalign탐지를 PCC에서 해야하나? 이건 고찰이 필요하다. 아마 이것만 고치면 되지 않을까? 오늘은 여기까지.

# [2025.05.14.]
당직이었다. 

Verilog 디지털 설계의 길잡이, Palnitkar의 책을 읽으며 전반적인 문법 공부를 좀 하였다.
그리고 현재 RV32I46F의 디버깅 로그의 진행 현황을 정리해보았다.

## RV32I46F Debug Log
### 상황 1.
Trap Controller 발동 정상. 하지만 PTH가 첫 FSM 단계까지만 진행되고 mtvec 주소로 분기하지 않았다. 
PC값 0부터 다시 실행되는 파형을 확인하였다. 
- SYSTEM 명령어 인식 시, PTH(Pre-Trap Handling)이 다음 사이클부터 진행됨을 확인하였다. 
이 때문에 `trap_done`이 0으로 되어 `pc_stall`이 되고, PTH가 수행되며 진행되어야 하는데 그 것이 안된다. 

즉, SYSTEM 명령어 식별과 동시에 PTH 수행이 해당 식별 사이클과 동시에 이루어져야한다. 

### 상황 2.
Trap Controller의 `trap_status` 신호 조건문을 조합논리회로로 합성하여 (always (*) begin) PTH가 `trap_status` 입력 시 즉시 수행하도록 변경했다.
기존에는 (always(posedge clk or posedge reset) begin)으로 모든 동작이 posedge clk에서 동작하였었다. 
내부 FSM 갱신 로직은 여전히 순차논리회로로 하였다. 
- Trap Controller의 testbench에서 trap_status의 인식과 PTH 시작이 해당 신호 식별 즉시 같은 타이밍에서 수행되도록 변경사항이 의도대로 반영된 것을 확인했다.

### 상황 3.
RV32I46F 탑 모듈 테스트벤치에서 PTH가 마지막 단계 즉 mtvec을 읽어오는 동작까지 정상적으로 수행했음을 파형으로 확인했다.
하지만 여전히 PC의 주소가 Trap Handler의 주소인 0x0000_1000으로 분기하지 않는다. 
Trapped도 됐고, trap_target도 잘 출력됐고, pc_stall도 0으로 잘 풀렸는데 안됐다. PCC의 문제로 추측했다.
next_pc값이 trap_target으로 선택되지 않았음을 확인했다. 하지만 PCC의 로직 자체는 문제가 없음을 확인했다. 
- 혹시나 PC_Aligner가 남아서 생기는 문제인가 해서 없애봤다.

### 상황 4. 
RV32I46F의 탑모듈 testbench가 stop하지 않음을 확인했다. 29500ms에서 멈췄고, 강제로 중단시킨 뒤 생성된 파형을 확인하였다.
AUIPC 다음 명령어가 misaligned된 JAL 주소로 점프하는 명령어이다. 이 때 freeze가 발생한다. 
즉, next_pc는 현재 pc가 수행중일 때 이미 나와있어야 하는데, 그러지 않았기에 ED에서 이를 탐지하지 못하고 미정렬된 PC로 가버렸다. 
차라리 next_pc의 misalign탐지를 PCC에서 해야하나? 이건 고찰이 필요하다. 

# [2025.05.15.]
왜일까...
미정렬된 PC로 가버린게 애초에 맞나?
PCC자체가 조합논리라 클럭 관련된 문제는 없을거고
ED 자체도 애초에 next_pc 받아오고 이것도 조합논리라 바로 탐지되어서 수행되어야하는게 맞을텐데..
바로 탐지되어서 수행된다...?

JAL 명령어 자체는 사실 문제가 없다. 그 이후 next_pc가 미정렬된 값인 것이 문제.
JAL로 인해서 next_pc가 jump_target으로 바뀌는데 성공했고 해당 next_pc를 ED가 파악하는데 성공했다면
PCC내부에서 Trapped 신호를 입력받아 next_pc가 trap_target으로 바뀌어야한다.
아 이런. 
JAL 명령어를 수행하기 때문에 next_pc = jump_target으로 jump 신호를 계속 입력받고 있는데 그와 동시에
trapped 신호를 입력받고 있어서 next_pc = trap_target으로 race condition이 발생한 것 같다.
하물며 trap_target 즉 Trap Handler의 시작 주솟값은 PTH 의 마지막 FSM에서 인출되는데 그동안 Trap Controller에서는 trap_done이 0이므로
pc_stall신호를 Control Unit이 보내고 있을 터이다. 이러면 위의 두 신호에 대한 race condition에 덧붙여
pc_stall 신호 때문에 next_pc = pc 라는 것 또한 충돌하게 된다. 
이걸 어떻게 해결한담... 이게 문제 같은데..

정리하자면, 

## RV32I46F의 29500ms 문제 원인 접근 A
PCC의 next_pc 선택을 위한 제어 신호들의 race condition이 발생하는 것이라면?
1. JAL 명령어, Control Unit에서 Jump 신호 출력
   ▶ next_pc = jump_target
2. Exception Detector에서 next_pc가 misaligned인 것을 확인. Trapped 신호 출력
   ▶ next_pc = trap_target
3. Trap Controller에서 trapped 신호를 받아 PTH(Pre-Trap Handling) 수행을 위해 trap_done = 0.
   Control Unit에서 PC_Stall 신호 출력.
   ▶ next_pc = pc

즉, next_pc를 설정하기 위한 신호 3개가 race condition을 일으켜 시뮬레이션이 freeze되는 것이다.

어떻게 해결할 수 있을까?
야간에 생활관에서 불 켜두고 Verilog 문법에서 답을 찾기 위해 Palnitkar의 Verilog HDL : 디지털 설계와 합성의 길잡이 책을 갖고 찾아보았다.
내일 알아볼 것 :
1. tri, trireg의 신호 강도 조절을 통한 race condition 제어로 해결할 수 있는가?
2. 블록킹 / 논블록킹 할당 구문 및 타이밍 제어문(사건 기반, 준위 구동)을 통한 race condition 해결이 가능한가?
3. 제로 지연을 통한 race condition의 해결이 가능한가?

생각해보니 Trap Controller에서 MRET할 때 trap_target 즉 복귀 주소를 미정렬된 값까지 허용할 수 있게 코드를 짰었다. 이번 문제와는 별개의 내용이지만, 
```
`TRAP_MRET: begin
    csr_write_enable   <= 1'b0;
    csr_trap_address   <= 12'h341; //mepc
    trap_target        <= ({csr_read_data[31:2], 2'b0} + 4);
    debug_mode         <= 1'b0;
    trap_done          <= 1'b1;
end
```
이렇게 수정해서 mepc로 귀환할 때 미정렬된 주솟값으로 돌아갈 수 없게끔했다. 

탑 모듈에서 잠깐 가봤는데.. misaligned를 PC_Aligner를 다시 넣어서 넘겨봐도 이후 Trap Controller / Exception Detector 검증을 위한 trap 시나리오에서 next_pc값이 trap_target으로 정상적으로 선택 출력되지 않는다. 어디서부터 뭐가 잘못된걸까...

# [2025.05.16.]
당직이었다. 
그리고 언제나 그랬듯이 답을 향한 실마리를 찾아냈다.
당직 중에 문제에 대해 고찰을 하다가, 머리를 비우고 처음부터 검토해볼 겸 RV32I46F의 다이어그램을 왼쪽에서부터 (PC부터) 다시 하나씩 손수 그려보다가 불현듯 떠올랐다.

## RV32I46F의 29500ms 문제의 해결에 대한 접근 A.
PCC의 로직은 단순하며, 이미 충실하다. 문제 해결의 열쇠는 PCC 제어 신호의 근원지인 Control Unit에서 찾을 수 있지 않을까?
이 말인 즉슨, 신호 중첩 시, 그 모든 신호를 PCC에게 다 출력하지 않게끔 하면 이 race condition자체를 해결 할 수 있을 것이라는 생각이다. 
PCC 제어 신호들에 조건문을 사용해 그들 중 오로지 하나의 신호만 출력하도록 하거나, 또는
하나의 통합된 PCC 제어 신호를 PCC에게 출력하도록 하는 것.

## RV32I46F의 next_pc race condition 해결 방안 A-1
Control Unit에서 명령어를 식별한 뒤, jump, trapped, pc_stall 이렇게 각 신호별로 PC Controller에 주지 않는다. 
PC Controller Opcode, pcc_op 신호. 즉 PC Controller의 operation code를 주어,
PCC 내부에서 next_pc에 대한 조건 인식을 하나의 신호로부터만 수행되게 한다. 
// 왜 현대 시스템에서 μ-opcode; micro-opcode가 상용되는지 이해되는 순간이다. 물론, CISC 구조의 한계를 극복하기 위해 RISC 특성을 접목시키기 위한 특이성 개선이 주된 이유겠지만.

문제 파악에만 3일이 걸렸고, 이 답안에 오는 데에만 2일이 걸렸다. 
이제 이걸 내일 그대로 접목해보자. 잘 되겠지.

# [2025.05.17.]
아니, 안된다. 
문제가 그대로다. 뭐라도 하나 변하는게 있었다면 좋겠는데 절망스럽게도 결과값 하나 변하지 않았다.
pcc_op를 접목한 Control Unit과 PC Controller의 각개 testbench에서도 문제는 없었다. race condition까지 모두 테스트했었다.
뭐가 문젤까... 뭐가 문젤까..

처음으로 돌아가보자.
만약 race condition 문제가 아니라면?
기존 PC_Aligner가 있었을 때, next_pc가 자동정렬되면서 제대로 진행은 됐었다.
문제는 next_pc가 향하는 Program Counter 레지스터에 있나?
Program Counter 자체에 next_pc가 입력되고 나서, 해당 값이 변경되지 않는 것인가?
하지만 너무나도 단순한 모듈인데 문제가 있을리가..
아. 

## RV32I46F의 29500ms 문제의 해결에 대한 접근 B.
program counter의 값은 posedge clk에서만 인식된다.
"Exception Detector에서 next_pc를 기준으로 하는 것이 아니라, PCC에서 선택될 주소 소스값을 기준으로 misaligned 계산을 한다면 어떨까?"

이런 구조적으로 근원적인 부분을 간과해버리다니. 
대기업 설계라고 한 모듈에 한 사람씩 붙는 그런 수준은 아니겠지만 확실히 혼자서 수 십개의 모듈들과 수 백개의 신호들을 꽤차고 있어야하는 현 상황에서 이러한 실수는 피하기 쉽지 않은 것 같다. 
기존 설계는 next_pc값을 기준으로 misaligned를 판단하는 구조이다. 
next_pc값을 보고, 해당 클럭 신호 안에 misaligned 되어있다면 trapped를 하든 pc_stall을 하든 pc값을 '변화' 시키는 것이 전제되는 것이다.
하지만, program counter는 오로지 posedge clk에서 확인된 값만 갖고 있다. 
이 말인 즉슨 미정렬된 값이 들어가고, 그걸 trapping 하고나서 뭐 어떻게 저쩧게 하려고 한들 일단 PC에 misalign이 들어간 이후라 현재 들고 있는 PC값의 변경이 불가능해지는 것이다. 
그리고 이러한 클럭 기반 값 갱신 구조는 변경하는 것 자체가 안정성의 리스크를 지닌다.
program counter는 그대로 둬야한다. 다만, exception 처리를 다른 방식으로 구상할 필요가 있다. 
이러면.,., PC_Aligner가 아니라 checker를 둬야하나.. 그 위치에 misalign인 걸 확인할 모듈을.. 아니다. 이건 뭔가 설계가 너무 조잡해진다.
Exception Detector에서 next_pc를 기준으로 하는 것이 아니라, PCC에서 선택될 주소 소스값을 기준으로 misaligned 계산을 한다면 어떨까?

PC Controller에서 jump_target을 감지해서 next_pc = pc로 misalign시 pc_stall을 자체적으로 한다.
이러면 Exception Detector가 동시에 jump_target이 misaligned 인지를 탐지하고 정상적으로 PTH를 수행할 수 있다. (20:32)
바로 실행에 옮겨보자.

된다... (20:35) PCC에서 자체적으로 pc_stall을 하게끔 했는데, 시뮬레이션이 이제 멈추지는 않는다.
30번째 명령어가 제대로 파형에 찍혔다...
이제 PTH 수행하도록 Exception Detector의 신호를 조정해보자.

jump_target 뿐만 아니라 분기를 위한 주소들의 misalign을 모두 탐지해야한다. 
하지만 Branch의 경우 기존 43F 아키텍처 기반에서는 PCC에서 현재 pc값과 imm 값을 덧셈하여 계산한 값을 바로 next_pc로 출력하는 구조를 취하고 있다. 
jump_target은 alu_result 신호이기에 이를 Exception Detector에 입력신호로 같이 주면 됐지만, 이래서는 branch_target의 misalignment를 확인할 수 없다.
이를 해결하기 위해서, Branch Adder, Calculator를 두기도 조금 조잡해지니, Branch Logic에 Branch Target 즉 분기 주소를 계산하는 로직을 내장하기로 결정했다. 
일단, Branch Logic 모듈을 수정했다 가정하고 Exception Detector를 수정해보자.

PTH로 잘 넘어간다!!! 
trap_handle_status FSM도 잘 굴러가고 Trap Handler 주솟값으로 잘 분기했다!!!! (20:47)
근데 내가 Trap Handler 루틴에서 CSR의 주소를 잘못 명령어에 인코딩한건지 동작이 의도한대로 되지 않았다.
mret 명령어로 기존 mepc 값 데이터로 분기가 안된다.
그래도 뭐가 잘못된건지 파형에 찍힐 정도로 명확한 사소한 트러블이라 큰 문제는 되지 않는다. 그냥 바로 수정하면 되니까.

Branch Logic에 변경사항을 반영시켜야겠다. 새 branch!
완료. Branch Logic에 branch taken일 때만 주소를 계산하도록 기능을 추가하였다.
이제 Branch Logic 모듈에 PC값과 imm 값이 들어가서 branch_target 주소를 덧셈 계산해 출력한다. 
테스트벤치까지 마쳤다.

Trap Handler에 어떤 문제가 있는지 살펴보고 수정해야겠다. instruction memory branch..
Instruction Memory data[1024]부터 시작하는 Trap Handler 에서
csrrs x6, mcause, x0 을 하는게 목적이었는데, 명령어 인코딩을 12'h343으로 기존에 하여 프로그램이 틀어져 수행된 것을 확인하였다.
12'h342로 mcause에 해당하는 CSR주소로 고쳤다. 그랬더니 PTH가 제대로 동작한다. 다 잘된다.

아 EBREAK에서 뭔가 문제가 있다 사실 위에서도 pcc_op가 제대로 적용이 안되어 trap_target으로 분기가 안되는 문제도 있었지만 일단 해결했었는데..
EBREAK 이후 EBREAK 내의 명령어가 실행되어야 하는데.. 디버그 명령어가 나오질 않는다... 왜지???

오늘은 여기까지.. 시간이 다 됐다...

# [2025.05.18.]
Debug Instruction으로 왜 안넘어갈까.. 왜 파형이 debug_mode가 나올 PTH FSM단계에서 끊겼을까..
debug 신호 자체가 애초에 올라가질 않는다.. 왜지?
코드를 뜯어보며 조금씩 수정해보고 확인해보는데... 
탑모듈에서 이러쿵저러쿵 하다가 안되어서 Instruction Decoder에 MUX를 넣어보았다. 
instruction decoder에서 이제 instruction memory instruction과 debug instruction을 모두 받는다. debug mode도 식별한다.
instruction decoder에서 debug_mode 코드를 debug모드일 때 아무것도 안하도록 헀더니 debug_mode 자체는 잘 올라가는데 instruction decoding은 안된다.
뭐 당연하다. 근데 문제가, 이제 그걸 조건문 안에 넣어서 debug 모드 일 때도 디코딩을 수행하게끔 하면
그냥 안에 preset으로 opcode = 7'b0001100이런거 그냥 넣어도 바로 해당 타이밍에서 freeze가 걸린다. 뭔가 문제가 있다.

제어 신호를 그대로 받아서 그런가? 별도의 토글 플래그 레지스터를 만들어서 신호가 오면 1로 set되게 한번 해볼까?

어라 이상하다. 탑모듈에서 이게... debug_mode 신호가 탑모듈과 trap_controller에서 파형이 안잡히는데, flag는 해당 타이밍에서 올라간다.
뭔가가 신호가 다시 0이 되도록 하고 있다는 것 같다.
Trap Controller에서 기존에 debug_mode의 기본값을 0으로 항상 잡아놓는 코드로 구성되어있는 것을 확인했다.
어차피 debug_mode가 활성화 된 후 debugger에서 복귀하는데 MRET을 실행하고 MRET에는 debug mode를 0으로 되돌리도록 설계해두었기에 필요없는 내용일 것이라고 생각하여 없앴다.
근데 아직도 안된다... 왜지...

..
설마설마 혹시나 싶어서 문법을 바꿔보았다.
된다...

기존에 if (debug_mode) begin
	instruction = dbg_instruction
end else begin
	instruction = im_instruction
end
이걸

if (debug mode) instruction = dbg_instruction
else instruction = im_instruction으로 바꾸니까 된다...

저기서 debug mode로만 하면 또 freeze가 걸린다. 저걸 flag로 치환하니 잘 된다.
이제 여기에 ECALL로 debug 명령어로 정상 decoding되어 명령어가 수행된다..

탑 모듈을 하나 따로 파서 종합적으로 디버깅을 하던 참이라 기록을 그때 그때 남기지 못해서 장장 5시간 연속에 걸친 디버깅 사고의 흐름을 모두 담아내지 못했지만,
이렇게 RV32I46F의 완성이 되었다.

탑 모듈로 Instruction Decoder의 MUX를 빼서 구현해보았는데 잘 된다. 
완성... 2025.05.18. 12:01.

# [2025.05.19.]
브랜치를 관리하면서 하나하나 pr하고 merge하고 수행하는 것이 상당한 시간 소요와 작업의 제한을 불러오기에 위에 적은 디버깅과 구현 로그들은 대부분 더티파일
(branch 기록에 안남는 통합 파일)에서 구현하며 있었던 내용들을 적은 것이다.
오늘은 위에서 되어야했던 더티파일의 내용들을 본 메인 파일에 반영시키면서 git 로그들을 남겼지만 
되던게 안되어서 이미 구현 성공했던 RV32I46F를 다시 디버깅해야했다. 

가장 큰 문제는 Trap Controller에서 블록킹 논블록킹 구문을 구별해서 썼어야했는데 실력 미숙으로 더티 파일에서 옮기면서 잘못 작성했기에 발생했다.
ebreak에서 PTH가 돌아가질 않았는데, 블록킹 구문으로 바꾸면서 해결했고, 마찬가지로 Instruction Memory에서 명령어 수정사항 있던걸 반영하지 않았기에 해당 내용도 반영하였다.
그리고 현재 브랜치에서 제대로 탑 모듈 동작이 된 것을 확인하고 develop branch에 merge했다.

ChoiCube84는 현재 입원중이라 개발을 직접적으로 하지 못하는 상황이라 코드 리뷰를 맡아주었고, 그 중 Branch Logic에서 branch_target 계산하는 내용을
굳이 branch_taken 일 때만 한다고 전력 효율 향상이나 그런 효과는 생기지 않을 것 같다길래 한번 찾아보았고 RTL 레벨에서 설계할 때 착각하는 내용일 뿐 실제로 그런 게 반영되기에는 미미하다는 것을 알았다.
그래서 해당 내용을 Branch Logic에서 always (*) begin branch_target = pc + imm; 하고 바로 case문으로 branch 종류별로 넘겨서 모든 상황에서 branch target은 그냥 다 계산되도록 변경하였다.

그리고 변수 관련해서 j_target_lsbs 같은걸 풀 네임으로 적어달라고 하기에 역시 급하게 구현하느라 정신 없어 놓쳤던 부분이라 고치기로 했다. 
이걸 고치고 나서, 46F Architecture 문서화를 진행하고 파이프라인 구현으로 넘어갈 생각이다. 

파이프라인 레지스터는 오전 중에 코드 리뷰 진행하며 틈틈히 작성했는데, 
다이어그램상 불필요하게 파이프라인 레지스터에 연결된 신호들이나(ID/EX 레지스터의 rs2, rd, IF단계의 PC를 ID/EX에 연결했다던가 등), 
필요한데 연결을 깜빡한 신호들 (레지스터 쓰기 근원지 값 선택 신호 register write data src select 신호가 EX/MEM에서 MEM/WB 레지스터로 나와야하는데 없었다.)을 찾아볼 수 있었다.
해당 내용들을 다이어그램에 새롭게 그렸고, 파이프라인 레지스터의 구성 자체는 다 했다. 
꽤나 많은 반복작업을 요해서 눈이 아팠다.

완료. 이제 문서화 작업만 하면 RV32I46F 작업은 모두 마무리 된다. 
원래 캐시 구조를 접목시키기로 하였으나, 이는 6월에 파이프라인 작업을 하면서 ChoiCube84가 퇴원하는대로 시간을 맡겨보도록 해야할 것 같다.
마음 속으로는 파이프라이닝이 조금 더 컴퓨터 구조론의 정석에 가깝다고 생각을 했어서 이걸 근거로 파이프라이닝을 먼저 한다고 하려 했는데,
David. A. Patterson 컴퓨터 구조 및 설계에서 물론 프로세서 설계에 메모리와 파이프라이닝 이후 캐시 구조가 나오긴 하지만 캐시구조 또한 정석에 속하는지라 (메모리 계층구조)
이걸 근거로 들기는 조금 그렇다고 생각했다. 오늘 안에 46F 설계를 끝내고, 파이프라인 레지스터에서 나오는 신호들을 각 모듈에 연결해볼 참이다. 
RV64I 확장이나 M, A확장은 파이프라이닝 이후에 할 것이다.
마감 기간이 7일 남짓에 당장 내일 당직근무라서 많이 일정이 빡빡하긴 하지만 어쩌겠는가. 해보는 수 밖에.
연등 시작. (22:05)

46F Architecure의 specification을 작성하던 중 설계와 구현에서 발생한 괴리로 인해 더 이상 쓰이지 않는 신호들이 다수 있다는 것을 확인하였다.
Exception Detector에서 funct7 신호를 뺐고, Data Memory에서 MemRead와 같은 신호들을 뺐다.
그리고 BE_Logic에서 47NF 구조에서 쓰일 예정이었던 BEDC_WD를 BEDM_WD로 바꿨다. (Byte Enabled Data Cache Write Data -> Byte Enabled Data *Memory* Write Data)
이를 RV32I46F.R5v2로 명명했다.

46F Architecture의 문서화가 모두 끝났다. 
휴. 이제 정말로 다음 단계로 나아갈 차례인 것 같다.

하나의 완성! 그것은 결코 끝이 아니다.
승리의 덧없음은 이미 그 성취된 승리의 앞에 새로운 승리가 마련되어 있고, 새로운 승리를 획등하기 위해 겪어 내야만하는 이전보다 더 가혹한 시련이 기다리고 있는 때문이다.
그 도전을 향한 과감한 도약은 이미 하나의 승리로 성취도어 있고
그것이 승리였기에 새로운 도전은 위대한 도전이 된다.
								- 갈매기의 꿈, 리처드 바크/ 강민우

23:40... 시간이 여유롭진 않지만 일단 하는데 까지 해보자.

RV32I46F의 파이프라인 버전 다이어그램의 초안을 완성했다!
오늘은 여기까지 ㅎㅎ., 계속 달려나가자!!!

# [2025.05.20.]
당직이었다.
음.. RV32I46F에서 생각해보니 데이터메모리가 캐시구조화 하면서 변경되었던걸 간과하고 그대로 진행했던 것 같은데
이를 확인해볼 필요가 있는 것 같다.

# [2025.05.21.]
확인해보니 256-bit 폭으로 Data Memory가 값을 출력하고 있어서 정상적인 작동을 기대하기 어려운 파형임을 탑모듈 vcd 에서 확인했다.
따라서 이를 feat/data_memory branch를 파서 별도의 기존 43F Architecture 기반 데이터 메모리 모듈을 추가했고
여태 만들어진 캐시 구조 기반 (43FC Architecture) 데이터 메모리는 Data_Memory_For_Cache.v 라는 이름으로 분리했다. 
Data_Memory_tb.v 즉 테스트벤치에서는 크게 달라진 것이 없어 Read Data가 기존 256-bit 되어있던 걸 32-bit로 바꾸고 주석처리로 추후 Cache 구조 기반 시 블럭 길이만큼 하라고 적어두었다.

파이프라인 해저드 유닛들의 설계를 정리해보고 있다. 2025.04.01에서 발췌하여 정리중.

==========
## Hazard Unit design

[입력 신호]
ID_rs1	(from Instruction Decoder)
ID_rs2	(from Instruction Decoder)
ID_rd	(from Instruction Decoder)

[출력 신호]
Hazardop (to Forward Unit)

[Logics]
A 명령어의 rd가 B명령어의 rs1, rs2 값과 같은지 비교한다.

instruction fetch를 거쳐 decoding 단계에서 rd, rs1, rs2의 값을 확인할 수 있다.
즉, ID 단계의 rd, rs1, rs2를 받아와서 기록을 하고
다음 클럭 사이클에서 기존에 저장되어있던 rd값과 방금 받아온 rs1, rs2 값을 비교한다.
비교 결과 같다면, Hazard op를 Forward Unit에 출력하여 Forward Unit이 전방 전달을 처리할 수 있도록 한다.
동시에 현재 받아온 rd값을 기존의 rd값에 갱신한다.


[Note]
해저드 검출이 곧 Hazard Unit의 본래 설계 목적.
1. 데이터 해저드
명령어의 종속성에 따라 이전 명령어가 끝날 때 까지 현재 명령어를 중단시켜야하는 경우
RAW계열. Read After Write. 쓰기 이후 읽어야 하는 경우에 해당 명령어가 모두 끝나야 메모리나 레지스터에 적히는데,
거기까지 생기는 빈 클럭들이 생기니까(그 값이 쓰이지 않은채 진행되면 프로그램의 문맥이 사라지고 의도한 결과를 낼 수 없다.)
버블을 삽입하여야한다. 하지만 버블 삽입만 해서는 성능이 많이 떨어지게 되니, 어차피 해당 선행 명령어의 결과값은 레지스터나 메모리에 WB되기 전에 나오게 되니
해당 쓰여지기 전 값을 현행 명령어의 소스값으로 전달을 해주는 것이다. 
이를 전방전달 방법이라고 하고, 이를 구현한 것이다.
-파이프라인에서 수행하는 명령어들 끼리의 종속성을 알아야한다.
과거 처리되어야할 레지스터 주솟값이 현재 수행하고자 하는 명령어가 참조하는 레지스터인지 확인해야한다.
A 명령어의 rd가 B명령어의 rs1, rs2 값과 같은지 비교.
instruction fetch를 거쳐 decoding 단계에서 rd, rs1, rs2의 값을 확인할 수 있다.
즉, ID 단계의 rd, rs1, rs2를 받아와서 기록을 하고
기존에 저장되어있던 rd값과 현재 받아온 rs1, rs2 값을 비교하여 같다면 전방 전달을 사용한다.
그리고 현재 받아온 rd값을 기존의 rd값에 갱신한다.

이렇게 데이터 해저드가 발생했는지를 알 수 있다.
이 데이터 해저드 발생 유무를 Forward Unit으로
실제 전방전달 방법을 처리하는 모듈에 알려준다.


## Forward Unit design

[입력 신호]

[출력 신호]

[Logics]
Hazardop로 데이터 해저드가 발생했음을 알고, 선행 명령어 A의 결과(레지스터파일에 결과적으로 쓰기 되는)에 해당되는 데이터를
현행 명령어 B의 유형에 맞게 ALUsrc 중 하나로 적절히 전달한다. 

[Note]
==========

Hazard Unit, Forward Unit에 대한 설계 내용을 46F_5SP_Architecture 폴더에 정리해두었다.

# [2025.05.22.]
And now, the end is near.
파이프라인들을 실제 파일로 설계해보자. 
IF_ID Register
ID_EX Register
EX_MEM Register
MEM_WB Register
총 4개의 파이프라인 레지스터를 만들었다. 모두 RV32I46F_5SP_R1 다이어그램을 따른다.

IF_ID Register, ID_EX Register까지 테스트벤치를 마쳤고, reset신호와 flush 신호, 그리고 파이프라인 레지스터의 다음 클럭에 현재 값 출력 로직까지 모두 검증하였다. 
내일은 EX_MEM, MEM_WB 레지스터의 테스트 벤치를 해야한다.
오늘은 여기까지. 테스트벤치까지 잘 돌아가서 할당량에는 못미치지만 만족했다. 얼른 내일이 찾아왔으면.

# [2025.05.23.]
개인정비시간. MEM_WB 레지스터까지 테스트벤치를 모두 마쳤다. 
20:06.
아차. 지금보니까 Register File의 Write Enable 신호와 CSR File의 Write Enable 신호를 파이프라이닝 해두지 않은 것을 확인했다.
이러면 안되는데. 애초에 Write Back 과정이 Register Write back인데 이러면 논리적으로 맞지 않는다. 
CSR의 Write Enable은 Trap Controller에서 나오는 과정이 정상적인 프로그램 수행이 아니라 예외적 수행이므로 파이프라인이 flush되며 즉시 수행해야하는 것이니
이렇게 직접 연결 (direct) 해도 되지만, 여전히 Zicsr 같은 정규 프로그램 명령어를 위해 Control Unit에서 나오는 CSR Write Enable 신호는 파이프라이닝 되는 것이 맞다.
해결했다. ID_EX, EX_MEM, MEM_WB 레지스터 모두에 register_write_enable신호와 csr_write_enable 신호를 추가하였다. 테스트벤치도 모두 마쳤다.
이제 기존 RV32I46F에서 5SP(5-Stage Pipeline) 탑 모듈을 만들어서 파이프라인 레지스터와 배선을 연결하여 1차적으로 동작을 확인해야겠다.
물론, 명령어들이 데이터 해저드를 일으키게끔 선행 명령어-후행 명령어 유기성을 가지고 있기에 값은 이상하게 나오겠지만 동작하는가?를 보는데 일단 1차 확인의 의의를 둔다. 
20:46.

---연등시간---
연등시간. 밀린 devlog를 쓰고 이제 위에서 말한 탑모듈 1차 작업에 착수한다. 22:19.
위 파이프라인 레지스터들을 배치하는데 있어, RV32I46F의 PCC op micro opcode 구조가 문제가된다.
Jump나 PC_Stall같은 정보들을 담고 있고, 이게 각 신호마다 어느 파이프라인 단계에서 PCC로 출력되어야하는지가 다른데, 이를 PCC에서 하나의 통합 신호를 타이밍 맞게 구분하는 것은
너무나도 복잡해지는 필요 이상의 수요를 남긴다. 
어차피 기존에 생기던 race condition이라고 착각했던 문제는 pcc op로서가 아니라 PC의 특성 문제였으므로 PCC op 구조를 빼도 정상 동작해야한다. 
때문에 PCC를 기존 pcc op가 없던 구조로 roll back 했고 pcc op를 둔 모듈은 향후를 위해 혹시 모르니 남겨두었다. 

아차. 파이프라인 레지스터들을 탑모듈에서 선언하며 알게 된 것. 
Reg Write 신호가 파이프라이닝 되었다는 것 자체가 쓰기 주소도 같이 들어가야하는건데 rd값을 그냥 그대로 디코딩해서 주고 있었다. 이를 파이프라이닝화 했다.
탑 모듈에서 신호 선언으로 일단 넣었고, 다시 feat/pipeline_registers 브랜치로 가서 해당 내용을 추가해야겠다..
모두 추가했다. 완료. 오늘은 여기까지.

# [2025.05.24.]
이제 Hazard Unit이랑 Forward Unit, Branch Predictor를 설계할 차례다. 

**PC_Controller** 모듈에서 저번에 PCC_op 코드를 뺐었는데, 향후 Branch 시 `Branch Target` 주솟값은 **Branch_Predictor**에서 담당하기 때문에 현재 롤백된 PC_Controller에 있던 imm값을 없애고, `branch_target` 신호를 추가하였다. 

이제 Hazard Unit을 설계해보자.

Hazard Unit을 모두 설계했다.
flush 관련 부분을 설계하면서 조금 의아해진 부분이 있어 검토를 다시 해봤는데,
jump 명령어 수행시나 branch prediction이 틀렸을 때 파이프라인 레지스터들을 flush해야한다.
해당 정보가 나오는 순간은 EX 단계이며, EX/MEM, MEM/WB에 담긴 정보는 해당 순간 선행 명령어이므로
flush 되면 안된다. 때문에 해당 레지스터들에 대한 flush 신호는 필요없다.
(명령어상에서 특정 파이프라인을 flush하라는게 있는 것도 아니고)
남은건 IF/ID, ID/EX인데, ID/EX를 flush했다간 현재 jump/branch prediction judgement EX 단계의 진행 맥락을 잃어버리므로 ID/EX는 flush해선 안된다. 
때문에 IF_ID_Register만 flush하는 것으로 결정했다.
물론 탑모듈에서 합성하다보면 알겠지 하하. 

이렇게 Hazard Unit에 대한 설계가 끝났고, 테스트벤치도 완료되었다.
코드를 짜면서, Hazard op 신호에 대해 애로사항이 좀 있었는데,
combinational logic을 구성하는 특성상 초깃값을 hazard_op = 0;을 잡고
조건문 충족 시 hazard_op = 1'b0; 을 하는 경우가 대부분이다.
허나 이렇게 하면 파형에서 순간적인 펄스만 생성되고 코드에 따라 다시 0으로 돌아가버려서
해당 로직을 수행하기 위한 시간이 없어지는데
이를 해결하기 위해서 flag를 넣어 조건문 안에 hazard_op대신 hazard_flag를 두고
그 밖에서 hazard_op = hazard_flag로 하여 해당 신호의 변화 이전까지 combinational logic에서도 값을 유지할 수 있다는 것을 알게 되었고 구현할 수 있었다.

예전에 RV32I46F 싱글 사이클 모듈 구현할 때 debug_mode 에대한 경험이 이번 문제를 수월하게 넘어가게 해주었다.
단번에 펄스 현상 때문에 tb에서 원하는 결과값이 나오지 않는 다는 것을 유추할 수 있었고
로직에 대해서도 직관적으로 틀린 부분이 없다는 것도 단박에 알 수 있었다. 
flag를 한번 그 때처럼 해보자 그 때도 됐었으니까 하는 것도 한 몫했고.
어디서 본 적 없는 내 아이디어긴 한데, 다들 이런 식으로 하지 않을까 싶다. 

연등 시간 끝.
아.. 주말외출만 아니었어도 2비트 Branch Predictor까지 만들 수 있었을 것 같은데..
내일 그래도 어느정도 할 수 있을 것 같다.

# [2025.05.25.]
원래대로면 파이프라인 레지스터들을 먼저 탑 모듈에 해보고 타 파이프라인 해저드 모듈들을 구현하고 합성해볼 계획이었지만
디버깅할거면 한번에 다 하는게 효율적이겠다는 생각에 일단 해저드유닛들을 먼저 다 설계해보고 있다. (난이도는 훨씬 올라가겠지만, 설계한 아키텍처가 옳다 믿고 하는 수 밖에 없다. 시간이 없으므로.)
어제는 Hazard Unit까지 설계했으니 이제 Forward Unit을 설계해보자. 

Forward Unit을 설계하는 중, rs1 값이 선행 명령어의 rd값과 겹쳐 rs1을 전방전달해야하는지,
rs2값이 겹쳐서 rs2를 전방전달해야하는지, 아니면 둘 다인지를 구분하기 위한 식별자가 필요하다는 것을 느꼈다.
그래서 기존 Hazard Unit에서 hazard_op 신호를 단순히 데이터 해저드가 발생했다는 것을 알리기 위한
1-bit 신호로 사용했었는데, 이를 2-bit로 확장해서 0번째 비트가 rs1 해저드, 1번째 비트가 rs2 해저드로 인식할 수 있게끔 Hazard Unit을 수정했다. 

다시 Forward Unit 설계로 되돌아가야겠다. 
설계 완료.
Forward Unit은 Hazard Unit으로부터 2비트 데이터 해저드 식별 신호인 hazard_op를 받아 2'b01이면 rs1 해저드, 2'b10이면 rs2 해저드, 2'b11이면 둘 다, 2'b00이면 해저드 미발생으로 처리한다.

동시에 hazard_op가 활성화되어 데이터 해저드가 발생했음을 알게 되면, 
ALU의 source 를 정상적인 데이터 흐름에서 오는 값을 나타내는 값인 2'b01값에서 2'b10으로 변경하여 전방전달된 source 값을 입력받아 연산할 수 있도록 한다. 
이 ALU source에 대한 MUX는 RV32I46F_5SP top-module에서 구현될 예정이고, 2'b00은 미선택을 의미하기 위해 남겨두었다.

hazard_op를 통해 어떤 해저드인지를 알게 되면 입력된 현행 명령어의 opcode값을 기반으로 어떤 값을 전방전달시킬지를 선택한다. 
load라면 Data_Memory 모듈의 MEM_read_data 신호를 포워딩하고, 
SYSTEM 명령어라면 (csr등) CSR File의 MEM_csr_read_data, 
LUI면 MEM_imm, 
JAL이나 JALR이면 MEM_pc_plus_4. 
나머지는 모두 MEM_alu_result를 전방전달 하도록 했다. 

탑모듈에서 잊지 말고 normal-forward source select MUX를 구현하도록 하자. 

이제 Branch Predictor의 구현이 남았다. BHT까지 있는게 좋겠지만.. 일단 단순 2-bit FSM으로 구현해보고 탑 모듈 합성으로 모두 잘 동작하면 그 때 추가 구현하는 것으로 한다.
계속되는 이상의 추구보단, 기대에 미치지 못하더라도 완성을 하는 것이 노력의 결실이 될테니까.

단순 2-bit FSM 기반 Branch Predictor를 구현했다. 워후. 
설계하면서 기존 5SP 설계에선 없던 EX_branch 신호를 Branch Predictor에 추가했다.
Branch 신호 자체를 파이프라이닝한 것. 
PR에도 올린 내용이지만, Branch Predictor의 내부 4단계 FSM (Strongly Not Taken, Weakly Not Taken, Weakly Taken, Strongly Taken)의 갱신을 위해서는 해당 시점이 branch인지를 식별해야한다.
해당 식별 신호가 없으면 branch신호가 아닌데도 현재 prediction counter의 값을 보고 계속 업데이트를 하게 되니까. 
그래서 추가했고, 이를 RV32I46F_5SP.R4 다이어그램에 반영했다. 벌써 101번째 PR이다. 
이젠 테스트벤치 작성도 쉽지 않다. 파이프라이닝 시점에 맞춰서 값을 넣고, 파형이 나와서 검증 할 때도 그걸 전제하고 현재의 값이 아니라 원하는 시점의 값을 정확히 봐야하기에 꽤나 시간걸렸다.
저녁 먹기 전까지 여기까지 마치려했는데 딱 맞출 수 있었다. 이제 밥 먹고 나서 탑모듈에서 합성하고 디버깅을 할 차례다.
으하하. 제일 큰게 남았다. 잘 해보자. (17:29) 

탑모듈 검증 시작. 일단 돌아는간다.
WB레지스터에 register_write_data가 잘못 선언되어있다. 이걸 byte_enable_logic_register_file_write_data로 바꿔야한다.
또한, 이제 파이프라이닝 구조에서 Branch Predictor가 branch_target을 계산한다.
branch_prediction_miss 신호에 따라 0일경우 계속 IF단계의 pc+imm값을 branch_target으로 출력하고,
만약 틀렸을 때, 그 시점이 판정된 EX단계에서 원래 분기했어야할 주소인 EX_pc값과 EX_imm값을 입력받고 있어 해당 값을 branch_target으로 출력한다.
때문에 기존 스칼라구조 (Single cycle 구조) 46F 아키텍처에 있던 Branch Logic의 branch_target 로직을 없애야한다. 
아니 그래도 값들이 이상하네 왜 register file에서 값이 제대로 안나오지

# [2025.05.26.]
작성일은 2025.05.29. 그 며칠동안, 인생을 걸고 혼신을 다해 달려나가느라 그 어떠한 기록도 남기지 못했다.
지금 작성하는 내용은 그 때의 회상기록이다. 
더티파일을 만들어서 그걸 디버깅하는 기록. 실제로 본 RISC-KC 에서 더티파일의 완성을 기록화하기 위해 하나씩 디버깅하면서 하는데, 더티파일에선 없었던 상황이 생긴다거나, 있던 상황이 없다거나 하는 경우가 생겼다.
이 점 감안하고 기록을 보길 바란다. 

밤새 생각하다 잠들고 아침점호 끝나자마자 사지방가서 밥도 굶고 파형분석했다. 요 며칠 동안 개발가능한 시간엔 밥도 안먹고 계속 하는 중.
28일부터 FPGA 구현을 위해 교육을 들으러 가고, 그 때 가서는 이미 개발이 마쳐져있어야하기 때문에 정말 시간이 없다. 내일이 사실상 마감.(27일)
분기예측기도 만들었고, 포워딩유닛이랑 해저드 유닛, 파이프라인 배치까지 모두 다 했는데 드랍되는건 너무 마음 아플 것이다. 
생각보다 PR과 commit, branch 관리에서 시간소요가 엄청나다. 때문에 오늘부터는 더티파일을 만들어서 먼저 완성을 목적으로 나아간 뒤, 이후 차차 해당 더티파일에서의 변경사항들을 commit하는 것으로 하겠다. (지금 작성일 기준 더티파일에 대한 commit을 하고 있다.)

문제 1. 레지스터가 자꾸 xx00_00bc 이런 식으로 나온다. 
- 레지스터 초기화 로직 작성해서 (initial) 0000_0000으로 모든 값을 시작하도록 했다. 이로서 레지스터의 파형엔 문제가 없어졌다.
(작성일 기준, 이상하게 해당 현상이 파형에서 잡히지 않는다. Register FIle에 해당 로직을 추가하지도 않았는데.. 뭐지?)

문제 2. imm값이 원활하게 나오지 않는 것 같다. 파이프라인 WB_raw_imm이 x값이다. 근데 이건 어찌저찌 해결한 것 같고 (아마 파생문제였을 듯.)

문제 3. Register에서 소스로 rs1 입력은 잘 되는데 해당 값이 나오질 않는다. 

ALU source값이 제대로 나오질 않아 찾아보니 탑 모듈에서 ALU 소스에서 포워딩된 값을 쓸 수 있도록 MUX를 만들었어야 했는데, 누락되어있었다. 수정했다.
또한 Branch Predictor의 EX_branch_taken 신호가 제대로 연결되어있지 않아 수정했다. 

trapped에서 trap_done으로 파이프라인 stall 기준 신호 바꾸니까 기존에 PTH 수행 후 pipeline stall로 Trap Handler 주솟값 분기가 이루어지질 않았는데, 이를 해결할 수 있었다.
PTH끝나고 정상적으로 stall 풀려서 트랩핸들러 넘어간다.

csr_write_enable 신호가 Trap Controller에서 나오는 신호와, 파이프라인되어 Control Unit에서 나오는 신호를 OR 처리했어야했는데, 탑 모듈에서 누락되어있어 수정했다.

Branch Predictor에서 branch prediction Strongly Not Taken이 기본값이라 후행명령어를 그냥 수행한다. 근데 분명 prediction이 틀렸는데 EX단계의 pc+imm값으로 분기하질 않는다.
branch_target값도 해당 주소로 잘 나오는데, 왜지?
일단 1차적으로 pc값을 IF_pc 라는 있지도 않은 신호를 파생하던 문제를 발견해서 수정했다. 잘 됐는데 이상하게 pcc의 branch taken은 0이다. 왜지?
아무래도 기존에 branch_taken을 branch_prediction값을 파생시켜서 생긴 문제로 보인다.
branch_estimation과 branch_prediction_miss로 신호를 분리해서, 실제 taken시 branch_Target. estimation이 참이면 마찬가지로 b_target으로. 아니면 그냥 넘기는 방식으로 했다.

이런. WB 포워딩이 필요한 사례가 발생했다.
188611ps 부분에서, WB에서 retire한 명령어가 rd 주소에 쓴 값을 후후행 명령어가 이미 EX단계로 와서 해당 갱신된 rd값을 들고있지 않는 문제가 발생한다. 포워딩유닛에서 WB단계의 포워딩도 구현해야한다.
오늘은 여기까지.

# [2025.05.27.]
EX_jump에서 misaligned 시 일단 jump라서 NOP flush 되는데, 이것 때문에 jump에서 misaligned 되었다는 문맥이 없어져
Trap PTH가 1단계만 진행되고 그냥 다음 ADDI x0 x0 0 으로 넘어가서 TH가 안되는 상황 발생했다. 
-> trapped 신호를 Hazard Unit에 연결, trapped 가 올라가면 파이프라인 레지스터 ID_EX_Register, EX_MEM_Register를 stall함. ID_EX_Register stall은 PTH가 될 때 까지 해당 문맥을 유지하기 위함이며, EX_MEM_Register는 비정상 명령어의 선행 명령어는 끝까지 수행이 보장되어야하므로 stall 함. 
PTH는 최소 2Cycle. 때문에 EX 문제 발생시 WB단계는 이미 WB처리 끝나고, stall되어 MEM에 있던게 WB으로 넘어가면 WB처리가 끝남. 이렇게 선행 명령어가 끝. 근데 MEM_WB_Register는 별도 처리 없냐? ㅇㅇ 없음. 선행 명령어 두개가 이미 끝났고 어차피 같은 주소에 같은 값 두 번 적는다고 현재 시스템에서 데이터 문제가 생기지는 않기 때문. 

## Branch Prediction 실패 이후 해당 실제 분기 주소로 분기하지 못한 문제에 대한 내용.
PC는 클럭신호에 따라 주솟값을 그 이전에 지장된 값을 출력하기에 branch_prediction_miss시 EX단계의 계산값을 PCC에 주고 그걸 PCC가 PC한테 전달을 한다고 해도 해당 값으로 분기하지 못한다. 
때문에 이 EX단계의 주소계산을 Branch Logic으로 옮겼고, PCC에서 brnach_estimation_target과 branch_target_actual 두가지 신호로 동시에 받고있어 조건문을 통해 prediction 이 맞는지 틀린지를 판단 후 PC에게 next_pc를 해당 주소로 출력할 수 있도록 했다.
근데 왜 branch_prediction_miss가 한번 1로 되면 계속 1이지? RTL 코드에서 조합회로 조건문 미충족시 기본값을 0으로 해두는 걸 적용안했나부다. 이걸 해결하면 끝인 듯.

# [2025.05.28.]
완성이다. 00:54.
KAIST IDEC에서 교육을 받기 위해 오늘 출발한다.
Xlinix FPGA 구현을 위한 교육이다. 3일 과정인데, 이제 더티파일에 작업하면서 기록 못한 변경사항들을 하나하나 commit, PR을 넣고
5월 안에 적어도 '완성'의 기록이 남는 것이 좋으니, 만약 시간이 없다고 판단되면 각 모듈의 최종파일을 한번에 commit 하도록 하겠다.
물론 각 변경사항은 해당 PR에 기록하겠다. 

# [2025.05.31.]
그 동안 교육을 받았고, FPGA 관련해서 어떻게 구현하면 되는지 Vivado의 FPGA 합성 워크플로우를 익히게 되었다.
디버깅 및 Timing Constraints 설정들 등등..
RTL 코드 단에서 기존 iverilog로 작성하는 것 보다 Vivado에서 Simulation이랑 Synthesis를 돌리는게 훨씬 더 많은 정보들과 오류들을 색출해낸다.
정보를 보니, Latch로 합성된게 꽤 있었고, 그 다음으로는 Timing Constraints를 설정해주고 그걸로 해결하지 못하는
Timing Violation들을 해결해야한다. xdc 파일을 다루는 법을 좀 알아야할 것 같고...
이제 로드라인이 다시 정리된다.
1. FPGA에서 Timing 관련 오류 및 Latch 합성 해결
2. FPGA에 FreeRTOS 같은 단순한 OS 탑재
3. FPGA에 화면출력과 키보드, 마우스 입력 구현
4. 성능 테스트 및 Doom 실행

이걸 6월 한달 안에 해야한다. 
1번이 어느정도 걸리는지에 따라 아마 결정될 것 같은데, 문제는 본 로직이 너무 커서 한번 Synthesis할 때 시간이 꽤 걸린다는 것. 
그리고 메모리가 많이 필요하다는 것. 16GB로 구성한 내 컴퓨터에서 Synthesis를 하룻밤 돌리니까 log상 새벽 3시에 OOME가 떴었다. 

이제 시간이 없다. 
여태 있었던 밀린 개발 기록들을 본 docs에 올리고 최종파일을 commit 하도록 하겠다.
솔직히, 이번에 더티파일을 기반으로 메인 파일을 수정하면서 더티에서는 발생했던 상황이 발생하지 않고, 더 적은 수정으로 기능을 점점 갖춰나가길래
최적화가 가능하다고 생각되어 그렇게 하고 싶었으나, 프로젝트의 '완수'가 중요하지 완벽을 지금 상황에서 목적으로 둬서는 안된다.
추구는 하더라도. 
아래는 그 개발 기록들이다. 

RV32I46F_5SP에서는, Trap 발생시 파이프라인 레지스터들을 flush하는 로직이 빠져있다.
이걸 넣으려고 하는데, Exception 발생 시, PC의 업데이트를 멈추고 기존 명령어들이 모두 처리 된 뒤 
Trap Handling을 진행하도록 하면 될 것 같다.
기존 레지스터의 데이터들을 Trap handler로 분기하면서 데이터 메모리에 저장해놨다가 mret 명령어시 다시 불러오도록. 

예를 들어 misaligned exception이라고 하자. 
(현재 지원하는 trap 은 misaligned instruction address, EBREAK, ECALL, mret 뿐. fencei는 원래 캐시가 있어야했는데 개발기간 문제로 드랍해서 지원하지 않는다.)
이걸 IF단계에서 Exception Detector가 감지, Branch Predictor에서 IF단계의 branch target을 계산한 값과 
EX단계에서 Jump address를 계산한 값을 모두 받는다. 
opcode를 통해서 어떤 명령어형태인지 파악하고 jump 이전에 처리중인 명령어들은 문맥이 없으니 
마저 WB까지 이루어질 때 까지 PC를 멈추고 flush를 한 뒤에 처리한다.

EX단계에서 Jump의 misaligned를 알았고, 그걸로 trap이 시동되어 pc_stall도 되었고, flush도 되었는데 
그 다음 클럭 사이클에 EX단계는 Jump의 후행 명령어인 flush로 인한 NOP가 와서 
EX단계의 opcode가 JAL이 아니어서 trapped가 풀리고 PTH도 수행이 안되니 trap_done도 다시 1로 올라가서 멋대로 다음 명령어를 수행해버린다.
이건 아마.. 파이프라인 레지스터의 갱신을 중단하고 현재 값을 그대로 유지하는 stall 신호를 추가하는 것이 좋은 선택일 것 같다.

탑모듈 테스트벤치 중.
PCC가 branch_estimation값을 받아서 branch_target을 쓸지 말지 정하는데, not taken으로 estimate했다가 
실제로 EX_branch_taken 값이 1이라서 잘못 예측한거면 해당 EX 단계에 있는 pc값과 imm값을 더한 branch target을 branch predictor 모듈에서 계산한다. 이 branch target을 쓰라고 코드를 짜고 싶은데...
현재 branch predictor의 상태가 strongly not taken이든 weakly not taken이든, 그것과 반하는 결과가 EX단계에서 도출되면 branch_target을 next_pc로 쓰게 하고 싶은 것.
-> 이건 위의 해답으로 귀결되었다. ## Branch Prediction 실패 이후 해당 실제 분기 주소로 분기하지 못한 문제에 대한 내용. 을 참고.
PC는 클럭신호에 따라 주솟값을 그 이전에 지장된 값을 출력하기에 
branch_prediction_miss시 EX단계의 계산값을 PCC에 주고 그걸 PCC가 PC한테 전달을 한다고 해도 해당 값으로 분기하지 못한다. 
때문에 이 EX단계의 주소계산을 Branch Logic으로 옮겼고, 
PCC에서 brnach_estimation_target과 branch_target_actual 두가지 신호로 동시에 받고있어 
조건문을 통해 prediction 이 맞는지 틀린지를 판단 후 PC에게 next_pc를 해당 주소로 출력할 수 있도록 했다.

WB단계의 포워딩이 핋요한 경우. 2025.05.25.에 대한 내용이다.
hazard unit에서 mem, wb 관련 해저드 신호를 hazard_op로서 각개 출력한다. 
hazard_mem, hazard_wb로.
그리고 그걸 포워딩유닛에서 받아서 처리한다.

처음에 포워딩이 잘 되지 않았다.
Forwarding을 이제 MEM뿐만 아니라 WB까지 수행하므로 탑 모듈에서 해당 로직이 바뀌어야하는 것.
그래서 아래와 같은 로직으로 변경했다.
alu_normal_source_A / alu_normal_source_B. 
alu_forward_source_data_A / alu_forward_source_data_B
alu_forward_source_select_A / alu_forward_source_select_B.
각각 현재 파이프라인 값, 포워딩 값, 그리고 그걸 선택하는값이다. 

## 분기예측 쪽 문제
misprediction으로인한 flush도 잘 되었고, prediction counter도 제대로 갱신되었고, NOP도 설계대로 삽입되었고, 
근데 branch_estimation이 branch taken과 같은데도 불구하고 한번 branch_prediction_miss가 1로 올라가고 나서 내려오질 않는다. 
코드에서 miss의 0 초기화 코드가 없는 것을 보고 추가함으로서 해결했다. 

## branch의 misprediction 수행 문제
miprediction으로 인해 EX단계에서 계산된 Branch Target으로 분기해야하지만, 
다음 클럭에서 branch 신호가 꺼져있어서 PCC가 그대로 다음 PC+4값으로 IF단계의 PC가 갱신됐다.
이 경우엔, EX단계의 branch taken 신호를 MEM단계까지 파이프라이닝해서 PCC에서 misprediction이고 
MEM단계 branch 신호가 1이면 branch target으로 분기 한다고 로직을 짜면 되려나?
믕... 이 경우도 위의 분기 예측기 주소 관련 문제로 귀결.
## Branch Prediction 실패 이후 해당 실제 분기 주소로 분기하지 못한 문제에 대한 내용. 을 참고.
이 때, 해당 분기 주소 계산을 어디서 하는가? 에 대해 생각을 해봤지만, 
(Branch Predictor에서 해당 EX단계의 imm값과 pc값을 더해 실제 분기 주소를 계산하는 로직은 의미가 없으니까, 이를 Branch Predictor 내의 콤비네이셔널 로직으로 수정해도 되는 거 아닌가? 꼭 Branch Logic에서 해야하는가?)

이건 Predictor에서 IF단계의 예측 소스와 EX결과 기반 갱신이라는 단순한 로직으로서 구성되는 편이 모듈의 경계를 깔끔하게 유지한다 판단하여
Branch Logic에서 해당 계산까지 포함하는 것으로 결정하였다. 

WB포워딩이 안되길래 뭐지 했다가 탑모듈을 보니 alu_forward_source_select에서 MEM단계만 포워딩하도록 되어있어
수정하는걸 깜빡했다는 것을 알아차리고 수정하였다.
하지만 alu_forward_source_select_a랑 b가 해당 타이밍에 전혀 변하지 않고 0으로 되어있다. 
HazardUnit에서 hazard_wb가 올라가야하는데, 아예 변화가 없는 걸 보면 WB단계 포워딩 조건을 검출하지 못해서 hazard_wb 신호 자체가 가지 않은 것 같다., 뭐지?
지금 파형을 잘 보니, 문제가 되는 EX_rs1이 0c일 때, WB_rd는 애초에 다른 값이라서 해저드 발생이 안되었다고 보는게 맞고 로직 자체는 문제가 없다. 
근데 문제는, 문제의 xor명령어에서 이미 retire된 sll 값의 rd 값을 소스로 하고 있는데, 이건 WB단계를 지나 이미 Register File에 저장되었고, 
WB단계의 rd는 이미 그 다음 명령어이니까 해저드 색출이 안되는 것 같다. 
이 경우엔 포워딩을 어떻게 해줘야하는걸까? 
이미 Register File로 저장이 되어있는데 저장 되기 전에 해당 주소의 값을 갖고 와서 EX단계에서 쓰려고 하는건데..
이걸 위해서 WB_IF_Register를 또 하나 만들어서 거기에 방금 retire된 명령어의 rd값을 집어넣어 포워딩을 할 수 있도록 해야하나?
아니다. 같은 클럭에서 WB가 같은 레지스터를 쓰려고 할 때, 즉 rd값이랑 rs1이 레지스터파일에서 같다면, 
읽기 데이터 = 쓰기 데이터로 bypass 로직을 추가했다. 
해결!

CSR쪽 포워딩이 안되는 것 같다. 
CSR명령어가 CSR값을 읽고 쓰는 걸 동시에 하다 보니 생기는 문제인가? 
원래 싱글 사이클대로라면, csrrs로 mepc에 2fc값이 저장되고, 그 직후 csrrc에서 mepc값을 불러오게 되는데, Zicsr 명령어는 rd가 아니라 rs끼리 겹쳐도 데이터 해저드가 발생하는구나..이걸 어떻게 해결하면 좋을까? CSR File을 고쳐야하나?
포워딩유닛과 해저드유닛에서 CSR의 포워딩을 지원하는 것으로 해결했다.

파형을 보면, ECALL을 설계대로 ID단계에서 Exception Detector가 탐지를 해 trap_status를 010 즉 ECALL로 올려 
해당 Pre-Trap Handling의 내용이 적힌 Trap Controller의 내부 루틴대로 잘 진행되었다. 
하지만, 이 PTH가 끝나면 305 csr_trap_address에서 읽은 mtvec값 0x0000_1000을 읽어서 해당 주소로 PC가 분기해서 진행되어야하는데, csr_trap_address로 305번지를 csr한테 줬는데, 주솟값이 안나왔다. 0x0000_0000이 나와버렸다. 
근데 또 막상 misaligned의 PTH에서는 305주소를 요청하면 0x0000_1000를 잘 출력하고 해당 주소로 잘 분기를 한다.
뭐가 문젤까? 
PCC에서는 trapped가 활성화되었는데 PCC로 인출되는 csr_read_data값이 0x00000000이라서 의도하지 않은 명령어가 IF단계부터 파이프라이닝되어 문제다. 어떻게 해결하면 좋을까??
ECALL이 ID에서 탐지되면 IF단계에서 인출된 명령어를 flush하고 싶은데.. 
Hazard Unit에서 trapped 신호에 IF_ID_Flush를 1로 올려주는 방식으로 해결했다.

# CSR File의 읽기 쓰기 주소 이원화에 대한 건
ID단계에서 읽은 주솟값이 WB단계가 되어서야 값이 인출됐다.
쓰기 작업이 아니고서야 csr의 address를 ID단계에서 디코딩된 raw_imm값으로 하고 싶은데 
현재 탑모듈 코드가 WB에서의 address를 받아오라고 하고 있어서 생긴 문제 같다. 
명령어 처리를 위해서 CSR File에 입력된 주소의 값이 바로나와줘야하는데, 의도와는 다르게 WB단계의 주솟값을 받고 있으니까. 
싱글사이클 일 때는 문제가 없었는데, 이렇게 되니까 쓰기용 주소 입력 포트를 따로(WB단계 주소를 받아오는 용도), 그리고 읽기용 주소 포트를 따로 두는게 해결방안이지 않을까? 현재 구현된 그냥 Register File처럼 읽기용 주소와 쓰기용 주소를 분리해서 읽기와 쓰기의 race가 일어나지 않도록 하는 것이다. 

생각해보니까, Trap Controller에서도 CSR File 모듈에 접근해서 PTH를 수행할 때 csr address에 바로 쓰기를 해야하는데, 
이렇게 되면 Write address 주소 입력 포트가 CSR File에 생긴다고 해도 
WB단계에서 CSR에 Zicsr확장의 명령어들 수행의 결과 값을 쓰기 위해 CSR_Write Address에 접근할거고, 
Trap이 발생되면 파이프라인들을 stall하지만 WB단계와 Trap Controller의 주소 접근 충돌이 날 수 있는 것 아닌가? 
그리고 Trap Controller는 읽기를 위한 주소신호 출력과 쓰기를 위한 주소 신호 출력을 csr_trap_address 하나의 신호로만 사용하는데, 
이러면 Trap Controller에서 csr address 출력 포트를 읽기 포트와 쓰기 포트로 이원화 시킬 필요가 있고, 
마찬가지로 CSR에서는 Trap Controller의 Write address 포트와 WB단계의 write address 포트로 이원화해야하는건가? 
그리고 Trap Controller에서 수행하는 PTH를 위한 CSR 접근인지 아닌지를 알아야 하니까 Trap Controller 모듈에서 나오는 trap_done 신호를 CSR File에 입력신호로 추가하고? 맞나...??
아니다. 애초에 WB단계 CSR명령어는 이미 파이프라인되어있는 명령어라 트랩 검출 이전, (애초에 로직이 트랩시 기존 명령어들을 모두 마치고 handling을 수행한다.)이 수행되고 그 이후 Trap이 해당 맥락에 관여하니 그럴 일은 없다. CSR의 주소 입력 신호를 읽기 주소 입력과 쓰기 주소 입력으로 각각 이원화하는 것으로 해결했다. 

# [2025.06.04.]
## FPGA 구현 개발에 대한 기록

요 며칠 새 기록을 남기는 걸 깜빡했다. 정확히는 이렇다 할 성과가 없었기 때문인데, 어느정도 Vivado에 익숙해지기 위한 인고의 시간들이라 생각한다.
2025.06.01부터 기록을 남겨 보겠다. 

### [2025.06.01]
우선, 현재 탑 모듈 자체를 바로 import해서 구현을 시작했었다. Elaboration을 하면서 Timing Violation이 떴고, 여기서부터 삽질이 시작됐다.
FPGA 교육을 들으면서 어느정도 이번 RV32I46F_5SP의 FPGA 구현 시도를 해봤는데, Timing Constraints를 위한 Wizard를 돌리고 거기서 Recommend된 옵션들을 모두 넣으니까 아예 합성하는데 반 나절이 걸리는 것이다.
이게 좀 이상해서 교수님께 여쭤봤고, 교수님께서 개발하신 RV32I기반 5~6단계 파이프라인 프로세서도 해봤자 5분 내외로 합성이 된다고 답변을 받았다. 역시 Timing Constraints에서 문제가 좀 있는 것 같다.
그래서 Timing Constraints를 아예 없애고 다시 합성을 하여 Timing Analysis를 하여 얼마정도의 Violation이 나는지 확인했다. 
결과는 30ns 언저리. 현재 FPGA 보드에서는 100MHz를 목표로 하고 있기에 약 20ns가 넘는 violation이다. 여기서부터 첫 삽질이 시작된다.
해당 경로를 확인하니, C->CE 경로 즉 클록에서 클록 활성화를 위해 경로가 설정된 것인데, 
(FPGA에서는 RTL 로직을 배선할 때 그들만의 규칙을 갖고 합성한다. 그리고 그 결과에서 Critical Path; 가장 긴 루트가 그 정도 레이턴시가 나오게 된 것.)
그 경로가 내가 만든 RV32I46F_5SP에서 전혀 쓰이지 않는 연관성을 지닌 모듈들 끼리의 신호였다. id_ex_register에서 if_id_register로 신호를 보낸다던가, 
Trap Controller의 내부 FSM을 위한 reg에서 다른 모듈로 클록이 간다든가.. 알 수 없는 것들 투성이라, 이걸 어떻게 해결하면 좋은지에 대해서 찾아보기 시작했고, 의도치 않은 배선 즉 실제로는 쓰이지 않는 경로의 경우 
Implementation 단계에서 최적화 작업 시 없어지니 해당 경로를 set_false_path 라는 XDC Timing Constraints를 설정해 해당 경로에 대한 Timing Violation을 Report에서 무시할 수 있다고 한다.
이를 XDC 파일에 문법을 적어서 저장하고 다시 합성을 하는데, 해당 설정이 적용이 안되길래 실제 변화를 보지도 못하고 그대로 하루를 보냈다. 물론 그 마지막 몇 분 사이에 적용법을 알게되었지만.
XDC파일을 직접 수정하는게 아니라(사실 직접 수정하는게 맞는 것 같긴 한데 내가 뭔가를 놓친 것인지 적용이 되질 않는다.) Edit Timing Constraints에서 조건을 추가하는 방식으로 적용할 수 있다.
2025.06.01.에서 언급한 의도치 않은 경로들 사이의 C->CE 경로들이 대략 수 백개 떴던 것들을 모두 set_false_path 를 통해서 모두 배제하여 Timing Violation을 모두 없앨 수 있었다. 
수백개의 신호를 일일히 추가할 수는 없는 일인지라, id_ex_register/*/*/* 같은 문법을 해당 경로 자체를 배재하는 식으로 했었다. 
하지만 여기서 발생하는 의문. 혹여나 내가 실제로 쓰이는 경로들을 제외해버렸다면 실제 합성에서도 문제가 야기될 수 있고 Timing 자체가 안맞는 걸 무시한 것일테니 제대로 동작도 안될 것이라는 생각.
사실 여기까지 작업하는데도 꽤나 시간이 걸렸던 터라, Implementation까지 한 뒤 뒤늦게 Simulation의 Post-Implementation Timing Simulation을 구동해봤다.
아직 사용한지 얼마 되질 않아서 까맣게 잊고 있었다. 돌려보니 영 알 수가 없는 파형들, 그리고 없어진 꽤나 많은 모듈들, 직감적으로 무엇인가 잘못된 것임을 느꼈다. 

### [2025.06.02]
당직. KAIST 입학지원서 및 자기소개서, 입증자료 양식을 인쇄하여 어떤 것들을 채울 것인지를 대략적으로 정했다.
그리고 당직 도중에 사지방을 잠시 사용할 수 있게 되어서 틈새 작업을 좀 했다.
아예 Timing Constraints를 모두 지우고, 현재 RTL 코드의 Vivado 시뮬레이션 자체가 의도된 값이 잘 나오는지를 확인했다.
결과는 참담. X값은 많지 않았지만 (대부분 Register File의 초기화 부재 문제. ) Z값이 꽤나 많이 뜬 것이었다. 왜일까.
iverilog말고 Vivado로 처음부터 RTL을 할 걸 그랬다는 푸념을 조금 늘어놓았다. 
Vivado에서 옆의 Flow 창에 있는 순서대로 진행을 하는 것이 어느정도 설계 워크플로우를 표준적으로 제시하는 느낌이라 각 단계별로 오류들과 경고들을 완벽히 파악하고 개선하고 넘어가기로 했다.
그래서 우선, 다시 첫 단계로 돌아와서 Behavior Simulation을 수행하여 파형에서 Z와 X값들이 뜨는 것들을 보고 이 값들을 우선 모두 없애는 것부터 시작하기로 했다.
어느정도 Z값을 없애다가.. 나왔다.

### [2025.06.03]
X와 Z값들을 모두 없앴다. 기존 탑 모듈에서 내 Verilog HDL을 다루는 실력 미숙으로 모듈에서 파생한 신호를 별도로 탑 모듈에서 추가로 중복 선언을 한 탑모듈 변수들이 Z값들을 토해낸 것이다.
이를 모두 없앴고, 레지스터를 초기화하는 로직을 포함하여 파형 내 X값들도 모두 없애는데 성공했다.
이 결과로, Timing이 꽤나 단축되었다. 12ns 대충 2ns내외의 violation. 기존에 35MHz 정도(30ns violation)에 비해 꽤나 향상되었다.
그리고 앞서 있던 원본 RTL코드에 있던 이상한 path의 C -> CE경로가 많이 사라졌다. 하지만 그래도 완전히 없어진 것은 아니다. 
그리고 이건 Synthesis단계의 내용일 뿐이라 Implementation에서는 또 어떻게 달라질지 모른다.
목표가 10ns인데 12ns 내외 즉 1.x 대의 violation이면 RTL을 어떻게 최적화하면 될 것 같아서 여러모로 분석해봤다.
일단 Vivado에서 Synthesis Stratage도 HighPerf로 바꾸고 여러가지 해봤는데, 설정으로 줄일 수 있는 Timing 여유는 폭이 그렇게 크진 않은 것 같다. 
지금부터는 RTL 코드를 만져야할 때이다.
. . .
조합회로의 연속으로 이루어지는 로직 때문에 Combinational Loop이 형성되었고 이 때문에 Timing 분석이 정확하지 않을 수 있다는 경고를 확인했다.
여러번 거친 조사 끝에, 이는 너무 깊은 수준의 조합 로직을 가진 경우 Vivado 자체에서 뭐 합성 어쩌구..., fanout에 따라 reg가 복제되어 안좋은게 생기고.,.
내부의 출력을 레지스터화 해서 조합논리회로끼리의 구성을 플립플롭으로 끊는 것인데, 이러면 사실상 해당 모듈이 동기식으로 변하게 된다. 
그래서 파이프라이닝에서 한 사이클 기다려야하는 대기 시간이 생기는데 이를 위해서 또 파이프라인 제어 신호와 원하는 값의 동작이 끝났으니 해당 대기를 풀어도 된다는 식별신호 로직을 만들어야한다.
과거 RV32I50F 구성할 때나 썼던 Read Done, Write Done이 되살아날 때 인 것 같다.
IDEC 2024때 RISC-V CPU 설계 및 FPGA 검증 강의를 들으면서 적은 강의 노트를 다시 읽는데, 지금 와서 보니까 뼈가 되는 말들이 적혀있다.
FPGA에서는 동기식 읽기만 가능하다는 제약이 있으므로, 비동기식 메모리에 플립플롭을 박아 레지스터화를 하여 클럭에 맞게끔 동작해야한다.
그리고 이러한 변경사항 때문에, 타이밍이 다 틀어진다. 이걸 당시에 싱글사이클 프로세서 구현을 위해 PLL 기능을 사용해 파훼했다. 
그리고 이걸 파이프라인 구조로 오면, 계속 타이밍이 다 밀리는데 이걸 학부생 수준에서는 해결 불가..라고?
하. 보여주지. 이미 한번 넘어온 산이다.

### [2025.06.04.] 그렇게 다시 오늘로 돌아온다. 
오전에는 아예 이렇게 된거, 모든 메모리를 동기식으로 바꾸자.. 라는 생각을 했다. 하지만 지금 이 개발 로그들을 다 쓴 지금
'굳이?' 싶다는 생각이 먼저 들었다. 정말로 FPGA에서 비동기식 읽기가 불가능한가?
그럼 실제 칩을 생산하는 경우엔 모든 메모리를 동기식으로 작동시킨다는 뜻이 되는데, CLK 라이징 엣지에서만 값을 읽고 처리하는 것은 큰 비효율을 야기시키며
이러면 조합논리회로가 있을 이유도 적잖이 퇴색된다. 애초에 캐시가 조합논리회로로서 동작하는 SRAM 아니었나? (POWER에서는 L3를 DRAM으로 처리하긴 하지만. )
FPGA에서 비동기식 읽기를 지원못할 이유가 전혀 없다고 생각된다. 용도 자체가 프로세서의 검증이랑 실물화로서 사용되는 이상 이 필수불가결한 요소가 안된다는 건 상상이 안되니까.
물론 그 내부의 물성을 알아야하긴 하겠지만은.
LUT RAM이 아마 비동기식 읽기, 동기식 쓰기.
BRAM이 동기식으로 모두 처리하는 것이라 아마 당시 강의에서 쓰인 칩에서는 그렇게 말한 게 아닐까 싶긴한데..
이미 너무 많은 뭔가를 하면서 파일의 투명성이 손실된 것 같은 기분이 든다. 아예 처음부터 FPGA 프로젝트를 다시 생성해야겠다.
알아낸 것은 많아도, 복잡한 변경사항은 없었기 때문에 (재선언 된 쓰이지 않는 탑 모듈 신호 선언 삭제, 레지스터 파일 초기화로직 추가) 다시 처음부터 하나하나 해봐야겠다.
Timing Constraints도 기본 클럭 생성말곤 한게 없으니까.

한 편으로는, 싱글사이클 프로세서에 IO를 모두 구현하고 파이프라이닝으로 넘어갈까 싶은데, 아니다. 이건 소요를 증대시킬 뿐이다. 
처음부터 시작해보자.

Hazard Unit의 clk, reset 신호 없앴고
파이프라인 레지스터들에 raw_imm이 [11:0] 으로 오선언 되어있던 것 고치면서 z 신호들 잡았고
탑 모듈에서 재선언한 안쓰이는 신호들 없애면서 불필요한 z값들 없앴다.
파형 올 그린.

Linter를 돌려야하지만 시간이 거의 끝났으므로 여기까지의 Timing Analysis를 해본다.
11.434ns. 어림잡아 여유 12ns에 오고, 얼추 80MHz는 나오는 것 같다. 오늘은 여기까지.
내일은 이 코드들을 commit하고, 그걸 기반으로 linter에서 지적되는 모든 Warning들을 파악하고 Synthesis로 넘어가서 디버깅을 이어하겠다.

# [2025.06.05. ]
아침부터 전투휴무 오전 개발 시작! (09:26)
확인해보니 저번에 이미 feat/pipeline_registers 브랜치에서 raw_imm값 변경을 해 두었기에 별도로 현재 시점에서 commit 할 변경사항은 없는 것 같다. 
Vivado의 Linter를 돌려본다..!! [First_Linter_Result](Devlog_images/FirstLinterResult.png)
위의 ASSIGN-6 문제는 메세지에 언급된 인덱스의 값을 실제로 쓰지 않는다 (읽지 않는다)는 뜻 인 것 같은데, 모두 의도된 바가 맞다. 그러니 수정 없이 넘어가도 좋다.
다음 ASSIGN-7. **Branch Predictor** 모듈에 있는 `branch_target` 신호와 **Trap Controller**에 있는 `debug_mode` 신호가 multi-driven 되었다는 것 같은데, 코드를 한번 봐야겠다.
아하. 아무래도 재선언을 하지 않은 것으로 보아 이 문제는 아닌 것 같고. 사진을 보면 reset시 `debug_mode`를 0으로 초기화하려고 그걸 순차논리에 포함시켰고
일반적으로 해당 값은 조합논리에서 다루는데 이러면 두 로직에서 값을 할당하게끔 되어 문제가 발생하는 것을 아마 경고한 것 같다.
![multi-driven_debug_mode](Devlog_images/TrapControllermultidriven.png)

debug_mode_enable 신호로 역할을 쪼개어 해결했다.
Branch_predictor에 있는 `branch_target` 신호도 multi-driven이라는데, 뭐가 문제일까.
아하. ![branch_target_multi-drvien](Devlog_images/branch_target_multi-driven.png) 
reset에서 순차식으로 0을 초기화하는데, 실제 값은 조합논리에서 생성되어 문제인 것 같다.
이건 조합논리에서 기본값을 0으로 두어도 조건에 따른 주솟값을 계산하며 해당 조건은 순간 신호가 아니니 상관없을 것 같다.
적용 완료. 해결했다. 

아니 왜 더 증가했지 타이밍이
RTL이 정확해져서 더 밑천이 드러난 것 뿐인가.
일단 Synthesis option에서 18ns까지 늘어난걸 Flow_PerfOptimized_high 로 바꿔서 15ns 정도로 줄였다.
14ns는 flatten을 full로 해야되는데, 이러면 디버깅이 난해해지니 rebuilt를 유지했다. 여기서부터 다시 디버깅이 시작된다...

으어. 검토를 하다보니 BE_Logic 모듈에 있던 misaligned memory address exception 신호를 발견하였고
이에 대한 Trap Handling을 구현하지 않고 누락했다는 것을 알게 되었다.
부랴부랴 14시부터 만들기 시작했고, 15시 09분에 더티파일로 구현을 완성했으며, 15:49분에 최종 push 및 PR 을 마쳤다. 
끙... 그래도 확실히 실력이 계속 늘고 있는 것 같다. 
처음 Trap Controller 구현할 때 머리 굴리느라 진짜 힘들었던 것이 생각나는데, 이제는 그게 기본으로 아무렇지도 않게 잘 추가했다.
로직을 잘 짜둬서그런가. 하하. 하지만 FPGA 구현은 다른문제니까..,. FPGA 프로젝트에 이걸 이식하고 다시 Timing Closure 작업을 마저해야겠다. 

오키. Vivado 에서 그냥 프로젝트파일 새로 만들어서 Behavior Simulation을 다시 돌려봤다. 전부 예상값대로 잘 나온다.

탑 모듈에서 Vivado를 위한 최적화를 모두 commit했고, 다시 새 프로젝트를 파서 돌리고 있다.
Synthesis를 돌리면서, 각 Strategy별 타이밍을 확인했고, rebuilt 방식의 PerfOptimized High 설정으로 하기로 했다.
대략 15ns의 violation.. 파이프라인의 stall신호를 if가 아니라 삼항문으로 모두 대체해서 0.1ns 의 마진을 확보했다.
그래서 일단 느려도 동작하는게 중요한 시점이니 XDC에서 10ns가 아니라 25ns로 잡아서 40MHz에서 동작이 제대로 되긴 하는지를 확인할 것이다.
25.5ns 로 해서 violation은 없는데, 혹시 몰라서 Critical Warning들을 확인해보니까, IO관련한 내용은 고사하고, Timing Loops를 찾았다고 한다. 뭐지이게?
찾아봐야겠다. 

일단 violation 없는 상태에서 Post Synthesis Timing Simulation을 돌렸다.
결과는 참담. 의도하지 않았고, 알 수도 없는 신호들이 이상한 값들을 토해내고 있었고 정상적으로 프로그램이 흘러가긴 커녕, 특정 시점부턴 X값과 Z값이 도배된다.
아,, 이걸 도대체 어떻게 해야한담..

하.. 일단 파형을 디버깅 하기 이전에 오류부터 모두 다 잡아야 한다.
정말 다른 탓을 할 요소가 없고 나서야 이 파형들을 건들여야할 것만 같은 느낌이다. 지금으로서는 이게 왜 이렇게 되는지 가늠조차 안가니까, Vivado에서 제시하는 모든 Warnings, Critical Warnings, Errors를 모두 해결해보자.
Timing Loop 발생, Combinational Loop란다.
리스트는 다음과 같다.
ALU, Exception Detector, CSR File, Trap Controller, RV32I46F_5SP 탑모듈.
Timing Analysis에서 나온 목록에서는 Forward Unit과 IF ID Register, Branch Predictor가 포함된다.
이걸 어떻게 해결해야할까. 
이 것들은 아예 조합식으로 웬만해서 작동하는데, 전부 동기식으로 재구성해야하나?
그런데 그러면., 아예 한 사이클씩 밀려서 파형이.,하아., RTL 코드부터 다시 가야한다....
심지어 이렇게 해도 될지 안될지를 모른다......
그래도 어떡하겠는가.. 이거 말곤 할 수 있는 것이 지금 없는데..

이걸 해결하고 나서, fanout이 227이나 되는 그걸 해결해보고... 믕.,,.
하하. FF를 넣으면서 동기식으로 만들어야하네.
37F부터 이 오류가 없으리란 법이 없으니 각 아키텍처별로 검토를 해서 하나하나 단계별로 수정해야겠다.

37F 근본 구조에서 비롯된게, ALU.
43F는 CSR_File
46F는 Trap Controler, Forward Unit, 
46F5SP는 Branch Predictor, IF ID Register, Forward Unit.
하아., ALU의 파이프라이닝? 이건 좀 생각도 못하겠는데 애초에 조합회로가 아니던가? 그냥 출력단을 레지스터화 하는 것으로 족한건가?

# [2025.06.06.]
의도치 않게 오전을 날려버렸다. 너무 피곤했던 것 같다.

오후. 빠르게 점심을 먹고 CSR의 레지스터화부터 시작했다. (12:43)
가볍게 CSR의 출력단에 csr_data_out이라는 걸로 해두고 기존 csr_read_data는 내부 레지스터로 두었다.
그에 맞게 탑모듈도 수정했다.
남은건 Valid 신호인데, CSR에 csr_ready 신호를 추가했고, Control Unit에서 이를 받아 PC_Stall을 하게끔 함과 동시에 
Hazard Unit에도 csr_ready 신호를 줘서 csr_ready가 아니라면 모든 파이프라인 레지스터를 stall하도록 했다.

CSR을 건들면서, 읽기 전용 CSR에 쓰기를 시도하면 그냥 단순히 NOP가 되는 것이 아니라 Illegal Instruction exception을 내어야하는 것을 누락했다는 것을 발견해서 추가 로직을 구현했다.
이제 읽기 전용 CSR에 쓰기 시도가 들어가면 (CSRRS, CSRRC x0은 제외. 이는 해당 CSR에 변경을 가하지 않으므로) Illegal Instruction Exception을 낸다.
CSR File에서 이를 감지해서 illegal csr 신호를 Exception Detector에 보내고, Exception Detector에서 trap_status를 111 : Illegal Instruction으로 하여 Trap Controller에 전달한다.
Trap Controller는 이를 인식해 mepc를 WB_PC값으로 쓰고 나머지 PTH를 진행해서 Trap Handler로 분기한다. 
Illegal Instruction 즉 잘못된 CSR에 대한 쓰기는 WB단계에서 알게되므로 (csr_write_address 는 trap이 아니고서야 WB단계의 주소를 가져온다.) WB_pc를 mepc에 저장하는 것으로 했다. 
Illegal Instruction 을 요하는 exception 상황이 이 뿐만 아니라 여러가지이고 그걸 탐지하는 단계도 달라질 수 있을 것 같은데, 이건 추후 설계에서 따로 조건문을 추가하는 방향으로 수정해야겠다.

동기식 CSR로 바꾸면서 PTH에 READ_MEPC 단계를 추가했다. 더 이상 MRET이 한 사이클 안에 mepc 주소로 분기할 수 없게되어 두 번째 사이클 즉 mepc의 값이 나올 때까지 동일한 주소를 넣으며 기다리는 것이다. debug mode는 바로 풀게 보존했고, trap_done은 READ_MEPC에서 1로 다시 올라가도록 했다. 

파형을 검증하다가 웬만큼 잘 진행이 되도록 했다. (17:29)
다만 Illegal Instruction Exception이 예상과는 다르게 움직인 구간이 두 곳 있어서 이를 디버깅하는게 남아있다.
본 CSR File 레지스터화의 본 목적은 Combinational Loop의 해결.
따라서 이게 해결되었는지를 우선 보기 위해 위 문제를 잠시 미루고 Vivado로 넘어갔다. 
Simulation을 하고 Z값이 조금 보이긴 했지만 일단 EBREAK 디버그 최종 명령어 ABADBABE까지 값이 잘 잡혀 바로 Synthesis로 넘어갔다.
결과는 오우. Timing Loop이 6개 정도 보고되었던 것으로 기억하는데, 그게 3개로 줄어들었고 타이밍이 (!!) 처음엔 잘못본건가 했는데, WNS가 37.565ns로 잡혀있었다. 
-37.565ns가 아니라. 저번에 PSTS를 위해서 클럭을 그냥 50ns로 포기하고 했었는데, 이젠 Total Delay가 12.108ns이다. 대략 15ns, 즉 75MHz 부근까지 줄일 수 있는 것..!!!
다행이다. Combinational Loop 문제를 해결해도 타이밍이 개판일 것 같아 불안했는데, 간만에 동기를 추가로 얻는 것 같다.

저녁점호

이제 Vivado Behavior Simulation을 기반으로 디버깅을 수행할 차례다.
봐야할 것은 ALU result, write_reg, write_data 그리고 파이프라인별 PC, Instruction이다.
이걸 해결하고, 나머지 Combinational Loop 경로를 조정해야겠다. 

아 이런. Misaligned에 오타가 있어서 로직이 제대로 작동 안했던 것 같다. 고치고 다시 해봐야겠다.

아 맞다. 이번에 CSR File을 레지스터화 하면서 기존 46F Architecture에서 누락한 부분을 발견했었다.
Misaligned Instruction Address Access 즉 JAL, JALR 명령어에서 잘못된 주소로 jump시도를 했을 때, PTH를 수행하고 Trap Handler로 분기하는 것 까진 잘 했는데,
JAL의 수행역할 중 나머지 R[rd] <= PC + 4 를 수행하지 못하게 무효화하는 것을 깜빡했다.
이 점을 고쳐서 이젠 해당 명령어가 flush되며 실제 Register에 해당 값을 저장하는 것을 수행하지 않고 단순 NOP가 수행되며 당연하게도 Trap Handler로 분기한다.
그리고 Trap Handler에 이제 Illegal Instruction Exception 지원이 추가되었으니 mcause 값을 비교하기 위해서 x8에 2를 저장하는 명령어를 추가했다. (Instruction Memory)

파형 분석 중. 일단 write_reg와 write_data를 비교하고 있다.
기존 46F 아키텍처에서는 Misaligned에서는 x2에 255를 더했지만 중복이슈로 rd를 x30으로 옮겼다.
때문에 원래 02에 bc00_00ff가 저장되어야하는데 30인 1e에 저장된다.

음. 765ns부근에 있는 mvendorid에 대한 쓰기가 illegal instruction이 떠야하는데, 뜨지 않고
이번 레지스터화로 인한 한 사이클 밀린 것에 대한 타이밍 맞추기로 인해 의도한 동작이 되지 않는 것 같다. 이번 이슈 이후 모든 파형은 예상값대로 움직임을 확인했다.
이것만 이제.. 내일 다시 분석해서 해결하면 될 듯 하다. 적어도 이번 주 내에는 FPGA Timing Analysis 끝내길 바란다.
오늘은 여기까지! 

# [2025.06.07.]
Illegal Instruction Exception 지원을 위해 여러가지 시도해보았으나..
처음에는 Illegal Instruction Exception이 한 사이클 늦게 뜨는 문제가 발생.
그걸 해결했더니 이젠 mtvec 값을 제대로 읽어오지 못하는 문제 발생.
그걸 해결하려고 코드를 짰더니 iverilog에서는 아예 시뮬레이션이 Freeze되고, Vivado에서는 파형이 보이지만 의도하지 않은 동작들을 보였다.
CSR File에서 Exception을 탐지하고 그걸 Detector로 보내 trap status 코드를 Trap Controller에게 주도록 해봤지만 앞서 말한 Freeze문제가 났었다.
거기에 WB단계에서 알게 되는 이 Exception이 만약 그 전에 또 다른 CSR 접근 관련 이슈가 터지게 되면 더 이상 로직을 추적하기가 어려워지는 문제가 발생한다.
때문에 Exception Detection이 하나의 일관된 파이프라인 단계에서 이뤄지는 것이 좋을 것 이라는 결론에 도달했고, EX단계에 가야하는 분기 예외 이외에 다른 것들은 ID단계에서 처리한다.
그래서 아예 Exception Detector에 rs1값이랑 csr_write_enable 값을 줘서 CSR 쓰기 활성화, CSRRW같이 해당 CSR에 값 변화를 무조건 요청하고 거기에 유효한 쓰기 주솟값이 아닐 경우, Exception을 발생시키도록 했다.
하지만 이 것도 마찬가지로 iverilog 시뮬레이션에서 Freeze를 일으켰고 마찬가지로 Vivado에서는 잘 나왔으나 이번에는 의도치 않은 주솟값에 write enable 신호가 같이 들어가서 엄한 주소를 mepc로 저장해 잘못된 분기를 진행하는 현상을 발견했다. 

여러모로 로직이 혼자서 추적하기 어려워지는 상황에 직면하여 현재 리팩토링과 Timing Closure 및 Behavior 오류가 발생하지 않는 이상 로직의 추가는 하지 않기로 했다.
RISC-V에서는 엄격한 예외처리를 원칙으로 하기에 이런 동작을 지원하지 않는다면 표준에 부합하지 않을 수 있으나.. 어쩌겠는가.
다시 한 번 강조하지만, 완벽을 추구하되 완성을 놓쳐서는 안되는 법이다. 
때문에 Illegal Instruction 관련을 현재 개발까지 주석처리 하고 온전히 동기식 모듈로 만든데에 검증을 진행하여 다음 Combinational Loop을 해결하도록 하겠다.

아. 도중에 보니까 ECALL 관련 로직을 잘못 짠 것이 보인다.
여태 검증하면서 Instruction Memory의 예상값 주석이 잘못된 것을 확인하고 이를 수정했는데,
이번에는 ECALL 때문에 PTH에 진입하며 EX단계와 MEM 단계에 머문 CSR 접근 명령어들이 수행을 완료하지 못하고 무효화 처리 되는 것을 확인했다.
MRET으로 돌아간다고 한들, ECALL은 ID단계에서 파악되어 해당 ECALL mepc값의 +4된 값으로 가니 ECALL 이전에 EX와 MEM단계에 있던 두 명령어를 살릴 수 없다.
그렇다고 다시 해당 명령어들로 돌아가면 어차피 ECALL이 다시 수행되니까 재귀문에 빠질 뿐이고.
ECALL감지시, 두 사이클을 stall하고 진행하는 것으로 로직을 수정해야겠다.
ECALL일 때 FSM을 대기하는걸 만들어서 WB단계의 명령어까지 살렸지만 ECALL의 PTH자체가 수행이 안되는 것을 확인했다. 이것 부터 고치는게 좋을 것 같다. (여기까지 오는데 1시간 30분 걸렸다...)

생각해보자.. 왜 ECALL PTH가 안넘어갈까...
그래. ECALL이 되면 ID단계의 ECALL을 식별할 instruction이 stall되어야하는데 flush 되면서 ECALL에 대한 문맥이 없어진다.
이 것 때문에 아예 ED에서 Trap임을 인식하지 못하니 PTH로 진행이 되지 않는 것이다. 실제로 파형에 IF_ID_Register의 flush가 있다. 이를 없애보자.
아까 디버깅하면서 ECALL시 IF_ID_Register Flush를 하는 로직을 Hazard Unit에 넣었었는데, 이를 삭제하지 못한 것 같다. 이를 지우니까 PTH로 잘 넘어간다. 이제 남은 명령어들을 살리는 작업을 해보자.

이런. 파형에서 놓친게 있다. 다행히 빨리 발견했는데,
ECALL PTH로 Trap Handler까지 분기하자마자 ECALL에 뒤따라오는 Misaligned 명령어가 있는데 이게 또 PTH를 일으켜 ECALL을 처리하지도 못했는데 다시 Trap Handler로 넘어간다.
문제다. ECALL의 PTH가 끝나면, 원칙상 Trap Handler로 분기하며 그 전에 있던 모든 명령어를 없애야겠다. 
어차피 ECALL은 다른 연산을 수행하는 것이 아니라 System Environment Call이라 Trap Handler로 넘어가는 것으로 족하다. 
생각해보니 Trap Handler로 넘어가게 되는 모든 Exception들은 IF단계에 Trap Handler의 첫번째 주소가 와서 첫 명령어가 실행되는 순간 선행되고 있던 모든 명령어를 flush하는게 옳아보인다. 
TH를 부른 이상 그 이후 명령어는 필요 없고, TH를 부른 그 명령어 자체도 사실 PTH 때문에 유지되어야 했던 것이지 이미 TH로 분기한 이상 필요는 없으니까. 
(없어져야하는 게 맞다. Exception을 부른 명령어가 정상수행되어 값이 반영되는 처리가 되어서는 안된다. )

Trap Controller에서 GOTO_MTVEC에 도달했을 때 마침 IF 단계의 PC값도 TH의 시작 주솟값 (mtvec)이니까 이 때 Hazard Unit으로 flush하라는 신호를 보내도록 하면 되겠다.
pth_done_flush 신호를 추가했고, 역할은 같지만 기존 misaligned_flush가 READ_MTVEC때 1로 올랐던 것과 달리 GO_MTVEC으로 옮기니 문제가 해결되었다. 
근데 이건 놓쳤었던 29번째 잘못된 JAL명령어의 Trap Handler로 분기하지 않는 버그를 잡아내면서 확인했고, 여전히 ECALL은 수행이 의도와는 조금 다르다. 
파형 분석중..왜 PTH를 두번 수행하지?

후... 1시간 30분 여러가지 방법을 시도해보다가 (csr_access를 따로 뺀다던가... 등등)
다시 롤백했다. 원점.. 다시 시작해보자..

아예 이번 기회에 심층 검증을 하는 것 같다.
기존 46F5SP, 46F, 43F에서 검증을 너무 대충했나...
데이터메모리의 주소 입력이 alu_result의 11:2로 되어있는데, 아마 ChoiCube84가 어차피 하위 2비트 미정렬 방지용으로 컷 한 것 같은데, 이러면 실제로는 Data Memory에서 의도된 alu result 주소값에 2비트 쉬프팅된 값으로 주소가 잡힌다. 파형보면서 Instruction Memory TestBench 에 적힌 의도값이랑 다르길래 혹시나 해서 9:0으로 다시 바꿔보니 맞다.

이런. SH Misaligned Memory도 PTH와 TH로 정상분기되지만 해당 문제의 명령어의 처리를 NOP하진 못한다. 이 것도 해결해야한다...
이건 추가 기능도 아니고 원래 잘 되어야 했던 부분을 하는건데.. 하아.,.... 또 다른 Combinational Loop은 도대체 언제 해결할 수 있을까...
이건 MEM단계에서 Trap을 감지하면 늦는다... MEM단계에서 감지해서 Write Enable을 빼앗는다고 쳐도 이미 그것보다 적히는 시간이 더 빠를 것이고 한 단계(클럭사이클) 안에서 어떤 신호가 더 먼저 작용할건지를 생각할 바에
그 전 사이클에서 선제적으로 차단하는 것이 효과적일 것이다. EX단계에서 어차피 alu_result도 나오고 opcode와 funct3로 어떤 Store 명령어인지 구분할 수 있으니까..
BE_Logic에서 misalign 감지 로직을 없애고, EX단계에 있는 신호들을 Exception Detector로 넘겨서 처리하도록 추가해야겠다...
해결! 근데 그 뒤에 뒤따라오는 LW 명령어의 Mialigned가 Traphandler 분기 이후 갑자기 또 PTH-TH를 일으켜서 흐름에 문제가 생겼다.
그래서 pth_done_flush에 IF_ID_Register Flush까지 포함했다. 

다음 문제.. 28번째 명령어 AUIPC 직후 Misaligned JAL인데, 이게 EX에서 PTH-TH를 하고 EX_pc 기준 다음명령어로 가다보니, 해당 PTH일 때 모든 MEM_WB를 제외한 모든 파이프라인 레지스터들이 flush된다. 
혹시 몰라서 misaligned instruction flush를 잠시 없애봤는데, (원래 파형에서 pth_done_flush 그 이전에 하나 찍히고 같이 찍히길래 그걸 혹여나 테스트해보려고 없앤 것이다.) 해결되었다...
엄. 원래 아까는 이렇게 하면 JAL 명령어가 살아서 해당 R[rd] = PC + 4 가 처리되어벼리길래 이 명령어를 Hazard Unit에 추가한 것이었는데.. 당혹스럽지만 할게 산더미라 일단 넘어가본다.

후. 거의 다 온 것 같다. 분기 예측도 Instruction Memory에서 x7에 대한 값을 TH에서 쓰다보니 이걸 고려하지 않고 시나리오를 짰던 것을 수정하여 제대로 작동함을 확인했다. 
이제 CSR명령어들인데, CSR이 동기식으로 변하여 읽기 값이 한 사이클 뒤에 출력되는 것은 확인 되었는데, Register에 Write되는 것이 주소와 타이밍이 맞지 않는 것 같다. 

아마 오늘은 여기까지 할 것 같기에... 기록을 먼저 남겨둔다.
Instruction Memory 38번까지는 모두 진행됐다. 야호. PTH는 여태 잘 되던걸 알고 있으니까 나머지 4개의 연속적인 CSR 명령어들을 모두 수행할 수 있으면 되는건데,..
일단 현재 문제는, CSR의 Read와 Write의 시간차이가 있어서, CSR의 데이터 출력을 포워딩해야한다는 것. 이미 구현했던 것 같은데, 무슨 차이가 있지?
문제를 더 자세히 묘사하자면, (내일 기억못할 나를 위해) 1045ns 부근에 ID단계에서 csrrw로 요청한 mvendorid 값을 입력받고 1055ns에서 출력한다. 그리고 연달아서 바로 다음으로
1065ns에서 csrrs로 mepc값, 1075 mepc 반환, 1085 csrrc mepc값, 1095 mepc 반환. 이렇게인데.
Zicsr은 읽기와 쓰기를 동시에 처리하는데, 읽기는 ID단계에서 진행되어 두 클럭에 걸쳐 나온다고 해도 쓰기가 WB 단계 즉 3사이클 이후에 적용된다.
= 같은 주소에 대해서 두 번 이상 Zicsr로 접근할 경우, 최대 이후 3개 명령어까지 첫 csr 명령어가 해당 주소에 쓸 데이터가 반영되지 않은 값을 받게 된다. 
이러면 포워딩을 해줘야하는데.... 기존 로직을 한번 봐보자.

아. MEM, WB의 CSR 포워딩만 구현되어있다. 이제 EX단계의 포워딩도 구현해두면 될 것같은데... 시간이 다 됐다.
오늘은 여기까지. 내일 꼭 해보자.. (아 내일 취지인데..)

아 오버타임 6분해서 했는데 왜 안되는 것 같지
파형은내일 봐야겠다 여기까지

# [2025.06.08]
CSR에 쓰여지는건 잘 쓰여진다. 근데 그게 21번 레지스터 쓰기에도 반영이 되어야하는데.. 안되네
이건 WB 포워딩인것 같은데..하하! 해결했다.
문제를 조금 잘 못 보고 있어서 노트에 하나씩 정리하면서 해결해봤다. 딱 30분 언저리 걸렸다.
문제 상황은, 동일한 CSR에 동일한 R[rd] 값을 가진 명령어가 연속으로 수행되며 선행 명령어 A로 인해서 변경된 CSR의 값을 후행 명령어 B가 읽지 못한채로 WB단계에 도달해
B가 가진 만료된 CSR의 값을 R[rd]에 쓰는 것이 문제. 원래는 A에서 변경한 새로운 CSR의 값을 B가 읽어서 R[rd]에 넣어야하는데 그게 안된 것이다.
앞서 ALU에서는 이미 이 hazard에 대해서 포워딩이 돼 제대로 계산된 값이 인출되어 CSR에는 제대로 된 값이 쓰기가 된 것이었지만, Register File에 저장할 값은 포워딩 로직이 구현되어있지 않았다.
(애초에 이건 생각지도 못했으니. 컴퓨터 구조 및 설계 책에서 해저드를 설명하면서 책에서 설명된 것 보다 더 많은 것들이 존재한다고 한 이유를 어렴풋이 이해하는 것 같다.)
때문에 이를 고찰해보니 답을 찾을 수 있었다. 
WB단계에서 retire하는 선행 명령어 A의 alu_result가 곧 후행 명령어 B의 R[rd]에 써야할 reg_write_data일테니 A의 alu_result를 포워딩하면 된다.
하지만 A는 이미 retire했으므로 WB레지스터에서 alu_result를 갖고와봤자 자기 스스로의 데이터를 포워딩하고 이는 의도된 동작이 아니기에 하면 안된다.
답안 : retire instruction의 alu_result값을 저장하는 레지스터를 top_module에서 추가로 설계해 csr-reg hazard 발생 시 register_file_write_data를 retired_alu_result로 하도록 MUX를 설계한다.
그리고 Hazard Unit에서는 물론 WB-MEM 할 수도 있지만 일관된 타이밍 검출 및 처리를 위해 모듈 내부에 별도의 retire_rd와 retire_alu_result를 넣고 아래와 같은 hazard 검출 요건과 로직을 만든다.

wire reg_csr_hazard = (EX_opcode == `OPCODE_ENVIRONMENT && (WB_rd == retire_rd) && (WB_csr_write_address == retire_csr_write_address));

always @(posedge clk or posedge reset) begin
        if (reset) begin
            retire_rd <= 5'b0;
            retire_csr_write_address <= 12'b0;    
        end else begin
            retire_rd <= WB_rd;
            retire_csr_write_address <= WB_csr_write_address;
        end
        
    end

해저드 검출은, CSR(SYSTEM; ENVIRONMENT OPCODE) 명령어이면서 WB할 레지스터의 주소가 retire_rd와 동일하고, WB할 csr의 주소가 retire_csr_write_address와 동일할 때 발생한다고 정의한다.
그리고 각 retire_rd, retire_csr_write_address 값은 클럭에 맞춰 한 사이클 지연을 가져 비교할 수 있도록 한다. 

Top module에서 retired_alu_result와 register_file_write_data MUX를 정의한 로직은 다음과 같다.

always @(posedge clk or posedge reset) begin
        if (reset) begin
            retired_alu_result <= {XLEN{1'b0}};
        end else begin
            retired_alu_result <= WB_alu_result;
        end
    end

`RF_WD_CSR: begin
                if (csr_reg_hazard) begin
                    register_file_write_data = retired_alu_result;
                end else begin
                    register_file_write_data = WB_csr_read_data; 
                end
            end

이제 파형을 다시 검증해볼까? ㅎㅎ

흠. 40번째 명령어인데, 결과가 조금 이상하다.
CSRRWI: x22 = FFFF_FFBC, CSR[342] = 0000_0000; // R[x22] = 0000_0000, CSR[342] = 0000_0003
CSR[342] mcause에는 3이란 값이 잘 쓰였는데, R[x22]에는 0000_0074라는 엉뚱한 값이 쓰여졌다.
CSR[342]는 기존에 0이 맞았고. 그럼 R[x22]에는 0000_0000이 쓰이는게 맞는데..
이상하다. csr_hazard_mem이 떠있다. 그래서 register_file_write_data_select 신호값도 010, WB_ALU_result를 R[rd]에 저장할 값으로 보내고 있는데...
csr_hazard_mem의 로직이 잘못된건가? 확인해봐야겠다. 엣. register_file_write_data_select는 Control Unit 주관인데...
흠.. 거의 알 것 같은데.. 취지 가야겠다. (11:14)

12:06 복귀.
음. 현재 명령어는 csrrsi. 즉 rs1 필드의 값과 CSR값을 계산해야하기에 ALUsrc는 A B 각각 rs1, CSR이 맞다. 그래서 3 3이고.
csr_hazard_mem의 조건은 MEM단계에 CSR_WE가 활성화되어있고, MEM단계 raw_imm(csr_write_address)이랑 EX단계 raw_imm이랑 같을 때.

잉 뭔가 이상하다... WB_raw_imm이 305로 되었을 때 mtvec값인 0000_1000이 WB_csr_read_data로 나왔어야하는데, 나오질 않는다.
어라. 원래 Zicsr 명령어로 csr에 접근해서 읽기라도 하는 순간에는 무조건 csr_ready가 0으로 내려갔다가 1로 올라오면서 값이 인출되어야하는데 csr_ready가 0으로 내려가지도 않는다. 뭐지?
csrrc까지는 잘 됐는데, csrrwi부터 그런다. Zicsr 상수 명령어에서만 그런건가? PTH에서도 잘 되니까..찾아봐야겠다. 
캬. 쾌거. CSR File에서 순차 로직에, 
if (csr_access && !csr_processing) begin
          csr_processing <= 1'b1;
          csr_read_out <= csr_read_data;
        end else if (csr_processing) begin
          csr_processing <= 1'b0;
          csr_read_out <= csr_read_data;
        end

즉 읽기 수행시에만 csr_read_out 나가게 했었던걸 발견했고, 이를 바꾸려고 csr_access를 바꾸려다가 마땅한 조건이 떠오르질 않았다. 
(쓰기까지 csr_access에 포함하거나 별도의 선언을 하게 되면 쓰기까지 2사이클로 아예 타이밍이 틀어진다.) 
그래서 저 아래에 그냥 else if (csr_write_enable) begin 해서 csr_processing과 상관 없이 csr_read_out <= csr_read_data;를 넣었다. (물론 조건을 위에서부터 확인하기 때문에 관련이 아예 없는게 아니겠지만.)
그러자 csr_read_out이 제대로 읽히기 시작해서 다음 문제로 넘어가기로 했다.
x22에 사이클 두 번동안 쓰기되어야하는 것은 옳다. 헌데 데이터가 한 차례 밀렸고 없어야하는 데이터가 있는 상황.
0000_0000, 0000_1000 모두 x22에 쓰여야하는데 첫 쓰기 사이클에는 0000_0074가 와있고, 두번째는 0000_0000. 세번째는 다음인 x23에 0000_1000이 쓰인다. 원래 x23에는 0000_1007이 쓰여야하는데.
0000_1007은 심지어 ALU에서도 잘 계산되어 나왔다. 흠,,

0000_0074가 어디서 나왔을까? 찾아보자. 

그리고 그 전에 ECALL이 ID 페이즈에서 감지된 뒤 전체 파이프라인 stall이 걸려서 기존에 있던 명령어들이 retire하지만 내부에 변경사항을 주지 못한 것을 해결하기 위해서 새로운 로직을 짰다.
ID단계의 ECALL 앞의 EX, MEM, WB의 명령어들이 retire하기 위해 Trap Controller 내부에 standby_mode 라는 출력을 만들었고, ECALL시 STANDBY와 그 이후 ECALL 전용 MEPC 값 쓰기 FSM 단계를 추가 구성하였다.
Hazard Unit에서도 standby_mode 신호를 받아 IF_ID, ID_EX만 stall하고 standby_mode가 아닐때는 PTH를 위한 전체 파이프라인 stall이 되도록 아래와 같이 구성했다. 
 if (standby_mode) begin
            IF_ID_stall = 1'b1;
            ID_EX_stall = 1'b1;
            EX_MEM_stall = 1'b0;
            MEM_WB_stall = 1'b0;
        end else if (!trap_done || !csr_ready) begin
            IF_ID_stall = 1'b1;
            ID_EX_stall = 1'b1;
            EX_MEM_stall = 1'b1;
            MEM_WB_stall = 1'b1;
        end
그리고 탑 모듈에서도 standby_mode가 아니고 trapped 일 경우에만 csr_trap_address와 같은 trap_controller의 신호들을 받아올 수 있도록 했다.
standby_mode에서는 평시처럼 WB단계의 retire하는 명령어들의 값을 그대로 받도록 한다는 뜻. 
로직을 떠올리고 시뮬레이션 두 번 정도로 해결했다. 대기로직을 처음에 바로 완성했는데, 탑 모듈에서 해당 MUX 선택 로직을 수정안한 것 때문에 두 번 걸렸다 ㅎㅎ..

40, 41, 42 CSR상수 명령어들이 CSR에 쓰는 값들이 원래는 안쓰여지고 넘어갔었는데, 이젠 다 쓰여지고 PTH로 넘어가서 수행이 된다. 이제 남은 문제는 레지스터..
레지스터 x22에 의도하지 않은 0000_0074값이 쓰여지는 문제... 그리고 그 의도치 않은 값 때문에 들어가야할 값들이 주솟값과 한 사이클 미뤄진 문제...
추적해보자..

일단 해당 값은 CSR에서 나온 것이다.
Zicsr 명령어이므로, RF_WD_src(Register File Write Data source)는 011; WB_csr_read_data로 잘 설정되어있고,
csr_data_out과 동일한 클럭에 동일한 값이 쓰여지는 것을 확인했다. 
허허.. 롤백했다. standby_mode는 유지했는데, retire값을 끌고오는 것이 CSR의 쓰기가 없을 때에만 csr_ready를 0으로 내리는 방법이었고, 사실상 CSR에서는 쓰기가 동시에 수행되니 아예 모든 CSR 접근에서 두 사이클을 잡는 것이 맞아 해당 로직을 지웠다. 이제 이 상태를 기반으로 다시 시작해야한다...

그래. 결국 WB단계에서 한 사이클씩 밀리는거고, ID단계에서 CSR 접근을 하지 않고서야 WB에서 한 사이클 딜레이가 없으니까..
WB단계에서 Zicsr 명령어임을 감지해서.. pc랑 pipeline stall을 한 번 걸어두는 방식은 어떨까?
WB단계에 Zicsr 확인되면, stall = 1
WB_stall 카운터 +1하고
만약, Zicsr인데 WB_stall 카운터 1이면 0으로 내리면서 stall도 0으로하고. 흠. 괜찮은데? 이건 어디서 처리해야할까? Hazard Unit이랑 CU에 넣어야겠다.
pc_stall은 CU관할이고, 파이프라인 stall은 해저드 유닛 관할이니까.
Zicsr 명령어의 식별자는,, OPCODE_ENVIRONMENT(1110011), funct3 != 0. 
둘 다 MEM/WB 레지스터에 있는 신호들이다. 한번 해보자. 아 애초에 opcode랑 funct3로 할 필요 없이 csr_write_enable로 확인하면되겠구나 csr 명령어는 이게 무조건 1이니까.

하하. 잠정 중단. 이건 어떻게 할 수가 없다.
CSR., 연속적인 같은 CSR주소의 접근은 아직 완전히 지원하지 않는다....
이건 지금 아무리 궁리를 해도 지적한계에 도달해서 진척이 없다. 포워딩 로직은 미완성이니 빼고, 동기식 CSR 토대로 Synthesis를 다시 해보자.
타이밍이 13ns 정도로 늘었다. Implementation까지 한번 돌려봤는데, 얘는 26ns. 음.

일단 다음 Combinational Loop부터 찾아서 해결해보자. 
Debug mode 관련해서 Loop이 있었다. 

19 LUT cells form a combinatorial loop. This can create a race condition. Timing analysis may not be accurate. The preferred resolution is to modify the design to remove combinatorial logic loops. If the loop is known and understood, this DRC can be bypassed by acknowledging the condition and setting the following XDC constraint on any one of the nets in the loop: 'set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets <myHier/myNet>]'. One net in the loop is branch_predictor/branch_estimation. Please evaluate your design. The cells in the loop are: branch_predictor/branch_estimation_INST_0,
branch_predictor/branch_target[0]_INST_0,
branch_predictor/branch_target[1]_INST_0,
exception_detector/trap_status[0]_INST_0,
exception_detector/trap_status[0]_INST_0_i_3,
exception_detector/trap_status[0]_INST_0_i_4,
exception_detector/trap_status[1]_INST_0, if_id_register_i_25,
if_id_register_i_26, if_id_register_i_27, if_id_register_i_28,
if_id_register_i_29, trap_controller/debug_mode_INST_0,
trap_controller/debug_mode_INST_0_i_2,
trap_controller/debug_mode_INST_0_i_3 (the first 15 of 19 listed).

330개의 LUT에 Loop이 있었는데, CSR_File의 Loop에서 소요가 컸던 것 같다. 이제 19밖에 안남았고, 해당 루프 경로를 유추해보니,
debug_mode가 IF의 opcode와 imm에 영향을 미치는데 (instruction 변화)
이러면 Branch Predictor에서 branch target, 그리고 Excpetion Detector에서 이걸 이용해 trap을 또 감지하고 하면 루프가 생길 것 같았다.
그래서 일단 debug_mode를 레지스터화 했고, Loop을 없애는데 성공했다. 아예 0개다.
그리고 Synthesis의 flatten 값을 none, full, rebuilt로 모두 해봤는데, 성능은 rebuilt나 full이 잘 나왔고 none은 계층구조가 무너지지 않아 디버깅에 용이했다.
덤으로 PSFS에서 rebuilt나 full로 하면 x,나 z값이 떴는데, none으로 하니까 딱히 뜨는 것들 없이 더 수행이 용이했다.
PSFS에서 의도한대로 잘 작동하는 것을 확인했고, PSTS에서는 역시 특정 시점부터 값들이 X로 도배되는 것을 보아 타이밍 관련 이슈가 뜨는 것 같다.
이는 이제 분석하면서, 본격적인 Timing Closure 작업을 시작하게 된다. 이렇게 해도 실제 implement 디자인으로 가니까 타이밍이 20ns까지 늘어지던데...
왜 이렇게 느릴까... 하긴 첫 작인데 완벽을 바라는 것 보다도 기능을 수행하게 하는 것이 중요하다.
Dhrystone 벤치마크랑, Doom 돌리기.. 화면 및 I/O 입출력 구현하기..
할게 산더미다. 이걸 이번 달 안에 다 한다니 할 수 있을까...
아니지. 해내는 수 밖에 없다. 잘 해보자.

# [2025.06.09.]
하루종일 밀려있던 Dirty 개발 파일들을 모두 commit 했고, PR열어 merge까지 마쳤다.

# [2025.06.10.]
어제 마지막으로 PR한 것에 대해 추가적으로 파형에서 x값이 발견되어 레지스터 파일의 초기 0값을 부여하는 로직을 commit 하고 최종 탑 모듈에서의 테스트벤치와 검증 파형까지 첨부해서 CSR File을 동기식으로 만든 시점에 대한
Revision을 PR했다. 그리고 시작된 Timing Closure 작업.
그리고 Timing Closure 작업의 시작인데, 파형을 확인해보니 Instruction들이 단순히 파이프라인레지스터들을 통과할 뿐인데 변조되는 것을 확인했다.
파형을 보면, 파이프라인 레지스터에 들어간 명령어가 레지스터끼리 옮겨가면서 값이 변하고 있는데, 왜 다음 클럭으로 넘어가면서 값이 변조될까?
원래도 2bc00093이어야하는데 처음엔 23c00093에서 2bc00080 이었다가 EX단계에 가서야 2bc00093이 되고,, 그 다음명령어도 01809113이 원래 맞는데 ID단계에서는 값이 01809100으로 변했다가 EX에서 다시 원래대로 변하고... 파이프라인에서 서로 값 넘길 때 별도의 로직이 없는 이상 값이 안변하는게 맞을텐데...
Post Synthesis Functional Simulation이랑 Behavior Simulation에서는 잘 됐었는데... 원인이 뭘까? 

디버깅하며 같은 클럭 1 인 상태 안에서도 값이 여럿 변하는 것을 목격하면서 글리치 문제도 물론 있겠지만 구조적인 조합식 로직의 취약점을 체감하였다.
그래서 Instruction Memory를 동기식으로 바꾸려고 한다. 적어도 한번 PC값이 들어가면 다음 사이클까지 바뀌지 않는다는 확정적인 조건을 부여하고, 
그리고도 값이 변하면 글리치로 특정지어 다른 조치 사항을 취할 수 있기 때문이다. Instruction Memory를 동기식으로 바꾸면서 PTH라던가 첫 실행시에만 Instruction Memory ready신호를 0 그리고 1로 바꾼다던가
(어차피 다음 사이클부터는 계속 유효한 값이 나가는게 맞으니까. 처음 값만 이상한게 나가지.) 여러가지 사항들을 접목하고 있는데, CSR명령어에서도 뭔가 이상한 경우를 발견했다.
분명 42번째 명령어 (data[41])에서 mtvec의 값이 이전 명령어에서 1007로 바뀌고 이번에 1000으로 바뀌어서 다시 제대로 trap handler 분기가 되어야하는데 1000값이 쓰여질 때 CSR write enable이 0으로 되어있는 것을 발견했다. 아마 CSR_WE 신호의 파이프라인 값을 트래킹하면서 봐야할 것 같다.
오늘은 컨디션이 많이 안좋아서 하루 종일 편두통에 시달려 거의 19시 30분부터 작업을 시작할 수 있었다.
내일은 더 나아지길 (이래놓고 연등하느라 수면 부족이지만).
오늘은 여기까지.

# [2025.06.11.]
시간이 너무 빨리 지나간다. 하루에 할 수 있는 것은 정해져 있고, 사력; 최선을 다하여도 될지 안될지 모르는 무모한 가능성에 난 한 발자국씩 도전하고 있다.
오늘도 시작해보자. (18:51)
위에 CSR_WE 신호가 WB파이프라인에선 제대로 나오고 있음을 확인하고 탑 모듈에서 CSR Write Enable source에 standby mode가 따로 조건문으로 적용이 되어있지 않아 이걸 적용하여 해결했다.

그러나, ecall trap PTH 수행 완료, 분기 후 수행 지점에서 그 이전에 있던 ecall 다음 명령어로 fetch된 명령어가 IF_ID_register에 그대로 남아있었고, 
(이건 flush를 해도 pc값에 대해 instruction memory가 데이터를 인출하는 것이기에 멈출 수 없다. ) 00001000 pc 주소 명령어가 수행되어야하는데 해당 misaligned sh 명령어 TRAP이 중도에 발현되어
mepc값이 또 Trap Handler로 들어가 무한 루프에 갖혀버렸다. 다음 클럭에 flush 되어 IF_ID_Register의 인출 값이 0과 NOP로 비워져있으니 입력되고 있는 00001000의 명령어가 기존엔 바로 나와줘서
IF단계에 pc_stall로 갖혀있는 sh값을 없앴는데, 지금은 동기식이라 0000_1000이 instruction Memory에 입력된 뒤 한 사이클 뒤에 해당 현상을 기대할 수 있기에 IF_ID_Register를 PTH 이후 한 사이클만 더 flush해야한다.
stall도 되겠지만, 일단 flush로 해보자. 흠, Trap Controller에서 추가 FSM 단계를 넣었는데 flush가 되질 않길래 확인해보니 이미 앞에서 flush를 해서 해당 명령어에 대한 context가 없는 상황임을 확인할 수 있었다.
아니다. 지금 이것 때문에 pc_stall이나 여러 로직들을 상황에 맞게 하나하나 추가하는 것이 소요를 더 크게 만들고 복잡한 것일 수록 약하기 마련이다.
단순하게, Instruction이 이제 한 사이클 뒤에 나오게 되니 pc도 변경에 따라 한 사이클 지연되어 나오도록 하면 되지 않을까? 레지스터화 하는 것이다.
아마 비슷한 아이디어가 논문 
장선경, 박상우, 권구윤 and 서태원. "FPGA를 이용한 32-Bit RISC-V 프로세서 설계 및 평가" 정보처리학회논문지. 컴퓨터 및 통신시스템 11, no.1 (2022) : 1-8.
에서 봤던 것 같다. 뭔가 기억났었는데, 한번 해보자.
아무런 성과가 없었다.
정확히는 Instruction Memory를 동기식으로 바꾸는데 엄청나게 많은 소요가 든 다는 것.

허허 참. 원상복귀다. 
내일은 그냥 이걸 무시하고, I/O 구현해 FPGA에 올리고 되나 안되나 볼 것이다.
온르은 여기까지. 하아.,

#[2025.06.12.]
일과시간 동안 이 Timing Closure 작업에 대해서 생각해보았다. 
정확히는 아직 Timing Simulation에서 기대하는 동작대로 수행이 되질 않았으니 디버깅에 가까울 것이다. 

아무래도 Implementation Functional Simulation에서도 Z값으로 IF단계의 instruction이 뜬 것으로 보아 Post Synthesis Timing Simulation에서 명령어가 이상하게 전달된 것의 원인을 내포하고 있는 것 같다는 생각.
기억으로나마 비교해보았지만, 파형에서 Z값이 뜬 비트 위치가 정확히 다른 숫자가 표시된 위치였다. 즉 그 Z값의 위치에 임의의 값이 PSTS에서 보여지게 된 것.
파이프라인 레지스터의 로직은 너무나도 단순하고 직관적이다. 때문에 파이프라인 레지스터의 문제라고는 생각하지 않는다.
Instruction Memory의 로직도 너무나도 단순하고 직관적이다. 비동기식이라는 단점은 해당 메모리 유닛에 복잡한 로직에 따라 그 기댓값이 변할 수 있을 때 드러나는 것이지,
단순히 입력받은 pc값을 내보내는 조합논리 회로는 그러한 요소로서 불안정성이 유의미하게 증대되지는 않는다고 생각한다.
다만, 문제라면 파이프라인에 전달되는 그 중간단계에서 있을 가능성을 염두한다.
파이프라인 레지스터는 동작을 잘 한다. Instruction Memory에서도 동작을 잘 한다. 그렇다면 문제는 그 사이의 로직.
우리의 RTL 설계에선, debug_mode 신호에 따라서 IF_ID_Register에 입력되는 명령어가 상이해진다. 그리고, 이 debug_mode로 인해서 입력되는 명령어는 고정 상수값 변수로, top module에서 dbg_instruction이라는 변수 명의
32'b00000001011110110000110000110011 값이 할당되어있다. 0x017b0c33. 
add x24, x22, x23 인데, 이를 Trap Controller에서 debug_mode를 활성화하는 순간 조합로직의 MUX 조건문을 통해서 해당 명령어가 IF_ID_Register로 입력되도록 하였다. 
차라리 이 과정에서 불안정성이 생겨 debug_mode에 대한 항시값이 Trap Controller에서 계속 부여되고 있다고 한들 Trap Controller의 복잡도를 생각하면 이전보단 타당한 가설이라고 생각했다.
때문에 이 debug_mode로 들어가는 것을 (이미 Trap Controller에서는 Combinatorial Loop을 끊기 위해서 레지스터화를 거쳤지만) 탑 모듈에서 동기식으로 신호를 받아 작동하도록 수정해볼 심산이다.
하지만 이건 주된 문제가 아니다. Z값이 파형에 존재하는 것은 물론 심각한 문제이지만, 어찌되었던 PSTS와 PITS에서 의도된 동작을 수행하는 것을 확인했기 때문이다.
진짜 문제는 중간에서부터 모든 값들이 X로 도배되는 시점이다.

이에 대한 내용을 담은 두 번째 생각이다. 
파형을 보면, 어찌저찌 중간까지는 EX단계에서 제대로 작동되고 WB단계에서도 레지스터에 값이 쓰여지지만 특정 시점에서부터 instruction과 다른 값들이 X로 도배되는 시점이 생긴다.
이는 사실 앞에서 instruction이 불안정하게 IF_ID_Register에 입력된 것과는 거리가 먼 문제점이라고 볼 수 있다고 생각했다.
그리고 해당 시점의 파형에서는 한 클럭안에 유지되어야할 하나의 next_pc값이 여러번 바뀌는 것을 확인할 수 있었는데, 무언가의 race-condition, 그리고 그게 정의되지 않은 상태에서 다음 Clock Cycle로 넘어가서 생기는
UNDEFINED (X) 오류가 생긴 것이라 추측했다. 이는 이제 파형을 보면서 해결해야할 부분이다.
시작해보자. (19:23)

흠,, 자세히 보니까.. Trap Control 관련 문제인 것 같다. 파형이 X로 도배되는 시점이 SH, Instruction Memory에서 trap관련 로직이 구동될 때인데,,
![Trap_Controller's_Combinational_Logic_Signal_Uncertainty](Devlog_images/Unstable_Trap_Status.png)
trap_status가 CC가 활성화 되어있을 때 원인신호를 추적할 수 없는 단위로 변경되어 제대로된 값을 도출해내지 못하여 이렇게 되는 것 같은데,
Exception Detector도 조합로직이 아니라, 동기식으로 바꿔야하나? 흠,,
하긴 명령어의 수행 자체에서 디코딩된 정보들을 조합하여 Exception을 찾아내는 모듈이니까 해당 문제의 명령어가 탐지되어 다음 사이클에 Trap을 발생시킨다 한들, 현재 구조에선 WB에서 발생하는 Exception은 없으니까
문제 없을 것 같다. 독립적으로 동작하는 모델이다보니 추가적으로 수정할 소요도 적어질 것 같고. 한 번 수정해봐야겠다. 
음. Exception Detector를 동기식으로 전환하면서 Detection 타이밍이 다음 사이클로 밀린 관계로 PTH의 MTVEC 진입을 두 FSM에 거쳐서 진행하도록 해야했고 (trapped신호가 1사이클 늦게 풀리므로) 
mepc에 적는 pc값의 타이밍을 기존 EX단계에서 MEM 단계로 전환해야 했다. 이렇게 해서 어느정도 로직이 되었는데, (여태까지 만든 변경사항 중 가장 순조롭다) ecall시 타이밍이 조금 다르다보니
trapped로 전환되면서 WB단계의 csr_write_enable이 끊겨 제대로 retire되어야하는 데이터가 retire되지 않는 상황이 발생해 이 것만 해결하면 된다. 이미 abadbabe 출력은 확인했으니..
저녁점호하고 와야겠다.

시작하자 (21:47)
Exception Detector에서 trapped신호를 보내면, 그걸 즉시 Top module의 CSR Write Enable source MUX 신호로 쓰지 말고,
해당 신호를 trap_controller에서 받아서 IDLE에서 실제로 아무 동작을 수행하지 않고 다음 단계로 넘어가게 하도록 하는 대신 IDLE 단계에서 csr_trap_enable 신호를 출력하도록 해서 해당 신호를 기반으로 
CSR write enable source를 조정하면 될 것 같다. 아, 아니지. 애초에 Trap Controller에 별도의 csr_write_enable신호가 출력으로 나가고 있었구나. 이럼 차라리 TC의 csr_write_enable신호를
MUX의 제어신호로 하면 될 것 같은데.. 타이밍이 좀 우려되긴 하지만 해보긴 하자. 
기존에 탑 모듈에서 csr_write_enable_source를 trapped를 제어신호로 하여 MUX로 처리하고 있었는데
assign csr_write_enable_source = tc_csr_write_enable ? tc_csr_write_enable : WB_csr_write_enable; 로 변경하여 해결했다. (설마 Combinatorial Loop는 안생기겠지..)
나머지 진행도 CSR RAW 문제 제외하고 모두 예상값대로 수행되는 것을 확인했다. 수정된 코드를 기반으로 PSTS를 해보자.
일단 Behavior Simulation은 iverilog 시뮬값과 동일해 보인다.
Synthesis 해보고 PSFS, PSTS 바로 들어가보자.
다행히 Synthesis에서 Loop이 보고되진 않았다. 

아... 거의 그대로인데.. 이제는 아예 파형에서 trap_status가 잡히질 않는다.
출력을 동기식으로 하는 것이 아니라 exception 판단 자체를 동기식으로 해야하나?
흠,,, 수정해보자.

미치겠다. 수정할게 너무 많다.
벌써 6월 중순인데. 과감하게 46F 아키텍처를 포기하고 43F로 돌아가보도록 한다
결국 Trap Handler 분기 시점에서 이상하게 되는거니까, Trap 관련을 비활성화 하고, I/O를 만들고 나면 이후 추가하면서 문제를 해결하는 것으로 로드라인을 변경한다.
근데... 아니 그냥 Instruction Memory 내용 자체를 Trap 없게 만들었는데도 왜 같은 시점에서 이러는거지????
돌겠네. 

# [2025.06.13.]
잘 되던 프로젝트가 갑자기 Synthesis에서 timing constraints를 met하지 못하더니 object가 없다고 뜨고 모든 파일에 syntax error가 뜨고 진행이 안되기 시작했다.
하아.,
허탈하게도, 새 프로젝트를 만들어서 지금까지 한 Exception Detector의 출력을 동기식으로 만든 변경 사항까지를 적용해서 Synthesis 후 Timing Simulation을 돌렸더니..
이게 웬걸, abadbabe까지 정상 진행됐다...
곧바로 Implementation까지 직행.. Timing Simulation을 돌려보니... csr 쓰기 신호가 timing 문제로 한 사이클 더 필요한데 닿지 않아 값이 쓰이지 않아 mtvec이 이상한 값으로 들어가 무한 루프가 걸리는걸 발견했는데,
어차피 Dhrystone과 같은 벤치마크에서 시스템명령어는 사용하지 않을 것 같아 일단 해결을 시도해보고 문제가 그대로이기에 일단 FPGA 구현으로 넘어가도 상관 없게 되었으니 Dhrystone을 ROM에 넣고 있다.
내일은 이걸 구현하고, FPGA에 download해서 디버깅을 진행하면 좋을 것 같다.
단번에 되리라고는 기대하지 않는다. 그래도.. 될 가능성이 보이니까 진행한다.
잘 해보자..

# [2025.06.14.]
동기식 Exception Detector 변경 사항과 탑 모듈 리비전 내용을 PR하는 것을 완료했다. 
이제 어제 하던 Dhrystone 구현을 마저 해볼 차례.
하루종일 툴체인과 Dhrystone 컴파일과 싸웠다.
결국엔 sifive에서 배포한 툴체인 프리셋은 rv32i-ilp32를 지원하지 않았기에, 다시 처음부터 툴체인을 risc-v gnu gcc로 다운받아야했고
./configure하고 make로 만드는데에 시간이 꽤 걸리는데 인터넷이 중간에 자꾸 끊겨서 (군대라서) 진척을 영 못냈다.
그래도 msys2 mingw64 쓰는 법이나 툴체인 설치 등등 관련해서 꽤나 잘 알게 된 것 같다
linker가 필요하고, gcc 툴체인이 필요하고, 그걸 위한 기초파일들 설치하고 등등..

# [2025.06.15.]
23:39. 진짜 하루종일 툴체인과 싸웠다.
그 중간중간에 CPU를 검증할 SoC 설계를 해서 OLED에 버튼을 통해 현재 명령어와 수행모드를 전환하여 수행하고, 그걸 디버깅할 수 있도록 인터페이스를 설계했다.
risc-v 툴체인을 처음부터 빌드를 해야하는데 어제 언급한 인터넷 때문에.. 친구에게 연락해서 친구 컴퓨터에 대신 툴체인을 빠르게 설치하고
(그마저도 3시간이 걸렸다.) dhrystone을 컴파일하는데 21:30분에 겨우 마쳤다.
rv32i로 컴파일된 dhrystone을 찾지 못했을 뿐더러 dhrystone 자체가 구버전 코드라 Sifive 배포판이랑 riscv-tests 배포판이랑 또 다 해보고
컴파일 에러들 디버깅하고 하느라 진짜 하루종일 다 썼다.
이제는 그 hex파일들을 받았고, 그리고 위에서 설계한 FPGA 검증 SoC를 Vivado에 올리고 있다.
해당 탑 모듈 tb 돌릴때 너무 타임을 크게 잡아서 vcd가 45GB나 되어버리는 대참사 때문에 그 당시엔 이유를 몰라서 Vivado를 D드라이브로 옮기느라 작업을 못했다.
일단.. 내일 할거
외부 인터페이스는 100MHz 로 동작하고, CPU는 50MHz로 동작할 예정인데, generated clock constraints가 XDC에 선언되어있지 않아서 추가했다
추가했더니 Timing Violation이 바로 나왔다. cpu_core에서 led로 가는데 11.102ns가 걸린다는 것. 
단순한 토글 클럭 분주기로 되어있는걸 Clock Enable로 바꿔서 다시 진행해봐야한다. 
그렇게 현재 있던 Instruction Memory 시나리오를 FPGA에서 구현하면서 CPU의 작동을 검증하고
Dhrystone 컴파일된걸 Instruction memory에 readmemh로 올려서 성능을 측정 해봐야한다. 
그리고 남은 시간동안은, DMIPS를 올리는데에 집중한다. 지금 50MHz니까 Critical Path를 정비해서 100MHz 이상으로 올리는 것을 목표로 한다.
Doom은.. 이거 다 하고도 시간이 남으면 구현해보자..
오늘은 여기까지.

# [2025.06.16.]
Clock Enable 적용 시작(18:58)
Clock Enable 모두 적용 했고, Vivado에서 기존 프로젝트에 파일들이 탑 모듈의 탑모듈이 생기며 손을 쓰기 힘들 정도로 틀어져 새 프로젝트를 만들고 클린하게 정리했다
버튼, OLED 인터페이스 100MHz, CPU 50MHz였고, Timing Violation 처음에 CPU의 50MHz 클럭을 토글식으로 구현한 데에 있어 발생했던 것을 카운터 식으로 바꿔서 해결했고
OLED도 Timing Violation 뜨길래 50MHz로 낮췄고, Button도 마찬가지로 50MHz로 낮췄다. Behavior Simulation을 돌려보려고 하였으나, 뭔가 느낌이 많이 달라서 클럭 연결의 문제라고 생각하고 어차피 
CPU도 제대로 tb 돌아갔던 것 그대로 코드 썼고, SoC도 마찬가지로 iverilog에서 원하는 값이 나왔기 때문에 Synthesis로 바로 넘어갔다.
Timing Contraints관련인가, timing not met 나와서 XDC에서 constraints를 추가했고 Implementation에서는 결과가 더 좋게 나올까 싶어 Implementation을 돌렸다.
create_generated_clock -name clk_50mhz -source [get_ports clk] -divide_by 2 [get_pins clk_50mhz_reg/Q]
set_multicycle_path -setup 2 -from [get_clocks clk_50mhz] -to [get_pins */*clk_enable*]
clk50mhz로 인한 의도치 않은 timing 계산에 대한 violation 알림을 끄기 위해 set_false_path도 썼다.
그리고 SoC TOP 모듈에서 출력에 debug pc랑 instruction을 모두 내보내는 것 때문에 IO 핀이 부족해져서 어차피 OLED로 확인 가능할 것이기 때문에 코드에서 과감히 output을 제외했다.
결과를 봐야하는데.. 시간이 다 되어서 여기까지.

# [2025.06.17.]
결과를 보니까 여전히 포트 문제가 나서 xdc 파일에 set_property ... [get_ports debug_*] 이런 와일드카드 때문에 의도치 않은 수 많은 신호들이 연관되어 버린 것을 확인했다
이를 없애서 해결했고, Implementation 성공.
Timing도 괜찮지만 이번엔 또 다음 목록과 같은 곳에서 not reached by a timing clock Critical Warning이 떴다.
TIMING #1 The clock pin FSM_onehot_display_update_state_reg[0]/C is not reached by a timing clock 
TIMING #4 The clock pin FSM_onehot_step_state_reg[0]/C is not reached by a timing clock 
TIMING #7 The clock pin button_controller/button_prev_reg[0]/C is not reached by a timing clock 
TIMING #12 The clock pin button_controller/button_rising_edge_reg[0]/C is not reached by a timing clock 
TIMING #17 The clock pin button_controller/button_stable_reg[0]/C is not reached by a timing clock 
TIMING #22 The clock pin button_controller/button_sync_reg[0][0]/C is not reached by a timing clock 
TIMING #37 The clock pin button_controller/continuous_counter_reg[0]/C is not reached by a timing clock 
TIMING #62 The clock pin button_controller/continuous_mode_reg_reg/C is not reached by a timing clock 
TIMING #63 The clock pin button_controller/continuous_pulse_reg/C is not reached by a timing clock 
TIMING #64 The clock pin button_controller/debounce_counter_reg[0][0]/C is not reached by a timing clock 
TIMING #159 The clock pin button_controller/display_mode_reg_reg[0]/C is not reached by a timing clock 
TIMING #161 The clock pin button_controller/mode_changed_reg_reg/C is not reached by a timing clock 
TIMING #162 The clock pin button_controller/reg_changed_reg_reg/C is not reached by a timing clock 
TIMING #163 The clock pin button_controller/selected_register_reg_reg[0]/C is not reached by a timing clock 
TIMING #168 The clock pin button_controller/step_pulse_reg_reg/C is not reached by a timing clock 
TIMING #169 The clock pin button_controller/step_pulse_reg_reg_lopt_replica/C is not reached by a timing clock 
TIMING #170 The clock pin cpu_clk_enable_reg/C is not reached by a timing clock 
TIMING #171 The clock pin oled_interface/FSM_onehot_spi_state_reg[0]/C is not reached by a timing clock 
TIMING #174 The clock pin oled_interface/FSM_onehot_state_reg[0]/C is not reached by a timing clock 
TIMING #181 The clock pin oled_interface/delay_counter_reg[0]/C is not reached by a timing clock 
TIMING #201 The clock pin oled_interface/frame_buffer_reg[0][1]/C is not reached by a timing clock 
종류별로 발췌했고 201부터 1000까지 프레임 버퍼의 not reached by a timing clock 이다. 그래서 이를 해결하기 위해서 create_generated_clock을 xdc에 추가했다.
기존에 지웠었는데 다시 만든 것.
그랬더니 이제 CDC; Clock Domain Crossing 발생해서 clk to clk_50mhz를 false path로 해서 없앴다.
그랬더니 CKLD #1 Clock net clk_50mhz is not driven by a Clock Buffer and has more than 512 loads. Driver(s): FSM_onehot_display_update_state_reg[0]/C,
FSM_onehot_display_update_state_reg[1]/C,
FSM_onehot_display_update_state_reg[2]/C, FSM_onehot_step_state_reg[0]/C,
FSM_onehot_step_state_reg[1]/C, FSM_onehot_step_state_reg[2]/C,
clk_50mhz_i_1/I1, clk_50mhz_reg/Q, cpu_clk_enable_reg/C,
reset_sync_reg[0]/C, reset_sync_reg[1]/C, reset_sync_reg[2]/C,
rv32i46f_5sp_debug/clk, update_display_reg_reg/C, update_pending_reg/C
(the first 15 of 17 listed) 가 떠서 자세히 보니까 Clock Buffer가 없으면 위험하다는 것 같아 buffer를 넣어뒀고.. 이제 에러가 없다.
Implementation 시작.

# [2025.06.18.]
OLED를 구현하려고 애써보았으나, 시간과 기간의 문제로 일단 잠정보류 후, 가장 빠르게 현재 상태를 확인해보기 위해 8개의 LED를 instruction 하위 7:0 비트를 할당하여 
가운데 버튼을 통해 순차 실행하므로서 명령어의 처리 흐름을 간이로 검증했다. 그 결과, trap handler 분기까지 정상적으로 의도된 대로 작동하는 것을 확인할 수 있었고,
비슷한 방식으로 레지스터의 값을 볼 수 있도록 LED 인터페이스를 통해서 검증하기로 했다. 이걸 내일까지 마칠 것이고, 바로 UART 로 넘어가서 Dhrystone 구동을 통해 성능을 측정해서 종지부를 찍을 예정이다.
정말 험난하고도 먼 모험이었다. ChoiCube84에게 우선 감사의 말을 전하고, 남은 마무리까지 잘 이행하도록 해야겠다.
2025.06.18. 
23:43.
RV32I46F_5SP
FPGA Implementation.

KHWL && ChoiCube84

# [2025.06.19.]
LED와 버튼, 스위치를 이용해서 OLED Interface에서 보려고 했던 레지스터 선택, 레지스터의 값, 현재 명령어, 현재 PC값을 추가적으로 검증해보려 하였지만
일단 UART를 구현하고 나면 해당 검증까지 다시 해봐야하기도 하고 그 즈음가서 하는 것이 더 빠르고 편할 것이기 때문에 바로 UART 인터페이스 구현에 착수했다.

# [2025.06.20.]
UART 구현했고, 테스트 시나리오 잘 돌아간다. 이제 이걸 develop에 PR 올리고 그걸 다운받아 다시 시험해봐야겠다.

# [2025.06.21.]
MISALIGNED STORE, LOAD를 이원화한 Trap Handler Instruction Memory에서 정상적인 수행이 되지 않는 다는 것을 발견했다. 왜일까? 일단 issue로 남겨두고 dhrystone 구현에 집중하도록 한다.

# [2025.06.22.]
dhrystone 구현을 하는데, 루프가 발생해서 관련한 디버그 로그를 남기려고 한다.
원래 여태 계속 남겼어야 했는데 하나 고치고 하나 문제 생기고 하는걸 시간이 없어서 기록하지 못했다.
정말 한시가 급해서 끼니도 거르고 계속 몰두하고 있다.

x0  – zero  
x1  – ra  
x2  – sp  
x3  – gp  
x4  – tp  
x5  – t0  
x6  – t1  
x7  – t2  
x8  – s0/fp  
x9  – s1  
x10 – a0  
x11 – a1  
x12 – a2  
x13 – a3  
x14 – a4  
x15 – a5  
x16 – a6  
x17 – a7  
x18 – s2  
x19 – s3  
x20 – s4  
x21 – s5  
x22 – s6  
x23 – s7  
x24 – s8  
x25 – s9  
x26 – s10  
x27 – s11  
x28 – t3  
x29 – t4  
x30 – t5  
x31 – t6  



addi a1, s2, 0
x11 = x18 + 0; x11 = 1000_7fa0
addi a0, s1, 0
x10 = x9 + 0; x10 = 1000_7f80

루프 이전 : a0(x10) = 0000_0001
s3(x19) = 0000_0001
a1(x11) = 0
s2(x18) = 1000_7fa0
s1(x9) = 1000_7f80

addi s0, a0, 0
x8 = x10 + 0; x8 = 0000_0001

beq a0, s3, -16
if x10 = x19, PC = PC + (-16) 
같다! PC = 0000_097C -> 0000_096C

lbu a1, 3(s2)
x11 = 1000_7fa0
EA = R[s1] + 3 = 1000_7fa3

CPU에는 Dhrystone을 올렸ek. 
문제는 지금 loop. 자꾸 jal ra, -80으로 되돌아가게 되고, 이걸 마주치지 않으려면 그 이전에 있는 beq a0, s3, -16이 not taken 되어야하는데 taken이 되고있다. 
그럼 어디서부터 이 둘이 같게되었는지를 찾아보고 그러다보니까 메모리 영역 문제를 찾게되었다. 
0x1000은 datamem, 0000은 ROM으로 한다면 그냥 명령어에서 data memory의 0000_1664를 load하면 1000_5990에 저장한 값이 나오게 될 수도 있다.

우리 Instruction Memory는 ROM으로 pc값에 대한 명령어만 나오게 하고 있는데, 그럼 이 주소 필드 0x0000nnnn 들에 대해 읽는 요청이 당연히 있을 수 있으니까 그에 대한 처리를 해야할 것 같다. 
명령어를 수행하면서 load나 store는 모두 data memory에서 처리되는데 막상 data memory에서 쓰이는건 0x1000nnnn 영역이니까 0x0000nnnn에 대한 처리가 data memory로 들어오게 되면 
그건 instruction memory의 값을 출력해주는게 올바른 것 같고... 
이래서 통합 메모리 위에 분리된 instruction cache와 data cache를 갖는구나. instruction 만 담아두는 메모리는 IF단계에 위치해서 MEM단계에서 그 값을 불러오기에는 구조적으로 골치아파지니까 
이 경우 cache miss를 내고 RAM에 잡힌 통합 메모리에 있는 0x0000nnnn에 대한 데이터를 그냥 갖고오면 되니까... 
메모리 계층구조가 단순히 속도 때문만이 아니라 구조적 최적화에 대한 내용도 품고 있는 거라고 봐도 되겠지? 
일단은, 임시적으로 data memory 안에 instruction memory 안에 있는 데이터를 모두 넣고, 그걸 rom처럼 읽기만 가능하게끔 수정하면 좋을 것 같다.
아니면 그냥 Data memory 안에서 주소 영역이 그에 겹치면 Instruction Memory에서 인출된 값을 그대로 출력하도록 해도 괜찮을 것 같다.
Instruction Memory의 내용을 Data Memory에서 출력할 수 있도록 변경.
조치했는데도 여전히 loop는 같다. 어떡하면 좋지?
지금 디버깅은 iverilog simulation vcd로 파형 보면서 진행하고 있다. 
더티파일로 진행하다가, 오히려 로직의 보장을 할 수가 없어져서 commit 31344d Synchronous Exception Detector 구현 시점 기준 소스파일을 다운받아 다시 하고 있다.

Loop의 흐름은 이렇다..
PC 380: addi a0, sp, 64
a0 = 1000_7fa0
s3 = 0000_0000

PC 384: jal ra, 2232

PC = c3c
... 프로그램 진행중. a0, s3는 변경 없음.
둘다 그대로 
a0 = 1000_7fa0
s3 = 0000_0000

...
PC c54: jalr zero, 0(ra)

PC = 388
...
PC 38c: addi a0, sp, 32
a0 = 1000_7f80
s3 = 0000_0000

PC 394: jal ra, 1460

PC = 948
...
PC 968: addi s3, zero, 1
a0 = 1000_7f80
s1 = 0000_0001
...
PC 970: lbu a0, 2(s1)
a0 = 0000_0000
s1 = 0000_0001
...
PC 974: jal ra, -80

PC = 924
...
PC 940: addi a0, zero, 1
a0 = 0000_0001
s1 = 0000_0001

PC 944 : jalr zero, 0(ra)

PC = 978 (ra가 이 때 0000_0978 이었음.)
...
PC 97c: beq a0, s3, -16
a0 = s3, Taken.

PC = 96c
...
PC 974: jal ra -80

PC = 924
...
PC 940: addi a0, zero, 1
a0 = 0000_0001
s1 = 0000_0001

PC 944 : jalr zero, 0(ra)

PC = 978
...
PC 97c: beq a0, s3, -16
a0 = s3, Taken.

PC = 96c 무한반복...

38c : addi a0, sp, 32로 a0이 1000_7f80이었는데,
960: addi s1, a0, 0 으로 s1은 이 때 1000_7f80이었고. 
970: lbu a0, 2(s1)으로 a0이 0000_0000이 된다.

그 이후, 974: jal ra, -80으로 PC는 924.
그리고 940: addi a0, zero, 1로 a0이 0000_0001이 됐다.
그러다가 또 970에서 0000_0000이 되고. 
루프.

이 문제는.. 다음과 같은 결과로 해결되었다.
FPGA에서 계속 loop 돌길래 뭐지 하고 5 시간 동안의 디버깅에 거쳐 jump, branch est의 조건 우선순위 문제인것을 발견하고 PCC를 수정.
branch estimation은 jump가 EX도달 하여 분기하기 이전에 IF단계에 생길 수 있지만 jump가 앞에 있는 이상 무시되어야하기에 jump가 branch est보다 우선순위가 높아야한다.
branch_prediction_miss 또한 마찬가지. 틀렸다면 IF단계의 est가 의미 없기에 branch Prediction miss는 branch est보다 높아야 한다.
branch miss랑 jump는 서로 같다.(둘이 똑같이 EX단계에서 알 수 있으므로) 그리고 이 둘은 충돌할 수 없으므로 상관 없음. jump를 1순위, 그 아래로 2-3순위로 배치했다.

그런데도 루프가 생긴다..
애초부터 컴파일이 잘못되었나? linker의 문제인가..
여러가지 보니까 아무래도 data가 원래 초기화되면서 값들이 올라가야하는데 관련한 내용을 boot.s에서 빼먹은 것 같다. 그래서 이를 수동으로 올렸다.
dhrystone.mem 에서 1424(1부터 하면 1425)부터 data들인데, 이걸 별도로 data_init.mem으로 바꿔서 data memory initial begin에 올렸다.

BE Logic에서 주소의 하위 2비트 address[1:0]가 사용되질 않아 항상 워드의 첫 바이트만 가져나올 수 있다는 우려가 보였다.
어차피 Data Memory에서 마스크로 어찌저찌할거니까 상관 없나.

놀랍게도 08시부터 지금(19:50) 까지 계속 하고 있다.

일단 data_init을 따로 빼니까 loop는 없어진 것 같아서 그대로 시뮬기반 파일에서 변경사항 있는 RTL만 빼서 적용하고, (Data Memory, Instruction Memory, core 모듈 인스턴스 수정)
FPGA synth-impl-bitstream 중.

이런. 다른 이상한 Loop이 나왔다. 
생각해보니 예전에 미뤄둔 부분인 Load 부분의 lb, lh에 대한 미흡한 구현이 있던 것 같아 이를 보완해서 다시 돌렸다. (위에서 언급한 BE Logic)
그렇게 20:50. 0x0000_006F jal x0 0 명령어를 끝으로 dhrystone이 모두 돌아갔다!!!!

이제 그 성능 측정을 위해 mcycle값이랑 minstret 값을 받아서 계산을 해봐야한다.
원래대로라면 그렇게 끝나자마자 자동으로 final cycles, final intructions 가 나와야하는데 안나오네.
관련해서 수정을 해야겠따.
차라리 기존에 있는 버튼 로직에서 alu result가 나오던 우측 버튼을 final cycles랑 final instructions가 나오게 바꿔야겠다.
이게 훨씬 구현 자체는 빠를 듯.

Instruction Memory에 rom read address, data 관련 로직을 추가해서 (data memory-instruction memory 통로) 타이밍이 0.02x 정도로 엄청 빡빡해졌다.
어라. 왜 다른 버튼들 다 작동도 안하고 000000000FE만 나오지? 

DebugUartController에서 alu_result에서 final_Cycles, instructions로 바꾸면서 교체하지 못한 로직이 있길래 마저 교체하고 다시 돌린다.
Synthesis 옵션도 Performance Opti 로 했고, Implementation도 Performance Explore로 해봤다.
과연 얼마나 변할까? 
Dhrystone을 내장시키고 난 뒤엔 합성에 거의 10분이 걸렸는데, 이번엔 어떻게 될까...
아 그리고, risc-v 툴체인이 로컬 시스템에 없는게 너무 아쉬워서 방법을 찾던 도중, 친구가 구글 colab을 추천해줘서 둘러보고 있다.
rv32i ilp32 multilib로 해서 make하는 중인데, 확실히 시간이 꽤 걸린다. 그래도 속도는 빠르고 용량도 넉넉해서 한번 사용할 가치는 있는 것 같아서 계속 빌드 켜 놓는 중.

와.
다른 버튼들 동작은 안하는데, 일단 ㅋㅋㅋ 성능 자료가 나왔다.

## [RV32I46F_5SP @ 50MHz Dhrystone benchmark]
00000000FEA94
Instr: 000000000009DDF0
이렇게 떴다. 위에는 Cycles일거고 (final_cycles)
아래는 final Instructions.

각각 1,043,092 / 646,640 이다.
총 사이클이 1,043,092 사이클 걸렸다는 것.
이걸로 DMIPS와 DMIPS/Hz를 계산해보자.
우리 클럭 50MHz.

수행 시간은 1043092/50×10^6이다. 0.0208618초.
Dhrystones/second = 반복횟수 / 수행 시간 = 2000 (DHRY_ITERS) / 0.0208618 = 95875

DMIPS = 초당 1757 Dhrystones
95875 / 1757 = 54.6DMIPS

54.6DMIPS / 50MHz = 1.09DMIPS/MHz.

이야. 하하. 하하하하하!!!!
이제 이 파일들을 develop에 push하고, 캬.. ㅋㅋ
데이터 나온 것들 종합하고, 코드 최적화하면서 최종 블럭 다이어그램을 수정하면 된다..
길잡이로서 쓰던 다이어그램을 이제 구현 이후 완성된 설계도로서 최종본을 그린다니..
감회가 색다르다. 23:21에 성능 계산 다했는데, 부모님께 전화하고 싶다. 아.
지금은 23:59.
이만 마친다.

# [2025.06.23.]
계획을 수정했다.
https://isocc.org/?page_id=180
2025년 10월 15일부터 18일에 거쳐 이뤄지는 ISOCC; International SoC design Conference의 논문 최초 제출이 2025.06.27일에 마감한다.
등재가 되던 안되던, 짧은 시간안에 본 개발이력과 코드를 가지고 논문을 완성해서 러프한 느낌이 있더라도 제출하도록 한다.
Github에 PR은 그 이후 주말에 날 잡고 할 예정.
Git에서 Release를 나눠서 할 것이다.
우선 basic_rv32s 레포지토리의 메인 시나리오는 모두 완료되었다. 
RV32I37F, RV32I43F, RV32I46F, RV32I46F_5SP, 46F5SP_SoC
이렇게 총 5가지의 배포판을 만들 것이며, RV32I46F까지는 RTL 합성(시뮬레이션)으로만.
그리고 RV32I46F_5SP와 46F5SP_SoC는 FPGA로 합성 가능하다고 표기할 것이다. 

논문의 내용은...

RV32I46F_5SP에 대한 내용 뿐만 아니라, basic_rv32s를 개발한 그 내용을 다룰 것이다.
basic_rv32s 레포지토리의 본 목적은 RV32I ISA기반 CPU를 설계하며 학술적인 탐구와 이해도를 높이는 데 있기도 하지만,
그 개발 기록과 디버그 로그, 그리고 각 리비전별로 바뀐 내역을 공개하여 CPU를 만들지 않은 입문자들부터 관심이 있는 모든이에게 이를 만들고 응용할 수 있는 가이드라인을 제시하는데 있다.
명확한 설계법이 있는 것은 아니지만, 그 흐름을 제시하고자 하고, 그리고 그렇게 설계한 CPU의 성능평가와 발생했던 문제점들, 그걸 해결하기 위한 내용들을 적을 것이다.
코어 다이어그램과 SoC 다이어그램. 실제 FPGA에 구현하여 UART를 통해 디버깅과 성능 측정한 사진. 다른 RISC-V RV32I 기반 프로세서들과 성능을 정량적으로 비교한 표.
LUT랑 뭐 그런게 얼마나 사용되었고, 전력은 얼마나 소비하는지.. 이 성능이 x86 CPU
RISC-V에 대한 이론적 배경과 본 설계에서는 어떻게 접목하였고, 기반이 된 헤네시 설계 기법에서 달라진 모듈들과 기능들이 뭔지.
CPU 코어를 구성하는 각 모듈들에 대한 세부적인 로직 설명들. 향후 연구 계획, 개발 로그와 이를 코어로서 다른 곳에 사용할 수 있도록 하는 가이드라인과 개발 이력들을 GitHub에 MIT 라이센스로 제공하여
RISC-V 생태계에 기여하고 본 학문에 대한 진입 장벽을 조금이라도 낮게 만들기 위함. 사람들이 흥미를 가져서 입문할 수 있게 하도록. 나도 해볼 수 있겠다 같은.

세부적인 목차를 만들어보자. 
논문 연구의 목적과 본 논문에서 뭘 다루는지에 대한 한눈 파악 초록 (ABSTRACT)
- 연구에서 제시하는 것 : 
헤네시 설계 법에 따라 설계한 베이스 CPU 모델 RV32I37F, 37F 아키텍처와 이를 기반하여 명령어 지원 수를 늘린 43F아키텍처, 46F 아키텍처 소개.
그리고 46F 아키텍처의 5단계 파이프라이닝과 이를 FPGA로 검증한 것. (사용한 보드 Digilent社 Nexys Video Artix-7 FPGA; XC7A200T-1SBG484C Xilinx Artix-7 칩 기반)
그리고 검증하면서 만든 46F5SP_SoC 의 설계와 이를 통해 측정한 RV32I46F_5SP CPU 코어의 성능, 타 RV32I 프로세서와 실제 데스크탑용 CPU와의 벤치마크 성능 비교
해당 CPU 코어들과 SoC를 만들면서 적용한 설계법들과 모듈들의 구성 설명.
진행하며 당면했던 문제들과 그를 해결한 방법. 
디버깅을 위해 고안한 방안과 그 구현 방법들. (직접 만든 테스트 시나리오 기반 명령어 하나씩 결과를 UART로 받아볼 수 있는 디버그 인터페이스, Dhrystone을 위한 벤치마크 실행 인터페이스)
본 연구에 대해 개발기록과 소스코드를 포함한 모든 내용을 Github에 MIT라이센스로 배포하였고 RISC-V 생태계 기여했다는 것.

- 연구 목적 : CPU설계에 대한 학술적 탐구, RISC-V 생태계 기여, 
CPU 설계에 대한 기초 수준(싱글사이클 RV32I 헤네시 설계법 기반)으로부터 해저드 처리 및 분기예측, 예외처리기가 포함된 5단계 파이프라인 수퍼스칼라 프로세서 설계까지의 체계화된 설계 가이드라인 제공.

위 가이드라인은 개발 로그와 각 아키텍처의 명확한 구분, 그리고 각 아키텍처별 '신호 단위'수준의 세세한 블럭 다이어그램 설계도와 각 모듈별 로직의 설명이 포함됨.
주석이 없는 clean code와 주석처리된 가이드 코드 두개 다 제공.
Github의 특성을 이용해서 자유로운 issue 처리와 관심이 있는 모든 사람들과 소통하며 본 구조를 더 개선시킬 여지 도모.
그리고 논문으로서 본 연구에 대한 이론적인 내용과 목적을 기록하여 알리고, 남겨 마이크로아키텍처 설계에 있어 도움이 되기 위함.

초록에서 위 내용을 언급하도록 잘 조율해보면 된다.

본문..

RISC-V의 기초 설명
(유래, 특성, 이론적 배경, 우리가 여기서 뭘 썼는지)
본문
아키텍처 만든 것들 뭐 있는지
37F 아키텍처 다이어그램 (RV32I37F)
각 모듈별 설명과 설계법 소개
43F 아키텍처 다이어그램 (RV32I43F)
추가된 모듈과 해당 의도, 설계법
46F 아키텍처 다이어그램 (RV32I46F)
추가된 모듈과 해당 의도, 설계법
46F5SP 아키텍처 다이어그램 (RV32I46F_5SP)

46F5SP의 FPGA 구현 내용
- 아키텍처의 실제 물성 합성을 위한 변경 내용 
(Combinatorial Loop 해결, 동기식 CSR 및 Exception Detector, 그리고 그 것 때문에 로직이 어떻게 달라지는지, 어떻게 구현했는지 등등.)
- 합성 툴 Vivado 2024.2, Synthesis, Implementation 전략 flatten hierarchy rebuilt, Flow PerfOptimized_high, Performance_Explore 합성 및 구현.

46F5SP_SoC의 FPGA 구현 내용
- UART TX 기반 버튼, LED를 이용한 초경량 디버그 인터페이스
- Dhrystone을 Instruction Memory에 담는 과정, 컴파일 툴체인 RISC-V GNU GCC march rv32i, ilp32. -o2, 반복횟수 1000회.
- Dhrystone 담으면서 생긴 문제들과 그걸 해결한 방안. (아키텍처 특성상 메모리 매핑이 메모리 모듈별로 독립적이지 않음. )
(원래 의도는 Instruction Memory에 수행할 명령어들이 모두 담겨져 있고, Data Memory를 접근 할 때 알아서 되는 것이었는데, 프로그램에서는 ROM과 RAM의 영역이 나누어져 있고 그 주소에 대한 매핑이 추가로 필요했음.)
(Instruction Memory에서 순차적으로 실행되는 것을 기대하고 만든 설계지만, 프로그램 수행 중 ROM을 접근하여 load하는 것도 있다는 것을 알게됨.) 
(Data Memory에서 Instruction Memory의 내용을 bypassing 해주는 로직을 추가하므로서 해결함.)
- 나온 성능 1.09DMIPS/MHz. (RV32I46F_5SP @ 50MHz) 

사용된 FPGA 리소스 LUT들, 예상 소비 전력 리포트, Device 면적 사진.
도출된 46F5SP 아키텍처의 성능과 타 RV32I 기반 프로세서들, 실제 데스크탑용 프로세서와의 비교.
현재 아키텍처의 한계: 
- CSR RAW Hazard 
- Short CSR_WE Hazard
- MISALIGNED LOAD, STORE를 분리해서 처리하지 않고 하나의 Exception으로 취급하였다는 점.
- Exception Detector가 동기식으로 바뀌면서 원래대로면 EX단계에서 store할 대상지가 misaligned인지 판단하고 exception해서 해당 메모리 주소에 쓰기가 되지 않아야하는데 
  MEM단계에서 exception이 처리되기 시작하면서 쓰기와 동시에 TH가 진행이 됨. 
- 분기예측기가 단순 2-bit FSM기반. 
- 캐시가 없음. 
- Exception, Trap Handler는 있지만 아직 Interrupt를 처리하지 못함. 
타이밍 개선의 여지가 있음. Critical Path를 조사해서 단축시킬 아키텍처적인 개선이 이뤄질 여지 충분.
클럭도 더 높이 나아갈 여지가 있음. 

향후 연구 계획:
위에 언급된 RV32I 표준 지원을 위한 이슈를 해결
(CSR RAW Hazard, Short CSR_WE Hazard, RISC-V Privileged Architecture Manual을 기반으로 한 Exception, Trap 처리)
FPGA로 오면서 생긴 구조적 문제 해결
분기예측기 성능 개선
설계안에는 포함되었지만, 구현하지 못한 캐시와 통합 메모리 구조의 구현
RISC-V Linux Kernel 구동을 위한 아키텍처의 전반적인 확장. (RV64IMAFDC; RV64G)
IDEC MPW 프로그램을 통한 프로세서 실제 프로토타입 생산 후 검증
듀얼 코어 구조와 외부장치 Interrupt 구현을 통해 RV32I 명령어 완전지원 아키텍처 제시(50F 아키텍처 제시; FENCE류 명령어의 지원 추가)

제일 먼저 이슈 해결부터 할 듯.

참고 문헌 : 
- 메모리 효율성을 높이기 위한 압축 명령어를 지원하는 32-비트 파이프라인 RISC-V프로세서 설계 및 구현

- RISC-V 아키텍처 기반 6단계 파이프라인 RV32I프로세서의 설계 및 구현

- FPGA를 이용한 32-bit RISC-V 5단계 파이프라인 프로세서 설계 및 구현

- 임베디드 환경에서의32-bit RISC-V RV32IM 파이프라인 프로세서 설계 및 구현

- Dynamic Branch Prediction 기반의 32-Bit RISC-V RV32IM 프로세서 설계 및 구현

- VexRiscv - SpinalHDL RV32G Processor

- An Analysis of Correlation and Predictability: What Makes Two-Level Branch Predictors Work

- Towards Developing High Performance RISC-V Processors Using Agile Methodology

- Scott McFarling, “Combining Branch Predictors,”
McFarling, Scott. Combining branch predictors. Vol. 49. Technical Report TN-36, Digital Western Research Laboratory, 1993.

00
FPGA를 이용한 32-bit RISC-V RV32I 기반 최적화된 캐시 구조 설계 및 분석 연구

Dynamic Branch Prediction 기반의 32-Bit RISC-V RV32IM 프로세서 설계 및 구현

RISC-V 아키텍처 기반 6단계 파이프라인 RV32I프로세서의 설계 및 구현

고성능 임베디드 디바이스를 위한 RV32IMC명령어 확장을 지원하는 RISC-V 파이프라인 프로세서 설계 및 구현

메모리 효율성을 높이기 위한 압축 명령어를 지원하는 32-비트 파이프라인 RISC-V프로세서 설계 및 구현

RISC-V RV32I 파이프라인 프로세서 및 주변장치 FPGA 검증

임베디드 환경에서의 32-bit RISC-V RV32IM 파이프라인 프로세서 설계 및 구현

FPGA를 이용한 32-bit RISC-V 5단계 파이프라인 프로세서 설계 및 구현


RISC-V32I칩 구현 및 RV-32IM설계

16-비트 압축 명령과 32-비트 정수 명령을 지원하는 RISC-V 마이크로프로세서의 하드웨어 설계

FPGA 합성을 통한 RISC-V R-타입 ISA 동작 검증 및 리소스 분석

FPGA를 이용한 32-bit RISC-V 프로세서 설계 및 평가

RISC-V multicore performance enhancing architecture based on temporary caching

비순차실행을 지원하는 고성능 RISC-V CPU 코어를 위한 검증 플랫폼

RISC-V 프로세서의 모의실행 및 합성

이정도. 햐... 논문의 시간이다... ㅋㅋㅋㅋ 그토록 바라왔던..

오늘은 여기까지. 
내일은 블럭 다이어그램 완성을 하고, 논문의 초록을 적는 것 부터 시작해봐야겠다.!!
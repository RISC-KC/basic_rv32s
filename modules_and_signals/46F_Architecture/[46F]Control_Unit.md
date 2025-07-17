# Control Unit (CU)
Based on 43F Architecture

[입력신호]
opcode      (from Instruction Decoder)
funct3      (from Instruction Decoder)
B_Taken     (from Branch Logic)
Trapped     (from Exception Detector)
Trap_Done   (from Trap Controller)
[출력신호]
PCC_op      (to PC Controller)
Branch      (to Branch Logic)
ALUsrcA     (to ALUsrcA_MUX)
ALUsrcB     (to ALUsrcB_MUX)
RegWDsrc    (to RegWDsrc_MUX)
MemRead     (to BE Logic)
MemWrite    (to Data Memory, BE Logic)
RegWrite    (to Register File)
CSR_Write   (to CSR_Write_Enable_OR)

[Logics]
opcode를 분석하여 J-Type 명령어이거나 jalr 명령어 즉 무조건 분기 명령어일 경우 ~~Jump 신호~~ PCCop 신호를 PCC에 보내어 다음 주소를 판단해 J_Target을 NextPC로 선택하도록 한다. 
opcode를 분석하여 B-Type 명령어 즉 조건 분기 명령어일 경우 Branch 신호를 Branch Logic 모듈에 보내어 분기 조건 충족 판단을 활성화한다. 
(Branch Logic에서는 funct3와 ALUzero값을 기반으로 분기 조건이 충족되었는지 아닌지를 판단한다. 
B_Taken 신호를 입력받아 PCC_op 신호로 인코딩하여 PCC에게 출력한다. PCC에서 다음 주소를 판단해 PCC에 입력중인 B_Target 주소 신호를 NextPC로 선택하도록 한다.)

opcode와 funct3를 분석해 명령어의 유형에 따라 레지스터 R[rd]에 쓰여져야할 데이터의 source를 선택한다. 

[RegWDsrc MUX 제어 신호 비트 사상 (RegWDsrc MUX Control signal bit mapping)]
000 = D_RD (Data Memory; DM_RD)
001 = ALUresult (ALU)
010 = CSR_RD
011 = imm
100 = PC+4

opcode와 funct3를 분석해 명령어의 유형에 따라 ALU에서 계산해야할 두 가지 연산자의 source를 판단하여 각 ALU source 선택을 담당하는 MUX를 제어한다.
R-Type, B-Type은 ALUsrcA를 0, RD1으로 선택하고 ALUsrcB를 0, RD2로 선택해서 해당 값들을 연산하도록 한다.
I-Type은 ALUsrcA를 00, RD1으로 선택하고 ALUsrcB를 01(imm)이나 10(shamt(imm[4:0]))으로 선택하여 해당 값들을 연산하도록 한다.

opcode를 분석하여 S-Type 명령어일 때 MemWrite 신호를 활성화하여 BE_Logic이 이에 맞게 처리하고 데이터 메모리(Data Memory)의 쓰기를 활성화 해 저장할 수 있도록 한다. 
opcode와 funct3를 분석해 분석하여 I-Type 명령어 중 Load 명령어일 때 MemRead 신호를 활성화하여 BE_Logic에서 이에 맞게 마스킹 처리하여 데이터 메모리로 입력(BE_Logic; ByteMask)한다. 
opcode와 funct3를 분석해 R[rd]에 쓰기가 요구되는 명령어일 경우 (사실상 대부분의 명령어들. R, I, U, J-Type 명령어) RegWrite 신호를 활성화하여 레지스터에서 쓰기를 해 적재할 수 있도록 한다. 

opcode와 funct3를 분석해 CSR명령어임을 식별하고 CSRwrite 신호를 CSR_File 모듈로 출력하여 쓰기를 활성화한다.
CSR은 기본적으로 읽기와 쓰기가 동시에 수행되므로 CSR명령어임을 식별하면 무조건 CSRwrite를 활성화한다. 

+ PCCop로 기존 Jump, B_Taken, Trapped신호가 통합되었다. 이를 인코딩하여 PCC에게 보내준다. (PCC의 next_pc 출력을 위한 제어신호 race condition을 방지하기 위해 고안되었다. devlog 참조.)
Trap Done은 항시 1이며, 0으로 떨어지면 PCCop를 pc_stall로 인코딩하여 PCC에 출력해 next_pc = pc로 하여 pc의 갱신을 멈춘다.
이는 곧 PTH가 수행중임을 뜻하며(Pre-Trap Handling; Trap Controller) 1로 올라가면 다시 로직을 수행하도록 한다. 

[Note]
opcode와 funct3 신호를 입력받아 해당 인코딩에 대응하여 해당되는 모듈들에 제어 신호를 보낸다.
ALUsrcA     = ALU source A selection
ALUsrcB     = ALU source B selection
RegWDsrc    = Register file Write Data source
MemRead     = Memory Read activated
MemWrite    = Memory Write enable
RegWrite    = Register file Write enable
+ CSRwrite    = CSR Write enable
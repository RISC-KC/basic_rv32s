# Control Unit (CU)

[입력신호]
opcode  (from Instruction Decoder)
funct3  (from Instruction Decoder)

[출력신호]
Jump        (to PCC)
Branch      (to Branch Logic)
ALUsrcA     (to ALUsrcA_MUX)
ALUsrcB     (to ALUsrcB_MUX)
RegWDsrc    (to RegWDsrc_MUX)
MemRead     (to BE_Logic)
MemWrite    (to BE_Logic, Data Memory)
RegWrite    (to Register File)

[Logics]
opcode를 분석하여 J-Type 명령어이거나 jalr 명령어 즉 무조건 분기 명령어일 경우 Jump 신호를 PCC에 보내어 다음 주소를 판단해 J_Target을 U_NextPC로 선택하도록 한다. 
opcode를 분석하여 B-Type 명령어 즉 조건 분기 명령어일 경우 Branch 신호를 Branch Logic 모듈에 보내어 분기 조건 충족 판단을 활성화한다. 
(Branch Logic에서는 funct3와 ALUzero값을 기반으로 분기 조건이 충족되었는지 아닌지를 판단한다. 
B_Taken 신호를 PCC에 출력해 PCC에서 다음 주소를 판단해 PCC에 입력중인 PC값과 imm값을 덧셈하고 해당 결과값을 U_NextPC로 선택하도록 한다. )

opcode와 funct3를 분석해 명령어의 유형에 따라 레지스터 R[rd]에 쓰여져야할 데이터의 source를 선택한다. 
000 = D_RD (Data Memory; DM_RD)
001 = ALUresult (ALU)
010 = reserved for Zicsr extension
011 = imm
100 = PC+4

opcode와 funct3를 분석해 명령어의 유형에 따라 ALU에서 계산해야할 두 가지 연산자의 source를 판단하여 각 ALU source 선택을 담당하는 MUX를 제어한다.
R-Type, B-Type은 ALUsrcA를 0, RD1으로 선택하고 ALUsrcB를 0, RD2로 선택해서 해당 값들을 연산하도록 한다.
I-Type은 ALUsrcA를 00, RD1으로 선택하고 ALUsrcB를 01(imm)이나 10(shamt(imm[4:0]))으로 선택하여 해당 값들을 연산하도록 한다.

opcode를 분석하여 S-Type 명령어일 때 MemWrite 신호를 활성화하여 BE_Logic이 이에 맞게 처리하고 데이터 메모리(Data Memory)의 쓰기를 활성화 해 저장할 수 있도록 한다. 
opcode와 funct3를 분석해 분석하여 I-Type 명령어 중 Load 명령어일 때 MemRead 신호를 활성화하여 BE_Logic에서 이에 맞게 마스킹 처리하여 데이터 메모리로 입력(BE_Logic; ByteMask)한다. 
opcode와 funct3를 분석해 R[rd]에 쓰기가 요구되는 명령어일 경우 (사실상 대부분의 명령어들. R, I, U, J-Type 명령어) RegWrite 신호를 활성화하여 레지스터에서 쓰기를 해 적재할 수 있도록 한다. 

[Note]
opcode 신호를 입력받아 그에 해당하는 모듈들에 제어 신호를 보내는 모듈이다.
ALUsrcA     = ALU source A
ALUsrcB     = ALU source B
RegWDsrc    = Register file Write Data source
MemRead     = Memory Read activated
MemWrite    = Memory Write enable
RegWrite    = Register file Write enable
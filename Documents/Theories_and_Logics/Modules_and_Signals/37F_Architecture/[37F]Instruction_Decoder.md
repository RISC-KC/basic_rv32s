# Instruction Decoder (ID)

[입력신호]
I_RD    (IM_RD; from Instruction Memory)

[출력신호]
opcode  (to imm_gen, ALUcontroller, Control Unit)
funct3  (to Control Unit, ALUcontroller, Branch Logic, BE_Logic)
funct7  (to ALUcontroller)
rs1     (to Register File - RA1)
rs2     (to Register File - RA2)
rd      (to Register File - RF_WA)
raw_imm (to imm_gen, ALUcontroller)

[Logics]
I_RD로 입력받은 32-bit 길이의 명령어를 RISC-V ISA Manual에 명시된 정의에 따라 비트 슬라이싱(bit-slicing)하여 필요로하는 각 모듈들에 출력한다.
opcode를 기반하여 무슨 타입의 명령어인지 식별하고, 그에 맞게 처리하여 해당하는 모듈들에 데이터 신호를 출력한다.

S-Type, B-Type, J-Type는 I-Type, U-Type과는 다르게 명령어에 인코딩된 imm값의 범위가 나누어져있다. 
(i.e. I-Type, imm = I_RD[31:20](imm[11:0]) 
B-Type, imm = I_RD[31:25, 11:7](imm[12], [10:5], [4:1], [11]))
이렇게 쪼개어 인코딩된 명령어의 imm값을 ISA에 명시된 비트체계에 맞게 상수값을 디코딩하여 raw_imm값으로 출력한다.
opcode  =   I_RD[6:0]
rd      =   I_RD[11:7]
funct3  =   I_RD[14:12]
rs1     =   I_RD[19:15]
rs2     =   I_RD[24:20]
funct7  =   I_RD[31:25]
raw_imm =   Depends on instruction type
            I-Type : I_RD[31:20]                (12-bit)
            U-Type : I_RD[31:12]                (20-bit)
            S-Type : I_RD[7:11, 25:31]          (12-bit)
            B-Type : I_RD[8:11, 25:30, 7, 31]   (12-bit)
            J-Type : I_RD[21:30, 20, 12:19, 31] (20-bit)

[Note]
slli, srli, srai같은 bit shift 명령어들은 ISA에서 31:20에 해당하는 imm영역 중 24:20을 shamt(shift amount)로 정의한다.
이 경우, shamt가 rs2에 해당하는 비트영역이지만 설계 직관성을 위해 rs2로 출력하지는 않는다. 
raw_imm으로 imm_gen에 출력, 확장되어 ALUsrcB에서 비트 슬라이싱(bit-slicing)하여 shamt로 사용된다.

추가적으로, raw_imm은 ALUcontroller에게도 가는데, I-Type 비트 쉬프트 (bit shift)연산 때문에 그렇다
비트 쉬프트의 명령어 식별자는 opcode, funct3, I_RD[31:20]인데
I_RD[31:25]는 R-Type의 funct7처럼 존재하는데, [30]번째 비트가 right shift type으로 인코딩 되어있다.
"_The right shift type is encoded in bit 30._"
-The RISC-V Instruction Set Maual Volume I: Unprivileged Architecture Version 20240411, 2.4.1. Integer Register-Immediate Instructions Page 26.
그리고 I_RD[24:20]은 shamt, shift amount 즉 쉬프팅 할 크기를 인코딩 해두었다. 
사실 우리와 같은 아키텍처에서는 raw_imm을 ALUcontroller에 줄게 아니라 funct7 신호로서 ALUcon에 입력을 해도 좋을 것 같다. 
어차피 I_RD를 bit-slicing해서 주는 것일 뿐이거니와 추가적인 신호를 중복되는 판단 식별 신호로서 입력하는 것은 비효율적이다. 
하지만, 명령어에서는 I_RD[31:25]가 0 1 0 0 0 0 0 인 imm값일 뿐 funct7이라고는 명시하지 않았고
매뉴얼을 최대한 반영하며 설계하는 것이 목표이니 설계 직관성을 위해서 raw_imm이라는 추가적인 신호를 배치하였다. 
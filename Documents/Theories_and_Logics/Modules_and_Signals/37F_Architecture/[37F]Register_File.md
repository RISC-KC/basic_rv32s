# Register File (Reg, RegF)

[입력신호]
CLK
RegWrite    (from Control Unit)
RA1         (from Instruction Decoder; rs1)
RA2         (from Instruction Decoder; rs2)
RF_WA       (from Instruction Decoder; rd )
RF_WD       (from RegWDsrc_MUX. Data Memory - D_RD, ALU - ALUresult, imm_gen, PC+4)

[출력신호]
RD1         (to ALUsrcA_MUX)
RD2         (to ALUsrcB_MUX, BE_Logic)

[Logics]
CLK 클럭 신호에 따라 제어 신호를 인식하고 입출력한다. 
레지스터의 쓰기는 RegWrite 신호로 Control Unit으로 부터 제어된다.
쓰기 시 수행할 주솟값을 RF_WA신호로 받고, 쓰여질 데이터 신호로 입력된 RF_WD를 해당 RF_WA로 지정된 주소의 레지스터에 쓴다.
읽기는 별도의 제어 신호 없이 주소 RA1(rs1), RA2(rs2)로 입력 받는 즉시 수행된다.
RA1, RA2로 각각 rs1, rs2에 해당하는 주솟값들을 받아 그 주솟값에 해당하는 레지스터에 쓰여져있는 데이터 값을 각각 RD1, RD2로 출력한다.

[Note]
레지스터들로 이루어진 집합. RISC-V의 약속에 따른 레지스터 가이드라인이 있다.
x0~x31까지 어떤 레지스터들로 이뤄져야하는지에 대한 내용. 꼭 참조할 것.

RegWrite    = Register Write enable
RA1 (rs1)   = Read Address 1
RA2 (rs2)   = Read Address 2
RF_WA (rd)  = Register File Write Address
RF_WD       = Register File Write Data
RD1         = Read Data 1
RD2         = Read Data 2
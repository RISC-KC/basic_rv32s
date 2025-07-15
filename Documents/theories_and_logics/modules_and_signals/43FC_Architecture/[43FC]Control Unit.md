# Control Unit (CU)
Basically same as 43F Architecture.

[입력신호]
...
+ Data_Ready

[출력신호]
...
+ PC_Stall

[Logics]
...

opcode와 funct3를 분석해 CSR명령어임을 식별하고 CSRwrite 신호를 CSR_File 모듈로 출력하여 쓰기를 활성화한다.
CSR은 기본적으로 읽기와 쓰기가 동시에 수행되므로 CSR명령어임을 식별하면 무조건 CSRwrite를 활성화한다. 
...

+ 입력받는 Data_Ready 신호(DM)가 준비되지 않았을 경우, PC_Stall을 High로 PCC에 출력한다. PCC에서는 PC_Stall이 High일 때 U_NextPC를 기존의 PC값 그대로를 출력하여 현재 명령어가 갱신되지 않고 계속 수행되도록 한다. 

[Note]
opcode와 funct3 신호를 입력받아 해당 인코딩에 대응하여 해당되는 모듈들에 제어 신호를 보낸다.

+ PC_Stall  = Program Counter update Stall
ALUsrcA     = ALU source A selection
ALUsrcB     = ALU source B selection
RegWDsrc    = Register file Write Data source
MemRead     = Memory Read activated
MemWrite    = Memory Write enable
RegWrite    = Register file Write enable
CSRwrite    = CSR Write enable
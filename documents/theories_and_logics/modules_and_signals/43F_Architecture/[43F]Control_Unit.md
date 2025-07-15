# Control Unit (CU)
Basically same as 37F Architecture.

[입력신호]
...
[출력신호]
...
+ CSRwrite

[Logics]
...

opcode와 funct3를 분석해 명령어의 유형에 따라 레지스터 R[rd]에 쓰여져야할 데이터의 source를 선택한다. 

+ [RegWDsrc MUX 제어 신호 비트 사상 (RegWDsrc MUX Control signal bit mapping)]
000 = D_RD (Data Memory; DM_RD)
001 = ALUresult (ALU)
010 = CSR_RD
011 = imm
100 = PC+4
...

opcode와 funct3를 분석해 CSR명령어임을 식별하고 CSRwrite 신호를 CSR_File 모듈로 출력하여 쓰기를 활성화한다.
CSR은 기본적으로 읽기와 쓰기가 동시에 수행되므로 CSR명령어임을 식별하면 무조건 CSRwrite를 활성화한다. 

[Note]
opcode와 funct3 신호를 입력받아 해당 인코딩에 대응하여 해당되는 모듈들에 제어 신호를 보낸다.
ALUsrcA     = ALU source A selection
ALUsrcB     = ALU source B selection
RegWDsrc    = Register file Write Data source
MemRead     = Memory Read activated
MemWrite    = Memory Write enable
RegWrite    = Register file Write enable
+ CSRwrite    = CSR Write enable
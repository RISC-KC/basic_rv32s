# Control Unit (CU)
Basically same as 43FC Architecture.

[입력신호]
...
Data_Ready
+ funct7
+ Rsv_YesNo

[출력신호]
...
PC_Stall
+ Rsv_Invalid   (to Atomic Unit)
+ DC_Atomic_MUX (to DC_Atomic_MUX)

[Logics]
...
+ [RegWDsrc MUX 제어 신호 비트 사상 (RegWDsrc MUX Control signal bit mapping)]
000 = D_RD
001 = ALUresult (ALU)
010 = CSR_RD
011 = imm
100 = PC+4
+ 101 = 1
+ 110 = 0

...
입력받는 Data_Ready 신호(DM)가 준비되지 않았을 경우, PC_Stall을 High로 PCC에 출력한다. PCC에서는 PC_Stall이 High일 때 U_NextPC를 기존의 PC값 그대로를 출력하여 현재 명령어가 갱신되지 않고 계속 수행되도록 한다. 

+ Atomic Unit에서 나오는 Rsv_YesNo 신호를 통해 Reservation이 valid한지 invalid한지를 식별한다. 

+ funct7값을 통해 aq, rl 값을 확인한다.
~2025.04.16.~
"A"확장의 명령어들은 26:25 각 1비트마다 각각 aq, rl 비트로서 사용된다. 
aq(aquire), rl(release). 두 비트는 메모리 순서(Memory Ordering)를 제어하기 위해 사용된다. 

aq 비트 set된 명령어는 그 명령어의 완료까지 hart가 기다리고 다음 명령어들을 수행할 수 있도록 해야한다. 

rl비트 set된 명령어는 그 명령어의 수행 이전까지의 모든 메모리 접근 명령어가 완료될 때까지 hart가 기다리고, 이후에 해당 rl비트 set된 명령어를 수행할 수 있도록 해야한다. 

위 로직대로 Control Unit에서 aq, rl 비트를 보고 PC_Stall을 조건에 따라 수행할 수 있도록 한다.

[Note]
+ opcode와 funct3, funct7 신호를 입력받아 해당 인코딩에 대응하여 해당되는 모듈들에 제어 신호를 보낸다.

PC_Stall  = Program Counter update Stall
ALUsrcA     = ALU source A selection
ALUsrcB     = ALU source B selection
RegWDsrc    = Register file Write Data source
MemRead     = Memory Read activated
MemWrite    = Memory Write enable
RegWrite    = Register file Write enable
CSRwrite    = CSR Write enable
+ Rsv_Invalid   = Reservation Invalidate
+ DC_Atomic_MUX = Data Cache Atomic MUX enable
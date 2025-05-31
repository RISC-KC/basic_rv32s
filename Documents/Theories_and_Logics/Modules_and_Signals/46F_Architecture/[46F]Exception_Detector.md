# Exception Detector (ED)

[입력신호]
funct12(raw_imm)    (from Instruction Decoder)
opcode              (from Instruction Decoder)
funct3              (from Instruction Decoder)
J_Target(ALUresult) (from ALU)
B_Target            (from Branch Logic)

[출력신호]
Trapped     (to Control Unit, CSR_Addr_MUX, CSR_WD_MUX)
Trap_Status (to Trap Controller)

[Logics]
raw_imm과 opcode, funct3 값을 입력받아 SYSTEM 명령어 혹은 Exception, Trap 명령어인지를 확인한다. 
만약 해당될 경우, Trapped 신호를 High로 출력하여 Trap 또는 Exception이 발생하였음을 알린다.
그와 데이터패스를 변경하고 (MUX 제어, CSR_Addr, WD_MUX) 어떤 유형의 Trap/Exception인지를 인코딩하여 Trap Controller로 정보를 보내 서브루틴이나 상황에 맞는 동작 수행을 할 수 있도록 한다. 

각 인코딩은 trap.vh 헤더파일에 명시되어있으며,
TRAP NONE, ECALL, EBREAK, MISALIGNED, MRET, FENCE.I으로 구성되어있다.

~~NextPC는 입력되는 주솟값이 Misaligned 된 주솟값인지를 항상 확인하며 만약 misaligned라면 misaligned exception을 발생시켜 그에 대응되는 Trap Handler를 Trap Controller에서 작동하도록 한다.~~
기존에는 위와 같이 NextPC를 탐지하고 고치는 것으로 설계했으나, NextPC가 적재되는 Program Counter 레지스터는 posedge clk에서만 작동한다.
때문에 NextPC값을 담기 이전에 로직을 처리해야한다는 것을 구현하며 알아냈다.
고로, misalign이 일어날 수 있는 분기 주솟값들을 Exception Detector에 직접 연결하였고, 
그를 위해 기존 PCC에서 내부적으로 계산되어 NextPC로 출력되던 (PC+imm 수행) B_Target(branch_target)을 Branch Logic에 편성해 계산된 B_Target을 그대로 ED가 판단할 수 있도록 했다.

[Note]
현재 구조는 EEI라던가, User level, Supervisor level 같은 Privilege mode가 명확히 구현되지 않은 Machine level (거의 bare-metal) EEI이다. 
ECALL, EBREAK 같은 환경 호출 명령어들은 디버거 호출로 가정하여 이를 수행하도록 했다. 
추후 OS 이식 때 더 깊은 모듈 수정 예정. 

┏실제 코드 내 변수 명┓
J_Target = jump_target_lsbs
B_Target = branch_target_lsbs
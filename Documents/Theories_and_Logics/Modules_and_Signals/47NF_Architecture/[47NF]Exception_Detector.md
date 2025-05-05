# Exception Detector (ED)

[입력신호]
raw_imm     (from Instruction Decoder)
opcode      (from Instruction Decoder)
funct3      (from Instruction Decoder)
NextPC      (from PCC)

[출력신호]
Trapped     (to PCC, CSR_Addr_MUX, CSR_WD_MUX)
Trap_Status (to Trap Controller)

[Logics]
raw_imm과 opcode, funct3 값을 입력받아 SYSTEM 명령어 혹은 Exception, Trap 명령어인지를 확인한다. 
만약 해당될 경우, Trapped 신호를 High로 출력하여 Trap 또는 Exception이 발생하였음을 알린다.
그와 데이터패스를 변경하고 (MUX 제어, CSR_Addr, WD_MUX) 어떤 유형의 Trap/Exception인지를 인코딩하여 Trap Controller로 정보를 보내 서브루틴이나 상황에 맞는 동작 수행을 할 수 있도록 한다. 

NextPC는 입력되는 주솟값이 Misaligned 된 주솟값인지를 항상 확인하며 만약 misaligned라면 misaligned exception을 발생시켜 그에 대응되는 Trap Handler를 Trap Controller에서 작동하도록 한다.

[Note]
현재 구조는 EEI라던가, User level, Supervisor level 같은 Privilege mode가 명확히 구현되지 않은 Machine level (거의 bare-metal) EEI이다. 
ECALL, EBREAK 같은 환경 호출 명령어들은 디버거 호출로 가정하여 이를 수행하도록 했다. 
추후 OS 이식 때 더 깊은 모듈 수정 예정. 
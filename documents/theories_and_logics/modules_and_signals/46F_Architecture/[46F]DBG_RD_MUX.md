# Debug Read Data Multiplexer (DBG_RD_MUX)

[입력신호]
Dbg.Mode    (from Trap Controller)
IM_RD       (from Instruction Memory)
DBG.instr   (from Debug Interface)

[출력신호]
I_RD        (to Instruction Decoder)

[Logics]
Exception Detector에서 Trap을 감지하고 Trap_Status 신호를 통해 Trap_controller에게 알린다. Trap Controller가 Trap_Status를 확인하고, 이 때 디버거 환경 요청 ECALL같은 명령어일 경우 DBG.instr을 출력하도록 한다. 아니라면 IA_RD로 정상적인 프로그램 수행을 하도록 MUX가 제어된다.

[Note]
┏실제 코드 내 변수 명┓
I_RD = instruction
IM_RD = im_instruction
Dbg.Mode = debug_mode
DBG.instr = dbg_instruction
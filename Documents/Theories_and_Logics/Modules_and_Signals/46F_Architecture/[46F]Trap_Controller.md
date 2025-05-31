# Trap Controller (TC)

[입력신호]
Trap_Status     (from Exception Detector)
PC              (from PC)
CSR_RD          (from CSR File)
CLK
RST

[출력신호]
T_Target    (to PCC)
Trap_Done   (to Control Unit)
Dbg.Mode    (to DBG_RD_MUX)
CSR_WE      (to CSR File - CSR_Write_Enable_OR)
CSR_T.Addr  (to CSR_Addr_MUX)
CSR_T.WD    (to CSR_WD_MUX)

[Logics]
Exception Detector로부터 인코딩된 Trap/Exception 에 대한 정보를 데이터 코드로 받아 그에 맞는 동작을 수행한다. 
Trap/Exception 발생시 CSR File을 조회, 읽기와 쓰기를 진행한다. 

예를 들어, Trap Handling을 위한 각 예외상황별 Trap Handler 시작 주소가 담긴 레지스터는 CSR File의 mtvec이다. 이 mtvec에 접근하기 위한 주솟값으로 CSR_T.Addr을 내보낸다.
그리고 그에 대한 정보가 CSR_RD로 들어오고, 해당 주소를 T_Target으로 PCC에 출력하여 Trap Handler 서브 루틴을 수행하도록 한다. 
PC값을 입력받아 서브루틴을 수행하는 당시에 기존 프로그램에 있던 PC값을 mepc CSR에 저장할 수 있도록 가지고 있어야 한다. 이는 CSR_T.WD 신호로 CSR File에 출력되어 mepc에 쓰여진다. 

즉, Trap Handler 서브루틴으로의 분기 또는 해당 Trap에 대한 내부적인 처리를 하기위해 수행해야하는 Trap Controller 자체의 전초작업이 있다.
이를 Pre-Trap Handling (PTH) 이라 칭한다.
한 클럭 사이클에 수행할 수 있는 자원이 한정적이기에 내부 FSM으로 구현하였으며 총 4가지의 단계를 가지고 있다.

IDLE, WRITE_MEPC, WRITE_MCAUSE, READ_MTVEC.
평시는 IDLE 상태로 있다가, trap이 발생하면 mepc에 값을 쓰고 WRITE MEPC 상태로 넘어간다.
WRITE_MEPC 상태에서는 mcause CSR에 현재 발생한 Trap의 내용을 쓰고 WRITE_MCAUSE상태로 넘어간다.
WRITE_MCAUSE 상태에서는 mtvec CSR을 읽어 해당 Trap Handler 루틴의 시작 주소로 분기하고, READ_MTVEC 상태로 넘어간다.
READ_MTVEC에서는 신호를 유지하고, 다시 IDLE상태로 되돌아간다.
NONE, MRET, FENCEI는 한 사이클에 trap handler 분기 없이 Trap Controller 내부적으로 처리가 가능하기에 별도의 상태 갱신은 없다. IDLE상태이다.
ECALL, EBREAK, MISALIGNED는 PTH FSM을 갱신시키며 처리된다. EBREAK는 debug mode를 활성화하며, ECALL과 MISALIGNED는 Trap Handler로 분기한다.
Trap Handler는 Instruction Memory에 있으며 csr 명령어 읽기와 비교 분기 명령어를 통해 적합한 처리문의 시작 주소로 분기하여 처리하고 
mret 명령어의 주소로 분기하여 다시 원래의 프로세스 흐름으로 돌아가게끔 했다.

[Note]
컴퓨터 구조론에 따라, 사실 어찌보면 당연하게, Trap Handler가 수행되며 GPR(General Purpose Register)들이 사용된다.
Trap 당시의 PC값은 CSR의 mepc에 저장된다고 해도, 현재 실행중이었던 프로그램의 문맥 정보 즉, 레지스터 정보들을 어딘가에 저장해둘 필요가 있다.
보통 이걸 메모리의 어느 구역에 저장하는데, 이를 구조적으로 구현하진 않았고, Trap Handler에서 제한적인 레지스터들을 사용하도록 했다. 
추후 OS 이식시 해결해야할 과제이기도 하다.

로드라인 작업 중 캐시 구조를 접목하며 Zifencei를 위해 해당 로직은 이미 구현이 되어있다. 
하지만 현재 46F구성에선 캐시구조가 구현되어있지 않아 사용되지 않지만 구현은 되어있는 신호로 참고하길 바란다.

┏실제 코드 내 변수 명┓
CSR_RD = csr_read_data
T_Target = trap_target
Dbg.Mode = debug_mode
CSR_WE = csr_write_enable
CSR_T.Addr = csr_trap_address
CSR_T.WD = csr_trap_write_data
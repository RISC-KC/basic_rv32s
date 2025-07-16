# Trap Controller (TC)

[입력신호]
Trap_Status     (from Exception Detector)
PC              (from PC)
CSR_RD          (from CSR File)
CLK
RST

[출력신호]
T_Target    (to PCC)
IC_Clean    (to Instruction Cache)
Dbg.Mode    (to DBG_RD_MUX)
CSR_T.Addr  (to CSR_Addr_MUX)
CSR_T.WD    (to CSR_WD_MUX)

[Logics]
Exception Detector로부터 인코딩된 Trap/Exception 에 대한 정보를 데이터 코드로 받아 그에 맞는 동작을 수행한다. 
Trap/Exception 발생시 CSR File을 조회, 읽기와 쓰기를 진행한다. 
예를 들어, Trap Handling을 위한 각 예외상황별 Trap Handler 시작 주소가 담긴 레지스터는 CSR File의 mtvec이다. 이 mtvec에 접근하기 위한 주솟값으로 CSR_T.Addr을 내보낸다.
그리고 그에 대한 정보가 CSR_RD로 들어오고, 해당 주소를 T_Target으로 PCC에 출력하여 Trap Handler 서브 루틴을 수행하도록 한다. 

PC값을 입력받아 서브루틴을 수행하는 당시에 기존 프로그램에 있던 PC값을 mepc CSR에 저장할 수 있도록 가지고 있어야 한다. 이는 CSR_T.WD 신호로 CSR File에 출력되어 mepc에 쓰여진다. 

[Note]
# Control and Status Register File (CSR_File; CSRFile; CSRF)

[입력신호]
CLK
RST
CSRwrtie    (from Control Unit)
CSR_Addr    (from imm_gen - raw_imm)
CSR_WD      (from ALU - ALUresult)

[출력신호]
CSR_RD      (to ALUsrcB_MUX, RegWDsrc_MUX)

[Logics]
기본적으로 한 사이클 안에 읽기와 쓰기를 동시에 수행한다. 
CSR명령어 특성상 한 주소에 대해 읽기와 쓰기를 동시에 수행하는데, 이로 인해 발생하는 race condition은 WAR 방식으로 처리한다.
WAR = Write after Read. 읽기로 먼저 값을 출력하고, 이후 입력된 값을 해당 CSR 주소에 쓰는 것이다. 
WAR방식만이 Zicsr의 현재 상태를 알려주고, 갱신한다는 취지에 적합하므로 이렇게 구현했다. 

[Note]
Zicsr 확장의 명령어들을 지원하기 위한 별도의 레지스터 파일.
Register File과 비슷하게, CSR_enable로 쓰기를 활성화하며, 비동기식으로 읽기를 수행한다.

인터럽트나 등등 시스템 연산에 주로 사용되며, 추후 OS 이식을 위해서는 Zicsr 확장이 필수적인데
이를 위해 설계된 CSR 레지스터들의 묶음이다. 

필요한 경우 임베디드 같은 환경에서는 필요한 CSR만 별도로 레지스터 낱개 구성이 가능할 것이다.  
(초기 CSR 관련 설계에서도 Interrupt 처리를 위해 mepc, mtvec 같은 필요한 CSR만 사용하려고 했었다. )
구현된 CSR의 목록은 CSR_Logics.md 문서 참조.

CLK         = CLocK
RST         = ReSeT
CSRwrite    = CSR write enable
CSR_Addr    = CSR address
CSR_WD      = CSR Write Data
CSR_RD      = CSR Read Data
# Data Memory (DM)

[입력신호]
CLK
MemWrite    (from Control Unit)
DM_WD       (from BE_Logic)
ByteMask    (from BE_Logic)
DM_Addr     (from ALU; ALUresult)

[출력신호]
DM_RD       (to BE_Logic; DM2RF_RD)

[Logics]
CLK rising edge에서 작동한다. 
CU에서 출력되는 MemWrite 신호를 통해 쓰기가 제어된다. 
DM_Addr은 주소 입력으로, 해당 주소를 읽거나 주소에 쓴다.
MemWrite가 high일 때 데이터를 쓰고, 읽기는 비동기식이다.
ByteMask를 통해 BE_Logic에서 디코딩된 마스크 값을 입력받고 해당 마스킹을 토대로 데이터를 읽거나 쓴다. 
DM_Addr의 데이터를 읽을 경우, DM_RD 출력 신호로 데이터를 출력한다.

[Note]
하버드 구조에 따라 이원화된 메모리 중 데이터를 담당하는 메모리이다. 명령어가 아닌 데이터들이 저장된다.
Memwrite 신호를 받아 쓰기를 활성화하고, MemRead는 구버전 설계에 있었지만 현재는 비동기식 읽기를 지원하는 Asynchronous Memory (비동기식 메모리) 로 구현하기로 했기에 없앴다. 
ByteMask는 BE_Logic에서 출력한 '어디에 쓰기를 해야하는지'에 대한 지점의 주소 정보 값이다. 이를 토대로 쓰기를 진행하게 된다. 
DM_Addr로 입력되는 Memory 주소는 rs값 + imm의 간접 주소 지정방식이기에 ALUresult에서 받아온다.

MemWrite    = Memory Write enable
DM_WD       = Data Memory Write Data
DM_Addr     = Data Memory input Address
DM_RD       = Data Memory Read Data
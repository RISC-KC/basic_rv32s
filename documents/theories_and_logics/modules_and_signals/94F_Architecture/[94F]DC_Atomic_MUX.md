# Data Cache Atomic enable MUX (DC_Atomic_MUX)

[입력신호]
DC_Atomic_MUX   (from Control Unit)
ALUresult       (from ALU)
DC_WD           (from DC_WD_MUX)

[출력신호]
D_WD            (to Data Cache - DC_WD(D_WD))

[Logics]
DC_Atomic_MUX 신호가 High일 때, ALUresult를 D_WD로 출력해 Atomic 명령어가 수행될 수 있도록 한다. 
Low일 때 DC_WD를 선택하여 M2C_Data가 입력되어 캐시를 갱신하게 하거나, 
BEDC_WD를 선택하여 저장(Store)명령어를 수행할 수 있도록 한다.

[Note]
D_WD로 나중에 신호들 수정해야할 것 같다.
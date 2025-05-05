# Data area Read Data Multiplexer (D_RD_MUX)

[입력신호]
DC_Status   (from Data Cache)
DC_RD       (from Data Cache)
DM_RD       (from Data Memory)

[출력신호]
D_RD        (to BE_Logic)

[Logics]
SAA를 위한 MUX. 
DC_Status 신호를 통해 Cache Miss 일 경우 데이터의 인출 source를 Data Memory로 지정하여
데이터 메모리가 출력하는 데이터 신호가 그대로 BE_Logic으로 가도록 한다. (이와 동시에 Data Cache로 가 데이터 캐시를 갱신하기도 한다.)
Cache Hit라면, DC_Status 0으로 데이터 캐시에서 인출되는 데이터를 선택해 BE_Logic으로 출력한다.

0 = DC_RD
1 = DM_RD

[Note]
SAA; Simultanious Address Access
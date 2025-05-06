# Data Cache Write Data Multiplexer (DC_WD_MUX)

[입력신호]
DC_Status   (from Data Cache)
DM_RD       (from Data Memory)
BEDC_WD     (from BE_Logic)

[출력신호]
DC_WD       (to Data Cache)

[Logics]
DC_Status 신호를 통해 Cache Miss 일 경우 Data Memory를 선택하여 SAA로 인해 데이터 메모리가 출력하는 데이터 신호가 그대로 Data Cache의 쓰기 데이터로 입력된다. (DC_WD) M2C 캐시 갱신.

Cache Hit라면, DC_Status 0으로 BE_Logic에서 출력되는 데이터(BEDC_WD)를 선택해 DC_WD로 입력시켜 쓰기 데이터로 사용한다.

0 = BEDC_WD
1 = DM_RD

[Note]
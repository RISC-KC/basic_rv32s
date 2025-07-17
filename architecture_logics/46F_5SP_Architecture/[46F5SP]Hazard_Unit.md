# Hazard Unit design

[입력신호]
ID_rs1	(from Instruction Decoder)
ID_rs2	(from Instruction Decoder)
ID_rd	(from Instruction Decoder)
branch_prediction_miss  (from Branch Logic)
EX_jump (from ID_EX_register)

[출력신호]
hazard_op       (to Forward Unit)
IF_ID_flush     (to IF_ID_register)
ID_EX_flush     (to ID_EX_register)
EX_MEM_flush    (to EX_MEM_register)
MEM_WB_flush    (to MEM_WB_register)

[Logics]
A 명령어의 rd가 B명령어의 rs1, rs2 값과 같은지 비교한다.

Instruction Decoding 단계에서 받은 rs1.A, rs2.A, rd.A 값을 저장하고, 
다음 명령어에서 주어지는 rs1.B, rs2.B, rd.B 값과 비교한다.
rd.A가 rs1.B, rs2.B 중에 하나라도 동일할 경우, 
데이터 해저드가 발생함을 포워딩 유닛에 hazardop 신호로 알린다. 

instruction fetch를 거쳐 decoding 단계에서 rd, rs1, rs2의 값을 확인할 수 있다.
즉, ID 단계의 rd, rs1, rs2를 받아와서 기록을 하고
다음 클럭 사이클에서 기존에 저장되어있던 rd값과 방금 받아온 rs1, rs2 값을 비교한다.
비교 결과 같다면, Hazard op를 Forward Unit에 출력하여 Forward Unit이 전방 전달을 처리할 수 있도록 한다.
동시에 현재 받아온 rd값을 기존의 rd값에 갱신한다.

[Note]
해저드 검출이 곧 Hazard Unit의 본래 설계 목적.
1. 데이터 해저드 (Data Hazard)
명령어의 종속성에 따라 이전 명령어가 끝날 때 까지 현재 명령어를 중단시켜야하는 경우
RAW계열. Read After Write. 쓰기 이후 읽어야 하는 경우에 해당 명령어가 모두 끝나야 메모리나 레지스터에 적히는데,
거기까지 생기는 빈 클럭들이 생기니까(그 값이 쓰이지 않은채 진행되면 프로그램의 문맥이 사라지고 의도한 결과를 낼 수 없다.)
버블을 삽입하여야한다. 하지만 버블 삽입만 해서는 성능이 많이 떨어지게 되니, 어차피 해당 선행 명령어의 결과값은 레지스터나 메모리에 WB되기 전에 나오게 되니
해당 쓰여지기 전 값을 현행 명령어의 소스값으로 전달을 해주는 것이다. 
이를 전방전달 방법이라고 하고, 이를 구현한 것이다.
-파이프라인에서 수행하는 명령어들 끼리의 종속성을 알아야한다.
과거 처리되어야할 레지스터 주솟값이 현재 수행하고자 하는 명령어가 참조하는 레지스터인지 확인해야한다.
A 명령어의 rd가 B명령어의 rs1, rs2 값과 같은지 비교.
instruction fetch를 거쳐 decoding 단계에서 rd, rs1, rs2의 값을 확인할 수 있다.
즉, ID 단계의 rd, rs1, rs2를 받아와서 기록을 하고
기존에 저장되어있던 rd값과 현재 받아온 rs1, rs2 값을 비교하여 같다면 전방 전달을 사용한다.
그리고 현재 받아온 rd값을 기존의 rd값에 갱신한다.

이렇게 데이터 해저드가 발생했는지를 알 수 있다.
이 데이터 해저드 발생 유무를 Forward Unit으로
실제 전방전달 방법을 처리하는 모듈에 알려준다.

2. 제어 해저드 (Control Hazard)
조건 분기 명령어시, 명령어의 판단 여부가 EX단계에서 결정되므로 그 동안 EX 단계 이전의 파이프라인 수행에 대한 문제.
세 가지 방법으로 접근 할 수 있다.
Stall, Taken 가정, Not Taken 가정
Stall을 하게 되면 제어 해저드에 대한 성능 손실을 대책없이 모두 끌어안게 된다.
Taken, Not Taken 가정은 결국 조건 분기문에 대한 예측을 전제한다. 
작은 임베디드의 경우 Not Taken으로 모두 전제하고 수행하다가 해당 분기 예측이 틀리게 되면 기존에 있는 파이프라인 레지스터들을 모두 Flush한다. 
이 분기에 대한 예측이 정확할 수록 성능은 당연하게도 상승하여 CPI를 1에 가깝게 만들 수 있다.
분기 예측 방법은 정적과 동적이 있다. 위에서 말한게 정적.
동적은 상황과 문맥에 맞는 예측을 하여 성능을 비교적 높인다.
이에 대한 내용은 devlog 참조. 
본 해저드 유닛은 2비트 BTB 기반 분기 예측을 구현한다.
때문에, Hazard Unit에서 EX단계에서 알 수 있는 분기 예측의 성공 유무를 받아와
분기 예측이 실패했다면 예측을 기반으로 진행된 명령어들의 값을 가지고 있는 파이프라인 레지스터들의 적재된 값들을 flush한다. (NOP처리, 꼭 모든 파이프라인을 flush할 필요는 없다.)
때문에 Hazard Unit에서 branch_prediction_miss 신호를 Branch Logic에서 받아온다.
그리고 각 파이프라인 레지스터들을 flush하는 신호 또한 포함한다. 
IF_ID_flush, ID_EX_flush, EX_MEM_flush, MEM_WB_flush 신호를 추가한다. 

무조건 분기에 대해서도 flush 작업이 있다.
분기 이후 마찬가지로, 이는 해당 버블을 보상할 방법이 없지만 jump의 주소가 결정되는 EX단계까지 수행된 IF, ID의 내용들을 flush해야한다.

즉, JUMP임을 알아야하니 EX_jump 신호를 입력신호로 추가한다.
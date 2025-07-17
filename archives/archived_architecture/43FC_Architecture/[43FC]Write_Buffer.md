# Write Buffer

[입력신호]
WB_Addr     (from Data Cache)
WB_Data     (from Data Cache)
CLK

[출력신호]
WB_Addr     (to Data Memory)
WB_Data     (to Data Memory)

[Logics]
D-Flip/Flop으로 구현되는 기본적인 레지스터.
입력된 값을 담고 있다가, 다음 클럭 갱신 때 해당 데이터를 인출하고 새로운 값을 담는다. 
(Write after Read; 읽기 이후 쓰기)

[Note]
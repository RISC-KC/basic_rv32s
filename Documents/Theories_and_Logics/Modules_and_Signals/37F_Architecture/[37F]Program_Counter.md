# Program Counter (PC)

[입력신호]
NextPC              (from PCC)
CLK; Clock signal   (클럭 신호)
rst; Reset          (초기화 신호)

[출력신호]
PC (to Instruction Memory)

[Logics]
다음 실행할 명령어의 주소인 NextPC값을 입력받는다. 
적재된 현재 실행할 명령어의 주소를 Instruction Memory로 출력하며 다음 클럭사이클까지 갖고 있는다.
다음 클럭 입력에 NextPC를 PC로 출력하고 다음 PC값을 NextPC로 입력받는다.

[Note]
D-FlipFlop 레지스터로 구현된다. 
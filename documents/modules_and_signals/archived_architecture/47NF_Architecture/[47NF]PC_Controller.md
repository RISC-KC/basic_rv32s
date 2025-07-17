# Program Counter Controller (PCC; PC Controller)
Basically same as 43FC Architecture.

[입력신호]
+ Trapped   (from Exception Detector)
PC_Stall    (from Control Unit)
Jump        (from Control Unit)
B_Taken     (from Branch Logic)
PC          (from Program Counter)
imm         (from imm_gen)
J_Target    (from ALU - ALUresult)
+ T_Target  (from Trap_Controller)

[출력신호]
+ NextPC    (to PC_Aligner)

[Logics]
PC모듈을 컨트롤한다. 
다음 PC가 가르킬 주소 신호인 NextPC를 PC_Aligner에 출력한다.

B_Taken시 입력된 PC값과 imm값을 덧셈 연산하여 NextPC를 출력한다.
Jump시 J_Target의 주솟값을 NextPC로 출력한다.
분기하지 않을 경우 PC에서 +4 한 값을 NextPC로 출력한다.

Control Unit에서 판단하기에, PC값을 아직 갱신하면 안되는 경우 (현재 명령어의 수행이 완료되지 않은 경우. 가장 빈번한 건 데이터 캐시 구조에서 캐시 갱신 등과 같은 이유로 두 사이클 이상이 소요될 때.) PC_Stall을 PCC로 출력한다. PCC에서는 PC_Stall이 High일 때 NextPC를 기존의 PC값 그대로를 출력하여 현재 명령어가 갱신되지 않고 계속 수행되도록 한다. 

+ Exception Detector에서 ECALL, EBREAK과 같은 environment 명령어를 탐지하거나 exception 요소를 발견할 경우 Trapped 신호를 PCC로 출력한다.
이 신호를 받은 PCC는, NextPC 값을 T_Target로 선택하여, Trap Handler의 시작 주솟값으로 프로그램을 진행해 서브루틴을 수행할 수 있도록 한다. 

[Note]
+ 기존 43FC Architecture 까지는 정렬되지 않은 명령어들을 PC_Aligner라는 모듈을 통해 강제 정렬하므로 PCC에서 출력하는 신호를 Unaligned Next PC로 규정했었다.
하지만 47NF에서는 exception및 trap을 발생하여 해당 처리 루틴으로 분기할 수 있게 되어 하위 2비트 강제 정렬하는 PC_Aligner를 없앴다. 
그런 연유로, U_NextPC 신호는 47NF Architecture부터는 NextPC로 바뀐다.

NextPC   = Next Program Counter value
PC_Stall = Program Counter update Stall
Jump     = Jump instruction execution
B_Taken  = Branch Taken
J_Target = Jump Target address
T_Target = Trap handler Target address
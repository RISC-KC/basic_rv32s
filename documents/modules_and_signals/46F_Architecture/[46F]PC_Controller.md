# Program Counter Controller (PCC; PC Controller)
Based on 43F Architecture

[입력신호]
+ PCCop     (from Control Unit)
PC          (from Program Counter)
+ B_Target  (from Branch Logic)
J_Target    (from ALU - ALUresult)
+ T_Target  (from Trap_Controller)

[출력신호]
+ NextPC    (to PC)

[Logics]
PC모듈을 컨트롤한다. 
다음 PC가 가르킬 주소 신호인 NextPC를 PC에 출력한다.

PCCop신호를 기반으로 Jump인지, Branch인지, Trapped인지 확인하여 각각 상황에 맞게 J_Target, B_Target, T_Target으로 NextPC를 출력한다.
분기하지 않을 경우 PC에서 +4 한 값을 NextPC로 출력한다.

Control Unit에서 판단하기에, PC값을 아직 갱신하면 안되는 경우 (현재 명령어의 수행이 완료되지 않은 경우. 가장 빈번한 건 데이터 캐시 구조에서 캐시 갱신 등과 같은 이유로 두 사이클 이상이 소요될 때.) PC_Stall을 PCCop로 출력한다. PCC에서는 PCCop의 값이 PC_Stall이고 이게 High일 때 NextPC를 기존의 PC값 그대로를 출력하여 현재 명령어가 갱신되지 않고 계속 수행되도록 한다. 

Exception Detector에서 ECALL, EBREAK과 같은 environment 명령어를 탐지하거나 exception 요소를 발견할 경우 Trapped 신호를 Control Unit으로 출력한다.
이 신호를 받은 Control Unit은 이를 PCCop로 인코딩하여 PCC에 전달한다. 
이를 탐지한 PCC는 NextPC 값을 T_Target로 선택하여, Trap Handler의 시작 주솟값으로 프로그램을 진행해 서브루틴을 수행할 수 있도록 한다.

[Note]
+ 기존 43F Architecture 까지는 정렬되지 않은 명령어들을 PC_Aligner라는 모듈을 통해 강제 정렬하므로 PCC에서 출력하는 신호를 Unaligned Next PC로 규정했었다.
하지만 46F에서는 exception및 trap을 발생하여 해당 처리 루틴으로 분기할 수 있게 되어 하위 2비트 강제 정렬하는 PC_Aligner를 없앴다. 
그런 연유로, U_NextPC 신호는 46F Architecture부터는 NextPC로 바뀐다.

NextPC   = Next Program Counter value
PC_Stall = Program Counter update Stall
Jump     = Jump instruction execution
B_Taken  = Branch Taken
J_Target = Jump Target address
T_Target = Trap handler Target address

┏실제 코드 내 변수 명┓
PCCop = pcc_op
B_Target = branch_target
J_Target = jump_target
T_Target = trap_target
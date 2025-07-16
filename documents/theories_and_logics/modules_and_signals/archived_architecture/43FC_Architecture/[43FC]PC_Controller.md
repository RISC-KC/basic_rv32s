# Program Counter Controller (PCC; PC Controller)
Basically same as 37F Architecture.

[입력신호]
+ PC_Stall   (from Control Unit)
Jump        (from Control Unit)
B_Taken     (from Branch Logic)
PC          (from Program Counter)
imm         (from imm_gen)
J_Target    (from ALU - ALUresult)

[출력신호]
U_NextPC    (to PC_Aligner)

[Logics]
PC모듈을 컨트롤한다. 
다음 PC가 가르킬 주소 신호인 U_NextPC를 PC_Aligner에 출력한다.

B_Taken시 입력된 PC값과 imm값을 덧셈 연산하여 U_NextPC를 출력한다.
Jump시 J_Target의 주솟값을 U_NextPC로 출력한다.
분기하지 않을 경우 PC에서 +4 한 값을 U_NextPC로 출력한다.

+ Control Unit에서 판단하기에, PC값을 아직 갱신하면 안되는 경우 (현재 명령어의 수행이 완료되지 않은 경우. 가장 빈번한 건 데이터 캐시 구조에서 캐시 갱신 등과 같은 이유로 두 사이클 이상이 소요될 때.) PC_Stall을 PCC로 출력한다. PCC에서는 PC_Stall이 High일 때 U_NextPC를 기존의 PC값 그대로를 출력하여 현재 명령어가 갱신되지 않고 계속 수행되도록 한다. 

[Note]
U_NextPC = Unaligned Next Program Counter value
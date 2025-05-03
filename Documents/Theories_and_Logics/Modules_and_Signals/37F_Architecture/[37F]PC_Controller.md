# PC Controller (PCC)

[입력신호]
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

[Note]
U_NextPC = Unaligned Next Program Counter value
# Branch Logic

[입력신호]
Branch  (from Control Unit)
funct3  (from Instruction Decoder)
ALUzero (from ALU)

[출력신호]
B_Taken  (to PCC)

[Logics]
Control Unit으로부터 조건분기문을 수행한다는 식별 신호인 Branch 신호를 입력받아 Branch신호가 high가 되면 분기 판단문을 수행한다.
funct3값을 비교하여 어떤 방식의 조건분기문인지 판단하고, 분기 충족 판든을 위한 값이 ALUzero를 통해 입력되었는지 확인한다.
조건분기문의 조건을 ALUzero가 충족했는지 아닌지를 판단하여 B_Taken 신호를 PCC로 출력한다.
PCC에 출력한 B_Taken신호를 기반으로 PCC에서 다음 주소를 판단해 PCC에 입력중인 PC값과 imm값을 덧셈하고 해당 결과값을 U_NextPC로 선택하도록 한다.

[Note]
B_Taken = Branch Taken
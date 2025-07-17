# Branch Logic
Based on 37F Architecture

[입력신호]
PC      (from Program Counter)
imm     (from Immediate_Generator)
Branch  (from Control Unit)
funct3  (from Instruction Decoder)
ALUzero (from ALU)

[출력신호]
B_Taken  (to Control Unit)
B_Target (to PCC)

[Logics]
Control Unit으로부터 조건분기문을 수행한다는 식별 신호인 Branch 신호를 입력받아 Branch신호가 high가 되면 분기 판단문을 수행한다.
funct3값을 비교하여 어떤 방식의 조건분기문인지 판단하고, 분기 충족 판든을 위한 값이 ALUzero를 통해 입력되었는지 확인한다.
조건분기문의 조건을 ALUzero가 충족했는지 아닌지를 판단하여 B_Taken 신호를 ~~PCC~~ Control Unit으로 출력한다.
이와 동시에, Branch Logic에서는 항상 B_Target 주소 신호를 내부적으로 계산하여 출력한다. (PC+imm)
기존 37F Architecture에서는 해당 B_Target을 PCC내부에서 B_Taken일 때 처리하여 NextPC로 출력했지만 변경되었다.
사유는 Exception Detector에 적힌 내용과 같다.
///
기존 설계에서는 NextPC를 탐지하고 고치는 것으로 설계했으나, NextPC가 적재되는 Program Counter 레지스터는 posedge clk에서만 작동한다.
때문에 NextPC값을 담기 이전에 로직을 처리해야한다는 것을 구현하며 알아냈다.
고로, misalign이 일어날 수 있는 분기 주솟값들을 Exception Detector에 직접 연결하였고, 
그를 위해 기존 PCC에서 내부적으로 계산되어 NextPC로 출력되던 (PC+imm 수행) B_Target(branch_target)을 Branch Logic에 편성해 계산된 B_Target을 그대로 ED가 판단할 수 있도록 했다.
///

CU에 출력한 B_Taken신호를 CU가 PCC로 PCCop 신호를 인코딩하여 전달한다. 
이를 기반으로 PCC에서 B_Target 주소 신호를 NextPC로 선택하도록 한다.

[Note]
┏실제 코드 내 변수 명┓
B_Taken = branch_taken
B_Target = branch_target
# Instruction Cache (IC)

[입력신호]
I.U_Data    (from Instruction Memory)
PC          (from PC)
CLK
RST

[출력신호]
IC_RD       (to I_RD_MUX)
IC_Status   (to I_RD_MUX)

[Logics]
입력된 PC 주솟값에 해당하는 데이터를 인출한다.
Cache miss시 IC_Status를 통해 miss 신호를 내보내고, I_RD_MUX에서 SAA 로직을 통해 IM_RD를 I_RD로 선택하도록 한다. Hit시 IC_RD를 I_RD로 선택하도록 한다. 

[Note]
자세한 내용은 43FC_Cache-Memory_Structure.md 참조.
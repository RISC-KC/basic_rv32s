# Instruction Cache (IC)
Basically same as 43FC

[입력신호]
I.U_Data    (from Instruction Memory)
PC          (from PC)
RST         (from Trap_Controller - IC_Clean)
CLK

[출력신호]
IC_RD       (to I_RD_MUX)
IC_Status   (to I_RD_MUX)

[Logics]
입력된 PC 주솟값에 해당하는 데이터를 인출한다.
Cache miss시 IC_Status를 통해 miss 신호를 내보내고, I_RD_MUX에서 SAA 로직을 통해 IM_RD를 I_RD로 선택하도록 한다. Hit시 IC_RD를 I_RD로 선택하도록 한다. 

+ Zifencei 명령어를 위해 RST 신호는 Trap_Controller에서 보내는 IC_Clean 신호를 RST 즉 무효화 신호로 설계했다.

[Note]
자세한 내용은 43FC_Cache-Memory_Structure.md 참조.
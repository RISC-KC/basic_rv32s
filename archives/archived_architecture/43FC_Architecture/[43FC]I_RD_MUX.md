# Instruction Read Data source Multiplexer (I_RD_MUX)

[입력신호]
IC_Status   (from Instruction Cache)
IM_RD       (from Instruction Memory)
IC_RD       (from Instruction Cache)

[출력신호]
I_RD       (to Instruction Decoder)

[Logics]
IC_Status 신호를 제어로 받아 miss일 경우 SAA를 통해 IM_RD가 선택되도록, Hit일 경우 캐시의 데이터가 인출되어야하니 IC_RD로 선택되도록 한다.

[Note]
IC_Status   = Instruction Cache hit / miss Status
IM_RD       = Instruction Memory Read Data
IC_RD       = Instruction Cache Read Data
I_RD        = Instruction Read Data
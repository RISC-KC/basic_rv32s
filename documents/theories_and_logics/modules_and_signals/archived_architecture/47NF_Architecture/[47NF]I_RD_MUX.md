# Instruction Read Data source Multiplexer (I_RD_MUX)
Basically same as 43FC

[입력신호]
IC_Status   (from Instruction Cache)
IM_RD       (from Instruction Memory)
IC_RD       (from Instruction Cache)

[출력신호]
+ IA_RD       (to DBG_RD_MUX)

[Logics]
IC_Status 신호를 제어로 받아 miss일 경우 SAA를 통해 IM_RD가 선택되도록, Hit일 경우 캐시의 데이터가 인출되어야하니 IC_RD로 선택되도록 한다.
출력값은 DBG_RD_MUX로 전달되어 Debug 실행 유무에 따라 실행할 I_RD가 선택되도록 한다.

[Note]
IC_Status   = Instruction Cache hit / miss Status
IM_RD       = Instruction Memory Read Data
IC_RD       = Instruction Cache Read Data
+ IA_RD        = Instruction Area Read Data

기존에 출력값이 I_RD 즉 Instruciton Read Data 였지만
Debug 라는 명령어 I_RD의 선택지가 하나 늘어나게 되었으므로
Debug Instruciton과 Instruction area(IM, IC)의 인출된 명령어 중 결과적으로 선택되어 I_RD가 되도록 해 용어가 겹치게 됐다.
때문에 기존 I_RD를 IA_RD로 바꾸고, 최종적으로 Instruction Decoder에 전달되는 인출된 명령어를 I_RD로 칭하기로 했다. 
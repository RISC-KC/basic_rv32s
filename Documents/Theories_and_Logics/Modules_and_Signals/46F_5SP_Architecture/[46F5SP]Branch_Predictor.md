# Branch Predictor design

[입력신호]
CLK
IF_opcode   (from Instruction Memory)
IF_PC       (from PC)
IF_imm      (from Instruction Memory)
EX_PC       (from ID_EX_register)
EX_imm      (from ID_EX_register)
EX_BTaken   (from Branch Logic)

[출력신호]
branch_estimation   (to PC Controller, IF_ID_register)
branch_target       (to PC Controller)

[Logics]
2-bit 분기예측 FSM을 사용하여 동적 분기예측을 한다. 
이 모듈을 기술하는 현재 25년 05월 21일. 26일까지 FPGA 구현 이전 1차 개발 과정을 마쳐두어야한다.
본래 BHT, BTB 2비트 분기 예측기를 구상했지만 해당 고급 기능 개발에 2일 잡아두고
먼저 단순 2-bit FSM으로 파이프라이닝이 25년 05월 24일까지 끝나야 넘어갈 수 있다. 
24일은 탑모듈에서 정상 동작하는 것을 기반으로 한다. 

[Note]
[2025.04.07. devlog ## Branch Predictor]
CLK - 클럭신호
IF.opcode - 조건부 분기 명령어인지 확인하기 위함
IF.PC - 현재 PC 값을 기반으로 예측값 Not Taken시 다음 PC 값을 계산해서 PCC에 주기 위함. (BTB의 경우 갱신을 위해서도 사용 됨.)
IF.imm - 현재 PC 값을 기반으로 예측값 Taken시 분기 목적지를 계산해서 PCC에 주기 위함. 
EX.PC - Misprediction 시 해당 분기 명령어의 분기 목적지 또는 다음 명령어 주소 계산을 위해 필요.
EX.imm - 조건 분기 명령어 Misprediction시 분기 목적지 주소를 계산하기 위함.
EX.BTaken - 분기예측한 내용이 실제로 적중했는지 아닌지를 피드백받기 위함.

B.EST - 분기를 예측한 정보를 PCC에 넘겨주기 위함.
B_Target - 예측한 분기 목적지 또는 다음 PC값 계산 결과를 PCC에 주기 위함.
~~BP_Miss - Misprediction시 해당 내용을 Hazard Unit에게 보내서 파이프라인 레지스터들의 데이터를 Flush하기 위함.~~

2025.04.07.에 적힌 devlog 에서 Branch Predictor에 대한 기술이 되어있는데,
IF.imm이 다이어그램에서 보면 PC값에서 나온다 되어있는데, PC값은 어떠한 imm필드의 값도 담고 있지 않으므로, Instruction Memory에서 인출된 명령어의 값을 받아오는 것이 올바르다. 이를 RV32I46F_5SP.R1에서 반영시키겠다. 
반대로, 다이어그램에서는 반영되어있는 내용이지만 2025.04.07.의 devlog에서 Branch Predictor의 입력신호로 BP_Miss가 있다. 이건 후술되어있는 대로, 
Branch Predictor는 IF 단계에서 작동하는 로직의 일률성이 어느정도 잡혀있기 때문에
BP_Miss 를 EX단계에서 ALUzero값과 바로 비교할 수 있는 Branch Logic에서 판단할 수 있도록 할 것이다. 
Branch Logic 모듈에서 BTaken을 판단하여 Branch Predictor에 넘겨줌과 동시에 
Branch Predictor에서 B.EST신호를 파이프라이닝해서 온 EX.B.EST신호를 Branch Logic 모듈에 연결해서 해당 BTaken 값과 비교해 Misprediction인지 판단한다.
그리고 Misprediction인지 아닌지를 BP_Miss신호로 Branch Logic에서 출력하여 Hazard Unit에게 전하는 것으로 변경했다. 
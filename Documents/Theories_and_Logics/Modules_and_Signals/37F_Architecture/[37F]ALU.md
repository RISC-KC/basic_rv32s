# Arithmetic Logic Unit (ALU)

[입력신호]
ALUop   (from ALUcontroller)
srcA    (from ALUsrcA_MUX)
srcB    (from ALUsrcB_MUX)

[출력신호]
ALUresult   (to PCC-J_Target, BE_Logic-address, Data Memory-DM_Addr, RegWDsrc_MUX)
ALUzero     (to Branch Logic)

[Logics]
ALUsrcA와 ALUsrcB로 입력된 데이터 신호들을 ALUcontroller로부터 입력된 ALUop 값에 따라 인코딩된 연산을 수행한다.
처리된 연산값은 ALUresult 데이터 신호로 출력된다. 
Branch Logic의 판단을 위한 비교 연산이 본 ALU에서 진행되므로 RISC-V의 조건 분기가 비교구문이 0인지 아닌지를 통해 판단하므로
처리된 연산값이 0인지 아닌지를 ALUzero값 데이터 신호로 Branch Logic에 출력한다. 

[Note]
ALUresult는 37F에서 
DM의 DM_Addr신호, 
Register File의 RF_WD신호, 
BE_Logic 모듈로 마스킹하기위한 주소 신호(BE_Logic - address), 
PCC의 J_Target으로 출력된다. 
# Register Write Data source MUX (RegWDsrc_MUX)
Basically same as 43F Architecture

[입력신호]
RegWDsrc    (from Control Unit)
ALUresult   (from ALU)
D_RD        (from Data Memory - DM_RD)
BERF_WD     (from BE_Logic)
CSR_RD      (from CSR File)
imm         (from imm_gen)
PC+4        (from PCplus4)
+ 1           
+ 0

[출력신호]
RF_WD       (to Register File)

[Logics]
다섯 가지 입력 데이터 신호들 중 제어신호(RegWDsrc)에 따라 출력신호 선택. 
3-bit MUX로 설계한다. 
000 = D_RD
001 = ALUresult (ALU)
010 = CSR_RD
011 = imm
100 = PC+4
+ 101 = 1
+ 110 = 0


[Note]
RF에 쓸 데이터를 정하는 MUX. 
Zicsr 확장의 모든 명령어에서 R[rd]에 CSR 레지스터 값을 적재하기에 RegWDsrc_MUX에 CSR_RD값을 추가하였다. 

1과 0은 A extension의 Zalrsc 중 SC.W 명령어를 위해 실패시 1, 성공시 0을 R[rd]에 쓰기 위해 즉시 값을 항상 MUX에 input하고 있는 것으로 구현했다.
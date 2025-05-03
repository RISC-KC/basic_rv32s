# Register Write Data source MUX (RegWDsrc_MUX)

[입력신호]
RegWDsrc    (from Control Unit)
ALUresult   (from ALU)
D_RD        (from Data Memory - DM_RD)
BERF_WD     (from BE_Logic - BERF_WD)
imm         (from imm_gen)
PC+4        (from PCplus4)

[출력신호]
RF_WD       (to Register File)

[Logics]


[Note]
RF에 쓸 데이터를 정하는 MUX. 
네 가지 입력신호들 중 제어신호에 따라 출력신호 선택. 
3-bit MUX로 설계한다. 
 000 = DM_RD
 001 = ALUresult
 010 = reserved for Zicsr extension
 011 = imm (directrly from imm_gen just for LUI instruction )
 100 = PC+4
# ALUsrcB_MUX

[입력신호]
ALUsrcB (from Control Unit)
RD2     (from Register File)
imm     (from imm_gen)
shamt   (from imm_gen - imm[4:0])
+ CSR    (from CSR File - CSR_RD)

[출력신호]
srcB    (to ALU)

[Logics]
두 가지 입력신호들 중 제어 신호(ALUsrcB)에 따라 출력신호 선택.
2-bit MUX로 설계한다. 
00 = RD2
01 = imm
10 = shamt(imm[4:0])
+ 11 = CSR(CSR_RD)

[Note]
ALU의 srcB에 들어갈 신호를 선택하는 3:1 MUX. 
+ Zicsr 확장에서 CSR값과 uimm값 뿐만 아니라 RD1 값의 연산도 존재한다.
+ ALUsrcA에서는 RD1 값을 받아와야하니, ALUsrcB에 CSR값을 입력으로 추가했다. 
# ALUsrcA_MUX

[입력신호]
ALUsrcA (from Control Unit)
RD1     (from Register File)
PC      (from Program Counter)

[출력신호]
srcA    (to ALU)

[Logics]
두 가지 입력신호들 중 제어 신호(ALUsrcA)에 따라 출력신호 선택.
1-bit MUX로 설계한다. 
0 = RD1
1 = PC

[Note]
ALU의 srcA에 들어갈 신호를 선택하는 2:1 MUX. 
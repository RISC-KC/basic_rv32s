# ALUsrcA_MUX
Basically same as 37F Architecture

[입력신호]
ALUsrcA (from Control Unit)
RD1     (from Register File)
PC      (from Program Counter)
+ rs1     (from Instruction Decoder)

[출력신호]
srcA    (to ALU)

[Logics]
두 가지 입력신호들 중 제어 신호(ALUsrcA)에 따라 출력신호 선택.
+ 2-bit MUX로 설계한다. 
00 = RD1
01 = PC
+ 10 = rs1

[Note]
+ ALU의 srcA에 들어갈 신호를 선택하는 3:1 MUX. 
43F Architecture로 오면서, Zicsr 확장이 추가되었다. 
Zicsr 확장에서 명령어의 rs1 비트 영역에 해당되는 데이터를 연산의 uimm 상수값으로 CSR와의 연산에 사용한다.
이러한 이유로, ALUsrcA에 Instruction Decoder에서 오는 I_RD[19:15]에 해당하는 rs1 값을 추가하였다.
ALUsrcB에서는 CSR값을 입력으로 해야하기 때문에 ALUsrcA에 rs1 값을 추가했다.
ALUsrcB에 CSR값을 입력으로 하는 이유는, CSR값과 uimm값 뿐만 아니라 RD1 값의 연산도 있기 때문이다. 
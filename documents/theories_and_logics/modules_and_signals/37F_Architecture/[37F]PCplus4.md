# Program Counter plus 4 (PC+4)

[입력신호]
PC      (from Program Counter)

[출력신호]
PC+4    (to RegWDsrc_MUX)

[Logics]
입력된 PC 데이터 신호값에 4를 덧셈하여 결과값을 PC+4 데이터 신호로 출력한다.

[Note]
jal, jalr 명령어에서 R[rd]에 PC+4한 값을 쓰기한다. 
i.e.) jalr : R[rd] = PC + 4; PC = R[rs1] + imm

이를 위해 ALU를 사용하기엔 ALU를 명령어에 인코딩된 별도의 산술 연산을 통해 사용해야하는 경우가 생겨서 별도로 배치하였다.
PCC에 있는 PC+4로직을 응용하려 했는데 별도 모듈로 빼는 것이 구조적 직관성이 좋아 그렇게 했고, 필요하다면 PCC에 내장할 수 있다. 
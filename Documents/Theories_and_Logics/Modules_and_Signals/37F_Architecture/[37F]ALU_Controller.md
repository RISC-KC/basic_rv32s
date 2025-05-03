# ALU Controller (ALUcon)

[입력신호]
opcode      (from Instruction Decoder)
funct3      (from Instruction Decoder)
funct7      (from Instruction Decoder)
raw_imm     (from Instruction Decoder)

[출력신호]
ALUop       (to ALU)

[Logics]
opcode와 funct3, funct7, raw_imm값을 기반으로 ALU에서 처리해야할 산술 논리 연산의 종류를 ALUop라는 별도의 코드로 인코딩한다. 
이를 ALU로 출력하여 ALUop코드를 기반으로 연산 종류를 선택해 처리할 수 있도록 한다.

[Note]

ALU controller에서 처리하는 이 모든 작업을 CU에서 물론 처리할 수 있다.
또한 ALUopcode라는 별도의 인코딩 없이 설계할 수도 있기도 하다.

하지만 ALU관련 Control을 별도 모듈로 이원화하였고, ALUopcode를 만들었다. 
차후 여러 명령어 확장이 더해졌을 때 복잡성이 증가할 가능성을 대비하기 위함이며, 
ISA 규정 외 ALU 동작을 할 수도 있는 유지보수성 증대를 기대할 수 있기 때문이다. 
(추후, 입력된 값 중 ALUsrcA나 ALUsrcB로 입력된 값 '하나'만 선택해서 그 값 그대로 내보내는 Bypass 또한 ALUop로 규정하여 활용도를 높일 수 있다.)
(일종의 내장 micro-opcode 인 것이다.)

또한 설계 가시성과 직관성이 좋아지기도 한다. 
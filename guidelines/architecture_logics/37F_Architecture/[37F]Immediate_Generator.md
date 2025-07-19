# Immediate Generator (imm_gen)

[입력신호]
opcode  (from Instruction Decoder)
raw_imm (from Instruction Decoder)

[출력신호]
imm     (to PCC, ALUsrcB_MUX, RegWDsrc_MUX)

[Logics]
opcode값을 기반으로 입력된 20-bit raw_imm값을 32-bit로 확장한다. 
기본적으로 sign-extension을 수행하며, opcode에 따라 zero-extension을 하기도 한다.
확장이 수행된 32-bit immediate값을 imm 데이터 신호로 출력한다.

[Note]
상수 생성기. 명령어에는 immediate 즉 상수 값이 12~20비트로 인코딩되어있다. 
이처럼 명령어에 인코딩된 12~20비트의 순수 상수값을 본 아키텍처에서 raw_imm 칭한다.
이 raw_imm을 처리 가능한 규격인 32-bit로 Sign-Extension해서 imm이라는 신호로 출력한다. 
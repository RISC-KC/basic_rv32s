# Bit changes

PC address, PC+4 are now 64-bit
shamt is now 6-bit
RD1, RD2, imm are now 64-bit
WB_Addr, WB_Data are now 64-bit
DM_RD, DC_RD, BEDC_WD, BERF_WD are now 64-bit
RF_WD, ALUresult are now 64-bit

Instruction length is still 32-bit
CSR Address is still 12-bit
Cache Block size is still 32-Byte

# Logic Changes
ALUcon에서 funct7의 7-bit 값을 받고 어떤 명령어인지 해독해 ALUop를 인코딩했었다.
하지만 RV64I로 오면서, 비트 쉬프트 연산들이 모두 funct7 필드가 6-bit가 되고 shamt가 5-bit에서 6-bit로 확장되었다. 
여전히 funct7 7-bit 명령어들은 있으므로, 다만 funct7의 [30]번째 비트
[6:0]일거고 이게 6-bit로 줄면 [6:1]이 되는데, [6]번째 비트를 보고 right shift 연산인 것을 판단하도록 설계한다.

변경 명령어.
[R-Type]
SLL, SRL, SRA : 최대 64비트 쉬프팅. rs2의 비트 영역이 6비트로 늘어나고, funct7이 대신 6비트로 줄어든다. (이름값 못하는 funct7이 된다. )

[I-Type]
SLLI, SRLI, SRAI : 최대 64비트 쉬프팅. imm값의 25:20을 shamt로 잡고, 31:26이 funct7으로 들어온다. (6비트)
LW : Load-word. 데이터 폭이 64비트로 바뀌었으므로 32비트를 로드하는데 나머지 남은 상위 32비트를 sign-extension한다.

신규 명령어.
[R-Type]
ADDW, SUBW, SLLW, SRLW, SRAW : 32비트 처리 명령어들. 덧셈, 뺄셈, 비트쉬프팅. 
각각 32비트로 계산하며, 그 결과의 상위 32비트를 sign-extension하여 쓰기한다. 

[I-Type]
ADDIW, SLLIW, SRLIW, SRAIW : 32비트 처리 상수 명령어들. 덧셈, 비트쉬프팅.
ADDIW는 마찬가지로 32비트 계산 후 sign-extension하여 쓰기한다. shifting은 위 설명대로. 

LWU, LD : Load(적재) 명령어. 
LWU - Load Word Unsigned. 32비트 데이터의 상위 32비트를 zero-extension하고 로드한다. 
LD - Load Double word. 64비트 데이터를 로드한다. 

이상이다. 

하드웨어 변경사항을 정리하면 다음과 같다.

1. Instruction Cache, Memory (Instruction Area)의 주소 폭 64비트. 

2. Instrcution Decoder : rs2의 비트 6비트로 확장, 'w'명령어일 때는 그에 맞는 비트 영역을 슬라이싱하도록 설계. (R-Type shifting 명령어의 shamt 즉 rs2 필드 값이 6-bit로 확장되었으므로.)

3. imm gen : 64비트 Sign-extension. (상황에 따라 zero-extension :  U-Type)

4. Register File : 레지스터 데이터 폭 및 RD1, RD2 출력 비트 64비트. 

5. CSR File : CSR_RD 64비트. 나머지 CSR 레지스터는 그 규격에 맞게 32비트와 64비트를 병행. (설계 자체로서 데이터 폭은 64비트. 32비트 데이터 출력시 zero-extension)

6. ALU Controller : W명령어 (RV64-only instructions)전용 연산 ALUop코드 추가. (32비트 계산 후 64비트 확장)

7. ALU : ALUop코드에 따른 W명령어 연산 및 처리 추가

8. Data Cache, Memory (Data Area)의 주소 및 데이터 폭 64비트

자세한 변경 내용은 랑그너 일기 2025.03.27. 2467번쨰 줄부터 참조하라.
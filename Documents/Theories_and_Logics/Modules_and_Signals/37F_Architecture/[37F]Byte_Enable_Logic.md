# Byte Enable Logic (BE_Logic)

[입력신호]
MemRead     (from Control Unit)
MemWrite    (from Control Unit)
funct3      (from Instruction Decoder)
address     (from ALU - ALUresult)
RF2DM_RD    (from Register File - RD2)
DM2RF_RD    (from Data Memory - D_RD(DM_RD))

[출력신호]
WriteMask   (to Data Memory - ByteMask)
BEDM_WD     (to Data Memory - DM_WD)
BERF_WD     (to RegWDsrc_MUX)

[Logics]
MemRead와 MemWrite 신호를 기반으로 각각 BERF_RD, BEDM_RD 신호로 마스킹된 데이터를 출력한다.
funct3를 통해 워드단위인지, 하프워드 단위인지, 바이트 단위인지 판단하고 address 신호를 기반으로 ByteMask를 생성한다. 
워드단위면 ByteMask가 0000, 즉 원본 데이터가 그대로 통과한다.
하프워드나 바이트 단위가 되면 그 위치를 BE_Logic이 Bit Masking 로직을 통해 처리하여 출력한다.
취급 단위의 판단을 위한 식별 신호는 funct3로, 해당 값을 받아서 명령어의 유형(워드, 하프 워드, 바이트)을 확인해 Byte Mask를 생성하고, 쓰여질 데이터를 생성한다.
RISC-KC의 basic_rv32s 에서는 해당 데이터 생성은 마스크에 따라 도배하는 방식을 사용한다.
쓰여져야할 데이터가 0xDEADBEEF고 ByteMask가 0011이라면 데이터를 0x0000_BEEF가 아니라, 0xBEEF_BEEF로 출력하는 것이다.
추가적으로 구현해야하는 로직을 줄이고자 본 방식처럼 구현하였다.
해당 출력된 데이터는 WriteMask를 통해 WriteMask를 디코딩하여 의도한 위치에 쓰기를 수행하여 데이터를 변경한다.

[Note]
비트 정렬 로직.
Load(적재; Register File에서 Memory로) 명령어나 Store(저장; Memory에서 Register로) 명령어를 보면, 
워드 단위뿐만 아니라 하프워드(2바이트), 바이트(8비트)단위로 쪼개지기도 한다. 
그에 맞게 명령어에서 지정한 위치에 데이터를 쓰기 위한 로직 처리 모듈이다.
RF에서 DM으로, DM에서 RF로. 쓰기 작업시엔 해당 데이터가 무조건 BE_Logic을 거친다.

 [예시]
 기존 값 : 0xDEAD_BEEF, 쓰려는 값 0x1111_1111
 Mask : 0000 (word) -> 결과 : 0x1111_1111
 Mask : 1100 (half-word) -> 결과 : 0x1111_BEEF
 Mask : 0110 (half-word) -> 결과 : 0xDE11_11EF
 Mask : 0011 (half-word) -> 결과 : 0xDEAD_1111
 Mask : 1000 (byte) -> 결과 : 0x11AD_BEEF
 Mask : 0100 (byte) -> 결과 : 0xDE11_BEEF
 Mask : 0010 (byte) -> 결과 : 0xDEAD_11EF
 Mask : 0001 (byte) -> 결과 : 0xDEAD_BE11
# Control and Status Register File (CSR_File; CSRFile; CSRF)

[입력신호]
CLK
RST
CSRwrtie    (from Control Unit)
CSR_Addr    (from imm_gen - raw_imm)
CSR_WD      (from ALU - ALUresult)

[출력신호]
CSR_RD      (to ALUsrcB_MUX, RegWDsrc_MUX)

[Logics]


[Note]
CLK         = CLocK
RST         = ReSeT
CSRwrite    = CSR write enable
CSR_Addr    = CSR address
CSR_WD      = CSR Write Data
CSR_RD      = CSR Read Data


Zicsr 확장의 명령어들을 지원하기 위한 별도의 레지스터 파일.
인터럽트나 등등 시스템 연산에 주로 사용되며, 추후 OS 이식을 위해 필수적인 Zicsr 확장을 위해 필수적인 레지스터 파일.
Register File과 비슷하다.
CSR_enable로 쓰기를 활성화하며, 비동기식 읽기이다. 
구현된 CSR의 목록은 CSR_Logics.md 문서 참조.
# CSR Address source Multiplexer (CSR_Addr_MUX)

[입력신호]
Trapped     (from Exception Detector)
raw_imm     (from Instruction Decoder)
CSR_T.Addr  (from Trap Controller)

[출력신호]
CSR_Addr    (to CSR File)

[Logics]
Exception Detector에서 Trap이나 Exception을 감지하면 CSR_Addr로 향하는 
CSR File의 입력 주소를 CSR_T.Addr로 선택해서 해당 위치의 CSR 파일을 접근하거나 쓰기할 수 있도록 한다. 평시에는 raw_imm으로 되어 Zicsr에 의한 명령어 수행을 할 수 있도록 한다. 

[Note]
┏실제 코드 내 변수 명┓
CSR_T.Addr  = csr_trap_address
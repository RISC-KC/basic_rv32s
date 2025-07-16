# CSR Write Data source Multiplexer (CSR_WD_MUX)

[입력신호]
Trapped     (from Exception Detector)
CSR_T.WD    (from Trap Controller)
ALUresult   (from ALU)

[출력신호]
CSR_WD      (to CSR File)

[Logics]
Exception Detector에서 Trap이나 Exception을 감지하면 CSR_WD로 향하는 
CSR File의 입력 주소를 CSR_T.WD로 선택해서 동시에 CSR_Addr_MUX에서 인출된 CSR_T.Addr 위치의 CSR 파일에 CSR_T.WD로 출력되는 값을 쓰기할 수 있도록 한다. 평시에는 ALUresult으로 되어 Zicsr에 의한 명령어 수행을 할 수 있도록 한다. 


[Note]
CSR_T.WD    = CSR Trapped Write Data
# Forward Unit design

[입력신호]
MEM_imm		(from EX/MEM Pipeline register)
MEM_alu_result		(from ALU)
MEM_csr_read_data	(from CSR File)
MEM_read_data		(from Data Memory)
MEM_pc_plus_4		(from EX/MEM Pipeline register)
MEM_opcode		(from EX/MEM Pipeline register)
hazard_op		(from Hazard Unit)

[출력신호]
alu_forward_source_a	(to ALU forward MUX A)
alu_forward_source_b	(to ALU forward MUX B)
alu_forward_source_select_a	(to ALU forward MUX A)
alu_forward_source_select_b	(to ALU forward MUX B)

[Logics]
Hazardop로 데이터 해저드가 발생했음을 알고, 
선행 명령어 A의 결과(레지스터파일에 결과적으로 쓰기 되는)에 해당되는 데이터를
현행 명령어 B의 유형에 맞게 ALUsrc 중 하나로 적절히 전달한다. 

ALU의 source에 어떤 데이터를 전달해야하는지는, 후행 명령어가 필요한 데이터의 유형을 알아야한다.
즉 후행 명령어가 어떤 유형의 명령어인지를 식별해야하고, 이를 opcode로 식별하기로 한다.
alu의 source A는 RD1, PC, rs1값
source B는 RD2, imm, CSR_RD값.
이 있는데, RD1, RD2는 레지스터에 저장된 값으로 레지스터에 저장될 소스를 포워딩해줘야한다.
그들이 D_RD, ALUresult, CSR_RD, imm(LUI), PC+4가 해당된다. 
결과적으로 Forward Unitd에서 전방전달해주어야하는 값은,
Memory Access 단계로 입력 되는 즉 EX단계의 결과 데이터인
D_RD,ALUresult, CSR_RD, imm, PC+4, PC, rs1값이다.

허나 rs1값은, 변경되는 데이터의 저장값이 아니라 해당 명령어에 인코딩된 5비트 uimm값이므로
전방전달하지 않는다. 마찬가지로 x0 일 경우도 값의 변경이 되는 레지스터가 아니기에 전방전달하지 않는다.
PC값은...연산에서 현재 있는 PC값을 사용하기 위해 ALUsrcA에 있는 것이니 전방전달하지 않는다.
최종적으로 전방전달되는 데이터는 아래와 같다.
imm값또한 해당 연산에서 종속성을 갖지 않는 상수 값이니 제외된다.
아니지. imm값이 LUI 명령어에서 결국 해당 레지스터에 적재되는 값이니 포함해야한다.
PC+4는..jal과 jalr을 위한 내용인데, 후행 명령어가 jal의 rd값을 rs로 사용하게 되면 해당 내용이 WB되기 전에 전방전달 할 수 있으니 포함한다.

D_RD, ALUresult, CSR_RD, imm, PC+4.
이렇게 된다. 전체적으로 명령어 MNEMONICS에서 R[rd]에 저장되는 소스값들이다. 

[Note]
ID에서 해저드 발생을 탐지하면 해당 해저드 명령어가 EX에 왔을 때 
그 바로 앞에 있는 MEM 단계 수행중인 명령어의 타입을 알아야 어떤 명령어를 통해 무슨 결과 값이 rd에 저장되는지 알 수 있다. 
그래서 EX/MEM 단계 레지스터에서 opcode신호를 받아왔다. 
# RISC-V RV32I Processor Development Log
The architecture design evolution is from **37F**, **43F**, **46F**, to **46F5SP**. 
Make sure to read the tutorials for optimal learning experience.

## Pre-CPU (Process before the 37F base architecture)

### [2024.12.14.]
- ChoiCube84 implemented **Program Counter** module in VerilogHDL, RTL source code.

### [2024.12.15.]
- Block Diagram tool has been decided to **draw.io**.  

- Designed Program Counter, Instruction Memory, Register File datapath  
![Start_Design](/diagrams/design_archive/Pre-CPU/RV32I_decoding.drawio.png)

- Control Unit development start  
-> Realizing that it's complex module, decided to delay until the base modules and datapaths are designed for executing the instruction. 

- ALUopcode idea  
We thought that ALU should be only performing the Arithmetic and Logic calculations.  
The operation decision should be separated from the main ALU since we do not actually know about what kind of calculations can be extended. So, KHWL thought we need **ALU decoder**<sup>1</sup> which controls the behavior of **ALU**, and this became the main idea of ALU operation code; ALUopcode= **ALUop signal.**  
<sup> 1. This **ALU decoder** further becomes **ALU Controller**

### [2024.12.18.]
- Added decoding signal path in block diagram. Instruction Memory Read Data to Register File.
![Signal_Decoded](/diagrams/design_archive/Pre-CPU/RV32I_rf.drawio.png)

### [2024.12.20.]
- Added **Instruction Decoder**, **ALU Controller**, **Control Unit**, **Register File Write Data Source MUX** module block diagram.  

- Revised **Register File** block's I/O signals. (Read Address1, Read Address2, Write Address, Write Data, clk, Write Enable, Read Data1, Read Data2)
![ID_CU_RF_ACU_ALU](/diagrams/design_archive/Pre-CPU/RV32I_id_CU_RF_ACU_ALU.drawio.png)

- We can just divide the signals from instruction, but for intuitive design and easy understanding, we've made **Instruction Decoder** module block indepedently.  

### [2024.12.21.]
- Added **Data Memory** module block
- **Register File Write Data MUX(Reg_WD_MUX)** gets ALU result, Data Memory Read Data, Next PC address.
![Signal_Connected_RV32I](/diagrams/design_archive/Pre-CPU/RV32I_Signals.drawio.png)


### [2024.12.22.]
Making the block diagram down to signal-level. 
- Added **immediate generator** module block for zero/sign-extension the immediate value from instruction decoder.  

- Added **Branch Logic** module block for checking if ALUresult is zero for recognizing if branch instruction's condition is true.  

![added_imm_gen_branch_logic](/diagrams/design_archive/Pre-CPU/RV32I_Branch.drawio.png)

### [2024.12.23.]
- Added **pc_plus_4** module block for intuitiveness. It goes to **Reg_WD_MUX**. in RISC-V RV32I, some (un)conditional branch instructions and U-Type instructions requires to write pc+4 value to register with the instruction main behavior.

<sup> I think this should be merged to **Reg_WD_MUX** in FPGA RTL codes. The intuitiveness should only be in block diagram and learning design. Not in actual core synthesis.</sup>

![added_pc_plus_4_reg_mux](/diagrams/design_archive/Pre-CPU/RV32I_Branch_PC4.drawio.png)

- Added draft **PC Controller** module block in core diagram.  
To execute the (un)conditional branch instructions, such as J-Type, B-Type instruction, KHWL thought there should be an separate control logic unit for PC value control. **Program Counter** should only perform as the register that holds current instruction's instruction memory address. 

![added_PCC](/diagrams/design_archive/Pre-CPU/RV32I_Branch_PCCon.drawio.png)

### [2024.12.24.]
- The logic idea of **PC Controller**  
.1. Receive current PC value and jump, branch instruction notice signal and corresponding target pc address signal  
.2. Decide whether it's jump, branch instruction or normal instruction and output the corresponding `next_pc` signal.  

If it's jump, branch; `next_pc` is `jump_target`, `branch_target` respectively, if it's neither one of those, `next_pc` is currnet pc value + 4.

Considered about designing the `next_pc` selection logic MUX outside of **PC Controller**.

![reviesed_PCC](/diagrams/design_archive/Pre-CPU/RV32I_PCcon_nextpcMUX(1).drawio.png)

### [2024.12.25.]
- Confirmization of initial **PC Controller** module block design  
Decided to integrated the `next_pc` selection logic MUX in **PC Controller**.

- Misunderstood about jump target address. In diagram `RV32I_PCcon_Branch.drawio`, jump target is from alu_result and ex-imm (extended immediate value from Immediate Generator module) 

- Added detail for **Branch Logic**-**PC Controller** datapath since the PC logic has been decided.
![Detailed_Branch_Logic](/diagrams/design_archive/Pre-CPU/RV32I_PCcon_Branch.drawio.png)

### [2024.01.02.]
- Organized PC Controller signal input
![Organize_PCC_signal](/diagrams/design_archive/Pre-CPU/RV32I_PCcon_Branch2.drawio.png/)

## 37F Architecture Development

### [2024.01.04.]
- The first draft version of RV32I37F Architecture designed
![Pre-RV32I37F](/diagrams/design_archive/Pre-CPU/FirsteverRV32Iown.drawio.png)
- PC Controller is now viewed as a module
- NZCV Flag signals was an input of Branch Logic from the output of ALU. 
(Removed since RISC-V doesn't require NZCV unlike ARM.)
(Main idea was from IDEC lecture about RISC-V CPU introduction and FPGA implementation by Y. W. Kim.)

|Name|Inputs|Outputs|Signals|
|:---|:---|:---|:---:|
|**Modules**|
|Program Counter| CLK, NextPC, reset|PC|3+1=4|
|PC Controller|PC, jump, branch_taken, jump_target, branch_target|NextPC|5+1=6|
|Instruction Memory|PC|IM_RD|1+1=2|
|Instruction Decoder|IM_RD|opcode, funct3, funct7, rs1, rs2, rd, imm|1+7=8|
|Register File|CLK, RA1, RA2, RW, WA, RF_WD|RD1, RD2|6+2=8|
|Data Memory|CLK, reset, MemWrite, MemRead, DM_WD, ALUresult|DM_RD|6+1=7|
|Control Unit|opcode|ALUsrcA, ALUsrcB, ALUop, Branch, Jump, MemWrite, MemRead, Memory2Reg, RegWrite|1+9=10|
|ALU Controller|ALUop, funct3, funct7|ALUcontrol|3+1=4|
|ALU|ALUcontrol, srcA, srcB|NZCV, ALUresult|3+2=5|
|Branch Logic|Branch, NZCV, funct3|branch_Taken|3+1=4|
|PCplus4|PC, 4|pc_plus_4|2+1=3|
|Immediate Generator|imm|ex_imm|1+1=2|
|**MUXs**|
|ALUsrcMUX_A|ALUsrcA, RD1, PC|srcA|3+1=4|
|ALUsrcMUX_B|ALUsrcB, RD2, ex_imm|srcB|3+1=4|
|RegF_WD_MUX|Mem2Reg, ALUresult, DM_RD, PC+4|RF_WD|4+1=5|

Total 15 Modules, 40 Signals.

### [2024.01.05.]
- Organized signal routing of Block Diagram.
![signal_organized_Pre-CPU](/diagrams/design_archive/Pre-CPU/RV32I_OrganizedSignals_A4_Signed_B.drawio.png)

Each signal's explainations
각 신호에 대한 설명
(CLK, rst
PC, NextPC, PC+4
Jump, Branch, BTaken, J_Target, B_Target, 
IM_RD, 
opcode, funct3, funct7, rs1, rs2, rd, imm, 
RA1, RA2, RW, WA, RF_WD, RD1, RD2, 
MW, MR, DM_WD, ALUresult, DM_RD, 
ALUsrcA, ALUsrcB, ALUop, M2R, 
ALUcontrol, srcA, srcB, NZCV, ALUresult
ex_imm)

- CLK = CLocK
- PC = Program Counter address (32-bit)
- NextPC = Next PC address (32-bit)
- PC+4 = PC address + 4 (32-bit)
- Jump = 	Whether Jump(J-Type) Instruction is operating or not. Decides PCC to select which signal should be NextPC.   
If true, NextPC = J_Target
- Branch = Whether Branch(B-Type) Instruction is operating or not. Enables Branch Logic's calculation.
- BTaken = Whether Branch(B-Type) Instruction's condition is satisfied or not. Decides PCC to select which signal should be NextPC.   
If true, NextPC = B_Target
- J_Target = If Jump is true, NextPC Address. NextPC = PC + imm(32-bit)
- B_Target = If Branch is true, NextPC Address NextPC = PC + imm(32-bit)
- IM_RD = Instruction Memory_Read Data.
		32-bit Instruction read from Instruction Memory, recognized with PC.
- opcode = opcode from IM_RD
- funct3 = additional opcode domain. specifies calculation variation.   
(If I-Type, add, sub..etc is decided by funct3 domain.)
- funct7 = additional opcode domain. If funct3 are same, funct7 does the distinction.
- rs1 = register source 1. The data that came from 32-bit instruction.
- rs2 = register source 2. same as rs1.
- rd = register destination. The destination address of register. 
- imm = immediate value. Varies by the type of Instruction. Usually used after extension by Immediate Generator Module.
- ex_imm = 32-bit sign-extended immediate value.
- RA1 = Read Address to Register File. 
- RA2 = same as RA1.
- RW = Register Write;RegWrite. Enables Register's write operation.
- WA = Write Address. Destination address of Register's write operation.
- RF_WD = Register File_Write Data. A data to write in Register File.   
Usually selected between ALUresult, DM_RD, PC+4. By RegF_WD_MUX.
- RD1 = Data that has read from Register File. 
- RD2 = Same as RD1.
- MemWrite = Memory Write. Enables Memory's write operation.
- MemRead = Memory Read. Enables Memory's Read operation.   
Unlike Register File, Data Memory's Read operation should be conditioned. Due to Load store operation. They should not crash each other.
- DM_WD = Data Memory_Write Data. The data that's going to write in Data Memory. Usually from the Register File.
- ALUresult = ALU's calculation result data. Usually goes to PCC for the Branch/Jump operation, or DataMemory or Register File to store data.
- DM_RD = Data Memory_Read Data. The data that has read from Data Memory.
- ALUop = ALU's base operation code from Control Unit. Inputs ALU controller Module.
- ALUcontrol = ALU's actual operation signal. From the ALU Control Module, decides which operation should ALU do.
- ALUsrcA = ALU's calculation source A. Decided by the ALUsrcMUX_A between RD1 and PC.
- ALUsrcB = Same as ALUsrcA. Decided by the ALUsrcMUX_B between RD2 and ex-imm.
- srcA = Decided ALUsrcMUX_A's data.
- srcB = Decided ALUsrcMUX_B's data.
- Mem2Reg = Memory to Register. A signal that decides which data should be written in Register File by RegF_WD_MUX. 
- NZCV = Negative, Zero, Carry, oVerflow. Flag signal.  
Usually outputs zero signal to Branch Logic to check if the branch condition is satisfied.

#### Things to revise
1. RV32I doesn't need NZCV flags according to the ISA Manual.   
→ **Revise NZCV in ALU to ALUzero signal**
2. We need module for aligning 2-bit of LSB for `jalr` instruction's J_Target calculation.  
→ Design idea for **PC Aligner**
3. We must specify which module should use CLK, reset signal
4. For `Register File`and `Data Memory`'s write operations, data stores not only 4bytes but also 2-1bytes by `lw`, `lh`, `lb`, `sw`, `sh`, `sb` instructions. Since typical data's length is 32-bit, there's possibility that 2 or 1 byte operations could be done in the middle of those bits. such as 0000_AA00, AA00_0000 (A is the source data to write).  
→ Design idea for **Byte Enable Logic**  
Using a `write_mask` signal for encoding the location of the data to be stored. e.g.) mask: 0011 = 0000_AAAA, 0100 = 00AA_0000

- Added **J_Aligner** module for forcefully aligning `J_Target` jump target address' 2-bit LSB to 00, preventing misalignment in jump instruction.
![RV32I37_J_Aligner](/diagrams/design_archive/RV32I37F/RV32I37_J_Aligned.drawio.png)

- Added **Byte Enable Logic** module for partial load and store instruction. Such as lh, lhu, lb, lbu, sb, sh.
![RV32I37_BE_Logic](/diagrams/design_archive/RV32I37F/RV32I37_BE_Logic.drawio%20(1).png)


### [2025.01.06.]
- Designed **CSR File** module's draft
The first purpose of adapting CSR was for implementing OS, but sooner, the main reason became for supporting the full RV32I ISA. ECALL, EBREAK instructions are handled with exception or trap, which requires Control & Status Register for handling. Also following the basics of Computer Architecture, just like other ISAs, CSR is required.
- We were referencing the RISC-V Instruction Set Manual Volume I: Unprivilged ISA Document version 2.2 which includes CSR instructions and fence.i instruction in base RV32I

![RV32I37_CSR_Draft](/diagrams/design_archive/RV32I37F/RV32I37_CSR.drawio.png)

- While verifying the datapath of ADD instruction, we found that the **Register File**'s design is awkward.  
	- The data signal which receives from RegF_WD_MUX's name is RF_RD(Register File Read Data)  
	- It outputs the data to **Byte Enable Logic** and **Data Memory**. This datapath could be optimized with **Register File**'s Read Data output `RD2` since the store instruction's description is `M[R[rs1]+imm] = R[rs2]`

### [2025.01.11.]
- Optimized **Register File** - **Data Memory** - **Byte Enable Logic** datapath as mentioned. (using RD2 signal)
- Added `CSR_Enable` signal to CSR File <sub> It removed later on, to streamline the signals for reducing complexity</sub>

![RV32I37_fixedBE_CSR](/diagrams/design_archive/RV32I37F/RV32I37_fixedBE_CSR.drawio.png)

Designing the **CSR File** for CSR instructions. 
- Added CLK and reset signal since the register flie's behavior should be synchronous for data signal stability (such as Read after Write)
- Designed **CSR File**'s write data signal `CSR_WD`'s datapath.   
	- For register-CSR instructions (CSRRW, CSRRS, CSRRC), it receives **ALU**'s `alu_result` signal.   
	Which means, it bypasses `RD1` signal from `ALUsrcA` to `alu_result`, forwarding to **CSR File**'s `CSR_WD`.
	Register-CSR instruction - CSRRW: R[rd] = CSR, CSR = R[rs1]
	- For immediate-CSR instructions (CSRRWI, CSRRSI, CSRRCI), it receives **Immediate Generator**'s `ex-imm`.   
	Immediate-CSR instructoin - CSRRWI: R[rd] = CSR, CSR = imm
	- These two data for CSR File's input is selected from CSR_WD_MUX.

![RV32I37_CSR_Ongoing](/diagrams/design_archive/RV32I37F/RV32I37_CSRongoing.drawio.png)


### [2025.01.12.]

Noticed that FENCE, FENCE.i, EBREAK, ECALL instructions are SYSTEM instruction while designing full RV32I compliant architecture (version 2.2). 
- To implement FENCE.i, we need cache structure.
- To implement FENCE, we need multi-hart system architecture.

These changes requires expanding the design.  
Since we have not RTL implement and verificated the design, expanding to those structures enlarges milestone too far.  

- For this reason, we choose to exclude 4 instructions(FENCE, FENCE.i, EBREAK, ECALL) and design 43 instruction supported arhitecture. 
- Which is RV32I43O, 43 architecture. 
<sub>O stands for Optimized signals.</sub>

![RV32I37_CSR_Draft](/diagrams/design_archive/RV32I37F/RV32I37_CSR.drawio.png)



현재 난관은 이 상황.
완전한 RV32I를 구현하는 것이 초기 목표였으나, 거의 완성 단계에 다다라서 FENCE, FENCE.i, EBREAK, ECALL 이 4가지 명령어가
시스템 명령어라는 것을 알게 됨. 별도의 메모리 및 캐시의 구현이 필요하며 이는 곧 시스템 개발로 노선이 확장된다..
아직 프로그래밍 구현과 검증을 해보지 않은 상황에서 이 것 까지 범위를 확장하기엔 마일스톤이 너무나 커진다. 
때문에, 47가지 명령어중 4가지 명령어를 제외한 43가지 명령어로 1차 개발을 마친다. 신호 최적화까지 마친 이 설계도의 이름은
RV32I43O 로 명명한다. RV32I 중 43개의 명령어, Optimized signals.
구현을 위하여 ChoiCube84가 모듈과 신호의 역할에 대해 충분한 이해를 하고 있어야 하므로 
ISA의 각 명령어별 의미와 작동 방식을 문서화하고, 모듈에 대한 내용 문서화, 신호에 대한 내용 문서화를 해야한다.
나에게도 복습이 되며 이걸 알아야 Verilog로 구현하는 의미가 있으니까. 

이대로 검증을 마치고,, 아마 내가 설명 자료를 먼저 만들고 CC84가 마저 구현하고 있을 것인데, 남는 시간동안엔 
Core Unit과 Memory Units, Interface의 Top Module 시점에서의 설계도를 구상하는 것을 시도해보아야 겠다.
결국 RV32G를 만드는 것이 목표인데, FENCE, FENCE.i, EBREAK, ECALL 명령어의 구현은 필수이다. 
얼추 검증이 끝나면 그 설계도를 기반하여 구현 시도를 해보고, 안되면 그 상태 그대로 5단계 파이프라이닝으로 넘어간다. 
Modules문서를 만들고 모듈들에 대한 전반적인 설명을 모두 마쳤다.
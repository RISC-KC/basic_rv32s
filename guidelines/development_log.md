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

![reviesed_PCC](/diagrams/design_archive/Pre-CPU/RV32I_PCcon_nextpcMUX.drawio.png)

### [2024.12.25.]
- Confirmization of initial **PC Controller** module block design  
![revised2_PCC](/diagrams/design_archive/Pre-CPU/RV32I_PCcon_nextpcMUX(1).drawio.png)
![revised3_PCC](/diagrams/design_archive/Pre-CPU/RV32I_PCcon_nextpcMUX.drawio.png)

Decided to integrated the `next_pc` selection logic MUX in **PC Controller**.

- Misunderstood about jump target address. In diagram `RV32I_PCcon_Branch.drawio`, jump target is from alu_result and ex-imm (extended immediate value from Immediate Generator module) 

- Added detail for **Branch Logic**-**PC Controller** datapath since the PC logic has been decided.
![Detailed_Branch_Logic](/diagrams/design_archive/Pre-CPU/RV32I_PCcon_Branch.drawio.png)

### [2024.01.02.]
- Organized PC Controller signal input
![Organize_PCC_signal](/diagrams/design_archive/Pre-CPU/RV32I_PCcon_Branch2.drawio/)

## 37F Architecture Development

### [2024.01.04.]
- The first draft version of RV32I37F Architecture designed
![Pre-RV32I37F](/diagrams/design_archive/Pre-CPU/FirsteverRV32Iown.drawio.png)
- PC Controller is now viewed as a module
- NZCV Flag signals was an input of Branch Logic from the output of ALU. 
(Removed since RISC-V doesn't require NZCV unlike ARM.)
(Main idea was from IDEC lecture about RISC-V CPU introduction and FPGA implementation by Y. W. Kim.)

### [2024.01.05.]
- Organized signal routing of Block Diagram.
![signal_organized_Pre-CPU](/diagrams/design_archive/Pre-CPU/RV32I_OrganizedSignals_A4_Signed_B.drawio.png)

- Added **Byte Enable Logic** module for partial load and store instruction. Such as lh, lhu, lb, lbu, sb, sh.

![RV32I37F_BE_Logic](/diagrams/design_archive/RV32I37F/RV32I37_BE_Logic.drawio%20(1).png)

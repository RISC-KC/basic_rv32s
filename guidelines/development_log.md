# RISC-V RV32I Processor Development Log
The architecture design evolution is from **37F**, **43F**, **46F**, to **46F5SP**. 
Make sure to read the tutorials for optimal learning experience.

## [2024.12.14.]
- ChoiCube84 implemented **Program Counter** module in VerilogHDL, RTL source code.

## [2024.12.15.]
- Block Diagram tool has been decided to **draw.io**.  

- Designed Program Counter, Instruction Memory, Register File datapath  
`diagrams/design_archive/Pre-CPU/RV32I_decoding.drawio.png`

- Control Unit development start  
-> Realizing that it's complex module, decided to delay until the base modules and datapaths are designed for executing the instruction. 

- ALUopcode idea  
We thought that ALU should be only performing the Arithmetic and Logic calculations.  
The operation decision should be separated from the main ALU since we do not actually know about what kind of calculations can be extended. So, KHWL thought we need **ALU decoder**<sup>1</sup> which controls the behavior of **ALU**, and this became the main idea of ALU operation code; ALUopcode= **ALUop signal.**  
<sup> 1. This **ALU decoder** further becomes **ALU Controller**

## [2024.12.18.]
- Added decoding signal path in block diagram. Instruction Memory Read Data to Register File.
`diagrams/design_archive/Pre-CPU/RV32I_rf.drawio.png`

## [2024.12.20.]
- Added **Instruction Decoder**, **ALU Controller**, **Control Unit**, **Register File Write Data Source MUX** module block diagram.  

- Revised **Register File** block's I/O signals. (Read Address1, Read Address2, Write Address, Write Data, clk, Write Enable, Read Data1, Read Data2)
`diagrams/design_archive/Pre-CPU/RV32I_id_CU_RF_ACU_ALU.drawio`  

- We can just divide the signals from instruction, but for intuitive design and easy understanding, we've made **Instruction Decoder** module block indepedently.  

## [2024.12.21.]
- Added **Data Memory** module block
- **Register File Write Data MUX(Reg_WD_MUX)** gets ALU result, Data Memory Read Data, Next PC address.
`diagrams/design_archive/Pre-CPU/RV32I_Signals.drawio`  


## [2024.12.22.]
Making the block diagram down to signal-level. 
- Added **immediate generator** module block for zero/sign-extension the immediate value from instruction decoder.  

- Added **Branch Logic** module block for checking if ALUresult is zero for recognizing if branch instruction's condition is true.  

`diagrams/design_archive/Pre-CPU/RV32I_Branch.drawio`  

## [2024.12.23.]
- Added **pc_plus_4** module block for intuitiveness. It goes to **Reg_WD_MUX**. in RISC-V RV32I, some (un)conditional branch instructions and U-Type instructions requires to write pc+4 value to register with the instruction main behavior.

<sup> I think this should be merged to **Reg_WD_MUX** in FPGA RTL codes. The intuitiveness should only be in block diagram and learning design. Not in actual core synthesis.</sup>

`diagrams/design_archive/Pre-CPU/RV32I_Branch_PC4.drawio`  

- Added draft **PC Controller** module block in core diagram.  
To execute the (un)conditional branch instructions, such as J-Type, B-Type instruction, KHWL thought there should be an separate control logic unit for PC value control. **Program Counter** should only perform as the register that holds current instruction's instruction memory address. 

`diagrams/design_archive/Pre-CPU/RV32I_Branch_PCCon.drawio`  

## [2024.12.24.]
- The logic idea of **PC Controller**  
.1. Receive current PC value and jump, branch instruction notice signal and corresponding target pc address signal  
.2. Decide whether it's jump, branch instruction or normal instruction and output the corresponding `next_pc` signal.  

If it's jump, branch; `next_pc` is `jump_target`, `branch_target` respectively, if it's neither one of those, `next_pc` is currnet pc value + 4.

Considered about designing the `next_pc` selection logic MUX outside of **PC Controller**.

`diagrams/design_archive/Pre-CPU/RV32I_Branch_PCCon_nextpcMUX.drawio`  

## [2024.12.25.]
- Confirmization of initial **PC Controller** module block design  
`diagrams/design_archive/Pre-CPU/RV32I_Branch_PCCon_nextpcMUX(1).drawio`  
`diagrams/design_archive/Pre-CPU/RV32I_Branch_PCCon_nextpcMUX.drawio.png`  

Decided to integrated the `next_pc` selection logic MUX in **PC Controller**.

- Misunderstood about jump target address. In diagram `RV32I_PCcon_Branch.drawio`, jump target is from alu_result and ex-imm (extended immediate value from Immediate Generator module) 

- Designed **Branch Logic** module 

## [2024.01.04.]
- The first draft version of RV32I37F Architecture designed
`diagrams/design_archive/Pre-CPU/FirsteverRV32Iown.drawio.png`
- PC Controller is now viewed as a module
- NZCV Flag signals was an input of Branch Logic from the output of ALU. 
(Removed since RISC-V doesn't require NZCV unlike ARM.)
(Main idea was from IDEC lecture about RISC-V CPU introduction and FPGA implementation by Y. W. Kim.)

## [2024.01.05.]
- Organized signal routing of Block Diagram.
`diagrams/design_archive/Pre-CPU/RV32I_OrganizedSignals_A4_Signed_B.drawio.png`
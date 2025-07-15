# Tutorials

The most efficient pathway to learn the processor design from scratch, we suggest following steps before the Development Log.

## Before getting started

This Processor design learning framework is based on **RISC-V RV32 ISA.**  
**We strongly recommend to check and read the** [Ratified specifications manual of RISC-V ISA](https://riscv.org/specifications/ratified/).  
Especially in Unprivileged Architecture manual, all of required information for designing the processor that meets the RISC-V ISA standard is fully desribed. 
 
Of course, the manual doesn't describe '*exactly how to*' design the processor from scratch, but even not knowing the methodology to start, this gives massive clues to infer the architecture to design. 

## Setup Environments

For Block Diagram (Blueprint of the Processor) Design : 
- [draw.io](https://draw.io/) (It also has [PC client version](https://www.drawio.com/blog/diagrams-offline); Visit their [GitHub](https://github.com/jgraph/drawio-desktop)!)

For RTL simulation only :
- [Icarus Verilog](https://bleyer.org/icarus/)
- [Surfer-Project](https://surfer-project.org/) (or [GTKwave](https://gtkwave.sourceforge.net/))

With FPGA Implementation and synthesis :
- Vivado 2024.2 (or other IDE)  

We've used cmd in Visual Studio Code terminal.  
Upper suggested environments are same as our development environment.  
You can use any other programs but note that the conversion tutorial to other environment is not provided.  

# Learn Architecture Design

0. Select which architecture you want to learn (We recommend to start with 37F base architecture. )
1. **Open Architecture Block Diagram**  
Open 37F block diagram design located at `documents/diagrams`.  
(We recommend to open with draw.io rather than `.png`, `.pdf`. It's way easier to track the signal's source and destination just by clicking the signal. )  

2. **See Architecture's Specification**  
37F Architecture's specification is located at `documents/theories_and_logics/modules_and_signals`. Its name is `Architecture_Specifications.md`(e.g. 37F_Specifications.md).  

3. **Check Instruction Datapath**  
Check the datapath that corresponds to instruction of which architecture support (e.g. beq, addi, lui... etc.). The intended datapath track file is located at `documents/theories_and_logics/modules_and_signals/37_Architecture/`, named `37F_instruction_datapaths.md`.  

4. **Fine module logic description and interpret the core architecture**  
Find each module's logic description document named `[Architecture Name]modulename.md`. and **try to interpret the core architecture behavior** with it.

5. **Now it's your turn!**  
To additionally design the function that you want processor to perform, specify the **logics you need**, and **abstractly design the module and signals** that you need for function.  
As you can find it in `development_log.md`, each module has been designed through these type of thoughts. Let's give an example with 37F architecture. 

## 37F Architecture Module Design Process

## Front-end

1. **Specify the function**  
Let's design core to **execute the ADD instruction in RISC-V RV32I**!  
In assmebly, it's used as `add rd, rs1, rs2`  
In mnemonics, `ADD → R[rd] = R[rs1] + R[rs2]`  
<sup> R[rd] means Register value that's in `rd` address of Register.  
e.g. ) R[x22] = Value of a register that is addressed in 22.  
ADD x2 x12 x6 = x2 ← x12 + x6

|funct7|rs2|rs1|funct3|rd|opcode|
|:-------:|:-----:|:-----:|:---:|:-----:|:-------:|
|31 - 25|24 - 20|19 - 15|14 - 12|11 - 7|6 - 0|
|0000000|register source 2|register source 1|001|register destination|0110011|

`opcode` specifies the *Type of Instruction* and `funct3` decides which R-Type instruction is it. 

2. **Specify the logics and abstractely design the module**  
ADD is an arithmetic calculation.  
-> This should be done in ALU.  
--> ALU should be capable of noticing the ADD operation.  
---> There is lot's of operation that should ALU execute. Let's make an encoded signal to recongnize which type of operation is needed in ALU.  
----> There should be an decoder unit for ALU opcode generation which should receiving the opcode and funct3, funct7 sinals for recognition. = **ALU Controller** module design  

---
#### This is where our design philosophy comes in.
Why ALU Controller module is separately needed? Can't it be integrated in **Control Unit**?  
Sure. It's possible, and we've considered about it. Since one of our philosophy to core design is that 
> Define clear module roles with focused logic to enhance modularity.  

we've decided to separte the **ALU Controller** from **Control Unit**. The main reason was that this modular methodology will enhance the intuitiveness for the processor design understanding, and increase maintainability for logic extension and modification. 

---

--> According to RISC-V Manual, add should be done with two source register values which is respectively the register value in `rs1`, `rs2` address, and the result should be written to the register in `rd` address.  
---> We need Register File, Register File should get two register address value and return it together.  = 2 read address input port for **Register File** module. 

The instruction fetch and Control Unit's conceptual approach is well explained on Computer Architecture textbooks and courses. 
(We recommend [Computer Organization and Design by David. A. Patterson](https://www.amazon.com/Computer-Organization-Design-RISC-V-Architecture/dp/0128203315). This repository's processor design methodology is heavily affected by this book.)

--> The result of ALU should be written at Register which is addressed in `rd` bit field of instruction.  
---> Register File should get write address not just read address. = 1 write address input port for **Register File**  
<sup>Why not re-use the address input port for reading? The logic becomes too complicated and lowers intuitiveness of core design.  </sup>  
----> ALU's result signal is not the only signal of Register File's Write Data source. = **Reg_WD_MUX**

With same methodology, CSR File in 43F arch, Trap Controller, Exception Detector in 46F architecture is designed and implemented. 

## Back-end

Based on **Front-end** design

# Run Simulation with Designed Architecture


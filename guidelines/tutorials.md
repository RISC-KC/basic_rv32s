# 📝 Tutorials

This document describes how to utilize the resources in basic_RV32s repository, enabling users to learn RISC-V processor design efficiently using our framework.

## 📚 Before getting started

This Processor design learning framework is based on **RISC-V RV32I ISA.**  
**We strongly recommend to check and read the** [Ratified specifications manual of RISC-V ISA](https://riscv.org/specifications/ratified/).  
Especially in Unprivileged Architecture manual, all of required information for designing the processor that meets the RISC-V ISA standard is fully described. 
 
Of course, the manual doesn't describe '*exactly how to*' design the processor from scratch, but even not knowing the methodology to start, this gives massive clues to infer the architecture to design. 

Most of our base architecture design's conceptual approach is well explained on Computer Architecture textbooks and courses. 
(We recommend [Computer Organization and Design by David. A. Patterson](https://www.amazon.com/Computer-Organization-Design-RISC-V-Architecture/dp/0128203315). This repository's processor design methodology is **heavily affected by this book**.)

## ⚖️ Design Philosophy

basic_RV32s follows **three principles** to guide an **intuitive and efficient hardware architecture design**.  
- Streamline I/O signals to reduce complexity.
- Define clear module roles with focused logic to enhance modularity.
- Prioritize performance improvements even when conflicting with the above principles, with effectiveness validated through testing.

These principles definitely helped our development process.  
It made our architecture design much more intuitive and easier to structure.

You don't have to follow our philosophy but it is clear that if you set your design philosophy for architecture design, it will reduce a lot of time while making decisions in some situations.

## 💻 Setup Environments

For Block Diagram (Blueprint of the Processor) Design : 
- [draw.io](https://draw.io/) (It also has [PC client version](https://www.drawio.com/blog/diagrams-offline); Visit their [GitHub](https://github.com/jgraph/drawio-desktop)!)

For RTL simulation only :
- [Icarus Verilog](https://bleyer.org/icarus/)
- [Surfer-Project](https://surfer-project.org/) (or [GTKwave](https://gtkwave.sourceforge.net/))

With FPGA Implementation and synthesis :
- Vivado 2024.2 (or other IDE)

If simulating the C program : 
- [RISC-V GNU GCC Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)  
  Make sure to configure the toolchain build with one of the following commands.
  ```
  ./configure --with-multilib-generator="rv32i-ilp32--"
  or
  ./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32
  make linux
  ```

We've used cmd in **Visual Studio Code** terminal.  
The above suggested environments are same as our development environment.  
You can use any other programs but note that the conversion tutorial to other environment is not provided.  

# 📐 Learn Architecture Design

0. Select which architecture you want to learn (We recommend to start with 37F base architecture. )
1. **Open Architecture Block Diagram**  
Open 37F block diagram design located at `documents/diagrams`.  
(We recommend to open with draw.io rather than `.png`, `.pdf`. It's way easier to track the signal's source and destination just by clicking the signal. )  

2. **See Architecture's Specification**  
37F Architecture's specification is located at `documents/theories_and_logics/modules_and_signals`. Its name is `Architecture_Specifications.md`(e.g. 37F_Specifications.md).  

3. **Check Instruction Datapath**  
Check the datapath that corresponds to instruction that the architecture supports (e.g. beq, addi, lui... etc.). The intended datapath track file is located at `documents/theories_and_logics/modules_and_signals/37_Architecture/`, named `37F_instruction_datapaths.md`.  

4. **Find module logic description and interpret the core architecture**  
Find each module's logic description document named `[Architecture Name]modulename.md`. and **try to interpret the core architecture behavior** with it.

5. **Now it's your turn!**  
To additionally design the function that you want processor to perform, specify the **logics you need**, and **abstractly design the module and signals** that you need for function.  
As you can find it in `development_log.md`, each module has been designed through these types of thoughts. Let's give an example with 37F architecture. 

## 📖 37F Architecture Module Design Process

## ✏️ Front-end

1. **Specify the function**  
Let's design core to **execute the SUB instruction in RISC-V RV32I**!  
In assembly, it's used as `sub rd, rs1, rs2`  
In mnemonics, `SUB → R[rd] = R[rs1] - R[rs2]`  
<sup> R[rd] means Register value that's in `rd` address of Register.  
e.g. ) R[x22] = Value of a register that is addressed in 22.  
SUB x2 x12 x6 = x2 ← x12 - x6

|funct7|rs2|rs1|funct3|rd|opcode|
|:-------:|:-----:|:-----:|:---:|:-----:|:-------:|
|31 - 25|24 - 20|19 - 15|14 - 12|11 - 7|6 - 0|
|0100000|register source 2|register source 1|000|register destination|0110011|

`opcode` specifies the *Type of Instruction* and `funct3`, `funct7` decides which R-Type instruction is it. 

2. **Specify the logics and abstractly design the module**  
SUB is an arithmetic calculation.  
-> This should be done in ALU.  
--> ALU should be capable of noticing the SUB operation.  
---> There are lots of operations that the ALU should execute. Let's make an encoded signal to recognize which type of operation is needed in ALU.  
----> There should be an decoder unit for ALU opcode generation which should receive the opcode and funct3, funct7 signals to recognize. = **ALU Controller** module design  

---
#### 🔖 This is where our design philosophy comes in.
Why ALU Controller module is separately needed? Can't it be integrated in **Control Unit**?  
Sure. It's possible, and we've considered about it. Since one of our philosophy to core design is that 
> Define clear module roles with focused logic to enhance modularity.  

we've decided to separate the **ALU Controller** from **Control Unit**. The main reason was that this modular methodology will enhance the intuitiveness for the processor design understanding, and increase maintainability for logic extension and modification. 

---

--> According to RISC-V Manual, sub should be done with two source register values which is respectively the register value in `rs1`, `rs2` address, and the result should be written to the register in `rd` address.  
---> We need Register File, Register File should get two register address value and return it together.  = 2 read address input port for **Register File** module. 

The instruction fetch and Control Unit's conceptual approach is well explained on Computer Architecture textbooks and courses. 
(We recommend [Computer Organization and Design by David. A. Patterson](https://www.amazon.com/Computer-Organization-Design-RISC-V-Architecture/dp/0128203315). This repository's processor design methodology is heavily affected by this book.)

--> The result of ALU should be written at Register which is addressed in `rd` bit field of instruction.  
---> Register File should get write address not just read address. = 1 write address input port for **Register File**  
<sup>Why not re-use the address input port for reading? The logic becomes too complicated and lowers intuitiveness of core design.  </sup>  
----> ALU's result signal is not the only signal of Register File's Write Data source. = **Reg_WD_MUX**

With same methodology, CSR File in 43F arch, Trap Controller, Exception Detector in 46F architecture is designed and implemented. 

## ⌨️ Back-end

1. **HDL code writing**  
Based on **Front-end** design, next step is to **make those block designs to actual RTL code with HDL**(Hardware Description Language; *VerilogHDL*, *VHDL*)  

2. **Debugging with testbenches**  
After the first HDL code is written, the testbench simulation results can be debugged with waveform viewer programs such as **GTKwave** and **Surfer-project** . 

3. **Waveform Debugging**  
Debug the signals by comparing the intended behaviors and values with logic modules and checking if it's correct or not.  
Through the Back-end debugging process, we can find the **additional logics that is needed** but couldn't think of it at the start, or the **incorrectly designed logics** that should be revised.  

4. **Commit the changes to Block Diagram**  
The changes of the architecture should be committed to the block diagram as well. When the processor's logic and scale is getting bigger, there's a certain limit to remember all the architecture just in mind.

**basic_RV32s**' architectures were designed by these processes.  
> A processor design methodology that abstracts conceptual design and implementation to synthesizable RTL code.  

This methodology is our basic pathway to design the processor.

# 📊 Run Simulation with Designed Architecture

To run the simulation with designed architecture, there are two ways to make core run.  

1. 📑 **Modify the instructions in Instruction Memory**
   Implement written instructions in Instruction Memory module with _hexadecimal_ or _binary_ encoded RISC-V RV32I assembly instruction.
   Default core design includes one of each instructions of RISC-V RV32I ISA. You can simply modify those as you want, and run the simulation to check the waveform.
   
2. 🖨 **Modify the $readmemh target file**
   Change the $readmemh target hex/binary file which has compiled with RISC-V GNU GCC toolchain.  
   You can run any C program by compiling the C code with RISC-V GCC toolchain. But there are several settings that you should do before implementing it.  
   - Linker script.  
     Our processor uses 0x0000_0000 as ROM address, 0x1000_0000 as RAM address.  
     Make sure the linker script of the compile's memory map is same as following.  
     ```
     ...
     MEMORY
     {
         ROM (rx) : ORIGIN = 0x00000000, LENGTH = 64K
         RAM (rw) : ORIGIN = 0x10000000, LENGTH = 32K
     }
     ...
     ```

If you are not a beginner like I was, you can just modify these memory settings.  
We're going to work about easy C program import on SoC soon.  

---
Tutorials will continue to be updated or expanded as necessary.

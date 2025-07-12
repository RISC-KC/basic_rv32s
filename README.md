# basic_RV32s

<img width="900" height="342" alt="basic_rv32s_logo" src="https://github.com/user-attachments/assets/e339df67-0331-42f9-a235-73147ff81225" />

basic_RV32s is a **framework for learning Processor design with RISC-V** ISA (Instruction Set Architecture).  
It provides step-by-step guideline for designing processor **from single-cycle processor to 5 Stage Pipelined with Exception Handling**.  

## Introduction

KHWL
> I've always wondered how to make CPU and I wanted to make my own.  
> Although it was a far dream for me, I've gave it a try when I was serving the Korean Military duty. And made the result pretty legitimatley.  
<img width="6984" height="4964" alt="250711 RV32I46F_5SP_Final" src="https://github.com/user-attachments/assets/e6b9f3b9-f1b1-4859-8d48-7258575c4002"/>
<sub> Signal-Level Block Diagram of RV32I46F_5SP Core </sub>
<br>
<br>
While designing the Architecture of processor, I've felt the gap between the theories and actual implementations at certain point and it took a long way to discover the problem and resolve it.  

So I decided to make this **project for academic / instructional purpose for anyone who wants to make & design the processor from scratch** can easily dive into it.  
I've documented all the **development progresses, train of thoughts, debug logs**. I assume this would work as a **mistake notebook or a guideline for beginners of RISC-V**, Processor design field.  
Since most of lectures I've heard were using Verilog, all of RTL codes we provide are written in pure **Verilog**. 

### Key Features

- 📦 What's in it? : CPU + SoC + **framework for learning**.
- ⌨️ Written in pure **Verilog 2001**.
- 🧱 **Modular design for each core design**, enhancing the scalability of the architecture and helping understanding.
- 🔌 **FPGA** Synthesizable sources.
- 📚 **Fully documentized** for **easy hand-on learning** for beginners. ( Repository's purpose )  
  (develop logs, debug traces, train of thoughts, rationales, module logic explainations, signal-level diagrams... etc.)

### Table of Contents

- [Introduction](https://github.com/RISC-KC/basic_rv32s/blob/docs/README.md#introduction)
- [Branches & Directories](https://github.com/RISC-KC/basic_rv32s/blob/docs/README.md#branches--directories)
- [About Guidelines](https://github.com/RISC-KC/basic_rv32s/blob/docs/README.md#about-guidelines)
- [Arhictectures and Specifications](https://github.com/RISC-KC/basic_rv32s/blob/docs/README.md#architectures-and-specifications)
- [FPGA Implementation Results](https://github.com/RISC-KC/basic_rv32s/blob/docs/README.md#fpga-implementation-results)
- [Getting Started](https://github.com/RISC-KC/basic_rv32s/blob/docs/README.md#getting-started)
- Contributions
- License  

-----

## Branches & Directories

### 📌Branches

- `main`  
  Latest released version of the repository.
- `develop`  
  Current ongoing version of the repository.  
  This branch only revises the RTL source code in **modules/** and **testbenches/**.
- `docs`  
  Revises the **documents/** directory.
  
### 📌Directories

### documents/  

Documentations of baisc_rv32s.  

- **/diagrams/**  
Processor design's signal-level block diagrams, Including archived legacies.  
PDF, PNG, drawio files.  

- **/project_devlog/**  
The raw development logs of main contributors.  

- **/theories_and_logics/**  
Description of each designed architecture down to logic block's signal and logics. 

- **/guidelines/**  
Annotated RTL sources, tutorials, organized devlogs, debug logs.  

- **/references/**  
References that helped.  

### modules/

clean RTL source code of actual synthesized core.

### testbenches/

testbench RTL code of each modules ( top module, module instances )  
result with `.vvp` and waveform `.vcd` files included.

---

## About Guidelines

**basic_RV32s** follows three design principles to guide an intuitive and efficient hardware architecture design.
1. Streamline I/O signals to reduce complextiy.
2. Define clear module roles with focused logic to enhance modularity.
3. Priortize performance improvements even when conflicting with the above principles, with effectiveness validated through testing.  

In directory `documents/guidelines/`, we provide comprehensive resources for learning and understanding the design of processors in **basic_RV32s**.  
- 🗃 **Incremental architecture documentation**  
  presenting each evolution with design decisions.
- 📑 **Dual-format verilog RTL source code**  
  offering annotated version from clean source code.
- 📖 **Development logs**  
  organized version based on raw devlogs located in `documents/project_devlog/`.
- 🔍 **Debug traces**, problem-solving approaches.
- 📜 **Design iteration histories**
- 🔬 **Verification methodologies**
  providing UART-based debugging and **Dhrystone** benchmark setup on **FPGA**.  

The Development logs might possibily not match with the current design, if there's some certain missing logs which is needed, you may request for it.  
<sub>Un-organized raw devlog in `documents/project_devlog` contains more imformations than the organized logs in `/guidelines`/ but even non-relative words are included. Also, project's developers are from **Republic of Korea**. All the raw devlogs are written originally in **Korean**. Please be aware of these. </sub>

In architecture documentations, we've included the **specifications of all modules** with **Signal-level Block Diagram**.
The I/O signals of each modules, the purpose of the modules, logic behavior.
This contains not only the top CPU module, but **all modules that constructs the processor**.

Since the last processor design of **basic_RV32s** is synthesized and implemented on **FPGA**, we also provide a project file so everyone can modify and implement the suggested core design.  

This project was done in limited environment (serving military duty, only 1 FPGA board, 2 developers, approx. 2 hours per day). We hope some other implementation reports. Please contact us if you have already. 📡  

## Architectures and Specifications  

**basic_RV32s** provides 4 RISC-V core designs and 1 SoC design for FPGA verification. 
|Processor|ISA|Added modules|note|
|-----|:---:|---|---|
|RV32I37F|RV32I<sup>a</sup>|-|Base single-cycle architecture|
|RV32I43F|RV32I<sup>a</sup>  +Zicsr|CSR File|supports Zicsr 6 instructions|
|RV32I46F|RV32I<sup>b</sup>  +Zicsr|Exception Detector, Trap Controller, MUXs|supports ECALL, EBREAK|
|RV32I46F_5SP|RV32I<sup>b</sup>  +Zicsr|2-bit FSM Dynamic Branch Predictor, Hazard Unit, Forward Unit|5-Stage Pipelined|
|46F5SP_SoC<sup>*</sup>|-|Button Controller, Debug UART Controller, UART TX, Benchmark Controller|GPIO, UART implemented SoC for Dhrystone|  

<sup>a</sup> Partial RV32I which excluded ECALL, EBREAK, FENCE, FENCE.TSO, PAUSE instructions.  
<sup>b</sup> Partial RV32I which excluded FENCE, FENCE.TSO, PAUSE instructions.  
<sup>*</sup> 46F5SP_SoC is made for debugging and running **Dhrystone** benchmark the core design.  
It utilizes **FPGA** on-board GPIOs such as LEDs, buttons and UART.  
  
  <img width="1755" height="1240" alt="basic_rv32s drawio (2)" src="https://github.com/user-attachments/assets/5f0c7fea-dfc0-4212-ac4b-5125d8859ae6" />
<sub> Architectures of basic_RV32s' processors </sub>

### RV32I37F



## FPGA Implementation Results

**RV32I46F_5SP** core implemented **46F5SP_SoC** was implemented on **Digilent Nexys Video** board (**AMD Xilinx Artix-7 XC7A200T FPGA**).  
FPGA Synthesis and Implementations were done in **Vivado 2024.2**.  
- 20ns (50 MHz) timing constraints
- Synthesis Strategy : Flow_PerfOptimized_high
- Implementation Strategy : Performance_Explore

Single-Cycle processors' FPGA implementation is not done yet. It will be added soon after the military duty ends. (Around Sep. 2025)
Table below is FPGA implementation results.  

|Processor|LUTs|FFs|BRAMs|DSPs|Fmax|DMIPS/MHz|
|-----|:---:|:---:|:---:|:---:|:---:|:---:|
|46F5SP_SoC|11,660<sup>*</sup>|2,383|0<sup>**</sup>|0|50 MHz|1.09|
|RV32I46F_5SP|3,010|2,383|0<sup>**</sup>|0|``|``|
|RV32I46F|-|-|-|-|-|-|
|RV32I43F|-|-|-|-|-|-|
|RV32I37F|-|-|-|-|-|-|

<sup>* **Dhrystone** benchmark and **Trap Handler** hard coded using readmemh. Resource varies depends on the program in memories. This will soon be standardized.</sup>  
<sup>** All memories are inffered as **LUT-based distributed RAM**.</sup>  

---

## Getting Started

asdasd  

## Contribution

asdfasdf  

## Lisence

Copyleft.

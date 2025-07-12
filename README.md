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

- Introduction
- Branches & Directories
- About Guidelines
- Arhictectures and Specifications
- FPGA porting and Results
- Development Environment
- Getting Started
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

**/diagrams/**  
Processor design's signal-level block diagrams, Including archived legacies.  
PDF, PNG, drawio files.  

**/project_devlog/**  
The raw development logs of main contributors.  

**/theories_and_logics/**  
Description of each designed architecture down to logic block's signal and logics. 

**/guidelines/**  
Annotated RTL sources, tutorials, organized devlogs, debug logs.  

**/references/**  
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
- RV32I**37F** ( RV32I )
- RV32I**43F** ( RV32I + Zicsr )
- RV32I**46F** ( RV32I + Zicsr + ECALL, EBREAK )
- RV32I**46F_5SP** ( 5-Stage Pipeline version of RV32I46F )
* 46F5SP_SoC  ( RV32I46F_5SP + GPIO + UART + Benchmarks )  
  Made for debugging and running **Dhrystone** benchmark the core design.  
  It utilizes **FPGA** on-board GPIOs such as LEDs, buttons and UART.  

starts with **RV32I37F** which supports RV32I, RISC-V Base Integer set excluding EBREAK, ECALL, FENCE instructions.  
To verify the core IP design, we've made SoC design for FPGA implementation.

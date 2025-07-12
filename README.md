# basic_RV32s
<img width="900" height="342" alt="basic_rv32s_logo" src="https://github.com/user-attachments/assets/e339df67-0331-42f9-a235-73147ff81225" />

basic_RV32s is a **framework for learning Processor design with RISC-V** ISA (Instruction Set Architecture).  
It provides step-by-step guideline for designing processor **from single-cycle processor to 5 Stage Pipelined with Exception Handling**.  

## Introduction
I've always wondered how to make CPU and I wanted to make my own.  
Although it was a far dream for me, I've gave it a try when I was serving the Korean Military duty, and made the result pretty legitimatley.  
While designing the Architecture of processor, I've felt the gap between the theories and actual implementations at certain point and it took a long way to discover the problem and resolve it.  

So I decided to make this **project for academic / instructional purpose for anyone who wants to make & design the processor from scratch** can easily dive into it.
I've documented all the **development progresses, train of thoughts, debug logs**. I assume this would work as a **mistake notebook or a guideline for beginers of RISC-V**, Processor design field.  
Since most of lectures I've heard were using Verilog, all of RTL codes we provide are written in pure **Verilog**. 

### Key Features
- ❓ What's in it? : CPU + SoC + **framework for learning**.
- ⌨️ Written in pure **Verilog 2001**.
- 🧱 **Modular design for each core design**, enhancing the scalability of the architecture and helping understanding.
- 🔌 **FPGA** Synthesizable sources.
- 📚 **Fully documentized** for **easy hand-on learning** for beginners. ( Repository's purpose )  
  (develop logs, debug traces, train of thoughts, rationales, module logic explainations, signal-level diagrams... etc.)

### Table of Contents
- Introduction
- Branches & Directories
- How to use Guidelines
- Arhictectures and Specifications
- FPGA porting and Results
- Development Environment
- Getting Started
- Contributions
- License  

## Branches & Directories

### Branches
- `main`  
  lately released version of the repository.
- `develop`  
  currently ongoing version of the repository.
  this branch only revises the RTL source code in **modules/** and **testbenches/**.
- `docs`  
  revises the **documents/** directory.
-----
### Directories
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

## How to use Guidelines
WIP
----- Work In Progress -----
----- temp -----
It starts with **RV32I37F** which supports RV32I, RISC-V Base Integer set excluding EBREAK, ECALL, FENCE instructions.  
- RV32I**37F** ( RV32I )
- RV32I**43F** ( RV32I + Zicsr )
- RV32I**46F** ( RV32I + Zicsr + ECALL, EBREAK )
- RV32I**46F_5SP** ( 5-Stage Pipeline version of RV32I46F )


To verify the core IP design, we've made SoC design for FPGA implementation.
- 46F5SP_SoC  
  Made for debugging and running **Dhrystone** benchmark the core design.  
  It utilizes **FPGA** on-board GPIOs such as LEDs, buttons and UART.  

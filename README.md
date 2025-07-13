# basic_RV32s

<img width="900" height="342" alt="basic_rv32s_logo" src="https://github.com/user-attachments/assets/e339df67-0331-42f9-a235-73147ff81225" />

basic_RV32s is a **framework for learning Processor design with RISC-V RV32I** ISA (Instruction Set Architecture).  
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
- [Future Works](https://github.com/RISC-KC/basic_rv32s/blob/docs/README.md#future-works)  

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

Clean RTL source code of actual synthesized core.

### testbenches/

Testbench RTL code of each module ( top module, module instances )  
result with `.vvp` and waveform `.vcd` files included.

### fpga/

Vivado project files for FPGA synthesis and implementation.  
Contains such as `.xpr` `.xdc` files to import the whole project easily.  
Also, the project file includes clean RTL code without annotations. 

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
The I/O signals of each module, the purpose of the modules, logic behavior.
This contains not only the top CPU module, but **all modules that constructs the processor**.

Since the last processor design of **basic_RV32s** is synthesized and implemented on **FPGA**, we also provide a project file so everyone can modify and implement the suggested core design.  

This project was done in limited environment (serving military duty, only 1 FPGA board, 2 developers, approx. 2 hours per day). We hope some other implementation reports. Please contact us if you have already. 📡  

---

## Architectures and Specifications  

### Naming conventions

RV32I43F = **RV32I** that supports **43** instructions. **Final**(latest) version.  
RV32I46F_5SP = **RV32I** that supports **46** instructions. **Final**(latest) version. **5-Stage Pipelined** architecture.  

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

- **ISA**: RISC-V RV32I v2.1  
  (except fence, fence.tso, pause, ecall, ebreak = total 37 instructions)  
- Modules and Signals table
  |Module name|Acronyms|Inputs|Outputs|Signals|
  |:---|:---:|:---|:---|:---:|
  |**Program Control**|
  |Program Counter|PC|next_pc, clk, reset|pc|3+1=4|  
  |PC Controlelr|PCC|jump, branch_taken, pc, imm, jump_target|next_pc|5+1=6|
  |PC Aligner|-|raw_next_pc|next_pc|1+1=2|
  |**Memory Units**|
  |Instruction Memory|IM|pc|instruction|1+1=2|
  |Instruction Decoder|ID|instruction|opcode, funct3, funct7, rs1, rs2, rd, raw_imm|1+7=8|
  |Register File|Reg|clk, read_reg1, read_reg2, write_reg, write_data, write_enable|read_data1, read_data2|6+2=8|
  |Data Memory|DM|clk, write_enable, address, write_data, write_mask|read_data|5+1=6|
  |**Controls**|
  |Control Unit|CU|opcode, funct3|jump, branch, alu_src_A_select, alu_src_B_select, register_file_write, register_file_write_data_select, memory_read, memory_write|2+8=10|
  |ALU Controller|-|opcode, funct3, funct7_5, imm_10|alu_op|4+1=5|
  |**Executions**|
  |Arithmetic Logic Unit|ALU|srcA, srcB, alu_op|alu_result, alu_zero|3+2=5|
  |Branch Logic|-|branch, alu_zero, funct3|branch_taken|3+1=4|
  |Byte Enable Logic|BE_Logic|memory_read, memory_write, funct3, register_file_read_data, data_memory_read_data, address|register_file_write_data, data_memory_write_data, write_mask|6+3=9|
  |Immediate Generator|imm_gen|opcode, raw_imm|imm|2+1=3|
  |PC plus 4|-|pc|pc_plus_4|1+1=2|
  |**MUXs**|
  |ALUsrcMUX_A|-|read_data1, pc, alu_src_A_select|srcA|  
  |ALUsrcMUX_B|-|read_data2, imm, alu_src_B_select|srcB|
  |Reg_WD_MUX|-|byte_enable_logic_register_write_data, alu_result, imm, pc_plus_4|register_file_write_data|

- Total 14 Modules, 74 Signals.

⚠️ Note: Misaligned address access is handled as zero-ing the low 2-bits from address. 

For each module's logic description, go to `docs/modules_and_signals/` for more imformation.
**Each module has its own logic behavior documentations which includes I/O signals, Logics and Note.**

### RV32I43F

- **ISA**: RISC-V RV32I v2.1  + **Zicsr** v2.0
  (except fence, fence.tso, pause, ecall, ebreak = total 37 instructions)  
- Modules and Signals table
  |Module name|Acronyms|Inputs|Outputs|Signals|
  |:---|:---:|:---|:---|:---:|
  |**Program Control**|
  |Program Counter|PC|next_pc, clk, reset|pc|3+1=4|  
  |PC Controlelr|PCC|jump, branch_taken, pc, imm, jump_target|next_pc|5+1=6|
  |PC Aligner|-|raw_next_pc|next_pc|1+1=2|
  |**Memory Units**|
  |Instruction Memory|IM|pc|instruction|1+1=2|
  |Instruction Decoder|ID|instruction|opcode, funct3, funct7, rs1, rs2, rd, raw_imm|1+7=8|
  |Register File|Reg|clk, read_reg1, read_reg2, write_reg, write_data, write_enable|read_data1, read_data2|6+2=8|
  |Data Memory|DM|clk, write_enable, address, write_data, write_mask|read_data|5+1=6|
  |**CSR File**|-|**clk, reset, csr_write_enable, csr_address, csr_write_data**|**csr_read_out**|5+1=6|
  |**Controls**|
  |**Control Unit**|CU|opcode, funct3|jump, branch, alu_src_A_select, alu_src_B_select, register_file_write, register_file_write_data_select, memory_read, memory_write, **csr_write_enable**|2+9=11|
  |ALU Controller|-|opcode, funct3, funct7_5, imm_10|alu_op|4+1=5|
  |**Executions**|
  |Arithmetic Logic Unit|ALU|srcA, srcB, alu_op|alu_result, alu_zero|3+2=5|
  |Branch Logic|-|branch, alu_zero, funct3|branch_taken|3+1=4|
  |Byte Enable Logic|BE_Logic|memory_read, memory_write, funct3, register_file_read_data, data_memory_read_data, address|register_file_write_data, data_memory_write_data, write_mask|6+3=9|
  |Immediate Generator|imm_gen|opcode, raw_imm|imm|2+1=3|
  |PC plus 4|-|pc|pc_plus_4|1+1=2|
  |**MUXs**|
  |**ALUsrcMUX_A**|-|read_data1, pc, **rs1**, alu_src_A_select|srcA|  
  |**ALUsrcMUX_B**|-|read_data2, imm, **csr_read_data**, alu_src_B_select|srcB|
  |**Reg_WD_MUX**|-|byte_enable_logic_register_write_data, alu_result, imm, pc_plus_4, **csr_read_data**|register_file_write_data|

- Total 15 Modules, 81 Signals.

Supported CSRs:
|CSR|address|Read-Only|WLRL, WARL|
|:---|:---|:---:|:---:|
|mvendorid|F11|O|-|
|marchid|F12|O|-|
|mimpid|F13|O|-|
|mhartid|F14|O|-|
|mstatus|300|-|-|
|misa|301|-|WARL|
|mtvec|305|-|WARL|
|mepc|341|-|WARL|
|mcause|342|-|WLRL|


⚠️ Notes
- Misaligned address access is handled as zero-ing the low 2-bits from address.
- In RV32I46F_5SP, the CSR logics are changed. For executing the trap and exceptions during the pipeline, the address signal separated to read address and write address input.
- `mhartid` is some dummy value for read-only CSR design test. No multi-hart architecture is available now.

For each module's logic description, go to `docs/modules_and_signals/` for more imformation.
**Each module has its own logic behavior documentations which includes I/O signals, Logics and Note.**

### RV32I46F

Work In Progress

### RV32I46F_5SP

Work In Progress

---

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

Various performance benchmark (such as coremark) will be added soon.  
We assume that the processor can reach higher clock speed and performance, but at the moment we couldn't keep the development in touch due to personal schedule (military duty, school admission).  
This will be worked soon also.

---

## Getting Started

**basic_RV32s** can be simply cloned by using
```git
$ git clone https://github.com/RISC-KC/basic_rv32s.git
```

### 🔎 Core behavior Simulations  

Required : Icarus Verilog for using `./test.sh` command.

```git
$ cd [source_code_directory]
$ ./test.sh RV32I37F.v RV32I37F_tb.v
```
This would run testbench as coded in `testbenches/`.  
The result of the simulation `.vvp` is generated in `testbenches/results/`.  
`.vcd` waveform result is generated in `testbenches/results/waveforms/`.  

Waveform can be viewed **GTKwave** or [Surfer-project](https://surfer-project.org/).  

### 🎛 FPGA implementation  

- Vivado environment (tested on 2024.2)  
  - In `fpga/` directory, select architecture source directory which you want to implement on your FPGA. (37F, 43F, 46F, 46F_5SP)  
    Launch Vivado and import project file which you have selected.

  - Current FPGA implementation's SoC can be applied to 43F, 46F, 46F5SP architecture. (release v1.0.0)   
    37F Architecture needs additional logics to replace the existing `mcycle` and `minstret` CSR to implement on **46F5SP_SoC** since it doesn't have CSR module.  
  
  - The RTL source code of **RV32I46F_5SP** in `fpga/` directory has `clk_enable` signal for sequential execution debugging.  
    If you need only the core IP itself, use the source in `modules/` directory.  

- Other IDE  
  You can manually import the sources located in `modules/` directory.  

### 📥 Setup RV32I RISC-V GNU toolchain with GCC.
Follow this guideline provided by official RISC-V github.
https://github.com/riscv-collab/riscv-gnu-toolchain

Make sure to configure the toolchain build with one of the following commands.
```
./configure --with-multilib-generator="rv32i-ilp32--"
or
./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32
make linux
```

### ⚠️ Notice

**Default program** is some RV32I instructions which is integrated in **Insturction Memory**.  
If you are going to simulate the **C program** which has been compiled through **RISC-V GNU GCC toolchain; RV32I**, the memory configuration is needed.  
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

If you are not beginner as I am, you can just modify this memory settings.  
Since the actual FPGA implementation is only done in **RV32I46F_5SP**, we suggest to use 46F_5SP architecture for C compiled program simulation.  

We'll going to work about easy C program import on SoC soon.  

---

## Future Works

1. issue resolvations
2. Single-Cycle core FPGA implementation and Evaluation
3. Additional benchmarks (Coremark, RISC-V ISA tests)
4. Standardized FPGA synthesis resource measurement
5. Optimize critical paths and reach higher clock speed and performance
6. Easy method for running C program on SoC

# basic_RV32s

<img width="900" height="342" alt="basic_rv32s_logo" src="https://github.com/user-attachments/assets/e339df67-0331-42f9-a235-73147ff81225" />

basic_RV32s is a **framework for learning Processor design with RISC-V RV32I** ISA (Instruction Set Architecture).  
It provides step-by-step guideline for designing processor **from single-cycle processor to 5 Stage Pipelined with Exception Handling**.  

## Introduction

KHWL
> I've always wondered how to make CPU and I wanted to make my own.  
> Although it was a far dream for me, I gave it a try when I was serving the Korean Military duty. And made the result pretty legitimately.  
<img width="6984" height="4952" alt="250723 RV32I46F_5SP_Final_R10" src="https://github.com/user-attachments/assets/d9556432-da64-4af3-8c5e-97f013c5cc0d" />
<sup> Signal-Level Block Diagram of RV32I46F_5SP Core </sup>
<br>
<br>
While designing the Architecture of processor, I've felt the gap between the theories and actual implementations at certain point and it took a long way to discover the problem and resolve it.  

So I decided to make this **project for academic/instructional purposes so that anyone who wants to make & design processors from scratch** can easily dive into it.  
I've documented all the **development progresses, train of thoughts, debug logs**. I assume this would work as a **mistake notebook or a guideline for RISC-V beginners**, Processor design field.  
Since most of lectures I've heard were using Verilog, all of RTL codes we provide are written in pure **Verilog**.  

_"A guideline for processor designing from scratch for begginer that has made by an actual beginner."_  

### Key Features

- 📦 What's in it? : CPU + SoC + **framework for learning**.
- ⌨️ Written in pure **Verilog 2001**.
- 🧱 **Modular design for each core design**, enhancing the scalability of the architecture and helping understanding.
- 🔌 **FPGA** Synthesizable sources.
- 📚 **Fully documentized** for **easy hand-on learning** for beginners. ( Repository's purpose )  
  (develop logs, debug traces, train of thoughts, rationales, module logic explainations, signal-level diagrams... etc.)

### Quick Start
- 📕 [Tutorials](https://github.com/RISC-KC/basic_rv32s/blob/main/guidelines/tutorials.md)  
  Architecture Design? How to use this repository? Let's get started.
- 📊 [Diagrams](https://github.com/RISC-KC/basic_rv32s/blob/main/documents/diagrams)  
  Processor architecture design block diagrams including the draft files.
- 📜 [Devlogs](https://github.com/RISC-KC/basic_rv32s/blob/main/guidelines/development_log.md)  
  Want to find out how did we made this processor? Here's the footprints of it.

### Table of Contents

- [Introduction](https://github.com/RISC-KC/basic_rv32s?tab=readme-ov-file#introduction)  
- [Branches & Directories](https://github.com/RISC-KC/basic_rv32s?tab=readme-ov-file#branches--directories)  
- [About Guidelines](https://github.com/RISC-KC/basic_rv32s?tab=readme-ov-file#about-guidelines)  
- [Architectures and Specifications](https://github.com/RISC-KC/basic_rv32s?tab=readme-ov-file#architectures-and-specifications)  
- [FPGA Implementation Results & Performance Evaluation](https://github.com/RISC-KC/basic_rv32s?tab=readme-ov-file#fpga-implementation-results)  
- [Getting Started](https://github.com/RISC-KC/basic_rv32s?tab=readme-ov-file#getting-started)  
- [Future Works](https://github.com/RISC-KC/basic_rv32s?tab=readme-ov-file#future-works)  

-----

## Branches & Directories

### 📌 Branches

- `main`  
  Latest released version of the repository.
- `develop`  
  Current ongoing version of the repository.  
  This branch only revises the RTL source code in **modules/** and **testbenches/**.
- `docs`  
  Revises the **documents/** directory.
  
### 📌 Directories

- 🗂 **Documents**
  - **/diagrams**  
Processor design's signal-level block diagrams, Including archived legacies.  
PDF, PNG, drawio files.  

  - **/guidelines**  
Annotated RTL sources, tutorials: processor design methodologies, organized devlogs, debug logs.  
    - **/architecture_logics**  
Description of each designed architecture down to logic block's signal and logics.  
    - **/annotated_rtl**  
Annotated verilog RTL source code about each module designs for hands-on learning.

  - /archives  
archived architecture designs, documents... etc.  

  - /project_devlog  
The raw development logs of main contributors.  

  - /references  
References that helped.  

- 💾 **Sources**
  - **/modules**  
Clean RTL source code of actual synthesized core.  

  - **/testbenches**  
Testbench RTL code of each module ( top module, module instances )  
result with `.vvp` and waveform `.vcd` files included.  

  - **/fpga**  
Vivado project files for FPGA synthesis and implementation.  
Contains such as `.xpr` `.xdc` files to import the whole project easily.  
Also, the project file includes clean RTL code without annotations. 

---

## About Guidelines

**basic_RV32s** follows three design principles to guide an intuitive and efficient hardware architecture design.
1. Streamline I/O signals to reduce complextiy.
2. Define clear module roles with focused logic to enhance modularity.
3. Prioritize performance improvements even when conflicting with the above principles, with effectiveness validated through testing.  

In directory `guidelines/`, we provide comprehensive resources for learning and understanding the design of processors in **basic_RV32s**.  
- 🗃 **Incremental architecture documentation**  
  & 📜 **Design iteration histories**  
  presenting each evolution with design decisions.
- 📑 **Dual-format verilog RTL source code**  
  offering annotated version from clean source code.
- 📖 **Development logs, Debug traces**  
  organized version based on raw devlogs located in `documents/project_devlog/` with problem-solving approaches.
- 🔬 **Verification methodologies**
  providing UART-based debugging and **Dhrystone** benchmark setup on **FPGA**.  

The Development logs might possibly not match with the current design, if there's some certain missing logs which is needed, you may request for it.  
<sub>Un-organized raw devlog in `documents/project_devlog` contains more information than the organized logs in `guidelines`/ but even non-relative words are included. Also, project's developers are from **Republic of Korea**. All the raw devlogs are written originally in **Korean**. Please be aware of these. </sub>

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
  
  <img width="7016" height="4956" alt="250723_basic_rv32s_simplified" src="https://github.com/user-attachments/assets/bd08682a-5a99-41d9-8d54-94d5360e9e80" />
<sub> Architectures of basic_RV32s' processors </sub>

### RV32I37F

- **ISA**: RISC-V RV32I v2.1  
  (except fence, fence.tso, pause, ecall, ebreak = total 37 instructions)  
- Total 14 Modules, 74 Signals.

  <details>
  <summary>Click to view Modules and Signals table</summary> 

  |Module name|Acronyms|Inputs|Outputs|Signals|
  |:---|:---:|:---|:---|:---:|
  |**Program Control**|
  |Program Counter|PC|next_pc, clk, reset|pc|3+1=4|  
  |PC Controller|PCC|jump, branch_taken, pc, imm, jump_target|next_pc|5+1=6|
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
  </details>
  


⚠️ Note: Misaligned address access is handled as zeroing the low 2-bits from address. 

For each module's logic description, go to `documents/modules_and_signals/` for more information.
**Each module has its own logic behavior documentations which includes I/O signals, Logics and Note.**

### RV32I43F

- **ISA**: RISC-V RV32I v2.1  + **Zicsr** v2.0
  (except fence, fence.tso, pause, ecall, ebreak = total 43 instructions)  
- Total 15 Modules, 81 Signals.

  <details>
  <summary>Click to view Modules and Signals table</summary> 
  
  |Module name|Acronyms|Inputs|Outputs|Signals|
  |:---|:---:|:---|:---|:---:|
  |**Program Control**|
  |Program Counter|PC|next_pc, clk, reset|pc|3+1=4|  
  |PC Controller|PCC|jump, branch_taken, pc, imm, jump_target|next_pc|5+1=6|
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
  
  </details>
  
Supported CSRs:
|CSR|address<sub>16</sub>|Read-Only|WLRL, WARL|
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

<sup>WLRL = Write Legal, Read Legal. WARL = Write Any, Read Legal.</sup>


⚠️ Notes
- Misaligned address access is handled as zeroing the low 2-bits from address.
- In RV32I46F_5SP, the CSR logics are changed. For executing the trap and exceptions during the pipeline, the address signal separated to read address and write address input.
- `mhartid` is a dummy value for read-only CSR design test. No multi-hart architecture is available now.

For each module's logic description, go to `documents/modules_and_signals/` for more information.
**Each module has its own logic behavior documentations which includes I/O signals, Logics and Note.**

### RV32I46F

- **ISA**: RISC-V RV32I v2.1  + **Zicsr** v2.0 + mret*  
  (except fence, fence.tso, pause, = total 46 instructions)  
  <sup>*privileged architecture version 20240411, 3.3.2. Trap-Return Instructions, page 51 </sup>  
- Total 16 Modules, 102 Signals.  
 
 <details>
 <summary>Click to view Modules and Signals table</summary>


- Modules and Signals table
  |Module name|Acronyms|Inputs|Outputs|Signals|
  |:---|:---:|:---|:---|:---:|
  |**Program Control**|
  |Program Counter|PC|next_pc, clk, reset|pc|3+1=4|  
  |**PC Controller**|PCC|**pcc_op**, pc, branch_target, jump_target|next_pc|4+1=5|
  |**Exception Detector**|ED|**clk, reset, opcode, funct3, alu_result, funct12, csr_write_enable, branch_target_lsbs**|**trapped, trap_status**|8+2=10|
  |**Trap Controller**|TC|**clk, reset, pc, trap_status, csr_read_data**|**trap_target, debug_mode, csr_write_enable, csr_trap_address, csr_trap_write_data, trap_done**|5+6=11|
  |**Memory Units**|
  |Instruction Memory|IM|pc|im_instruction|1+1=2|
  |Instruction Decoder|ID|instruction|opcode, funct3, funct7, rs1, rs2, rd, raw_imm|1+7=8|
  |Register File|Reg|clk, read_reg1, read_reg2, write_reg, write_data, write_enable|read_data1, read_data2|6+2=8|
  |Data Memory|DM|clk, write_enable, address, write_data, write_mask|read_data|5+1=6|
  |CSR File|-|clk, reset, csr_write_enable, csr_address, csr_write_data|csr_read_out|5+1=6|
  |**Controls**|
  |**Control Unit**|CU|opcode, funct3, **branch_taken, trapped, trap_done**|**pcc_op**, alu_src_A_select, alu_src_B_select, register_file_write, register_file_write_data_select, memory_read, memory_write, csr_write_enable|5+8=13|
  |ALU Controller|-|opcode, funct3, funct7_5, imm_10|alu_op|4+1=5|
  |**Executions**|
  |Arithmetic Logic Unit|ALU|srcA, srcB, alu_op|alu_result, alu_zero|3+2=5|
  |**Branch Logic**|-|branch, alu_zero, funct3, **pc, imm**|branch_taken, **branch_target**|5+2=7|
  |Byte Enable Logic|BE_Logic|memory_read, memory_write, funct3, register_file_read_data, data_memory_read_data, address|register_file_write_data, data_memory_write_data, write_mask|6+3=9|
  |Immediate Generator|imm_gen|opcode, raw_imm|imm|2+1=3|
  |PC plus 4|-|pc|pc_plus_4|1+1=2|
  |**MUXs**|
  |ALUsrcMUX_A|-|read_data1, pc, **rs1**, alu_src_A_select|srcA|  
  |ALUsrcMUX_B|-|read_data2, imm, **csr_read_data**, alu_src_B_select|srcB|
  |Reg_WD_MUX|-|byte_enable_logic_register_write_data, alu_result, imm, pc_plus_4, csr_read_data|register_file_write_data|
  |**CSR_addr_MUX|-|trapped, raw_imm, csr_trap_address|csr_address**|
  |**CSR_addr_MUX|-|trapped, csr_trap_write_data, alu_result|csr_write_data**|
  |**DBG_RD_MUX|-|debug_mode, im_instruction, dbg_instruction|instruction**|
</details>

⚠️ Notes
- Misaligned address access is now handled with **Exception Handling**
- Operations that should be done before branching to the *Trap Handler*, such as writing `mcause, mepc` CSRs and reading `mtvec` is done in **Trap Controller** module. (Pre-Trap Handling; PTH)  
This **PTH** consumes about 5 Clock cycles. 
- CSR configurations are same as 43F architecture.

For each module's logic description, go to `documents/modules_and_signals/` for more information.
**Each module has its own logic behavior documentations which includes I/O signals, Logics and Note.**

### RV32I46F_5SP

- **ISA**: RISC-V RV32I v2.1  + **Zicsr** v2.0 + mret*  
  (except fence, fence.tso, pause, = total 46 instructions)  
  <sup>*privileged architecture version 20240411, 3.3.2. Trap-Return Instructions, page 51 </sup>  
- Total 23 Modules, 338 Signals.  
 
 <details>
 <summary>Click to view Modules and Signals table</summary>


- Modules and Signals table
  |Module name|Acronyms|Inputs|Outputs|Signals|
  |:---|:---:|:---|:---|:---:|
  |**Program Control**|
  |Program Counter|PC|clk, reset, next_pc|pc|3+1=4|  
  |**PC Controller**|PCC|jump, branch_estimation, branch_prediction_miss, trapped, pc, jump_target, branch_target, branch_target_actual, trap_target, pc_stall|next_pc|10+1=11|
  |**Exception Detector**|ED|clk, reset, **ID_opcode, EX_opcode, MEM_opcode, ID_funct3, EX_funct3, MEM_funct3**, alu_result, **MEM_alu_result**, raw_imm, **EX_raw_imm**, csr_write_enable, branch_target_lsbs, **branch_estimation**|trapped, trap_status|15+2=17|
  |**Trap Controller**|TC|clk, reset, **ID_pc, EX_pc, MEM_pc, WB_pc**, trap_status, csr_read_data|trap_target, debug_mode, csr_write_enable, csr_trap_address, csr_trap_write_data, trap_done, **misaligned_instruction_flush, misaligned_memory_flush, pth_done_flush, standby_mode**|8+10=18|
  |**Memory Units**|
  |Instruction Memory|IM|pc|im_instruction|1+1=2|
  |Instruction Decoder|ID|instruction|opcode, funct3, funct7, rs1, rs2, rd, raw_imm|1+7=8|
  |Register File|Reg|clk, read_reg1, read_reg2, write_reg, write_data, write_enable|read_data1, read_data2|6+2=8|
  |Data Memory|DM|clk, write_enable, address, write_data, write_mask|read_data|5+1=6|
  |**CSR File**|-|clk, reset, **trapped**, csr_write_enable, **csr_read_address, csr_write_address**, csr_write_data|csr_read_out, **csr_ready**|7+2=9|
  |**Controls**|
  |**Control Unit**|CU|opcode, funct3, trap_done, **csr_ready**|**jump, branch**, alu_src_A_select, alu_src_B_select, register_file_write, register_file_write_data_select, memory_read, memory_write, csr_write_enable, **pc_stall**|4+10=14|
  |ALU Controller|-|opcode, funct3, funct7_5, imm_10|alu_op|4+1=5|
  |**Executions**|
  |Arithmetic Logic Unit|ALU|srcA, srcB, alu_op|alu_result, alu_zero|3+2=5|
  |**Branch Logic**|-|branch, **branch_estimation**, alu_zero, funct3, pc, imm|branch_taken, **branch_target_actual**, **branch_prediction_miss**|6+3=9|
  |Byte Enable Logic|BE_Logic|memory_read, memory_write, funct3, register_file_read_data, data_memory_read_data, address|register_file_write_data, data_memory_write_data, write_mask|6+3=9|
  |Immediate Generator|imm_gen|opcode, raw_imm|imm|2+1=3|
  |PC plus 4|-|pc|pc_plus_4|1+1=2|
  |**Pipelines**|
  |**IF ID Register**|**IF/ID**|clk, reset, flush, IF_ID_stall, IF_pc, IF_pc_plus_4, IF_instruction, IF_branch_estimation|ID_pc, ID_pc_plus_4, ID_instruction, ID_branch_estimation|9+4=13|
  |**ID EX Register**|**ID/EX**|clk, reset, flush, ID_EX_stall, ID_pc, ID_pc_plus_4, ID_branch_estimation, ID_instruction, ID_jump, ID_branch, ID_alu_src_A_select, ID_alu_src_B_select, ID_memory_read, ID_memory_write, ID_register_file_write_data_select, ID_register_write_enable, ID_csr_write_enable, ID_opcode, ID_funct3, ID_funct7, ID_rd, ID_raw_imm, ID_read_data1, ID_read_data2, ID_rs1, ID_rs2, ID_imm, ID_csr_read_data|EX_pc, EX_pc_plus_4, EX_branch_estimation, EX_instruction, EX_jump, EX_memory_read, EX_memory_write, EX_register_file_write_data_select, EX_register_write_enable, EX_branch, EX_alu_src_A_select, EX_alu_src_B_select, EX_opcode, EX_funct3, EX_funct7, EX_rd, EX_raw_imm, EX_read_data1, EX_read_data2, EX_rs1, EX_rs2, EX_imm, EX_csr_read_data|28+24=52|
  |**EX MEM Register**|**EX/MEM**|clk, reset, flush, EX_MEM_stall, EX_pc, EX_pc_plus_4, EX_instruction, EX_memory_read, EX_memory_write, EX_register_file_write_data_select, EX_register_write_enable, EX_opcode, EX_funct3, EX_rs1, EX_rd, EX_read_data2, EX_imm, EX_raw_imm, EX_csr_read_data, EX_alu_result|MEM_pc, MEM_pc_plus_4, MEM_instruction, MEM_memory_read, MEM_memory_write, MEM_register_file_write_data_select, MEM_register_write_enable, MEM_csr_write_enable, MEM_opcode, MEM_funct3, MEM_rs1, MEM_rd, MEM_read_data2, MEM_imm, MEM_raw_imm, MEM_csr_read_data, MEM_alu_result|21+17=38|
  |**MEM WB Register**|**MEM/WB**|clk, reset, MEM_WB_stall, flush, MEM_pc, MEM_pc_plus_4, MEM_instruction, MEM_register_file_write_data_select, MEM_imm, MEM_raw_imm, MEM_csr_read_data, MEM_alu_result, MEM_register_write_enable, MEM_csr_write_enable, MEM_rs1, MEM_rd, MEM_opcode, MEM_byte_enable_logic_register_file_write_data|WB_pc, WB_pc_plus_4, WB_instruction, WB_register_file_write_data_select, WB_imm, WB_raw_imm, WB_csr_read_data, WB_alu_result, WB_register_write_enable, WB_csr_write_enable, WB_rs1, WB_rd, WB_opcode, WB_byte_enable_logic_register_file_write_data|18+14=32|
  |**Hazard Unit**|-|clk, reset, trap_done, csr_ready, standby_mode, trap_status, misaligned_instruction_flush, misaligned_memory_flush, pth_done_flush, ID_rs1, ID_rs2, ID_raw_imm, MEM_rd, MEM_register_write_enable, MEM_csr_write_enable, MEM_csr_write_address, WB_rd, WB_register_write_enable, WB_csr_write_enable, WB_csr_write_address, EX_rd, EX_opcode, EX_rs1, EX_rs2, EX_imm, EX_csr_write_enable, EX_jump, branch_prediction_miss|hazard_mem, hazard_wb, csr_hazard_mem, csr_hazard_wb, IF_ID_flush, ID_EX_flush, EX_MEM_flush, MEM_WB_flush, IF_ID_stall, ID_EX_stall, EX_MEM_stall, MEM_WB_stall|28+12=40|
  |**Forward Unit**|-|hazard_mem, MEM_imm, MEM_alu_result, MEM_csr_read_data, MEM_pc_plus_4, MEM_opcode, byte_enable_logic_register_file_write_data, hazard_wb, WB_imm, WB_alu_result, WB_csr_read_data, WB_byte_enable_logic_register_file_write_data, WB_pc_plus_4, WB_opcode, csr_hazard_mem, csr_hazard_wb, MEM_csr_write_data, WB_csr_write_data, csr_read_data|alu_forward_source_data_a, alu_forward_source_data_b, alu_forward_source_select_a, alu_forward_source_select_b, csr_forward_data|19+5=24|
  |**Branch Predictor**|**BP**|**clk, reset, IF_opcode, IF_pc, IF_imm, EX_branch, EX_branch_taken|branch_estimation, branch_target**|7+2=9|
  |**MUXs**|
  |**ALUsrcMUX_A|-|EX_read_data1, EX_pc, EX_rs1, EX_alu_src_A_select**|srcA|
  |**ALUsrcMUX_B|-|EX_read_data2, EX_imm, EX_csr_read_data, EX_alu_src_B_select**|srcB|
  |**ALUsrc_forward_MUX_A|-|alu_forward_source_select_a, alu_forward_source_data_a, srcA|ALUsrcA**|
  |**ALUsrc_forward_MUX_B|-|alu_forward_source_select_b, alu_forward_source_data_b, srcB|ALUsrcB**|
  |**Reg_WD_MUX**|-|**WB_byte_enable_logic_register_write_data, WB_alu_result, WB_imm, WB_pc_plus_4, WB_csr_read_data|WB_register_file_write_data**|
  |**CSR_read_addr_MUX**|-|**trapped, standby_mode, raw_imm, csr_trap_address|csr_read_address**|
  |**CSR_write_addr_MUX**|-|**trapped, standby_mode, WB_raw_imm, csr_trap_address|csr_write_address**|
  |**CSR_data_MUX**|-|trapped, **standby_mode**, csr_trap_write_data, **WB_alu_result**|csr_write_data|
  |DBG_RD_MUX|-|debug_mode, im_instruction, dbg_instruction|instruction|
</details>

⚠️ Notes
- 46F_5SP architecture was designed to be implemented on FPGA. So some modules have turned to Syncrhonous modules.  
This made some hazards. Please be aware of these which is written in issues. 
- Since the Exception Detector logic and CSR File have been changed to Synchronous, **PTH now consumes about 10 Clock cycles.**
- CSR configurations are same as 43F architecture.
- To run C program, the bypass logic between Instruction Memory and Data Memory is required (since the toolchain linker divides the ROM and RAM address map.). Please check the core design in `fpga/` for running C program on our SoC.

For each module's logic description, go to `documents/modules_and_signals/` for more information.
**Each module has its own logic behavior documentations which includes I/O signals, Logics and Note.**

---

## FPGA Implementation Results

<img width="3785" height="2701" alt="fpga_verifications_bscrv32s_compressed" src="https://github.com/user-attachments/assets/47b0c98e-5fc2-4176-8e4c-a2eef39fa5b4" />
<sup> 46F5SP_SoC with RV32I46F_5SP core implemented on Digilent Nexys Video FPGA board </sup>  

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
<sup>** All memories are inferred as **LUT-based distributed RAM**.</sup>  

### 📈 Performance Evaluation

Dhrystone performance can be calculated by **DMIPS** (Dhrystone Million Instructions Per Second).  

Since we've got the total cycles and instructions that needed to benchmark the Dhrystone, we can calculate our core's performance through this information.

The proposed performance of RV32I46F_5SP core's dhrystone benchmark is evaluated with the following conditions:
- 2000 iterations settings
- 50MHz of timing constraints (20ns, clock cycle speed)

In our settings on Digilent Nexys Video FPGA, we obtained:
- final cycles : 00000000FEA94 = 1,043,092 Cycles
- final instructions : 000000000009DDF0 = 646,640 Instructions

```math
CPI = \frac{Clock\;Cycles}{Instructions} = \frac{1,043,092}{646,640} = 1.61\;cycles/instr.
```

- MIPS (Million Instructions Per Second)
```math
MIPS = \frac{instructions}{t} / 10^6 = \frac{646,640}{0.0208618} / 10^6 \approx\, 31.0\,MIPS
```

- Execution Time
```math
t = \frac{Clock\;Cycles}{Clock\;Frequency} = \frac{1,043,092}{50\,\times\,10^6}\; \approx\, 0.0208618\,seconds
```

- Dhrystones per Second
```math
Dhrystones/sec = \frac{iterations}{t} = \frac{2,000}{0.0208618} \approx\, 95,875\, DPS
```

- DMIPS (Dhrystone Million Instructions Per Second)  
<sup> 1 DMIPS equals to 1757 Dhrystones Per Second. </sup>
```math
DMIPS = \frac{Dhrystones/sec}{1757} = \frac{95,875}{1757} \approx\, 54.6\, DMIPS
```

- DMIPS/MHz
```math
\frac{54.6\, DMIPS}{50\, MHz} \approx\; 1.09\, DMIPS/MHz
```

Various performance benchmark (such as coremark) will be added soon.  
We assume that the processor can reach higher clock speed and performance, but at the moment we couldn't continue development in touch due to personal schedule (military duty, school admission).  
This will be worked soon also.

---

## Getting Started

**basic_RV32s** can be simply cloned by using
```git
$ git clone https://github.com/RISC-KC/basic_rv32s.git
```

### ⚠️ Setup Project file path

Some files contain absolute paths in include statements:
Such as : 
```verilog
`include "source_locations/a/b/c/source_name.v"
```

Please update these paths to match your project structure.  

### 🔎 Core behavior Simulations  

Required : Icarus Verilog for using `./test.sh` command.

```git
$ cd [source_code_directory]
$ ./test.sh RV32I37F.v RV32I37F_tb.v
```
This would run testbench as coded in `testbenches/`.  
The result of the simulation `.vvp` is generated in `testbenches/results/`.  
`.vcd` waveform result is generated in `testbenches/results/waveforms/`.  

Waveform can be viewed using **GTKwave** or [Surfer-project](https://surfer-project.org/).  

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

If you are not a beginner like I was, you can just modify this memory settings.  
Since the actual FPGA implementation is only done in **RV32I46F_5SP**, we suggest to use 46F_5SP architecture for C compiled program simulation.  

We're going to work on easy C program import on SoC soon.  

---

## Future Works

1. issue resolutions
2. Single-Cycle core FPGA implementation and Evaluation
3. Additional benchmarks (Coremark, RISC-V ISA tests)
4. Standardized FPGA synthesis resource measurement
5. Optimize critical paths and reach higher clock speed and performance
6. Easy method for running C program on SoC

---

## Contributions
### This repository is not Frozen or Completed ❄️!

Most of repository structure has been designed, but still some documents are on-going.  
Since the project is being done in limited environment (military duty), this could take some time.  
We are currently targeting October 2025 to complete the entire documentation plan as described in the README.  

Since it's still an open-source RISC-V core implementation and instructional framework, the changes can be done as needed.  
Please feel free to generate an issue for improving this project to make it possible to newcommers and beginners can easily dive in to RISC-V and Processor Design.  

Thanks! 📡

---

## Acknowledgment

Heartfelt thanks to [@ChoiCube84](https://github.com/ChoiCube84) for being an incredible project companion throughout this processor design journey. Even in the challenging environment of military service, your consistent support and dedication made this project possible. 

**Contributors:**
- [@T410N](https://github.com/t410n) (KHWL) - Project Lead & Architecture Design
- [@ChoiCube84](https://github.com/ChoiCube84) - Development & Project support

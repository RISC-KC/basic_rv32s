# Tutorials

The most efficient pathway to learn the processor design from scratch, we suggest following steps before the Development Log.

## Before getting started

This Processor design learning framework is based on **RISC-V RV32 ISA.**  
**We strongly recommend to check and read the** [Ratified specifications manual of RISC-V ISA](https://riscv.org/specifications/ratified/).  
 Especially in Unprivileged Architecture manual, all of required information for designing the processor that meets the RISC-V ISA standard is fully desribed. 
 
 Of course, the manual doesn't describe '*exactly how to*' design the processor from scratch, but even not knowing the methodology to start, this gives massive clues to infer the architecture to design. 

# Learn Architecture Design

0. Select which architecture you want to learn (We assume to start with 37F base architecture. )
1. Open 37F block diagram design located at `documents/diagrams`.  
(We recommend to open with draw.io rather than `.png`, `.pdf`. It's way easier to track the signal's source and destination just by clicking the signal. )
2. See 37F architecture's specification located at `documents/theories_and_logics/modules_and_signals`. Its name is `Architecture_Specifications.md`.
3. Check each datapath that corresponds to instruction that architecture support.
(e.g. beq, addi, lui... etc.)  
The intended datapath track file is located at `documents/theories_and_logics/modules_and_signals/37_Architecture/`.
4. Find each module's logic description document named `[Architecture Name]modulename.md`. 
5. 
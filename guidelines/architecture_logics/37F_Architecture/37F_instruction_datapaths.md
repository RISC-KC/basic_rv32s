# 37F Architecture RV32I Instruction Datapath

**RISC-V RV32I v2.1**  
---
Unprivilged Architecture Manual version 20240411.  
**RV32I37F.R4v2** Core design architecture.  
**basic_RV32s**' base core architecture.  

---
### R-Type
- ADD, SUB,  
PC - Instruction Memory - Instruction Decoder - Register File, Control Unit- ALU controller - ALU - Reg_WD_MUX - Register File

<img width="1646" height="984" alt="RV32I37F R4v2_R drawio (2)" src="https://github.com/user-attachments/assets/68cdae4d-b127-4776-a1de-a195c054cf27" />

---
### I-Type
- ADDI  
PC - Instruction Memory - Instruction Decoder - Register File, Control Unit, Immediate_Generator - ALU controller - ALU - Reg_WD_MUX - Register File

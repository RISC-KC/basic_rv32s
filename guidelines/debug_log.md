# 🖍 RISC-V RV32I Processor Debug Log
This document is a summary of problems that required resolutions from the `development_log.md`.  

The architecture design evolution is from **37F**, **43F**, **46F**, to **46F5SP**.  

⚠️ Make sure to read the tutorials for optimal learning experience.

## [2025.01.05.]

- **Problem** : Because of `jalr` instruction, we need an logics for misaligned jump address calculation. `jalr` instruction calculates target address by adding immediate value on register value. This leaves room for misaligned instruction address. 
    - **Resolution** : Designed **PC Aligner** module for aligning the instruction address forcefully.  
- **Problem** : We find out that in RISC-V RV32I, the hardware should support not only 4-byte load/store but also 2-byte, 1-byte load/store. 
    - **Resolution** : Designed **Byte Enable Logic** module for masking the bytes when it needs partial load/store operation.  
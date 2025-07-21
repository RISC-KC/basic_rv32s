# Verification Methodology Using Dhrystone

This document is about implementing Dhrystone program on **RV32I46F_5SP** core design for FPGA verification and performance evaluation.  

## Setup for Dhrystone RISC-V RV32I Compile

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

### Setup files for compiling Dhrystone
To compile Dhrystone, you need to setup several files.
 
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

### Debug Dhrystone compile Errors
- Since our core design doesn't exactly support the C functions (or , the C version difference) there could be some errors while compiling the Dhrystone in march rv32i, ilp32. 

The debug logs will be added soon.

## SoC Design for Dhrystone Benchmarking
To measure the performance executing the Dhrystone, we've designed **46F5SP_SoC** architecture. 
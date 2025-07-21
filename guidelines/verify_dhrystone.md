# 📊 Verification Methodology Using Dhrystone

This document is about implementing Dhrystone benchmark on **RV32I46F_5SP** core design for FPGA verification and performance evaluation.  
First, clone or download the required files from the release or `fpga/` directory.

## 📼 Environment Setup

### SoC Design for Dhrystone Benchmarking and FPGA implementation
To measure Dhrystone execution performance, we designed **46F5SP_SoC** architecture. 
- UART TX
- Button and LED interfaces
- Button signal debouncer module 
- Debugger module
- **Benchmark Controller** for calculating Dhrystone performance
- **Dhrystone Instructions** integrated in **Instruction Memory** and **Data Memory**.  
(RV32I, ilp32: riscv32-unknown-elf-gcc compiled Dhrystone)

### ⚠️ Setup Project file path

Some files contain absolute paths in include statements:
Such as : 
```verilog
`include "source_locations/a/b/c/source_name.v"
```

Please update these paths to match your project structure.  

### 📍 Setup USB to UART bridge Virtual COM Port (VCP) driver
On Digilent Nexys Video FPGA, we need VCP driver for FTDI FT232R USB-UART bridge (attached to connector J13).  
Required Drivers depend on which FPGA board you use.  
Please check each vendor's manual for precise information.  

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
 
1. Make sure the **linker script** of the compile's memory map is same as following.  

    ```
    ...
    MEMORY
    {
        ROM (rx) : ORIGIN = 0x00000000, LENGTH = 64K
        RAM (rw) : ORIGIN = 0x10000000, LENGTH = 32K
    }
    ...
    ```

    You can just modify these memory settings according to your needs.  
2. **Makefile**  
In dhrystone's makefile, we can find the iteration value parameter.  
Default iterations are 2000. You can change this as needed.

### Debug Dhrystone compile Errors
- Our core design doesn't exactly support the C functions (or , it could be due to C version differences).    
There could be some errors while compiling the Dhrystone in march rv32i, ilp32. 

The debug logs will be added soon.

## ✅ Run Dhrystone

1. **Synthesize & Implement** design in Vivado (IDE)
2. Generate **Bitstream**
3. **Download hardware** on your FPGA
4. Check if it works with **buttons and LEDs**  
<sup>press reset button if needed</sup>
5. **Connect UART** with your PC and start communication  
<sup>(default baud rate is 115200 baud.)</sup>
6. **Press result button** first, you will see 0 values comming out.
7. **Press Up button** and watch the LEDs change  
<sup> This indicates the Dhrystone benchmark has been completed </sup>
8. **Press result button** to get the retired instructions and cycles that took for dhrystone benchmark.  
<sup>(minstret, mcycle with hex value)</sup>  
e.g. ) 00000000FEA94  
Instr: 000000000009DDF0

## 📈 Calculate the Performance

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

## Conclusion

The RV32I46F_5SP core achieves approx. **1.09 DMIPS/MHz** performance on the Dhrystone benchmark.  
This result provides a baseline for comparing with other RISC-V implementations and can be used to evaluate the core's efficiency for embedded applications.  

For questions or issues, please refer to the project documentation or open an issue in the repository.  
# 🖍 RISC-V RV32I Processor Debug Log
This document is a summary of problems that required resolutions from the `development_log.md`.  

The architecture design evolution is from **37F**, **43F**, **46F**, to **46F5SP**.  

⚠️ Make sure to read the tutorials for optimal learning experience.

-----

## PC Aligner Design for `jalr` misaligned jump address
### [2025.01.05.]

> - **Problem** :   
>   - Because of `jalr` instruction, we need an logics for misaligned jump address calculation.   
>   - `jalr` instruction calculates target address by adding immediate value on register value. This leaves room for misaligned instruction address. 
- **Resolution** : 
    - Designed **PC Aligner** module for aligning the instruction address forcefully.    
    (Note; This design changes for precise exception handling in 46F Architecture. Idea from 2025.02.04.)

-----

## Byte Enable Logic for Partial byte operations
### [2025.01.05.]
> - **Problem** :   
We find out that in RISC-V RV32I, the hardware should support not only 4-byte load/store but also 2-byte, 1-byte load/store.    
>   - `lw`, `lh`, `lb`, `sw`, `sh`, `sb`

- **Resolution** : 
    - Designed **Byte Enable Logic** module for masking the bytes when it needs partial load/store operation.  

-----

## Instruction Decoder `raw_imm` width issue
### [2025.01.28.]

> - **Problem** :   
>   - In the prior scheme, `imm` was treated as a **12-bit** entity.   
And U-type uses a **20-bit** immediate.  
>   - In the current ID, all `imm` (except for CSR/ALUcontroller meta-uses) were being **sign-extended** into the ALU, which leads to a problem:  
>   - The **Imm_gen** could not know which bit is the MSB for the given instruction’s immediate.
>   - Example failure:  
>       - `0000111010` → treats bit 5 as MSB and extends...  
>       - `0001111001010` → again treats bit 5 as MSB... → broken data for 20-bit U-type.

- **Resolution** : 
    - Instruction Decoder now **zero-extends** the RAW `imm` to 32 bits.
    - For **U-type AUIPC** (20-bit immediate), **bypass** Imm_gen and use this zero-extended `imm` directly.
    - For all **12-bit** immediates, pass through **Imm_gen** to produce a sign-extended `ex-imm` for the ALU.

- **Module changes:**
    - Add a new source to **ALUsrcB** for the “plain `imm`” path → **4:1 MUX**.
    - CU must select **ALUsrcB = imm** when it detects **U-type**.
- **RV32I47F.R4** revision

-----

- This is revised in 2025.01.30., to RV32I47F.R6 following
    - **Instruction Decder `imm` width = 20 bits.**

    - For **12-bit** immediates, output the **raw 12 bits**; upper 8 bits are **don’t-care**   
    (ImmGen slices what it needs).
    - For **20-bit** immediates, output the **raw 20 bits** to `imm_gen`.  
    - Add **`opcode`** as an input to **`imm_gen`** so it can perform the **correct sign/zero extension by instruction type**.

-----

## ALU Controller's ALUop encoding issue
### [2025.02.24.]

>- **Problem** : 
>   - Since `ALUop` does not have an instruction-type identifier, **there’s no way to distinguish I-type `SRAI` from R-type `SRA`**.  
>   - For I-type instructions, only for shift instructions, I had separated them with funct7 and shamt in the imm field, and the key is slicing this.  
>   - If we just slice the input source data, the **ALU** wouldn’t know whether it’s R-type `SRA` or I-type `SRAI`, so following the `ALUop` code for `SRA`, it could end up slicing _funct7_ and shamt from `RD2`.  

- **Resolution** : 
    - Slicing `imm[4:0]` and putting it into `ALUsrcB`. Doing so gives _shamt_ → `imm[24:20]` → `SRA` operator. Shift by `imm[24:20]`.  
    - Separately extract `imm` and add one more selection to `ALUsrcB` with a 4:1 MUX.  

-----

## Data Memory Synchronous `read_enable` issue
### [2025.02.28.] ~ [2025.03.02.]

>- **Problem** : 
>   - In an LW operation that the data read from Data Memory is output in the next clock cycle. 
>   - synchronous Data Memory with a Read Enable signal outputs data in the cycle after a read signal is sent.  
>   - Unexpected testbench scenario's results

- **Resolution** : 
    - Add `read_done` and feed it to the **PC Controller** so we only proceed to the next instruction after a Data Memory read completes.

- **Logics** : 
    - Load instruction handling
        - The Control Unit detects a load.
        - If read_done is 0, assert a PC_Stall from the CU to the PCC to hold PC = PC.
        - On the next cycle, read data appears and read_done goes to 1 simultaneously.
        - PC_Stall deasserts and PC advances to NextPC.

    - If the next instruction is also a load
        - Memory read remains 1.
        - read_done is already 1, so we advance immediately.

    - If the next instruction is not a load
        - Memory read drops to 0.
        - read_done is also 0, but since this isn’t a load, it’s ignored.
        - PC_Stall remains deasserted and we continue to the next instruction.

    - PC Stall datapath
        - Data Memory asserts read_done to the Control Unit.
        - The Control Unit drives PC_Stall to the PC Controller based on read_done.
        - When PC_Stall is asserted, the PC Controller holds NextPC at the current PC, blocking further instruction issue.
        - When read_done is 1, the Control Unit deasserts PC_Stall and execution resumes.  

-----

### [2025.03.16.]
- **Another Resolution** : 
    - IDEC’s reference Data Memory code in our testbench, we found it operates correctly within a single cycle. = Unnecessary `read_done`
    - The issue was Verilog’s “=” from existing RTL code of **Data Memory**
    - The `read_done` signal goes away. 
    - The `read_enable` signal goes away.

-----

## Data Memory `WriteMask` one cycle delayed waveform result issue
### [2025.03.03.]

>- **Problem** : 
>   - Data Memory WriteMask—and its 32-bit extended mask—lagging by one cycle. 
>   - Oddly, stores still worked.  

- **Resolution** : 
    - Declaring `extended_mask` as a **wire**(verilog RTL) solved it.

-----

## Trap Controller **Pre-Trap Handling**(PTH) FSM debug
### [2025.05.08.]

>- **Problem** : 
>   - Originally the **FSM** only had three states: `IDLE` – `WriteMEPC` – `WriteMCAUSE`.  
>   - That worked because execution starts in `IDLE`; then write mepc; and if write mepc, proceed to write mcause, and return to idle.  
>   - But in back-to-back **Trap Controller** interventions, this tangles the FSM. (Continuous Trap Condition)
>   - If signals keep coming in, waveform shows that the current situation gets re-recognized and the FSM cycles again.  

- **Resolution** : 
    - Add a terminal `READ_MTVEC` state so that on the next instruction update we return to `IDLE` and can run from the start again.

- **Changes** : 
    - It takes 3 cycles total from trap occurrence to control, during which the **PC** must be frozen, and we also need additional write control for the **CSR File**.  
    - But only the **Trap Controller** knows when writes to the **CSR File** occur, so the **TC** should send a `write enable` signal to the **CSRF**, and in the top we should _bitwise OR_ the **Control Unit** and **TC** write-control signals so that **CSRF** write is enabled.  
    - Similarly, during **Pre-Trap Handling**, the **PC** must not update; I think we should add a `Trap_Done` signal to the **CU**.  

-----

## Trap Controller `trap_done` signal implementation debug
### [2025.05.09.]
>- **Problem** : 
>   - First implement: `trap_done <= 1'b0` in the `IDLE: begin` block and `trap_done <= 1'b1` in the `WRITE_MCAUSE: begin` block.
>   - If it doesn’t behave as intended, move `trap_done <= 1'b1` into a new `READ_MTVEC: begin` block and include it there.
>   - Now it’s 0 only in IDLE, and 1 in WRITE_MEPC, WRITE_MCAUSE, READ_MTVEC.

- **Resolution** : 
    - Moved `trap_done <= 1'b1` into `WRITE_MCAUSE` (`READ_MTVEC` for other cases)
    - Wrote `trap_done <= 1'b0` directly where `trap_status` is set, not in the `trap_handle_state`.  
    - `trap_done` goes to 0 during **Pre-Trap Handling**, and rises back to 1 at `TRAP_NONE` next, which is as intended.

-----

## RV32I46F Top module RTL Simulation Debugging (Delayed PTH: ECALL `pc_stall` issue)

### [2025.05.13.]
>- **Problem** : 
>   - ECALL get recognized correctly, mepc (CSR 341) got the current PC written, but the next PC didn’t stall and instead updated to 0000_0000
>   - pc_stall... becomes asserted not at 0000_00BC (ECALL) but the next cycle

- **Attempts** : 
    - Originally, on TRAP occurrence during **PTH** I set `trap_done` to 0, but since **TrapController** sets `trap_status != 0`, trap_done should be 0 for all instructions anyway.   
Maybe I should set `trap_done` in the case statement itself rather than per-case.  
        - Tried that, but Verilog disallows writing something before the case condition declaration.

    - Previously I only drove `trap_done <= 0` at the start of each FSM state and assumed it would persist, then set `trap_done <= 1` at the end of the FSM.  
Now, except for the final FSM stage, I put `trap_done <= 0` into every FSM state.  
I need to compare the new vcd with the old to see what differs...    
        - No difference
    
    - To avoid unintended latches in the Trap Controller, I set trap_done <= 1 before the case(trap_status)
        - Same outcome, but I caught a different angle.

>- **Revealed Problem** : 
>   - PTH’s activation itself is one cycle late
>   - Should pull it one cycle earlier so **PTH** triggers in the same cycle `trap_status` arrives

- **Resolution** : 
    - I made the detection logic _combinational_ `always (*)` to monitor changes and kick off **PTH** immediately, and kept the FSM progression sequential always `(posedge clk or posedge reset)` so it recognizes and reacts right away.  
    -  that works! But it didn’t branch to the mtvec address. 

## RV32I46F Top module RTL Simulation Debugging (PTH mtvec jump issue)
### [2025.05.13.]

 - **Situation** : 
   - **Pre-Trap Handling** didn’t branch to the `mtvec` address.
       - `trapped` asserted, `trap_target` looked good, `pc_stall` dropped properly
       - `next_pc` wasn’t selected as `trap_target` in **PC Controller(PCC)**
   - The instruction after `AUIPC` is a `JAL` that jumps to a misaligned address. 
       - That’s when the freeze happens.  
   - **Trap Controller** triggers fine. But **PTH** only proceeds to the first FSM stage and doesn’t branch to `mtvec`.  
   - In the waveform PC restart from 0. 

> - **Problem 1** : 
>   - Upon recognizing a ***SYSTEM*** instruction, **PTH** starts from the next cycle.
>       - Because of that, `trap_done` goes 0 → `pc_stall`, and PTH should proceed—but it doesn’t.
>   - **PTH** must begin in the same cycle the _SYSTEM instruction_ is identified.

- **Resolution** : 
    - Synthesized the **Trap Controller**’s `trap_status` condition as _combinational logic_ `always (*)` so PTH begins immediately on trap_status input.   
    (Previously everything ran on posedge clk (always (posedge clk or posedge reset)).)
    - The internal FSM update logic remains sequential. 
    - PTH now begins immediately upon detecting trap_status, as intended.

> - **Problem 2** : 
>   - **PTH** proceeds through the last stage (reading `mtvec`), but still, **PC** does not branch to the _Trap Handler_ at `0x0000_1000`.  
>   - `Trapped` asserted, `trap_target` looked correct, `pc_stall` deasserted—still no branch.   
I suspected PCC.
>   - `next_pc` wasn’t selected as `trap_target`. PCC logic itself looks fine

- **Revealed Problem** : 
    - Removed PC_Aligner in case it was interfering.
        - RV32I46F top-module testbench doesn’t stop.   
        - It hung at 29500 ms
        - The instruction after `AUIPC` is a `JAL` that jumps to a _misaligned address_. That’s where it freezes.
        - So `next_pc` must already be produced while the current PC is executing, but since it wasn’t, Exception Detector(ED) didn’t detect it and we went to a misaligned PC.  

## RV32I46F 29500ms issue debugging
### [2025.05.15.] ~ [2025.05.17.]

#### Approach A to the RV32I46F 29500 ms issue

If the race is among control signals selecting next_pc in PCC:

1. JAL instruction → Control Unit asserts Jump  
   ▶ next_pc = jump_target
2. Exception Detector sees next_pc misaligned, asserts Trapped  
   ▶ next_pc = trap_target
3. Trap Controller sees Trapped, starts PTH, sets trap_done = 0.  
   Control Unit asserts PC_Stall.  
   ▶ next_pc = pc

So three drivers for next_pc selection race and freeze the simulation.

Come to think of it, in Trap Controller I allowed trap_target (return address) on MRET to be an unaligned value. That’s separate from the current issue, but:

```verilog
`TRAP_MRET: begin
    csr_write_enable   <= 1'b0;
    csr_trap_address   <= 12'h341; //mepc
    trap_target        <= ({csr_read_data[31:2], 2'b0} + 4);
    debug_mode         <= 1'b0;
    trap_done          <= 1'b1;
end
```

I changed it so mepc return can’t go to a misaligned address.

- I peeked at the top module: even putting **PC_Aligner** back and letting it pass through, the trap scenarios for Trap Controller(TC)/Exception Detector(ED) verification still don’t select `next_pc` = `trap_target` properly.

#### Approach A to resolving RV32I46F’s 29500 ms issue.

The **PCC** logic is simple and already solid. Maybe the key lies in the **Control Unit**, which is the source of the PCC control signals.  
In other words, if we prevent all overlapping signals from being sent to the PCC at once, we can eliminate the race condition itself.  

> Either use conditionals on the PCC control signals so that only one of them is asserted, or send a single unified PCC control signal to the PCC.

#### Solution plan A-1 for the RV32I46F next_pc race condition

After the Control Unit decodes an instruction, do not drive `jump`, `trapped`, and `pc_stall` as separate signals to the **PC Controller**.  
Provide the **PC Controller** with an opcode-like `pcc_op` signal—i.e., a **PC Controller** operation code—so that the **PCC** determines `next_pc` from just one control input.  

**Solution A didn't work**

----

#### Approach B to resolving RV32I46F’s 29500 ms issue.

The program counter only samples on posedge clk.  
> “What if, instead of basing the misaligned check on `next_pc` in the **Exception Detector**, we compute misalignment in the **PCC** based on the candidate address source that would be selected?”  

The current design judges misalignment based on `next_pc`.  

It looks at `next_pc` and, if misaligned within the same clock, it assumes we can trap or stall and thus “change” the PC value.  
But the program counter only holds a value captured on posedge clk.  
Which means once a misaligned value is presented and we try to trap and fix it, the misaligned PC has already been latched, and we can’t change the current PC for that cycle.  
And changing this clocked update scheme would introduce stability risks.  

So the program counter should stay as-is. We need a different exception-handling scheme.  
Should I place a checker—not an aligner—there to detect misalignment? That feels messy.  

What if, instead of the Exception Detector judging `next_pc`, the PCC computes misalignment based on whichever address source it’s about to select?  

- **Resolution**
    - Have the PC Controller detect a misaligned jump_target and self-issue pc_stall by holding `next_pc` = pc.  
        - Then the Exception Detector can simultaneously recognize the misaligned jump_target and proceed with PTH normally. (20:32)  
    - **Solution B worked.**
        - Made the PCC self-stall the PC, and the simulation no longer freezes.  
        - Now should wire the Exception Detector signals so PTH actually runs

We need to detect misalignment for all branch targets, not just jump_target.  
However, in the old 43F-based architecture, the PCC computed the branch target internally by adding the current PC and the immediate and directly output that as next_pc.  

`jump_target` arrives on the alu_result signal, so I could feed that into the Exception Detector, but with branching done inside the PCC I can’t observe branch_target misalignment.  
To fix this, rather than adding a separate Branch Adder/Calculator (which would get messy), I decided to embed branch-target computation inside the Branch Logic module.

- **PTH Entered Properly.**
    - The `trap_handle_status` FSM advances correctly and we branch to the _Trap Handler_ address

-----

#### `mret` instruction `mepc` return issue

> - **Problem** : 
>   - In the _Trap Handler_ starting at **Instruction Memory** `data[1024]`, the goal was `csrrs x6, mcause, x0`, but I had encoded the CSR address as `12'h343`, which threw off the program’s control flow.  

- **Resolution** : 
    - I corrected it to 12'h342, the actual CSR address for mcause. 
        - PTH behaved correctly. 

-----

## RV32I46F Debug mode switching issue
### [2025.05.18.]

> - **Problem** : 
>   - After `EBREAK`, the instruction inside the _EBREAK handler_ should execute
>   - But the debug instruction doesn’t appear.

- **Attempts** : 
    - In the top module, added a MUX in the **Instruction Decoder**.  
        - Now the decoder takes both the instruction-memory instruction and the debug instruction
        - It also detects `debug mode`.  
    
> - **Revealed Problem** : 
>   - When I made the decoder do nothing in `debug_mode`, the `debug_mode` signal itself rose correctly, but decoding didn’t happen.  
>       - Which is expected. 
>   - But when I wrapped that in a conditional so it also decodes in debug mode—even if I just preset something like `opcode = 7'b0001100` inside—it freezes immediately at that timing. 

- **Attempts 2** : 
    - In the top module the debug_mode signal doesn’t show up in the waveforms for either the top module or the trap_controller, but the flag does rise at that timing.  
        - Something must be forcing the signal back to 0.  
    - I checked and found Trap Controller still had code that always defaulted debug_mode to 0.  
        - Since once debug_mode is active the debugger returns by executing MRET—and I already designed MRET to clear debug mode back to 0—I figured that defaulting wasn’t needed, so I removed it.
        - Still not working

- **Resolution** : 
    - On a hunch I changed the coding style.  
    Now it works...

    - Previously I had:  
    ```verilog
    if (debug_mode) begin
        instruction = dbg_instruction;
    end else begin
        instruction = im_instruction;
    end
    ```

    - I changed it to:  
    ```verilog
    if (debug_mode) instruction = dbg_instruction;
    else instruction = im_instruction;
    ```

- **Notes** : 
    - If I use debug_mode directly there, it freezes again. 
        - Replacing it with the flag solves it.  
    - With that in place, an ECALL routes to the debug instruction, it decodes correctly, and the instruction executes.
    - Also moved the Instruction Decoder’s MUX out into the top module and tried it—works fine.  

-----

## 
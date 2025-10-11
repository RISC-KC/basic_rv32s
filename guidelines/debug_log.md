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

## RV32I46F_5SP Debugging
### [2025.05.26.]

- Issue 1. 
    - Registers kept showing values like xx00_00bc.
        - I wrote an init block to zero all registers so they all start at 0000_0000. That cleared up the register waveform issue.  
   (As of today’s writing, oddly, I can’t catch that behavior in the waveforms anymore—even without adding that logic to the Register File. Huh?)

- Issue 2. 
    - The imm value didn’t seem to come out cleanly. 
        - WB_raw_imm in the pipeline was x.   
        - Solved with correcting instanciation typo error.

> - Issue 3.
>   - `rs1` was being fed into the **Register File** just fine
>   - But the corresponding source value wouldn’t come out.   

- **Resolution**
    - I’d forgotten to add the MUX in the top module that lets the **ALU** pick a forwarded source. 
        - Fixed that.  

- Issue 4.
    - `EX_branch_taken` from the **Branch Predictor** wasn’t wired correctly
        - Solved.

- Issue 5. 
    - After **PTH** the pipeline stalled and wouldn’t branch to the _Trap Handler_ address
        - Switched the pipeline-stall basis from `trapped` to `trap_done`
    - Fixed

- Issue 6. 
    - Missing bitwise OR between CSR write-enable 
        - One from the Trap Controller 
        - One from the pipelined write-enable coming from the Control Unit in the top module. 
    - Solved.  

-----

## RV32I46F_5SP Debugging (Branch Predictor)
### [2025.05.26.]

> - **Problem** : 
>   - With the Branch Predictor defaulting to Strongly Not Taken, the following instruction runs. 
>   - But even when the prediction is clearly wrong, we still weren’t branching to the EX-stage `pc+imm`.  
>   - Even the `branch_target` itself was correct

- **Attempts** : 
    - I found I’d been fabricating a nonexistent IF_pc signal for pc
        - Fixed that
        - PCC’s branch_taken was still 0

- **Resolution** : 
    - Derived branch_taken from branch_prediction, which caused trouble. 
    - Splited signals into `branch_estimation` and branch_prediction_miss
        - On actual taken, use branch_target
        - If the estimation says taken, also use b_target
        - Otherwise, just fall through.

-----

## RV32I46F_5SP Debugging (WB-stage forwarding from Retired Instruction)
### [2025.05.26.]

> - **Problem** : 
>   - Case that needs WB forwarding.  
>   - At 188611 ps, an instruction that retired in WB wrote to its `rd`
>     - But a later instruction had already reached EX without that updated `rd`.

- **Resolution** : 
    - Revise **Forward Unit** to forward data from Retired Instruction's value in WB-Stage

-----

## RV32I46F_5SP Debugging (Trap/Exception Pipeline Flush issue)
### [2025.05.27.]

> - **Problem** : 
>   - When EX_jump is misaligned, it inserts a NOP flush because it’s a jump. 
>   - But then we lose the context that the jump was misaligned
>       - So PTH only runs the first step and then we just move on to ADDI x0 x0 0.
>       - Thus, the TH never runs.  

- **Resolution** : 
    - Wired `trapped` into the **Hazard Unit** 
    - When `trapped` goes high, stalls the **ID_EX_Register** and **EX_MEM_Register**.
        - The ID_EX stall preserves context until **PTH** can run; 
        - The EX_MEM stall ensures the preceding (non-faulting) instruction completes.  

- **Notes** : 
    - PTH takes at least 2 cycles. 
    - By then, the WB stage has already completed
    - When the stalled MEM stage advances into WB, that WB also completes—so preceding instructions finish.   
> Do we need special handling for **MEM_WB_Register**?
> - No. 
> - Two preceding instructions will have already completed, and writing the same value to the same address twice doesn’t cause a data issue in the current system.

-----

## RV32I46F_5SP Debugging (Branching to Actual Branch Address when prediction fail)
### [2025.05.27.]

> - **Problem** : 
>   - PC only outputs the address set in the previous clock
>   - So even if the EX-stage computes the correct address and PCC passes it on, we won’t branch to it right away. 

- **Resolution** : 
    - PCC decides—based on whether the prediction was right—and outputs next_pc accordingly.  

- **Notes** : 
    - But `branch_prediction_miss` stay at 1 once it goes high?
        - Forgotten to set a 0 default in the combinational logic for the “no condition met” path.
        - Solved.

## RV32I46F_5SP Debugging
### [2025.05.31.]

Issue 1. (flush pipeline registers on a trap is missing)
- In **RV32I46F_5SP**, the logic to flush pipeline registers on a trap is missing.  
    - Add it.
        - On an exception, we stop updating the **PC**, let all in-flight instructions complete
        - Then conduct _trap handling_
        - While branching to the _Trap Handler_, we’ll save the current GPR contents into a heap area in data memory and reload them on `mret`.
- Example Scenario (misaligned exception)
    - (Current supported traps are misaligned instruction address, EBREAK, ECALL, and mret only.)
    - The **Exception Detector** catches this in IF
    - And the **Branch Predictor** receives both the branch target calculated in IF and the jump address calculated in EX.  
    - Using the `opcode` to determine the instruction form, instructions being processed before the jump have no context, 
    - So we hold the **PC** until they reach WB, flush, then proceed.

Issue 2. (Context Flush issue)
- Detected a misaligned jump in EX, which triggered a trap: `pc_stall` asserted and flush happened.  
- But on the next clock, EX holds a `NOP` due to the flush (the instruction after the jump), 
- So EX’s opcode is no longer `JAL`, trapped deasserts, **PTH** doesn’t run, `trap_done` returns to 1, and execution continues incorrectly.  
    - Add a stall signal that stops pipeline-register updates and holds their current values.

Issue 3. (Branch Predition Latch behavior)
- Flush on misprediction worked, the prediction counter updated, NOP got inserted as designed.  
- But once `branch_prediction_miss` went high, it never dropped even when `branch_estimation` matched branch taken.  
    - There was no zero-initialization path for miss in the combinational code
    - Adding that fixed it.

## RV32I46F_5SP Debugging (Post-Branch Misprediction issue)
### [2025.05.31.]

> - **Problem** : 
>   - On misprediction it should branch to the EX-computed branch target
>   - But on the next clock the branch signal is deasserted, so **PC Controller** updates IF’s `PC` with `PC+4`.  

- **Resolution** : 
    - [2025.05.27.] ## Branching to Actual Branch Address when prediction fail

- **Notes** : 
    - We could put a combinational adder in the Predictor to add the EX imm and pc to get the actual branch address
    - Decided to keep the Predictor simple
        - Just IF-stage prediction and EX-result-based update—to keep module boundaries clean, and to include the computation in Branch Logic.

## RV32I46F_5SP Debugging (Forward Unit WB-Stage Data Forwarding issue)
### [2025.05.31.]

> - **Problem** : 
>   - WB forwarding not working

- **Resolution** : 
    - Looking at the top module, `alu_forward_source_select` only forwarded from MEM
    - Solved.

> - **Revealed Problem** : 
>   - `alu_forward_source_select_{a,b}` weren’t changing at that timing
>   - They staying at 0

- **Resoning** : 
    - `hazard_wb` should have asserted from the **Hazard Unit**, 
        - But since nothing changed it looks like the WB-forwarding condition wasn’t detected
        - So `hazard_wb` never fired. 
    - Looking closely at the waveforms: 
        - The problematic `EX_rs1` was `0c`, but `WB_rd` was different
        - So there was no hazard—that logic was fine.  
    - The real issue: 
        - In the `xor` instruction, the `rd` from a completed `sll` is already in the **Register File** after WB
        - And `WB_rd` now belongs to the next instruction, so the hazard detector won’t see it.  

    - The data is already being written into the **Register File**
        - But the EX stage wants to read that same register in the same clock before the write “takes.”  

- **Resolution** : 
    - Added a write-through bypass in the **Register File**:
        - When WB writes the same register being read, the read data = write data in that cycle.  
    - Fixed!

## RV32I46F_5SP Debugging (CSR data forwarding issue)
### [2025.05.31.]

- Issue 
    - Since CSR instructions read and write CSR in one go, this pops up. 
    - In single cycle, `csrrs` writes `0x2fc` to `mepc`, then a `csrrc` immediately reads `mepc`; 
Zicsr hazards happen even when rs overlaps, not just `rd`. 
    - Resolved by adding CSR forwarding support to the **forwarding** and **hazard unit**s.

## RV32I46F_5SP Debugging (PTH `mtvec` read-jump issue)

> - **Problem Context** : 
>   - From the waveforms: 
>      - `ECALL` is detected in **Instruction Decoder** by the **Exception Detector**
>      - trap_status goes to 010 (ECALL), and PTH proceeds inside the Trap Controller as designed.  
>   - But when **PTH** ends, reading `mtvec` from `CSR address 305` should yield `0x0000_1000` and it should jump there. 
>       - We did set `csr_trap_address=305`, but the read came back `0x0000_0000`.  
>       - Meanwhile in the misaligned **PTH**, requesting 305 does return `0x0000_1000` and we jump correctly. 

> - **Problem** : 
>   - In **PC Controller**, trapped is asserted, but `csr_read_data` arriving at PCC is `0x0000_0000`
>   - So the wrong instruction starts down the pipe from IF.

- **Resolution** : 
    - Solved it by having the **Hazard Unit** raise `IF_ID_Flush` when trapped is asserted. 
    - Solved.

## RV32I46F_5SP Debugging (CSR File Read/Write splited address structure issue)
### [2025.05.31.]

> - **Problem** : 
>   - An address read in ID wasn’t producing a value until WB.  

- **Reasoning** : 
    - For non-write operations I want to use the ID-decoded raw_imm as the CSR address,
        - But the current top-module code feeds the WB-stage address, which causes this issue.  
    - To execute instructions correctly, CSR values must appear immediately for the address presented, 
        - but we were handing it WB’s address instead—fine in single cycle, not here.  
    - The fix is to give the CSR File separate ports for read address and write address (like the general Register File), 
        - so reads/writes don’t race.  
    - Also, the **Trap Controller** accesses the **CSR File** during **PTH** and must write to CSR immediately.
        - Even if we add a dedicated write-address port, WB will also be writing CSR on Zicsr results. 
    
    - On a trap we stall the pipeline, but could WB’s write address conflict with **Trap Controller**’s?  
        - And the **Trap Controller** currently uses a single `csr_trap_address` for both CSR reads and writes.  
    - This suggests splitting the **Trap Controller**’s CSR address outputs into separate read and write ports, and likewise splitting the CSR’s write-address ports between **Trap Controller** and WB.  

    - Do we also need to tell **CSR File** whether the access is for **PTH** (e.g., by adding trap_done as an input)?
        - No—WB-stage CSR ops are already in flight before trap detection, and our logic completes in-flight instructions before handling the trap. 
        - So there’s no conflict.   

- **Resolution** : 
    - Solved it by splitting the CSR’s address inputs into separate `read-address` and `write-address` ports.
    - Solved.

## RV32I46F_5SP Debugging (FPGA Implementation; Vivado)
### [2025.06.01.]
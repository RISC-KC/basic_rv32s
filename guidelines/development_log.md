# RISC-V RV32I Processor Development Log
The architecture design evolution is from **37F**, **43F**, **46F**, to **46F5SP**. 
Make sure to read the tutorials for optimal learning experience.
Some of the translation were done with ChatGPT 5-Thinking: Standard.

## Pre-CPU (Process before the 37F base architecture)

### [2024.12.14.]
- ChoiCube84 implemented **Program Counter** module in VerilogHDL, RTL source code.

### [2024.12.15.]
- Block Diagram tool has been decided to **draw.io**.  

- Designed Program Counter, Instruction Memory, Register File datapath  
![Start_Design](/diagrams/design_archive/Pre-CPU/RV32I_decoding.drawio.png)

- Control Unit development start  
-> Realizing that it's complex module, decided to delay until the base modules and datapaths are designed for executing the instruction. 

- ALUopcode idea  
We thought that ALU should be only performing the Arithmetic and Logic calculations.  
The operation decision should be separated from the main ALU since we do not actually know about what kind of calculations can be extended. So, KHWL thought we need **ALU decoder**<sup>1</sup> which controls the behavior of **ALU**, and this became the main idea of ALU operation code; ALUopcode= **ALUop signal.**  
<sup> 1. This **ALU decoder** further becomes **ALU Controller**

### [2024.12.18.]
- Added decoding signal path in block diagram. Instruction Memory Read Data to Register File.
![Signal_Decoded](/diagrams/design_archive/Pre-CPU/RV32I_rf.drawio.png)

### [2024.12.20.]
- Added **Instruction Decoder**, **ALU Controller**, **Control Unit**, **Register File Write Data Source MUX** module block diagram.  

- Revised **Register File** block's I/O signals. (Read Address1, Read Address2, Write Address, Write Data, clk, Write Enable, Read Data1, Read Data2)
![ID_CU_RF_ACU_ALU](/diagrams/design_archive/Pre-CPU/RV32I_id_CU_RF_ACU_ALU.drawio.png)

- We can just divide the signals from instruction, but for intuitive design and easy understanding, we've made **Instruction Decoder** module block indepedently.  

### [2024.12.21.]
- Added **Data Memory** module block
- **Register File Write Data MUX(Reg_WD_MUX)** gets ALU result, Data Memory Read Data, Next PC address.
![Signal_Connected_RV32I](/diagrams/design_archive/Pre-CPU/RV32I_Signals.drawio.png)


### [2024.12.22.]
Making the block diagram down to signal-level. 
- Added **immediate generator** module block for zero/sign-extension the immediate value from instruction decoder.  

- Added **Branch Logic** module block for checking if ALUresult is zero for recognizing if branch instruction's condition is true.  

![added_imm_gen_branch_logic](/diagrams/design_archive/Pre-CPU/RV32I_Branch.drawio.png)

### [2024.12.23.]
- Added **pc_plus_4** module block for intuitiveness. It goes to **Reg_WD_MUX**. in RISC-V RV32I, some (un)conditional branch instructions and U-Type instructions requires to write pc+4 value to register with the instruction main behavior.

<sup> I think this should be merged to **Reg_WD_MUX** in FPGA RTL codes. The intuitiveness should only be in block diagram and learning design. Not in actual core synthesis.</sup>

![added_pc_plus_4_reg_mux](/diagrams/design_archive/Pre-CPU/RV32I_Branch_PC4.drawio.png)

- Added draft **PC Controller** module block in core diagram.  
To execute the (un)conditional branch instructions, such as J-Type, B-Type instruction, KHWL thought there should be an separate control logic unit for PC value control. **Program Counter** should only perform as the register that holds current instruction's instruction memory address. 

![added_PCC](/diagrams/design_archive/Pre-CPU/RV32I_Branch_PCCon.drawio.png)

### [2024.12.24.]
- The logic idea of **PC Controller**  
.1. Receive current PC value and jump, branch instruction notice signal and corresponding target pc address signal  
.2. Decide whether it's jump, branch instruction or normal instruction and output the corresponding `next_pc` signal.  

If it's jump, branch; `next_pc` is `jump_target`, `branch_target` respectively, if it's neither one of those, `next_pc` is currnet pc value + 4.

Considered about designing the `next_pc` selection logic MUX outside of **PC Controller**.

![reviesed_PCC](/diagrams/design_archive/Pre-CPU/RV32I_PCcon_nextpcMUX(1).drawio.png)

### [2024.12.25.]
- Confirmization of initial **PC Controller** module block design  
Decided to integrated the `next_pc` selection logic MUX in **PC Controller**.

- Misunderstood about jump target address. In diagram `RV32I_PCcon_Branch.drawio`, jump target is from alu_result and ex-imm (extended immediate value from Immediate Generator module) 

- Added detail for **Branch Logic**-**PC Controller** datapath since the PC logic has been decided.
![Detailed_Branch_Logic](/diagrams/design_archive/Pre-CPU/RV32I_PCcon_Branch.drawio.png)

### [2024.01.02.]
- Organized PC Controller signal input
![Organize_PCC_signal](/diagrams/design_archive/Pre-CPU/RV32I_PCcon_Branch2.drawio.png/)

## 37F Architecture Development

### [2024.01.04.]
- The first draft version of RV32I37F Architecture designed
![Pre-RV32I37F](/diagrams/design_archive/Pre-CPU/FirsteverRV32Iown.drawio.png)
- PC Controller is now viewed as a module
- NZCV Flag signals was an input of Branch Logic from the output of ALU. 
(Removed since RISC-V doesn't require NZCV unlike ARM.)
(Main idea was from IDEC lecture about RISC-V CPU introduction and FPGA implementation by Y. W. Kim.)

|Name|Inputs|Outputs|Signals|
|:---|:---|:---|:---:|
|**Modules**|
|Program Counter| CLK, NextPC, reset|PC|3+1=4|
|PC Controller|PC, jump, branch_taken, jump_target, branch_target|NextPC|5+1=6|
|Instruction Memory|PC|IM_RD|1+1=2|
|Instruction Decoder|IM_RD|opcode, funct3, funct7, rs1, rs2, rd, imm|1+7=8|
|Register File|CLK, RA1, RA2, RW, WA, RF_WD|RD1, RD2|6+2=8|
|Data Memory|CLK, reset, MemWrite, MemRead, DM_WD, ALUresult|DM_RD|6+1=7|
|Control Unit|opcode|ALUsrcA, ALUsrcB, ALUop, Branch, Jump, MemWrite, MemRead, Memory2Reg, RegWrite|1+9=10|
|ALU Controller|ALUop, funct3, funct7|ALUcontrol|3+1=4|
|ALU|ALUcontrol, srcA, srcB|NZCV, ALUresult|3+2=5|
|Branch Logic|Branch, NZCV, funct3|branch_Taken|3+1=4|
|PCplus4|PC, 4|pc_plus_4|2+1=3|
|Immediate Generator|imm|ex_imm|1+1=2|
|**MUXs**|
|ALUsrcMUX_A|ALUsrcA, RD1, PC|srcA|3+1=4|
|ALUsrcMUX_B|ALUsrcB, RD2, ex_imm|srcB|3+1=4|
|RegF_WD_MUX|Mem2Reg, ALUresult, DM_RD, PC+4|RF_WD|4+1=5|

Total 15 Modules, 40 Signals.

### [2024.01.05.]
- Organized signal routing of Block Diagram.
![signal_organized_Pre-CPU](/diagrams/design_archive/Pre-CPU/RV32I_OrganizedSignals_A4_Signed_B.drawio.png)

Each signal's explainations
각 신호에 대한 설명
(CLK, rst
PC, NextPC, PC+4
Jump, Branch, BTaken, J_Target, B_Target, 
IM_RD, 
opcode, funct3, funct7, rs1, rs2, rd, imm, 
RA1, RA2, RW, WA, RF_WD, RD1, RD2, 
MW, MR, DM_WD, ALUresult, DM_RD, 
ALUsrcA, ALUsrcB, ALUop, M2R, 
ALUcontrol, srcA, srcB, NZCV, ALUresult
ex_imm)

- CLK = CLocK
- PC = Program Counter address (32-bit)
- NextPC = Next PC address (32-bit)
- PC+4 = PC address + 4 (32-bit)
- Jump = 	Whether Jump(J-Type) Instruction is operating or not. Decides PCC to select which signal should be NextPC.   
If true, NextPC = J_Target
- Branch = Whether Branch(B-Type) Instruction is operating or not. Enables Branch Logic's calculation.
- BTaken = Whether Branch(B-Type) Instruction's condition is satisfied or not. Decides PCC to select which signal should be NextPC.   
If true, NextPC = B_Target
- J_Target = If Jump is true, NextPC Address. NextPC = PC + imm(32-bit)
- B_Target = If Branch is true, NextPC Address NextPC = PC + imm(32-bit)
- IM_RD = Instruction Memory_Read Data.
		32-bit Instruction read from Instruction Memory, recognized with PC.
- opcode = opcode from IM_RD
- funct3 = additional opcode domain. specifies calculation variation.   
(If I-Type, add, sub..etc is decided by funct3 domain.)
- funct7 = additional opcode domain. If funct3 are same, funct7 does the distinction.
- rs1 = register source 1. The data that came from 32-bit instruction.
- rs2 = register source 2. same as rs1.
- rd = register destination. The destination address of register. 
- imm = immediate value. Varies by the type of Instruction. Usually used after extension by Immediate Generator Module.
- ex_imm = 32-bit sign-extended immediate value.
- RA1 = Read Address to Register File. 
- RA2 = same as RA1.
- RW = Register Write;RegWrite. Enables Register's write operation.
- WA = Write Address. Destination address of Register's write operation.
- RF_WD = Register File_Write Data. A data to write in Register File.   
Usually selected between ALUresult, DM_RD, PC+4. By RegF_WD_MUX.
- RD1 = Data that has read from Register File. 
- RD2 = Same as RD1.
- MemWrite = Memory Write. Enables Memory's write operation.
- MemRead = Memory Read. Enables Memory's Read operation.   
Unlike Register File, Data Memory's Read operation should be conditioned. Due to Load store operation. They should not crash each other.
- DM_WD = Data Memory_Write Data. The data that's going to write in Data Memory. Usually from the Register File.
- ALUresult = ALU's calculation result data. Usually goes to PCC for the Branch/Jump operation, or DataMemory or Register File to store data.
- DM_RD = Data Memory_Read Data. The data that has read from Data Memory.
- ALUop = ALU's base operation code from Control Unit. Inputs ALU controller Module.
- ALUcontrol = ALU's actual operation signal. From the ALU Control Module, decides which operation should ALU do.
- ALUsrcA = ALU's calculation source A. Decided by the ALUsrcMUX_A between RD1 and PC.
- ALUsrcB = Same as ALUsrcA. Decided by the ALUsrcMUX_B between RD2 and ex-imm.
- srcA = Decided ALUsrcMUX_A's data.
- srcB = Decided ALUsrcMUX_B's data.
- Mem2Reg = Memory to Register. A signal that decides which data should be written in Register File by RegF_WD_MUX. 
- NZCV = Negative, Zero, Carry, oVerflow. Flag signal.  
Usually outputs zero signal to Branch Logic to check if the branch condition is satisfied.

#### Things to revise
1. RV32I doesn't need NZCV flags according to the ISA Manual.   
→ **Revise NZCV in ALU to ALUzero signal**
2. We need module for aligning 2-bit of LSB for `jalr` instruction's J_Target calculation.  
→ Design idea for **PC Aligner**
3. We must specify which module should use CLK, reset signal
4. For `Register File`and `Data Memory`'s write operations, data stores not only 4bytes but also 2-1bytes by `lw`, `lh`, `lb`, `sw`, `sh`, `sb` instructions. Since typical data's length is 32-bit, there's possibility that 2 or 1 byte operations could be done in the middle of those bits. such as 0000_AA00, AA00_0000 (A is the source data to write).  
→ Design idea for **Byte Enable Logic**  
Using a `write_mask` signal for encoding the location of the data to be stored. e.g.) mask: 0011 = 0000_AAAA, 0100 = 00AA_0000

- Added **J_Aligner** module for forcefully aligning `J_Target` jump target address' 2-bit LSB to 00, preventing misalignment in jump instruction.
![RV32I37_J_Aligner](/diagrams/design_archive/RV32I37F/RV32I37_J_Aligned.drawio.png)

- Added **Byte Enable Logic** module for partial load and store instruction. Such as lh, lhu, lb, lbu, sb, sh.
![RV32I37_BE_Logic](/diagrams/design_archive/RV32I37F/RV32I37_BE_Logic.drawio%20(1).png)

## 43F Architecture Development
### [2025.01.06.]
- Designed **CSR File** module's draft
The first purpose of adapting CSR was for implementing OS, but sooner, the main reason became for supporting the full RV32I ISA. ECALL, EBREAK instructions are handled with exception or trap, which requires Control & Status Register for handling. Also following the basics of Computer Architecture, just like other ISAs, CSR is required.
- We were referencing the RISC-V Instruction Set Manual Volume I: Unprivilged ISA Document version 2.2 which includes CSR instructions and fence.i instruction in base RV32I

![RV32I37_CSR_Draft](/diagrams/design_archive/RV32I37F/RV32I37_CSR.drawio.png)

- While verifying the datapath of ADD instruction, we found that the **Register File**'s design is awkward.  
	- The data signal which receives from RegF_WD_MUX's name is RF_RD(Register File Read Data)  
	- It outputs the data to **Byte Enable Logic** and **Data Memory**. This datapath could be optimized with **Register File**'s Read Data output `RD2` since the store instruction's description is `M[R[rs1]+imm] = R[rs2]`

### [2025.01.11.]
- Optimized **Register File** - **Data Memory** - **Byte Enable Logic** datapath as mentioned. (using RD2 signal)
- Added `CSR_Enable` signal to CSR File <sub> It removed later on, to streamline the signals for reducing complexity</sub>

![RV32I37_fixedBE_CSR](/diagrams/design_archive/RV32I37F/RV32I37_fixedBE_CSR.drawio.png)

Designing the **CSR File** for CSR instructions. 
- Added CLK and reset signal since the register flie's behavior should be synchronous for data signal stability (such as Read after Write)
- Designed **CSR File**'s write data signal `CSR_WD`'s datapath.   
	- For CSR-Register instructions (CSRRW, CSRRS, CSRRC), it receives **ALU**'s `alu_result` signal.   
	Which means, it bypasses `RD1` signal from `ALUsrcA` to `alu_result`, forwarding to **CSR File**'s `CSR_WD`.
	CSR-immediate instruction - CSRRW: R[rd] = CSR, CSR = R[rs1]
	- For immediate-CSR instructions (CSRRWI, CSRRSI, CSRRCI), it receives **Immediate Generator**'s `ex-imm`.   
	Immediate-CSR instructoin - CSRRWI: R[rd] = CSR, CSR = imm
	- These two data for CSR File's input is selected from CSR_WD_MUX.

![RV32I37_CSR_Ongoing](/diagrams/design_archive/RV32I37F/RV32I37_CSRongoing.drawio.png)

- To implement CSR Instruction's `R[rd] = CSR`, connection between **CSR File** - **RegF_WD_MUX** has been designed.
- To implement CSR-Register, CSR-immediate calculation (CSRRS, CSRRC, CSRRSI, CSRRCI)
Added `CSR_RD` signal to ALUsrcA, ALUsrcB MUXs. ALUsrcA CSR for CSR-imm calculation, ALUsrcB for CSR-Register calculation

![RV32I37_CSR_Ongoing](/diagrams/design_archive/RV32I37F/RV32I37_EBREAKnFENCE.drawio.png)

- Optimized signal for legibility
![RV32I37_CSR_Optimized](/diagrams/design_archive/RV32I37F/RV32I37O_debugs.drawio.png)

### [2025.01.12.]

Noticed that FENCE, FENCE.i, EBREAK, ECALL instructions are SYSTEM instruction while designing full RV32I compliant architecture (version 2.2). 
- To implement FENCE.i, we need cache structure.
- To implement FENCE, we need multi-hart system architecture.

These changes requires expanding the design.  
Since we have not RTL implement and verificated the design, expanding to those structures enlarges milestone too far.  

- For this reason, we choose to exclude 4 instructions(FENCE, FENCE.i, EBREAK, ECALL) and design 43 instruction supported arhitecture. 
- Which is RV32I43O, 43 architecture. 
<sub>O stands for Optimized signals.</sub>
![RV32I43O](/diagrams/design_archive/RV32I43F/RV32I43O_Final.drawio.png)

For RTL implementation, the Back-end, ChoiCube84 should be fully aware of the modules and signals purposes, there should be documents about modules and signal logics. 
This also reviews the progress.

After making the specification document, ChoiCube will follow up implementing the RTL. 
I will try to make Top Module view about block diagram for Core-Memory Units, and interfaces when some time lefts.

Our final destination is making RV32G for Operating System support, it seems like FENCE instructions and Environment instructions(ECALL, EBREAK) are mandatory. 
Once the verification with the core's RTL simulation is done, I'll try to design those instructions, and if it's expected to take so long, we'll jump to 5-stage pipelining. 

Making the specifications document is done. Now working on Top module block diagram.

## 47F Architecture Development

### [2025.01.17.]
Worked on Top module block diagram draft. 
![Draft_top-module-block](/diagrams/design_archive/TopModule/COREnMEMC.drawio.png)

### [2025.01.18.]
Worked on Top module block diagram draft.
![Draft_cache_top-module-block](/diagrams/design_archive/TopModule/CnM250118.drawio.png)

Designing Cache. According to Memory hierarchy, the top access module of memory is cache memory. Access to cache, if misses, accessing to memory.

[Question1.]
While reviewing the signal scheme: on a Cache Miss, IC (I-Cache; Instruction Cache) sends an IMRead(Instruction Memory Read) request signal to IM (Instruction Memory) to fetch an instruction. Is it correct for “a mere memory” to originate such a control request?

[Question 2.]
Previously, the Instruction Decoder consumed data directly from Instruction Memory.
Now that I-Cache is added, does IM receive two inputs controlled by a MUX and control signals?
—or—according to memory hierarchy principles, on a Cache Miss we search from IM, update I-Cache and then fetch the instruction so the data can be reused frequently?

[Question 3.]
If we update IC with IM data on a Cache Miss, don’t we need extra control logic?
(e.g., on a miss, which IC index/tag to store IM’s data into, and by what replacement/placement algorithm?)

Blind spot: RV32I has no ISA to explicitly control caches. I may need to look up extension instructions one by one. CMO?
└ Likely we must implement this ourselves.

- On an IC→IM miss path, IC and IM have different structures, hence different request address formats. We’ll need a module to translate addresses, plus address signals and read-control signals appropriate for each side.

- Finding: For Question 2, the latter is correct (update I-Cache after IM fetch). 
Question 1 can be handled by MemCon.

- Address mapping between memory and cache has three styles: Direct-Mapped, Fully-Associative, and Set-Associative. ChoiCube84 must also consider this carefully—this is logic work.

1. On a cache miss, MemCon converts the address for Memory, forwards it, receives the returned data, and passes it to ID (Instruction Decoder). (Possibly could bypass MemCon, but…)

2. Because we must also update the cache with (1), MemCon supplies the computed cache address and the data to store. Do we assert write-enable here as well? How exactly does MemCon compute that address?



### [2025.01.19.]
Still implementing the Cache. 
![Draft2_cache_top-module-block](/diagrams/design_archive/TopModule/CnM250119.drawio.png)

1. The address systems of Cache and Memory differ.
The existing IM stored raw 32-bit words in chunks of 4, but the Cache must be organized differently (this is the Cache Line unit).
Therefore, on a cache miss, send the cache’s address to the `Memory Controller` to convert it into `Instruction Memory`’s address format; `Memory Controller` requests data from `Instruction Memory` with that converted address, and `Instruction Memory` returns the data to `Memory Controller`.
`MemC` forwards it to `Instruction Decoder` and also updates `Instruction Cache`—stores the data at the cache address computed by the logic to refresh the cache.

Cache Line structure.
The existing PC granularity follows IM as implemented, but the Cache is like a pocket that keeps a bunch of likely-to-be-reused instructions ready to serve.
So, when fetching with PC = 0x00, the cache stores 0x00, 0x04, 0x08, 0x0C (four consecutive instructions) at once.
That makes the cache line size 16 bytes. On the next instruction, we get a cache hit, reducing memory accesses and making it much faster. Also, compared to implementing IC with the IM address scheme as-is, this reduces miss frequency and improves performance.

The sequence is as follows:
- Bring the PC value into IC.
- Extract the Index to select a cache line.
- Use the Tag inside that line to identify and output the target data.
- On a cache miss, fetch a whole cache line from IM and update the cache.

Perhaps the split between memory and cache is due to physical properties.
If both had the same memory structure and identical device characteristics, there’d be no point in separating them; direct-mapped address→data access would be equivalent, and direct might even be better.
But they differ, and cache is faster than general memory—hence this arrangement.

[Additional question.]
Running an OS means the stream of instructions changes constantly. In that case, shouldn’t IM or IC not be ROM?

-----
#### [2025.01.19 Meeting]

Explained and aligned with ChoiCube84 on the basics of the memory hierarchy.
Materials on cache structures and policies:
https://velog.io/@khsfun0312/%EC%BA%90%EC%8B%9C-%EC%A0%95%EC%B1%85%EC%95%8C%EA%B3%A0%EB%A6%AC%EC%A6%98

Agenda: boot-time operation of Instruction Cache / Instruction Memory.
At first, start with IC empty (zero cold start), let it miss naturally, use it, and keep updating.
After the final development stage, try switching the logic: sequentially pre-load IM’s instructions to fully fill IC in advance.
Observing the performance delta between these two should itself be paper-worthy—another line of inquiry.

To-do now:
1. Define the signal scheme of the Instruction Cache.
2. Understand the cache structure on the Data side.
3. Based on the understanding of both caches, define and implement MemC’s signal scheme.
Add these blocks to RV32I43O to complete RV32I47F.
Complete the block diagram at the top-module level with Core–Memory separation.

Search reference designs for future RV32G expansion:
Rocket core, PicoRV, Riscy.

Proposed reordering: apply 5-stage pipelining after RV32G?
After discussion, we decided splitting an already-complex single-cycle module later would be harder. Keep the current roadmap:
(RV32I → 5SP RV32I → 5SP RV32G → 7SP+ RV32G)

Asked ChoiCube84 to begin with RV32I43O; cache structures are not the hard part later (just signal adjustments and new modules).

-----

#### Development log.  
Mastered Instruction Cache / Memory structure.  
Instruction Datapath.

1. Instruction Cache.  
Role: accept an address and return the instruction to ID.  
If the address is not present, assert a Cache Miss signal to MemC.  
Output the PC address as-is to IM and MemC.  
Return the data found in IM back to IC (Up_Data).  
Simultaneously drive IM’s data directly to ID.  
MemC computes, based on PC, which IC address to store the instruction in.  
Store Up_Data into that IC address (update complete).  

[inputs]
- PC (addr) — of course.  
- MemWrite — write-enable. Comes from CU. Same for MemRead.  
- MemRead — read-enable. Separated to avoid read/write conflicts.  
- Up_Data — data for cache update on miss. Comes from IM.  
- Up_Addr — address to update on miss. Comes from MemC.  
But honestly, MemWrite/MemRead aren’t necessary. If PC is present, it’s a read; on miss, it’s a write.  

PC, Up_Data, Up_Addr — these three inputs are sufficient.  

[outputs]
- PC (addr) — pass the address through to IM on cache miss.
- IC_RD — on a cache hit, output directly to ID.
- IC_Status — 0 = hit, 1 = miss. Sent to MemC.

★Proposal to ChoiCube84★
Considering whether to split IC_Status into I.C_Hit and I.C_Miss.  
Since the default is Hit and only Miss needs extra handling, keeping a single Status that briefly flips to 1 on Miss might be better. But if a split is cleaner, please suggest freely.

2. Instruction Memory.
Role: when a cache miss occurs, accept the address and return the instruction to ID.  
Accept the PC value output from IC to MemC as-is.  
Output the data both to IC’s Up_Data and directly to ID (for cache update).  

[inputs]
- IM_Addr — exactly the PC value.
- IM_RD — data signal returned to ID and output to IC for update.

3. IC.IM_MUX
Purpose: when a cache miss triggers an IM lookup, allow IM’s data to go straight to ID rather than passing through IC.  
Role: when IC_Status is 1 (MemC recognizes a cache miss), MemC drives the control so that IM_RD (IM’s data) is selected into ID.  
If it’s a cache hit, keep 00 (default): select IC_RD (IC’s data) into ID.

[inputs]
- IM_RD, IC_RD
- IC.IM_MUX — 00 for cache hit → select IC_RD; 01 for cache miss → select IM_RD.

[outputs]
- Found_Instruction — one of {IC_RD, IM_RD}.

Time to examine the Data memory structure.  
Since Instruction Memory behaves like a simple ROM, there weren’t major changes.  
But Data Memory includes many signals: write/read enables, byte-aligning mask for data, write data/address, and read data output.  
With D-Cache added, we must determine how these change.  

For now, I’ve finished the top-module-level block diagram for Instruction Memory / Cache.  
![Draft3_cache_top-module-block](/diagrams/design_archive/TopModule/DataCacheMem250119.drawio.png)

### [2025.01.20.]
Raised issue & ChoiCube84’s suggestion:  
“`CSR_addr` from the Instruction Decoder is unnecessary.”  
Upon review, CSR instructions follow the I-Type bit layout; pass the Imm field directly as the CSR address to the CSR File module.  
Applied this to RV32I43O: removed `CSR_addr` and wired `imm` to the CSR File’s `CSR_addr` input.  

Additionally, while verifying datapaths for CSR instructions, I considered ALU logic.  
CSR either returns a CSR value to the register file or writes a value from the register file (or imm) to CSR. In the current design, `RD1`/`RD2` always pass through the ALU (except for BE_Logic).  
I briefly considered returning `rs1` straight into CSR, but that would break logical consistency and worsen efficiency (and increase complexity).  
Therefore, the ALU should take `rs1` as `srcA` and either bypass it or operate with `0` to output `rs1` unchanged.  
I thought about adding a `0` input to the `ALUsrcB` MUX, but concluded it’s better to add a bypass path inside the ALU itself to output directly.  
This removes extra operations, reduces delay, and preserves the usefulness of separating by `ALUop` (ALU functionality beyond pure ISA ops).  

Today’s tasks: finalize the Memory/Cache side for Data; reflect the Instruction-side cache structure in RV32I43O.  

A question that came to mind:  
When a cache miss requires a Memory reference, why not feed the address to both modules from the start—i.e., have Memory already searching even before the miss is known, and on miss simply use the already-issued address so Memory can return immediately?  
Is this discarded because it causes problems later in pipelining? Or is there a practical hybrid that’s actually used? Given the drive to minimize latency and maximize parallelism, this must have been discussed.  

Pros/cons (as expected), with some refinements:
Pros

* Even if a cache miss occurs, the lower level Memory read is already in-flight → greatly reduces miss penalty.  
* Increases parallelism.  

Cons (issues I anticipated at pipeline stages)

1. Cache–Memory synchronization becomes complex.  
2. Stall likelihood increases.  
   Additional potential issues learned:  
3. Inefficient memory bandwidth usage; can become a bottleneck on multi-core.  
4. Energy loss from unnecessary work on cache hits (extra memory access significantly increases power).  

Mitigations: conditional parallel access.  

1. Allow parallel access only when the critical word is a subset of the cache line.  
2. Prefetching: predict cache misses similarly to branch prediction and fetch data from memory in advance. Not parallel access per se, but can achieve a similar effect.  

We should consider a prefetching logic later. RV32“G” expansion will include Branch Prediction; could implement it alongside.  

Implemented the Instruction Cache / Memory module structure on the existing RV32I43O.  
Also improved the CSR module name and signals.  
![RV32I43IC](/diagrams/design_archive/RV32I43F/RV32I43IC.drawio.png)

From the previous `DataCacheMem250119` top-level system diagram, designed/implemented a system diagram based on the RV32I47F core with integrated cache structures.  
Supports all 47 RV32I instructions. Close to finishing stage 1 of 4.  
Top-level system diagram is named: **Basic_RV32–S1**.  
Each milestone increments the S-stage. Let’s go.  
![basic_RV32s-s1_top-diagram](/diagrams/design_archive/TopModule/basic_rv32s1f.drawio.png)

RV32I47F is almost done. 
![RV32I43MC_ongoing](/diagrams/design_archive/RV32I43F/RV32I43MC_onging.drawio.png)

### [2025.01.21.]
RV32I47Prototype complete at 19:58.   
![RV32I47Proto](/diagrams/design_archive/RV32I47F/RV32I47Prototype.drawio.png)

Since the original diagram wasn’t designed with a Cache–Memory structure in mind, the signal graph became quite complex, but I managed to implement it.  
At the same time, I cleaned up and optimized the signal scheme of Basic_RV32_S1. Filename: Basic_RV32_S1_o (20:24).  
![basic_RV32_s1_o](/diagrams/design_archive/TopModule/basic_rv32s1_o.drawio.png)

With this, a design “draft” of a processor supporting all 47 RV32I instructions is complete.  
Next: implement based on this and verify each instruction—then it’s done.  

Next steps likely include implementing cache and branch prediction…  

Today I’ll summarize the processor features and write basic validation + module notes for the Cache structure.  

- Feature 1.
[Conditional Direct Memory Fetch.]  

Existing flow on cache miss:  
Memory lookup, data fetch → update Cache with fetched data → output data from the updated Cache.  

Changed flow:  
Memory lookup, data fetch → output data directly → update Cache with the fetched data  

Unlike the old structure, which waited for the cache update and then had the cache output the data, the Memory now outputs to both the Cache and the destination, performing the cache write and the data output in parallel to reduce latency.  
Added a MUX in front of each destination to select the data source; the `Memory Controller` drives these MUXes (one for Instruction side, one for Data side—two total).  
When `MemC` sees a Miss in the Status signal, it drives the MUX to 01, i.e., select Memory.  
Timing must be tuned: there’s a delay from miss detection to Memory returning data at that address, so either delay the 01 select into the MUX or hold the control long enough so a valid value is presented to the MUX input.  

- Feature 2.
[ALU Controller]

Introduced a dedicated control unit that only governs ALU behavior to improve clarity and maintainability. Beyond ISA-defined ops, the developer can “program” control signals for custom handling.  
In this core, CSR instructions that would otherwise perform an add with 0 through the ALU now use a dedicated Bypass ALUop to forward RD1 unchanged. This trims extra operations, reduces delay, and preserves the value of having distinct ALUops.  

- Feature 3.
[J_Aligner]

A standalone bit-alignment module for the J-type instruction jalr.  
I could have embedded the logic into the PCC, but separating it improved clarity and simplicity.  

- Feature 4.
[Cache Status Signal]

Did not split Hit/Miss into two lines. Single status: 0 = Hit, 1 = Miss.

- Feature 5.
CSR File address uses the I-type immediate directly; no separate CSR_addr from the Instruction Decoder. imm drives CSR_Addr as-is.

- Feature 6.
Implemented the Instruction Decoder as a standalone module for clarity and maintainability.

23:47.
Optimized the placement of modules and signals—the main practical hurdle in integrating the cache beyond conceptual understanding.  
Reduced unnecessary area and made signal placement more readable.  
![RV32I47PO](/diagrams/design_archive/RV32I47F/RV32I47PO.drawio.png)

Tomorrow’s tasks: study cache structures (mapping methods, architecture theory); draft a Core-only unit diagram without Memory modules.  
Study/design/implement the Trap Handler. - ECALL/EBREAK require a Trap Handler design.  
Do basic, per-instruction cache-structure validation; start pipeline implementation.  
Before pipelining, write module and signal descriptions.

### [2025.01.22.]
20:25. Implemented Trap Handler and Exception Detector.  
For now, implemented as follows.  

![RV32I47TH_draft](/diagrams/design_archive/RV32I47F/RV32I47TH.drawio.png)

**Trap Handler (TH)**  
- [inputs]  
`Trap_Status`  
`PC`
`CauseCode`  
`mtvec`  

- [outputs]  
`mepc`  
`mcause`  
`T_Target`  

**Exception Detector (ED)**
- [inputs]  
`I_RD`  

- [outputs]  
`Trap_Status` (unified ECALL-enable / EBREAK-enable into a single status signal)  
`CauseCode`

Time to study the Privileged ISA.   
With Zicsr required right now, I don’t need to know everything yet, but I’m starting to see the pieces—Privileged mode, CSR structure, etc.  
For now, the base TH/ED path for ECALL seems done.   
Next up: implement FENCE.i, FENCE, and EBREAK; currently reading each instruction.  

Design thoughts & improvements during implementation:  
I initially added separate signals to write mepc and mcause, but realized they’re CSR writes—so I decided to feed CSR_addr and CSR_WD into TH instead. This made the design more intuitive.  
Accordingly, added a 2→1 MUX on CSR_addr, and changed CSR_WD to a 3→1 MUX.  
Since CU can determine which exception instruction it is by opcode, CU will drive the control signals for these MUXes.  
Updated the design under RV32I47TH_ongoing.  
I also considered separate identification signals for ECALL vs EBREAK, but unified them into Trap_Status.  

![RV32I47TH_ongoing](/diagrams/design_archive/RV32I47F/RV32I47TH_ongoing.drawio.png)

### [2025.01.23.]
-----
#### Minutes
Topic: ALUop

ChoiCube84’s proposal: 
> Do we really need an ALU control signal?  

—Yes. ALUcontrol: when the opcode indicates an operation is required, this unit decodes it into the form the ALU expects.  

Instruction operation identifiers: funct3, funct7.  
Using these three inputs, determine which operator it is.  

Encode into a simpler code, e.g.:  

- 0001 – add
- 0010 – sub  
Name this code ALUcontrol and feed it to the ALU.  
The ALU then executes using srcA/srcB based on this code.  

> What is the role of ALUop? Is it only ALU enable and Bypass?  

—ALUop is an identifier code that receives the instruction type from the opcode and enables type-specific handling.  

> Then if it’s just the instruction type—there are six types (R, I, S, U, J, B)—isn’t 3 bits enough even if we use all? Why 4 bits?  

—I expected more types with the G extension, but even accounting for that, 3 bits should suffice. System ops like mret follow the R-type structural pattern even if the bit usage differs.  

> If ALUop identifies the instruction type, rename it to Instruction_Type—more intuitive.  

—Agree for inside modules. But on the block diagram, names should reveal the target module and role at a glance without signal tracing; that policy would be broken if this one differed. Also the name is too long.  

> Couldn’t we just prefix the target module at the start, like ALUresult?

—Right, I ran into the same limitation and adopted that style. I’ll do that and shorten the name to Instr.Type.  

Maybe we can compress to 2 bits? If we fold to four instruction-type buckets and still distinguish using funct3/funct7, it might work.  
—OK, I’ll explore feasibility.  

—End of meeting—

-----
#### Development logs
RV32I47TH → RV32I47Fenced.
![RV32I47Fenced](/diagrams/design_archive/RV32I47F/RV32I47Fenced.drawio.png)
Changes
---
1. TrapHandler ↔ Instruction Cache  
Added a signal for FENCE.i (IC invalidation).  
└ Named IC_Clean.

2. Data Cache ↔ Data Memory structure  
Adopted a buffered D-Cache structure.  
Write policy: implement Write-Through first, plan Write-Back later.  
Added buffer→Memory write signals (cache–memory synchronization):  
└ B2M (Buffer to Memory) = B2M_Addr, B2M_Data.  
D-Cache outputs B2M signals, which feed Data Memory.

3. Write path on the Data side  
Previous: RF → BE_L → DataMemory (direct memory write).  
└ Cache was updated only on request—i.e., miss-driven incremental updates.

Revised: `RF → BE_L → D-Cache Buffer → D-Cache →→→ Data Memory`.  
└ The flush from D-Cache to Data Memory is deferred and performed in burst, not immediately after a cache update.  
Reason: direct RF→Memory writes are slower than cache.

Reflections in signals:

- Added DC_WD to Data Cache.
- Data Memory’s DM_WD is replaced by B2M_Data.  
Data arriving via DC_WD lands in the D-Cache buffer first.  
Since the cache/buffer structure is now in place, DM_WD won’t be used for direct writes → replaced.  
(This makes the cache a module-in-module hierarchy rather than a single block; needs its own diagram. Other modules, too.)

!To-do: 

4. FENCE implementation; Data Cache Write_Done  
Given the Buffer–Cache–Memory path, a completion signal is required to mark the end of cache–memory flush for FENCE.  
Added Write_Done (Data Cache → Control Unit).

Today’s work: basic understanding of FENCE, FENCE.i, ECALL, EBREAK.  
Reworked Data Cache–Memory datapath, added buffer structure, set policies.  
└ Added corresponding signals.  

!To-do:  

- We added a Data Cache write-enable (DC_Write)—verify if it’s truly necessary. (CU → Data Cache.)

- Validate semantics, handling, timing, and cases. Since FENCE is a fence, should this go to Trap_Handler rather than CU? Needs investigation.

- Implemented EBREAK (needs verification and datapath simulation), but I need to study RISC-V’s Debug mode, debugger, and debugging interface as described in the mnemonics and spec.

### [2025.01.24.]

#### Research Notes

1. The instruction “type” of **mret** being System refers only to bit usage; the **bit layout (field allocation)** itself is identical to R-type.
   Therefore there is no need (for now) to add a separate System-instruction type to **ALUop**.

2. **ALUop** need not identify all six instruction types; **R, I, S** are sufficient.
   ALU operations split into two categories:
   A. register–register operations
   B. register–immediate(imm) operations
   And B splits by purpose: whether the result is used as **data** or as an **address**.

Mapping to instruction types:

* **R** → register–register
* **I** → register–imm (data)
* **S** → register–imm (address)

Check remaining types (B, U, J) can fold into these:

* **B-type** is a register comparison → falls under **R**.
* **U-type** (`AUIPC`) is `PC + imm` → address → **S**.
* **J-type** likewise `PC + imm` → address → **S**.

Thus **ALUcontrol** can be compressed to three categories, and **Instr.Type (ALUop code)** can be **2 bits**.

3. The Data Cache **write-enable** (Cache_Write) is necessary.
   Without an explicit write-enable, unintended writes may occur; the signal is required to avoid timing confusion. (25.01.23 To-do #1.)

4. With a **buffered** cache now in place, add control signals to **flush buffer and cache**.
   Flush-enable, and address/data for flush (`Flush_Addr`, `Flush_Data`).
   +++ To-do: study **Dirty Bit** logic (my cache-architecture understanding isn’t at target depth yet).

We should implement **buffer→cache flush** first; **cache→memory flush** can wait because we’re currently **write-through**. We can change later.

5. Meaning and routing of **Write_Done**.
   `FENCE` waits until all writes complete, so a “write completed” signal is essential. As expected, once `FENCE` finishes memory work, PC updates and the next instruction executes.
   This is not an exception case, so it’s handled by the **Control Unit**, not the Trap Handler.
   `Write_Done` should enter the CU; when CU recognizes Data Cache write/read completion, it updates `PC` to `NextPC` to continue.

Refinement.
`FENCE` guarantees data consistency by **finishing memory writes**; i.e., it halts further data ops and synchronizes memory.
Therefore the PC update must occur **after** `Write_Done`, which is the **PCC**’s domain.
Clarify signal flow: CU decodes `FENCE` by opcode and asserts **Fence_Enable** to PCC to **halt NextPC output** (pause PC update).
After memory work completes, `Write_Done` goes to PCC; then PCC resumes and outputs `NextPC` to update PC.

New signal scheme:

* **Control Unit outputs**: `+FenceD` (add), `-Write_Done` (moved to PCC)
* **PCC inputs**: `+FenceD`, `Write_Done`

(This may also let PCC control PC updates for Trap Handler later—similar concept.)

6. Understanding the **EBREAK** system.
   What is “debug”? Executing something like `EBREAK` to halt the current program sequence, suspend normal flow at the break point, and perform separate work.
   On `EBREAK`, halt the original program flow at the current PC: store current `PC` in CSR **mepc** and stop automatic PC updates.
   The CPU then **waits** at that state until the user injects commands.
   A **debug interface** bridges an external debugger and the CPU, and a **debug control unit** governs debug actions.

When **debug mode** is active, PC is frozen; the user can perform operations not in the program’s planned flow to read/modify state.
For example, after `EBREAK`, an injected `add x6, x7, x10` is fed directly to the Instruction Decoder—**without** going through PC or I-Cache/Memory.
After debugging ends, execute **mret** to output **mepc** as **NextPC** in the PCC and return to the original flow—exiting debug mode.

[EBREAK detection]

* `I_RD` into Instruction Decoder and Exception Detector.
* Exception Detector detects `EBREAK` → outputs `Trap_Status = 10`.
* Trap Handler detects via `Trap_Status` → writes `mepc`, `mcause` to CSR via `CSR_Addr`, `CSR_Data`.

[PC update stop sequence]

* Activate debug mode → PCC stops `NextPC` output.

[Debugging]

* External debugger injects `add x7, x5, x6` via the debug interface.
* Interface drives the instruction to the Instruction Decoder.
* CPU executes; registers/memory change accordingly.

[Exit debug]

* Debugger finishes and executes **mret**.
* Trap Handler …
  just when I thought I was almost done—what is **mtvec** again…

##### —Emergency meeting—

`mtvec` is a CSR holding the **start address** of the Trap Handler.
“Start address”??? So the Trap Handler isn’t a *module*?
Right… when an exception occurs, you need a **routine** to handle it. I had treated “Trap Handler” as a hardware module, and didn’t realize the handler itself is **software**.
From ChoiCube84’s software-debugging input I learned we can **program** the Trap Handler to change the initial actions on a trap.
Mental stabilized. Reflecting that info below.
—End of emergency meeting—

The **Trap Handler routine** executes **after switching to debug mode**, before interacting with the external debugger.
Since it’s a **software routine**, the CPU jumps to the CSR `mtvec` address designated by the Trap_Control module and runs the Trap_Handler code.
— To-do: I likely need to write this Trap_Handler routine.

![RV32I47_EBREAK](/diagrams/design_archive/RV32I47F/RV32I47EB.drawio.png)

**[Trap_Handler responsibilities]**

0. **CSR update**
   Trap_Control stores the current CPU state (e.g., `mepc`, `mcause`) into CSRs.
   This CSR update is performed by Trap_Control **before** Trap Handler runs.

1. **Enter Trap Handler**
   Trap_Control sets `PC` to CSR `mtvec` (i.e., PCC outputs `NextPC = mtvec`).
   CPU jumps to `mtvec` and executes the Trap Handler routine.

2. **Analyze & initialize**
   The Trap Handler routine reads CSR state, examines `mcause` and `mepc`, and performs any initialization needed to prepare debugger interaction.
   This is the practical part—needs further study.

**—[EBREAK flow]—**

1. **Detect EBREAK**
   `I_RD` → Instruction Decoder & Exception Detector.
   ED detects `EBREAK` → `Trap_Status = 10`.
   Trap_Control detects via `Trap_Status` → prepare to activate debug mode.

2. **Prepare debug mode**
   Trap_Control writes `mepc` and `mcause` via `CSR_Addr`/`CSR_Data` (with `mcause` = 3 for EBREAK).

3. **Run Trap Handler**
   Trap_Control sets `PC = mtvec`.
   CPU jumps to Trap Handler routine to prepare debug mode.
   Trap Handler reads `mcause`/`mepc` and gets ready for debugger interaction.

4. **Stop PC update**
   Trap_Control activates debug mode; PCC halts `NextPC` output.

5. **Debugging**
   External debugger sends `add x7, x5, x6` via the debug interface.
   Interface drives it to the Instruction Decoder.
   CPU executes; state mutates as per debug steps.

6. **Exit debug**
   Debugger completes and executes **mret**.
   Trap_Control fetches `mepc` and supplies it so PCC outputs `NextPC = mepc`.

7. **Done.**

### [2025.01.26.]
PC must load the TrapHandler routine **before** debugging begins. The TH start address should be driven on `T_Target` from Trap_Control.  

Proposed datapath:  

PC → I.C → `EBREAK` → ED selects `TrapStatus = EBREAK` and outputs to TC.  
To output `NextPC = T_Target`, TC asserts `Trapped` to PCC.  
TC writes `mepc`/`mcause` to CSR via `CSR_Addr`, `CSR_Data`.  
Using `mtvec` read from CSR, TC computes the Trap Handler start address and drives it on `T_Target`.  
PCC, having received `Trapped`, accepts `T_Target` and outputs `NextPC` = Trap Handler start address.  
IC–IM path then fetches and executes the Trap Handler.  

Now the debugger injects instructions directly…  
Strictly speaking, during debugging can we access/modify I-Cache or Instruction Memory?  
Is execution-only allowed? Memory visible via reads and writes through executed instructions? In practice it’s all via instructions.  
Therefore insert one more MUX **before** `I_RD` to select between `I_RD` and `Dbg.Instr`.  
This lets us choose between normal fetch (`I_RD`) and debugger-injected instruction (`Dbg.Instr`) after entering debug mode.  

Question: which module should control this **`I_RD.DbgInstr_MUX`** select? Debug Interface? Trap Control? Control Unit?  

While pushing existing modules right to make room for the `I_RD.DbgInstr_MUX` and optimizing signals, I found an error: the source-select for `CSR_Addr` and for `CSR_WD` was shared.  
To fix this, split CU’s `CSRsrc` into **`CSR.Addr.src`** and **`CSR.Data.src`**.  

Rearranged CU signal placements accordingly (19:50).  
Intermediate save as **RV32I47EBpush** (20:40).  

ChoiCube84’s suggestion:
> In the current ALUcontrol code, `srli/srai` are I-type and thus identified by **imm**, not `funct7`.  

`srl/sra` use `funct7` and shift by the value in a register; `srli/srai` use the immediate **shamt**.
I-type bit layout:
`imm[31:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | opcode[6:0]`
Within `imm`, bits `[31:25]` serve as a `funct7`-like discriminator for `srli/srai`, and `[24:20]` is the **shamt** (shift amount).
Therefore ALUcontrol needs `imm` as an input for identification—**added**.

ChoiCube84’s suggestion 2:  
> For `slli` and `lh`, both use ALU and are distinguished only by **opcode**.

They share I-type and the same `funct3`, but ALUcontrol currently doesn’t take `opcode`.
Rather than having CU encode a separate **Instr.Type** and feed that to ALUcontrol, it’s more reasonable to feed **opcode** itself to ALUcontrol.  
Thus **replaced Instr.Type with opcode** as an ALUcontrol input.  
Also, since ALUcontrol outputs the ALU action code and the old `ALUop` signal has been removed, rename the ALUcontrol→ALU action signal to **`ALUop`**.  
Approved and changed accordingly.  

Moved modules and added **`I_RD.DbgInstr_MUX`**.  
(Still open: which module drives its select? As above.)

---

— Re the earlier question —  
During debugging, can we access/modify I-Cache or IM directly? Execution is via injected instructions, so control is instruction-driven.
Hence add `I_RD.DbgInstr_MUX` before `I_RD` to select between normal fetch and `Dbg.Instr` when in debug mode.
Who controls it—Debug Interface, Trap Control, or CU?

---

I need an answer for this. Pausing here for an intermediate save.  
Along the way I applied the above changes and optimized signals (23:54).

![RV32I47_EB_opt](/diagrams/design_archive/RV32I47F/RV32I47EBpushed.drawio.png)

To-dos:

* Map which modules are affected in debug mode.
* For each, identify the control/modification signals required during debugging.

Decision (for now): since entering debug mode requires overriding the `I_RD` path to ID, **Trap_Control** will drive the select for **`I_RD.DbgInstr_MUX`**.

### [2025.01.27.]

While assembling the units needed for **debug mode**, I asked: how far do I actually have to design? To prepare debugging logic, I need information about the debugger—what instructions it issues, how debugging proceeds. But that effectively means designing a separate processor (debugging unit), which is **not** what I should do now.  
For now, I only need to implement the **EBREAK** flow: prepare for entering debug mode on EBREAK, enter debug, ensure the debug instruction reaches the Instruction Decoder correctly, ensure debug mode is actually enabled, and confirm we can return to the original program flow with **mret**.  

I added a **debug interface** to the top-core module diagram. With that, the first-pass **RV32I47F** core design looks done.  
(Technically this is the second pass, but the earlier pass lacked EBREAK and FENCE support—so this is the first in a true sense.)  

**—during signal-wiring optimization—**

> Do CSR address/data computations ever include `imm`?   

If yes, should it be the **raw instruction-format imm** or the **sign-extended ex-imm (32-bit)**?  
—Use the **raw instruction-format imm**. `ex-imm` is for ALU ops (address calc or I-type processing).  

> Do we need explicit **Write/Read** signals for the CSR file?   

The Register File is effectively always readable, but CSR felt different: in cases with tight read–write coupling (Exception, Trap), a lack of explicit control could cause timing confusion or unintended accesses.  
Therefore I split the old `CSRenable` into **`CSR_Read`** and **`CSR_Write`**.  

Applied all of this to the **RV32I47F** core design; aligned signals and modules. (16:32)  

Next I need to modify the **Top Module** diagram.  

**-Question that came up while checking for missing signal schemes in the Top Module design-**

Current **Data Cache** structure/policy:  
For writes, write quickly to the **cache buffer** first.  
Later, synchronize buffer→cache and simultaneously cache→memory. In other words, the buffer sends address/data to memory—but I realized there’s no control signal telling it to perform this **flush**.  
—Add **`B2M_Flush`** (from the Memory Controller).  
In this case, Data Memory must also enable writes; upon detecting `FENCE`, the Control Unit should assert **`Memory_Write`** as well.  
RISC-V ISA has no dedicated instruction for flushing a cache buffer to cache and memory.  
Typically cache synchronization is handled by **FENCE**, hence enabling `MemWrite` in CU on FENCE.  
But behaviorally, buffering-then-flush vs. writing into the cache itself and later flushing to memory seem equivalent… I need to study this more.  

![RV32I47F_draft](/diagrams/design_archive/RV32I47F/RV32I47F.drawio.png)

23:51. Completed additions to the module-document signal schemes and the new modules.
While checking each module, I also optimized and reflected signal names for **RV32I47F**.
Added **colors** to the diagram with 3 levels:

* **Blue**: Verilog implementation complete
* **Green**: implementation in progress
* **Red**: not implemented / dummy

Version named **RV32I47F.R2**.

![RV32I47F.R2](/diagrams/design_archive/RV32I47F/RV32I47F.R2.drawio.png)

---

— **Tomorrow’s tasks** —

* Finalize which modules require **clock** and **reset** inputs.
* Rebuild the **Top Module** diagram.
* Reorganize and update the repository **Docs** folder per plan.

### [2025.01.28.]
Clock/reset ingress modules finalized. Updated to **RV32I47F.R3**. (17:18)
![RV32I47F.R3](/diagrams/design_archive/RV32I47F/RV32I47F.R3.drawio.png)

— **Instruction Decoder** —
1. `imm` was output raw and, when needed, sign-extended before entering the ALU.  

**ChoiCube84 — Issue Raised**
* In the prior scheme, `imm` was treated as a **12-bit** entity.
  *Reason:* U-type uses a **20-bit** immediate.
* In the current ID, all `imm` (except for CSR/ALUcontroller meta-uses) were being **sign-extended** into the ALU, which leads to a problem:
  The **Imm_gen** could not know which bit is the MSB for the given instruction’s immediate.
  Example failure:

  * `0000111010` → treats bit 5 as MSB and extends…
  * `0001111001010` → again treats bit 5 as MSB… → broken data for 20-bit U-type.

**Decision / Fix (in ID):**

* ID now **zero-extends** the RAW `imm` to 32 bits.
* For **U-type AUIPC** (20-bit immediate), **bypass** Imm_gen and use this zero-extended `imm` directly.
* For all **12-bit** immediates, pass through **Imm_gen** to produce a sign-extended `ex-imm` for the ALU.

**Module changes:**

* Add a new source to **ALUsrcB** for the “plain `imm`” path → **4:1 MUX**.
* CU must select **ALUsrcB = imm** when it detects **U-type**.

(19:14) **RV32I47F.R4** revision complete.
![RV32I47F.R4](/diagrams/design_archive/RV32I47F/RV32I47F.R4.drawio.png)

* Applied the above `imm` fix (ALUsrcB 4:1 MUX).
* Performed signal-scheme optimizations.

Remaining items: Top-Module re-design; instruction datapath verification.  
Some of the issues ChoiCube84 is surfacing during implementation would have been caught in datapath verification (others are unique to his signal-optimization focus).  
I’ll laminate the schematics and trace them one by one.  
Might need to author a document that integrates MNEMONICS with bit layouts...  

Additional note (from ChoiCube84):
The latest **RISC-V manual** vs. our textbook/reference ISA show slight differences.  
We should standardize on the latest manual. In that view, **FENCE.TSO** appears, while **UJ/SB** aren’t named explicitly (they’re referred to as **J** and **B**).  
Also: **FENCE.i** is **Zifence.i** (an extension), not part of base RV32I. I mistakenly treated it as base.  
Net effect: the platform we built is still useful; practically we must add **FENCE.TSO** and **PAUSE**. Need to research semantics and which modules/signals they touch. (20:27)  

——

Findings (summary):

* **FENCE.TSO** is a constrained form of **FENCE**.  

  * General FENCE orders **I/O/R/W**; it ensures memory consistency by completing prior ops of those classes before proceeding.
  * **TSO** (= Total Store Order) restricts to **R/W**: complete prior reads/writes before executing subsequent ops.
  * In the bit layout, certain fields (e.g., `rs1`) are **ignored**; it’s largely a classifier.
* **PAUSE** appears effectively NOP-like (needs deeper confirmation).

### [2025.01.29.]
#### Research Notes

**FENCE**, **PAUSE**, **HINT** instructions, **hart**, etc.  
The **FENCE** instruction is fundamentally about **memory ordering**.  
In multi-core or multi-threaded execution, memory references can violate order; FENCE-family instructions address that.  
Derived forms vary the bit identifiers on top of the base FENCE: e.g., **FENCE.TSO**, **PAUSE**.  

* **FENCE** — provides ordering over memory and I/O.
  Ensure all prior memory operations complete **before** any successor work proceeds.

* **FENCE.TSO** — before any successor *memory* operation executes,
  all predecessor **loads** must complete; and before any successor **store**,
  all predecessor **stores** must complete.

* **PAUSE** — first, recall the RISC-V notion of a **HINT** instruction: one that **executes** but has **no architectural effect**.
  Example: `ADD` writing to `x0` is a HINT, since `x0` is hard-wired to 0.
  **PAUSE** belongs to the **Zihintpause** extension. It merely indicates the current **hart** should temporarily reduce or stop instruction retirement; architecturally it has no effect.  
  In multi-threaded/multi-core contexts, it can help while waiting on memory consistency by yielding/relaxing.  
  In our design, we can treat **PAUSE** as **`nop`**.  
  A **hart** is a complete RISC-V hardware thread of execution (a fully usable compute unit).  

(20:58)

---

#### Datapath Verification

I’ll handle this in a separate **Datapath** document.

**Reference:** *The RISC-V Instruction Set Manual, Volume I: Unprivileged Architecture*, version **20240411**.  
See **Chapter 34. RV32G/64G Instruction Set Listings** (p. 555).  

I’ll begin verification from **`lui`** (going opcode by opcode; grouping by type might be better, but I’ll start sequentially).  

**Register File writeback** will be classified into four consistent paths:  

1. **LOAD** data from **Data Memory**,
2. **ALU** results computed from `rs*` and/or `imm`,
3. **CSR LOAD** data from **CSR File**,
4. **PC+4**.

**-`LUI`-**  
In our current architecture, `imm` is already **zero-extended** in ID; we could write it straight to the register.  
However, for **datapath consistency**, we still pass it through `RegF_WD_MUX` (the ALU/writeback mux path).  

![RV32I47F.R5](/diagrams/design_archive/RV32I47F/RV32I47F.R5.drawio.png)
![RV32I47F.R5_datapath_LUI](/diagrams/design_archive/RV32I47F/RV32I47F.R5_LUI.drawio.png)
![RV32I47F.R5_datapath_AUIPC](/diagrams/design_archive/RV32I47F/RV32I47F.R5_AUIPC.drawio.png)
![RV32I47F.R5_datapath_JAL](/diagrams/design_archive/RV32I47F/RV32I47F.R5_JAL.drawio.png)

A thought: always zero-extending feels a bit messy. Perhaps **ImmGen** should receive the **instruction type** and perform the **appropriate sign-extension**?  
I recall RISC-V generally presumes **sign-extension** semantics; always extending unconditionally also looks inefficient.  

### [2025.01.30.]
#### Confliction.

**My claim:** 
> Zero-extending the `imm` of **all** instructions is inefficient.

Only **U/J** types ultimately use zero-extended 32-bit immediates; for the rest (**I/S/B**) the immediate must be **sign-extended**.
Problems: unnecessary extension → extra ALU work; and wider-than-needed datapath width.

**Context:**  
J-type bit layout: `imm[20|10:1|11|19:12] | rd[11:7] | opcode[6:0]`.  
U-type uses `[31:12]`. CC84 pointed out that, based on *Computer Organization and Design, RISC-V Ed.*, Ch.4 Figs. 4.16/4.17, one might try to reduce MUXes by having ID always output a **32-bit zero-extended** `imm` for U/J, then let `imm_gen` do sign extension.   
(Interpreting “[31:12]” as implying a pre-extended zero-filled representation.)  
But those figures don’t strongly justify this, and burning bits on uncertainty isn’t great—so we chose an improvement.  

#### Improvement
![RV32I47F.R6_temp](/diagrams/design_archive/RV32I47F/RV32I47F.R6_temp.drawio.png)

* **ID `imm` width = 20 bits.**

  * For **12-bit** immediates, output the **raw 12 bits**; upper 8 bits are **don’t-care**   
  (ImmGen slices what it needs).
  * For **20-bit** immediates, output the **raw 20 bits** to `imm_gen`.
* Add **`opcode`** as an input to **`imm_gen`** so it can perform the **correct sign/zero extension by instruction type**.

--**Updated datapath application**--
![RV32I47F.R6_datapath_JALR](/diagrams/design_archive/RV32I47F/RV32I47F.R6_JALR.drawio.png)

**U-type (2 instr: `auipc`, `lui`)**

* `lui`: write `{imm, 12'b0}` to `R[rd]` (i.e., **zero-fill** low 12).
* `auipc`: write `PC + {imm, 12'b0}` to `R[rd]`.
  Since `auipc` adds **zero-filled** `imm` to **PC**, this zero-fill is unsuitable to “do inside ALU” generically; better handled in **ImmGen**.
  → **U-type**: ImmGen outputs a **32-bit zero-filled** value.

**J-type (2 instr: `jal`, `jalr`)**

* `jal`: `R[rd] = PC + 4;  PC = PC + {imm, 1'b0}`.
  The manual: *“The offset is sign-extended and added to the address of the jump instruction …”* → **sign-extend**, then **<<1**.
* `jalr`: `R[rd] = PC + 4;  PC = R[rs1] + imm`.
  Requires **sign-extended** `imm` (ALU datapath is 32-bit).

#### Notes

* `shamt` = shift amount ⇒ I-type **shift immediates are not sign-extended**.
* CSR **address field** is 12 bits → **no extension** needed.
* For CSR instructions with immediate-as-data, that imm must be **zero-extended**.

#### ALU bypass vs. direct paths (writeback)

Caught a spec slip: the CSR-to-register instruction is **`csrrw`** (CSR Read & Write):  
`R[rd] = CSR;  CSR = R[rd]`.   
I had already included a corresponding input on `RegF_WD_MUX`.
This reduces the need for an extra ALU-bypass just for CSR→Reg writes.  

For **`lui`** (U-type), we only need to deposit `{imm,12'b0}` to `R[rd]`; no ALU op required.  
Doing this inside the ALU would imply extra cycles or special cases (conflicts with `auipc` usage), so better to **generate the constant in ImmGen**.

Decision:

* Prefer **direct** writeback paths for constant/CSR cases to avoid ballooning the ALU’s role.
* However, to keep the writeback MUX from growing unbounded, balance direct lines vs. ALU-bypass. For now, **keep a dedicated direct write** for CSR_RD and U-constant paths, and avoid piling too many one-off inputs into a single MUX.

#### ID outputs & source pruning

* ID now outputs either **12-bit raw** or **20-bit raw** `imm` (both packed into a **20-bit bus**).  
* **ImmGen** performs **zero-fill** or **sign-extend** according to **`opcode`/type** (including `{imm,12'b0}` synthesis for U; sign-extend+shift for J).  
* Reviewed ALU sources:

  * **`ALUsrcB`** needs only **`RD2`** and **`ex-imm`**.
  * **`RegF_WD_MUX`** now includes **`CSR_RD`** and **`ex-imm`** as additional candidates (alongside ALU result, load data, PC+4).

For `jal`, **`NextPC = PC + {imm, 1'b0}`** (with `imm` sign-extended before shift).  Yes—since it’s an unconditional jump, `NextPC` should be that target.

![RV32I47F.R6](/diagrams/design_archive/RV32I47F/RV32I47F.R6.drawio.png)

### [2025.01.31.]
-morning work meeting-

Discussed the operating structure of **B-type** instructions.  
B-type must handle **two** operations in one go: (1) the conditional comparison, and (2) computing the branch target from `PC`.  

* The comparison uses `rs1` and `rs2`, so it’s reasonable for the **ALU** to take the two sources and evaluate the condition.
* The question was where to compute the **branch target address**: in **Branch Logic**, in **PCC**, or via a separate calculator module.

Decision: **do it in PCC**.  
We initially considered Branch Logic, but:  

* `PC = PC + {imm, 1'b0}` where the `1'b0` alignment is handled in **ImmGen**.
  Per relative-addressing policy, **sign-extend first**, then shift left by 1 (the `1'b0` alignment).
* Although we briefly moved `B_Target` to Branch Logic, philosophically Branch Logic should remain a **predicate unit** (condition check), not a PC calculator.
* Doing it in the ALU would add resource/complexity.
* A separate PC-adder module would feel like unnecessary hardware.

Therefore, computing `NextPC` in **PCC** aligns with the design philosophy and will also be cleaner for pipelining later.  

**Consequences**

* **PCC** now receives **`ex-imm`** to compute `PC + (sign-extended, shifted imm)` internally under the branch-taken condition.
* The explicit **`B_Target`** signal is **removed**; `NextPC` is produced directly by PCC based on the condition outcome.
* The `ALUresult` currently sent to PCC (only used for jump-related PC values) will **remain** as-is—for future **G-extension** work, J-type handling via the ALU path may still be preferable.

**To-do**

* Explain to **CC84** why **PCC needs a `CLK`** input.
* Revisit why **`BE_Logic`** has an **address** signal. For loads (DM → RF), the destination register address is already `rd` in the instruction, and the source address is `rs1 + imm`. The extra address line in BE_Logic looks unnecessary.

![RV32I47F.R7](/diagrams/design_archive/RV32I47F/RV32I47F.R7.drawio.png)

Wrapped for today. Finished datapath verification **up to `lb`**! (23:57)
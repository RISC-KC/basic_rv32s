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

## 37F Architecture Development (Partial RV32I Except SYSTEM instructions)

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

## 43F Architecture Development (37F + Zicsr extension)
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

## 47F Architecture Development (43F + Zifencei + ECALL + EBREAK + mret)

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

1. On a cache miss, MemCon converts the address for Memory, forwards it, receives the returned data, and passes it to ID (Instruction Decoder). (Possibly could bypass MemCon, but...)

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

Next steps likely include implementing cache and branch prediction...  

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
**-[Changes]-**
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
* Trap Handler ...
  just when I thought I was almost done—what is **mtvec** again...

##### —Emergency meeting—

`mtvec` is a CSR holding the **start address** of the Trap Handler.
“Start address”??? So the Trap Handler isn’t a *module*?
Right... when an exception occurs, you need a **routine** to handle it. I had treated “Trap Handler” as a hardware module, and didn’t realize the handler itself is **software**.
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

Now the debugger injects instructions directly...  
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
But behaviorally, buffering-then-flush vs. writing into the cache itself and later flushing to memory seem equivalent... I need to study this more.  

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

  * `0000111010` → treats bit 5 as MSB and extends...
  * `0001111001010` → again treats bit 5 as MSB... → broken data for 20-bit U-type.

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
U-type uses `[31:12]`. ChoiCube84 pointed out that, based on *Computer Organization and Design, RISC-V Ed.*, Ch.4 Figs. 4.16/4.17, one might try to reduce MUXes by having ID always output a **32-bit zero-extended** `imm` for U/J, then let `imm_gen` do sign extension.   
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
  The manual: *“The offset is sign-extended and added to the address of the jump instruction ...”* → **sign-extend**, then **<<1**.
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

![RV32I47F.R7](/diagrams/design_archive/RV32I47F/RV32I47F.R7.drawio.png)

**-Datapath Verification with Diagram check-**
![47F_LUI](/diagrams/design_archive/RV32I47F/RV32I47F.R7v2_LUI.drawio.png)
![47F_AUIPC](/diagrams/design_archive/RV32I47F/RV32I47F.R7v2_AUIPC.drawio.png)
![47F_JALR](/diagrams/design_archive/RV32I47F/RV32I47F.R7v2_LUI.drawio.png)

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

![RV32I47F.R7v2](/diagrams/design_archive/RV32I47F/RV32I47F.R7v2.drawio.png)
![47F_JAL](/diagrams/design_archive/RV32I47F/RV32I47F.R7v2_JAL.drawio.png)
![47F_B-Type](/diagrams/design_archive/RV32I47F/RV32I47F.R7v2_B-Type.drawio.png)
![47F_LB](/diagrams/design_archive/RV32I47F/RV32I47F.R7v2_LB.drawio.png)

**To-do**

* Explain to **ChoiCube84** why **PCC needs a `CLK`** input.
* Revisit why **`BE_Logic`** has an **address** signal. For loads (DM → RF), the destination register address is already `rd` in the instruction, and the source address is `rs1 + imm`. The extra address line in BE_Logic looks unnecessary.

Wrapped for today. Finished datapath verification **up to `lb`**! (23:57)

### [2025.02.01.]

- Started design of Memory Aligner which is for partial byte load-store operation's address alignment. 

Reviewing ChoiCube84's suggestion, there's always a possiblity of getting misaligned address to BE_Logic and Data Memory's address input.   
Since this is same for Jump-Jalr instruction, decided to design integrated address alignment logic module.  

Named RV32I47F.R8_temp.
![RV32I47F.R8_temp](/diagrams/design_archive/RV32I47F/RV32I47F.R8_temp.drawio.png)

### [2025.02.02.]

Memory Aligner module designed named RV32I47F.R8_dump.(Dumped design due to following reasons)
![RV32I47F.R8_dump](/diagrams/design_archive/RV32I47F/RV32I47F.R8_dump.drawio.png)

Found the rationale for WriteMask and the Address into BE_Logic.  

- Block access granularity is based on address bits [11:2].
- We must support word / halfword / byte reads/writes.   
So we accept the raw (potentially unaligned) address as-is, but if an address violates the instruction’s alignment rule, we raise an exception (e.g., SW needs word-aligned, SH halfword-aligned, SB any).

- WriteMask is literally a bit/byte mask for selective writes.

- Therefore the Mem_Aligner module is removed; we keep the existing signal scheme (use Address + WriteMask + exception on misalignment).

### [2025.02.03.]

#### Final meeting on Byte Enable Logic module

Most of the time was spent on handling the Write Mask and understanding the module–logic related to it.  
The guiding philosophy is to minimize operations in memory. BE_Logic is for that.  

The data required for WriteMask are target data, original data, and mask.  
Using the mask, apply masking to the original data; if there is DEADBEEF, make it 00ADBEEF.  

For the target data as well, using the mask, if there is CAFEBEBE, make it CA000000.  
And the mask used for this operates with FF000000, but sending this as a 32-bit value from BE_Logic to DataMemory as-is violates a hardware design philosophy—minimization and simplification of I/O signals—so we decided to encode and send it as 4 bits, which is close to a de facto technical standard.  

And at this time, the BEDM_WD sent from BE_Logic is CACACACA.  
Since the WriteMask is effectively sent, and an &(bitwise AND) operation and decoding have to be done, have DM generate the value CA000000 as-is and perform the data store in one step with it.  

Although we are using an unofficial standard at the suggestion of ChoiCube84, the computation has been greatly reduced.

![RV32I47F.R8_temp_250203](/diagrams/design_archive/RV32I47F/[250203]RV32I47F.R8_temp.drawio.png)

### [2025.02.04.]

I spent four hours creating the RV32I Essentials Cheat Sheet.  
I put the instructions, their descriptions, mnemonics, and bit layouts all on a single page.  
Since proper materials were scarce or paywalled, I made it myself.  

And I also discussed J_Align with CC84.  

> ChoiCube84:  
> Unless a programmer codes incorrectly, I don’t think misalignment will occur on a jump.

KHWL.  
No. Since the address is computed based on a constant and a referenced register value, we cannot rule it out. This is mentioned in the manual as well.  

> ChoiCube84:  
Then let’s look at the relevant content.  
"will generate instruction-address-misalinged exception."  
Since it’s an exception, instead of handling it in J_Aligner, how about handling it separately in the Trap_Handler for hardware simplification?  

KHWL.  
Hmm. That makes sense. But we also have to keep performance differences in mind.  
It might be better to pass through a simple logic module and run without raising an exception.  

Still, if the ALU result for J_Target always goes through the J_Aligner module logic, there could be delay from unnecessary operations even when the condition doesn’t occur.  
Handling it as an exception does seem clearly reasonable.  

### [2025.02.05.]

In fact, the if-statement to determine whether a misalign occurred is logic that has to be passed somewhere at least once even without a J_Aligner, and even if it’s implemented elsewhere, it doesn’t seem likely to bring significant performance benefits.  
Rather, invoking a separate handling routine via an Exception could end up hampering timing when we later extend to a pipeline, and if we’re going to keep monitoring misaligns anyway, and the handling itself is an alignment logic that drops the lower 2 bits, then I think just having J_Aligner is better now and in the future.  
Still, to see whether Exception handling components like the Trap Controller and Exception Detector operate correctly, let’s implement it as an Exception for now.  
This seems better off eventually residing as separate logic in the PCC. An Exception assigns too much resource.  

Quoting the manual verbatim:  
> “The JAL and JALR instructions will generate an instruction-address-misaligned exception if the target address is not aligned to a four byte boundary.”  

In the end, if the target address—i.e., the J_Target signal—is already aligned when it is fed into the PCC, no Exception occurs, and if we perform alignment before Exception Detect when the situation arises, prior to an Exception occurring, then generating an exception is not mandatory.  

For now, this won’t be a standalone module in the implementation. When ALUresult goes to the PCC as J_Target, we will also feed a signal to the Exception Detector so that a separate Trap_Handler is invoked on misalign.  
I can already feel the timing getting tangled, but thinking ahead now about issues for later isn’t a bad thing.  
Name this diagram RV32I47F.R8v1. There have been several attempts to revise to R8 so far, but many were dismissed through debate.  
For now, the officially adopted R8 is the diagram with v1 appended.
(20:44)

![RV32I47F.R8v1](/diagrams/design_archive/RV32I47F/RV32I47F.R8v1.drawio.png)

Indeed, forcibly aligning with 00 can cause the program to proceed in unintended ways. This is a misconception.  
It may be a method used in simple or embedded systems, but from the perspective of a general-purpose processor, it isn’t appropriate.  
In the end it’s Exception handling, and we must compose the TrapHandler ourselves so it behaves that way.  
Since we aim for general purpose, we decided that in such Exceptions we will either enter debug mode, force-terminate, or handle it somehow, and J_Aligner is gone for now.  
I spent the entire evening study period exploring standards and examples for handling misaligned addresses, as well as implementation methods and their validity.  
## RV32I50F Devleopment (47F + FENCE + FENCE.TSO + PAUSE)
### [2025.02.07.]
To do: Adding B_Target(NextPC) address input to `Exception Detector`  
->Revision on RV32I50F.R1
![RV32I50F.R1](/diagrams/design_archive/RV32I50F/RV32I50F.R1.drawio.png)

> ChoiCube84’s proposal during CSR implementation.   
If the behavior is determined by CSRop, why are separate Read and Write signals needed? In any case, a CSR instruction causes both of those to happen simultaneously.  

KHWL:  
Right. Delete the two and use CSRop.

> ChoiCube84: Then couldn’t CSRop actually just take funct3 and operate?  

KHWL:  
No, no. We still need the purpose of a non-operating Enable. For datapath management we need a non-operating opcode, so it’s better to manage it with CSRop.

To modify: change that module’s input signals to match the Exception Detector code.
Move the DC_Write signal to the Memory Controller.  
(Write operations to the cache occur only on a cache miss, and in that case the Control Unit, under the original design, cannot know that a cache miss occurred. So this signal must go into MemCon.)  
The Control Unit’s opcode output is actually meaningless. We should just wire the opcode signal coming out of the Instruction Decoder directly.  
Accordingly, modified the ALU controller’s signals.  
- Rename the mem2reg signal to reg_wd-src.

### [2025.02.09.]
The Exception Detector should be modified according to the approved merged code on the development branch.  
For ECALL and EBREAK, the discriminator depends on whether bit 0 of the imm field (funct12) is 0 or 1, and if it is for distinguishing that, it seems fine to feed in the raw_imm value, so I did that.  

The Branch Target value needs to go in, but since this is a value computed in the PCC, I decided to use the value of NextPC directly as the input signal.  

Misalign exceptions occur only in Jump and Branch.  
For Jump, you can just plug the ALUresult, which is the Jump Target address, directly and judge it.  
For Branch, the B_Target address is computed in the PCC when B_Taken and output as NextPC,
so in that case, wouldn’t it be enough to feed only the NextPC value to the Exception Detector, without needing the B_Taken signal?  

Even if it’s not specifically a Branch, this way we can trigger an exception when the address destined for PC is not aligned to 4 bytes according to its purpose.  
If so, J_Target has no advantage other than earlier arrival latency compared to NextPC...  
In fact, it seems we only need to receive NextPC. I should propose this to ChoiCube84.  

Yeah. In truth, this Misaligned Address exception is for when the address that NextPC points PC to is misaligned and interferes with instruction execution.  
Therefore, rather than separately singling out B_Taken or Jump (and Jump wasn’t even there originally), it is optimal for the Exception Detector module to simply monitor the NextPC value and handle the situation when it occurs.   
This also allows handling even when misalignment arises for some reason other than those two.   
ChoiCube84 agreed, so we decided to modify it that way.   
As for funct3, I wondered what that was about, and since CSR and Environment instructions share an opcode and only when f3 is 000 is it environment, I’ll take it together to distinguish.  
It’s just a CSR instruction, and an exception shouldn’t occur.  

Today’s tasks.

1. Revise the Exception Detector input signals to match the GitHub code.  
   Done. (22:54)

2. DC_Write is in CU; move this to the Memory Controller.  
   Done. (23:04)  

3. Write the module description Manual.

4. Verify each instruction datapath.

5. The signal RF2DM_RD should be R[rs2], but right now it’s the rs1 value. Needs fixing.
   Done. (23:07)

6. Establish the FENCE datapath.   
e.g.) Before the Write_Done signal arrives, we need to hold the update of PC;   
how will this be implemented?

7. Document the RV32I; Essentials Cheat Sheet.  
   Revise to v3 and correct 12b'0 to 12'b0.  
   – Only the format has been created.

8. Paper documentation.  
   Write in the manual there as well, and based on that, also write the IDE files.  
   It might be good to combine modules, signals, and module purpose into a single Excel file (table).  
   – Only the format has been created.  

9. Push Docs after finishing the related work.  

**—Evening meeting—**

During Control Unit implementation, a problem was found.   
It seems ChoiCube84 pondered whether CSR.Addr.src and CSR.Data.src should be in the Control Unit.  

A. The meaning of CSR.Addr.src is as follows.  
In normal situations, it distinguishes whether it is the 12-bit address value in the csr field within CSR instructions, or the CSR address value designated by the Trap Controller in the event of TrapHandler execution, i.e., an Exception situation.  
Therefore this should not be done in the Control Unit; set the Trapped signal from the Exception Detector as the control signal of the MUX, so that when the Trap occurs and the flag goes to 1, at the same time the MUX value switches to CSR_T.Addr.  
Accordingly, the CSR.Addr.src_Select signal is removed from the Control Unit (CU), and instead it is changed to consume the Trapped signal from the Exception Detector (ED).  

B. In the case of CSR.Data.src.

Done. (23:48)

![RV32I50F.R1v2](/diagrams/design_archive/RV32I50F/RV32I50F.R1v2.drawio.png)

### [2025.02.10.]
Our goal is to build an RV32I CPU now.  
And in that process, to make all RV32I instructions meaningful, we integrated a cache–memory structure and the CSR extension.  

The Zicsr extension was an extension to make environment-call instructions like ECALL and EBREAK meaningful, and through this we did a simple implementation of Debug Mode.  
The Zifencei extension started from the mistake of reading an older RISC-V manual and thinking the fence.i instruction was included in the RV32I Base Instruction Set.  
As a result, we ended up making a cache structure for the fence.i instruction.  
It’s not clear whether fence and fence.tso, pause (fence variations) are thanks to that, but we at least got to see whether these instructions operate.  

In the diagrams, Verilog HDL implementations of almost all modules are each nearing completion.  
CC84 is implementing the Control Unit as the final chapter, and what remains is: after the Control Unit, the top-module DUT testbench of RV32I37F, and then cache and CSR implementations based on additional extensions to support the remaining 4 instructions.  

CC84 requested research on this CSR. Exactly how should CSR be implemented? There seem to be machine-level registers that hardware must update automatically, which makes it hard to treat them as ordinary registers, and whether we need to implement the list of those CSR registers all now.  

Also, with cache-structure integration ahead, deeper research on the logic needs to be done. Our current cache policy is write-through, strictly speaking with read/write buffers in the cache, and only flushing the backlogged memories on the FENCE instruction.  
But with that, there is a problem that data loss can occur in the cache memory sharing the same line when writes pile up, and according to computer architecture, I relearned that there are cases where you need to pause work until the writes are all done.  

The nature of the problem is similar to pipelining, and based on that, citing computer architecture, as a solution we explored performing things like Flush concurrently when executing R-type or other instructions—that is, when the Data Cache–Memory side is not used.   
Of course the idea is simple, but its implementation will soon face the big delayed wave called timing, so it’s just a conceptual idea for now. And we plan to derive matching control signals using the Write Done signal.  
This line of exploration was prompted by CC84’s Control Unit implementation—specifically the need for the Write Done signal and whether this signal could be used beyond the simple FENCE-instruction scenario.   
As expected, there is a clear gap between conceptual implementation and actual implementation, and it seems we are completing it by bridging the two appropriately.  

After those 5 years, I also feel that the insights gained through times of renewal are being completed as lessons.
Division of labor shines not when the domains of work are clear, but when the points where they interlock are clear.
Not the boundary line between two sets, but when you focus on the clarity of the intersection, only then can you proceed freely and infinitely productively.

Anyway, from personal maintenance time 17:30 I ate, ran back, and conducted CSR-related research. In Korean, there are almost no materials. Just one Tistory post and a paper that is one of our references, **“Design and Evaluation of 32-Bit RISC-V Processor Using FPGA.”**  
Even in that paper, they partially implemented the privileged ISA as needed using CSR.  
> “Implemented the privileged instruction set and CSRs for trap handling in M mode.”

Back to the point, CSR itself has registers that the hardware must handle automatically, regardless of instruction execution.  
But we don’t have to implement all registers at once.   

> Quoting The RISC-V Instruction Set Manual: Volume II, Privileged Architecture,  
there are a total of 3 stages of Privilege Mode.  
Stage 1 / M (Machine level). For simple embedded systems.  
Stage 2 / M, U (User level). For secure embedded systems.  
Stage 3 / M, S (Supervisor mode), u. For systems running Unix-like operating systems.  

In the end, to implement stage 3, the CSR and the current processor’s operating scheme may need to be improved to match each Privileged Hierarchy structure.  
For now, we don’t need to implement all CSR registers;   
we should implement the registers needed within our current desired spec, and if there is Machine Level logic needed, we need to add it.  

22:15 evening study time.
While reading the Privileged Architecture, ISA manual, the main emphasis before CSR, in the introduction, is almost on “secure.”  
Operational-stage security. A basic design that supports only machine mode cannot provide security against faulty or malicious application code, and that seems to be one of the starting points for CSR.  
(It says the optional PMP facility’s lock function can support partial security even if only M-mode is implemented, but... I don’t know what PMP is..)  

Since we have to implement up to the G extension anyway, we need a proper understanding of the Privileged Architecture.  
At this point, I’ll translate the RISC-V Privileged Architecture ISA Manual into Korean. What’s the big deal about 172 pages.  

From now on, the content continues in the file Privileged_ISA.Korean.md.  
From the register descriptions in the CSR Listings, I was able to find the meaning of PMP.
It stands for Physical Memory Protection.   

**[Supervisor Trap Setup]**  
Unless otherwise noted, it follows the privilege level of the first word of the classification, and RW; Read/Write; are read–write registers.
I’ll write only the important Names separately.
- sstatus
- sie
- stvec
- scounteren   

No, we need them all. It’s right to implement these one by one in order.

For now, the Hypervisor stage is unnecessary since we’re only going to run a simple OS at this point, so exclude it.  
Let’s count the total number of CSRs, and among them, estimate only those needed for implementation in RV32I50F.  
The total number of CSRs follows “Currently allocated RISC-V CSR addresses” in the Manual.  

fflages, frm, fcsr, cycle, time, instret, hpmcounter3 ~ hpmcounter31 (29), starting from h instructions cycle, 32 in total
- Total 64 + 3 (FP CSRs) = 67 Unprivileged CSRs.

sstatus, sie, stvec, scounteren, senvcfg, scountinhibit, sscratch, sepc, scause, stval, sip, scountovf, satp
scontext, sstateen0, sstateen1, sstateen2, sstateen3
- 18 Supervisor CSRs

mvendorid, marchid, mimpid, mhartid, mconfigptr, mstatus, misa, medeleg, mideleg, mie, mtvec, mcounteren,
mstatush, medelegh, mscratch, mepc, mcause, mtval, mip, mtinst, mtval2, menvcfg, menvcfgh, mseccfg, mseccfgh,
pmpcfg0,   
pmpcfg goes up to 15.. pmpaddr from 0 to 63. mstateen0 to 3, including h values.  
- Then total 25 + 16 + 64 + 8 = 113  

mnscratch, mnepc, mncause, mnstatus, mcycle, minstret, mhpmcounter3~31, including h ×2.
mcounthibit, phpmevent3~31, including h. tselect, tdata1~3, mcontext, dcsr, dpc, dscratch0, 1.
- 4+62+59+5+4 = 134..

- Hypervisor..  
7+5+2+1+1+2+8+9 = 35..

Total 367 allocated CSRs.. Of those, let’s estimate what we need to implement..

- RISC-V Unprivileged CSRs (64) [URO]
  cycle, time, instret, hpmcounter3~31, cycleh~hpmcounter31h. Total 64

- Supervisor-level CSRs (18)
  sstatus, sie, stvec, scounteren,
  senvcfg, scountinhibit,
  sscratch, sepc, scause, stval, sip, scountovf (SRO),
  satp, scontext, sstateen0, sstateen1, sstateen2, sstateen3

- Machine-level CSRs ( 163 out of 134)
  mvendorid, marchid, mimpid, mhartid, mconfigptr (Machine Information Registers) 5
  mstatus, misa, medeleg, mideleg, mie, mtvec, mcounteren, mstatush, medelegh (Machine Trap Setup) 9
  mscratch, mcpc, mcause, mtval, mip, mtinst, mtval2 (Machine Trap Handling) 7
  menvcfg, menvcfgh, mseccfg, mseccfgh (Machine Configuration) 4

pmp needs to be considered.. 80..

mstateen0~3, mstateen0h~3h (Machine State Enable Registers) 8.

What is NMI..

Machine Counter/Timers (62)
Machine Counter Setup (59)
Debug/Trace Registers (shared with Debug Mode) (5)
Debug Mode Registers (4)

Total 245.. Out of roughly 400, we have to implement 245.

### [2025.02.11.]
Today’s tasks.  
(Diagram)

1. Add Write_Done signal to PCC  
   (When FENCE occurs, instruction updates must be halted; this signal is needed for that.)  
   Done. 20:39. RV32I50F.R1v3_temp.draw.io

![RV32I50F.R1v3_temp](/diagrams/design_archive/RV32I50F/RV32I50F.R1v3_temp.drawio.png)

2. Create Simplified Core Diagram.  
   Is the baseline RV32I37? Diagram excluding CSR and cache structure.  
   Also a simplified diagram based on current RV32I50F. Need to make two in total.  

3. Organize the CSRs to implement in the CSR File, and modify the matching logic modules and CSR File module.  

—Evening study time—

4. Verify Control Unit behavior  

5. Check whether, in the future instruction extensions RV32G (IMAFD, Zicsr, Zifencei), there are any additional PC-calculating and jumping instructions beyond the RV32I Base Instruction Set.  

While working on 5, I found a chapter that defines the order of sources and destinations per instruction.  
Page 108, Source and Destination Register Listings.  

Item 5 actually arose while verifying item 4, when a thought about JAL’s datapath suddenly came up.  
JAL ultimately does PC = PC + {imm, 1'b0}, and PC + {imm, 1'b0} is computed the same way in Branch as well.  
For this, the Branch comparison is processed in the ALU, and to avoid consuming two cycles for a branch instruction and do it within one cycle, I had implemented PC + {imm, 1'b0} in the PCC.  
So I wondered if we could achieve optimization by reusing the PCC’s logic rather than sending JAL’s PC operation all the way to the ALU.  

Then a problem: the PCC would need to distinguish between JAL and JALR and act accordingly (for JALR, ALUresult = NextPC; for JAL, PC + {imm, 1'b0}).  
To do that, the Jump signal output from the Control Unit to the PCC would need to be made 2-bit so it can identify them.  
Thus I considered the usefulness of reusing that logic in the PCC without going through the ALU.  

After comparing datapaths, it came down to a single MUX difference, and we’re not going to implement a large, high-performance adder for the PCC (though later we could justify it for performance).  
Since the ALU already has a high-performance adder, merely saving a MUX doesn’t promise a big performance gain, so I decided to keep the existing system.  
As before, the ALU computes PC = PC + {imm, 1'b0} and feeds it as J_Target.  

Control Unit verification is complete.  
**Results.**

A. In csrrw and csrrwi. For csrrw where CSR = R[rs1], RD1 should be bypassed into the ALU, but why is ALUsrcB set to 11 selecting CSR?  
In csrrwi as well, CSR = imm, so ALUsrcB should be imm and this should be bypassed, but why is ALUsrcA 11?  

-> For bypass, any unused src will be selected as 00. Keep consistent design, just like unused MUX control signals are 0.  

B. FENCE instruction.  
FENCE is currently implemented by forcing all Control Unit output signals to 0, but this won’t do.  
The point of FENCE is, to prevent resource races and ordering violations, to pause execution of other instructions for any reason (stop updating the value of NextPC...? shouldn’t instructions of the same nature continue to execute?)
and wait until the in-progress instruction completes.   

That is, if a Memwrite operation is in progress, the control signals for that Memwrite should remain asserted.  
Also, depending on what is included in “the in-progress instruction,” the types of FENCE vary.  
The premise of FENCE is resource race and ordering violation, i.e., another hart is assumed. So predecessor and successor executions are defined, and the kinds of operations are Input, Output, Read, Write.  
This still needs research... not easy.  

Anyway. The basic fence is an instruction that includes all of IORW. If operations corresponding to any of these four are in progress, those in-progress operations must continue.  
For example, keep input signal handling going until it finishes, keep writes going likewise.  
FENCE.TSO applies to Read and Write only. For reference, the fm bitfield denotes the meaning of that fence instruction.   
Since it’s a fence type, you can think of it like an opcode for fence.  
PAUSE applies only to the predecessor’s Write.  
Refer to the manual for details. I’ll research more and raise it to a level where I can say it with certainty. (by tomorrow)  

The improvement direction I propose is this.  
When executing a FENCE instruction, we need to know whether the fence-relevant instruction immediately preceding it has fully completed...  
This is complicated... If we zero the CU, then yes, we satisfy the fence that waits for completion of all instruction executions, but fence.tso and pause become inaccurately implemented...  
I need to think of an approach to this...  

### [2025.02.12.]
**Simpilfied Diagram of RV32I50F.R1v3 - draft**
![250212_RV32I50F.R1v3_temp.s](/diagrams/design_archive/RV32I50F/[250212]RV32I50F.R1v3_temp.s.drawio.png)

After evening study yesterday, we held a meeting until 01:20.  
As a result, we were able to obtain clues and ideas for handling FENCE, and decided to implement FENCE handling with zero control signals as we are doing now.  

The precise implementation method for FENCE is to control the PCC’s instruction updates via the cache’s Write Done signal using a buffer.  
When there is no real-time access to that memory, the hardware continuously performs Buffer to Cache writes by flushing the buffer.  
We define this method as the **Simultanious Buffer Flush** Model. **SBF Model**.  

There are about two kinds of problems that can occur related to Load or Store.   
One is when the write instruction is called excessively and the buffer becomes full; the other is when, in the course of using concurrent programming, the user creates a race condition.  

We can solve the first by using the write_done signal, but in the second case we cannot assume all cases and solve it purely in hardware.  
So we intend to let programmers use FENCE instructions so they can resolve such situations themselves.  

Anyway, the buffer structure is the core.  

Things to do today  
- Create the Simplified Core diagram  
- Create the improved CSR diagram. = RV32I50F.R2  

Create RV32I37F (No cache, no CSR, no Debug)
Done. 23:45.
![RV32I37F](/diagrams/design_archive/RV32I37F/RV32I37F.drawio.png)

Create RV32I43F (Yes CSR, No cache, no debug)

Create RV32I47F (Yes CSR, Yes Cache, no debug)

Create RV32I50F (Yes CSR, Cache, Debug)


### [2025.02.13.]
Creation of RV32I43F done. 20:50
![RV32I43F](/diagrams/design_archive/RV32I43F/RV32I43F.drawio.png)

Creation of RV32I47F done. 23:59
![RV32I47F.R9](/diagrams/design_archive/RV32I47F/RV32I47F.R9.drawio.png)

### [2025.02.14.]
During working hours I read the manual on RVWMO.   
Unlike the colloquial, mostly literary books I used to read, reading technical literature—hundreds of pages—was a very different experience.  

Tomorrow, Saturday, I have duty, and it was recently changed to full-time duty where I cannot use my phone from 08:30 in the morning to 08:30 the next morning, so I decided to read through the entire RISC-V manual during that time.  
So… I printed a document of about 651 pages… and by skimming it I roughly identified a study route.  
The current time is 23:24. From now on I will identify the CSR instructions to use, review the current CSR structure of RV32I50F, and then try implementing the CSR module using Verilog HDL.  
And while reading the manual I learned a great many things. I often made guesses and experienced my head ringing, and of course there were valuable products of thought gained from that, but the basic guide manuals and standards to follow for that were “already” covered in the manual.   
The cache structure we implemented follows a rather primitive structure and has a structure somewhat different from modern high-performance computing.  
If you look at the manual, you can see that the table of contents is organized as one big flow where implementing the RISC-V “G” Extension goes up to the “Q” Extension (G = IMAFD + Zicsr + Zifencei Extensions), and accordingly, understanding the cache-management ISA, which is organized as one of the sections before the floating-point extension, will be necessary for our core structure to have a cache structure that follows modern computing.  

“CMO” Extensions for Base Cache Management Operation ISA, Version 1.0.0  
And in any case, for the semantically complete implementation of the FENCE instruction, there must be multiple harts, that is, a multithreading environment. Since predecessor and successor are assumed, we have to do hyperthreading or a dual-core structure somehow…  
Therefore, unfortunately for now, the implementation of the FENCE instruction is likely to be replaced with NOP.   
I will try to make it with the intention of a fully implementable level in actual hardware, but the result will not be able to affect actual output values.  
It looks like we will end up following as-is the NOP handling of the FENCE instruction due to designing a single-core processor, as in the paper we used as a reference, **"A Design and Implementation of 32-bit Five-Stage RISC-V Processor Using FPGA."**(Sangun Jo, Lee, Jong Hwan and Yongwoo Kim. (2022). A Design and Implementation of 32-bit Five-Stage RISC-V Processor Using FPGA. Journal of the Semiconductor & Display Technology, 21(4), 27-32.)  
As a result there was no real progress, but through the process it was a good opportunity to form our own structure for the cache and to contemplate the related memory structure while also making some mistaken misunderstandings (SBF Model, etc.).  

Now. Time to explore the manual. I had already done some indexing work previously, so progress will be quite fast.  
23:36. Start.

The total six instructions performed in Zicsr are atomic instructions.  
It is correct that uimm is the zero-extension of the 5-bit rs1 value of the instruction. (pages 46–47)  
When uimm in CSRRSI, CSRRCI is 0 and the instruction is given, the following must be followed.  

1. The CSR is not written.  
2. It does not cause any side effects that may occur when writing the CSR.  
3. It does not raise an illegal-instruction exception for a read-only (RO) CSR.  

In the CSRRWI instruction when rd = x0:  

1. The instruction must not read the CSR.  
2. It must not cause any side effects that may occur when reading the CSR.  

CSRRSI and CSRRCI always read the CSR and may cause any of the side effects of reading, regardless of rd or rs1.  

I read most of the RISC-V Unprivileged Architecture manual’s section on the Zicsr extension.   
I will read it closely tomorrow, but for now the content is mainly about supporting the instructions rather than implementing the CSR itself.  
Basically CSR is composed of instructions where reading and writing happen simultaneously, and those pseudo-instructions, i.e., CSRW, CSRR, are decoded into formal CSR instructions by processing the write or read value as 0 according to the logic that operates when uimm | rd is 0 as specified above.  

I should print the Privileged Manual as well. That’s it for today. 23:57.  
I never feel quite refreshed when ending in the middle of some research. I would feel good if I at least made a firm diagram…

And since the semantically complete implementation of FENCE requires a multithreading environment, the process after pipelining will be the implementation of a dual-core processor after the G extension.  
Just thinking about designing a shared cache and implementing the timing coordination and logic between the two harts already makes my head spin…

### [2025.02.15.]

I was on duty, read Chapter 1 and 2 of "The RISC-V Instruction Set Manual: Volume I; Unprivileged Architecture" What I need to read in Unprilviled is about 123 pages. I read 37 of them.  

### [2025.02.16.]

I slept after finishing duty and woke up. Around 16:00. After setting up the development environment, CC84 showed me the Vivado synthesized RTL schematic of the ALU.  
I saw wiring that looked quite complex and densely packed to the point I wondered if it was really this big. So I looked for other Verilog HDL–based schematic tools and found a pretty decent one.  
It isn’t an industry-standard RTL schematic style, but it’s called DigitalJS; if you upload a Verilog file, it shows the circuit at the RTL level and lets you test it by entering values in real time.  
I haven’t yet found a way to run a testbench, but it seems like a pretty good tool. I don’t know at what synthesis level Vivado generated the schematic, but the rough form looked similar enough that it seemed fine.  
While testing the ALU in DigitalJS, I discovered that the SUB instruction wasn’t working properly. For some reason, when it was SUB, the MUX signal did select the SUB calculation circuit, but the SUB output was shown as xxxx.  
I raised this with CC84, and he said he’d take another look if he had time when he got back from off-base leave today.  
Come to think of it, I was a bit flustered because there was no explicit code specifying how to handle negative results from subtraction, but in the first place the ALU input data are 32-bit “sign-extended”…  
Oh, no—right. When the subtraction result is negative, a two’s-complement sign-extended value should come out, and it seems there’s no related logic.  
When calculating negative minus negative, since it’s arithmetic on signed values, the result will be signed anyway, so that’s fine, but if a positive and a negative, or a positive and a positive yield a negative result, it seems necessary to review the logic of the ALUresult output.  

Once again, my to-dos:

1. Establish the set of CSRs to implement
2. Review the CSR module design and revise the diagram based on 1
3. If necessary in 2, modify the logic of other modules
4. Based on 2, write the Verilog HDL code for the CSR_File

The biggest roadmap at the moment  
Build the Top-Module Verilog HDL for RV32I37F. Verify with a testbench.  
- RV32I43F CSR  
- RV32I47F Cache  
- RV32I50F Debug  

- 5-stage pipeline extension
- G extension
- OS installation, run DOOM.

It seems implementing expansion interfaces will inevitably be necessary.  

Regarding installing an OS on RISC-V, I checked the Linux kernel’s RISC-V documentation and looked through various projects and materials.  
I also looked into high-performance RISC-V processors, and the XiangShan NH processor developed in China in 2022 stood out.  
SiFive, the industry frontrunner in actual design and sale of RISC-V processors, clearly has limitations on several business fronts and in technology/price, and hasn’t fully handled RISC-V’s potential, but the NH processor has a fairly advanced dual-core structure and seems to achieve at least Haswell-era x86-Intel-level performance.  
What’s notable in that paper is that, instead of being bound by traditional processor design/verification methods, they built an efficient chip production procedure and taped out the base processor in about 10 months, then improved performance in the second generation (the NH processor).  
There are 37 authors, so it’s clearly not an outcome a mere handful of people can achieve.  

In the end, the purpose of making the G extension stems from OS installation, but for fast project progress, it seems better to focus on OS installation rather than making the G extension the main goal.  

**—Evening study period—**  
Establishing the list of CSR implementations.  
Current RV32I50F, at a level close to bare metal without an OS, list of CSRs to implement

—Unprivileged CSRs.—  
- • Counter / Timers
   - cycle (h)
   - time (h)
   - instret (h)
   - hpmcounter 3~31 (h)

—Machine-level CSRs.—
- • Machine Information Registers
   - mvendorid
   - marchid
   - mhartid
- • Machine Trap Setup
   - mstatus
   - misa
   - mie
   - mtvec
- • Machine Trap Handling
   - mscratch
   - mepc
   - mcause
   - mtval
   - mip
- • Machine Counter/Timers
   - mcycle (h)
   - minstret (h)
   - mhpmcounter3~31 (h)
   - mhpmevent3~31 (h)
   - mcountinhibit

### [2025.02.17]
It’s combat leave…  
Results as of 14:36.  
First, I finalized the move to 64-bit. For CSRs as well, the advantages of shifting to 64-bit are very strong.  
(CSR implementation becomes easier. Installing Linux becomes easier. There’s no need to consider memory misalign exceptions.)  
Therefore, after RV32I, I’ll do a bit-width expansion to RV64 and then build the 5-stage pipeline.  
And to raise project progress as much as possible, instead of focusing on the “G” extension, I’ll focus on OS installation and make a “5-stage pipeline RV64IMA_Zicsr_Zifencei + virtual-memory processor.”  
And as milestones, the RV32I project will yield a total of four core structures.  
Single-cycle, at the machine-level baseline.  

- RV32I37F – supports the basic RV32I instructions. Instructions like FENCE are treated as NOP.
- RV32I43F – RV32I + CSR
- RV32I47F – RV32I + CSR + Cache
- RV32I50F – RV32I + CSR + Debug

I will define the CSR files based on the current RV32I50F.  
Among the CSRs decided yesterday, things like mcycle that, on an RV32 basis, would require h-split [63:32], [31:0] logic partitioning/mapping won’t be needed after a 64-bit expansion, so all register files related to those will be zero'd.  
Therefore, the re-established list of CSR files for RV32I50F is as follows.  
Counters and cycle / instruction counters will be additionally implemented upon 64-bit expansion.  

—Machine-level CSRs.—
- • Machine Information Registers
   - mvendorid
   - marchid
   - mhartid
   - mimpid
- • Machine Trap Setup
   - mstatus
   - misa
   - mie
   - mtvec
- • Machine Trap Handling
   - mscratch
   - mepc
   - mcause
   - mtval
   - mip

Let’s design the logic for the above 13 CSR files and implement the CSR File.

CSR was a huge door… Each register has fields assigned that can represent interrupts, traps, and status, which means we must implement separate conditional logic so we can write the values those fields signify.  
Also, there are cases where two or more CSRs interact to perform an operation, and those must be implemented together as well.  
Registers whose understanding and logic design I’ve completed so far: Machine Information Registers, Machine Trap Setup.  

### [2025.02.18.]
Research and study on the 13 CSRs to be implemented.

### [2025.02.19.]
23:42. While researching approaches to implement the CSR, I heard news about the RV32I37F testbench and immediately went over.  
It looked like it had failed, and I thought it might be a tool issue, and while I was looking through the waveform file, around 23:42, on a whim I just went to ChoiCube84 and he was furiously typing something.  
Then the waveform popped up, and we witnessed certain success.  
**RV32I37F. Complete.**
The starting program was simple. Put the value of x0 + 10 into A, the value of x0 + 20 into B. A + B into C. A complete success. Everything worked correctly.  
This is where it begins. From now on we have to create a testbench to test each of the 37 instructions one by one.  
We originally tried to use the EECS fa22 skeleton benchmark code from UC Berkeley, but since the core design differs, we decided to create a separate testbench that cites that benchmark.  

### [2025.02.20.]
CSR establishment is complete. The contents organized in an xlsx file can be found in RV32I50F_CSR_Listings.  
The final list to be implemented is as follows.  

Spent 30 minutes on whether mtvec should be writable or read-only.  
Since it’s machine-level CSR behavior, it makes no sense for a mere user to control it, and even if we implement it, I can’t think of any benefit at all, and even if there were an instruction that changes the BASE address, we’ll implement vectored mode, so such a large bit cost becomes unnecessary—that’s how I explained it.  
We said the same two things for 30 minutes.

Anyway, that’s it for today. Most of the content is in the cells. Please refer to it.

### [2025.02.22.]
While on duty on 02.21, I defined all initial values for the CSRs and recorded both the cache memory structure and the CSR’s logic structure in the RV32I50F Core Architecture Manual document.  
And the implementation of the CSR file has begun.   
Up until now in this project, I took charge of the logic, diagrams, and operational design, and ChoiCube84 handled the implementation using Verilog.  
But I thought proceeding without touching Verilog in this learning-oriented project wouldn’t fit the purpose, so I said I’d implement at least the CSR file from scratch myself.  
Of course, there’s quite a bit to study and ponder within the CSR logic itself, so CC84 probably would have requested a separate meeting anyway… Once this implementation is done, we can immediately create the TB for RV32I43F and verify it.  

Currently, CC84 is generating the waveform for RV32I37F and setting up the testbench environment (defining intended output signals per module for each instruction).  
Our goal is to finish the first round of implementation and verification of the RV32I50F core within February.  
After that comes the 64-bit expansion and 5-stage pipelining, the IMA extension, and OS installation.  
- Mid-March to mid-April: 64-bit expansion and 5-stage pipeline
- Mid-April to mid-May: IMA extension
- Mid-May to July: kernel programming to install RISC-V Linux
- July–: paper writing (CC84 discharge…), mid-August: submit to arXiv.
- After August: write KAIST self-introduction
- September: admissions…

Phew… I can do it. Let’s do it well.

![RV32I50F.R1v4](/diagrams/design_archive/RV32I50F/RV32I50F.R1v4.drawio.png)

### [2025.02.23.]
Today I implemented the CSR logic in practice.  
What I spent nearly half a day on turned out to be a wild-goose chase, but the feeling of having learned about Verilog syntax during the process was stronger, so I wasn’t particularly disheartened.  
I had been implementing under the assumption that arithmetic/logic operations (Set, Clear) on CSRs would be performed within CSR as well.  
But if it works like that, I figured the CSR_File would no longer be a CSR_File and would be closer to a CSR_Unit, so I wondered whether I should hand those operations over to the ALU.  

I told CC84, who was surprised and came over asking me to explain. As I explained and stared at the diagram, I realized that my past self, when I was in good condition, had already designed it so CSR operations are carried out through the ALU, and the CSR_File is indeed designed to be a simple File that only stores and returns data.  
So I had been spinning off separate modules per CSR to implement, but I retired all of them and reorganized it into a single module called CSR_File that, based on address, CSRop, and clock, performs simple read/write operations.   
Then CC84 pointed out that CSR is needed not only for CSR instructions but also when values are required during TRAP, and I looked at the diagram again.  
Come to think of it, in TC we can just request the address with T.Addr, and the CSRFile simply receives that and returns it as RD.  
> Then CC84 said,   
if csr_op is 0 that implies the CSR is entirely inactive, so shouldn’t it not be 0? 

> KHWL explained  
that since reads themselves are asynchronous I’ll just use always *, and since the important instruction implementations involve writes anyway, the reads themselves can be returned at all times like a general register file regardless of CSR_NONE.

And if it’s like that, the output RDs won’t cause operational problems unless the CU selects them anyway.  
After thinking, CC84 said then we can just write with a CSR_Write signal. Thus the 3-bit CSRop signal was retired and replaced/optimized with a 1-bit CSR_Write signal.  
I then produced the CSR file in 15 minutes… (as always, research time is longer than implementation time…)   
Tomorrow I’ll make a TB and verify it.  
Tomorrow Monday I get combat leave as compensation for Friday duty, and although CC84 has a normal workday and it’ll be a bit inconvenient, let’s do our best.
Let’s go let’s go!!!

### [2025.02.24]

![RV32I50F.R2](/diagrams/design_archive/RV32I50F/RV32I50F.R2.drawio.png)

CSRFile implementation complete.  
I used combat leave for Friday duty and spent almost half a day touching only Verilog.  
While reviewing I learned a lot of syntax and various things, and although it’s a bit cumbersome, I found a way to partially lift the restrictions on the PC room computers.  
Installing drivers in Safe Mode and such… then I can run GTKWave too. Haha.  

Anyway, verification was the problem while implementing CSR, and in the TB the original value and the value after write should come out separately, but the original value, i.e., the value right after RESET, was not the designed 0 but the output signal value I had written just before.  
So after adding delays and flailing about, it behaved correctly and I made that the final.  
After dinner, I adjusted the format of my CSR Verilog file to match CC84’s existing Verilog design.  
With the remaining time, I manually rewrote the RV32I50F Core Architecture Manual that I had written on the duty PC and revised its contents.  
Then came evening study time.  

While I was adjusting the format of the CSR file and almost finished, CC84 found a critical problem in the top-module bench.  
The true value of the top-module bench is beginning to show!
The problem is: since ALUop does not have an instruction-type identifier, there’s no way to distinguish I-type SRAI from R-type SRA.  
For I-type instructions, only for shift instructions, I had separated them with funct7 and shamt in the imm field, and the key is slicing this.  
If we just slice the input source data, the ALU wouldn’t know whether it’s R-type SRA or I-type SRAI, so following the ALUop code for SRA, it could end up slicing f7 and shamt from RD2.  
I remembered the original intent that ALUop should include the instruction type, and when I looked up the meeting notes I found relevant content.  

#### From 2025.01.23. Meeting notes.
> CC84: What is the role of the ALUop signal? Is it merely ALU enable and Bypass?  
— The ALUop signal is an identifying code for performing type-specific operations, receiving the instruction type according to the opcode.  


The original purpose was to embed the Type in ALUop…  
It seems during development it felt more important to define the kinds of ALU operations themselves, so the direction changed.  
So I felt we should either add the instruction type to ALUop… or give a separate signal to notify the ALU of the type, but CC84 is thinking differently.  

He suggested slicing imm[4:0] and putting it into ALUsrcB. Doing so gives shamt → imm[24:20] → SRA operator. Shift by imm[24:20].  
But here’s the thought… yes, that works, but later there will be more instructions regardless of I-type and so on…
Thinking of generality for the future, wouldn’t adding a type-identifying signal be the right decision? This feels too limited to the SRA issue at hand…  
In the sense of including the meaning of a general solution, I think it’d be better to add a type identification signal.
Evening study time is over. We’ll need a separate meeting on this. That’s it for today.

### [2025.02.25.]

Weekday off-post… In the end, yesterday’s issue was decided by separately extracting imm and adding one more selection to ALUsrcB with a 4:1 MUX.  
Even if we consider future instruction extensions, merely identifying types doesn’t seem to yield a clearly suitable signal utility that justifies changing the current design.  

When I came back for evening study, I tried to systematize the memory–cache operation logic structure in earnest and document and concretize it, but a bit-related conflict over MUX arose with CC84.  
I, taking the most conservative stance in design, think that when not selected we must send an inactive signal.   
The complexity of the designed hardware will only increase over time, and even though it’s hard at our current scale to fully guarantee all operations, I think it’s better to guarantee as much as possible within the feasible range.   
Therefore, for all MUXes—only by the early RV32I43O standard—I had included 00 among MUX select bits, but when moving to 47F we decided not to use 00 at all and to use signals starting from 01. The 00 signal is for inactive, explicitly indicating that no value is selected by the MUX and that no value is output.   
This way it can be clearly seen in debugging and signal handling.  

But CC84’s design philosophy was different: maximum optimization and simplification.   Simplify circuits as much as possible, and if it’s fine to stream 0 or other default values into unused modules, then keep the select to just 1 bit (or the minimal bits absolutely needed), and remove “inactive” signals since they’re irrelevant to operation—he wants to do it that way in the name of ‘optimization.’  

It truly was a conflict arising from a difference in design philosophy.   
Even after I showed results of unnecessary operations caused by unnecessary signal streaming, he said he didn’t know what the problem was.   
It seems that was a reply considering that since it ultimately doesn’t affect the outcome, it doesn’t look like a problem. (See RV32I50F.R2_B-Type)  

![RV32I50F.R2_B-Type](/diagrams/design_archive/RV32I50F/RV32I50F.R2_B-Type.drawio.png)

After much thought, since the inactive signal was kept with the possibility it could become a problem later in mind, I said we’ll add the inactive signal if and when it becomes a problem.  
CC84 said he already proceeded with 3 bits as discussed, so let’s revisit it in a later optimization session. 
Thus I again got nothing done during evening study, with only about 5 minutes left…  
Originally, the deadline was to finish design and verification up to RV32I50F within February and move to 64-bit expansion in March, but it feels even further away.
Still, shouldn’t we do what we can.

### [2025.02.26.]

Revision on 37F and 50F
![RV32I37F.R2](/diagrams/design_archive/RV32I37F/RV32I37F.R2.drawio.png)
![RV32I50F.R2v2](/diagrams/design_archive/RV32I50F/RV32I50F.R2v2.drawio.png)

Today I did meal support and spent the morning recovering from fatigue with CC84, and in the afternoon I studied cache structures.  
I finally understood how Tag, Index, and Offset are operated and learned various cache mapping methods. Naturally we will adopt the Set-Associative method.  
If the base were firmly established and we had the developed base processor and the wherewithal, I’d like to consider other cache mapping methods or storage logic, but we don’t have that leeway now.  
The cache data array is composed of Sets and Ways.   
There are Ways, which are collections of Sets, and the more columns a Way has, the larger it gets.   
The Tag, a component of the cache, is stored along with the data. First, through the Index, we determine which Set the data is in.  

Then, through the Tag, we determine which Way it is in. And the data tagged in that Way. In other words, a cache’s data does not store only one memory’s data, but, depending on design, stores multiple pieces of data.  
Among those multiple pieces of data, to find the currently needed memory data, we use the Offset. This is the basic operation of the cache. (Set Associative)  

We plan to equip the cache update logic with LRU, and need to look into the practical implementation related to this.
That’s it for today.

### [2025.02.27.]

Duty shift. Writing the RISC-KC Processor Design Manual. Systematized future roadmaps, current development status, and the formats. 

### [2025.02.28.]

Already the last day of February.   
Originally the deadline was to finish verification up to RV32I50F, but it looks like it’ll only be RV32I37F. In fact, even so, it more or less matches the original timeline, so it’s not a big problem, but it’s still a shame.   
Originally I was going to push the manual as far as possible, but today we decided to finish verification together for RV32I37F.  
Because at this rate it felt like we’d still be verifying RV32I50F come March and even by the time of discharge.  

As we verified together and evening study time was ending, I, while verifying BE_Logic, noticed something odd in Data Memory’s read. CC84, at the same time, was verifying Data Memory, and each of us confirmed in an LW operation that the data read from Data Memory is output in the next clock cycle.   
After investigating, we found that a synchronous Data Memory with a Read Enable signal outputs data in the cycle after a read signal is sent.  

The mechanism by which this happens was a bit different in our logic structure.   
In the RV32I37F testbench, after passing through the three Store (S-type) instructions, it is designed to immediately perform the six I-type Load instructions, so the falling edge of the Memory_Write signal coincides with the rising edge of the Memory_Read signal, and with the clock’s rising edge rising in between, some state occurs such that the default clause of a case with no activation signal received is executed.  

That’s the situation, and by changing the default value to DEADBEEF, CC84 verified that was indeed the case.   
In that case, we either have to devise a method of placing the memory read signal over two cycles, or devise a way to make it work within a single cycle.

## RV32I50F.5SP Development (50F + 5-Stage Pipeline)

### [2025.03.01.]
I went out on weekend leave today and came back feeling refreshed.
What I did after returning was signal verification for the modules.

- 25.03.01 Verified Module List
   - ALU
   - ALUcon
   - Branch Logic
   - Control Unit
   - Instruction Decoder
   - Instruction Memory
   - PC Controller
   - PC + 4
   - Program Counter

- Queued Module verification list
   - BE_Logic
   - Data_Memory
   - Immediate_generator
   - Register File

I said we should take this opportunity to separate the raw_imm signals from the imm signals; if we don’t do it now, we probably won’t.  
In fact, we still haven’t resolved how to handle the issue in Data_Memory where, presumably due to the limits of a synchronous structure, a read doesn’t output the expected value immediately on the read signal but in the next cycle instead.  
Still, I do feel we’re making progress as new problems arise and we tackle them one by one. I’m relieved. Let’s keep it up. Always grateful, CC84.  

- As for the cycle issue in DM, we set the direction to remove Memory_Read—that is, the read enable signal.  
  We plan to switch to logic that always reads in step with the clock without a read enable. However, removing Read Enable can introduce problems, so we’ll look into that and apply countermeasures.  
  For now, we’ll do it this way to get data output in a single cycle, and we’ll aim to mitigate the resource cost in a later optimization pass.

### [2025.03.02.]

Continued verification.
Data Memory can be verified outside the problematic cycle window, so I began verification excluding the Load portion that triggers that cycle issue.   
While verifying BE_Logic and Data Memory, I found that only LW needs to be ignored; other loads such as LH and LB all work correctly.   
With LW excluded, verification of those two modules is complete, leaving only Immediate_generator and Register File.  

Immediate_generator remains queued because the raw_imm signal refactor is in progress; values could change again after verification. Register File also remains queued, since it only makes sense to verify once Data Memory is fully settled.

On removing the Read Enable signal: after looking into it, most real systems—including the FPGA used for validation—employ synchronous memories like SDRAM that do use a Read Enable.   
Considering stability and what the standards imply, I decided to keep Read Enable. The question is how to handle it.  

Five-stage flow (Fetch, Decode, Execution, Memory, Write Back): until valid output is ready, the current PC must be held, and Fetch/Decode must be paused. In Data Memory, when a read returns Memory[address], it will simultaneously raise a read_done signal to 1; otherwise, it stays 0. That lets the FSM know whether the read completed.  

Following the earlier Write Done idea, I’ll feed read_done into the PC Controller; when read_done is 0, set NextPC = PC. One open question: if there is no memory access, should read_done be treated as 1 by default? I’ll discuss this with CC84.  

CC84 finished the raw_imm refactor and typo fixes and handed me rv32i37f testbench v2. Based on that, I’ll re-verify the signals, think through related issues, and work on the five-stage pipeline design.  

RV32I37F Top-Module testbench; Module Verification Listings.

- = 25.03.01 =
   - ALU
   - ALUcon
   - Branch Logic
   - Control Unit
   - Instruction Decoder
   - Instruction Memory
   - PC Controller
   - PC + 4
   - Program Counter

- = 25.03.02 =
   - Data Memory (excluding LW)
   - BE_Logic (excluding LW)

- Queued  
   - Immediate_generator
   - Register File

Discussion with CC84 about Data Memory reads.  
Adopting a read_done signal seems best, but first we checked whether modern memories like SDRAM have such a signal.   
They do not. I pointed out that up to RV32I50F we’re effectively building a memory-embedded SoC, and in such cases the architecture often uses special-purpose designs. Our Instruction Memory is currently a ROM, I/O isn’t implemented yet, and adopting standard I/O and memory structures beyond RV32I can reasonably wait until we’ve built enough hardware background and before OS bring-up.

Conclusion: add read_done and feed it to the PCC so we only proceed to the next instruction after a Data Memory read completes. (Isn’t this what FENCE was for? Not sure.)   
Also, once we pipeline or go dual-core and bring in SDRAM/DDR4-class hierarchy, retrofitting will be costly; we need to pick the right timing for that transition. 

For now, I revised RV32I37F to R2.v2, adding read_done to Data Memory and PC Controller.   
![RV32I37F.R2v2](/diagrams/design_archive/RV32I37F/RV32I37F.R2v2.drawio.png)

Next step: re-verify with the updated testbench.

raw_imm verification complete.
- Cross-checked across three modules:
   - Instruction Decoder
   - Immediate Generator
   - ALU Controller  

Aside from a few expected-value typos in Instruction Memory today (LHU, LBU, LUI), raw_imm and imm both work correctly across all modules.

Final decision on Data Memory read logic.  
After thinking through it during evening formation and discussing with CC84, we settled on this:

Keep the current Data Memory logic, but add a read_done output.  
Goal: produce the read value in response to a read signal without inserting duplicate instructions.  

Load instruction handling
- The Control Unit detects a load.
- If read_done is 0, assert a PC_Stall from the CU to the PCC to hold PC = PC.
- On the next cycle, read data appears and read_done goes to 1 simultaneously.
- PC_Stall deasserts and PC advances to NextPC.

If the next instruction is also a load
- Memory read remains 1.
- read_done is already 1, so we advance immediately.

If the next instruction is not a load
- Memory read drops to 0.
- read_done is also 0, but since this isn’t a load, it’s ignored.
- PC_Stall remains deasserted and we continue to the next instruction.

PC Stall datapath
- Data Memory asserts read_done to the Control Unit.
- The Control Unit drives PC_Stall to the PC Controller based on read_done.
- When PC_Stall is asserted, the PC Controller holds NextPC at the current PC, blocking further instruction issue.
- When read_done is 1, the Control Unit deasserts PC_Stall and execution resumes.  

With read_done and PC_Stall added for Data Memory reads, RV32I37F verification should be ready to wrap up. Hopefully the testbench shows no issues.  

While Data Memory read revisions and Register File verification are finishing, I’ll draft the five-stage pipeline:  

- Stages
   - Fetch, Decode, Execution, Memory, Write-back

- Interstage registers (4 total)  
   - IF/ID register (between IC and ID)  
   - ID/EX register (likely between ALUcontroller and ALU; needs more study)
   - EX/MEM register
   - MEM/WB register

A new module will be the Hazard Unit (for hazard handling).

That’s it for today. CC84 has already finished verifying PC_Stall in the PC Controller.  
We’re making tangible daily progress. Let’s keep going.

### [2025.03.03.]
Designing the 5-stage pipeline and drawing the diagram.  

The pipeline has five stages:  
- Instruction Fetch (IF) – instruction fetch
- Instruction Decode (ID) – instruction decode
- Execution (EX) – execute
- Memory access (MEM) – memory access
- Write Back (WB) – write-back

The point of a pipeline is not to restrict work to a single instruction, but to parallelize by treating each stage of instruction processing as its own unit in sequence.   
To execute multiple instructions per overall cycle, we need somewhere to hold the data each stage requires; that place is the pipeline registers.

These pipeline registers are D flip-flops driven by the clock. On each clock, they output the value stored in the previous cycle and capture the next value—just simple registers.   
They are not addressable like a memory. Each pipeline register holds the state and data (the “context”) required between stages.

In a 5-stage pipeline we need four pipeline registers:  
IF/ID register, ID/EX register, EX/MEM register, MEM/WB register.

From here, I’ll place each register in the block diagram and learn the signal discipline and structure of the pipeline as I go.

First, the IF/ID register goes between the Instruction Memory side and the Instruction Decoder.   
Inputs are PC and I_RD. Other signals that must act globally and immediately, regardless of the pipeline, stay outside the pipeline.   
For example, IC_Status and NextPC (from the Exception Detector) are globally controlled and must take effect immediately at any stage, so they are not needed in the IF/ID pipeline register.

Next, the ID/EX register.  
The Instruction Decoder already splits out signals like opcode, funct3, funct7, and imm and wires them to each module. Now those signals should pass through the ID/EX register before reaching the modules.   
Be careful not to disturb independently operating paths—e.g., don’t interfere with signals like J_Target that share similar routes. While drafting the pipeline I wondered whether the presence of ID/EX would make the Instruction Decoder unnecessary, but the conclusion is no: we still need a separate module to do decoding.  

“CPU fits on a single A4 page” they say… It’s starting to feel hard to keep it all on one sheet. The limit comes from labeling each signal with explicit source and destination to keep datapaths clear. I’ll try to keep this 5-stage pipeline on a single A4 for now, then consider increasing the layout size afterward.   

These are draft designs of RV32I50F's 5-Stage Pipelining : RV32I50F_5SP
![RV32I50F_5SP-draft0](/diagrams/design_archive/RV32I50F.5SP/RV32I50F_5SP.drawio.png)
![RV32I50F_5SP-draft1](/diagrams/design_archive/RV32I50F.5SP/RV32I50F_5SP(1).drawio.png)
![RV32I50F_5SP-draft2](/diagrams/design_archive/RV32I50F.5SP/RV32I50F_5SP(1)(1).drawio.png)
![RV32I50F_5SP-draft3](/diagrams/design_archive/RV32I50F.5SP/RV32I50F_5SP(1)(3).drawio.png)
![RV32I50F_5SP-draft4](/diagrams/design_archive/RV32I50F.5SP/RV32I50F_5SP(1)(6).drawio.png)

-----

CC84 uploaded a waveform for the RV32I37F Data Memory read-timing fix; I haven’t looked yet, but CC84 says it seems fine. Good—if it hadn’t worked, it would have taken longer, which might have been painful but also fun. There will be equal or worse problems ahead anyway. For now I’ll take a quick PX break and then start signal verification. If things go well, we might finish RV32I37F verification today.

During verification… (waveform via GTKwave / Surfer project)

Both Read Done and PC_Stall behave correctly. Only on the first read does the logic stall until the read finishes; after that initial two-cycle read produces the correct value, subsequent loads return in a single cycle as intended. Later, during pipelining, this PC_Stall from the PC Controller should be handy for hazard handling. Good—this worked as designed.

At 16:14 I found the Data Memory WriteMask—and its 32-bit extended mask—lagging by one cycle. Oddly, stores still worked. I fed this back to CC84 and we fixed it. The extended mask had been updated on the clock; declaring extended_mask as a wire solved it.

March 3, 2025, 17:06
RV32I37F complete. (Almost.)
With the testbench reflecting the new Data Memory read logic and after Register File verification, all modules and signals are finally verified. Great work. With a solid foundation we can do anything next. Next up is CSR (43F), then the cache structure (47F), then the debugger (50F). Let’s go.  

While CC84 integrates my CSR module into the RV32I43F top module, I’ll keep working on the pipeline. If I can finish a first draft of the pipeline today, that would be fantastic.  

Ah—I noticed RV32I37F’s misalignment checks weren’t in the testbench. I quickly asked CC84 to add them:  
- misaligned jump target
- misaligned branch target
- misaligned register address
- misaligned data memory address

I requested tests for all four, but CC84 asked to do only one; we settled on two cases:  
- misaligned PC and misaligned data memory address.   

It’d be best to cover them all, but it seems heavy right now; given the effort already spent, I accepted that for the moment. I could just do it myself…

We discussed improving the repository file structure, and concluded that making separate folders for each of RV32I37F through 50F will lead to too much duplication.   

We then created a PC_Aligner and discussed misaligned data-memory addresses. 
For reads, there’s no change—our logic forces the lower two address bits to 00 on reads, so misalignment doesn’t arise. 
The issue is misaligned store addresses: here CC84 and I (KHWL) differed.   
CC84 wanted to perform the store instruction but suppress the actual write (address accepted, no write).   
I wanted to force the lower two bits aligned (like an ECC-style correction) so the operation completes. After debate, considering potential security implications raised by CC84, we decided to handle it like a HINT: effectively skip the write.  

#### RV32I37F Waveform RTL Verification Complete

Thus I produced the final RV32I37F diagram, RV32I37F.R3. It looks like PC_Aligner and Data-Memory misalignment handling are in place. Time for verification.  
![RV32I37F.R3](/diagrams/design_archive/RV32I37F/RV32I37F.R3.drawio.png)

Verification done.  
CC84 only changed the JAL and LW addresses; they worked in the original bench, so for the extra bench we just updated values. 
There’s no signal that explicitly shows LW’s auto-aligned address value; we confirmed the mis-entered address (0000_02c1) went in, and since there’s no address output signal, we confirmed the correct data was loaded as expected.

We added a scenario where misaligned operations are skipped, and captured a new VCD.   
We verified that misaligned cases are simply skipped with no side effects, like a HINT.   
For stores, we also saw BE_Logic’s misaligned flag assert.

With that, RV32I37F verification is complete—2025-03-03 23:34. RV32I37F is done.  

Nine minutes left in evening study… I’ll sketch more of the pipeline and call it a day. Keep moving forward.  

### [2025.03.04.]
Today I planned to continue the 2-stage pipeline design and place the EX/MEM register.  
During duty hours I reread the pipelining chapter of “Computer Organization and Design,” 5th ed.; as expected of a textbook, there was a lot worth referencing.  

I couldn’t develop during personal maintenance time, so I was going to start during evening study.
Right then CC84 said he had to take an e-learning course and asked if I wanted to implement RV32I43F myself.  
At first I thought the pipeline should come first, but since I also implemented the CSR file, I decided it might actually be good for me to implement RV32I43F, too.

So I began the RV32I43F top-module design.  
Based on the RV32I37F code, I newly declared the CSR module signals and instantiated the CSR File.  
While doing so I noticed that after csr_op had been retired (replaced by csr_write_enable), that change wasn’t reflected in the Control Unit.  
I requested permission from CC84 to modify the Control Unit’s csr_op handling and, once approved, made the change.  

Plan for tomorrow:
- Testbench for the Control Unit’s csr_write_enable signal
- Review RV32I43F CSR derivations and datapath clauses
- Add CSR-related instructions to Instruction Memory and run the RV32I43F DUT
- Analyze waveforms and verify

That’s it for today.

### [2025.03.05.]
Duty day. I only worked on writing “RISC-KC Processor Design Manual I.”
Aside from about 30 minutes dozing and handling tasks, I spent nearly the entire time on this document.
I drafted all of Section 3.2 (Main Modules), and for Extension Modules I only have three left to write: Memory Controller, Exception Detector, and Trap Controller.  
At this pace, two or three more duty shifts should finish the whole thing.  
Somehow it’s already at 18 pages, and it’s still a draft with lots left out—so it’ll grow even more.  

### [2025.03.06.]
After lights-out for duty personnel I woke up around 16:00. I tried to get a haircut but the line was too long, so after dinner I went straight back to development.

**Tasks**

1. Apply upper-architecture changes on top of the 37F architecture.
   - Diagram first:   
   I carried over the Read Done signal and PC_Stall added in the 37F implementation, and for the 43F diagram I also included PC_Aligner so that 37F is fully inherited. Named it RV32I43F.R2.

2. Build RV32I43F
   - Control Unit TB (CSRop → CSR_Write Enable).  
   - Top-module integration + TB.  
   I replaced csr_op with csr_write_enable and ran the Control Unit testbench; it works. 
   When OPCODE_ENVIRONMENT is selected and funct3 ≠ 0 (i.e., CSR instruction), the old csr_op assigned per-funct3 behaviors; now that we’ve optimized to a simple write-enable, that logic is unnecessary, so when funct3 ≠ 0 I assert csr_write_enable = 1.  

I also began wiring the RV32I43F top module: declared/derived signals and instantiated the CSR File. 
I’d previously split out a separate csr_write_data wire in the top, but architecturally the CSR write data is just ALUresult, so I removed csr_write_data and feed ALUresult directly into the CSR File’s write data.  

![RV32I43F.R2](/diagrams/design_archive/RV32I43F/RV32I43F.R2.drawio.png)

That’s it for today. Let’s go!

### [2025.03.07.]
*I had a “combat leave” day but got almost no development done.   
In the morning the duty officer suddenly tightened restrictions on the PC room; by afternoon I was dragged to the mobilization training site for handover despite being on leave, and it turned into manual labor rather than real knowledge transfer. I swallowed the frustration, got back right before personal maintenance time, opened the lab, and started.
I was supposed to push RV32I43F code, but to cool my head I switched to pipeline design.*  

The essence of pipelining is to split a single-cycle instruction into five cycles (or however many stages you define), and then decide which signals live in which stage, which are global (not pipelined) vs. local (stage-scoped), and which are used/unused per stage.  
Before, I could think up the logic, design a module, and drop it into the block diagram; now I also have to reason about timing and locality so the right signals arrive at the right stage—this raises the difficulty.

I’m drafting the RV32I50F 5-stage pipeline diagram.   
IF, ID, and EX are pipelined now; EX/MEM register placement is the sticking point. 
EX comprises ALU Controller, ALU, and Branch Logic; fitting all of that on one A4 page is tough.   
I could omit I/O labels to shrink blocks, but this is a learning-oriented project and I’d hate to lose explicit signal names. I’ll compress signals and pack modules tightly—boosting our “integration density,” ha. Time’s up for today; tomorrow’s goal is a first draft of the 5-stage pipeline.

![RV32I50F.R3_temp](/diagrams/design_archive/RV32I50F/RV32I50F.R3_temp.drawio.png)
![250307-RV32I50F.5SP_temp](/diagrams/design_archive/RV32I50F.5SP/250307RV32I50F.5SP_temp.drawio.png)

### [2025.03.08.]

![250308-RV32I50F.5SP_temp](/diagrams/design_archive/RV32I50F.5SP/250308RV32I50F.5SP_temp.drawio.png)

I designed the RV32I43F top module and loaded Zicsr instructions into Instruction Memory.
Uh-oh: writes are landing one cycle late. That’s a problem.

### [2025.03.09.]

I suspected it might just be a waveform handling issue, so I verified whether the expected values were coming out correctly.   
In consecutive writes, reads, and references, despite the waveform seemingly indicating that values were written in the next cycle, the values were in fact read smoothly and the expected results matched, so I marked verification complete.  

To be honest, there were quite a few issues getting through verification up to this point: the CSR write-enable signal wouldn’t assert, CSR instructions weren’t displayed correctly on the waveform, I appended a HINT instruction at the end to check the final-cycle result of a preceding instruction but the new instruction wouldn’t enter, the Register’s write source wouldn’t get selected to CSR properly, etc.  

Most of these were issues with deriving MUXes, modules, and signals that needed expansion or modification to graft RV32I43F onto the RV32I37F architecture; there were no fatal logic errors or module-level rework required.  
I should have recorded things right away, but two days slipped by without the chance, so this is pretty condensed.  
We’re getting to the point where an FPGA board is needed to proceed with implementation verification. *I spent a fair bit of time choosing a board, and along the way I came across ADChips’ EISC-architecture “ARK core,” a general-purpose CPU from a domestic Korean company. Might be worth looking up later.*  

DE0-115 and Z7-20 were in the initial candidate set as mainstream FPGA boards, and I figured time having passed, there’d be better boards for similar prices—but no. 
The Z7-20 seems the most suitable. It has a graphics output interface, it’s Xilinx-family so we can rely on AMD’s FPGA courses and support, and the licensing… is quite permissive!

### [2025.03.10.]
*One year since enlistment. I got dragged out early as a mobilization-reservist TA and accomplished nothing notable, then came back, rested, and realized personal maintenance time ends at 20:30—so I rushed over to write the overdue dev logs.* 

I just finished the logs for the 8th and 9th. It’s 20:26 now.   
I have to go… I wanted to buy a Z7-20, but as a personal purchase it runs close to 600–700k KRW, and running it on base would incur nontrivial additional costs… Tomorrow I’ll bring the computer architecture textbook and a print of the current architecture diagram, and whenever there’s spare time I’ll continue the pipeline design and study dual-core architecture.  

It is what it is. Let’s handle it. *(ChoiCube84 started leave(vacation) today… and there’s no evening study because of training tomorrow…)*

### [2025.03.13.]
*Three days of mobilization training are over. I’ll go back tomorrow to wrap up, but tonight I got personal maintenance time. Whether from fatigue or from frustration at not being able to develop, I felt pretty drained.*

Looking over the diagram pipelined up through stage 3 (EX/MEM), I kept thinking about how to implement dual-core and multithread scenarios.   
In multi-hart, multithreaded, multi-core environments, it’s less about structural differences between cores and more about how to share a common memory space, distribute resources, and implement distributed scheduling. 
We need to control the instruction execution flow in hardware—how can that be implemented?

Hoping for leads, I excerpted Chapter 17 (RVWMO) and the Rtso section from the RISC-V Volume I manual and brought them to training. 
I read them when I could, but I can’t claim full understanding yet.  

In pipelining, the EX/MEM stage needed some thought about memory control signals. 
In the 50F architecture, signals that must bypass the pipeline and be handled immediately—like exceptions—are already managed by the Exception Detector and Trap Controller, so excluding those that directly connect there, the remaining memory control signals should pass through the pipeline registers so that instructions execute at the correct time. 
That’s the conclusion I reached.

So my goal for this evening study block is to finish a first-draft diagram of RV32I50F_5SP.

The Memory Controller’s IC_Status and IC.IM_MUX signals control cache behavior in the fetch stage, so they are not connected to pipeline registers.  
Also, while planning the pipeline, I recalled that in the current 47F cache-structure definition we assumed cache and memory share the same address inputs. 
Previously, based on the (now-dropped) premise that their address schemes differed, I had implemented logic in the Memory Controller to convert the address upon an instruction cache miss and feed that to the cache; I’m rolling that back and deleting the Memory Controller’s PC and I.Up_Addr signals. 
In the instruction area, instead of having the Instruction Cache output PC to Memory per the old diagram, I’ll just take the PC signal straight from the Program Counter register module and keep the STAA structure as-is. 
In the current architecture, I don’t see a reason the Instruction Cache needs to output a separate PC like before.  

But I still don’t know what to do with the Read Done signal. 
I’ll have to verify this later hands-on. 
Trying to find a theoretical basis here and design a perfect architecture from the start would take too long.

In progress. I almost finished the MEM/WB register, but due to space limits I have to move it to the side.

![250313-RV32I50F.5SP_temp](/diagrams/design_archive/RV32I50F.5SP/250313RV32I50F.5SP_temp.drawio.png)

### [2025.03.14.]

ChoiCube84 implemented the Instruction Cache. I verified the logic.  
I found the module design differed from the diagram and started discussing it.  
We had included an IC_Clean signal in the diagram for the FENCE.i instruction, but it wasn’t in the code. When he suggested we could just handle it with reset, I agreed.  
He had structured the current code with an FSM concept, separating Update Mode from normal operation. I said there was probably no need to go that far.  
On a cache miss, an update is just a simple write, and I quoted what we had organized during the 47F cache-structure planning.  

![250314-RV32I50F.5SP_temp](/diagrams/design_archive/RV32I50F.5SP/250314RV32I50F.5SP_temp.drawio.png)

1. Since the cache itself detects a miss, keep an internal register and, with a conditional, when satisfied, write the data being fetched from memory into the cache immediately.

2. Following clear separation of roles and design philosophy, send the Hit/Miss signal to the Memory Controller, and have the MC send the corresponding control signal back to the cache.  
That becomes the cache’s write-enable signal; when asserted, the cache writes the memory’s incoming data to the designated address.

Those were the two approaches I had in mind, and the one reflected in the current diagram is (2).  
We send the Hit/Miss to the Memory Controller; the MC recognizes it and sends a Write Enable to the cache, which writes the fetched memory data and updates.  
Looking closely now, I noticed that Write Enable signal is actually missing from the diagram. To-do item added.  

I also finished thinking through where, in the 5-stage pipeline, to connect the Read Done, Write Done, and BTaken signals to their respective modules.  
Pipelining turns a single-cycle instruction into five staged cycles to increase throughput, but not every instruction must be split across all stages. You can emit signals to the needed modules in the needed stages, and treat the rest as NOP.  
So I connected Read Done and Write Done to the Control Unit in the MEM stage, and connected BTaken from the EX stage to the PC Controller.

While firming up Write Done, I realized we held different understandings of the buffer–cache–memory structure.  
What I had in mind was this: our data cache unit has a buffer space.  
On a cache write, you first write into the buffer; when there’s no memory access (read/write) in progress, hardware immediately flushes the buffer into the cache.  
If consecutive writes fill the buffer, the cache detects this and sends a DC_Stats signal to the Memory Controller to indicate a flush is needed.  
The Memory Controller recognizes this and sends a B2M_Flush to the Data Cache, which flushes the buffered data directly to memory.  
The data flow is Buffer → Cache → Memory, but when the buffer is full, it flushes Buffer → Memory in one go.  

ChoiCube84, however, was describing cache → buffer → memory rather than buffer → cache → memory.  
I’d already felt something was off; architecturally, his version makes more sense.  
So we settled on the more standard, higher-level “write-back” cache structure and left the earlier buffer concept in the dev log as an idea.  
Write Done remains necessary for write-back and FENCE. The meaning shifts slightly: after a write-back completes and data has been written to data memory, Write Done indicates it’s safe to proceed with the next data-memory-accessing instruction.  

And as we applied the PC_Stall logic—added during 43F design and verification—to the 47F-based architecture, we no longer need to send Write Done to the PC Controller.  
Write Done will go only to the Control Unit, and the CU will adjust PC_Stall based on it.


![250314-RV32I50F.5SP.R1](/diagrams/design_archive/RV32I50F.5SP/250314RV32I50F.5SP.R1.drawio.png)

### [2025.03.15.]

Thinking it through, we obviously need a discriminator to notify the Instruction Cache of FENCE.i and trigger invalidation. 
The IC_Clean signal should exist. The Trap Controller should receive the FENCE.i identifier and cause the Instruction Cache to invalidate.   
However, instead of handling the Trap Controller’s signal as a separate IC_Clean input in the Instruction Cache, we can simply treat it as the RST (reset) signal.

![250315-RV32I50F.5SP.R1](/diagrams/design_archive/RV32I50F.5SP/[250315]RV32I50F.5SP.R1.drawio.png)

- After switching the cache write policy to Write-Back, ChoiCube84 asked about the cache–memory interface signals: 

> when writing back from the cache to memory, is it enough to send only the new data value, or must we also send the address? 

- My answer:  
Write-Back is triggered in the following situations:  
When we need to bring in a memory block with a different tag into a cache line that already contains modified data, we must write the old line back to data memory.  
This can occur on both reads and writes in the data area:  
   - On a read miss, we may have to evict a modified line to make room for the miss line we load into the cache.
   - On a write, if the targeted line is occupied and dirty, its modifications must be reflected back to memory.  

   Because of STAA, the same value ends up being used on the read path anyway. 
   The key with Write-Back is that the address to be written to memory is not the address of the currently executed access, but the address of the line that must be written back. 
   Therefore, a separate address must be provided.   
   Since the address format and values on the data side are the same, the cache can drive memory directly. 
   I updated the leftover buffer-era B2M_Data and B2M_Addr signals to WB_Data and WB_Addr.

With this updated cache design integrated, the pipelined architecture has been completed. 
But this is not the end of pipeline processor design—the placement of pipeline registers is really just the prelude. The real work begins with the Hazard Unit, which handles hazards introduced by pipelining.

For now, I need to push the updated 47F architecture diagram to ChoiCube84, reflecting the pipeline register placement and the latest cache design. Let’s go.  

18:56 — RV32I47F.R10 completed. I applied the changes introduced in the 43F architecture and updated the diagram to incorporate the revised cache structure from the 50F 5-stage pipeline work. I also simplified the Mybox file layout.

![RV32I47F.R10](/diagrams/design_archive/RV32I47F/RV32I47F.R10.drawio.png)

Next up: design the Hazard Unit.

According to “Computer Organization and Design” (David A. Patterson, 2015), hazards that can occur in a pipeline are:

Definition of a hazard: situations in which the next instruction cannot execute in the next clock cycle. There are three kinds:

1. Structural hazards
   Hardware cannot support a particular combination of operations in the same cycle.

2. Data hazards
   The pipeline must be delayed when one stage has to wait for another to finish. In CPU pipelines, a later instruction depends on a result still in flight from an earlier instruction.

3. Control hazards

I spent the evening session studying pipelining. 
The key insight was to treat data signals and control signals separately, and to deliver each to the appropriate module within its designated stage; this was my biggest concern, and the textbook provided a clear guideline that matches what I had already reasoned out. 
Good—validation.

There is a problem, though. This isn’t about pipelining per se, but about our rv32s: beginning with the implementation of lw, it is no longer a single-cycle processor, and the cache makes it even harder to fit everything into one cycle. 
Extending the clock period to cram all actions into a single cycle is not a fundamental solution, since most logic is posedge-driven anyway.

![HazardDesign-RV32I50F.5SPH.R1](/diagrams/design_archive/RV32I50F.5SP/RV32I50F.5SPH.R1.drawio.png)

### [2025.03.16.]

This morning, I optimized the signal routing in the RV32I50F.5SP.R1 diagram. While reading the Computer Organization & Design book yesterday, I noticed a tendency to bundle signal paths into single routes, and I’d already been thinking that would look cleaner, so I took the chance to optimize it that way.

![SignalOpt-RV32I50F.5SPH.R1](/diagrams/design_archive/RV32I50F.5SP/RV32I50F.5SPH.R1.drawio.png)

After that, I continued studying the one-cycle latency in Data Memory. 
During last night’s meeting after the evening session, we floated the idea of making the read enable signal posedge-based and I tried it—merciless syntax error…  
Right now, at the rising edge of the clock (when it goes to 1), read enable is seen as 0, and by design it only becomes 1 after passing through multiple conditionals, so it looks like we can’t start a read immediately.  

Is there no way around this? 
If the issue is that timing is missed because we only key off the clock’s edge, I wondered if we could write the Data Memory read behavior as “posedge clk or clk,” letting it also act while clk is high, so the read would still happen.   
But that would violate synchronous design principles and would likely cause all kinds of unforeseen problems, so I scrapped it.  

I reviewed training materials from IDEC, and their Data Memory code looked quite different from what we’re using now. 
I’ve asked ChoiCube84 to do additional research on this; if their code improves our issue under the same testbench conditions, we’ll revise the Data Memory structure starting from 37F. 
If the same one-cycle slip still appears, we’ll stick with the current Data Memory design. 
After RV32I50F is implemented and verified, we plan to make a new repo for the 64-bit expansion, and from RV64I onward we’ll also use the FPGA’s DDR3 SDRAM, so we can overhaul the Data Memory structure then.

-----

While implementing the 47F architecture, ChoiCube84 raised an issue about the implementation of fence.i.   
In 50F, fence.i is handled in the Exception Detector and Trap Controller, but in 47F there’s no module or signal to assert rst to the Instruction Cache. 
Originally 47F supported 47 instructions, and compared to 43F the additions were FENCE, FENCE.tso, PAUSE, and FENCE.i.  

However, to implement fence.i now, we’d need to add signals to the Memory Controller and Control Unit. 
That would introduce a structure unique to 47F, harming interoperability with other architectures and making it non-reusable elsewhere.   
So we decided to move the Zifencei extension to 50F and **rename the 47F architecture to 46F.**

10+15+3+6+3+6+2+1 = 46  
47F Architecture supports Total 46 Instructions.  

Thus, the naming of 47F Architecture renamed to 46F Architecture.  
(Originally 47F Architecture includes fence.i instruction with Memory Controller.
However considering the module’s Interoperability, we decided to remove zifencei extension to 50F Architecture.)

![250316-RV32I50F.R3_temp(1)](/diagrams/design_archive/RV32I50F/RV32I50F.R3_temp(1).drawio.png)

-----

Running IDEC’s reference Data Memory code in our testbench, we found it operates correctly within a single cycle. 
We’ll now revise our existing Data Memory code with reference to that.

I’m organizing the instructions that are added or changed in RV64I.  

------

-Evening session-

Finished organizing the RV64I instructions.  
Under the current Write-Back cache policy, on FENCE we will commit pending writes to Data Memory. 
Since the cache knows when the flush has finished, Write Done was connected from the Data Cache, and since PC_Stall will likely still be useful in the pipeline, I left it in place. 
I haven’t yet verified behavior after modifying with the reference code.

Oh—it worked… the issue was Verilog’s “=”… What a relief. It wasn’t that I was missing something bigger; it was a mistake from not being fluent enough with Verilog.  
With this, the read_done signal goes away. 

And if PC_Stall goes into the PCC, then Write Done is no longer needed by the PCC, but it remained in the diagram—so I removed it. 

I also removed read enable; honestly that seems to be the key. Now I need to revise each final diagram version to reflect these changes.

That’s it for today. I’m taking a 1-night, 2-day pass starting tomorrow, so I’ll need to zip up and upload the entire development environment.

## Architecture and Roadmap Revision

### [2025.03.18.]
A proposal from ChoiCube84 regarding the cache architecture and the FENCE instructions.  

> Allowing FENCE to trigger cache Write-Back does not have strong justification.   
There’s no real reason to do it, and it also runs counter to the intent in a multi-hart context.

On reflection, in a single-hart system there’s no need to flush all write-backs, so I accepted the suggestion.  
Rather than expanding from the 43F architecture to the 46F architecture (supporting FENCE, FENCE.TSO, and PAUSE), we will expand from the 43F architecture to the 44F architecture, excluding the FENCE family and adding support only for the Zifencei instruction.  

To that end, we will add an Instruction Cache, and since the Data Cache has already been designed and implementation has begun, the cache architecture will be present starting with RV32I44F.  

Zifencei is required for the G extension and/or for bringing up the Linux kernel.

I studied the A extension and the CMO.

### [2025.03.19.]

[2025.03.19.]
I planned the roadmap and architecture, and revised and detailed the plan.

The revised roadmap is as follows.

#### [basic_rv32s]

- RV32I37F : 	Base Architecture that supports 37 Instructions.  
Which is an amount that excluded EBREAK, ECALL, FENCE, FENCE.TSO, PAUSE instructions.
   - Partial RV32I (RV32I except FENCE, FENCE.TSO, PAUSE, ECALL, EBREAK)
- RV32I43F
   - P.RV32I + Zicsr

- RV32I44F_C
   - P.RV32I + Zicsr + Zifencei
   - \+ Cache Structure (Instruction Cache, Data Cache)

- RV32I47F : 	Supports EBREAK, ECALL, mret from RV32I & Privileged Architecture.  
Final version of basic_rv32s repository
   - P.RV32I + Zicsr + Zifencei + ECALL + EBREAK + mret
   - \+ Debug Interface, Debugger

#### [RV64s]

- RV64I59F : RV64I Extension
   - 47F + RV64I

- RV64I59F_5SP
   - 59F + 5-Stage Pipeline

- RV64IM72F : M extension supported. Maybe Grapchics Interface from this architecture.
   - 59F5SP + RV64M

#### [Final]
- RV32IMA104_CMO_RVWMO : A extension supported.
   - Full RV64I + RV64M + RV64A + Zicsr + Zifencei + mret + CMO + RVWMO

▶ Fully supports RV32I. Including FENCE, FENCE.TSO, PAUSE after all.  
▶ Complies RVWMO memory consistancy model.  
▶ Dual-Core (multi-hart) processing system.  
▶ Improved Cache structure  
├ Two separate L1 Cache 	; Instruction Cache, Data Cache respectively.  
├ One integrated L2 Cache 	; Integrated Cache that contains Instructions and Datas.  
└ One shared L3 Cache		; A Cache that shared by each core(hart).  

L1$, L2$ for each core respectively, L3$ is shared cache that all the core can access.  
▶ Supports DDR3 SDRAM integrated on FPGA board.

### [2025.03.20.]

Now that pipeline register placement is done, the next tasks are:   
- Design the Hazard Unit and plan countermeasures for control, data, and structural hazards 
- Revise all rv32s final schematics to reflect recent architectural changes.

It turned out our “single-cycle within one cycle” memory read worked because it was implemented as asynchronous read. 
Looking into it, most introductory single-cycle CPU examples use data memory with asynchronous read and synchronous write. 
So we decided to keep memory asynchronous until we move to the 5-stage pipeline, and I revised the 37F and 43F architecture diagrams accordingly.  

Since RV32I50F now excludes the FENCE family, it effectively becomes RV32I47F; however, the old diagram names were too similar.   

I archived **RV32I50F as of the 19th(250319) and will call the new one RV32I47NF**. Likewise, the former RV32I47F—also without the FENCE family—becomes RV32I44F. There’s no naming conflict there, so we’ll keep RV32I44F.  

Action items:  
- Archive RV32I47F at R9 and revise it as RV32I44F.
- Archive RV32I50F and revise it as RV32I47NF.

That’s all for today. I’ll use tomorrow’s personal time to push progress.

On hardware: per the professor’s recommendation, I purchased a Nexys Video FPGA board. All that’s left is acquiring the local workstation.

Revisions completed up through 43F.

![RV32I37F.R4](/diagrams/design_archive/RV32I37F/RV32I37F.R4.drawio.png)
![RV32I43F.R3](/diagrams/design_archive/RV32I43F/RV32I43F.R3.drawio.png)

### [2025.03.21.]

Come to think of it, at the 250316 meeting we decided to implement Zifencei when the Trap Controller lands, **so this isn’t 44F—it's a 43F-based architecture with caches. Final name: RV32I43FC (C for Cached).**

![RV32I43FC](/diagrams/design_archive/RV32I43FC/RV32I43FC.drawio.png)

With 37F, 43F, and 43FC set, it’s time to revise the 47F architecture (formerly 50F).

While porting 47F and adapting the old Memory Controller to the current scheme, a thought came up. 
The Data Cache’s DC_Write (i.e., write-enable) comes from the Memory Controller. 
That means the MemC must understand the instruction and assert that action. 
It feels right that the MemC receive instruction context; if the CU did this instead, the MemC would be reduced to a path-selector that only flips MUXes on STAA misses to route memory-return data—basically just a datapath selector.

> ChoiCube:   
“So rather than CU driving Data Cache directly, route it through the Memory Controller first?”

This isn’t a trivial wiring tweak; it needs rationale. 
We’ll eventually use the DDR3 SDRAM on the FPGA. Practically, “CPU-controlled memory” (per core) will be L1/L2; shared L3$ and RAM shouldn’t be driven directly by each core’s CU. A Memory Controller should sit in the middle to manage L3$ and RAM.

I should survey modern CPU practice. 
As far as I recall, CPUs do have on-die memory controllers.
In AMD’s modular-die (MCM/chiplet) Zen, the controller is on a separate die; in Intel’s monolithic designs it still exists, just not as a separate die.

[https://en.wikichip.org/wiki/File:zen_block_diagram.svg](https://en.wikichip.org/wiki/File:zen_block_diagram.svg)

Zen’s block diagram shows cache-related datapaths that are worth referencing.  
Also: I need to submit the Defense Startup Competition application today.

Dinner first. (17:52)

I analyzed cache hierarchy, its controller, and the DRAM controller referencing Ryzen Zen. For rv32s we’ll implement memory as on-SoC for now, and bring up FPGA after pipelining, so we’ll integrate it at the core level. Learned the “uncore” concept.  
(Not sure if async-read/sync-write RAM infers cleanly on the FPGA—but I’d like rv32s validated on FPGA too.)

-----

After optimizing cache structure with ChoiCube, we ended up removing the Memory Controller.  
The MUX that selects fetched instructions/data per SAA on hit/miss now keys off cache status lines directly (DC_Status, IC_Status). 
Since writes to Memory only happen on write-back, CU’s MemRead/MemWrite both go to the Cache. Data Memory’s write-enable is driven by NOT(DC_Status). 
Early on I assumed we “must” have a Memory Controller, influenced by modern systems, so I kept one in the early cache sketches. 
As we’ve learned, at our current stage we don’t need it.  

When L3$ or DDR3 SDRAM enters the picture—shared across cores—we’ll introduce a Memory Controller to handle coherence policy. 
Following Zen, I’ll design an uncore top that bundles display/GUI, DDR interface, USB, etc.
Cache structure is finalized; time to implement. Targets: RV32I43F_C.R1 and RV32I47NF.

![RV32I43FC_temp](/diagrams/design_archive/RV32I43FC/RV32I43FC_temp.drawio.png)

## RV64I59F Development (50F + RV64I)

### [2025.03.22.]

With the finalized cache structure and the revised roadmap, I completed RV32I43FC.R1 and RV32I47NF, the finished architectures for the rv32s project. 
I finished them at 14:58 and 15:50, respectively.   

![RV32I43FC.R1](/diagrams/design_archive/RV32I43FC/RV32I43FC.R1.drawio.png)
![RV32I47NF](/diagrams/design_archive/RV32I47NF/RV32I47NF.drawio.png)

I also wrapped up small signal-placement optimizations. 
Now I need to draft the initial design for RV64I59, which will kick off the RV64I expansion in the next repository, tentatively named rv64s. 
I don’t think rv32s will need many more changes, but probably not none—although it feels like we’ve brought out everything, the implementation phase has always brought more revisions and learning than expected, so from here it’s really ChoiCube84’s part.  

I organized the filesystem well in mybox, and I need to update the main GitHub repository (basic_rv32s) to match it. I’ll do that after dinner.  

Only in RV64I59F, which starts the RV64 expansion, will I explicitly annotate bit widths at each signal’s input. Actually, to compare against RV32, it would be good to annotate them in RV32I47NF as well.  

![RV64I59F](/diagrams/design_archive/ima_make_rv64/RV64I59F/RV64I59F.drawio.png)

### [2025.03.23.]

Sunday duty day. I opened an operating systems book and studied up to Chapter 2. I covered the OS development process and the basic hardware theories that underpin it. I’ve learned much of this while developing the CPU to this point, but I felt we’ve been building in a way that aligns well with modern computer architecture. And based on that experience, I’m understanding the book much faster.

I studied the basics—types of operating systems and their underlying ideas and solutions: 
time-sharing OS, multiple processes, and so on. 
I finished updating and printing the RV64 version of the RV32I CheatSheet. 

An officer kindly offered to check if we can export such files—very grateful. 
Re-checking against the manual as I read, I saw that most operations don’t produce 64-bit results outright; the word itself is 32 bits, and it’s expanded to 64 bits to fit the data format.   
We could add this expansion logic to the ALU, but there seem to be two ways to implement it:   
(1) add an ALUop that includes the bit expansion in the operation (in which case both the ALUcontroller and ALU need changes), or   
(2) create a 64-bit extender that separately takes opcode and funct3/funct7 and handles the operation as appropriate.

### [2025.03.24.]

Around 23:49, ChoiCube84 reported that Data Cache verification was complete.   
Starting tomorrow, I should be able to run my own verification.   
I’ll also bundle the RV64I work-in-progress into a zip on mybox and upload it to goormIDE.   
Filesystem housekeeping—done for today.

### [2025.03.25.]

I studied operating systems and found a pretty solid paper: “BRISC-V: An Open-Source Architecture Design Space Exploration Toolbox.”   
It covers single-cycle, 5–7 stage pipelines, cache hierarchies, multicore scaling, and more—basically a platform-level hardware stack.   
A lot of it aligns with our roadmap, so it looks like a valuable reference. I should dig into it.

And… five months until discharge, plus two months for the paper and personal statement—so three months left to finish that entire roadmap? I’m honestly very unsure.   
I asked GPT o1 what caliber the BRISC-V work is; it sounds like a lab project or PhD-level effort—i.e., not something you wrap in a few semesters.   
Maybe getting this far is already something. 
Even if the architecture was quick to sketch, a huge amount of credit goes to ChoiCube84 for making it real.   

Given we’ve only had ~3 hours a day, the outcome is still respectable.   
Can this contribute to academia? What do I want the paper to show? Why am I doing this?  
Because I want into KAIST via the special admissions track; because building CPUs was always the dream; because I want to found something like AMD or Intel.   
I’m scared, it’s a lot, and I worry—but there’s nothing else I want to do.   
So I’ll keep going.  

### [2025.03.26.]
I visited the site linked in the BRISC-V paper and looked around the platform. There’s quite a bit of code I could use as a reference.

### [2025.03.27.]
Today I unexpectedly met up with the deployed ChoiCube84 during an off-site medical visit and we had a brief meeting.  
- Data Cache masking issue.   
In a cold-start state, we issue a store to memory, it gets written into the cache. When flushing that value, if we don’t apply masking, the cache’s initial value can leak through.  
e.g.) Cache: 0000_0000, Mem: DEAD_BEEF. Cache: AAAA_0000, Mem: DEAD_BEEF -> Cache: 1242_AABE, Mem: AAAA_0000 (Expected AAAA_BEEF)  

Huh, but in that case couldn’t we just standardize the initial values of memory and cache to 0? Do we really need a masking signal on cache flush?  
Is there any case where we invalidate a line on the Data Cache side…? It would be nice if there were…  

For the RV64 implementation, we decided to implement it by modding the ALU, ALUController, and Instruction Decoder.  

Other changes: in the data area and Register File, the data width must be XLEN (64-bit).  
In the instruction area, even with RV64, instruction data width remains 32-bit, so no change there.  
However, because the addressable range in the instruction area expands to 64-bit, the width stays the same but the depth increases.  

Changes to the Instruction Decoder are as follows.  
- Shift instructions with a “W” suffix operate on words, i.e., 32-bit units (even in RV64, each instruction is 32 bits long, so a word is 32 bits).  
- Un-suffixed instructions like SLL and SRA that existed in RV32I operate over XLEN, i.e., 64 bits in RV64, so shamt (shift amount) expands to 6 bits.  
But “W”-suffixed instructions, which still operate on 32 bits as in RV32I, must be limited to a 5-bit rs2.

Since these are newly added in RV64I, one could mistake them as 64-bit operations (I did), but we need the legacy 32-bit operations, so those are marked W, and the rest become XLEN-based as part of the 64-bit expansion.  

- The changes when moving to RV64 are as follows.

   - [R-Type]  
      - SLL, SRL, SRA: shift up to 64 bits.   
   The rs2 field increases to 6 bits, and funct7 shrinks to 6 bits   
   (so “funct7” no longer really lives up to its name).

   - [I-Type]  
      - SLLI, SRLI, SRAI: shift up to 64 bits.   
   Treat imm[25:20] as shamt and imm[31:26] as a 6-bit funct7.
      - LW: Load-word.   
      Since the data width is now 64 bits, we load 32 bits and sign-extend the upper 32 bits.

- New instructions.
   - [R-Type]
      - ADDW, SUBW, SLLW, SRLW, SRAW: 32-bit operations (add, subtract, shifts).  
      Each computes on 32 bits, then sign-extends the upper 32 bits on writeback.

   - [I-Type]  
      - ADDIW, SLLIW, SRLIW, SRAIW: 32-bit immediate operations (add, shifts).  
      ADDIW likewise computes on 32 bits then sign-extends on writeback.   
      Shifts behave as described above.

      - LWU, LD: load instructions.
      - LWU — Load Word Unsigned.   
      Zero-extend the upper 32 bits when loading a 32-bit value.
      - LD — Load Doubleword. Load a 64-bit value.

That’s it.

Summarizing the hardware changes:

1. Instruction Cache/Memory (instruction area) address width becomes 64-bit.

2. Instruction Decoder:   
expand rs2 to 6 bits; when it’s a “W” instruction, slice the appropriate bit fields accordingly.

3. imm_gen:   
64-bit sign-extension (and zero-extension where appropriate, e.g., U-Type).

4. Register File:   
register data width and RD1/RD2 output widths become 64-bit.

5. CSR File:   
CSR_RD is 64-bit. Other CSR registers follow their spec—some 32-bit, some 64-bit.   
(Architecturally, the datapath is 64-bit; output 32-bit values with zero-extension.)

6. ALU Controller:   
add ALUop codes for W-instructions (RV64-only) that compute on 32 bits then extend to 64 bits.

7. ALU:   
add operations/handling for W-instruction ALUop codes.

8. Data Cache/Memory (data area) address and data widths become 64-bit.

And one question that came up while sketching the cache structure:  
When memory ultimately moves to external DRAM, instructions and data reside in a unified memory. 
How do we distinguish what should go into the Instruction Cache vs. the Data Cache?  

The answer: while memory itself holds both code and data, the OS uses page tables to assign attributes to each page—executable vs. data-only.   
The MMU consults these attributes; instruction fetches pull from executable pages into the I-cache, while data accesses go through the D-cache.  

Concretely, the OS configures page table entries (PTEs) with execute permissions and read/write rights—e.g., the NX (No-eXecute) bit.   
Software can thus designate certain regions (like the .text section) as executable and others as data.

Even in “unified memory,” the CPU internally routes instruction fetches and data accesses separately to I-cache and D-cache, based on the pipeline access type and MMU page attributes (e.g., executability).  

“Memory Protection and Page Attributes”  
“NX bit and executable memory”  
“Unified memory with separate instruction and data cache”  
“MMU and cache management”  
“Cache partitioning based on executable attribute”  

The outline of RV64I59F feels sufficiently fleshed out.   
From here, to implement the 5-stage pipeline, I’ll adapt the existing RV32I50F-based 5SP draft to the RV32I47NF baseline (the RV64I59F module designs are the same) and design the Hazard Unit.  
I’ve got duty tomorrow; I’ll continue studying OS then.  

I’m re-placing the pipeline registers for RV64I59F. 
I was going to reuse RV32I50F_5SPH.R1 as is, but the placement didn’t line up well, so I used it as an opportunity to re-review existing signals.  

I found one mistake: Trap_Controller takes CSR_RD as an input—does that really belong in the Instruction Decode stage? I need to think about it.  
That’s it for today.

![RV32I43F.R3v2](/diagrams/core_architectures/RV32I43F.R3v2/RV32I43F.R3v2.drawio.png)
![RV64I59F.R1](/diagrams/design_archive/ima_make_rv64/RV64I59F/RV64I59F.R1.drawio.png)
![250327-RV64I59F_5SP_temp](/diagrams/design_archive/ima_make_rv64/RV64I59F_5SP/RV64I59F_5SP_temp250327.drawio.png)

### [2025.03.31.]

I finished writing the HCWcloud documentation and returned to CPU development. I’ve nearly completed the pipeline placement for RV64I59F. I’ll probably finish placing all pipeline registers tomorrow morning and spend the remaining time sketching the Hazard Unit.

![250331-RV64I59F_5SP_temp](/diagrams/design_archive/ima_make_rv64/RV64I59F_5SP/RV64I59F_5SP_temp250331.drawio.png)

### [2025.04.01.]
11:59 I finished placing all pipeline registers and also optimized the signals.  

![RV64I59F_5SP](/diagrams/design_archive/ima_make_rv64/RV64I59F_5SP/[250401]RV64I59F_5SP.drawio.png)

Now I need to place the hazard unit… time to start the research.  
Let me finish organizing what I started on 2025.03.14 about pipelining.  

Based on computer architecture (Computer Organization and Design, David A. Patterson, 2015)
Definition of a hazard: a situation where the next instruction cannot execute in the next clock cycle. There are three types:  

1. **Structural hazard**  
   – Means the hardware cannot support the combination of instructions that want to execute in the same clock cycle.  
   → This might correspond to the case where synchronous memory cannot return data in a single cycle.

2. **Data hazard**  
   – Occurs when a pipeline must be stalled because one stage must wait for another stage to finish.  
   – In CPU pipelines, this happens when an instruction in the pipeline depends on an earlier instruction still in the pipeline.

Types: RAW (Read After Write), WAR (Write After Read), WAW (Write After Write)

Solution 1: forwarding/bypassing  
Add hardware so you can obtain values earlier from internal resources than you normally could.

Solution 2: CCC; Change Clock Cycle   
Split the clock so writes happen in the first half and reads happen in the second half.

3. **Control hazard**  
   – Occurs when other instructions need to make a decision based on the result of an instruction that is still executing (branch instructions).

Solution 1: delay

Solution 2: branch prediction  
Simple: assume branches are always not taken; only stall when a branch actually occurs.
Advanced: predict taken in some cases and not taken in others (dynamic hardware predictor).
Keep a history of whether each branch was taken, and use recent history to predict the future. When a misprediction occurs, squash the instructions after the mispredicted branch and restart the pipeline from the correct target.

Solution 3: delayed decision (software); delayed branch  
Always execute the next sequential instruction; the actual branch occurs one cycle later, after that instruction has entered the pipeline.

Since structural hazards classify hardware-insufficient cases, I’ll set them aside; what we must handle are data hazards and control hazards.

To handle pipeline hazards in hardware, we need two kinds of logic:

1. detection logic to determine whether a hazard has occurred
2. handling logic to resolve the hazard once detected

Designing hazard detection logic:

First, data hazards.  
Because of dependencies among instructions, we may need to pause the current instruction until the previous one finishes.  
So we need to know the dependencies among in-flight instructions in the pipeline.  
Since the processor works around registers, we check whether the destination register of a prior instruction matches the source register(s) referenced by the current instruction.  
Compare instruction A’s rd (register destination) against instruction B’s rs1 and rs2 (register sources).  

Exclude x0 since it is always zero and never changes, so no forwarding is needed for x0.
We only know rd/rs1/rs2 after decode, so the earliest place to judge this is probably at ID/EX.

- ALU data sources are srcA and srcB.
   - srcA can be RD1, PC, rs1  
   - srcB can be RD2, imm, imm(shamt), csrRD

Register values are used as resources; due to the pipeline, a register’s value may be changed by a prior instruction, so we may need to wait.  
To minimize the waiting, we use forwarding: deliver the result of instruction 1 forward to instruction 2’s ALU inputs before it is written back to the register file.  
This requires an extra MUX to choose between the normal ALUsrc path and the forwarded data. The forwarded data can be one of the five writeback sources: D_RD, ALUresult, CSR_RD, imm (LUI), PC+4.  
So forwarding must select, according to the instruction, one of these potential writeback sources and deliver it to the right ALU source.  

I split this into two modules: a hazard detection unit and a forwarding unit.  
The hazard detection unit stores rs1.A, rs2.A, rd.A from the instruction in Decode and compares them with the next instruction’s rs1.B, rs2.B, rd.B.  
If rd.A matches either rs1.B or rs2.B, it flags a data hazard to the forwarding unit via a hazardop signal.  

The forwarding unit, seeing hazardop, selects the prior instruction A’s to-be-written result (the value that will eventually go to the register file) and forwards it to one of the EX-stage ALU sources for instruction B, according to B’s type.  

- Signals needed by the forwarding unit:  

   - EX/MEM.imm (LUI)
   - EX/MEM.ALUresult
   - EX/MEM.CSR_RD
   - MEM.D_RD
   - EX.PC+4

Plus an instruction identification signal. For now, I set it up this way.  
The forward unit needs an instruction identifier; but we don’t need to identify every instruction—only those whose result writes to the register as one of D_RD, ALUresult, CSR_RD, imm (LUI), or PC+4.  

I’ll identify via opcode. Even if I made a separate signal, pipelining would force me to decide when and where that signal is generated anyway.  
Added signals to the forwarding unit:  

- EX/MEM.opcode  
  When a hazard is detected in ID and the hazardous instruction reaches EX, the instruction in MEM (right ahead) must be identified so we know what result will be written to rd.   
  Hence I take opcode from EX/MEM.

With this, the forwarding implementation is “done” for now… 19:49. I’ll rest a bit and then study control hazards.

![RV64I59F_5SP_Forwarding](/diagrams/design_archive/ima_make_rv64/RV64I59F_5SP/[250401]RV64I59F_5SPH_FW.drawio.png)

—Evening study—  
Now, control hazards.

Control hazards arise from branch handling.

Researching this, there are many branch predictor types, and there are associated security risks…  
Those are more relevant to OoOE designs; for now I’ll focus on the branch prediction itself.

First, summary from the book.  
Branch prediction ⊂ speculation

1. **Static branch prediction** (predict fall-through sequential execution)  
   Assume the branch is not taken and keep executing sequentially.  
   If the branch is actually taken, flush the fetched/decoded instructions and continue execution at the branch target.  
   Similarly for the opposite assumption.  

   Implementation:  
   When a misprediction is discovered, once the branch reaches MEM stage, zero the control signals for all earlier-stage instructions so they are annulled.

2. Earlier branch resolution  
   If we can decide taken/not-taken earlier than MEM, we can reduce the misprediction penalty.  

   Implementation:  
   In my RV32I37F-based design, branch decisions are computed in ALU (EX). In the pipelined RV64I59F_5SP, that effectively resolves in MEM (after EX/MEM). 
   If I add a dedicated branch-evaluation unit and move it earlier—say into ID—that would require further research.

3. **Dynamic branch prediction**  
   Predict during execution.  
   3.1. Look up whether the branch was taken the last time it executed at this address.
   If so, fetch from the target this time too.  

   Implementation:  
   3.1.1. One-bit predictor  
   Use a branch prediction buffer (branch history table), a small memory indexed by low bits of the branch PC, storing a bit indicating whether it was recently taken.

   3.1.2. Two-bit predictor  
   Implemented as a small special buffer accessed in IF by instruction address.  
   If predicted taken, fetch from the target as soon as the PC is known (if early resolution is implemented, possibly as early as ID).  
   If predicted not taken, fetch sequentially; on misprediction, update the two-bit state (needs two consecutive misses to flip direction).  

   3.1.3. Branch Target Buffer (BTB)  
   Cache the branch target PC (and/or target instruction) with tags; use it like a cache.

   3.1.4. Correlating predictor  
   Use both local behavior of the branch and global behavior of recent branches to improve accuracy using the same number of bits.

### [2025.04.03.]

![RV64I59F_5SP_BP-temp](/diagrams/design_archive/ima_make_rv64/RV64I59F_5SP/[250403]RV64I59F_5SPH_FW_BP_temp.drawio.png)

### [2025.04.04.]

![250404-RV64I59F_5SP_BP-temp](/diagrams/design_archive/ima_make_rv64/RV64I59F_5SP/[250404]RV64I59F_5SPH_FW_BP_temp.drawio.png)

> ChoiCube84’s cache-implementation question

[Starting state]  
Cache: AAAA_AAAA (tag: 00000)  

Memory:  
00000_00000: AAAA_AAAA  
00001_00000: 0000_0000  

**SW, address 00001_00000, write data = DEAD_BEEF**

[After SW]  
Cache: DEAD_BEEF (tag: 00001) (dirty)

Memory:  
00000_00000: AAAA_AAAA  
00001_00000: 0000_0000  

**SH, address 00000_00000, write data = CAFE_CAFE, write mask = 0011**

[After SH]  
*Flush*  
Cache: DEAD_BEEF (clean) (tag: 00001)  

Memory:  
00000_00000: AAAA_AAAA  
00001_00000: DEAD_BEEF

— input, Addr: 00000_00000, Data: CAFE_CAFE, Mask: 0011  

! Tag differs; assuming all blocks are full.  
The cache must fetch the new tag’s data.  

Cache: AAAA_AAAA (clean) (tag: 00000)  

Memory:  
00000_00000: AAAA_AAAA  
00001_00000: DEAD_BEEF 

------

[Write]  
Cache: AAAA_CAFE (dirty) (tag: 00000)

Memory:   
00000_00000: AAAA_AAAA   
00001_00000: DEAD_BEEF

In other words, a Memory → Cache synchronization is needed.  
When the cache set is full and you need to replace a line, you must bring in the existing data from memory.  
In the worst case, to model **flush → read → write** with an FSM, you’d need to encode these phases into the **valid** bit (or an equivalent status).  

**My answer:** Would that situation even arise?   
In modern CPU designs, a cache line isn’t 1:1 with memory words like ours—it’s typically 64 bytes per line.   
We’re currently not using the **offset**; if we use it, we can both preserve a set-associative design and resolve this problem.  

### [2025.04.05.]

*Duty shift. A reminder of what I did.  
Since I was on duty, I’m writing this on 2025.04.06.*  

First off… cache issues resolved.

I read everything on caches in “Computer Organization and Design.”  
Based on that, I’m going to simplify and solve the cache design by defining a clear specification from scratch.  

The cache structure we’re building now is the Instruction Cache and Data Cache that will eventually become L1$.  

-----

#### RV32I43FC-based cache specification  
Specification (L1$)  

- L1 Cache

   - 2-way set associative  
[Tag, Index, Offset]  
Tag: block search within a set  
Index: set selection among ways  
Offset: data selection within a block

   - 32 KiB each for Instruction & Data Cache (Harvard structure)  
   Total 64 KiB of L1$

   - 32-byte data per block (8 words per block; B = byte)  
   (Block = minimum transfer unit between memory hierarchy levels)

   - 512 sets, 1024 blocks.

   - 32 − 5 (offset, log2 32 = 5) = 27 bits “left” to split    
   log2 512 = 9 bits for Index    
   27 − 9 = 18 bits for Tag. 

   - 32-bit requested address:  
   Tag 18 bits  
   Index 9 bits  
   Offset 5 bits  
   Tag [31:14], Index [13:5], Offset [4:2]  

   - Cache block replacement: LRU (Least Recently Used)

-----

RV32I43FC-based memory hierarchy behavior  
[Write buffer, SAA (Simultaneous Address Access) adopted.]

1. Load  
   [Cache hit] (Dirty bit doesn’t matter here.)

(1) Return the data from the cache.

- [Cache miss]  
   - (1) Access memory.  
   - (2) Decide the block to replace in the indexed set (check dirty bit). 

- [if Clean]  
   - CLK 1  
   (1) With SAA, return memory data.  
   (2) Overwrite the cache line with the returned memory data.  
   (3) Set the cache line’s dirty bit.

- [if not SAA]
   - CLK 2  
   (4) Return the updated clean cache-line data at that address.  

—————
- [if Dirty]
   - CLK 1  
   (1) With SAA, return memory data.  
   (2) Save the cache’s dirty block (data + its address) into the write buffer.  
   (3) Clear the cache line’s dirty bit.

   - CLK 2  
   [After SAA, the requested address must keep being presented]  
   (Needed so we have the address for the memory block being fetched for step (3).)    
   - (3) Overwrite the now-clean cache line with the memory block.
   (4) Write the buffered address+data back to memory.

(If by any chance the write-buffered address equals the memory block being fetched: it can’t; if they were the same, it would have been a cache hit to begin with.)

- [if not SAA]
   - CLK 3  
   (5) Return the updated clean cache-line data at that address.

2. Store

- [Cache hit]
   - (1) Write the data into the cache (set dirty bit).

- [Cache miss]
   - (1) Access memory.
   - (2) Check dirty bit on the block to be replaced in this index.
.
- [if Clean]
   - CLK 1  
   (1) Overwrite with the memory-returned data.
   - CLK 2  
   (1) Perform the store into the refreshed cache line.  
   (2) Set the line’s dirty bit.  
—————
- [if Dirty]
   - CLK 1  
   (1) Save the dirty cache block (data + address) into the write buffer.

   - (if not SAA; CLK 2)  
   (2) Overwrite with memory-returned data; line becomes clean.  
(SAA hazard is conceivable: the address where memory data is written back equals the address of the dirty cache line. Since L1$ is fastest, timing might work out, but it’s a concern; if it actually occurs, we’ll revisit.)

   - CLK 2 (if not SAA; CLK 3)  
   (1) Perform the store into the refreshed clean cache line.    
   (2) Set the line’s dirty bit.    
   (3) From the write buffer, output the data+address to memory; update memory   (cache–memory synchronization).

### [2025.04.06.]

For a 32-bit ISA with a 2-way set-associative cache, we’ll benchmark and study AMD’s K6-III CPU as closely as possible.
Branch prediction will also be benchmarked on AMD-based systems.

By defining the cache structure this way, I’ve resolved the issues. As expected, you really do need to settle the specification first before diving into development…

Branch prediction research results are as follows.
(Gotta grab dinner. 2025.04.06. 17:43)

—— Evening self-study ——

I’ll start with an explanation of the branch predictor.
First, the branch predictor to be designed into this RV64I59F structure has the following specification.

[Dynamic branch prediction]
Tournament branch predictor.

Global branch correlation predictor
Local branch correlation predictor
Meta predictor

It consists of three 2-bit predictors.

On cold start, they’re all set to Weakly Not Taken (correlation predictors) / Weakly Local (meta predictor).

![250406-RV64I59F-5SPH_FW_BP-temp](/diagrams/design_archive/ima_make_rv64/RV64I59F_5SP/[250406r]RV64I59F_5SPH_FW_BP_temp.drawio.png)

Because Not Taken tends to be more common, and the Local predictor generally has higher correlation prediction performance.  
But due to time constraints, for the first completion of this project we will use a 2-bit BHT predictor.  

The rest will follow what’s in the book for now, but rather than the internal logic, we now have to consider signals for actual placement inside the CPU.  

To-do. Verify what signals are needed
We need to flush on mispredict—choose where this flush will be handled
Think about how to handle the writedone signal.  

If Jump calculation can be done in the Branch Predictor, i.e., in IF, the flush penalty would be reduced—decide how to do this. It feels like it’ll go away once we do OoOE anyway, but for now… we need speed, so we’ll keep the existing scheme: in EX, the Jump signal and ALUresult arrive, and PCC updates NextPC to that address.

That’s it for today. Let’s hurry and finish pipelining, then make the RV64IMA cheat sheet while studying each extension, and study dual-core structure, TLB, virtual memory, OS…

### [2025.04.07.]

Changed Hazard Detector to Hazard Unit and added a Flush signal, adding a flush signal to each pipeline register.  
For signals that need disambiguation by pipeline stage, I distinguished names like EX.D_RD to indicate which stage a signal is derived in.  

Also, in our Branch Predictor it seems better to use a BTB; if development time looks too delayed, we’ll just have the BP compute the target each time instead.

Let’s outline the Branch Predictor logic assuming the worst case.

Assume we are executing a conditional branch.

- [IF stage]  
   - The Branch Predictor receives the current PC and opcode.  
Using the opcode, it confirms it’s a branch instruction and stores the current branch-point PC.  

   - Prediction result is Taken.  
It sends the “taken” prediction to the PC Controller via B.EST.  
At the same time, it computes the branch target by adding the input IF.PC and IF.imm, and sends it to the PCC.  
And it stores that IF.PC.  

   - If a BTB is implemented, it stores the branch target as data with the PC as the tag, in a direct-mapped manner.  
Then it compares the input PC to the BTB and immediately sends the corresponding branch target to the PCC.

The PCC uses this to set the PC to the branch target and outputs it to PC as NextPC.

- [ID stage]  
Instruction decode stage

- [EX stage]  
   - The branch’s actual outcome is computed.  
   Result is Not Taken.  
   - EX.BTaken is input to the Branch Predictor.

   - Based on this, the BP detects a misprediction and sends BP_Miss to the Hazard Unit.
   - At the same time, it hands over the saved prior IF PC + 4 to the PCC.

Simultaneously, the Hazard Unit receives BP_Miss and sends Flush to each pipeline register to invalidate them.

---------- Opposite case ----------

   - Prediction result is Not Taken.
   - It sends the “not taken” prediction to the PC Controller via B.EST.
   - And it stores the IF.PC and IF.imm.
   - The PCC receives that signal and outputs current IF.PC + 4 as NextPC.

In this case, the BTB is not used.

- [ID stage]  
Instruction decode stage

- [EX stage]  
   - The branch’s actual outcome is computed.
   - Result is Taken.
   - EX.BTaken is input to the Branch Predictor.

   - Based on this, the BP detects a misprediction and sends BP_Miss to the Hazard Unit.
   - At the same time, it computes the target address from the previously stored IF PC and imm.
   - It delivers the computed branch target to the PCC.
   - The PCC outputs that B_Target input as NextPC.

This creates an issue.   
In the PCC, B_Target was selected as NextPC only when BTaken is true; in this case, even when Not Taken (i.e., BTaken is false), the PCC must be able to output B_Target as NextPC.  

Hmm… right, the original BTaken signal comes from the EX-stage Branch Logic, and the PCC’s BTaken input is now changed to B.EST, i.e., the predicted value, so it’s fine.  
We can make it 2 bits: 00 = no prediction, 01 = Not Taken, 10 = Taken.

If using a BTB, the BTB is updated.

Simultaneously, the Hazard Unit receives BP_Miss and sends Flush to each pipeline register to invalidate them.

And in this structure we can know in EX whether the branch prediction was right, but then we need space to hold the information of 2 + 1 in-flight instructions (since when reflecting the EX-stage branch result, we need that branch’s PC).  
We’d need to store imm values corresponding to PC for 3 instructions, and a register implementation would be good for that.  

No—since only on misprediction do we need to compute the next address of the mispredicted instruction, we can just pass PC and imm from the EX-stage pipeline register (where misprediction is known) to the Branch Predictor.  
That way we don’t need internal storage; we take the information only when needed, compute the address, and output B_Target.

Good—that completes the branch predictor design.  

Let’s summarize what signal interfaces are required, then I need to go eat.

- Branch Predictor (BP)  
   [Inputs]
   - CLK - clock
   - IF.opcode - to check whether it’s a conditional branch
   - IF.PC - to compute the next PC for Not Taken prediction and give it to the PCC  
   (also used to update the BTB)
   - IF.imm - to compute the branch target for Taken prediction and give it to the PCC
   - EX.PC - needed to compute the branch target or fall-through on misprediction
   - EX.imm - to compute the target on mispredicted conditional branch
   - EX.BTaken - to get feedback on whether the prediction matched reality

   [Outputs]
   - B.EST - to pass branch prediction info to the PCC
   - B_Target - to pass the predicted branch target or next PC computation result to the PCC
   - BP_Miss - on misprediction, to tell the Hazard Unit to flush pipeline registers

Likewise, since the PCC is indirectly affected,整理 the logic and signals there too.

- PC Controller (PCC)  
   [Inputs]
   - CLK - clock
   - Trapped - to select NextPC for exceptions or traps
   - PC_Stall - to stall other instructions until a memory access instruction finishes  
(It’ll be in MEM stage—if another instruction that doesn’t use MEM is running, can’t we just keep executing it?)
   - EX.Jump - identifies a jump whose target can be computed in EX, to select that target as NextPC
   - B.EST - branch prediction info from the Branch Predictor, to select B_Target as NextPC

   - B_Target - branch target or next PC computed by the Branch Predictor
   - IF.PC - current PC, to output PC+4 as NextPC
   - IF.T_Target - trap target address (trap is decided in Instruction Fetch)
   - EX.J_Target - jump target computed in EX

   [Output]
   - NextPC - next PC according to conditions

Change:   
Although BP_Miss could be handled in the Branch Predictor, the BP’s logic is fairly uniform in IF.  
We’ll have Branch Logic in EX compare directly with ALUzero and decide BP_Miss there.  
Branch Logic determines BTaken, passes it to the Branch Predictor, and at the same time receives EX.B.EST (the pipelined B.EST) from the Branch Predictor to compare with BTaken and judge misprediction.  
Then Branch Logic outputs BP_Miss to the Hazard Unit.

With that… the branch predictor design is finished. Implementation will come after ChoiCube84 finishes the current RV32I43FC cache implementation… I hope.  

*My head already hurts thinking about debugging. I want to document the Forward Unit at the same level of detail as this Branch Predictor, but ugh… I skipped a meal and we have afternoon assembly—do it afterward.*
*No—let’s accelerate design and fix it later if needed. This is still a pre-implementation draft, so let’s save time and move on.*

Back to cache issues.   
Strictly speaking, it resurfaced because of pipelining.  
In the single-cycle structure, Write Done went into the Control Unit; when CU recognized the end of a cache read/write, it updated PC to NextPC and continued.
But with an improved cache and higher complexity, on memory access we can have both cache→memory writes and memory→cache writes.  
Data needed to refresh the cache is inserted as memory returns it, and per the sequence above the cache is refreshed on the second clock.  

Therefore we must not change the instruction at that second step; we need a WriteDone signal from the Cache to recognize this (Cache Ready).  
Likewise, for memory updates (let’s call the dirty-bit clearing sequence “Cache Clean”), the data to be written to memory is handed from the write buffer, and
since handing from write buffer to memory happens on the second clock, we need another WriteDone (Memory Ready) to keep instructions from changing before then.

The problem is pipelining these signals…  
We only know whether to stall at MEM stage—how do we keep things from advancing until then…  

Do we need something extra in the pipeline registers?  
In any case, since the IF-stage PCC must know that the MEM stage needs delay to stop fetching the next instruction temporarily, in the single-cycle design the Control Unit received WriteDone and decided PC_Stall toward the PCC, but the pipelined Control Unit has timing uniformity in ID. 
Of course we could receive a MEM-stage signal and forward it to IF, but…  

Oh, right. Send Cache Ready and Memory Ready to the Control Unit, and have the CU always decide PC_Stall and send it to the PCC.  
The CU itself is combinational logic and not restricted to a specific pipeline stage, so this seems correct without forcing timing uniformity.  
The PCC’s purpose should remain “selection” of the PC address under conditions. So instead of having the PCC monitor all Write Done signals, let the Control Unit handle that role and just accept a simple PC_Stall.

Pipeline registers keep their values unless updated, so that’s fine.

We should at least “briefly” touch unconditional branches too.  
For a Jump, to compute the target we must reach EX stage.  
At that time we send Jump and J_Target to the PCC, and we must simultaneously flush the pre-EX IF and ID stage contents (their pipeline registers).  
(In OoOE you could keep executing to the end and cache out-of-order results… that’s for later.)  

Flushing should be done by the Hazard Unit; just forward the Jump signal, pipelined up to EX, to the Hazard Unit.

Done… At 14:51 I completed the RV64I59F_5SPH_FW_BP architecture.  
We’ll surely hit many issues in real implementation and debugging and have to revise, but for now this is the best result.
I’ll summarize the Forward Unit logic, then skip further pipeline work and look at the next steps.

![RV64I59F_5SPH_FW_BP](/diagrams/design_archive/ima_make_rv64/RV64I59F_5SP/[250407b]RV64I59F_5SPH_FW_BP.drawio.png)

Based on what I wrote on April 1, here’s the final version.

Data hazards—cases where the current instruction must pause until the previous one finishes due to dependencies.  
Then we need to know inter-instruction dependencies in the pipeline.  
Since a processor fundamentally operates on registers, we check whether the register destination address from a prior instruction that will be updated is referenced by the current instruction.  
Compare instruction A’s rd (register destination) with instruction B’s rs1 and rs2 (register sources).  
Note that x0 is a constant zero; no forwarding needed in that case.  
You only know rd/rs1/rs2 after instruction fetch when decoding, so at least by ID we can know this.

The ALU uses srcA and srcB for computation, with

srcA: RD1, PC, rs1  
srcB: RD2, imm, imm(shamt), csrRD  

Seven total possible inputs for operations.  
Register data may change due to a prior instruction, so we sometimes must wait.

To minimize the waiting, we use forwarding.  
Before instruction 1’s result is written back to the register file, we forward that value to instruction 2’s ALU src as appropriate.  
Thus the ALU can use the forwarded data in computation.  
We add a MUX that selects between the ALUsrc MUX output and the forwarded data.
Forwarded data sources correspond to the five register writeback sources: D_RD, ALUresult, CSR_RD, imm(LUI), PC+4.  

So forwarding selects the appropriate source according to the instruction type that will write the register.  
The forwarding unit learns a data hazard occurred via hazardop.  
Based on that, it forwards the result of the leading instruction A (the data that will ultimately be written to the register file—this will be in EX or MEM) to an appropriate EX-stage ALUsrc for instruction B.

I split it into two modules: a hazard detection unit and a forwarding unit.  
The hazard detection unit stores rs1.A, rs2.A, rd.A from the Instruction Decode stage, and compares them to rs1.B, rs2.B, rd.B of the following instruction.  
If rd.A matches either rs1.B or rs2.B, it flags a data hazard and signals hazardop to the forwarding unit.  

Signals needed by the forwarding unit are as follows.

[Inputs]  
- MEM.imm (LUI) - one of the already-executing sources that will be written back
- MEM.ALUresult - one of the already-executing sources that will be written back

On April 1 I wrote EX, but thinking it through:   
the leading instruction (A) moves to MEM while the trailing (B) is in EX and needs the data;  
what A computed in EX ends up in the MEM pipeline register, so categorizing it as MEM is correct.  
Also, I prefer sourcing from the pipeline register that will definitely output on the next clock edge, rather than directly from a module, so I corrected it to MEM.

- MEM.CSR_RD - one of the already-executing writeback sources
- MEM.D_RD -    one of the already-executing writeback sources
- MEM.PC+4 -    one of the already-executing writeback sources (EX.PC+4)

We’ll confirm during debugging, but the premise here is forwarding from the leading instruction (A) in MEM to the trailing instruction (B) in EX;  
strictly speaking, that suggests PC+4 should also be produced in MEM, same as the ALUresult comment below.
So I changed it to MEM.PC+4.

- MEM.opcode - to identify what instruction A in MEM is, and select the correct forwarded data source

[Outputs]
- aluFW.srcA - data output of the selected forwarded source; goes to aluFW_MUX.A
- aluFW.srcB - data output of the selected forwarded source; goes to aluFW_MUX.B

- aluFW.A - select control for aluFW_MUX.A.   
When Hazardop indicates forwarding is needed, based on MEM.opcode, if the kind of data corresponds to ALUsrcA, feed the forwarded data to aluFW.A  
(RD1, PC, rs1)
- aluFW.B - select control for aluFW_MUX.B.   
When Hazardop indicates forwarding is needed, based on MEM.opcode, if the kind of data corresponds to ALUsrcB, feed the forwarded data to aluFW.B  
(RD2, imm, imm(shamt), CSR_RD)

Now, concretizing the Hazard Unit.  
[Inputs]
- BP_Miss - on branch prediction miss, receive from EX.Branch Logic and decide to flush
- EX.JMP  - receive EX-stage Jump and decide to flush
- ID.rs1  - record trailing instruction (B)’s rs1 from ID
- ID.rs2  - record trailing instruction (B)’s rs2 from ID
- ID.rd   - record leading instruction (A)’s rd from ID

[Outputs]
- IF/ID.flush   - flush (invalidate/clear/reset) IF/ID pipeline register
- ID/EX.flush   - flush ID/EX pipeline register
- EX/MEM.flush  - flush EX/MEM pipeline register
- MEM/WB.flush  - flush MEM/WB pipeline register
- Hazardop      - compare recorded rd of A with rs1/rs2 of B.  
If rd.A equals rs1.B or rs2.B, regard it as a dependency and assert Hazardop to the Forward Unit.

Great. That completes the basic design and logic of the pipeline structure.

Next up: understanding M and A extensions, dual-core scaling, checking the requirements to bring up an OS, GUI and I/O implementation.

That’s it for now. During evening study I need to set priorities among the upcoming extensions and refit the project plan accordingly.

Let’s push harder. (20:40)

— Evening study —

We now have a draft up to 64-bit 5-stage pipelining. Let’s review the roadmap.

RV32I (basic_rv32s)  
RV32I37F, 43F, 43FC, 47NF (basic RV32I instruction support, cache support, debugger environment instruction support, CSR support)

RV64I  
RV64I59F, RV64I59F_5SPH (64-bit extension based on RV32I, 5-stage pipeline, branch predictor support, forwarding support)

— up to here —  
Now the remaining extensions.  
(a) “M” extension  
(b) “A” extension  
(c) OS prep  
├ Implement RISC-V Privileged Architecture up to Supervisor mode (Machine, User, Supervisor)  
├ Implement GUI  
├ Understand GPIO, MMIO  
├ Implement virtual memory  
└ Understand and port the RISC-V Linux kernel  
(d) Dual-core structure  
(e) Multi-level cache  
(f) DDR3 SDRAM integrated main memory  
(g) Understand and implement RVWMO  
(h) Implement CMO  
(i) FPGA implementation and validation  

The actual goal is a RISC-V processor that can run an OS…  
Benchmarking AMD K6-III, dual-core isn’t strictly required just to run an OS…  

Let’s order the work by importance for the shortest-path goal.  

Even on a single core, atomic operations are needed for concurrency control such as interrupts and deadlock avoidance, so the A extension is necessary.

1. “A” extension
2. “M” extension
3. OS preparation  
   ├ Implement Supervisor Privileged ISA (Supervisor mode, User mode)  
   ├ Trap/Exception/Interrupt handling, CSR, timer, interrupt controller (PLIC/CLINT)  
   ├ Sv39, Sv48; virtual memory, MMU  
   ├ GPIO, MMIO, basic device access  
   └ RISC-V Linux kernel study and port (kernel config, Device Tree, boot loader, OpenSBI)  
4. DDR3 SDRAM integrated main memory  
5. FPGA implementation and validation  
6. GUI implementation

The rest—multi-level cache, dual-core, RVWMO, CMO—will be left as later tasks.
GUI will be tight, too. Possible if time allows…

From here, add the MA extensions and prepare for the OS.  
We already bought the FPGA board and it arrived, but using it will be later.  
Maybe in late April we’ll have the MA design and a rough handle on it?  
Whether to finish on FPGA or bring up the OS and then port to FPGA…  

Either way, let’s do this well.  
That’s all for today.

![250407c-RV64I59F_5SPH_FW_BP](/diagrams/design_archive/ima_make_rv64/RV64I59F_5SP/[250407c]RV64I59F_5SPH_FW_BP.drawio.png)

### [2025.04.10.]

Came to IDEC for Synopsys VCS/Verdi training. VCS is king.  
Up to now I had to manually verify each datapath, and whenever a related structure changed, I had to redo everything from the beginning, step by step. Now, instead, I can simply feed a Verilog file that describes the module and its signals, and do both simulation and debugging with Verdi.  
Wow!

For now, I’m continuing to attend. The first session is over, and I also made separate lecture notes.

### [2025.04.11.]

After the VCS lecture ended, I wanted to load the current CPU source into VCS/Verdi and try porting schematic/debug flows.  
Honestly, I had no idea how to start, so I asked the Synopsys instructor, and they helped.  

A few things I learned: 
depending on the compiler/tool in use, the source layout has to change a bit.
Up to now we used **Icarus Verilog (iverilog)** and ran everything—including tb—at once from the folder via commands, but it seems VCS uses different path specifications for `include`.  
Because of this, compile errors kept popping up; we looked into it together, and it took a while to realize that was the issue.  

I prepared a combined list of module files and tb files, but the porting work was more involved than expected.   
With iverilog, the latest version compiled clean (syntax etc.), but after porting to VCS—once the file path problems were fixed—many hard-to-read errors started showing up.  

Of course, iverilog is a fairly used compiler, and we even verified correct operation via a VCD file, so there’s likely no major problem in the code itself; still, the VCS port will probably take considerable time.  
It’s worth it, though. Tasks I used to do manually can be automated, and verification/debugging can be done in a much more intuitive environment—this is a very powerful tool.  

I think the person was a Synopsys employee; they seemed to look quite favorably on the ongoing project.  
They said they once designed a CPU based on a separate ISA proposed in an old computer architecture textbook—named something like “MOSA/MOA”?  
It’s not exactly the same target as our general-purpose RISC-V processor, but they were encouraging.  
Ideally, I wanted to do more of the porting at the KAIST N26 IDEC lab and even bring up schematic generation there, but due to time pressure, I had to stop there.
A truly meaningful and beneficial lecture.  

### [2025.04.12.]

Returned from leave… Installed Fedora on the local system for VCS, and set up a dual-OS with Windows.  
I wanted to do everything—including FPGA—on Fedora alone if possible, but the Xilinx Vivado toolchain is optimized for Windows, so I chose dual OS.  
One mistake: I didn’t account for how much space the dev tools would consume and configured only 256 GB of local storage.  
Splitting into two OSes at 128 GB each already felt tight, and I found that Xilinx tool installs hit a lot of space limits.  
On the plus side, it forced me to check every irrelevant option and install only the dev kits I truly need…  

But a problem emerged: even with a local system, I might not be able to run VCS on base.  
I asked my professor; the university provides Synopsys licenses, but they can only be used on campus.  
I tried to sign up for SolvNet just to install VCS, but even that requires a separate ID key tied to licensing; the professor said it would be hard to sort out right now.  
So for now… VCS usage will be on hold. I’ve heard POSTECH supports VPN for license access, so it might be possible—I'll ask **ChoiCube84**.  

Let’s list what to do starting tomorrow.  

1. Try initial FPGA verification setup
2. Study the “A” extension
3. Study virtual memory  
   (Otherwise same as the 25.04.07 roadmap)

I had finished installing Xilinx before heading back from leave, but the dual-boot got messed up about an hour before departure; I finally finished driver setup around 22:40.  
The USB modem claims 150 Mbps, but in practice I’m lucky to get 5 MB/s… the internet suddenly tanked and speeds are weird.  
I’ll just leave the Xilinx install running and come back in the morning.  

That’s it for today.

### [2025.04.13.]

Looked into the “A” extension.

These are Zaamo AMO instructions; contrary to my initial worries, the A extension looks fairly approachable. It feels a bit like SIMD—multiple actions bundled into one instruction.  

Commonly, it performs **R[rd] <- R[rs1]**, and also
**R[rs1] <- Binary Operated R[rs1] and R[rs2]**.  
We can find clues to the Binary Operation by looking at Zaamo instructions:  

amo**swap**.W/D  
amo**add**.W/D  
amo**and**.W/D  
amo**or**.W/D  
amo**xor**.W/D  
amo**max[u]**.W/D  
amo**min[u]**.W/D  

In other words, each instruction performs one of nine binary ops depending on the specific mnemonic: **swap, ADD, AND, OR, XOR, MAX, MAX_unsigned, MIN, MIN_unsigned**.

For **AMOADD.W**, used as `AMOADD.W rd, rs2, rs1`, the behavior is:

**R[rd] <- M[rs1]**  
**M[rs1] <- M[rs1] + R[rs2]**

First, **M[rs1]** is written into **R[rd]**; then **M[rs1]** is updated with (original **M[rs1]** + **R[rs2]**).

On RV64, double-word (64-bit) is supported.  
Also on RV64, 32-bit AMO instructions (word-size) always sign-extend the value written to **R[rd]** (the original **M[rs1]**), and ignore the upper 32 bits of the **R[rs2]** operand (the value combined with **M[rs1]** by the binary op).

Two things I still don’t understand:

1. Why these AMO operations are important when delegating roles in a multi-core architecture.
2. What **Load-Reserved / Store-Conditional** precisely mean.

### [2025.04.14.]

Further study on the “A” extension.

The A extension’s instructions are divided into two categories: Zalrsc and Zaamo.

- Zalrsc = Z, Atomic; Load-Reserved, Store-Conditional.
- Zaamo = Z, Atomic; Atomic Memory Operation.

In the Zalrsc subset, we see the reservation mechanism that underlies the A extension.  
It is divided into **LR.W** and **SC.W** (RV64 also supports double-word: **LR.D**, **SC.D**).

The execution of Load-Reserved is as follows.

1. Read a word from the specified memory address while marking that address as **reserved**.
2. **R[rd] <- M[rs1]**
3. At the same time, record information about the address marked reserved in step 1, and track whether that address is modified by another hart until an **SC.W** appears.

Conclusion: **R[rd] = M[rs1]**, and the address in **rs1** is marked “reserved.”

-----

The execution of Store-Conditional is as follows.

Write a new value to the address previously reserved by **LR.W**.

1. Perform **M[rs1] <- R[rs2]**.  
   If the reservation since **LR.W** has **not** been broken (i.e., the data at that address has not been modified by another hart), the store **succeeds**.
   If the reservation **has** been broken (i.e., the data at that address was modified/updated by another hart), the store **fails**.  
   - 1.1 On success: **R[rd] <- 0**  
   - 1.2 On failure: **R[rd] <- 1** (in this case, no actual write to memory occurs).

To support reservations, we usually implement a register that holds the reserved address, or we can integrate with the cache and track at the cache-line granularity.

Conclusion:

1. Validate the reservation.
   - 1.1 If valid: **M[rs1] = R[rs2]**, **R[rd] = 0**
   - 1.2 If invalid: **R[rd] = 1**

-----

The “A” extension instructions use bits **26:25** as **aq** and **rl**.  
**aq (acquire)**, **rl (release)**. These two bits are used to control **memory ordering**.

An instruction with **aq** set must ensure the hart waits until that instruction completes before subsequent instructions can proceed.  

An instruction with **rl** set must ensure the hart waits until all prior memory accesses complete **before** executing the **rl**-set instruction.  

Functionally, I already wait two cycles when reading from memory and hold the instruction until the read-done signal arrives; this resembles the behavior required when **aq** is set (continue to hold until the **aq**-marked instruction completes). 
I can implement **aq** in a similar fashion.  

-----

#### Meeting with ChoiCube84 on data cache–memory structure

1. > shouldn’t memory be larger than the cache? 

   Yes.

On our FPGA board we’ll use 512 MB DDR3 SDRAM, but implementing with 1 MB for now is fine.
Regardless of capacity, let’s just make memory larger than the cache for now.

2. > What about the address scheme?  

   For now, let’s size it to the current memory capacity only.

We’ll specify this in the architecture specification, and once the Exception Detector is built, we should raise a dedicated exception.  
I’ll research mechanisms from CPUs like **AMD K6-III** as references—they likely considered this too.  

Conclusion: for now, use only as many address bits as needed for the current memory size.  

3. > Cache–memory block-granularity communication?
   
   We should do it.

Memory → Cache: **block** granularity  
Cache → WriteBuffer → Memory: **word** granularity  
For now, cache–memory communication should be **block**-based.  

### [2025.04.15.]

#### ChoiChube84 Issue

1. When running vvp in the Data Memory testbench, it freezes and dies.  
   KHWL: Likely because we set memory to 512 MB. Try reducing to 1 MB and run again.  
   CC84: More likely because we widened the output from 31:0 to 255:0.  
   ----For now, I was told to reduce to 1 MB----  
   CC84: Reducing to 1 MB worked!  
   KHWL: Nice.  

2. What sequence does our memory need to fetch 32 B of data from SDR?  
   KHWL: SDRAM can output per word. Currently it’s a 32-bit word; to get 32 B, we need 8 outputs.  
   CC84: If that’s the case, why not just make one block 32-bit? This seems very inefficient.  
   KHWL: 32-bit (4 bytes) -> 32 bytes -> 8 cycles is correct, but we load adjacent data per locality of reference, so it’s still meaningful.  

   If the program is fixed (embedded, ASIC), total execution time is the same, so such a structure might be undesirable; but for general-purpose workloads running many different programs, that complaint doesn’t matter much.  
   Total execution time differs by program, and how much locality each program exploits also differs.  

   Bluntly, if a bank can hold 8 items vs. only 1, the latter must be refreshed every time, whereas the former keeps hitting in the cache after one load.

3. Then shouldn’t we increase ways?  
   KHWL: Heh… true, but for now we benchmarked AMD K6-III and set L1$ to 2-way. We’ll increase it at L2 with the unified cache.  
   Of course more ways and capacity are better, but beyond cost/area issues, our purpose here is academic; following a suitable reference is sufficient.

Today my workday ended around 19:30, so I couldn’t study much.  
Still, we had a meaningful meeting, and writing the logs I hadn’t yet written about the A extension let me review once more.  

To do tomorrow: summarize the A extension’s Zaamo subset and look at additional A-extension instructions.  
Study virtual memory from the computer architecture text / paging.  
Look into Sv48 virtual memory.  

Current roadmap: try to execute as much as possible by June.  
After FPGA porting training at the end of May, start FPGA porting in early June based on the design as of that time.  

Isn’t running an OS more important, really?   
Yes, but the bigger prerequisite is ensuring the design is actually implementable, not just logical. That’s why I set it up this way. Whatever happens, completing the project matters most—producing results to achieve the goal.

#### Remaining roadmap:

~ RV32I43FC in progress (implementing cache and memory structure)  
~ RV32I47NF in progress (Exception Detector, Trap Controller, Debug Interface design done, pending implementation)  
~ RV64 extension (design done, pending implementation)  
~ 5-stage pipeline extension (design done, pending implementation)  
① “A” extension (design in progress)  
② “M” extension (design done, no changes; implementation should not require long delay)  

③ OS preparation  
├ Implement Supervisor-Privileged ISA (Supervisor mode, User mode)  
├ Trap/Exception/Interrupt handling, CSR, timer, interrupt controller (PLIC/CLINT)  
├ Sv39, Sv48; virtual memory, MMU (studying)  
├ GPIO, MMIO, basic device access  
└ Understand and port RISC-V Linux Kernel (kernel config, Device Tree, boot loader, OpenSBI, )

④ DDR3 SDRAM integrated main memory implementation  
⑤ FPGA implementation and verification  
⑥ GUI implementation  

Plan is to move straight to backend after completing RV64IMA109 plus virtual memory and MMIO. Beyond this, implementation time grows too long, and the next stages require studying several other areas.  

That’s it for today.

### [2025.04.16.]
In the morning, I looked into the extensions derived from the A extension: Zawrs (Z; Atomic, Wait-on-Reservation-Set instructions) and Zacas (Z; Atomic, Compare And Swap).  
Zawrs is an extension that provides instructions for entering a low-power (wait-like) mode used in polling loops, and Zacas is an extension that supports conditional swap instructions up to quadword (128-bit).  
Zawrs is good just to be aware of, and I should carefully read the Zacas manual once.

In the afternoon, our unit went on an outing to Heyri Village.  
I brought the “Computer Organization and Design” book to read in the car, and since we stayed at a cafe for a long time, I was able to spend some really good time.  

I got a rough sense of virtual memory: it feels like a kind of cache for managing and accessing program memory.  
The difference is that a cache is a direct physical access optimization for instructions/data, while virtual paging/virtual memory creates something cache-like so that programs can run more simply and smoothly at higher performance under hardware and the OS. 
And with virtual paging, we also use caches together.

This is a first pass, so I didn’t understand everything precisely, but I feel like I’ll understand more as I go.  
TLB, etc.—I’ll study that part later; first I’ll focus on implementing the A extension.

Once evening study time starts, I need to check whether the M extension can be implemented in the current RV64I59F design without structural changes and lock it in.  
And then start implementing the A extension.

Let’s do this. That’s it for now.

--Evening self-study time--

Okay. Let’s check the M extension first.

M instructions..  
[R-Type]  
mul, mulh, mulhsu, mulhu, div, divu, dviuw, remw, remuw  

It seems only R-Type exists. Let’s write MNEMONICS for each instruction.  

XLEN-bit × XLEN-bit  
MUL : R[rd] = (R[rs1] × R[rs2]) [XLEN-1:0]  
MULH : R[rd] = (R[rs1] × R[rs2]) [2×XLEN-1:XLEN] (Signed × Signed)  
MULHU : R[rd] = (R[rs1] × R[rs2]) [2×XLEN-1:XLEN] (Unsigned × Unsigned)  
MULHSU : R[rd] = (R[rs1] × R[rs2]) [2×XLEN-1:XLEN] (Signed × Unsigned)  
MULW : R, {R × R} [31:0]  

DIV : R[rd] = R[rs1] ÷ R[rs2] (Signed)  
DIVU : R[rd] = R[rs1] ÷ R[rs2] (Unsigned)  
DIVW (RV64) : R ÷ R  
└ Write the 32-bit result to R[rd] sign-extended to 64-bit.  
DIVUW (RV64) : R ÷ R  
└ Write the 32-bit result to R[rd] zero-extended to 64-bit.

REM is the modulo operation, A % B = C.  
It is the remainder C when A is divided by B.  

REM : R[rd] = R[rs1] % R[rs2] (Signed)  
REMU : R[rd] = R[rs1] % R[rs2] (Unsigned)  
REMW (RV64) : R, {R % R} [31:0]  
└ Write the 32-bit result to R[rd] sign-extended to 64-bit.  
REMUW (RV64) : R % R} [31:0]  
└ Write the 32-bit result to R[rd] zero-extended to 64-bit.

Overall, it looks like I only need to change the ALU code itself and adjust ALUops in the ALU Controller.  
The M extension can be added to the RV64I59F design without structural changes.

Good, now let’s design the “A” extension.

------ A Extension MNEMONICS ------

Zalrsc Extension: Z, Atomic; Load-Reserved / Store-Conditional Extension  
LR.W : R[rd] = M[R[rs1]],  
Set a reservation on the value in R[rs1] (which is the memory address used in step 1).  

SC.W :  
if Reservation is valid, M[R[rs1]] = R[rs2], R[rd] = 0  
if Reservation is invalid, R[rd] = 1  

Zaamo Extension: Z, Atomic; Atomic Memory Operation  

AMOSWAP.W : R[rd] = M[R[rs1]], M[R[rs1]] = R[rs2]  
(Write the original M[R[rs1]] to R[rd], then write rs2 to memory (swap))  

AMOADD.W : R[rd] = M[R[rs1]], M[R[rs1]] = M[R[rs1]] + R[rs2]  
(Write the original M[R[rs1]] to R[rd], then write (original + rs2) to memory.)  

AMOXOR.W : R[rd] = M[R[rs1]], M[R[rs1]] = M[R[rs1]] ^ R[rs2]  
AMOAND.W : R[rd] = M[R[rs1]], M[R[rs1]] = M[R[rs1]] & R[rs2]  
AMOOR.W : R[rd] = M[R[rs1]], M[R[rs1]] = M[R[rs1]] | R[rs2]  

┌ Comparisons are performed as signed.  
AMOMIN.W : R[rd] = M[R[rs1]],  
if (M[R[rs1]] < R[rs2]), M[R[rs1]] = M[R[rs1]].  
else M[R[rs1]] = R[rs2]  

┌ Comparisons are performed as signed.  
AMOMAX.W : R[rd] = M[R[rs1]],  
if (M[R[rs1]] > R[rs2]), M[R[rs1]] = M[R[rs1]].  
else M[R[rs1]] = R[rs2]  

AMOMINU.W : R[rd] = M[R[rs1]],  
if ((Unsigned) M[R[rs1]] < (Unsigned) R[rs2]), M[R[rs1]] = M[R[rs1]].  
else M[R[rs1]] = R[rs2]  

AMOMAXU.W : R[rd] = M[R[rs1]],  
if ((Unsigned) M[R[rs1]] > (Unsigned) R[rs2]), M[R[rs1]] = M[R[rs1]].  
else M[R[rs1]] = R[rs2]  

That’s it for today. I need to think about this more. Ah, I’m on duty tomorrow… hmm… I should study virtual paging.

### [2025.04.17.]
I’ll record what I studied and organized during duty.

**Virtual Memory**

Reasons to use virtual memory

1. Effective memory sharing when running multiple programs simultaneously  
   -> Removes the constraint of having to program within the limited size of main memory.

Assuming there are VMs that use shared memory.  
A virtual machine must guarantee protection so that each process is protected.  
This means each program must be guaranteed R/W (Read/Write) only within the portion of main memory allocated to it.  

Virtual memory translates a program’s address space into a physical address.  

-> VMs that share memory change dynamically while the VMs are running.  
--> Dynamic interaction: each program must be compiled in its own address space.  
---> There must be a separate memory region accessible only by that program.  

= The translation process can protect one program’s address space from other virtual machines.

2. Allows user programs to be larger than main memory.  
   -> Virtual memory automatically manages a two-level memory hierarchy consisting of main memory and secondary storage.

It has properties similar to a cache, but the terminology is distinguished.  

[Memory block]: the unit/format that communicates with memory  
Cache = cache line, cache block  
Virtual memory = page  

A failure in virtual memory is called a page fault.

A processor that supports virtual memory generates a virtual address.  
It then translates this into a physical address; this is called address mapping or address translation.  
It is commonly called address translation (e.g., Translation Lookaside Buffer; TLB).

This “physical address” is the address used to access main memory by a combination of HW and SW.  
 
-----

Virtual memory – relocation: simplifies loading of programs to be executed.  
It maps the virtual addresses used by the program to different physical addresses “before” they are used to access memory.  
-> Allows a program to be loaded at any location in main memory.

In modern systems, programs are relocated as a set of fixed-size blocks (pages).  
= There is no need to find contiguous blocks in memory to allocate a program; the OS only needs to ensure there are enough pages in main memory.

### [2025.04.18.]

Changes to cache structure.

Data read, cache miss, and dirty bit cases.

The requested data are fetched from memory according to SAA, but to update the cache, the data output from memory must still continue.  
Since the address used for the cache update must also continue to be driven, a PC_Stall is required.

Update the dirty bit at CLK1, and at CLK2 update that cleaned block in the cache with the data fetched from data memory at CLK1.  
In other words, PC_Stall must persist until all cache writes complete.  
Cache writes finish at CLK2. Since the cache is the first to know that writing is complete, a Cache Write_Done signal was added.  

In RV32I43FC, content about the Write Buffer was missing from the diagram, so I revised to RV32I43FC.R2 and added the Write Buffer.  

![RV32I43FC.R2](/diagrams/design_archive/RV32I43FC/RV32I43FC.R2.drawio.png)

At the same time, I also added the DC_WriteDone signal to the Data Cache as noted above.  

Reflected this in RV64I59F_5SP as well.  
![RV64I59F_5SP.R2](/diagrams/design_archive/ima_make_rv64/RV64I59F_5SP/RV64I59F_5SP.R2.drawio.png)

While looking into the A extension,,

For instructions that already take more than two cycles, I had designed it so that the pipeline stops via Ready signals from the Control Unit and the Cache or Memory,
and waits without updating instructions until the current memory operation is completely finished.  

AMO operations are aligned with this focus; without a multi-core structure, there doesn’t seem to be anything more complex to implement.  

It seems I can keep most of the existing structure, but the problem is Zalrsc rather than Zaamo.  
I still don’t fully understand this “reservation.”  
I understand the actions required when setting the aq and rl bits for each instruction execution, but LR.W and SC.W…  

To do tomorrow: study reservations.

### [2025.04.22.]  
I was on duty. I had off-base leave on the 19th and 20th for a Jeet Kune Do seminar, and on the 21st I was on duty again.  
During duty I originally planned to study virtual memory further, but because of a knee fracture my energy was pretty drained, so I worked on the A-extension design/implementation.  

I started with the easier-to-understand Zaamo subset.  

Additional design items for Zaamo

1. There is no datapath where ALUresult is driven to Memory.  
   Most Zaamo instructions follow this form:  
   R[rd] ← M[R[rs1]]  
   M[R[rs1]] ← M[R[rs1]] bit operation with R[rs2]

In this case, the bit operation is performed in the ALU. 
RD2 (the value of R[rs2]) sits on ALUsrcB, but the operand M[R[rs1]] that must be combined with it is not on ALUsrcA. 
Therefore, expand the existing ALUsrcA MUX to 3 bits so it can select among RD1, PC, rs1, and D_RD (Data area Read Data).  

2. ALUresult must be routable to the Data area’s Data Cache input DC_WD (Data Cache Write Data).  
   Previously, ALUresult was only used as an address on the data side, but in the A extension ALUresult is also used as data to be written.  
   DC_WD’s inputs were chosen between two sources—input from DM for write-back and input from the Register File—selected based on cache hit/miss.  
   Given the added requirement above, either expand that MUX to 2 bits so CU can select the input, or keep the existing MUX and add one more MUX after it (two 1-bit MUXes total), letting the CU choose between ALUresult and the existing WB/RegF value.

Item 1 applied. Item 2 applied using option 2 (two 1-bit MUXes).  
One concern: with option 2, could there be a data conflict during WriteBack?  
Let’s do a thought experiment.  

AMOADD.W  
R[rd] = M[R[rs1]]  
M[R[rs1]] = M[R[rs1]] + R[rs2]  

[Control signals]  
MemWrite = 1.  
RegWrite = 1.  
Atomic = 1.  

Now, suppose the address M[R[rs1]] misses; we must fetch from Data Memory.  
Due to SAA, M[R[rs1]] is returned first. At the same time, DM_RD must feed the DC_WD input.  
The WB/Reg MUX selects WB on a miss, so DM_RD is chosen. Since this is an atomic operation, the WB/Reg / Atomic MUX selects Atomic.  

Wait. Write-back is impossible here. In other words, on a cache miss the cache will be updated in the next cycle, so the Atomic MUX must always be set to WB/Reg when there’s a cache miss…  
Therefore, the CU must be able to determine cache hit/miss, or DC_WD must always select WB/Reg when DC_Ready is Not Ready.  
Miss = Not Ready. For cache M2C updates we wait for the Write_Done signal, so a miss implies Not Ready.  

With this, on a cache miss we naturally PC_Stall until the cache update completes.  

CLK 1. R[rd] = M[R[rs1]]  

Data Cache lookup finds no M[R[rs1]].  
Cache miss. Begin cache update sequence. Assert MemWrite = 1.  

[if Clean]  
DC_Ready : not ready.

- SAA: Data Memory outputs M[R[rs1]]   
   - → written to R[rd].
   - M[R[rs1]] = M[R[rs1]] + R[rs2]   
   executed simultaneously output to the Data Cache as well.   
   Store that data at the current DC_Addr input, i.e., R[rs1].

-----

[if Dirty]  
DC_Ready : not ready → PC_Stall  

SAA return;   
- Data Memory outputs M[R[rs1]] → written to R[rd].   
- M[R[rs1]] = M[R[rs1]] + R[rs2], MemWrite = 1  
Store the cache’s dirty data block with its address into the Write Buffer.   
At the same time… compute M[R[rs1]] op R[rs2].  
Clear the cache dirty bit.  

CLK 2. Since CLK1 was PC_Stall, DC_Addr is still the same address.  
Overwrite the cleaned cache block with the memory block.  
Write the address/data saved in the Write Buffer back to memory.  

![RV32I47NF.R1](/diagrams/design_archive/RV32I47NF/RV32I47NF.R1.drawio.png)
![RV64I59F.R2](/diagrams/design_archive/ima_make_rv64/RV64I59F/RV64I59F.R2.drawio.png)

### [2025.04.23.]

![RV64I59F_Zaamo_temp](/diagrams/design_archive/ima_make_rv64/RV64I59F/RV64I59F_Zaamo_temp.drawio.png)

Ah… what should I do about the A extension.  
During work hours I significantly improved my understanding of virtual memory/paging. I don’t fully grasp everything including the TLB yet, but I think I’ve learned the basics.  
If the buffer between registers and memory is the cache, then the buffer between cache and memory/secondary storage seems to be virtual memory; pages.  
A fully associative, cache-like structure… the virtual page number is used like a tag, and the physical page number is the corresponding data. Separately there is a page offset…  
The page offset determines the number and size of pages. Number of page-number bits × page offset = the size of that paged memory (virtual page bits → virtual paging size; physical page bits → physical memory size).  
Therefore, to implement a TLB or virtual memory, I think we need to fix the physical memory size itself.  

One TLB miss handling method is to hand control over to the OS, and supporting virtual memory implies that in addition to main memory, secondary storage must also exist.  
So, for some reason I had thought implementing only the main memory DDR3 SDRAM would suffice, but that’s not it—we have to consider external storage as well…  

There’s more to do than I expected… it feels like the more I dig, the more it grows…

The issue I was worrying about yesterday can probably be solved by implementing an FSM.  
Let’s run the thought experiment again.

Assume the worst case: cache miss with block dirty.  
The instruction is Zaamo; AMOADD.W  

AMOADD.W  
R[rd] = M[R[rs1]]  
M[R[rs1]] = M[R[rs1]] + R[rs2]  

[Control signals]  
MemWrite = 1.  
RegWrite = 1.  
Atomic = 1.  

**CLK1**
I need to do M[R[rs1]] into R[rd].  
SAA: Query Data Cache and Memory; the address value is driven on DC_Addr and DM_Addr.  
Cache index, miss.  
The Memory WB/ALUresult MUX switches to ALUresult on the cache-miss signal, and the memory read at that address begins.  

The memory identifies the data at that address and outputs it (DM_RD).  
The output DM_RD is driven to the register’s RF_WD and stored into R[rd], which is currently on the register’s RF_WA.  
R[rd] = M[R[rs1]] complete.  

At the same time, since the output DM_RD must also update the Data Cache, it is being driven to DC_WD.  
At the first MUX (WB/Reg MUX), WB is selected via the cache-miss signal and goes to the second MUX.  

> “At the second MUX, since this is Atomic, it selects ALUresult instead of WB.”  

That’s the problem.  

Because it’s a cache miss, WB must take precedence over Atomic so that WB occurs.

Ah… I need to write more… time out… this is it for evening study today.

### [2025.04.24.]

I thought about it during work hours. A way to solve the issue.  
At the second MUX, Atomic control is active, so WB is not selected.  

On cache miss, switch DC_Ready to not ready and have the CU receive it.  
In the CU, via an always conditional or otherwise, allow the atomic operator to execute only when DC is ready.  
That solves it.

Assuming this fix, continuing the thought experiment proceeds as follows.  

-----
At the first MUX (WB/Reg MUX), WB is selected via the cache-miss signal and goes to the second MUX.  

Cache miss sets DC_not ready, so the Control Unit issues PC_Stall and we advance to the next clock cycle.

Since Data Cache is not ready, Atomic = 0 (inactive). 
Therefore, the second MUX selects WB instead of ALUresult, and the memory’s DM_RD is being driven into DC_WD.

However, since we assumed dirty, the Cache stores the dirty data block together with that block’s address into the Write Buffer.  
The cache’s dirty bit is cleared, but since it’s not yet updated, we must proceed to the next cycle.

**CLK2**
Due to PC_Stall, the same-context instruction is executing.  
The memory’s DM_RD is overwritten into the cleaned cache block.  
The address/data saved at CLK1 in the WriteBuffer are driven as WB_Data… the DM_Addr MUX needs to select WB, but should DC_Status still be Miss in this CLK2?  
This doesn’t seem to be about handling only the ‘current’ Hit/Miss… moreover, in CLK2 we need M[R[rs1]] = M[R[rs1]] + R[rs2], so it needs to be a cache Hit…  
This likely needs adjustment. The select signal of the DM_Addr MUX should probably be handled in the CU as if recognizing the cache FSM. Here, Data Memory should have WriteEnable asserted.

Anyway.

Cache update complete, memory write-back complete.  
At the same time we need to do M[R[rs1]] = M[R[rs1]] + R[rs2]… I’ll probably need to check this in simulation.  

Usually after a write, the waveform clearly shows it from the next cycle; if this can be tuned, the atomic operation ends in CLK2, but in the worst case due to the cache structure it might slip to CLK3.

(Perhaps CLK3)  
M[R[rs1]] = M[R[rs1]] + R[rs2].  
Having gone through CLK1–2, the cache is updated, so it will be a Hit for sure.  
By driving the RD1 value (bypassed from the ALU) to DC_Addr, the cache outputs the memory data at that R[rs1] address to DC_RD, which then reaches the ALU as D_RD???
That means it passes through the ALU twice???

Then to drive R[rs1] as the address to DC_Addr, instead of bypassing through the ALU, we have no choice but to make a 2-to-1; 1-bit MUX selecting ALUresult vs. RD1.
Only then can the operation be completed in a single cycle… and the select signal for that MUX should likewise be handled by the CU.  
It can be controlled by the same Atomic signal. 
It will be inactive during Write Back anyway, so no issue, and when DC is Ready, any operation structurally should be fine…

That’s it for today. I updated the organized logic notes and additional control details on the Telegram channel and the Discord server.

![RV64IM90_Zaamo](/diagrams/design_archive/ima_make_rv64/RV64IMA94F/[250424]RV64IM90_Zaamo.drawio.png)

### [2025.04.25.]

Things left to do now   
aq, rl bit support    
Zalrsc extension support  

Let’s design aq, rl bit support first.  

#### ~2025.04.16.

The “A” extension instructions use bits 26:25 as **aq** and **rl**, one bit each.
aq (acquire), rl (release). These two bits are used to control memory ordering.

An instruction with the aq bit set must cause the hart to wait until that instruction completes before subsequent instructions can proceed.

An instruction with the rl bit set must cause the hart to wait until all prior memory accesses complete before executing the rl-set instruction.

-----

This… shouldn’t require structural adjustments. 
The Control Unit needs to look at the aq, rl bits and assert PC_Stall based on conditions, so I need to add the relevant funct7 bit range as input signals.  
Done. RV64IM90_Zaamo_aqrl  

![250425-RV64IM90_Zaamo_aqrl](/diagrams/design_archive/ima_make_rv64/RV64IMA94F/[250425]RV64IM90_Zaamo_aqrl.drawio.png)

What remains is Zalrsc… Load-Reserved, Store-Conditional…

Zalrsc Extension: Z, Atomic; Load-Reserved / Store-Conditional Extension
- LR.W : R[rd] = M[R[rs1]],  
Set a reservation on the value in R[rs1]   
(the memory address used in step 1).

- SC.W :  
if Reservation is valid, M[R[rs1]] = R[rs2], R[rd] = 0  
if Reservation is invalid, R[rd] = 1  

To implement the Zalrsc extension, I first need to understand the notion of reservation.  
I searched a lot of material, but there wasn’t anything that explained it clearly, so I’ll have to rely entirely on the manual to understand it.  

The basis of the A extension is to synchronize atomic read-modify-write on shared memory when multiple RISC-V harts operate in the same memory space.  
There are two forms of atomic instructions: “load-reserved/store-conditional instructions” and “atomic fetch-and-op memory instructions.”  
Both support various memory-ordering semantics: unordered, acquire, release, and sequentially consistent.  
These instructions allow RISC-V to support the RCsc memory consistency model.  
(RCsc: release consistency with special accesses sequentially consistent; Memory consistency and event ordering in scalable shared-memory multiprocessors, Gharachorloo et al., 1990)

After much discussion, RISC-V adopted release consistency as the standard memory consistency model.  
So RISC-V’s atomic support is based on that model.  
…

I almost went down the path of translating the entire A Extension chapter into Korean (tempting, but time is too tight—learned my lesson from the Privileged_ISA.Korean.md precedent… lol).  
Instead, I extracted and summarized sentences in that chapter containing the words “reservation,” “reservation set.” Doing this forced me to read the chapter word by word; the clues I got are as follows.  
(A_extension_Korean.md created.)

In conclusion, Load-Reserved and Store-Conditional are used as a pair.   
LR.W establishes a reservation, and a successful SC.W invalidates that reservation.
Therefore, we need a “data space” for the reservation, and in a single-hart system one is sufficient.   
The issue is the size of that data; the A spec doesn’t directly prescribe it.  

However, it states:
> “**The platform should provide a means to determine the size and shape of the reservation set.**”  

> “**A platform specification may constrain the size and shape of the reservation set.**”  

So the size and shape are left to platform design discretion, and the spec requires that the platform document this.

If the reserved data itself needed to be explicitly marked, the spec would have said to reserve “that data” directly; instead, the wording about including the “bytes” of the data suggests a more flexible implementation.   
It feels a bit like cache tag/index… could be implemented that way. Given locality, data used within an LR/SC sequence tends to be somewhat constrained… but at a point where uncertainty and my own limits could lead me astray, an experimental approach would slow development and add risk.  
Of course that’d be fun(!), but with only about a month left including FPGA work (deadline May 28), I should take the stable route.  

Memory is fetched in blocks and the target datum is identified within the block via an offset… so perhaps it’s enough to size the reservation to the size of the datum?  
To keep implementation simple, I’ll do exactly that. This way I can implement Zalrsc in the simplest way without “logically” violating the spec.  
Add a single buffer register, the reservation register (RR), to store the address and data.  
Then, on each subsequent memory lookup, compare against RR to judge whether the data at that address matches or differs.  

When does a reservation get broken, again… what exactly am I checking this comparison for? Reservation validity?? I’ll stop here for today—evening study time just ended.  

I think I can implement Zalrsc by tomorrow.
You’re doing well… doing… well.

### [2025.04.26.]

I decided to define the size of the reservation set based on one cache line.  
It can be handy when that byte region is referenced, and considering future I/O and structural extensions, allowing that much overhead shouldn’t be a problem.  
The reservation set will be a 32-byte register.  
Triggering SC.W invalidates the reservation established by LR.W. Also, the reserved data are registered per hart, and each hart holds only one reservation set at a time.  
According to the SC.W failure conditions, the reservation set is invalidated under the following cases.  
Even without a direct association with the reservation set, we must invalidate on execution of SC.W regardless of success or failure to comply with the ISA rule that SC.W invalidates the reservation set.  

0. If the address targeted by SC.W is not contained in the reservation set, invalidate.
1. If another hart writes to data corresponding to the reservation set, invalidate.
2. If another device writes to the bytes accessed by LR, invalidate.  
   (If a write happens to bytes other than those accessed by LR but still within the reservation set, SC may either succeed or fail. For simplicity, in our case we treat line-granularity access as failure.)
3. If, in program order, there is another SC (to any address) between LR and SC, invalidate.

Implementation is as follows.  
1. When executing SC.W (the CU checks via funct7 bits),  
to judge success/failure, we must check validity of the reservation set in the Reservation Register. 
- We must check whether the R[rs2] data fall within the reservation set, so feed RD2 as an input to the Reservation Register.  
During LR.W, the reservation registers the data value of R[rs1] (which is the memory address, since M[R[rs1]]), so feed RD1 as an input to the Reservation Register.  

- Since this is a reservation set, we need a control signal to invalidate when required, so add an invalidate control as a CU output and feed the Invalidate signal into the Reservation Register.  
Because this is implemented as a register, provide the clock as an input to align outputs with the clock.  
We need an output signal that indicates success/failure by comparing RD2 to the address registered in RD1 as the reservation-set base; call this output **Rsv_YN** (Reservation_Yes_or_No). Feed **Rsv_YN** back into the Control Unit.  

1. We must detect writes to the reserved memory address (R[rs1])… at this point it seems best to make a separate Atomic Control module.  
   - Atomic Control Unit  
   On memory writes, check whether the write address falls within the reservation set.  
   **[Inputs]**  
      - CLK,
      - MemWrite,
      - Rsv_Invalid,
      - RD1,
      - RD2,
      - Data_Addr (ALUresult)  

      **[Output]**
      - Rsv_YN

   Logic:  
   On LR.W execution, take the input coming on Data_Addr.  
   Align that address to form a 32B-block-sized reservation set and mark it Valid.  

   On SC.W execution, compare the incoming RD2 value against the reservation set.  
   If Valid and within the reservation set, output Rsv_YN = Yes (1).  
   Simultaneously invalidate the reservation set.  
   In the CU, on SC success (Rsv_YN is Yes), select DC_Atomic_MUX to ALUresult so that the RD2 value bypassed from the ALU is stored to memory M[R[rs1]].  
   Simultaneously select RegWDsrc_MUX = 110 to write 0 into R[rd].  

   If Valid but not within the reservation set, output Rsv_YN = No (0).  
   Then invalidate the reservation set. Simultaneously select RegWDsrc_MUX = 111 to write 1 into R[rd].  

   If Invalid in any situation, Rsv_YN = No, and select RegWDsrc_MUX = 111 to write 1 into R[rd].  

   For other instructions, if MemWrite is asserted and Data_Addr (ALUresult) lies within the current reservation set, invalidate the reservation set.

---------- Zalrsc overall summary ----------

Premise: Complex atomic memory operations ~~ are performed with the load-reserved (LR) and store-conditional (SC) instructions.  
In other words, treat the operations covered by Zalrsc as memory operations.  

LR.W loads a word from the address in rs1, places the sign-extended value in rd, and registers a reservation set  
-> a set of bytes that subsumes the bytes in the addressed word.  
--> LR.W loads a word from the address in rs1, writes its sign-extended value into rd, then registers it in the reservation set.  
The reservation set is the set of bytes that includes the bytes of the word loaded from rs1.

Load means loading a value from Memory into a Register.  
So “word from the address in rs1” is M[R[rs1]].  
Sign-extend M[R[rs1]] and write into R[rd], then register it in the reservation set.
The reservation set is the set of bytes that includes the bytes of the word loaded from the rs1 address.  
So we write M[R[rs1]] into the reservation set at cache-line granularity (32B in our case).  
If 0x8000_1234 is M[R[rs1]], then designate 0x8000_1200–0x8000_123F as the reservation set.  

Therefore we need a place to hold that reservation set; call this the Reservation Register, and since we must invalidate and update it via control, place the Reservation Register inside the Atomic Unit.  
In the diagram, Atomic Unit ≈ Reservation Register is acceptable.

-----

SC.W conditionally writes a word in rs2 to the address in rs1:  
the SC.W succeeds only if the reservation is still valid and the reservation set contains the bytes being written.  

= SC.W conditionally writes the word from rs2 to rs1. SC.W succeeds if the reservation is still valid and the reservation set contains the bytes to be written to rs1.

> “SC.W conditionally writes the word from rs2 to rs1…”

Store means writing a Register value to Memory.  
So the word in rs2 is R[rs2], and writing to rs1 means storing to M[R[rs1]].  
That is, M[R[rs1]] = R[rs2].  
And the bytes to be written to rs1—i.e., to M[R[rs1]]—are R[rs2].  
SC.W and LR.W operate as a pair.  
For SC.W to succeed as above, the bytes written by SC.W to rs1 must be contained in the Reserved Set of bytes registered earlier by LR.W.  

![250426-RV64IM90_Zaamo_aqrl](/diagrams/design_archive/ima_make_rv64/RV64IMA94F/[250426]RV64IM90_Zaamo_aqrl.drawio.png)

That’s it for today.

### [2025.04.27.]

![250427c-RV64IMA90](/diagrams/design_archive/ima_make_rv64/RV64IMA94F/[250427c]RV64IMA90.drawio.png)

### [2025.04.28.]

20:18 Finally today—after many twists and turns—I decided how to do it.  

On executing LR.W, place the sign-extended M[R[rs1]] value into rd.  
In other words, M[R[rs1]] is written to R[rd].  
The address of M[R[rs1]] is R[rs1].  

*reservation set* : a set of bytes that subsumes the bytes in the addressed word.
The set of bytes that includes the bytes of the “*addressed word*.”  

Here’s the problem.  
Is the **addressed word** the address of M[R[rs1]], i.e., R[rs1]?  
—or is it the data value of M[R[rs1]], i.e., M[R[rs1]] itself?  

Let’s split into cases and analyze.  

What if addressed word meant Data itself?  
-> For SC.W to check the reservation, we would have to compare the data output (D_RD) with the Reservation Set.  

Contradiction. In this case, data is output and compared to the Reservation Set, but D_RD flows straight through BE_Logic and RegWDmux into the Register File.  
If Register Write Enable is active then it is written immediately; adding extra logic and controls just to block this would cause extreme structural inefficiency.

What if address word meant Address?  
-> For SC.W to check the reservation, we would compare the memory address (ALUresult) with the Reservation Set.  
Along with the contradiction above, “Store Conditional” implies that the reservation decision must be made before the data for the store is even provided.  
At the moment the address for the store—i.e., RD1 (when the 5-bit rs1 goes into the Register File and the data stored at that register-address is output)—is fetched, we compare against the reservation set and gate execution through conditionals.   
This is natural and structurally ideal for implementing the function.

It follows the existing logic as-is, but now with a clearer, self-consistent reason.

With that, we can now write it simply. hehe…

LR.W : R[rd] <- M[R[rs1]]  
Reservation Set <- ( the 32B block address set that contains R[rs1] )  

SC.W : condition check.  
```
if { ( R[rs2] ∈ Reservation set && Reservation set == valid )  
 M[R[rs1]] = R[rs2],  
 R[rd] = 0  
}  

else R[rd] = 1
```
Done!!! haha

The Atomic Unit holds the Reservation Set, and when executing Zalrsc instructions,
it informs the Control Unit whether SC.W should succeed or fail,
so MemWrite must be enabled or disabled.   
In this case, since we must store 0 or 1 in Register File R[rd], the CU enables RegWrite.

And to determine validity of the Reservation Set according to the failure conditions described above, when a memory write occurs we must check whether the address being written falls within the Reservation Set.  
That is, the ALUresult (data memory address) must be an input signal.

At the same time, on memory reads, we must not invalidate just because that ALUresult was looked up in memory; therefore, perform the comparison only when MemWrite (i.e., a write) is active, so MemWrite must also be an input signal.  

And when SC.W executes, the Reservation Set must be invalidated automatically regardless of success/failure.  
Since the Control Unit is the first to know the exact instruction being executed and manages the control flow, the CU must be able to invalidate the Reservation Set on SC.W execution—so the CU sends Rsv_Invalid to the Atomic Unit.   
In other words, Rsv_Invalid must be an input signal.

-----
Now we can finalize the Atomic Unit design.

- [Input signals]  
   - R[rs1]   
   for registering the Reservation Set, i.e., RD1 from the Register File.
   - R[rs2]   
   for comparing with the Reservation Set, i.e., RD2 from the Register File.
   - ALUresult  
   the memory address signal to know whether writes (other than SC) hit the Reservation Set.

These three are the data signals to receive.  
The rest are control signals.  

- MemWrite,   
the write-enable signal to know whether a write to an address in the Reservation Set (other than SC) is happening.
- Rsv_Invalid.

The theory only takes you so far.  
Later in the verification procedure and testbench I’ll be able to see whether my understanding was correct.

Cheers.

---Evening self-study---

Ah, since the Reservation Set is implemented as a register, it must include a CLK signal.  

As for output signals mentioned above from the Atomic Unit to the Control Unit,
we need Rsv_YN (Reservation Yes/No) to indicate success or failure.  

- [Output signal]
   - Rsv_YN,   
   whether access to the Reservation Set succeeded or failed.

-----

Verifying the LR.W datapath.  
Since the Atomic Unit’s Reservation Set is implemented as a register similar to the Register File, it will need a write-enable signal.  
Add Rsv_Write to the input signals. However, derive this signal from the DC_Atomic_MUX control.  
When DC_Atomic_MUX is enabled for an Atomic instruction—to drive RD1 as the address only in Atomic ops—then, likewise, we can enable writes to the Reservation Set register for that Atomic op.  

But… that would also write during SC.W. Inevitably we need a separate signal from the CU.  
Add Rsv_Write as an output from the Control Unit and an input to the Atomic Unit.

For LR.W… there’s really no need to output Rsv_YN. 
Whatever value it is, we won’t use it while executing that instruction anyway.

Move on to verifying the SC.W datapath.   
Uh. I separately fed RD1 via a MUX signal, but RD2 needs an ALU bypass?   
Well, bypass is fine; we never use RD2 as a memory address in this operation. 
Let’s do bypass.

Hmm… problem. We only compare on writes (i.e., when SC.W causes a memory write), but SC is a store, so MemWrite would already be asserted by default and we couldn’t conditionally enable it…  

Have the Control Unit, when the opcode belongs to the Zalrsc extension, drive MemWrite conditionally based on Rsv_YN.  

If that doesn’t work, a separate Control Unit… no. That’s the only viable way.

Wait. The Atomic Unit must know it’s an Atomic operation.  
By default, to see whether a write to an address in the reservation set is happening, the Atomic Unit takes MemWrite and ALUresult.  
When MemWrite is asserted, it compares ALUresult against the Reservation Set.  

However, when SC.W appears,  
assuming MemWrite is deasserted by default, there is no identifier that tells us we must compare in this case.  
Therefore, via a signal indicating “Atomic,” we must force comparison of Reservation Set and RD2.  
For this, add the DC_Atomic_MUX’s Atomic signal as an input to the Atomic Unit.  

Done… A-extension implementation success…
RV64IMA94F… Now I just need to add this to the 5-stage pipeline… hahaha…
That’s it for today!!!

![250428-RV64IMA94F](/diagrams/design_archive/ima_make_rv64/RV64IMA94F/[250428]RV64IMA94F.drawio.png)

### [2025.04.29.] 

While doing the 5-stage pipelining, most actions like registering the reservation set, invalidating it when executing SC.W, and comparing RD2 with the reservation set could be performed in the Instruction Decoding stage.   
This is because the Control Unit must immediately check upon fetch whether to enable MemWrite for SC.W through the Atomic Unit’s Rsv_YN, and because that control signal must be pipelined and take effect properly in the MEM stage.  

I’m currently pipelining Zalrsc behavior, and one issue has already come up. 
I think I only need to solve this one: if a separate Store occurs within the address range registered in the reservation set, that reservation set must be invalidated.  
In other words, I need to compare ALUresult (Data_Address) against the reservation set, but the comparison must happen only after a reservation has been made.  

If I compare the ALUresult value fetched in the MEM stage whenever MemWrite is asserted, then in terms of pipeline context, even if it’s outside the LR/SC sequence, a write within the LR-related address range would immediately cause invalidation from the Instruction Decoding stage’s perspective.   
That must not happen.

So I probably need a separate comparison unit for the reservation set in the MEM stage.  
And that comparison unit must share the reservation set with the Atomic Unit.  
Ah. Right. I can add a flag that says “LR and SC have begun, so start comparing,” to mark the start and end.  

Then I don’t need a separate comparison unit; I can keep the ALUresult output in the MEM stage wired into the Atomic Unit just like in the single-cycle implementation, and provide an identifier that LR/SC has begun and ended during the atomic operation.  

I shouldn’t use the Atomic_MUX signal (it’s also used by Zaamo and could be misinterpreted), so the CU should provide a separate flag signal.  
Alternatively I could feed opcode and funct7, but that would get too messy. I’ll add a dedicated signal in the Control Unit.  
That’s it for today.

![RV64IMA94F_5SP](/diagrams/design_archive/ima_make_rv64/RV64IMA94F_5SP/RV64IMA94F_5SP.drawio.png)

### [2025.04.30.]

I added the flag signal for LR.W and SC.W that I mentioned yesterday to the CU as LRSC_Flag, and also to the Atomic Unit.  

In the pipeline, the behavior for aq and rl bits must work a bit differently.  
When aq is set, the hart must stall execution of subsequent instructions until the A-extension instruction with aq completes, then resume.  
When rl is set, the hart must wait until all prior memory-access instructions complete before resuming the instruction with rl set.  

When the Control Unit recognizes that aq is set, it should hold PC_Stall while waiting for an identification signal in the WB stage that the aq-set instruction has completed.  
Similarly, when the Control Unit recognizes that rl is set, it should hold PC_Stall while waiting until all instructions prior to the rl-set instruction have completed up to the WB stage—in other words, insert a bubble.  

How to implement this…  
Pipeline the Atomic signal and carry it to the WB stage.  
Place a comparison module in WB; when Atomic is 1 and the instruction arrives, return an aq_done signal to the Control Unit to release PC_Stall.  
No, wait… if that’s the plan, I can just carry the Atomic signal to WB and feed it directly back to the Control Unit.  
I’ll do that.  

Then how about rl?  
How do I insert the bubble… The Hazard Unit already has flush capability per pipeline register, so I’ll implement it so that when the rl bit is set, using the flush function we issue a NOP, based on inputs of the Atomic identification bit, the rl bit at ID, and the rl bit at WB.  

Wiring the rl bit in WB now.  
That’s it for today.  
I spent some time reading the 2026 KAIST admissions guidelines that were just released.  

May is close; FPGA starts in June.  
Let’s wrap this up well.  

![RV64IMA94F.R1](/diagrams/design_archive/ima_make_rv64/RV64IMA94F/RV64IMA94F.R1.drawio.png)

![250430-RV64IMA94F_5SP](/diagrams/design_archive/ima_make_rv64/RV64IMA94F_5SP/[250430]RV64IMA94F_5SP.drawio.png)

### [2025.05.01.]

I was on duty. I’ve pipelined Zalrsc, and I’m in the middle of wiring the logic made yesterday to support the aq, rl bits.  

![250501-RV64IMA94F_5SP](/diagrams/design_archive/ima_make_rv64/RV64IMA94F_5SP/[250501]RV64IMA94F_5SP.drawio.png)

What remains now is to verify the datapath to ensure Zaamo works correctly.  
With that, the A extension will be finished, and I’ll move on to preparations for OS bring-up.   
At the very least… for the OS, I need virtual memory and I/O (including GUI). And while implementing those two, the privileged levels should naturally get implemented too…  
hmm…  

### [2025.05.02.]

Since the backend dev side hasn’t yet completed RV32I47NF, after finishing this Zaamo pipeline check I plan to jump back into backend and push quickly.  
The goal is to finish implementing basic_rv32s during this holiday stretch—by May 6.

Let’s begin!

Ah, right. Come to think of it, for Zaamo I included the D_RD signal in ALUsrcA…
In single-cycle, every unit can be used in the same cycle, so no problem.
But in a pipeline, before MEM, the EX stage cannot use memory-fetched data as an operand. The memory fetch has to happen in EX… this would be overstepping…

**~2025.04.13~**

If we execute AMOADD.W as `AMOADD.W rd, rs2, rs1`, it performs:  
R[rd] <- M[rs1]  
M[rs1] <- M[rs1] + R[rs2]  

First M[rs1] is written to R[rd], then M[rs1] is updated with (old M[rs1] + R[rs2]).

I considered placing a Zaamo-only ALU in a separate MEM stage, but concluded we can’t recover the one-cycle loss.  
Placing an ALU in MEM is effectively, for Zaamo only, moving EX after MEM (or merging the two)—a dynamic pipeline arrangement.  
Normally it’s IF/ID/EX/MEM/WB, but for Zaamo, EX would have nothing to do in the middle, so it would just pass through and become IF/ID/MEM/EX/WB.  
The problem is we haven’t implemented such “skips.”  
So instead of dynamic rearrangement like IF/ID/MEM/EX/WB, it becomes IF/ID/bubble/MEM/EX/WB—incurring a one-cycle penalty.  
If we did implement dynamic rearrangement, we could avoid that penalty and even gain performance versus the baseline datapath, but there isn’t time now to attempt such a non-standard approach. So, another path:  

Use PC_Stall.  
When a Zaamo instruction is recognized, have EX assert a signal to the CU to PC_Stall.  
Hold the Zaamo in EX; on the next clock, proceed to MEM.  
When the memory source appears in MEM, feed it back into EX and simultaneously release PC_Stall.  
Then we return to the original order: EX-stage ALU computes, passes the result to MEM, and commits in WB.  

In short, based on core pipeline principles, we accept a one-cycle loss but proceed without adding hardware resources.  

I’ll go with this. I already have stall/flush logic per pipeline register.  

Done! RV64IMA94F_5SP.R1, 23:56; KHWL2025!!

![RV64IMA94F_5SP.R1](/diagrams/design_archive/ima_make_rv64/RV64IMA94F_5SP/RV64IMA94F_5SP.R1.drawio.png)

### [2025.05.03.]
Today, before starting Verilog development for RV32I47NF, I’m going to organize the logic and explanations of each module in the processor design I’ve built so far.  
Once that’s done, I plan to jump into backend. The reason to do this now is clear: later on I kept running into “huh, why does this signal exist again?” even while the project was underway.

I’ll start from RV32I37F and add on.  
Each architecture had additions/changes to module roles, so I need to be careful about that.  
Start! (10:23)  

![RV32I37F.R4v2](/diagrams/core_architectures/RV32I37F.R4v2/RV32I37F.R4v2.drawio.png)

20:48 Done… a 10-hour task…  

Based on this, I just need to create documents on the modules that changed from the original when moving to 43FC, plus any added modules.  
Probably… I can finish the docs tomorrow morning and jump to backend in the afternoon.  

I’ve wrapped most of it up through 43F. I really might be able to finish tomorrow… right? That’s it for today. 23:59.

### [2025.05.04.]

I finished documenting up through 43FC. But I found an issue and we went into a meeting around 20:00.  
The root cause was designing the Data Cache miss signal as the control for DM_Addr_MUX in the Data Cache–Memory structure.  
The resulting problem is as follows.  

1. Read attempt (address 0x1111_1111)  
   Data cache: let’s look it up.  
   Data memory: let’s look it up.  

2. Cache: oh, it’s a cache miss.  
   -> The address that had been driven to memory automatically switches to WB_Addr.   
   SAA is interrupted mid-way.

Memory: huh?? What, you want me to fetch WB_Addr?  
-> It fetches the value at WB_Addr as is.

In other words, this is an issue caused by SAA.  
If DM_Addr_MUX is simply set to WB_Addr on DC_Status = Miss,  
then instead of fetching data at ALUresult as the address, it fetches data at WB_Addr.  

My fix for this: build a 1-bit FSM in data memory.  
Read.  
Cache and memory access the address via SAA.  

Cache miss!  
-> Send the cache-miss signal to both D_RD_MUX and Data Memory.

D_RD select MUX chooses DM_RD.

Data Memory access… address in progress… complete!  
DM_RD fetched and cache miss detected!  
-> DM_RD has been fetched, and the cache miss is detected.  
flag rises, enter write-back mode.  
Since both conditions are met, switch to Write-Back mode (set the FSM bit to 1).

WB_Addr input, WB_Data wrote.  
Set Data Memory’s Address MUX to WB_Addr input.  
Complete Data Memory write-back (C2M).  

Back to normal mode (set FSM bit back to 0. DM_Addr_MUX switches back to ALUresult).

The above logic is under review, and CC84 proposed an idea.  

#### Meeting 

> CC84:  
Even if the value at flush_address is fetched, the control unit has already stopped PC updates anyway, so it shouldn’t be a problem.

KHWL:  
LW instruction. R[rd] = M[R[rs1]]

- CLK1.

   - SAA. Simultaneous address access by cache/memory.  
Cache miss, Not Ready, PC_Stall.  
D_RD selects DM_RD.

   Data Memory should output the correct data.  
   But since DM_Addr is using WB_Addr due to the cache miss, it outputs data based on WB_Addr.  
   -> R[rd] = wrong M[R[rs1]].  
   At the same time, the cache also receives incorrect data based on WB_Addr.

   The data cache outputs the dirty block and its address to the Write Buffer for flush to DM.

- CLK2.
   - DC Status is still Miss.
   - Not Ready, PC_Stall ongoing.
   - DM_Addr is still receiving WB_Addr.
   - MemWrite is asserted, and the Data Cache is updated with the incorrect M[R[rs1]].
   - D_RD is still DM_RD, and the wrong data based on WB_Addr is being output.

   - DM_Not ready.
   - Write Buffer outputs WB_Addr and WB_Data to Data Memory. Write-back occurs in DM.   
   Flush to memory ends.

- CLK3.
   - DC_Ready, DM_Ready. PC_Stall is released. Instruction updates resume.

If there’s no flaw in this reasoning, the problem indeed occurs.

> CC84 option 1:  
When controlling the dm_address signal MUX, instead of using only hit/miss, combine it with cache_ready to control the MUX.

hit | cache_ready | select
:---:|:---:|:---
0 | 0 | flush_address
0 | 1 | alu_result
1 | 0 | x
1 | 1 | x

KHWL:   
The initial state is Miss and Not Ready; if you feed flush_address in that case, the memory fetch will be incorrect.

In the second cycle, the cache would have to become ready. 
Since the update happens in the second cycle, that’s when data at ALUresult should be fetched from memory, sent to the data cache, and simultaneously be the value written to the register.

But? There’s no case where the cache becomes ready in the second cycle.  
It becomes ready after the update, which means readiness becomes “effective” starting from CLK3.  

CLK3? DC and DM are Ready.   
Even if you switch back to ALUresult at this point, the data won’t come out of Data Memory. Why? Because PC_Stall was released and instruction updates resumed.

Considering the time cost of introducing extra logic just to preserve SAA, I’m reviewing dropping SAA.   
The above is the summary of a 1 hour 10 minute meeting.

For now, I’ll see how far I can get by tomorrow and then decide.  
Most of the logic is already implemented, and I’m told that aside from the cache issue, converting what was a 10-bit address cache structure into the specified 32-bit scheme should be mostly straightforward.  

### [2025.05.05.]

Aside from the cache structure issue (I marked the docs with [43FC]!!DM_Addr_MUX to indicate what needs to be corrected),
I finished structural documentation up through RV32I47NF. (17:27)  

I think I can wrap up RV64IMA94F within today.  
During evening study I’ll switch to backend with the goal of designing the Exception Detector and Trap Controller.  

Time to grab food.  

Finished through RV64I59F…  
RV64IM72F has no structural differences from RV64I59F.  

### [2025.05.06.]

#### Trap Controller Design
Let’s design the Trap Controller..

I can’t remember exactly what ECALL and EBREAK were supposed to do… let me dig through the notes.

##### - [EBREAK handling process]

1. [Detect EBREAK.]
   I_RD signal goes into Instruction Decoder and Exception Detector.  
   Exception Detector detects EBREAK. Outputs Trap_Status = 10.  
   Trap Control detects EBREAK via Trap_Status. Prepares to enable debug mode.  

2. [Prepare to enable debug mode.]  
   Trap_Control writes mepc and mcause into the CSR via CSR_Addr and CSR_Data (mcause; EBREAK code = 3).

3. [Run Trap Handler]  
   Trap_Control sets PC to mtvec from CSR.  
   CPU jumps to the Trap Handler routine to prepare debug mode.  
   The Trap Handler routine reads mcause and mepc from CSR to prepare interaction with the debugger.

4. [PC update stop sequence]  
   Trap Control enables debug mode. PCC stops outputting NextPC.  

5. [Debugging]  
   The external debugger sends the instruction add x7, x5, x6 via the debugger interface.  
   The debugger interface outputs that instruction to the Instruction Decoder.  
   CPU executes it. Register and memory values change according to the debugging.

6. [Exit debug]  
   The debugger finishes and executes mret.  
   The Trap_Control module fetches mepc and outputs it to the PCC so that PCC can output NextPC as mepc.

7. End.

Simplifying: ECALL = wait in PC-stall until mret executes.  
EBREAK = execute instructions from the debug interface.  

-----

Ah… implementing mret…   
On mret, we need to fetch mepc and send it to PCC so it can become NextPC…  
Likewise, send it via T_Target and then drop PC_Stall and Trapped—shouldn’t that do it?

Wait.  
To implement mret, we need to read mepc and pass it to PCC, and since SYSTEM instructions and CSR are controlled according to logic, it seems reasonable for the Trap Controller to handle it.  
But currently the Exception Detector doesn’t take funct7 as input.  
It only takes opcode, funct3, and raw_imm; with that, it can’t distinguish ECALL/EBREAK (same opcode/funct3) from mret.  
ECALL/EBREAK are each I-Type and can be distinguished by bit 0 of raw_imm, but mret needs bits 29 and 28 of funct7, so we must feed funct7 in.  

I included funct7 in the implementation, but I need to fix the diagram again.

!To-do  
Add funct7 to Exception Detector in the diagram.

-----

Instead of internally aligning and giving T_Target on misalign exception in the trap controller…  
it might be better to branch to an address of a handler routine that performs the alignment and returns.  
Then… how does mtvec behave again? direct vs vectored…  
No, using just one is fine.  
Enter a single Trap Handler first, then in that program code use a zicsr instruction to read mcause, determine what exception it was, and handle accordingly.  

Trap Controller Testbench Scenario

- Trap-handling instructions must be present starting at Instruction Memory address 10000.

- CSR mtvec and current pc should be provided as inputs (assumption).

- Declare $display for the trap_handle_state register so we can observe its changes.

Tomorrow I should implement the testbench for the trap controller.  
The code is fairly well-organized and I think I implemented the intended logic, so even if I test tomorrow there shouldn’t be major issues.  
It’s been a while since I wrote Verilog—syntax and all—feels nostalgic in many ways.  

On the cache side, it looks like verification via testbench is ongoing; the 32-bit conversion process itself seems to be going well.  
Starting today, I’ll set the cache aside for a bit and from tomorrow move to the 64-bit, M, and A extensions.  
There will be some edits needed, but nothing too hard, and since the logic is already established, assuming I follow and implement as understood, I’m setting the 64IMA extension deadline to the 12th.  

After that I’ll return to the cache structure to finish it, and I’ll also take on external-device interrupts or pipelining as a two-track approach.
And from May 27 to 31 there’s an FPGA implementation course at IDEC. After taking that, I’ll focus on FPGA implementation in June.

That’s it for today!

### [2025.05.07.]

##### Testbench day

Let’s go.

The cache implementation that had been ongoing up to yesterday is on hold after partial completion of the data cache.  
Just in case, here’s a note of the immediate cache issue:  
[Read, cache miss, lines are full, all lines are clean]  
We’ll perform two reads of 3333_3333.  

```
A: 1111_1111  LRU: old  
B: CCCC_CCCC  LRU: recently used  
```
On the first access, 3333_3333 misses. So A gets replaced.

At replacement, the A block that was old and a miss becomes hit immediately.  
Because the address is still being driven… why is this a problem again?  
Honestly, the MUXes up front are already controlling this, and on a miss, SAA already outputs the intended data via DM_RD, so it doesn’t seem like a big problem.

Anyway, since finishing the cache will require more verification time, I’m putting it on hold and doing the 64IMA extensions first.  
Today I briefed ChoiCube84 on my research to date regarding the A extension—Zalrsc, aq/rl bits, Zaamo.  
Today, ChoiCube84 will handle the 64-bit extension, likely starting in a separate repository.  
For now, docs stop here; I’ll code until evening study ends, then come back and push.  

#### Begin Trap Controller testbench implementation

What to observe in Trap_controller:  

- Changes in trap_handle_state  
- Address changes in csr_trap_address
- Value changes in csr_trap_write_data

Changes in trap_target address

Whether ic_clean is asserted on FENCE.I

On MRET, whether debug mode returns to 0  
Whether mepc is correctly output as t_target

On NONE, whether ic_clean, debug_mode are 0 and trap handle state is IDLE  

For now, the tb itself more or less works. I didn’t have time to check the waveform, but the values printed with $display appear as intended.  
Tomorrow I’ll do deep verification.  
Let’s go!

### [2025.05.08.]

#### Pre-Trap Handling procedure logic - PTH

I built the Trap Controller testbench scenarios during work hours.

I call the preparatory work done before branching to the Trap Handler address **“Pre-Trap Handling.”**  
This Pre-Trap Handling includes CSR mepc write and CSR mcause write.  
After that, by reading CSR mtvec we set NextPC to the Trap Handler address and branch there, or handle it inside the Trap Controller’s own logic.

Typically, exceptions/traps like ECALL, EBREAK, MISALIGNED end with mret in the TH (Trap Handler), so you can consider using MRET as part of the same bundle.

The scenarios are as follows.
```
ECALL - mret  
MISALIGNED - mret  
EBREAK - mret  
zifencei  
none  
```
For detailed input addresses and expected outputs, see the Trap_Controller_tb.v file.  
I wrote everything out in comments, one by one.

I rewrote the Trap_Controller testbench directly, built scenarios, and I’m verifying.  
Originally the FSM only had three states: IDLE – WriteMEPC – WriteMCAUSE.  
That worked because execution starts in IDLE; then write mepc; and if write mepc, proceed to write mcause, and return to idle.  
But in back-to-back Trap Controller interventions, this tangles the FSM.  
And if signals keep coming in, I observed in vcd that the current situation gets re-recognized and the FSM cycles again.  
So I added a terminal READ_MTVEC state so that on the next instruction update we return to IDLE and can run from the start again.

Also, it takes 3 cycles total from trap occurrence to control, during which the PC must be frozen, and we also need additional write control for the CSR File.  
But only the Trap Controller knows when writes to the CSR File occur, so the TC should send a write enable signal to the CSRF, and in the top we should OR the CU and TC write-control signals so that CSRF write is enabled.  

Similarly, during Pre-Trap handling, the PC must not update; I think we should add a Trap_Done signal to the CU.  
Ugh. Pipelining this will be a headache.

23:43. Everything works correctly according to the scenario test cases.  
I need to apply the above modifications.  

!To-do
- Add Trap_Done logic to the Control Unit
- Add CSR_WD (CSR Write Enable) signal to the Trap Controller
- In the soon-to-be RV32I47NF top module, OR the CSRF write-enable signals from TC and CU and feed as CSR_Write.  

That’s it for today! Ahh, it feels good to see code working well again after a while.  
I should aim to build RV32I47NF by tomorrow.  
Let’s do it.

### [2025.05.09.]

When should I drive Trap_Done to 0 for Pre-Trap Handling…  
When trap status is detected?  
When trap_Handle_state is IDLE?  
Once PTH runs, it doesn’t go back to IDLE unless it’s MRET or NONE…  
After the final mtvec read or after internal logic completes, bring it back to 1.  
Wait. If Trap_Done is driven in IDLE, then when it’s not a TRAP situation…  
Ah, the case statement only runs after TRAP is detected anyway, so even if it’s IDLE before detection, it’s fine.  

I’ll first implement trap_done <= 1'b0 in the IDLE: begin block and trap_done <= 1'b1 in the WRITE_MCAUSE: begin block, then run the tb.  

If it doesn’t behave as intended, I’ll move trap_done <= 1'b1 into a new READ_MTVEC: begin block and include it there.

Now it’s 0 only in IDLE, and 1 in WRITE_MEPC, WRITE_MCAUSE, READ_MTVEC…

I moved trap_done <= 1'b1 into WRITE_MCAUSE (or READ_MTVEC for other cases), and
I wrote trap_done <= 1'b0 directly where trap_status is set, not in the trap handle state.  
With this, trap_done goes to 0 during Pre-Trap Handling, and rises back to 1 at TRAP_NONE next, which is as intended.

But… doesn’t PTH’s last state need to rise back to 1 so PC updates can proceed?  
If it stays 0 until the end, there won’t be a next instruction and it won’t proceed…
Right now, the tb is driving the next scenario, so it looks like it flows, but that’s not right. I should fix it.  

Or not.  
For safety I gave 5 clocks to the first ECALL scenario even though ECALL needs 3 clocks;  
after the fix, with Trap_handle_state stuck at 11, Trap_Done also rises to 1 as is.
The problem is EBREAK… in the waveform, THS goes to 10 (WRITE_MCAUSE), rises to 1, then drops back to 0. Why… I need to run it again and check.

Driving trap_done to 1'b1 explicitly in WRITE_MCAUSE fixes it.  
Even with one extra slack cycle it stays 1 correctly, and with exactly 3 cycles it returns to 1 on the next.

Huh, the waveform shows csr_write_enable = 1 on MRET… why?  
—The waveform file was old…

Added TC’s Trap_Done and CSR_WE output signals and finished tb.  
Added CU’s Trap_Done input signal (for PC_Stall) and finished tb.  

I’m on duty tomorrow… I should figure out approaches for OS and virtual paging support.  
On Sunday I’ll move into designing the RV32I47NF top module.  
Fighting!!!

### [2025.05.10.]

I was on duty, and to find a lead on guidelines for hardware support for virtual paging, I started reading “Computer Organization and Design.”  
Below is a transcription of what I wrote in my notebook.

#### -Architecture changes-  
When adding the “M” Extension, ALUresult must be 128-bit [127:0].  
In computer multiplication algorithms, the product of a multiplicand and a multiplier has up to n+m bits for n-bit and m-bit operands.  
So, as described in RISC-V, the result has 2 × XLEN bits.  
-> In COD 5e, it says if the sign bit is ignored, the size is n+m bits, but in the RISC-V Unprivileged Architecture Manual I, it’s specified simply as length 2 × XLEN bits.  

> “MUL performs an XLEN-bit × XLEN-bit multiplication of rs1 by rs2 and places the lower XLEN bits in the destination register. MULH, MULHU, MULHSU perform the same multiplication but return the upper XLEN bits of the full 2 × XLEN-bit product.”

So is handling of the sign bits left to design discretion?  
The ISA ought to define this…  
Well, given that COD 5e references MIPS and RISC-V is fundamentally different (e.g., flag usage), that may explain it.

In any case, I’ll ask ChoiCube84 about two options:  

1. Provide a separate 128-bit result signal for multiplication.
2. Extend the existing ALUresult signal to 128 bits; for legacy XLEN-wide results, output zero-extended.

Option 1 doesn’t make sense—the modules needing 128-bit data would have to be audited separately, with per-instruction identifiers and logic.  

So option 2…

Oh right—RISC-V “M” extension splits the instructions so you can fetch either the lower or upper XLEN bits with different opcodes as needed…  
Then I can keep ALUresult as 64 bits (XLEN) with no structural change, as I originally thought.  

#### -Architecture changes 2-
Privileged Architecture research.  
Notes.

3 privilege levels  
Machine level, Supervisor level, User level

4 privilege modes  
Debug mode > Machine mode > Supervisor mode > Hypervisor mode

Level and mode are often used interchangeably.

---

Prefixes for Privileged Architecture extensions.  

- Machine level: Sm  
- Supervisor level:

  - Supervisor-level Virtual memory architecture: Sv
  - Supervisor-level architecture: Ss
- Hypervisor level: Sh

---

##### Machine-level Privileged Extensions

- Sm state en (Smstateen): State Enable extension
- Sm csr ind (Smcsrind): Indirect CSR access
- Sm e pmp (Smepmp): Enhanced PMP (Physical Memory Protection)
- Sm cntr pmf (Smcntrpmf): Counter Privilege Mode Filtering
- Sm r n m i (Smrnmi): Resumable Non-Maskable Interrupts **Frozen Specifications**
- Sm c deleg (Smcdeleg): Counter Delegation

##### Supervisor-level Privileged Extensions

- Sv32, Sv39, Sv48, Sv57: Page-Based 32, 39, 48, 57-bit Virtual Memory System

- Sv n a p o t (Svnapot): Naturally Aligned Power Of Two translation contiguity

- Sv p b m t (Svpbmt): Page-Based Memory Types

- Sv inval (Svinval): Fine-Grained Address-Translation Cache Invalidation

- Sv ad u (Svadu): A/D Bits hardware Updating

- Sv v ptc (Svvptc): Eliding Memory-Management Fences on making PTEs Valid

- Ss state en (Ssstateen): State Enable

- Ss csr ind (Sscsrind): Indirect CSR access

- Ss t c (Sstc): Supervisor-mode Timer Interrupts

- Ss c of pmf (Sscofpmf): Count OverFlow and Privilege Mode Filtering

---

##### RISC-V Privileged Instruction Set Listings

- Trap-Return Instructions

  - SRET: Supervisor-level trap-RETurn
  - MRET: Machine-level trap-RETurn
  - MNRET: Smrnmi’s return instruction **Frozen Specifications**
- Interrupt-Management Instructions

  - WFI: Wait For Interrupt
- Supervisor Memory Management Instructions

  - SFENCE.VMA

---

##### RISC-V CSR Address Mapping Conventions

- CSR = 12-bit [11:0]

   - [11:8]  : Read/write accessibility by privilege level
   - [11:10] : Whether the register is read/write or read-only
   - [9:8]   : Lowest privilege level that can access the CSR.

---

Unlike the Unprivileged Architecture, which introduces additional instructions via extensions, the Privileged Architecture regulates the data in each CSR and the extensions that must be supported.  
Privileged Architecture instructions are all encoded with the SYSTEM opcode and fall into two families:

1. Zicsr: instructions that atomically read-modify-write CSRs.
2. The other Privileged Instructions

   - At the supervisor/debugger side there are four: SRET, MRET, WFI, SFENCE.VMA.

Since the OS or kernel reads CSRs and performs actions accordingly, the Privileged Architecture feels like mapping the necessary info as “extensions” so software can use them.

For example: if bit 11 of CSR 0x0FF is set and we try to execute instruction A?
If that bit implies hypervisor, but the instruction is for machine mode, then access denied—raise exception.
Something like that.

If my understanding is correct, conceptually it’s not hard, but in terms of workload it’s not exactly easy.  
We need to implement exception conditions for each extension accordingly,
set each CSR’s values to fit our spec, set per-CSR logic per WLRL/WARL rules… lots to audit in the Privileged Architecture.

## RV32I46F Design

### [2025.05.11.]

Today was supposed to be RV32I47NF top-module design synthesis.  
I planned to do synthesis and then come back to the docs.  

But first I need to reflect the diagram changes that arose while implementing the Trap Controller and Exception Detector.  
Due to the temporary halt on the cache, I also have to reflect the memory-structure change for the RV32I47NF.R1 I’m about to synthesize.  
Since dropping the cache means I can’t support Zifencei anyway, rather than naming it RV32I47NF_noCache, **I’ll just call it RV32I46F.**  

1. Added funct7 to ED — done
2. Added Trap_Done to CU — done
3. Added CSR_WE to TC — done
4. OR’ed the CSR_WE signals from TC and CU — done

Those were the changes. I applied all of them.

![RV32I46F](/diagrams/design_archive/RV32I46F/RV32I46F.drawio.png)

Now I’ll switch branches to design the RV32I46F top module.  
Uh… I renamed the branch that implemented the Trap Controller (feat/exception_detector) to “Trap Controller,” pushed, opened a PR, and merged into develop.  
To do RV32I46F on a new branch, I should branch off develop with those changes already merged… for now I’m separately developing a file parser.  
It should be fine; I’ll probably PR it tomorrow.  

Other than updating diagrams, tweaking GitHub branches, and signing up for arXiv, I didn’t do much…  
Oh, the research notes I left yesterday… hmm…  

I want to do more tomorrow, but I’ve also got cooking-support duty, so I’ll just go as far as I can.  
Let’s do our best.  
That’s it for today.

### [2025.05.12.]

Come to think of it, I… didn’t actually add funct7 to the Exception Detector.  
I updated the diagram, but I missed the actual Verilog change. I’ll do this and then merge.  

After that I’ll build RV32I46F… let’s do it right.  

Turns out I misread the branch and just thought I hadn’t added funct7 to ED.  
Looking at the commit history, it was the very first thing I implemented… haha.  

I created the RV32I46F top module, and while declaring signals I noticed the Trap Controller’s reset signal is named rst. 
It shouldn’t be the odd one out, so I’ll spin up a new feat/trap_controller branch to fix it and then merge again.  

I also realized I hadn’t implemented the Debug Interface module.  
I implemented CSR_Addr_MUX and CSR_WD_MUX, and I OR’d the CU’s write-enable with the TC’s write-enable to drive the CSR write enable input.  
While doing that, I hit the question of where the instruction fed into ID comes from in debug mode—Instruction Memory or Debug Interface.  
So the Debug Interface needs to output a [31:0] instruction signal with a clear name to derive and wire signals; I noticed this was missing.  
I’ll add it. I’ll probably finish the RV32I46F top-module design before evening study ends today!

?Question I see Instruction Memory automatically takes the PC address with its lower 2 bits aligned to 00…  

```verilog
always @(*) begin
   instruction = data[pc[31:2]];
```

end

But now in the RV32I47NF (RV32I46F) design I formally handle misaligned exceptions. Should I remove this structure, or leave it as-is?

**!Notes**

Problem…  
For this design I planned a lightweight Debug Interface that simply outputs a fixed instruction (an input device from the core’s perspective) to fetch something like 0xABADBABE into a register.  
But to write 0xABADBABE into a register, I’d have to clear that register first (shift instruction), then add the whole value (ADDI).  

Sure, using the initial testbench value of x22 I could compute a single ADDI that lands on ABADBABE, but that runs counter to the spirit of a debug interface that shouldn’t “know” internal state up front.  

Even with a single instruction, issues appear. With two instructions the problem is this:  
> Because of memory semantics, values are fetched based on inputs.

So the debug instruction execution must be recognized and fetched in sequence, cycle-aligned.  
And this must include midstream halt on PC_Stall.  
The module complexity is higher than I expected.  

How can I force a fixed value the simple way…

Ah! In the top module I can just declare a signal and set its contents to a fixed constant—encoded as a 32-bit instruction!  
Ha. Such a simple fix.  
This won’t let me run two instructions in sequence though… and I do want two…  

Since SLLI and ADDI can be handled in single cycles, I’ll just output one at a time, clocked in sequence.  
On an FPGA I’d probably drive this with a button.
```verilog
always @ (posedge clk) begin
   instruction = data[pc[31:2]];
end
```
The current Instruction Memory code is like this… To change it stepwise per clock… I’ll add a counter.

Done.

I should’ve finished today…  
Sigh… tomorrow morning I’ll finish the Debug Interface testbench, and in the afternoon I’ll finish the RV32I46F top module and its testbench.

### [2025.05.13]

This way the Debug Interface keeps running even when it’s not used, so I’ll just do the simpler thing… implement it as an add on the current x22 value—by adding a signal in the top module.  
And to construct ABADBABE by 12-bit imm ADDIs I’d have to keep adding; that’s cumbersome and inflates the instruction count.  
The Debug_Interface as implemented so far will be redesigned later, so I’m pausing the module and wrapping feat/debug_interface here.  
No need to merge into develop; in cases like this I’m not sure what’s best. Given the shape will change a lot, discarding it might be right.  
I’ll keep it for now just in case.

I’ve copied the exact Trap Controller testbench scenarios into Instruction Memory.

#### Trap_Handler

- Trap Handler start address. mtvec = 0000_1000 = 4096 ÷ 4 Byte = 1024  
- On entry we should store the original GPRs into a separate heap area and proceed, but we’ll omit this for now.  
- Read CSR mcause: if ecall, set x1 = 0000_0000; if misaligned, add FF to x2  
- Then mret

#### Write this in RISC-V assembly…
```RISC-V
// Prep loads for conditional branches/comparisons  
csrrs x6, mcause, x0   // load mcause into x6
addi x7, x0, 11        // load ECALL code 11 into x7 (to compare mcause we need 11 in a register and compare regs)

// Analyze mcause and branch to the relevant Trap Handler
beq x6, x7, +12        // ECALL; if x6==x7, branch to address +12 bytes = data[1029]
beq x6, x0, +16        // MISALIGNED; if x6==0, branch to address +16 bytes = data[1032]
jal x0, +16            // End TH (jump to mret code address)

// ECALL Trap Handler @ data[1029]
addi x1, x0, 0         // clear register x1
jal x0, +8             // End TH (jump to mret code address)

// MISALIGNED Trap Handler @ data[1031]
addi x2, x2, 255       // add 0xFF to x2 (BC00_0000 -> BC00_00FF)

// ESCAPE Trap Handler @ data[1032]
MRET                   // PC = CSR[mepc]
```
#### Encode that assembly to binary and load into Instruction Memory.
```RISC-V
// Prep loads for conditional branches/comparisons
data[1024] = {12'h343, 5'd0, 3'b010, 5'd6, `OPCODE_ENVIRONMENT};
	data[1025] = {12'd11, 5'd0, `ITYPE_ADDI, 5'd7, `OPCODE_ITYPE};

// Analyze mcause and branch to the relevant Trap Handler
data[1026] = {1'b0, 6'd0, 5'd7, 5'd6, `BRANCH_BEQ, 4'b0110, 1'b0, `OPCODE_BRANCH};
data[1027] = {1'b0, 6'd0, 5'd0, 5'd6, `BRANCH_BEQ, 4'b1000, 1'b0, `OPCODE_BRANCH};
data[1028] = {1'b0, 10'b000_0001_000, 1'b0, 8'b0, 5'd0, `OPCODE_JAL};

// ECALL Trap Handler @ data[1029]
data[1029] = {12'd0, 5'd0, `ITYPE_ADDI, 5'd1, `OPCODE_ITYPE};
data[1030] = {1'b0, 10'b000_0000_100, 1'b0, 8'b0, 5'd0, `OPCODE_JAL};

// MISALIGNED Trap Handler @ data[1031]
data[1031] = {12'hFF, 5'd2, `ITYPE_ADDI, 5'd2, `OPCODE_ITYPE};

// ESCAPE Trap Handler @ data[1032]
data[1032] = {7'b0011000, 5'b0, 5'b0, 3'b0, 5'b0, `OPCODE_ENVIRONMENT};
```
I’m told the convention for read-only CSR access is CSRRS with rs1=x0…  
An assembler directive like csrr x5, mcause is auto-encoded as csrrs x5, mcause, x0, and csrrw modifies rd, etc.

Anyway, done. I haven’t actually run the tb to confirm the instructions emit correctly—so I’ll run it, then create a new feat/rv32i46f branch and proceed with tb.

Given there’s only one debug instruction, it must be at the very end of the testbench scenario… I’ll move it.

Ah, I must need a break. It was already in that position—I forgot again.  
I’ve been at this for hours straight. I’ll pop over to the PX, get ChoiCube84’s PR approval, and then switch to the RV32I46F top-module testbench. (15:07)

*Getting comfortable with Verilog. Declaring and instantiating signals in the top module led to a bit of reflection.*

Module-to-module connection signals should be wire; signals whose values change should be reg.

And instantiation syntax goes roughly like this:
```verilog
[ModuleToInstantiate] [instance_name]   (
   .internal_signal (top_level_signal_name)
)
```
## RV32I46F Top module Debugging

Why did ECALL get recognized correctly, mepc (CSR 341) got the current PC written, but the next PC didn’t stall and instead updated to 0000_0000…  
pc_stall… becomes asserted not at 0000_00BC (ECALL) but the next cycle…? Is that it?

Originally, on TRAP occurrence during PTH I set trap_done to 0, but since TC sets trap_status != 0, trap_done should be 0 for all instructions anyway.   
Maybe I should set trap_done in the case statement itself rather than per-case.

Tried that, but Verilog disallows writing something before the case condition declaration.

Previously I only drove trap_done <= 0 at the start of each FSM state and assumed it would persist, then set trap_done <= 1 at the end of the FSM.  
Now, except for the final FSM stage, I put trap_done <= 0 into every FSM state.  
I need to compare the new vcd with the old to see what differs…  

No difference in the traces… I’ll check the actual top module.  

Still no difference.  
To avoid unintended latches in the Trap Controller, I set trap_done <= 1 before the case(trap_status), but reset will assert anyway at start…  
And every case path drives trap_done explicitly, so it should be fine, right?  
I’ll re-run the TC testbench like this.

Same outcome, but I caught a different angle.

PTH’s activation itself is one cycle late… Why?  
How can I pull it one cycle earlier so PTH triggers in the same cycle trap_status arrives?

I made the detection logic combinational (always (*)) to monitor changes and kick off PTH immediately, and kept the FSM progression sequential (always (posedge clk or posedge reset)) so it recognizes and reacts right away.  

Some of the edge-registered logic might not fire…?  
But as long as PC_Stall happens, we’re fine… I’ll run the RV32I46F top module.

Wow, that works! But it didn’t branch to the mtvec address.  
Trapped asserted, trap_target looked good, pc_stall dropped properly… I’ll check the PC_Controller signals; maybe that’s where it is.

Right—next_pc wasn’t selected as trap_target. I’ll have to debug that.

Looked at PCC logic—still fine…  
Maybe the PC_Aligner is lingering and causing this; I removed it to check.

Reran the sim and looked closely: the instruction after AUIPC is a JAL that jumps to a misaligned address. That’s when the freeze happens.  
So next_pc must already be available while the current PC is executing… that’s how ED detects it.  
Maybe next_pc misalignment should be detected in PCC instead? Needs thought. If I fix this it might resolve the issue. That’s it for today.

### [2025.05.14.]

I had duty.

I studied general syntax with Palnitkar’s “Verilog HDL: A Guide to Digital Design and Synthesis,”
and I organized the current RV32I46F debugging progress.

**RV32I46F Debug Log**

#### Situation 1.

Trap Controller triggers fine. 
But PTH only proceeds to the first FSM stage and doesn’t branch to mtvec.  
In the waveform I saw PC restart from 0.  
— Upon recognizing a SYSTEM instruction, PTH starts from the next cycle.  
Because of that, trap_done goes 0 → pc_stall, and PTH should proceed—but it doesn’t.

So PTH must begin in the same cycle the SYSTEM instruction is identified.

#### Situation 2.

I synthesized the Trap Controller’s trap_status condition as combinational logic (always (*)) so PTH begins immediately on trap_status input.  
Previously everything ran on posedge clk (always (posedge clk or posedge reset)).
The internal FSM update logic remains sequential.  
— In the Trap Controller testbench I confirmed PTH now begins immediately upon detecting trap_status, as intended.

#### Situation 3.

In the RV32I46F top-module testbench, I confirmed via waveform that PTH proceeds through the last stage (reading mtvec).  
But still, PC does not branch to the Trap Handler at 0x0000_1000.  
Trapped asserted, trap_target looked correct, pc_stall deasserted—still no branch. I suspected PCC.  
I confirmed next_pc wasn’t selected as trap_target. PCC logic itself looks fine.
— I removed PC_Aligner in case it was interfering.

#### Situation 4.

I found the RV32I46F top-module testbench doesn’t stop.   
It hung at 29500 ms; I forced stop and inspected the waveform.  
The instruction after AUIPC is a JAL that jumps to a misaligned address. That’s where it freezes.  
So next_pc must already be produced while the current PC is executing, but since it wasn’t, ED didn’t detect it and we went to a misaligned PC.  
Maybe next_pc misalignment should be detected in PCC. Needs investigation.

## RV32I46F 29500ms issue debugging

### [2025.05.15.]

Why…  
Did it really go to a misaligned PC in the first place?  
PCC itself is combinational, so it’s not a clocking issue, and ED also takes next_pc combinationally and should flag immediately.  
So it should flag immediately…?

JAL itself is fine. The issue is that the next_pc after it is misaligned.  
If JAL changed next_pc to jump_target successfully, and ED detected the misalignment, then PCC should receive Trapped and switch next_pc to trap_target.  

Oh.
Because we’re executing JAL, Control Unit keeps asserting jump, making next_pc = jump_target; at the same time, `trapped` is asserted, making next_pc = trap_target. That’s a race condition.  

On top of that, `trap_target` (the Trap Handler’s entry) is produced at the last PTH FSM stage, and while that runs, Trap Controller keeps trap_done = 0, so Control Unit outputs pc_stall. Now next_pc = pc also contends with the two above.  
How do I resolve this… this seems like the problem.

In short,

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

How to fix?  
Late at night in the barracks I read Palnitkar looking for answers in Verilog semantics.  
To check tomorrow:  

1. Can tri/trireg and drive strengths address the race?
2. Can blocking/non-blocking assignments and timing controls (event-based, level-sensitive) resolve it?
3. Can zero-delay techniques resolve the race?

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

I peeked at the top module: even putting PC_Aligner back and letting it pass through, the trap scenarios for TC/ED verification still don’t select next_pc = trap_target properly. Where did this go wrong…

### [2025.05.16.]

I was on duty.  
And as always, I found a thread that could lead to an answer.  
While thinking through the problem during duty, I tried clearing my head and redrawing RV32I46F’s diagram from the left (starting at the PC) by hand, and suddenly it hit me.

#### Approach A to resolving RV32I46F’s 29500 ms issue.

The PCC logic is simple and already solid. Maybe the key lies in the Control Unit, which is the source of the PCC control signals.  
In other words, if we prevent all overlapping signals from being sent to the PCC at once, we can eliminate the race condition itself.  
Either use conditionals on the PCC control signals so that only one of them is asserted, or send a single unified PCC control signal to the PCC.

#### Solution plan A-1 for the RV32I46F next_pc race condition

After the Control Unit decodes an instruction, do not drive jump, trapped, and pc_stall as separate signals to the PC Controller.  
Provide the PC Controller with an opcode-like pcc_op signal—i.e., a PC Controller operation code—so that the PCC determines next_pc from just one control input.  
*This is the moment it clicks why modern systems employ μ-opcodes; micro-ops. Of course the main reason is to graft RISC-like traits to overcome CISC limits, but still, it makes sense here.*

It took three days just to pinpoint the problem, and two more days to arrive at this answer.  
I’ll apply it tomorrow as-is. It should work.

### [2025.05.17.]

Nope, it doesn’t.  
The problem is unchanged. It’d be nice if at least something had shifted, but depressingly not a single result bit moved.  
In standalone testbenches for the Control Unit and PC Controller with pcc_op integrated, there were no issues—even with race-condition tests.  
What’s wrong… what is it…

![RV32I46F.R3](/diagrams/design_archive/RV32I46F/RV32I46F.R3.drawio.png)

Back to the beginning.  
What if this isn’t a race condition problem?  
With the old PC_Aligner in place, next_pc was auto-aligned and execution proceeded correctly.  
Is the problem in the Program Counter register that next_pc feeds into?  
Is next_pc getting into the Program Counter but then not taking effect?  
It’s such a simple module… could it really be the culprit?  
Ah.

#### Approach B to resolving RV32I46F’s 29500 ms issue.

The program counter only samples on posedge clk.  
> “What if, instead of basing the misaligned check on next_pc in the Exception Detector, we compute misalignment in the PCC based on the candidate address source that would be selected?”  

I can’t believe I overlooked such a fundamental structural point.  
This isn’t a big-company setup with one person per module; I’m solo tracking dozens of modules and hundreds of signals, so mistakes like this are hard to avoid.  
The current design judges misalignment based on next_pc.  
It looks at next_pc and, if misaligned within the same clock, it assumes we can trap or stall and thus “change” the PC value.  
But the program counter only holds a value captured on posedge clk.  
Which means once a misaligned value is presented and we try to trap and fix it, the misaligned PC has already been latched, and we can’t change the current PC for that cycle.  
And changing this clocked update scheme would introduce stability risks.  
So the program counter should stay as-is. We need a different exception-handling scheme.  
Should I place a checker—not an aligner—there to detect misalignment? That feels messy.  
What if, instead of the Exception Detector judging next_pc, the PCC computes misalignment based on whichever address source it’s about to select?  

Have the PC Controller detect a misaligned jump_target and self-issue pc_stall by holding next_pc = pc.  
Then the Exception Detector can simultaneously recognize the misaligned jump_target and proceed with PTH normally. (20:32)  
Let’s implement it right away.

It works… (20:35) I made the PCC self-stall the PC, and the simulation no longer freezes.  
The 30th instruction shows up cleanly in the waveform…  
Now I’ll wire the Exception Detector signals so PTH actually runs.  

We need to detect misalignment for all branch targets, not just jump_target.  
However, in the old 43F-based architecture, the PCC computed the branch target internally by adding the current PC and the immediate and directly output that as next_pc.  

`jump_target` arrives on the alu_result signal, so I could feed that into the Exception Detector, but with branching done inside the PCC I can’t observe branch_target misalignment.  
To fix this, rather than adding a separate Branch Adder/Calculator (which would get messy), I decided to embed branch-target computation inside the Branch Logic module.
Assuming that change in Branch Logic, I’ll update the Exception Detector.

PTH is entered properly!!!
The trap_handle_status FSM advances correctly and we branch to the Trap Handler address!!! (20:47)

But I must have encoded the CSR address wrong in the Trap Handler routine; it didn’t behave as intended.  
mret didn’t branch back to the mepc value.  
Still, that’s a small, clearly visible issue in the waveform—easy to fix.  

I’ll propagate the Branch Logic changes. New branch!  
Done. I added functionality so the Branch Logic computes the address only when the branch is taken.  
Now the Branch Logic takes PC and imm, computes the branch_target by addition, and outputs it.  
Testbench finished.  

Next, I’ll inspect and fix whatever’s wrong in the Trap Handler. instruction memory branch…  
In the Trap Handler starting at Instruction Memory data[1024], the goal was csrrs x6, mcause, x0, but I had encoded the CSR address as 12'h343, which threw off the program’s control flow.  
I corrected it to 12'h342, the actual CSR address for mcause. Then PTH behaved correctly. Everything works.

Ah, there’s still some issue with EBREAK. Earlier, pcc_op wasn’t applied correctly so we failed to branch to trap_target, but I fixed that.  
However, after EBREAK, the instruction inside the EBREAK handler should execute… but the debug instruction doesn’t appear. Why???  

That’s it for today… time’s up.

## RV32I46F EBREAK debugging

### [2025.05.18.]

Why won’t it switch to the debug instruction… why did the waveform stop at the PTH FSM stage where debug_mode should appear…  
The debug signal itself never goes high to begin with… why?

I poked through the code, tweaking bit by bit and checking.  
I fiddled in the top module—no luck—so I tried adding a MUX in the Instruction Decoder.  
Now the decoder takes both the instruction-memory instruction and the debug instruction, and it also detects debug mode.  
When I made the decoder do nothing in debug_mode, the debug_mode signal itself rose correctly, but decoding didn’t happen.  
Which is expected. But when I wrapped that in a conditional so it also decodes in debug mode—even if I just preset something like `opcode = 7'b0001100` inside—it freezes immediately at that timing. Something’s off.

Maybe it’s because I’m passing the control signal straight through?  
What if I add a separate toggle flag register and set it to 1 when the signal arrives?

Huh, strange. In the top module the debug_mode signal doesn’t show up in the waveforms for either the top module or the trap_controller, but the flag does rise at that timing.  
Something must be forcing the signal back to 0.  
I checked and found Trap Controller still had code that always defaulted debug_mode to 0.  

Since once debug_mode is active the debugger returns by executing MRET—and I already designed MRET to clear debug mode back to 0—I figured that defaulting wasn’t needed, so I removed it.  
Still not working… why…

---

On a hunch I changed the coding style.
Now it works…

Previously I had:

```verilog
if (debug_mode) begin
    instruction = dbg_instruction;
end else begin
    instruction = im_instruction;
end
```

I changed it to:

```verilog
if (debug_mode) instruction = dbg_instruction;
else instruction = im_instruction;
```

and it works…

If I use debug_mode directly there, it freezes again. Replacing it with the flag makes it behave.  
With that in place, an ECALL routes to the debug instruction, it decodes correctly, and the instruction executes.

I spun up a separate top module to debug everything end-to-end, so I didn’t jot notes in real time; I can’t fully capture the five-hour stream of debugging thought.
But with this, RV32I46F is complete.  

I also moved the Instruction Decoder’s MUX out into the top module and tried it—works fine.  
Done… 2025.05.18. 12:01.

![RV32I46F.R4](/diagrams/design_archive/RV32I46F/RV32I46F.R4.drawio.png)
![RV32I46F.R5](/diagrams/design_archive/RV32I46F/RV32I46F.R5.drawio.png)

## RV32I46F_5SP Design

### [2025.05.19.]

While managing branches, creating PRs, and merging one by one was consuming a lot of time and imposing constraints on the work, most of the debugging and implementation logs above were written while implementing in a dirty file (an integrated file that doesn’t leave a branch record).  
Today I reflected what should have been in the dirty file back into the main files and left git logs, but things that used to work stopped working, so I had to re-debug the already-working RV32I46F.  

The biggest issue was that in the Trap Controller I needed to distinguish between blocking and non-blocking assignments, but due to lack of skill I wrote them incorrectly when moving from the dirty file, which caused the problem.  
PTH wouldn’t run on ebreak, and switching to blocking assignments fixed it. I also hadn’t reflected some instruction changes in the Instruction Memory, so I applied those too.  
After confirming the top module works correctly on the current branch, I merged into the develop branch.  

Since ChoiCube84 is hospitalized and can’t directly develop right now, he handled code review. He pointed out that having the Branch Logic compute branch_target only when branch_taken wouldn’t really give power-efficiency gains or similar effects, so I looked it up and learned that this is a misconception at the RTL level and has negligible practical effect.  

So I changed the Branch Logic to:  
```verilog
always (*) begin 
   branch_target = pc + imm; 
end
```
and then immediately pass through a case statement by branch type, so that branch_target is always computed in all situations.

He also asked me to spell out variable names like j_target_lsbs in full, and I agreed—something I’d missed in the rush—so I fixed those.  
After that, I plan to document the 46F Architecture and then move on to the pipeline implementation.

I wrote the pipeline registers bit by bit during the morning while doing code review.  
On the diagram I found signals unnecessarily connected to pipeline registers (e.g., rs2 and rd on the ID/EX register, or connecting the IF stage’s PC to ID/EX), and signals that should’ve been connected but I forgot (e.g., the register write data source select signal should come out of EX/MEM and go into MEM/WB).  
I redrew those parts on the diagram, and finished defining the pipeline registers themselves.  
The amount of repetitive work was pretty eye-straining.

Done. Now only the documentation remains, and then all RV32I46F work will be wrapped up.  
Originally I planned to integrate the cache, but I’ll likely postpone it to June—once we’re into pipelining—and hand time to it as soon as ChoiCube84 is discharged.  
In my mind, pipelining felt a bit more “textbook” computer architecture, and I was going to use that as the reason to do it first, but while Patterson’s *Computer Organization and Design* does present memory and pipelining before cache, the cache hierarchy is also part of the “textbook” path, so it didn’t feel right to lean on that as a justification.  
If I finish the 46F design today, I’ll wire the signals coming out of the pipeline registers into each module.  
RV64I and the M, A extensions will come after pipelining.  

The deadline is about 7 days out and I’m on duty again tomorrow, so the schedule is tight, but it is what it is. I’ll just do what I can.  

--Evening study starts. (22:05)--

While writing the 46F Architecture specification, I found that—due to divergences between design and implementation—a number of signals were no longer used.  
I removed funct7 from the Exception Detector, and removed signals like MemRead from the Data Memory.  
In BE_Logic, I changed BEDC_WD to BEDM_WD (Byte Enabled Data Cache Write Data → Byte Enabled Data *Memory* Write Data), which was slated for the 47NF structure.
I named this RV32I46F.R5v2.  

![RV32I46F.R5v2](/diagrams/design_archive/RV32I46F/RV32I46F.R5v2.drawio.png)

Documentation of the 46F Architecture is complete.  
Phew. It really feels like it’s time to move on to the next step.  

> One completion isn’t the end.  
The futility of victory lies in the fact that, ahead of any victory achieved, a new victory awaits—and harsher trials than before must be endured to seize it.  
A bold leap toward that challenge is already a victory in itself,
and because it is a victory, the new challenge becomes a great one.  
— *Jonathan Livingston Seagull*, Richard Bach / translated by Kang Min-Woo

23:40… Time’s not generous, but I’ll push as far as I can.

I finished the first draft of the RV32I46F pipelined version diagram!

![RV32I46F_5SP](/diagrams/design_archive/RV32I46F_5SP/RV32I46F_5SP.drawio.png)
<sub>Printed day is wrong. It's likely 250519.</sub>  

That’s it for today, haha. Let’s keep charging ahead!!!

### [2025.05.20.]

I was on duty.  
Hmm… thinking about RV32I46F, I realize I likely overlooked that the data memory had been changed while we were moving to a cache-based structure and proceeded as-is.  
I should verify this.  

### [2025.05.21.]

Upon checking the top-module VCD, I confirmed that Data Memory was outputting 256-bit-wide data, making correct operation unlikely.  
So I created a new branch, feat/data_memory, added a separate data-memory module based on the older 43F Architecture, and split the cache-structured (43FC Architecture) data memory into a file named Data_Memory_For_Cache.v.  
In Data_Memory_tb.v (the testbench), not much changed—Read Data was switched from the prior 256-bit to 32-bit, and I left a comment noting that when we go back to a cache-based structure, we should match the block length.  

I’m organizing the design of the pipeline hazard units, extracting and summarizing notes from 2025.04.01.  

==========

#### Hazard Unit design

- [Inputs]
   - ID_rs1 (from Instruction Decoder)
   - ID_rs2 (from Instruction Decoder)
   - ID_rd  (from Instruction Decoder)

- [Outputs]
   - Hazardop (to Forward Unit)

- [Logics]
   - Compare whether instruction A’s rd equals instruction B’s rs1 or rs2.

After instruction fetch, rd, rs1, and rs2 become observable at the decoding stage.  
So, capture rd, rs1, rs2 from the ID stage, store them, and in the next clock cycle compare the previously stored rd with the freshly received rs1 and rs2.  
If equal, assert Hazardop to the Forward Unit so it can perform forwarding.  
At the same time, update the stored rd with the current rd.  

[Note]  
Hazard detection is the Hazard Unit’s original design goal.

1. Data hazard  
   When, due to dependencies between instructions, the current instruction must wait until a prior one finishes.  
   RAW: Read After Write. Since writes to memory or registers complete only after the prior instruction finishes, leaving “empty” cycles (and if the value hasn’t been written yet, program context is lost and results are wrong), we insert bubbles.   
   But bubbles alone hurt performance; since a prior instruction’s result is available before it’s actually written back, we forward that pre-WB value to the current instruction’s source.  
   This is the forwarding method, and this design implements it.

*We must know the dependencies between in-flight pipeline instructions.*  
Check whether the register address that must be written by a past instruction is referenced by the current one.  
Compare A’s rd with B’s rs1 and rs2.  

rd, rs1, rs2 are visible at the ID stage:  
capture ID-stage rd/rs1/rs2, compare the previously stored rd with the current rs1/rs2, and if equal, use forwarding.  
Then update the stored rd with the current rd.  

This tells us when a data hazard occurs.  
Signal this data-hazard occurrence to the Forward Unit, which actually performs the forwarding.  

#### Forward Unit design

[Inputs]

[Outputs]

[Logics]
Upon Hazardop indicating a data hazard, forward the prior instruction A’s result (the value that would eventually be written to the register file) to one of the ALU sources for the current instruction B, appropriately chosen based on B’s type.

**[Note]**

I saved the Hazard Unit and Forward Unit design notes under the 46F_5SP_Architecture folder.  

### [2025.05.22.]

And now, the end is near.  
Let’s implement the pipelines as actual files.  

- IF_ID Register
- ID_EX Register
- EX_MEM Register
- MEM_WB Register

I created all four pipeline registers, following the RV32I46F_5SP_R1 diagram.

![RV32I46F_5SP.R1](/diagrams/design_archive/RV32I46F_5SP/RV32I46F_5SP_R1.drawio.png)

I finished testbenches for the IF_ID Register and the ID_EX Register, and verified the reset signal, flush signal, and the “output current value on the next clock” behavior of the pipeline registers.  
Tomorrow I’ll write the testbenches for the EX_MEM and MEM_WB registers.  
That’s it for today. Even if I didn’t meet my quota, the testbenches ran well, so I’m satisfied. I can’t wait for tomorrow.  

### [2025.05.23.]

Personal maintenance time.   
I finished all the testbenches up through the MEM_WB register.  
20:06.  

Looking now, I realized I hadn’t pipelined the Write Enable signal for the Register File and the Write Enable signal for the CSR File.  
That won’t do. Since Write Back is literally the register write-back stage, this is logically inconsistent.  

For CSR, the Write Enable coming from the Trap Controller occurs during exceptional handling rather than normal program flow, so it should be flushed and executed immediately—direct connection is fine for that path.   
But for regular program instructions like Zicsr, the CSR Write Enable coming from the Control Unit should indeed be pipelined.  

Resolved. I added register_write_enable and csr_write_enable signals to all of ID_EX, EX_MEM, MEM_WB registers, and finished their testbenches as well.  
Next, from the existing RV32I46F I need to build the 5SP (5-Stage Pipeline) top module, wire up the pipeline registers and signals, and do a first-pass bring-up.  
Of course, since the instruction sequence will create data hazards between producer/consumer pairs, values will look odd, but the point of this first pass is simply, “does it run?”

20:46.

--Evening study--
Evening study. I’m catching up the devlog and now starting the first-pass top-module work mentioned above. 22:19.  

When placing those pipeline registers, the RV32I46F PCC op micro-opcode structure becomes problematic.  
It carries things like Jump and PC_Stall, and each control must arrive at PCC from different pipeline stages; making PCC decode one unified signal with precise timing separation explodes complexity unnecessarily.  
Since the earlier issue I mistook for a race condition turned out to be a PC characteristics issue rather than a pcc_op vs. overlapping controls issue, rolling back the PCC to the pre-pcc_op structure should still work.  
So I rolled PCC back to the older structure and kept the pcc_op versioned module around just in case for the future.  

Ah—while declaring pipeline registers in the top module I realized: if the Reg Write signal is pipelined, the write-address must be pipelined too, but I was simply feeding rd straight from decode. I fixed this by pipelining rd.  
I stubbed it in via top-module signal declarations; now I’ll jump back to the feat/pipeline_registers branch and add it properly…  
All added. Done. That’s it for today.

![RV32I46F_5SP.R2](/diagrams/design_archive/RV32I46F_5SP/RV32I46F_5SP_R2.drawio.png)

### [2025.05.24.]

Now it’s time to design the Hazard Unit, Forward Unit, and Branch Predictor.

I had removed PCC_op codes from the PC_Controller earlier; since the Branch Predictor will own the Branch Target address in the future, I removed the imm from the rolled-back PC_Controller and added a branch_target signal instead.

Let’s design the Hazard Unit.

Hazard Unit is fully designed.  
While designing the flush behavior, I paused to re-examine a few things.  

On a jump, or when branch prediction is wrong, pipeline registers must be flushed.  
The decision point is in EX, and information carried in EX/MEM and MEM/WB pertains to already-preceding instructions at that moment, so those must not be flushed. Hence, no flush signals are needed for those registers.  
(There’s no instruction that explicitly orders “flush this specific pipeline register,” either.)  

What’s left are IF/ID and ID/EX.   
If I flush ID/EX, I lose the in-flight EX-stage judgment context for the current jump/branch prediction decision, so ID/EX must not be flushed.  

Therefore, I decided to flush only the IF_ID_Register.  
(Of course, I’ll find out in the top-module integration if this needs tuning, haha.)

So the Hazard Unit design is done, and the testbench, too.  
While coding, I hit some friction with the hazard_op signal.  
Because it’s combinational, I typically set an initial hazard_op = 0; and then inside conditions set hazard_op = 1’b1;.  

But that yields only a momentary pulse in the waveform, and depending on the code it immediately returns to 0, leaving no time for the downstream logic to react.  

To solve this, I introduced a flag: use hazard_flag inside the conditional branches, and outside have hazard_op = hazard_flag so that even in pure combinational logic the value persists until the inputs change. I implemented it that way.

My previous RV32I46F single-cycle experience with debug_mode helped here.  
I could immediately infer that the lack of expected tb results was due to the pulse effect, and also be confident the logic itself wasn’t conceptually wrong.  
“Let’s try the flag trick from back then—since it worked then”—that hunch helped, too.  
It’s my own idea I haven’t seen written elsewhere, but I imagine others do something similar.

![RV32I46F_5SP.R3](/diagrams/design_archive/RV32I46F_5SP/RV32I46F_5SP_R3.drawio.png)

Evening study over.  
If not for weekend leave, I might have finished the 2-bit Branch Predictor as well…  
Still, I think I can make decent progress tomorrow.  

### [2025.05.25.]

Originally I planned to wire the pipeline registers into the top module first, then implement the other pipeline hazard modules and integrate.  
But for debugging efficiency, I decided to design all hazard units first and debug them together (higher difficulty, but I trust the architecture and I’m short on time).  
Yesterday I finished the Hazard Unit; now onto the Forward Unit.

While designing the Forward Unit, I realized I need identifiers to distinguish: does rs1 need forwarding due to matching a prior rd, does rs2, or both?  
So I expanded the hazard_op from the Hazard Unit from a single “data hazard occurred” bit to 2 bits: bit 0 indicates an rs1 hazard, bit 1 indicates an rs2 hazard. I updated the Hazard Unit accordingly.

Back to the Forward Unit.  
Design complete.  
The Forward Unit receives the 2-bit hazard_op from the Hazard Unit: 2’b01 → rs1 hazard, 2’b10 → rs2 hazard, 2’b11 → both, 2’b00 → no hazard.

When hazard_op indicates a data hazard, it switches the ALU source select from the “normal dataflow” value 2’b01 to 2’b10 to accept forwarded source data for computation.  
This ALU source MUX will be implemented in the RV32I46F_5SP top module. 2’b00 remains unused to mean “no selection.”

Given which hazard it is (via hazard_op), and using the current instruction’s opcode, it chooses what value to forward:  
- for loads, forward Data_Memory’s MEM_read_data;
- for SYSTEM (CSR, etc.), CSR File’s MEM_csr_read_data;
- for LUI, MEM_imm;
- for JAL/JALR, MEM_pc_plus_4;  
 otherwise, forward MEM_alu_result.

Note to self: don’t forget to implement the normal-vs-forward source-select MUX in the top module.

Now the Branch Predictor remains. A BHT would be nice, but first I’ll do a simple 2-bit FSM predictor; if the top-module integration behaves, I can add a BHT later.  
Better to finish something—even if shy of the ideal—than to chase perfection and never land it.

I implemented a simple 2-bit FSM Branch Predictor.   
While designing, I added EX_branch to the predictor—a signal the original 5SP didn’t have.  
As I wrote in the PR, to update the predictor’s 4-state FSM (Strongly Not Taken, Weakly Not Taken, Weakly Taken, Strongly Taken), I must know whether the moment is actually a branch.  
Without a branch-identify signal, the predictor would keep updating counters even when the instruction isn’t a branch.  
So I added it and reflected this in the RV32I46F_5SP.R4 diagram. That’s the 101st PR already.  

![RV32I46F_5SP.R4](/diagrams/design_archive/RV32I46F_5SP/RV32I46F_5SP_R4.drawio.png)

Writing the testbench isn’t easy now—values must be driven and checked aligned to pipeline timing, and validation must look at the correct cycle, not “current” values—so it took quite a while.  
I aimed to finish by dinner and just made it. Now after eating, it’s time to integrate into the top module and debug.  
Only the biggest part remains. Let’s do this. (17:29)

![RV32I46F_5SP.R4v2](/diagrams/design_archive/RV32I46F_5SP/RV32I46F_5SP_R4v2.drawio.png)

Top-module verification start. It runs, at least.  
register_write_data in the WB register is declared wrong. 
I need to rename it to byte_enable_logic_register_file_write_data.  
Also, in the pipelined structure the Branch Predictor now computes branch_target.  
If branch_prediction_miss is 0, it keeps outputting IF-stage pc+imm as branch_target; if the prediction is wrong, then at the EX-stage decision point it is already receiving EX_pc and EX_imm and outputs that as branch_target.  

Therefore, I must remove the Branch Logic’s branch_target computation from the scalar (single-cycle) 46F architecture.  
Still, values look wrong—why aren’t values coming out correctly from the register file?

![RV32I46F_5SP.R5](/diagrams/design_archive/RV32I46F_5SP/RV32I46F_5SP_R5.drawio.png)

## Debugging RV32I46F_5SP RTL Simulation Testbench

### [2025.05.26.]

Written on 2025.05.29. 
For several days I poured everything I had into this and couldn’t leave any record at all. What follows is a recollection of that period.  
I made a dirty file and debugged from there. 
While I was reproducing the dirty file’s “completion” on the real RISC-KC codebase and debugging step by step, I ran into cases that didn’t happen in the dirty file and cases that did happen there but didn’t here. Keep that in mind reading this.

*I kept thinking till I fell asleep, then went straight to the PC room right after morning formation; I even skipped meals and just analyzed waveforms. These past few days I’ve basically been coding every possible minute without eating. I leave on the 28th for FPGA training, and by then development really has to be finished. The real deadline is the 27th.*

I’ve built the branch predictor, forwarding unit, hazard unit, and the whole pipeline—dropping any of that would be painful.  
PRs/commits/branch management are soaking up a huge amount of time.   
So starting today I’ll develop to “done” first in a dirty file, then backfill commits from that dirty file (as of the day I’m writing this, I’m in the middle of committing those dirty-file changes).  

- Issue 1. Registers kept showing values like xx00_00bc.
   - I wrote an init block to zero all registers so they all start at 0000_0000. That cleared up the register waveform issue.  
   (As of today’s writing, oddly, I can’t catch that behavior in the waveforms anymore—even without adding that logic to the Register File. Huh?)

- Issue 2. The imm value didn’t seem to come out cleanly. 
   - WB_raw_imm in the pipeline was x.   
   I think I worked this out somehow (probably a knock-on effect).

- Issue 3.   
rs1 was being fed into the Register File just fine, but the corresponding source value wouldn’t come out.

Tracing why the ALU source wasn’t right, I found I’d forgotten to add the MUX in the top module that lets the ALU pick a forwarded source. Fixed that.  
Also, EX_branch_taken from the Branch Predictor wasn’t wired correctly—fixed.  

Switching the pipeline-stall basis from trapped to trap_done fixed the problem where after PTH the pipeline stalled and wouldn’t branch to the Trap Handler address.  
Now once PTH finishes, the stall clears and we jump into the Trap Handler as intended.  

I had also missed OR’ing the CSR write-enable from the Trap Controller with the pipelined write-enable coming from the Control Unit in the top module. Fixed.  

With the Branch Predictor defaulting to Strongly Not Taken, the following instruction runs. 
But even when the prediction is clearly wrong, we still weren’t branching to the EX-stage pc+imm.  
`branch_target` itself was correct—so why?

First-pass fix: I found I’d been fabricating a nonexistent IF_pc signal for pc—fixed that. 
That helped, but for some reason PCC’s branch_taken was still 0. Why?  

Looks like I’d derived branch_taken from branch_prediction, which caused trouble.  
I split signals into branch_estimation and branch_prediction_miss: on actual taken, use branch_target; if the estimation says taken, also use b_target; otherwise, just fall through.

Uh oh. I hit a case that needs WB forwarding.  
At 188611 ps, an instruction that retired in WB wrote to its rd, but a later instruction had already reached EX without that updated rd. I need the forwarding unit to forward from the WB stage as well.  
That’s it for today.

![RV32I46F_5SP.R6](/diagrams/design_archive/RV32I46F_5SP/RV32I46F_5SP_R6.drawio.png)

### [2025.05.27.]

When EX_jump is misaligned, we insert a NOP flush because it’s a jump. 
But then we lose the context that the jump was misaligned, so PTH only runs the first step and then we just move on to ADDI x0 x0 0, and the TH never runs.  
→ I wired trapped into the Hazard Unit and, when trapped goes high, I stall the ID_EX_Register and EX_MEM_Register.   
The ID_EX stall preserves context until PTH can run; the EX_MEM stall ensures the preceding (non-faulting) instruction completes.  

PTH takes at least 2 cycles. 
By then, the WB stage has already completed, and when the stalled MEM stage advances into WB, that WB also completes—so preceding instructions finish.   

Do we need special handling for MEM_WB_Register?   
No. Two preceding instructions will have already completed, and writing the same value to the same address twice doesn’t cause a data issue in the current system.

#### After a branch prediction miss, we still didn’t jump to the real target:  
PC only outputs the address set in the previous clock, so even if the EX-stage computes the correct address and PCC passes it on, we won’t branch to it right away.  

So I moved the EX-stage address calculation into the Branch Logic, and PCC now receives both branch_estimation_target and branch_target_actual. 
PCC decides—based on whether the prediction was right—and outputs next_pc accordingly.  

But why does branch_prediction_miss stay at 1 once it goes high?   
I must have forgotten to set a 0 default in the combinational logic for the “no condition met” path. Fix that and we’re done.

### [2025.05.28.]

It’s done. 00:54.  
I’m heading out today to KAIST IDEC for training—Xilinx FPGA implementation, a 3-day course. 
Now I’ll go through and commit/PR the changes I made in the dirty file but didn’t record.  

Since it’s better to have a “finished” record within May, if time gets too tight I’ll commit the final versions of each module in one go and document the changes in the PR.

![RV32I46F_5SP.R8](/diagrams/design_archive/RV32I46F_5SP/RV32I46F_5SP_R8.drawio.png)

### [2025.05.31.]
During this time I took the training and learned Vivado’s FPGA synthesis workflow—how to actually implement things on FPGA. Debugging, setting timing constraints, etc.  

At the RTL level, running Simulation and Synthesis in Vivado surfaces far more information and errors than writing with iverilog. 
From the reports, quite a few blocks were being synthesized into latches, and beyond that I’ll need to set timing constraints and then fix any timing violations that those constraints don’t eliminate.   
I should learn more about handling the .xdc file…

The roadmap is now:

1. Fix timing-related errors and unintended latch synthesis on FPGA
2. Bring up a simple OS like FreeRTOS on FPGA
3. Implement display output and keyboard/mouse input on FPGA
4. Performance testing and run Doom

All of this needs to happen within June. How long #1 takes will likely determine everything else. 
The problem is the logic is big enough that one synthesis run takes quite a while. 
And it needs a lot of memory—on my 16 GB machine, an overnight synthesis hit OOME in the logs around 3 a.m.  
<sub>*Later on, it turned out to be an RTL error.*</sub>

There’s no time left. I’ll push the backlog of development notes to the main docs and commit the final files.  
Honestly, while porting the main files from the dirty file, some situations that occurred in the dirty file didn’t occur here, and with fewer changes things gradually shaped up, so I thought optimization might be possible and wanted to go that way—but what matters is “finishing” the project, not chasing perfection given the current situation. We can pursue it, but not make it the goal right now.
Below are those development notes.

In RV32I46F_5SP, the logic to flush pipeline registers on a trap is missing.  
I’m planning to add it so that, on an exception, we stop updating the PC, let all in-flight instructions complete, then conduct trap handling.  
While branching to the Trap Handler, we’ll save the current GPR contents into a heap area in data memory and reload them on mret.

For example, take a misaligned exception.  
(Current supported traps are misaligned instruction address, EBREAK, ECALL, and mret only. fencei was dropped because we cut the cache due to schedule.)  

The Exception Detector catches this in IF, and the Branch Predictor receives both the branch target calculated in IF and the jump address calculated in EX.  
Using the opcode to determine the instruction form, instructions being processed before the jump have no context, so we hold the PC until they reach WB, flush, then proceed.

We detected a misaligned jump in EX, which triggered a trap: pc_stall asserted and flush happened.  
But on the next clock, EX holds a NOP due to the flush (the instruction after the jump), so EX’s opcode is no longer JAL, trapped deasserts, PTH doesn’t run, trap_done returns to 1, and execution continues incorrectly.  
The likely fix is to add a stall signal that stops pipeline-register updates and holds their current values.

In top-module testbench.  
PCC decides whether to use branch_target based on branch_estimation. 
If we estimated not-taken but EX_branch_taken is 1 (misprediction), the Branch Predictor computes the EX-stage branch target by adding the EX pc and imm.   
I want to code it so that whenever EX contradicts a strongly/weakly not-taken state, we use that branch_target as next_pc.  
→ This converged to the solution above. See “#### After a branch prediction miss, we still didn’t jump to the real target:” from ## [2025.05.27.]

Because the PC outputs the address set on the prior clock edge, even if PCC passes the EX-stage computed address on a misprediction, we won’t branch to it immediately.  
So we moved the EX-stage address calculation into the Branch Logic, and PCC now receives both brnach_estimation_target and branch_target_actual, decides whether the prediction was right, and outputs next_pc accordingly.

A case that needs WB-stage forwarding (from 2025.05.25.).  
The hazard unit outputs separate mem and wb hazard signals as hazard_op: hazard_mem and hazard_wb.  
The forwarding unit receives and handles them.  

#### Forwarding initially didn’t work.  
Now that we forward from WB as well as MEM, the top-module logic had to change.  

So I changed it to this scheme:  
- alu_normal_source_A / alu_normal_source_B.
- alu_forward_source_data_A / alu_forward_source_data_B.
- alu_forward_source_select_A / alu_forward_source_select_B.  
These are, respectively, the current pipeline value, the forwarded value, and the select for those.

#### Branch prediction issues.
Flush on misprediction worked, the prediction counter updated, NOP got inserted as designed.  
But once branch_prediction_miss went high, it never dropped even when branch_estimation matched branch taken.  
I noticed there was no zero-initialization path for miss in the combinational code; adding that fixed it.  

#### Branch misprediction execution issue.
On misprediction we should branch to the EX-computed branch target, but on the next clock the branch signal is deasserted, so PCC updates IF’s PC with PC+4.  
Should we pipeline the EX branch-taken signal into MEM and have PCC, on misprediction with MEM stage branch=1, jump to the branch target?  

Hmm… this also converges to the predictor/target issue above. See “#### After a branch prediction miss, we still didn’t jump to the real target:” from ## [2025.05.27.]  

As for where to compute that target:  
(We could put a combinational adder in the Predictor to add the EX imm and pc to get the actual branch address, but does it have to live in Branch Logic?)  
I decided to keep the Predictor simple—just IF-stage prediction and EX-result-based update—to keep module boundaries clean, and to include the computation in Branch Logic.

#### WB forwarding wasn’t working;  
looking at the top module, alu_forward_source_select only forwarded from MEM—I’d forgotten to update it. Fixed.  

#### But alu_forward_source_select_{a,b} weren’t changing at that timing;  
they stayed at 0.  
hazard_wb should have asserted from the HazardUnit, but since nothing changed it looks like the WB-forwarding condition wasn’t detected, so hazard_wb never fired. Why?  

Looking closely at the waveforms: the problematic EX_rs1 was 0c, but WB_rd was different, so there was no hazard—that logic was fine.  
The real issue: in the xor instruction, the rd from a completed sll is already in the Register File after WB, and WB_rd now belongs to the next instruction, so the hazard detector won’t see it.  

How to forward in this case?  
The data is already being written into the Register File, but the EX stage wants to read that same register in the same clock before the write “takes.”  
I added a write-through bypass in the Register File: when WB writes the same register being read, the read data = write data in that cycle.  
Fixed!

#### CSR-side forwarding wasn’t working.
Since CSR instructions read and write CSR in one go, this pops up. In single cycle, csrrs writes 0x2fc to mepc, then a csrrc immediately reads mepc; 
Zicsr hazards happen even when rs overlaps, not just rd. How to fix—change the CSR File?  
I resolved it by adding CSR forwarding support to the forwarding and hazard units.

#### PTH mtvec read issue
From the waveforms: ECALL is detected in ID by the Exception Detector, trap_status goes to 010 (ECALL), and PTH proceeds inside the Trap Controller as designed.  
But when PTH ends, reading mtvec from CSR address 305 should yield 0x0000_1000 and we should jump there. We did set csr_trap_address=305, but the read came back 0x0000_0000.  
Meanwhile in the misaligned PTH, requesting 305 does return 0x0000_1000 and we jump correctly.  

What’s wrong?  
In PCC, trapped is asserted, but csr_read_data arriving at PCC is 0x0000_0000, so the wrong instruction starts down the pipe from IF. How to fix?  
I wanted to flush the IF-fetched instruction when ECALL is detected in ID.  
I solved it by having the Hazard Unit raise IF_ID_Flush when trapped is asserted.  

#### CSR File Read/Write address read issue
On splitting CSR File read/write addresses.  
An address read in ID wasn’t producing a value until WB.  
For non-write operations I want to use the ID-decoded raw_imm as the CSR address, but the current top-module code feeds the WB-stage address, which causes this issue.  
To execute instructions correctly, CSR values must appear immediately for the address presented, but we were handing it WB’s address instead—fine in single cycle, not here.  
The fix is to give the CSR File separate ports for read address and write address (like the general Register File), so reads/writes don’t race.  

Also, the Trap Controller accesses the CSR File during PTH and must write to CSR immediately.  
Even if we add a dedicated write-address port, WB will also be writing CSR on Zicsr results. On a trap we stall the pipeline, but could WB’s write address conflict with Trap Controller’s?  
And the Trap Controller currently uses a single csr_trap_address for both CSR reads and writes.  
This suggests splitting the Trap Controller’s CSR address outputs into separate read and write ports, and likewise splitting the CSR’s write-address ports between Trap Controller and WB.  

Do we also need to tell CSR File whether the access is for PTH (e.g., by adding trap_done as an input)? Is that right…?  
No—WB-stage CSR ops are already in flight before trap detection, and our logic completes in-flight instructions before handling the trap. So there’s no conflict.   
I solved it by splitting the CSR’s address inputs into separate read-address and write-address ports.

�
Command: %s
1870*	planAhead2�
�read_checkpoint -auto_incremental -incremental C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/utils_1/imports/synth_1/RV32I46F5SPSoCTOP.dcpZ12-2866h px� 
�
;Read reference checkpoint from %s for incremental synthesis3154*	planAhead2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/utils_1/imports/synth_1/RV32I46F5SPSoCTOP.dcpZ12-5825h px� 
T
-Please ensure there are no constraint changes3725*	planAheadZ12-7989h px� 
�
Command: %s
53*	vivadotcl2�
�synth_design -top RV32I46F5SPSoCTOP -part xc7a200tsbg484-3 -directive PerformanceOptimized -fsm_extraction one_hot -keep_equivalent_registers -resource_sharing off -no_lc -shreg_min_size 5Z4-113h px� 
:
Starting synth_design
149*	vivadotclZ4-321h px� 
{
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
	Synthesis2

xc7a200tZ17-347h px� 
k
0Got license for feature '%s' and/or device '%s'
310*common2
	Synthesis2

xc7a200tZ17-349h px� 
E
Loading part %s157*device2
xc7a200tsbg484-3Z21-403h px� 
o
HMultithreading enabled for synth_design using a maximum of %s processes.4828*oasys2
2Z8-7079h px� 
a
?Launching helper process for spawning children vivado processes4827*oasysZ8-7078h px� 
M
#Helper process launched with PID %s4824*oasys2
8244Z8-7075h px� 
�
%s*synth2{
yStarting RTL Elaboration : Time (s): cpu = 00:00:08 ; elapsed = 00:00:08 . Memory (MB): peak = 1039.496 ; gain = 467.809
h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ProgramCounter2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Program_Counter.v2
188@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ProgramCounter2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Program_Counter.v2
188@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
PCController2�
|C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Controller.v2
338@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
PCController2�
|C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Controller.v2
338@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2	
PCPlus42|
xC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Plus_4.v2
108@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2	
PCPlus42|
xC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Plus_4.v2
108@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
InstructionMemory2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Memory.v2
1508@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
InstructionMemory2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Memory.v2
1508@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
InstructionDecoder2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Decoder.v2
878@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
InstructionDecoder2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Decoder.v2
878@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ImmediateGenerator2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Immediate_Generator.v2
328@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ImmediateGenerator2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Immediate_Generator.v2
328@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ControlUnit2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Control_Unit.v2
3228@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ControlUnit2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Control_Unit.v2
3228@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
RegisterFileDebug2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Register_File_Debug.v2
648@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
RegisterFileDebug2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Register_File_Debug.v2
648@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2

DataMemory2~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Data_Memory.v2
348@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2

DataMemory2~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Data_Memory.v2
348@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ALUController2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU_Controller.v2
1678@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ALUController2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU_Controller.v2
1678@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ALU2v
rC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU.v2
748@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ALU2v
rC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU.v2
748@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
BranchLogic2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Logic.v2
398@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
BranchLogic2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Logic.v2
398@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ByteEnableLogic2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Byte_Enable_Logic.v2
1038@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ByteEnableLogic2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Byte_Enable_Logic.v2
1038@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2	
CSRFile2{
wC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/CSR_File.v2
1198@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2	
CSRFile2{
wC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/CSR_File.v2
1198@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ExceptionDetector2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Exception_Detector.v2
2938@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ExceptionDetector2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Exception_Detector.v2
2938@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
TrapController2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Trap_Controller.v2
2388@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
TrapController2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Trap_Controller.v2
2388@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
IF_ID_Register2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/IF_ID_Register.v2
468@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
IF_ID_Register2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/IF_ID_Register.v2
468@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ID_EX_Register2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ID_EX_Register.v2
1548@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ID_EX_Register2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ID_EX_Register.v2
1548@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
EX_MEM_Register2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/EX_MEM_Register.v2
1228@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
EX_MEM_Register2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/EX_MEM_Register.v2
1228@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
MEM_WB_Register2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/MEM_WB_Register.v2
1068@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
MEM_WB_Register2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/MEM_WB_Register.v2
1068@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2

HazardUnit2~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Hazard_Unit.v2
1458@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2

HazardUnit2~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Hazard_Unit.v2
1458@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ForwardUnit2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Forward_Unit.v2
838@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ForwardUnit2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Forward_Unit.v2
838@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
BranchPredictor2�
C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Predictor.v2
608@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
BranchPredictor2�
C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Predictor.v2
608@Z8-9937h px� 
�
$data object '%s' is already declared5597*oasys2
MEM_WB_flush2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
2198@Z8-9339h px� 
�
)previous declaration of '%s' is from here4683*oasys2
MEM_WB_flush2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
2008@Z8-6826h px� 
�
%second declaration of '%s' is ignored7413*oasys2
MEM_WB_flush2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
2198@Z8-11152h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ProgramCounter2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Program_Counter.v2
188@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ProgramCounter2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Program_Counter.v2
188@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
PCController2�
|C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Controller.v2
338@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
PCController2�
|C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Controller.v2
338@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2	
PCPlus42|
xC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Plus_4.v2
108@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2	
PCPlus42|
xC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Plus_4.v2
108@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
InstructionMemory2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Memory.v2
1508@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
InstructionMemory2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Memory.v2
1508@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
InstructionDecoder2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Decoder.v2
878@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
InstructionDecoder2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Decoder.v2
878@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ImmediateGenerator2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Immediate_Generator.v2
328@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ImmediateGenerator2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Immediate_Generator.v2
328@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ControlUnit2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Control_Unit.v2
3228@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ControlUnit2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Control_Unit.v2
3228@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
RegisterFileDebug2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Register_File_Debug.v2
648@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
RegisterFileDebug2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Register_File_Debug.v2
648@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2

DataMemory2~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Data_Memory.v2
348@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2

DataMemory2~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Data_Memory.v2
348@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ALUController2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU_Controller.v2
1678@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ALUController2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU_Controller.v2
1678@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ALU2v
rC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU.v2
748@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ALU2v
rC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU.v2
748@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
BranchLogic2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Logic.v2
398@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
BranchLogic2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Logic.v2
398@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ByteEnableLogic2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Byte_Enable_Logic.v2
1038@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ByteEnableLogic2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Byte_Enable_Logic.v2
1038@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2	
CSRFile2{
wC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/CSR_File.v2
1198@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2	
CSRFile2{
wC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/CSR_File.v2
1198@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ExceptionDetector2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Exception_Detector.v2
2938@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ExceptionDetector2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Exception_Detector.v2
2938@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
TrapController2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Trap_Controller.v2
2388@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
TrapController2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Trap_Controller.v2
2388@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
IF_ID_Register2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/IF_ID_Register.v2
468@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
IF_ID_Register2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/IF_ID_Register.v2
468@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ID_EX_Register2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ID_EX_Register.v2
1548@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ID_EX_Register2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ID_EX_Register.v2
1548@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
EX_MEM_Register2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/EX_MEM_Register.v2
1228@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
EX_MEM_Register2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/EX_MEM_Register.v2
1228@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
MEM_WB_Register2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/MEM_WB_Register.v2
1068@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
MEM_WB_Register2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/MEM_WB_Register.v2
1068@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2

HazardUnit2~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Hazard_Unit.v2
1458@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2

HazardUnit2~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Hazard_Unit.v2
1458@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ForwardUnit2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Forward_Unit.v2
838@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ForwardUnit2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Forward_Unit.v2
838@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
BranchPredictor2�
C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Predictor.v2
608@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
BranchPredictor2�
C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Predictor.v2
608@Z8-9937h px� 
�
$data object '%s' is already declared5597*oasys2
MEM_WB_flush2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
2198@Z8-9339h px� 
�
)previous declaration of '%s' is from here4683*oasys2
MEM_WB_flush2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
2008@Z8-6826h px� 
�
%second declaration of '%s' is ignored7413*oasys2
MEM_WB_flush2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
2198@Z8-11152h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
RV32I46F5SPDebug2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
7918@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
RV32I46F5SPDebug2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
7918@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
ButtonController2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Button_Controller.v2
1698@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
ButtonController2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Button_Controller.v2
1698@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
UARTTX2z
vC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/UART_TX.v2
528@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
UARTTX2z
vC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/UART_TX.v2
528@Z8-9937h px� 
�
*overwriting previous definition of %s '%s'6131*oasys2
module2
DebugUARTController2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Debug_UART_Controller.v2
1468@Z8-9873h px� 
�
2previous definition of design element '%s' is here6195*oasys2
DebugUARTController2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Debug_UART_Controller.v2
1468@Z8-9937h px� 
�
.identifier '%s' is used before its declaration4750*oasys2
continuous_mode2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/46F5SP_SoC_TOP.v2
488@Z8-6901h px� 
�
synthesizing module '%s'%s4497*oasys2
RV32I46F5SPSoCTOP2
 2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/46F5SP_SoC_TOP.v2
68@Z8-6157h px� 
�
synthesizing module '%s'%s4497*oasys2
BUFG2
 29
5D:/Xilinx/Vivado/2024.2/scripts/rt/data/unisim_comp.v2
26768@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
BUFG2
 2
02
129
5D:/Xilinx/Vivado/2024.2/scripts/rt/data/unisim_comp.v2
26768@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
ButtonController2
 2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Button_Controller.v2
18@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
ButtonController2
 2
02
12�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Button_Controller.v2
18@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
UARTTX2
 2z
vC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/UART_TX.v2
18@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
UARTTX2
 2
02
12z
vC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/UART_TX.v2
18@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
DebugUARTController2
 2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Debug_UART_Controller.v2
18@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
DebugUARTController2
 2
02
12�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Debug_UART_Controller.v2
18@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
RV32I46F5SPDebug2
 2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
308@Z8-6157h px� 
H
%s
*synth20
.	Parameter XLEN bound to: 32 - type: integer 
h p
x
� 
�
synthesizing module '%s'%s4497*oasys2
ProgramCounter2
 2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Program_Counter.v2
18@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
ProgramCounter2
 2
02
12�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Program_Counter.v2
18@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
PCController2
 2�
|C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Controller.v2
18@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
PCController2
 2
02
12�
|C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Controller.v2
18@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2	
PCPlus42
 2|
xC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Plus_4.v2
18@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2	
PCPlus42
 2
02
12|
xC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/PC_Plus_4.v2
18@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
InstructionMemory2
 2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Memory.v2
98@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
InstructionMemory2
 2
02
12�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Memory.v2
98@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
InstructionDecoder2
 2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Decoder.v2
38@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
InstructionDecoder2
 2
02
12�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Instruction_Decoder.v2
38@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
ImmediateGenerator2
 2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Immediate_Generator.v2
38@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
ImmediateGenerator2
 2
02
12�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Immediate_Generator.v2
38@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
ControlUnit2
 2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Control_Unit.v2
78@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
ControlUnit2
 2
02
12
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Control_Unit.v2
78@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
RegisterFileDebug2
 2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Register_File_Debug.v2
18@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
RegisterFileDebug2
 2
02
12�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Register_File_Debug.v2
18@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2

DataMemory2
 2~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Data_Memory.v2
18@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2

DataMemory2
 2
02
12~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Data_Memory.v2
18@Z8-6155h px� 
�
Pwidth (%s) of port connection '%s' does not match port width (%s) of module '%s'689*oasys2
152	
address2
102

DataMemory2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
3478@Z8-689h px� 
�
synthesizing module '%s'%s4497*oasys2
ALUController2
 2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU_Controller.v2
88@Z8-6157h px� 
�
default block is never used226*oasys2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU_Controller.v2
608@Z8-226h px� 
�
default block is never used226*oasys2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU_Controller.v2
968@Z8-226h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
ALUController2
 2
02
12�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU_Controller.v2
88@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
ALU2
 2v
rC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU.v2
38@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
ALU2
 2
02
12v
rC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ALU.v2
38@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
BranchLogic2
 2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Logic.v2
38@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
BranchLogic2
 2
02
12
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Logic.v2
38@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
ByteEnableLogic2
 2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Byte_Enable_Logic.v2
48@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
ByteEnableLogic2
 2
02
12�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Byte_Enable_Logic.v2
48@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2	
CSRFile2
 2{
wC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/CSR_File.v2
38@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2	
CSRFile2
 2
02
12{
wC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/CSR_File.v2
38@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
ExceptionDetector2
 2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Exception_Detector.v2
68@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
ExceptionDetector2
 2
02
12�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Exception_Detector.v2
68@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
TrapController2
 2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Trap_Controller.v2
38@Z8-6157h px� 
H
%s
*synth20
.	Parameter XLEN bound to: 32 - type: integer 
h p
x
� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
TrapController2
 2
02
12�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Trap_Controller.v2
38@Z8-6155h px� 
�
9port '%s' of module '%s' is unconnected for instance '%s'4818*oasys2

ic_clean2
TrapController2
trap_controller2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
4348@Z8-7071h px� 
�
Kinstance '%s' of module '%s' has %s connections declared, but only %s given4757*oasys2
trap_controller2
TrapController2
202
192�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
4348@Z8-7023h px� 
�
synthesizing module '%s'%s4497*oasys2
IF_ID_Register2
 2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/IF_ID_Register.v2
18@Z8-6157h px� 
H
%s
*synth20
.	Parameter XLEN bound to: 32 - type: integer 
h p
x
� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
IF_ID_Register2
 2
02
12�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/IF_ID_Register.v2
18@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
ID_EX_Register2
 2�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ID_EX_Register.v2
18@Z8-6157h px� 
H
%s
*synth20
.	Parameter XLEN bound to: 32 - type: integer 
h p
x
� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
ID_EX_Register2
 2
02
12�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/ID_EX_Register.v2
18@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
EX_MEM_Register2
 2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/EX_MEM_Register.v2
18@Z8-6157h px� 
H
%s
*synth20
.	Parameter XLEN bound to: 32 - type: integer 
h p
x
� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
EX_MEM_Register2
 2
02
12�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/EX_MEM_Register.v2
18@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
MEM_WB_Register2
 2�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/MEM_WB_Register.v2
18@Z8-6157h px� 
H
%s
*synth20
.	Parameter XLEN bound to: 32 - type: integer 
h p
x
� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
MEM_WB_Register2
 2
02
12�
~C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/MEM_WB_Register.v2
18@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2

HazardUnit2
 2~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Hazard_Unit.v2
48@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2

HazardUnit2
 2
02
12~
zC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Hazard_Unit.v2
48@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
ForwardUnit2
 2
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Forward_Unit.v2
38@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
ForwardUnit2
 2
02
12
{C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Forward_Unit.v2
38@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
BranchPredictor2
 2�
C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Predictor.v2
38@Z8-6157h px� 
H
%s
*synth20
.	Parameter XLEN bound to: 32 - type: integer 
h p
x
� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
BranchPredictor2
 2
02
12�
C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Predictor.v2
38@Z8-6155h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
RV32I46F5SPDebug2
 2
02
12�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/RV32I46F_5SP_Debug.v2
308@Z8-6155h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
RV32I46F5SPSoCTOP2
 2
02
12�
}C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/46F5SP_SoC_TOP.v2
68@Z8-6155h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
send_buf_reg2
DebugUARTController2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Debug_UART_Controller.v2
728@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
tx_data_reg2
DebugUARTController2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Debug_UART_Controller.v2
1218@Z8-7137h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2
branch_prediction_reg2�
C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/Branch_Predictor.v2
358@Z8-6014h px� 
p
9Port %s in module %s is either unconnected or has no load4866*oasys2
clk2

HazardUnitZ8-7129h px� 
w
9Port %s in module %s is either unconnected or has no load4866*oasys2

clk_enable2

HazardUnitZ8-7129h px� 
r
9Port %s in module %s is either unconnected or has no load4866*oasys2
reset2

HazardUnitZ8-7129h px� 
{
9Port %s in module %s is either unconnected or has no load4866*oasys2
trap_status[2]2

HazardUnitZ8-7129h px� 
{
9Port %s in module %s is either unconnected or has no load4866*oasys2
trap_status[1]2

HazardUnitZ8-7129h px� 
{
9Port %s in module %s is either unconnected or has no load4866*oasys2
trap_status[0]2

HazardUnitZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
misaligned_instruction_flush2

HazardUnitZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
misaligned_memory_flush2

HazardUnitZ8-7129h px� 
{
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[11]2

HazardUnitZ8-7129h px� 
{
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[10]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[9]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[8]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[7]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[6]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[5]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[4]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[3]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[2]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[1]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[0]2

HazardUnitZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
EX_csr_write_enable2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[31]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[30]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[29]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[28]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[27]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[26]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[25]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[24]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[23]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[22]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[21]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[20]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[19]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[18]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[17]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[16]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[15]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[14]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[13]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[12]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[11]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	ID_pc[10]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

ID_pc[9]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

ID_pc[8]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

ID_pc[7]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

ID_pc[6]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

ID_pc[5]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

ID_pc[4]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

ID_pc[3]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

ID_pc[2]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

ID_pc[1]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

ID_pc[0]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[31]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[30]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[29]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[28]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[27]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[26]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[25]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[24]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[23]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[22]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[21]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[20]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[19]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[18]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[17]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[16]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[15]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[14]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[13]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[12]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[11]2
TrapControllerZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
	WB_pc[10]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

WB_pc[9]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

WB_pc[8]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

WB_pc[7]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

WB_pc[6]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

WB_pc[5]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

WB_pc[4]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

WB_pc[3]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

WB_pc[2]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

WB_pc[1]2
TrapControllerZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2

WB_pc[0]2
TrapControllerZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
csr_write_enable2
ExceptionDetectorZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2
pc[1]2
InstructionMemoryZ8-7129h px� 
y
9Port %s in module %s is either unconnected or has no load4866*oasys2
pc[0]2
InstructionMemoryZ8-7129h px� 
�
%s*synth2{
yFinished RTL Elaboration : Time (s): cpu = 00:00:11 ; elapsed = 00:00:12 . Memory (MB): peak = 1167.258 ; gain = 595.570
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
;
%s
*synth2#
!Start Handling Custom Attributes
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Handling Custom Attributes : Time (s): cpu = 00:00:12 ; elapsed = 00:00:12 . Memory (MB): peak = 1167.258 ; gain = 595.570
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished RTL Optimization Phase 1 : Time (s): cpu = 00:00:12 ; elapsed = 00:00:12 . Memory (MB): peak = 1167.258 ; gain = 595.570
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002
00:00:00.1372

1167.2582
0.000Z17-268h px� 
K
)Preparing netlist for logic optimization
349*projectZ1-570h px� 
>

Processing XDC Constraints
244*projectZ1-262h px� 
=
Initializing timing engine
348*projectZ1-569h px� 
�
Parsing XDC File [%s]
179*designutils2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/constrs_1/imports/new/RV32I46F_5SP_Debug_XDC.xdc8Z20-179h px� 
�
Finished Parsing XDC File [%s]
178*designutils2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/constrs_1/imports/new/RV32I46F_5SP_Debug_XDC.xdc8Z20-178h px� 
�
�Implementation specific constraints were found while reading constraint file [%s]. These constraints will be ignored for synthesis but will be used in implementation. Impacted constraints are listed in the file [%s].
233*project2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/constrs_1/imports/new/RV32I46F_5SP_Debug_XDC.xdc2%
#.Xil/RV32I46F5SPSoCTOP_propImpl.xdcZ1-236h px� 
H
&Completed Processing XDC Constraints

245*projectZ1-263h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002
00:00:00.0012

1258.2662
0.000Z17-268h px� 
l
!Unisim Transformation Summary:
%s111*project2'
%No Unisim elements were transformed.
Z1-111h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2"
 Constraint Validation Runtime : 2

00:00:002
00:00:00.0152

1258.2662
0.000Z17-268h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
Finished Constraint Validation : Time (s): cpu = 00:00:25 ; elapsed = 00:00:26 . Memory (MB): peak = 1258.266 ; gain = 686.578
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
D
%s
*synth2,
*Start Loading Part and Timing Information
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Loading part: xc7a200tsbg484-3
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Loading Part and Timing Information : Time (s): cpu = 00:00:25 ; elapsed = 00:00:26 . Memory (MB): peak = 1258.266 ; gain = 686.578
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
H
%s
*synth20
.Start Applying 'set_property' XDC Constraints
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished applying 'set_property' XDC Constraints : Time (s): cpu = 00:00:25 ; elapsed = 00:00:26 . Memory (MB): peak = 1258.266 ; gain = 686.578
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
7
%s
*synth2
Start Preparing Guide Design
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
�The reference checkpoint %s is not suitable for use with incremental synthesis for this design. Please regenerate the checkpoint for this design with -incremental_synth switch in the same Vivado session that synth_design has been run. Synthesis will continue with the default flow4740*oasys2�
�C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/utils_1/imports/synth_1/RV32I46F5SPSoCTOP.dcpZ8-6895h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2~
|Finished Doing Graph Differ : Time (s): cpu = 00:00:25 ; elapsed = 00:00:26 . Memory (MB): peak = 1258.266 ; gain = 686.578
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Preparing Guide Design : Time (s): cpu = 00:00:25 ; elapsed = 00:00:26 . Memory (MB): peak = 1258.266 ; gain = 686.578
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
w
3inferred FSM for state register '%s' in module '%s'802*oasys2
	state_reg2
DebugUARTControllerZ8-802h px� 
~
3inferred FSM for state register '%s' in module '%s'802*oasys2
trap_handle_state_reg2
TrapControllerZ8-802h px� 
z
3inferred FSM for state register '%s' in module '%s'802*oasys2
step_state_reg2
RV32I46F5SPSoCTOPZ8-802h px� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
z
%s
*synth2b
`                   State |                     New Encoding |                Previous Encoding 
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
y
%s
*synth2a
_                 ST_IDLE |                              001 |                               00
h p
x
� 
y
%s
*synth2a
_                 ST_SEND |                              010 |                               01
h p
x
� 
y
%s
*synth2a
_                 ST_WAIT |                              100 |                               10
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
�
Gencoded FSM with state register '%s' using encoding '%s' in module '%s'3353*oasys2
	state_reg2	
one-hot2
DebugUARTControllerZ8-3354h px� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
z
%s
*synth2b
`                   State |                     New Encoding |                Previous Encoding 
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
y
%s
*synth2a
_                    IDLE |                      00000000001 |                             0000
h p
x
� 
y
%s
*synth2a
_               READ_MEPC |                      00000000010 |                             0100
h p
x
� 
y
%s
*synth2a
_             RETURN_MRET |                      00000000100 |                             0110
h p
x
� 
y
%s
*synth2a
_             MEM_STANDBY |                      00000001000 |                             0111
h p
x
� 
y
%s
*synth2a
_              WB_STANDBY |                      00000010000 |                             1000
h p
x
� 
y
%s
*synth2a
_            RTRE_STANDBY |                      00000100000 |                             1001
h p
x
� 
y
%s
*synth2a
_        ECALL_MEPC_WRITE |                      00001000000 |                             1010
h p
x
� 
y
%s
*synth2a
_              WRITE_MEPC |                      00010000000 |                             0001
h p
x
� 
y
%s
*synth2a
_            WRITE_MCAUSE |                      00100000000 |                             0010
h p
x
� 
y
%s
*synth2a
_              READ_MTVEC |                      01000000000 |                             0011
h p
x
� 
y
%s
*synth2a
_              GOTO_MTVEC |                      10000000000 |                             0101
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
�
Gencoded FSM with state register '%s' using encoding '%s' in module '%s'3353*oasys2
trap_handle_state_reg2	
one-hot2
TrapControllerZ8-3354h px� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
z
%s
*synth2b
`                   State |                     New Encoding |                Previous Encoding 
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
y
%s
*synth2a
_                  iSTATE |                              001 |                               00
h p
x
� 
y
%s
*synth2a
_                 iSTATE0 |                              010 |                               01
h p
x
� 
y
%s
*synth2a
_                 iSTATE1 |                              100 |                               10
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
�
Gencoded FSM with state register '%s' using encoding '%s' in module '%s'3353*oasys2
step_state_reg2	
one-hot2
RV32I46F5SPSoCTOPZ8-3354h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished RTL Optimization Phase 2 : Time (s): cpu = 00:00:27 ; elapsed = 00:00:28 . Memory (MB): peak = 1258.266 ; gain = 686.578
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
C
%s
*synth2+
)

Incremental Synthesis Report Summary:

h p
x
� 
<
%s
*synth2$
"1. Incremental synthesis run: no

h p
x
� 
O
%s
*synth27
5   Reason for not running incremental synthesis : 


h p
x
� 
�
�Flow is switching to default flow due to incremental criteria not met. If you would like to alter this behaviour and have the flow terminate instead, please set the following parameter config_implementation {autoIncr.Synth.RejectBehavior Terminate}4868*oasysZ8-7130h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
:
%s
*synth2"
 Start RTL Component Statistics 
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Detailed RTL Component Info : 
h p
x
� 
(
%s
*synth2
+---Adders : 
h p
x
� 
F
%s
*synth2.
,	   2 Input   32 Bit       Adders := 6     
h p
x
� 
F
%s
*synth2.
,	   3 Input   32 Bit       Adders := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input   25 Bit       Adders := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input   19 Bit       Adders := 5     
h p
x
� 
F
%s
*synth2.
,	   2 Input    9 Bit       Adders := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input    7 Bit       Adders := 33    
h p
x
� 
F
%s
*synth2.
,	   2 Input    5 Bit       Adders := 2     
h p
x
� 
F
%s
*synth2.
,	   2 Input    4 Bit       Adders := 1     
h p
x
� 
&
%s
*synth2
+---XORs : 
h p
x
� 
H
%s
*synth20
.	   2 Input     32 Bit         XORs := 1     
h p
x
� 
+
%s
*synth2
+---Registers : 
h p
x
� 
H
%s
*synth20
.	              152 Bit    Registers := 1     
h p
x
� 
H
%s
*synth20
.	               32 Bit    Registers := 30    
h p
x
� 
H
%s
*synth20
.	               26 Bit    Registers := 1     
h p
x
� 
H
%s
*synth20
.	               20 Bit    Registers := 8     
h p
x
� 
H
%s
*synth20
.	               16 Bit    Registers := 1     
h p
x
� 
H
%s
*synth20
.	               10 Bit    Registers := 1     
h p
x
� 
H
%s
*synth20
.	                8 Bit    Registers := 1     
h p
x
� 
H
%s
*synth20
.	                7 Bit    Registers := 4     
h p
x
� 
H
%s
*synth20
.	                5 Bit    Registers := 15    
h p
x
� 
H
%s
*synth20
.	                4 Bit    Registers := 1     
h p
x
� 
H
%s
*synth20
.	                3 Bit    Registers := 7     
h p
x
� 
H
%s
*synth20
.	                2 Bit    Registers := 3     
h p
x
� 
H
%s
*synth20
.	                1 Bit    Registers := 32    
h p
x
� 
&
%s
*synth2
+---RAMs : 
h p
x
� 
Y
%s
*synth2A
?	              32K Bit	(1024 X 32 bit)          RAMs := 1     
h p
x
� 
W
%s
*synth2?
=	             1024 Bit	(32 X 32 bit)          RAMs := 1     
h p
x
� 
'
%s
*synth2
+---Muxes : 
h p
x
� 
F
%s
*synth2.
,	   2 Input  152 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   3 Input  152 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input   32 Bit        Muxes := 48    
h p
x
� 
F
%s
*synth2.
,	  66 Input   32 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	   4 Input   32 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   3 Input   32 Bit        Muxes := 3     
h p
x
� 
F
%s
*synth2.
,	  11 Input   32 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   2 Input   25 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input   20 Bit        Muxes := 3     
h p
x
� 
F
%s
*synth2.
,	   2 Input   19 Bit        Muxes := 10    
h p
x
� 
F
%s
*synth2.
,	   2 Input   12 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	  17 Input   11 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input   10 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   3 Input   10 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	  11 Input   10 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input    9 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   2 Input    7 Bit        Muxes := 37    
h p
x
� 
F
%s
*synth2.
,	   4 Input    5 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input    5 Bit        Muxes := 8     
h p
x
� 
F
%s
*synth2.
,	   3 Input    5 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input    4 Bit        Muxes := 5     
h p
x
� 
F
%s
*synth2.
,	   7 Input    4 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   3 Input    4 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   3 Input    3 Bit        Muxes := 3     
h p
x
� 
F
%s
*synth2.
,	   2 Input    3 Bit        Muxes := 18    
h p
x
� 
F
%s
*synth2.
,	   5 Input    3 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   3 Input    2 Bit        Muxes := 3     
h p
x
� 
F
%s
*synth2.
,	   2 Input    2 Bit        Muxes := 8     
h p
x
� 
F
%s
*synth2.
,	   8 Input    2 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input    1 Bit        Muxes := 41    
h p
x
� 
F
%s
*synth2.
,	   3 Input    1 Bit        Muxes := 24    
h p
x
� 
F
%s
*synth2.
,	   7 Input    1 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	  11 Input    1 Bit        Muxes := 6     
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
=
%s
*synth2%
#Finished RTL Component Statistics 
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
6
%s
*synth2
Start Part Resource Summary
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
s
%s
*synth2[
YPart Resources:
DSPs: 740 (col length:100)
BRAMs: 730 (col length: RAMB18 100 RAMB36 50)
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Finished Part Resource Summary
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
E
%s
*synth2-
+Start Cross Boundary and Area Optimization
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
H
&Parallel synthesis criteria is not met4829*oasysZ8-7080h px� 
p
9Port %s in module %s is either unconnected or has no load4866*oasys2
clk2

HazardUnitZ8-7129h px� 
w
9Port %s in module %s is either unconnected or has no load4866*oasys2

clk_enable2

HazardUnitZ8-7129h px� 
r
9Port %s in module %s is either unconnected or has no load4866*oasys2
reset2

HazardUnitZ8-7129h px� 
{
9Port %s in module %s is either unconnected or has no load4866*oasys2
trap_status[2]2

HazardUnitZ8-7129h px� 
{
9Port %s in module %s is either unconnected or has no load4866*oasys2
trap_status[1]2

HazardUnitZ8-7129h px� 
{
9Port %s in module %s is either unconnected or has no load4866*oasys2
trap_status[0]2

HazardUnitZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
misaligned_instruction_flush2

HazardUnitZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
misaligned_memory_flush2

HazardUnitZ8-7129h px� 
{
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[11]2

HazardUnitZ8-7129h px� 
{
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[10]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[9]2

HazardUnitZ8-7129h px� 
z
9Port %s in module %s is either unconnected or has no load4866*oasys2
ID_raw_imm[8]2

HazardUnitZ8-7129h px� 
�
�Message '%s' appears more than %s times and has been disabled. User can change this message limit to see more message instances.
14*common2
Synth 8-71292
100Z17-14h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Cross Boundary and Area Optimization : Time (s): cpu = 00:01:06 ; elapsed = 00:01:07 . Memory (MB): peak = 1293.305 ; gain = 721.617
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�---------------------------------------------------------------------------------
Start ROM, RAM, DSP, Shift Register and Retiming Reporting
h px� 
l
%s*synth2T
R---------------------------------------------------------------------------------
h px� 
X
%s*synth2@
>
Distributed RAM: Preliminary Mapping Report (see note below)
h px� 
�
%s*synth2r
p+---------------------------------------+---------------+-----------+----------------------+------------------+
h px� 
�
%s*synth2s
q|Module Name                            | RTL Object    | Inference | Size (Depth x Width) | Primitives       | 
h px� 
�
%s*synth2r
p+---------------------------------------+---------------+-----------+----------------------+------------------+
h px� 
�
%s*synth2s
q|rv32i46f_5sp_debug/register_file_debug | registers_reg | Implied   | 32 x 32              | RAM32M x 12      | 
h px� 
�
%s*synth2s
q|rv32i46f_5sp_debug/data_memory         | memory_reg    | Implied   | 1 K x 32             | RAM256X1S x 128  | 
h px� 
�
%s*synth2s
q+---------------------------------------+---------------+-----------+----------------------+------------------+

h px� 
�
%s*synth2�
�Note: The table above is a preliminary report that shows the Distributed RAMs at the current stage of the synthesis flow. Some Distributed RAMs may be reimplemented as non Distributed RAM primitives later in the synthesis flow. Multiple instantiated RAMs are reported only once.
h px� 
�
%s*synth2�
�---------------------------------------------------------------------------------
Finished ROM, RAM, DSP, Shift Register and Retiming Reporting
h px� 
l
%s*synth2T
R---------------------------------------------------------------------------------
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
@
%s
*synth2(
&Start Applying XDC Timing Constraints
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Applying XDC Timing Constraints : Time (s): cpu = 00:01:15 ; elapsed = 00:01:16 . Memory (MB): peak = 1388.473 ; gain = 816.785
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
4
%s
*synth2
Start Timing Optimization
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2
}Finished Timing Optimization : Time (s): cpu = 00:01:23 ; elapsed = 00:01:24 . Memory (MB): peak = 1397.754 ; gain = 826.066
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s
*synth2�
�---------------------------------------------------------------------------------
Start ROM, RAM, DSP, Shift Register and Retiming Reporting
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
A
%s
*synth2)
'
Distributed RAM: Final Mapping Report
h p
x
� 
�
%s
*synth2r
p+---------------------------------------+---------------+-----------+----------------------+------------------+
h p
x
� 
�
%s
*synth2s
q|Module Name                            | RTL Object    | Inference | Size (Depth x Width) | Primitives       | 
h p
x
� 
�
%s
*synth2r
p+---------------------------------------+---------------+-----------+----------------------+------------------+
h p
x
� 
�
%s
*synth2s
q|rv32i46f_5sp_debug/register_file_debug | registers_reg | Implied   | 32 x 32              | RAM32M x 12      | 
h p
x
� 
�
%s
*synth2s
q|rv32i46f_5sp_debug/data_memory         | memory_reg    | Implied   | 1 K x 32             | RAM256X1S x 128  | 
h p
x
� 
�
%s
*synth2s
q+---------------------------------------+---------------+-----------+----------------------+------------------+

h p
x
� 
�
%s
*synth2�
�---------------------------------------------------------------------------------
Finished ROM, RAM, DSP, Shift Register and Retiming Reporting
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
3
%s
*synth2
Start Technology Mapping
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2~
|Finished Technology Mapping : Time (s): cpu = 00:01:28 ; elapsed = 00:01:29 . Memory (MB): peak = 1513.102 ; gain = 941.414
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
-
%s
*synth2
Start IO Insertion
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
?
%s
*synth2'
%Start Flattening Before IO Insertion
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
B
%s
*synth2*
(Finished Flattening Before IO Insertion
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
6
%s
*synth2
Start Final Netlist Cleanup
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Finished Final Netlist Cleanup
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2y
wFinished IO Insertion : Time (s): cpu = 00:01:34 ; elapsed = 00:01:36 . Memory (MB): peak = 1614.824 ; gain = 1043.137
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
=
%s
*synth2%
#Start Renaming Generated Instances
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Renaming Generated Instances : Time (s): cpu = 00:01:34 ; elapsed = 00:01:36 . Memory (MB): peak = 1614.824 ; gain = 1043.137
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
:
%s
*synth2"
 Start Rebuilding User Hierarchy
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Rebuilding User Hierarchy : Time (s): cpu = 00:01:34 ; elapsed = 00:01:36 . Memory (MB): peak = 1614.824 ; gain = 1043.137
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Start Renaming Generated Ports
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Renaming Generated Ports : Time (s): cpu = 00:01:34 ; elapsed = 00:01:36 . Memory (MB): peak = 1614.824 ; gain = 1043.137
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
;
%s
*synth2#
!Start Handling Custom Attributes
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Handling Custom Attributes : Time (s): cpu = 00:01:34 ; elapsed = 00:01:36 . Memory (MB): peak = 1614.824 ; gain = 1043.137
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
8
%s
*synth2 
Start Renaming Generated Nets
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Renaming Generated Nets : Time (s): cpu = 00:01:34 ; elapsed = 00:01:36 . Memory (MB): peak = 1614.824 ; gain = 1043.137
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Start Writing Synthesis Report
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
/
%s
*synth2

Report BlackBoxes: 
h p
x
� 
8
%s
*synth2 
+-+--------------+----------+
h p
x
� 
8
%s
*synth2 
| |BlackBox name |Instances |
h p
x
� 
8
%s
*synth2 
+-+--------------+----------+
h p
x
� 
8
%s
*synth2 
+-+--------------+----------+
h p
x
� 
/
%s*synth2

Report Cell Usage: 
h px� 
5
%s*synth2
+------+----------+------+
h px� 
5
%s*synth2
|      |Cell      |Count |
h px� 
5
%s*synth2
+------+----------+------+
h px� 
5
%s*synth2
|1     |BUFG      |     2|
h px� 
5
%s*synth2
|2     |CARRY4    |    97|
h px� 
5
%s*synth2
|3     |LUT1      |     7|
h px� 
5
%s*synth2
|4     |LUT2      |   878|
h px� 
5
%s*synth2
|5     |LUT3      |   251|
h px� 
5
%s*synth2
|6     |LUT4      |   435|
h px� 
5
%s*synth2
|7     |LUT5      |   342|
h px� 
5
%s*synth2
|8     |LUT6      |  1257|
h px� 
5
%s*synth2
|9     |RAM256X1S |   128|
h px� 
5
%s*synth2
|10    |RAM32M    |    10|
h px� 
5
%s*synth2
|11    |RAM32X1D  |     4|
h px� 
5
%s*synth2
|12    |FDCE      |  1136|
h px� 
5
%s*synth2
|13    |FDPE      |    18|
h px� 
5
%s*synth2
|14    |FDRE      |   169|
h px� 
5
%s*synth2
|15    |IBUF      |     7|
h px� 
5
%s*synth2
|16    |OBUF      |     9|
h px� 
5
%s*synth2
+------+----------+------+
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Writing Synthesis Report : Time (s): cpu = 00:01:34 ; elapsed = 00:01:36 . Memory (MB): peak = 1614.824 ; gain = 1043.137
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
b
%s
*synth2J
HSynthesis finished with 0 errors, 1 critical warnings and 108 warnings.
h p
x
� 
�
%s
*synth2�
Synthesis Optimization Runtime : Time (s): cpu = 00:01:19 ; elapsed = 00:01:32 . Memory (MB): peak = 1614.824 ; gain = 952.129
h p
x
� 
�
%s
*synth2�
�Synthesis Optimization Complete : Time (s): cpu = 00:01:35 ; elapsed = 00:01:36 . Memory (MB): peak = 1614.824 ; gain = 1043.137
h p
x
� 
B
 Translating synthesized netlist
350*projectZ1-571h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002
00:00:00.1132

1620.0162
0.000Z17-268h px� 
U
-Analyzing %s Unisim elements for replacement
17*netlist2
239Z29-17h px� 
X
2Unisim Transformation completed in %s CPU seconds
28*netlist2
1Z29-28h px� 
K
)Preparing netlist for logic optimization
349*projectZ1-570h px� 
Q
)Pushed %s inverter(s) to %s load pin(s).
98*opt2
02
0Z31-138h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002
00:00:00.0022

1630.2702
0.000Z17-268h px� 
�
!Unisim Transformation Summary:
%s111*project2�
�  A total of 142 instances were transformed.
  RAM256X1S => RAM256X1S (MUXF7(x2), MUXF8, RAMS64E(x4)): 128 instances
  RAM32M => RAM32M (RAMD32(x6), RAMS32(x2)): 10 instances
  RAM32X1D => RAM32X1D (RAMD32(x2)): 4 instances
Z1-111h px� 
V
%Synth Design complete | Checksum: %s
562*	vivadotcl2

482b0ac4Z4-1430h px� 
C
Releasing license: %s
83*common2
	SynthesisZ17-83h px� 
�
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
1372
1082
552
0Z4-41h px� 
L
%s completed successfully
29*	vivadotcl2
synth_designZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
synth_design: 2

00:01:422

00:01:472

1630.2702

1301.582Z17-268h px� 
c
%s6*runtcl2G
ESynthesis results are not added to the cache due to CRITICAL_WARNING
h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Write ShapeDB Complete: 2

00:00:002
00:00:00.0082

1630.2702
0.000Z17-268h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2r
pC:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.runs/synth_1/RV32I46F5SPSoCTOP.dcpZ17-1381h px� 
�
Executing command : %s
56330*	planAhead2m
kreport_utilization -file RV32I46F5SPSoCTOP_utilization_synth.rpt -pb RV32I46F5SPSoCTOP_utilization_synth.pbZ12-24828h px� 
\
Exiting %s at %s...
206*common2
Vivado2
Sat Jun 28 13:50:34 2025Z17-206h px� 


End Record
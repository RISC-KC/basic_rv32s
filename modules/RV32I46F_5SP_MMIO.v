`include "modules/Program_Counter.v"
`include "modules/PC_Controller.v"
`include "modules/PC_Plus_4.v"
`include "modules/Instruction_Memory.v"
`include "modules/Instruction_Decoder.v"
`include "modules/Immediate_Generator.v"
`include "modules/Control_Unit.v"
`include "modules/Register_File.v"
`include "modules/Data_Memory.v"
`include "modules/ALU_Controller.v"
`include "modules/ALU.v"
`include "modules/Branch_Logic.v"
`include "modules/Byte_Enable_Logic.v"
`include "modules/CSR_File.v"
`include "modules/Exception_Detector.v"
`include "modules/Trap_Controller.v"

`include "modules/IF_ID_Register.v"
`include "modules/ID_EX_Register.v"
`include "modules/EX_MEM_Register.v"
`include "modules/MEM_WB_Register.v"

`include "modules/Hazard_Unit.v"
`include "modules/Forward_Unit.v"
`include "modules/Branch_Predictor.v"

`include "modules/MMIO_Interface.v"

`include "modules/headers/alu_src_select.vh"
`include "modules/headers/rf_wd_select.vh"

module RV32I46F5SPMMIO #(
    parameter XLEN = 32
)(
    input clk,
    input reset,
    input UART_busy,
    
    output wire [31:0] retire_instruction,
    output wire [7:0] mmio_uart_tx_data,
    output wire mmio_uart_tx_start
);

    // MMIO Interface
    reg [31:0] mmio_uart_tx_status;
    wire mmio_uart_status_hit;
    wire [XLEN-1:0] mmio_uart_status;

    // Program Counter and  PC Plus 4
    wire [XLEN-1:0] pc;
    wire [XLEN-1:0] pc_plus_4_signal;
    wire [XLEN-1:0] next_pc;
    
    // Instruction Memory and Debug Interface
    wire [31:0] im_instruction;
    wire [31:0] dbg_instruction = 32'b00000001011110110000110000110011; //add x24 = x22 + x23 = FFFF_FFBC + ABAD_BB02 = ABADBABE
    reg [31:0] instruction;
    wire [XLEN-1:0] IF_imm;
    wire [6:0] IF_opcode;

    // ROM bypass signals (MEM stage instruction memory access)
    wire [31:0] rom_address;
    wire [31:0] rom_read_data;

    assign IF_imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    assign IF_opcode = (instruction[6:0]);

    // Instruction Decoder
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [4:0] rs1;
    wire [4:0] rs2;
	wire [4:0] rd;
    wire [19:0] raw_imm;
    
    // Immediate Generator
    wire [XLEN-1:0] imm;

    // Control Unit
    wire pc_stall;
    wire jump;
	wire branch;
	wire [1:0] alu_src_A_select;
	wire [2:0] alu_src_B_select;
    wire memory_read;
	wire memory_write;
	wire register_file_write;
	wire [2:0] register_file_write_data_select;
    wire cu_csr_write_enable;

    // Branch Logic and Branch Predictor
    wire branch_taken;
    wire [XLEN-1:0] branch_target;
    wire [XLEN-1:0] branch_target_actual;

    // Register File
    reg [XLEN-1:0] register_file_write_data;
    
    // Register File
    wire [XLEN-1:0] read_data1;
    wire [XLEN-1:0] read_data2;

    // ALU Controller
    wire [3:0] alu_op;

    // ALUsrcA, srcB MUX
    reg [XLEN-1:0] src_A;
    reg [XLEN-1:0] src_B;

    // ALU
    wire [XLEN-1:0] alu_result;
    wire alu_zero;
	
    // Data Memory and Byte Enable Logic
    wire [XLEN-1:0] data_memory_read_data;
	wire [XLEN-1:0] byte_enable_logic_register_file_write_data;
    wire [XLEN-1:0] data_memory_write_data;
    wire [3:0] write_mask;

    // CSR File
    wire csr_write_enable;
    reg [11:0] csr_read_address;
    reg [11:0] csr_write_address;
    reg [XLEN-1:0] csr_write_data;
    wire [XLEN-1:0] csr_read_out;
    wire csr_ready;
    reg instruction_retired;

    // Exception_Detector
    wire trapped;
    wire [2:0]  trap_status;

    // Trap Controller
    wire trap_done;
    wire debug_mode;
    wire tc_csr_write_enable;
    wire [XLEN-1:0] trap_target;
    wire [11:0] csr_trap_address;
    wire [XLEN-1:0] csr_trap_write_data;
    wire pth_done_flush;
    
    // IF_ID_Register
    wire [XLEN-1:0] ID_pc;
    wire [XLEN-1:0] ID_pc_plus_4;
    wire [31:0] ID_instruction;
    wire ID_branch_estimation;

    // ID_EX_Register
    wire [XLEN-1:0] EX_pc;
    wire [XLEN-1:0] EX_pc_plus_4;
    wire EX_branch_estimation;
    wire [31:0] EX_instruction;

    // EX_MEM_Register
    wire EX_jump;
    wire EX_memory_read;
    wire EX_memory_write;
    wire [2:0] EX_register_file_write_data_select;
    wire EX_register_write_enable;
    wire EX_csr_write_enable;
    wire EX_branch;
    wire [1:0] EX_alu_src_A_select;
    wire [2:0] EX_alu_src_B_select;
    wire [6:0] EX_opcode;
    wire [2:0] EX_funct3;
    wire [6:0] EX_funct7;
    wire [4:0] EX_rd;
    wire [19:0] EX_raw_imm;
    wire [XLEN-1:0] EX_read_data1;
    wire [XLEN-1:0] EX_read_data2;
    wire [4:0] EX_rs1;
    wire [4:0] EX_rs2;
    wire [XLEN-1:0] EX_imm;
    wire [XLEN-1:0] EX_csr_read_data;

    wire [XLEN-1:0] MEM_pc;
    wire [XLEN-1:0] MEM_pc_plus_4;
    wire [31:0] MEM_instruction;

    wire MEM_memory_read;
    wire MEM_memory_write;
    wire [2:0] MEM_register_file_write_data_select;
    wire MEM_register_write_enable;
    wire MEM_csr_write_enable;
    wire [6:0] MEM_opcode;
    wire [2:0] MEM_funct3;
    wire [4:0] MEM_rs1;
    wire [4:0] MEM_rd;
    wire [XLEN-1:0] MEM_read_data2;
    wire [XLEN-1:0] MEM_imm;
    wire [19:0] MEM_raw_imm;
    wire [XLEN-1:0] MEM_csr_read_data;
    wire [XLEN-1:0] MEM_alu_result;

    wire [XLEN-1:0] WB_pc;
    wire [XLEN-1:0] WB_pc_plus_4;
    wire [31:0] WB_instruction;
    wire [6:0] WB_opcode;

    // MEM_WB_Register
    wire MEM_WB_flush;
    wire [2:0] WB_register_file_write_data_select;
    wire [XLEN-1:0] WB_imm;
    wire [19:0] WB_raw_imm;
    wire [XLEN-1:0] WB_csr_read_data;
    wire [XLEN-1:0] WB_alu_result;
    wire WB_register_write_enable;
    wire WB_csr_write_enable;
    wire [4:0] WB_rs1;
    wire [4:0] WB_rd;

    wire [XLEN-1:0] WB_byte_enable_logic_register_file_write_data;

    // Hazard Unit
    wire IF_ID_flush;
    wire ID_EX_flush;
    wire IF_ID_stall;
    wire ID_EX_stall;
    wire EX_MEM_stall;
    wire MEM_WB_stall;
    wire csr_hazard_mem;
    wire csr_hazard_wb;
    wire store_hazard_mem;
    wire store_hazard_wb;

    // Forward Unit
    wire [1:0] hazard_mem;
    wire [1:0] hazard_wb;
    wire [XLEN-1:0] csr_forward_data;
    wire [XLEN-1:0] alu_forward_source_data_a;
    wire [XLEN-1:0] alu_forward_source_data_b;
    wire [1:0] alu_forward_source_select_a;
    wire [1:0] alu_forward_source_select_b;
    reg [XLEN-1:0] alu_normal_source_a;
    reg [XLEN-1:0] alu_normal_source_b;

    reg [XLEN-1:0] retired_alu_result;
    reg [XLEN-1:0] retired_csr_read_data;

    wire [XLEN-1:0] store_forward_data;
    wire store_forward_enable;
    wire [XLEN-1:0] EX_read_data2_MUX;
    assign EX_read_data2_MUX = store_forward_enable ? store_forward_data : EX_read_data2;

    // Branch Predictor
    wire branch_estimation;
    
    wire [31:0] writeback_instruction = WB_instruction;
    assign retire_instruction = writeback_instruction;

    wire csr_write_enable_source;
    assign csr_write_enable_source = tc_csr_write_enable ? tc_csr_write_enable : WB_csr_write_enable;

    wire [XLEN-1:0] data_memory_read_data_muxed;
    assign data_memory_read_data_muxed = mmio_uart_status_hit ? mmio_uart_status : data_memory_read_data;

    ALU alu (
        .src_A(src_A),
        .src_B(src_B),
        .alu_op(alu_op),

        .alu_result(alu_result),
        .alu_zero(alu_zero)
    );

    ALUController alu_controller (
        .opcode(EX_opcode),
	    .funct3(EX_funct3),
        .funct7_5(EX_funct7[5]),
        .imm_10(EX_imm[10]),
	
        .alu_op(alu_op)
    );

    BranchLogic branch_logic (
        .branch(EX_branch),
        .branch_estimation(EX_branch_estimation),
        .funct3(EX_funct3),
        .alu_zero(alu_zero),
        .pc(EX_pc),
        .imm(EX_imm),
    
        .branch_taken(branch_taken),
        .branch_prediction_miss(branch_prediction_miss),
        .branch_target_actual(branch_target_actual)
    );

    BranchPredictor #(.XLEN(XLEN)) branch_predictor(
        .clk(clk),
        .reset(reset),
        .IF_opcode(IF_opcode),
        .IF_pc (pc),
        .IF_imm (IF_imm),
        .EX_branch(EX_branch),
        .EX_branch_taken (branch_taken),

        .branch_estimation (branch_estimation),
        .branch_target (branch_target)
    );

    ByteEnableLogic byte_enable_logic (
        .memory_read(MEM_memory_read),
        .memory_write(MEM_memory_write),
        .funct3(MEM_funct3),
	    .register_file_read_data(MEM_read_data2),
	    .data_memory_read_data(data_memory_read_data_muxed),
	    .address(MEM_alu_result[1:0]),
	
	    .register_file_write_data(byte_enable_logic_register_file_write_data),
	    .data_memory_write_data(data_memory_write_data),
        .write_mask(write_mask)
    );

    ControlUnit control_unit (
        .write_done(1'b1),
	    .opcode(opcode),
	    .funct3(funct3),
        .trap_done(trap_done),
        .csr_ready(csr_ready),
        .IF_ID_stall(IF_ID_stall),

        .pc_stall(pc_stall),
        .jump(jump),
	    .branch(branch),
	    .alu_src_A_select(alu_src_A_select),
	    .alu_src_B_select(alu_src_B_select),
	    .register_file_write(register_file_write),
	    .register_file_write_data_select(register_file_write_data_select),
	    .memory_read(memory_read),
	    .memory_write(memory_write),
        .csr_write_enable(cu_csr_write_enable)
    );

    CSRFile #(.XLEN(XLEN)) csr_file (
        .clk(clk),
        .reset(reset),
        .trapped(trapped),
        .csr_write_enable(csr_write_enable_source),
        .csr_read_address(csr_read_address),
        .csr_write_address(csr_write_address),
        .csr_write_data(csr_write_data),
        .instruction_retired(instruction_retired),

        .csr_read_out(csr_read_out),
        .csr_ready(csr_ready) 
    );

    DataMemory data_memory (
        .clk(clk),
        .write_enable(MEM_memory_write && !mmio_uart_status_hit),   // UART status 조회시 ROM이므로 쓰기 방지.
        .address(MEM_alu_result),
        .write_data(data_memory_write_data),
        .write_mask(write_mask),
        .rom_read_data(rom_read_data),
        .rom_address(rom_address),

        .read_data(data_memory_read_data)
    );

    ExceptionDetector exception_detector (
        .clk(clk),
        .reset(reset),
        .ID_opcode(opcode),
        .ID_funct3(funct3),
        .EX_opcode(EX_opcode),
        .EX_funct3(EX_funct3),
        .MEM_opcode(MEM_opcode),
        .MEM_funct3(MEM_funct3),
        .raw_imm(raw_imm[11:0]),
        .EX_raw_imm(EX_raw_imm[11:0]),
        .csr_write_enable(cu_csr_write_enable),
        .alu_result(alu_result[1:0]), // for jump_target_lsbs and data_memory_address_lsbs
        .MEM_alu_result(MEM_alu_result[1:0]),
        .branch_target_lsbs(branch_target[1:0]),
        .branch_estimation(branch_estimation),

        .trapped(trapped),
        .trap_status(trap_status)
    );

    ForwardUnit forward_unit (
        .hazard_mem(hazard_mem),
        .hazard_wb(hazard_wb),
        .MEM_imm(MEM_imm),
        .MEM_alu_result(MEM_alu_result),
        .MEM_csr_read_data(MEM_csr_read_data),
        .byte_enable_logic_register_file_write_data(byte_enable_logic_register_file_write_data),
        .MEM_pc_plus_4(MEM_pc_plus_4),
        .MEM_opcode(MEM_opcode),
        .WB_opcode(WB_opcode),
        .WB_imm(WB_imm),
        .WB_alu_result(WB_alu_result),
        .WB_csr_read_data(WB_csr_read_data),
        .WB_byte_enable_logic_register_file_write_data(WB_byte_enable_logic_register_file_write_data),
        .WB_pc_plus_4(WB_pc_plus_4),
        .alu_forward_source_data_a(alu_forward_source_data_a),
        .alu_forward_source_data_b(alu_forward_source_data_b),
        .alu_forward_source_select_a(alu_forward_source_select_a),
        .alu_forward_source_select_b(alu_forward_source_select_b),

        .store_forward_data(store_forward_data),
        .store_forward_enable(store_forward_enable),

        .csr_hazard_mem(csr_hazard_mem),
        .csr_hazard_wb(csr_hazard_wb),
        .MEM_csr_write_data(MEM_alu_result),
        .WB_csr_write_data(WB_alu_result),
        .store_hazard_mem(store_hazard_mem),
        .store_hazard_wb(store_hazard_wb),
        .csr_read_data(csr_read_out),

        .csr_forward_data(csr_forward_data)
    );

    HazardUnit hazard_unit (
        .clk(clk),
        .reset(reset),
        .trap_done(trap_done),
        .standby_mode(standby_mode),
        .trap_status(trap_status),
        .misaligned_instruction_flush(misaligned_instruction_flush),
        .misaligned_memory_flush(misaligned_memory_flush),
        .pth_done_flush(pth_done_flush),
        .csr_ready(csr_ready),
        .ID_rs1(rs1),
        .ID_rs2(rs2),
        .ID_raw_imm(raw_imm[11:0]),
        .EX_csr_write_enable(EX_csr_write_enable),
        .MEM_rd(MEM_rd),
        .MEM_register_write_enable(MEM_register_write_enable),
        .MEM_csr_write_enable(MEM_csr_write_enable),
        .MEM_csr_write_address(MEM_raw_imm[11:0]),
        .WB_rd(WB_rd),
        .WB_register_write_enable(WB_register_write_enable),
        .WB_csr_write_enable(WB_csr_write_enable),
        .WB_csr_write_address(WB_raw_imm[11:0]),
        .EX_rs1(EX_rs1),
        .EX_rs2(EX_rs2),
        .EX_rd(EX_rd),
        .EX_opcode(EX_opcode),
        .EX_imm(EX_raw_imm[11:0]),
        .branch_prediction_miss(branch_prediction_miss),
        .EX_jump(EX_jump),

        .hazard_mem(hazard_mem),
        .hazard_wb(hazard_wb),
        .csr_hazard_mem(csr_hazard_mem),
        .csr_hazard_wb(csr_hazard_wb),
        //.csr_reg_hazard(csr_reg_hazard),
        .store_hazard_mem(store_hazard_mem),
        .store_hazard_wb(store_hazard_wb),

        .IF_ID_flush(IF_ID_flush),
        .ID_EX_flush(ID_EX_flush),
        .EX_MEM_flush(EX_MEM_flush),
        .MEM_WB_flush(MEM_WB_flush),
        .IF_ID_stall(IF_ID_stall),
        .ID_EX_stall(ID_EX_stall),
        .EX_MEM_stall(EX_MEM_stall),
        .MEM_WB_stall(MEM_WB_stall)
    );

    ImmediateGenerator immediate_generator (
        .raw_imm(raw_imm),
        .opcode(opcode),
        .imm(imm)
    );

    InstructionDecoder instruction_decoder (
        .instruction(ID_instruction),
        .opcode(opcode),
	    .funct3(funct3),
	    .funct7(funct7),
	    .rs1(rs1),
	    .rs2(rs2),
	    .rd(rd),
	    .raw_imm(raw_imm)
    );

    InstructionMemory instruction_memory (
        .pc(pc),
        .instruction(im_instruction),
        .rom_address(rom_address),
        .rom_read_data(rom_read_data)
    );

    MMIO_Interface mmio_interface (
        .clk(clk),
        .reset(reset),
        .data_memory_write_data(data_memory_write_data),
        .data_memory_address(MEM_alu_result),
        .data_memory_write_enable(MEM_memory_write),
        .UART_busy(UART_busy),

        .mmio_uart_tx_data(mmio_uart_tx_data),
        .mmio_uart_status(mmio_uart_status),
        .mmio_uart_tx_start(mmio_uart_tx_start),
        .mmio_uart_status_hit(mmio_uart_status_hit)
    );

    ProgramCounter program_counter (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    PCPlus4 pc_plus_4 (
        .pc(pc),
        .pc_plus_4(pc_plus_4_signal)
    );

    PCController pc_controller (
        .jump(EX_jump),
        .branch_estimation(branch_estimation),
        .branch_prediction_miss(branch_prediction_miss),
        .trapped(trapped),
	    .pc(pc),
        .jump_target(alu_result),
        .branch_target(branch_target),
        .branch_target_actual(branch_target_actual),
	    .trap_target(trap_target),
        .pc_stall(pc_stall),
	    .next_pc(next_pc)
    );

    RegisterFile register_file (
        .clk(clk),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(WB_rd),
        .write_data(register_file_write_data),
        .write_enable(WB_register_write_enable),
	
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    TrapController #(.XLEN(XLEN))trap_controller (
        .clk(clk),
        .reset(reset),
        .trap_status(trap_status),
        .ID_pc(ID_pc),
        .EX_pc(EX_pc),
        .MEM_pc(MEM_pc),
        .WB_pc(WB_pc),
        .csr_read_data(csr_read_out),

        .debug_mode(debug_mode),
        .trap_target(trap_target),
        .trap_done(trap_done),
        .misaligned_instruction_flush(misaligned_instruction_flush),
        .misaligned_memory_flush(misaligned_memory_flush),
        .pth_done_flush(pth_done_flush),
        .standby_mode(standby_mode),
        .csr_write_enable(tc_csr_write_enable),
        .csr_trap_address(csr_trap_address),
        .csr_trap_write_data(csr_trap_write_data)
    );

    IF_ID_Register #(.XLEN(XLEN)) if_id_register (
        .clk(clk),
		.reset(reset),
        .flush(IF_ID_flush),
        .IF_ID_stall(IF_ID_stall),

        // Signals from IF Phase
        .IF_pc(pc),
        .IF_pc_plus_4(pc_plus_4_signal),
        .IF_instruction(instruction),
        .IF_branch_estimation(branch_estimation),

        // Signals to ID_EX_Register and ID Phase
        .ID_pc(ID_pc),
        .ID_pc_plus_4(ID_pc_plus_4),
        .ID_instruction(ID_instruction),
        .ID_branch_estimation(ID_branch_estimation)
    );

    ID_EX_Register #(.XLEN(XLEN)) id_ex_register (
        .clk(clk),
		.reset(reset),
        .flush(ID_EX_flush),
        .ID_EX_stall(ID_EX_stall),
        
        // Signals from IF_ID_Register
        .ID_pc(ID_pc),
        .ID_pc_plus_4(ID_pc_plus_4),
        .ID_branch_estimation(ID_branch_estimation),
        .ID_instruction(ID_instruction),

        // Signals from ID Phase
        .ID_jump(jump),
        .ID_branch(branch),
        .ID_alu_src_A_select(alu_src_A_select),
        .ID_alu_src_B_select(alu_src_B_select),
        .ID_memory_read(memory_read),
        .ID_memory_write(memory_write),
        .ID_register_file_write_data_select(register_file_write_data_select),
        .ID_register_write_enable(register_file_write),
        .ID_csr_write_enable(cu_csr_write_enable),
        .ID_opcode(opcode), 
        .ID_funct3(funct3),
        .ID_funct7(funct7),
        .ID_rd(rd),
        .ID_raw_imm(raw_imm),
        .ID_read_data1(read_data1),
        .ID_read_data2(read_data2),
        .ID_rs1(rs1),
        .ID_rs2(rs2),
        .ID_imm(imm),
        .ID_csr_read_data(csr_read_out),

        // Signals to EX_MEM_Register
        .EX_pc(EX_pc),
        .EX_pc_plus_4(EX_pc_plus_4),
        .EX_branch_estimation(EX_branch_estimation),
        .EX_instruction(EX_instruction),

        .EX_jump(EX_jump),
        .EX_branch(EX_branch),
        .EX_alu_src_A_select(EX_alu_src_A_select),
        .EX_alu_src_B_select(EX_alu_src_B_select),
        .EX_memory_read(EX_memory_read),
        .EX_memory_write(EX_memory_write),
        .EX_register_file_write_data_select(EX_register_file_write_data_select),
        .EX_register_write_enable(EX_register_write_enable),
        .EX_csr_write_enable(EX_csr_write_enable),
        .EX_opcode(EX_opcode),
        .EX_funct3(EX_funct3),
        .EX_funct7(EX_funct7),
        .EX_rd(EX_rd),
        .EX_raw_imm(EX_raw_imm),
        .EX_read_data1(EX_read_data1),
        .EX_read_data2(EX_read_data2),
        .EX_rs1(EX_rs1),
        .EX_rs2(EX_rs2),
        .EX_imm(EX_imm),
        .EX_csr_read_data(EX_csr_read_data)
    );

    EX_MEM_Register #(.XLEN(XLEN)) ex_mem_register (
        .clk(clk),
		.reset(reset),
        .flush(EX_MEM_flush),
        .EX_MEM_stall(EX_MEM_stall),

        // Signals from ID_EX_Register
        .EX_pc(EX_pc),
        .EX_pc_plus_4(EX_pc_plus_4),
        .EX_instruction(EX_instruction),

        .EX_memory_read(EX_memory_read),
        .EX_memory_write(EX_memory_write),
        .EX_register_file_write_data_select(EX_register_file_write_data_select),
        .EX_register_write_enable(EX_register_write_enable),
        .EX_csr_write_enable(EX_csr_write_enable),
        .EX_opcode(EX_opcode),
        .EX_funct3(EX_funct3),
        .EX_rs1(EX_rs1),
        .EX_rd(EX_rd),
        .EX_raw_imm(EX_raw_imm),
        .EX_read_data2(EX_read_data2_MUX),
        .EX_imm(EX_imm),
        .EX_csr_read_data(EX_csr_read_data),

        // Signal from EX Phase
        .EX_alu_result(alu_result),

        // Signals to MEM_WB_Register
        .MEM_pc(MEM_pc),
        .MEM_pc_plus_4(MEM_pc_plus_4),
        .MEM_instruction(MEM_instruction),
        .MEM_memory_read(MEM_memory_read),
        .MEM_memory_write(MEM_memory_write),
        .MEM_register_file_write_data_select(MEM_register_file_write_data_select),
        .MEM_register_write_enable(MEM_register_write_enable),
        .MEM_csr_write_enable(MEM_csr_write_enable),
        .MEM_opcode(MEM_opcode),
        .MEM_funct3(MEM_funct3),
        .MEM_rs1(MEM_rs1),
        .MEM_rd(MEM_rd),
        .MEM_raw_imm(MEM_raw_imm),
        .MEM_read_data2(MEM_read_data2),
        .MEM_imm(MEM_imm),
        .MEM_csr_read_data(MEM_csr_read_data),
        .MEM_alu_result(MEM_alu_result)
    );

    MEM_WB_Register #(.XLEN(XLEN)) mem_wb_register (
        .clk(clk),
		.reset(reset),
        .MEM_WB_stall(MEM_WB_stall),
        .flush(MEM_WB_flush),

        // Signals from EX_MEM_Register
        .MEM_pc(MEM_pc),
        .MEM_pc_plus_4(MEM_pc_plus_4),
        .MEM_instruction(MEM_instruction),

        .MEM_register_file_write_data_select(MEM_register_file_write_data_select),
        .MEM_imm(MEM_imm),
        .MEM_csr_read_data(MEM_csr_read_data),
        .MEM_alu_result(MEM_alu_result),
        .MEM_register_write_enable(MEM_register_write_enable),
        .MEM_csr_write_enable(MEM_csr_write_enable),
        .MEM_rs1(MEM_rs1),
        .MEM_rd(MEM_rd),
        .MEM_raw_imm(MEM_raw_imm),
        .MEM_opcode(MEM_opcode),

        // Signal from MEM Phase
        .MEM_byte_enable_logic_register_file_write_data(byte_enable_logic_register_file_write_data),

        // Signals to WB Phase
        .WB_pc(WB_pc),
        .WB_pc_plus_4(WB_pc_plus_4),
        .WB_instruction(WB_instruction),
        .WB_register_file_write_data_select(WB_register_file_write_data_select),
        .WB_imm(WB_imm),
        .WB_csr_read_data(WB_csr_read_data),
        .WB_alu_result(WB_alu_result),
        .WB_register_write_enable(WB_register_write_enable),
        .WB_csr_write_enable(WB_csr_write_enable),
        .WB_rs1(WB_rs1),
        .WB_rd(WB_rd),
        .WB_raw_imm(WB_raw_imm),
        .WB_opcode(WB_opcode),
        .WB_byte_enable_logic_register_file_write_data(WB_byte_enable_logic_register_file_write_data)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            retired_alu_result <= {XLEN{1'b0}};
            retired_csr_read_data <= {XLEN{1'b0}};

            instruction_retired <= 1'b0;
        end else begin
            retired_alu_result <= WB_alu_result;
            retired_csr_read_data <= WB_csr_read_data;

            if (!MEM_WB_stall && !MEM_WB_flush && 
                WB_instruction != 32'h00000013) begin
                instruction_retired <= 1'b1;
            end else begin
                instruction_retired <= 1'b0;
            end
        end
    end

    always @(*) begin
        if (EX_alu_src_A_select == `ALU_SRC_A_RD1) begin
            alu_normal_source_a = EX_read_data1;
        end
        else if (EX_alu_src_A_select == `ALU_SRC_A_PC) begin
            alu_normal_source_a = EX_pc;
        end
        else if (EX_alu_src_A_select == `ALU_SRC_A_RS1) begin
            alu_normal_source_a = {27'b0, EX_rs1};
        end
        else begin
            alu_normal_source_a = 32'b0;
        end

        if (EX_alu_src_B_select == `ALU_SRC_B_RD2) begin
            alu_normal_source_b = EX_read_data2;
        end
        else if (EX_alu_src_B_select == `ALU_SRC_B_IMM) begin
            alu_normal_source_b = EX_imm;
        end
        else if (EX_alu_src_B_select == `ALU_SRC_B_SHAMT) begin
            alu_normal_source_b = {27'b0, EX_imm[4:0]};
        end
        else if (EX_alu_src_B_select == `ALU_SRC_B_CSR) begin
            alu_normal_source_b = csr_forward_data;
        end
        else begin
            alu_normal_source_b = 32'b0;
        end

        if (!standby_mode && trapped) begin
            csr_write_data  = csr_trap_write_data;
            csr_write_address = csr_trap_address;
            csr_read_address = csr_trap_address;
        end
        else begin
            csr_write_data = WB_alu_result;
            csr_write_address = WB_raw_imm[11:0];
            csr_read_address = raw_imm[11:0];
        end

        if (debug_mode) instruction = dbg_instruction;
        else instruction = im_instruction;

        case (WB_register_file_write_data_select)
            `RF_WD_LOAD: begin
                register_file_write_data = WB_byte_enable_logic_register_file_write_data;
            end
            `RF_WD_ALU: begin
                register_file_write_data = WB_alu_result;
            end
            `RF_WD_LUI: begin
                register_file_write_data = WB_imm;
            end
            `RF_WD_JUMP: begin
                register_file_write_data = WB_pc_plus_4;
            end
            `RF_WD_CSR: begin
                /*if (csr_reg_hazard) begin
                    register_file_write_data = retired_alu_result;
                end else */begin
                    register_file_write_data = WB_csr_read_data; 
                end
            end
            default: begin
                register_file_write_data = 32'b0;
            end
        endcase

        case (alu_forward_source_select_a)
            2'b10: src_A = alu_forward_source_data_a;
            2'b11: src_A = alu_forward_source_data_a;
            default: src_A = alu_normal_source_a;
        endcase

        case (alu_forward_source_select_b)
            2'b10: src_B = alu_forward_source_data_b;
            2'b11: src_B = alu_forward_source_data_b;
            default: src_B = alu_normal_source_b;
        endcase
    end

endmodule
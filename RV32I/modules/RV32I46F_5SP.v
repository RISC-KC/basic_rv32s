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

`include "modules/headers/alu_src_select.vh"
`include "modules/headers/rf_wd_select.vh"

module RV32I46F5SP #(
    parameter XLEN = 32
)(
    input clk,
    input reset
);
    // Program Counter and  PC Plus 4
    wire [31:0] pc;
    wire [31:0] pc_plus_4_signal;
    wire [31:0] next_pc;
    
    // Instruction Memory and Debug Interface
    wire [31:0] im_instruction;
    wire [31:0] dbg_instruction = 32'b00000001011110110000110000110011; //add x24 = x22 + x23 = FFFF_FFBC + ABAD_BB02 = ABADBABE
    reg [31:0] instruction;
    wire [31:0] IF_imm;
    wire [6:0] IF_opcode;

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
    wire [31:0] imm;

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
    wire [31:0] branch_target;

    // Register File
    reg [31:0] register_file_write_data;
    
    // Register File
    wire [31:0] read_data1;
    wire [31:0] read_data2;

    // ALU Controller
    wire [3:0] alu_op;

    // ALUsrcA, srcB MUX
    reg [31:0] src_A;
    reg [31:0] src_B;

    // ALU
    wire [31:0] alu_result;
    wire alu_zero;
	
    // Data Memory and Byte Enable Logic
    wire [31:0] data_memory_read_data;
    wire [31:0] data_memory_address;
	wire [31:0] byte_enable_logic_register_file_write_data;
    wire [31:0] data_memory_write_data;
    wire [3:0] write_mask;

    // CSR File
    wire csr_write_enable;
    reg [11:0] csr_address;
    reg [31:0] csr_write_data;
    wire [31:0] csr_read_data;

    // Exception_Detector
    wire trapped;
    wire [2:0]  trap_status;

    // Trap Controller
    wire trap_done;
    wire debug_mode;
    wire tc_csr_write_enable;
    wire [31:0] trap_target;
    wire [11:0] csr_trap_address;
    wire [31:0] csr_trap_write_data;

    // IF_ID_Register
    wire [XLEN-1:0] IF_pc;
    wire [XLEN-1:0] IF_pc_plus_4;
    wire [31:0] IF_instruction;
    wire IF_branch_estimation;

    wire [XLEN-1:0] ID_pc;
    wire [XLEN-1:0] ID_pc_plus_4;
    wire [31:0] ID_instruction;
    wire ID_branch_estimation;

    // ID_EX_Register
    wire ID_jump;
    wire ID_branch;
    wire [1:0] ID_alu_src_A_select;
    wire [2:0] ID_alu_src_B_select;
    wire ID_memory_read;
    wire ID_memory_write;
    wire [2:0] ID_register_file_write_data_select;
    wire ID_register_write_enable;
    wire ID_csr_write_enable;
    wire [6:0] ID_opcode; 
    wire [2:0] ID_funct3;
    wire [6:0] ID_funct7;
    wire [4:0] ID_rd;
    wire [4:0] ID_rs2;
    wire [11:0] ID_raw_imm;
    wire [XLEN-1:0] ID_read_data1;
    wire [XLEN-1:0] ID_read_data2;
    wire [4:0] ID_rs1;
    wire [XLEN-1:0] ID_imm;
    wire [XLEN-1:0] ID_csr_read_data;

    wire [XLEN-1:0] EX_pc;
    wire [XLEN-1:0] EX_pc_plus_4;
    wire EX_branch_estimation;

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
    wire [11:0] EX_raw_imm;
    wire [XLEN-1:0] EX_read_data1;
    wire [XLEN-1:0] EX_read_data2;
    wire [4:0] EX_rs1;
    wire [XLEN-1:0] EX_imm;
    wire [XLEN-1:0] EX_csr_read_data;

    wire [XLEN-1:0] EX_alu_result;

    wire [XLEN-1:0] MEM_pc_plus_4;

    wire MEM_memory_read;
    wire MEM_memory_write;
    wire [2:0] MEM_register_file_write_data_select;
    wire MEM_register_write_enable;
    wire MEM_csr_write_enable;
    wire [6:0] MEM_opcode;
    wire [2:0] MEM_funct3;
    wire [4:0] MEM_rd;
    wire [XLEN-1:0] MEM_byte_enable_logic_register_file_write_data;
    wire [XLEN-1:0] MEM_read_data2;
    wire [XLEN-1:0] MEM_imm;
    wire [XLEN-1:0] MEM_csr_read_data;
    wire [XLEN-1:0] MEM_alu_result;

    wire [XLEN-1:0] WB_pc_plus_4;

    // MEM_WB_Register
    wire [2:0] WB_register_file_write_data_select;
    wire [XLEN-1:0] WB_imm;
    wire [XLEN-1:0] WB_csr_read_data;
    wire [XLEN-1:0] WB_alu_result;
    wire WB_register_write_enable;
    wire WB_csr_write_enable;
    wire [4:0] WB_rd;

    wire [XLEN-1:0] WB_byte_enable_logic_register_file_write_data;

    // Hazard Unit
    wire [1:0] hazard_op;

    // Forward Unit
    wire [XLEN-1:0] alu_forward_source_data_a;
    wire [XLEN-1:0] alu_forward_source_data_b;
    wire [1:0] alu_forward_source_select_a;
    wire [1:0] alu_forward_source_select_b;

    assign csr_write_enable = cu_csr_write_enable | tc_csr_write_enable;

    ProgramCounter program_counter (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    PCController pc_controller (
        .jump(jump),
        .branch_taken(branch_estimation),
        .trapped(trapped),
	    .pc(pc),
        .jump_target(alu_result),
        .branch_target(branch_target),
	    .trap_target(trap_target),
        .pc_stall(pc_stall),
	    .next_pc(next_pc)
    );

    PCPlus4 pc_plus_4 (
        .pc(pc),
        .pc_plus_4(pc_plus_4_signal)
    );

    InstructionMemory instruction_memory (
        .pc(pc),
        .instruction(im_instruction)
    );

    InstructionDecoder instruction_decoder (
        /*.debug_mode(debug_mode),
        .im_instruction(im_instruction),
        .dbg_instruction(dbg_instruction),*/
        .instruction(instruction),
        .opcode(opcode),
	    .funct3(funct3),
	    .funct7(funct7),
	    .rs1(rs1),
	    .rs2(rs2),
	    .rd(rd),
	    .raw_imm(raw_imm)
    );

    ImmediateGenerator immediate_generator (
        .raw_imm(raw_imm),
        .opcode(opcode),
        .imm(imm)
    );

    ControlUnit control_unit (
        .write_done(1'b1),
	    .opcode(opcode),
	    .funct3(funct3),
        .trap_done(trap_done),
        .trapped(trapped),
        .branch_taken(branch_taken),

	    .branch(branch),
	    .alu_src_A_select(alu_src_A_select),
	    .alu_src_B_select(alu_src_B_select),
	    .register_file_write(register_file_write),
	    .register_file_write_data_select(register_file_write_data_select),
	    .memory_read(memory_read),
	    .memory_write(memory_write),
        .csr_write_enable(cu_csr_write_enable)
    );

    RegisterFile register_file (
        .clk(clk),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(register_file_write_data),
        .write_enable(register_file_write),
	
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    DataMemory data_memory (
        .clk(clk),
        .write_enable(memory_write),
        .address(alu_result[11:2]),
        .write_data(data_memory_write_data),
        .write_mask(write_mask),

        .read_data(data_memory_read_data)
    );

    ALUController alu_controller (
        .opcode(opcode),
	    .funct3(funct3),
        .funct7_5(funct7[5]),
        .imm_10(imm[10]),
	
        .alu_op(alu_op)
    );

    ALU alu (
        .src_A(src_A),
        .src_B(src_B),
        .alu_op(alu_op),

        .alu_result(alu_result),
        .alu_zero(alu_zero)
    );

    BranchLogic branch_logic (
        .branch(branch),
        .funct3(funct3),
        .alu_zero(alu_zero),
        .pc(pc),
        .imm(imm),
    
        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );

    ByteEnableLogic byte_enable_logic (
        .memory_read(memory_read),
        .memory_write(memory_write),
        .funct3(funct3),
	    .register_file_read_data(read_data2),
	    .data_memory_read_data(data_memory_read_data),
	    .address(alu_result),
	
	    .register_file_write_data(byte_enable_logic_register_file_write_data),
	    .data_memory_write_data(data_memory_write_data),
        .write_mask(write_mask)
    );

    CSRFile csr_file (
        .clk(clk),
        .reset(reset),
        .csr_write_enable(csr_write_enable),
        .csr_address(csr_address),
        .csr_write_data(csr_write_data),

        .csr_read_data(csr_read_data)
    );

    ExceptionDetector exception_detector (
        .opcode(opcode),
        .funct3(funct3),
        .funct12(raw_imm),
        .jump_target_lsbs(alu_result[1:0]),
        .branch_target_lsbs(branch_target[1:0]),

        .trapped(trapped),
        .trap_status(trap_status)
    );

    TrapController trap_controller (
        .clk(clk),
        .reset(reset),
        .trap_status(trap_status),
        .pc(pc),
        .csr_read_data(csr_read_data),

        .debug_mode(debug_mode),
        .trap_target(trap_target),
        .trap_done(trap_done),
        .csr_write_enable(tc_csr_write_enable),
        .csr_trap_address(csr_trap_address),
        .csr_trap_write_data(csr_trap_write_data)
    );

    IF_ID_Register if_id_register (
        .clk(clk),
		.reset(reset),
        .flush(flush),

        // Signals from IF Phase
        .IF_pc(pc),
        .IF_pc_plus_4(pc_plus_4_signal),
        .IF_instruction(instruction),
        .IF_branch_estimation(branch_estimation),

        // Signals to ID_EX_Register
        .ID_pc(ID_pc),
        .ID_pc_plus_4(ID_pc_plus_4),
        .ID_instruction(ID_instruction),
        .ID_branch_estimation(ID_branch_estimation)
    );

    ID_EX_Register id_ex_register (
        .clk(clk),
		.reset(reset),
        .flush(flush),
        
        // Signals from IF_ID_Register
        .ID_pc(ID_pc),
        .ID_pc_plus_4(ID_pc_plus_4),
        .ID_branch_estimation(ID_branch_estimation),

        // Signals from ID Phase
        .ID_jump(jump),
        .ID_branch(branch),
        .ID_alu_src_A_select(alu_src_A_select),
        .ID_alu_src_B_select(alu_src_B_select),
        .ID_memory_read(memory_read),
        .ID_memory_write(memory_write),
        .ID_register_file_write_data_select(register_file_write_data_select),
        .ID_register_write_enable(register_write_enable),
        .ID_csr_write_enable(csr_write_enable),
        .ID_opcode(opcode), 
        .ID_funct3(funct3),
        .ID_funct7(funct7),
        .ID_rd(rd),
        .ID_raw_imm(raw_imm),
        .ID_read_data1(read_data1),
        .ID_read_data2(read_data2),
        .ID_rs1(rs1),
        .ID_imm(imm),
        .ID_csr_read_data(csr_read_data),

        // Signals to EX_MEM_Register
        .EX_pc(EX_pc),
        .EX_pc_plus_4(EX_pc_plus_4),
        .EX_branch_estimation(EX_branch_estimation),
        .EX_jump(EX_jump),
        .EX_memory_read(EX_memory_read),
        .EX_memory_write(EX_memory_write),
        .EX_register_file_write_data_select(EX_register_file_write_data_select),
        .EX_register_write_enable(EX_register_write_enable),
        .EX_csr_write_enable(EX_csr_write_enable),
        .EX_branch(EX_branch),
        .EX_alu_src_A_select(EX_alu_src_A_select),
        .EX_alu_src_B_select(EX_alu_src_B_select),
        .EX_opcode(EX_opcode),
        .EX_funct3(EX_funct3),
        .EX_funct7(EX_funct7),
        .EX_rd(EX_rd),
        .EX_raw_imm(EX_raw_imm),
        .EX_read_data1(EX_read_data1),
        .EX_read_data2(EX_read_data2),
        .EX_rs1(EX_rs1),
        .EX_imm(EX_imm),
        .EX_csr_read_data(EX_csr_read_data)
    );

    EX_MEM_Register ex_mem_register (
        .clk(clk),
		.reset(reset),
        .flush(flush),

        // Signals from ID_EX_Register
        .EX_pc_plus_4(EX_pc_plus_4),
        .EX_memory_read(EX_memory_read),
        .EX_memory_write(EX_memory_write),
        .EX_register_file_write_data_select(EX_register_file_write_data_select),
        .EX_register_write_enable(EX_register_write_enable),
        .EX_csr_write_enable(EX_csr_write_enable),
        .EX_opcode(EX_opcode),
        .EX_funct3(EX_funct3),
        .EX_rd(EX_rd),
        .EX_read_data2(EX_read_data2),
        .EX_imm(EX_imm),
        .EX_csr_read_data(EX_csr_read_data),

        // Signal from EX Phase
        .EX_alu_result(alu_result),

        // Signals to MEM_WB_Register
        .MEM_pc_plus_4(MEM_pc_plus_4),
        .MEM_memory_read(MEM_memory_read),
        .MEM_memory_write(MEM_memory_write),
        .MEM_register_file_write_data_select(MEM_register_file_write_data_select),
        .MEM_register_write_enable(MEM_register_write_enable),
        .MEM_csr_write_enable(MEM_csr_write_enable),
        .MEM_opcode(MEM_opcode),
        .MEM_funct3(MEM_funct3),
        .MEM_rd(MEM_rd),
        .MEM_read_data2(MEM_read_data2),
        .MEM_imm(MEM_imm),
        .MEM_csr_read_data(MEM_csr_read_data),
        .MEM_alu_result(MEM_alu_result)
    );

    MEM_WB_Register mem_wb_register (
        .clk(clk),
		.reset(reset),
        .flush(flush),

        // Signals from EX_MEM_Register
        .MEM_pc_plus_4(MEM_pc_plus_4),
        .MEM_register_file_write_data_select(MEM_register_file_write_data_select),
        .MEM_imm(MEM_imm),
        .MEM_csr_read_data(MEM_csr_read_data),
        .MEM_alu_result(MEM_alu_result),
        .MEM_register_write_enable(MEM_register_write_enable),
        .MEM_csr_write_enable(MEM_csr_write_enable),
        .MEM_rd(MEM_rd),

        // Signal from MEM Phase
        .MEM_byte_enable_logic_register_file_write_data(byte_enable_logic_register_file_write_data),

        // Signals to WB Phase
        .WB_pc_plus_4(WB_pc_plus_4),
        .WB_register_file_write_data_select(WB_register_file_write_data_select),
        .WB_imm(WB_imm),
        .WB_csr_read_data(WB_csr_read_data),
        .WB_alu_result(WB_alu_result),
        .WB_register_write_enable(WB_register_write_enable),
        .WB_csr_write_enable(WB_csr_write_enable),
        .WB_rd(WB_rd),
        .WB_byte_enable_logic_register_file_write_data(WB_byte_enable_logic_register_file_write_data)
    );

    HazardUnit hazard_unit (
        .clk(clk),
        .reset(reset),
        .ID_rs1(ID_rs1),
        .ID_rs2(ID_rs2),
        .ID_rd(ID_rd),
        .branch_prediction_miss(branch_prediction_miss),
        .EX_jump(EX_jump),

        .hazard_op(hazard_op),
        .IF_ID_flush(IF_ID_flush)
    );

    ForwardUnit forward_unit (
    .hazard_op(hazard_op),
    .MEM_imm(MEM_imm),
    .MEM_alu_result(MEM_alu_result),
    .MEM_csr_read_data(MEM_csr_read_data),
    .MEM_byte_enable_logic_register_file_write_data(MEM_byte_enable_logic_register_file_write_data),
    .MEM_pc_plus_4(MEM_pc_plus_4),
    .MEM_opcode(MEM_opcode),
    .alu_forward_source_data_a(alu_forward_source_data_a),
    .alu_forward_source_data_b(alu_forward_source_data_b),
    .alu_forward_source_select_a(alu_forward_source_select_a),
    .alu_forward_source_select_b(alu_forward_source_select_b)
    );

    BranchPredictor #(.XLEN(XLEN)) branch_predictor(
        .clk(clk),
        .reset(reset),
        .IF_opcode(IF_opcode),
        .IF_pc (IF_pc),
        .IF_imm (IF_imm),
        .EX_pc (EX_pc),
        .EX_imm (EX_imm),
        .EX_branch(EX_branch),
        .EX_branch_taken (EX_branch_taken),

        .branch_estimation (branch_estimation),
        .branch_target (branch_target)
    );

    always @(*) begin
        if (alu_src_A_select == `ALU_SRC_A_RD1) begin
            src_A = read_data1;
        end
        else if (alu_src_A_select == `ALU_SRC_A_PC) begin
            src_A = pc;
        end
        else if (alu_src_A_select == `ALU_SRC_A_RS1) begin
            src_A = {27'b0, rs1};
        end
        else begin
            src_A = 32'b0;
        end

        if (alu_src_B_select == `ALU_SRC_B_RD2) begin
            src_B = read_data2;
        end
        else if (alu_src_B_select == `ALU_SRC_B_IMM) begin
            src_B = imm;
        end
        else if (alu_src_B_select == `ALU_SRC_B_SHAMT) begin
            src_B = {27'b0, imm[4:0]};
        end
        else if (alu_src_B_select == `ALU_SRC_B_CSR) begin
            src_B = csr_read_data;
        end
        else begin
            src_B = 32'b0;
        end

        if (trapped) begin
            csr_write_data  = csr_trap_write_data;
            csr_address     = csr_trap_address;
        end
        else begin
            csr_write_data  = alu_result;
            csr_address     = raw_imm[11:0];
        end

        if (debug_mode) instruction = dbg_instruction;
        else instruction = im_instruction;

        case (register_file_write_data_select)
            `RF_WD_LOAD: begin
                register_file_write_data = byte_enable_logic_register_file_write_data;
            end
            `RF_WD_ALU: begin
                register_file_write_data = alu_result;
            end
            `RF_WD_LUI: begin
                register_file_write_data = imm;
            end
            `RF_WD_JUMP: begin
                register_file_write_data = pc_plus_4_signal;
            end
            `RF_WD_CSR: begin
                register_file_write_data = csr_read_data;
            end
            default: begin
                register_file_write_data = 32'b0;
            end
        endcase
    end

endmodule
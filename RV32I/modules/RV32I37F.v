`include "modules/Program_Counter.v"
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

`include "modules/headers/alu_src_select.vh"
`include "modules/headers/rf_wd_select.vh"

module RV32I37F (
    input clk,
    input reset
);

    wire [31:0] pc;
    wire [31:0] pc_plus_4_signal;

    wire [31:0] next_pc;

    wire [31:0] instruction;

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [4:0] rs1;
    wire [4:0] rs2;
	wire [4:0] rd;
    wire [31:0] raw_imm;
    
    wire [31:0] imm;

    wire jump;
	wire branch;
	wire [1:0] alu_src_A_select;
	wire [1:0] alu_src_B_select;
    wire memory_read;
	wire memory_write;
	wire register_file_write;
	wire [2:0] register_file_write_data_select;

    reg [31:0] register_file_write_data;
    
    wire [31:0] read_data1;
    wire [31:0] read_data2;

    wire [3:0] alu_op;

    reg [31:0] src_A;
    reg [31:0] src_B;

    wire [31:0] alu_result;
    wire alu_zero;
	
    wire [31:0] data_memory_read_data;
    wire [31:0] data_memory_address;
	wire [31:0] byte_enable_logic_register_file_write_data;
    wire [31:0] data_memory_write_data;
    wire [3:0] write_mask;

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

    InstructionMemory instruction_memory (
        .pc(pc),
        .instruction(instruction)
    );

    InstructionDecoder instruction_decoder (
        .instr(instruction),
        .opcode(opcode),
	    .funct3(funct3),
	    .funct7(funct7),
	    .rs1(rs1),
	    .rs2(rs2),
	    .rd(rd),
	    .imm(raw_imm)
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

        .jump(jump),
	    .branch(branch),
	    .alu_src_A_select(alu_src_A_select),
	    .alu_src_B_select(alu_src_B_select),
	    .register_file_write(register_file_write),
	    .register_file_write_data_select(register_file_write_data_select),
	    .memory_read(memory_read),
	    .memory_write(memory_write)
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
        .read_enable(memory_read),
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
    
        .branch_taken(branch_taken)
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

    always @(*) begin
        if (alu_src_A_select == `ALU_SRC_A_RD1) begin
            src_A = read_data1;
        end
        else if (alu_src_A_select == `ALU_SRC_A_PC) begin
            src_A = pc;
        end

        if (alu_src_B_select == `ALU_SRC_B_RD2) begin
            src_B = read_data2;
        end
        else if (alu_src_B_select == `ALU_SRC_B_IMM) begin
            src_B = imm;
        end

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
            default: begin
                register_file_write_data = 32'b0;
            end
        endcase
    end

endmodule

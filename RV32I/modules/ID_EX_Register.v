module ID_EX_Register #(
    parameter XLEN = 32
)(
    // pipeline register control signals
    input wire clk,
    input wire reset,
    input wire flush,
    input wire ID_EX_stall,

    // signal from IF phase
    // input wire [XLEN-1:0] IF_PC but why? What was this for?

    // signals from IF/ID register
    input wire [XLEN-1:0] ID_pc,
    input wire [XLEN-1:0] ID_pc_plus_4,
    input wire ID_branch_estimation,
    input wire [31:0] ID_instruction,

    // signals from ID phase
    input wire ID_jump,
    input wire ID_branch,
    input wire [1:0] ID_alu_src_A_select,
    input wire [2:0] ID_alu_src_B_select,
    input wire ID_memory_read,
    input wire ID_memory_write,
    input wire [2:0] ID_register_file_write_data_select,
    input wire ID_register_write_enable,
    input wire ID_csr_write_enable,
    input wire [6:0] ID_opcode, 
    input wire [2:0] ID_funct3,
    input wire [6:0] ID_funct7,
    input wire [4:0] ID_rd,
    input wire [19:0] ID_raw_imm,
    input wire [XLEN-1:0] ID_read_data1,
    input wire [XLEN-1:0] ID_read_data2,
    input wire [4:0] ID_rs1,
    input wire [4:0] ID_rs2,
    input wire [XLEN-1:0] ID_imm,
    input wire [XLEN-1:0] ID_csr_read_data,

    // signals to EX/MEM register
    output reg [XLEN-1:0] EX_pc,
    output reg [XLEN-1:0] EX_pc_plus_4,
    output reg EX_branch_estimation,
    output reg [31:0] EX_instruction,

    output reg EX_jump,
    output reg EX_memory_read,
    output reg EX_memory_write,
    output reg [2:0] EX_register_file_write_data_select,
    output reg EX_register_write_enable,
    output reg EX_csr_write_enable,
    output reg EX_branch,
    output reg [1:0] EX_alu_src_A_select,
    output reg [2:0] EX_alu_src_B_select,
    output reg [6:0] EX_opcode,
    output reg [2:0] EX_funct3,
    output reg [6:0] EX_funct7,
    output reg [4:0] EX_rd,
    output reg [19:0] EX_raw_imm,
    output reg [XLEN-1:0] EX_read_data1,
    output reg [XLEN-1:0] EX_read_data2,
    output reg [4:0] EX_rs1,
    output reg [4:0] EX_rs2,
    output reg [XLEN-1:0] EX_imm,
    output reg [XLEN-1:0] EX_csr_read_data
);

always @(posedge clk or posedge reset) begin
    if (reset || flush) begin
        EX_pc <= {XLEN{1'b0}};
        EX_pc_plus_4 <= {XLEN{1'b0}};
        EX_branch_estimation <= 1'b0;
        EX_instruction <= 32'h0000_0013; // ADDI x0, x0, 0 = RISC-V NOP, HINT

        EX_jump <= 1'b0;
        EX_memory_read <= 1'b0;
        EX_memory_write <= 1'b0;
        EX_register_file_write_data_select <= 3'b0;
        EX_register_write_enable <= 1'b0;
        EX_csr_write_enable <= 1'b0;
        EX_branch <= 1'b0;
        EX_alu_src_A_select <= 2'b0;
        EX_alu_src_B_select <= 3'b0;
        EX_opcode <= 7'b0;
        EX_funct3 <= 3'b0;
        EX_funct7 <= 7'b0;
        EX_rd <= 5'b0;
        EX_raw_imm <= 20'b0;
        EX_read_data1 <= {XLEN{1'b0}};
        EX_read_data2 <= {XLEN{1'b0}};
        EX_rs1 <= 5'b0;
        EX_rs2 <= 5'b0;
        EX_imm <= {XLEN{1'b0}};
        EX_csr_read_data <= {XLEN{1'b0}};
    end else if (!ID_EX_stall) begin
        EX_pc <= ID_pc;
        EX_pc_plus_4 <= ID_pc_plus_4;
        EX_branch_estimation <= ID_branch_estimation;
        EX_instruction <= ID_instruction;

        EX_jump <= ID_jump;
        EX_memory_read <= ID_memory_read;
        EX_memory_write <= ID_memory_write;
        EX_register_file_write_data_select <= ID_register_file_write_data_select;
        EX_register_write_enable <= ID_register_write_enable;
        EX_csr_write_enable <= ID_csr_write_enable;
        EX_branch <= ID_branch;
        EX_alu_src_A_select <= ID_alu_src_A_select;
        EX_alu_src_B_select <= ID_alu_src_B_select;
        EX_opcode <= ID_opcode;
        EX_funct3 <= ID_funct3;
        EX_funct7 <= ID_funct7;
        EX_rd <= ID_rd;
        EX_raw_imm <= ID_raw_imm;
        EX_read_data1 <= ID_read_data1;
        EX_read_data2 <= ID_read_data2;
        EX_rs1 <= ID_rs1;
        EX_rs2 <= ID_rs2;
        EX_imm <= ID_imm;
        EX_csr_read_data <= ID_csr_read_data;
    end 
end

endmodule
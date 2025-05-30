module MEM_WB_Register #(
    parameter XLEN = 32
)(
    // pipeline register control signals
    input wire clk,
    input wire reset,
    input wire flush,

    // signals from EX/MEM register
    input wire [XLEN-1:0] MEM_pc,
    input wire [XLEN-1:0] MEM_pc_plus_4,
    input wire [XLEN-1:0] MEM_instruction,

    input wire [2:0] MEM_register_file_write_data_select,
    input wire [XLEN-1:0] MEM_imm,
    input wire [XLEN-1:0] MEM_csr_read_data,
    input wire [XLEN-1:0] MEM_alu_result,
    input wire MEM_register_write_enable,
    input wire MEM_csr_write_enable,
    input wire [4:0] MEM_rd,

    // signals from MEM phase
    input wire [XLEN-1:0] MEM_byte_enable_logic_register_file_write_data,

    // signals to MEM register
    output reg [XLEN-1:0] WB_pc,
    output reg [XLEN-1:0] WB_pc_plus_4,
    output reg [XLEN-1:0] WB_instruction,

    output reg [2:0] WB_register_file_write_data_select,
    output reg [XLEN-1:0] WB_imm,
    output reg [XLEN-1:0] WB_csr_read_data,
    output reg [XLEN-1:0] WB_alu_result,
    output reg WB_register_write_enable,
    output reg WB_csr_write_enable,
    output reg [4:0] WB_rd,

    output reg [XLEN-1:0] WB_byte_enable_logic_register_file_write_data
);

always @(posedge clk or posedge reset) begin
    if (reset || flush) begin
        WB_pc <= 32'b0;
        WB_pc_plus_4 <= {XLEN{1'b0}};
        WB_instruction <= 32'h0000_0013;

        WB_register_file_write_data_select <= 3'b0;
        WB_imm <= {XLEN{1'b0}};
        WB_csr_read_data <= {XLEN{1'b0}};
        WB_alu_result <= {XLEN{1'b0}};
        WB_register_write_enable <= 1'b0;
        WB_csr_write_enable <= 1'b0;
        WB_rd <= 5'b0;
        
        WB_byte_enable_logic_register_file_write_data <= {XLEN{1'b0}};
    end else begin
        WB_pc <= MEM_pc;
        WB_instruction <= MEM_instruction;

        WB_register_file_write_data_select <= MEM_register_file_write_data_select;
        WB_imm <= MEM_imm;
        WB_csr_read_data <= MEM_csr_read_data;
        WB_alu_result <= MEM_alu_result;
        WB_register_write_enable <= MEM_register_write_enable;
        WB_csr_write_enable <= MEM_csr_write_enable;
        WB_rd <= MEM_rd;
        
        WB_byte_enable_logic_register_file_write_data <= MEM_byte_enable_logic_register_file_write_data;
    end
end

endmodule

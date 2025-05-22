module EX_MEM_Register #(
    parameter XLEN = 32;
)(
    // pipeline register control signals
    input wire clk,
    input wire reset,
    input wire flush,

    // signals from ID/EX register
    input wire [XLEN-1:0] EX_pc_plus_4,

    input wire EX_memory_read,
    input wire EX_memory_write,
    input wire [2:0] EX_register_file_write_data_select,
    input wire [6:0] EX_opcode,
    input wire [2:0] EX_funct3,
    input wire [XLEN-1:0] EX_read_data2, // Register File to Data Memory read data
    input wire [XLEN-1:0] EX_imm,
    input wire [XLEN-1:0] EX_csr_read_data,

    // signals from EX phase
    input wire [XLEN-1:0] EX_alu_result,

    // signals to EX/MEM register
    output reg [XLEN-1:0] MEM_pc_plus_4,

    output reg MEM_memory_read,
    output reg MEM_memory_write,
    output reg [2:0] MEM_register_file_write_data_select,
    output reg [6:0] MEM_opcode,
    output reg [2:0] MEM_funct3,
    output reg [XLEN-1:0] MEM_read_data2,
    output reg [XLEN-1:0] MEM_imm,
    output reg [XLEN-1:0] MEM_csr_read_data,

    output reg [XLEN-1:0] MEM_alu_result
);

always @(posedge clk or posedge reset) begin
    if (reset or flush) begin
        MEM_pc_plus_4 <= {XLEN{1'b0}};

        MEM_memory_read <= 1'b0;
        MEM_memory_write <= 1'b0;
        MEM_register_file_write_data_select <= 3'b0;
        MEM_opcode <= 7'b0;
        MEM_funct3 <= 3'b0;
        MEM_read_data2 <= {XLEN{1'b0}};
        MEM_imm <= {XLEN{1'b0}};
        MEM_csr_read_data <= {XLEN{1'b0}};

        MEM_alu_result <= {XLEN{1'b0}};
    end else begin
        MEM_pc_plus_4 <= EX_pc_plus_4;

        MEM_memory_read <= EX_memory_read;
        MEM_memory_write <= EX_memory_write;
        MEM_register_file_write_data_select <= EX_register_file_write_data_select;
        MEM_opcode <= EX_opcode;
        MEM_funct3 <= EX_funct3;
        MEM_read_data2 <= EX_read_data2;
        MEM_imm <= EX_imm;
        MEM_csr_read_data <= EX_csr_read_data;
    end
end

endmodule

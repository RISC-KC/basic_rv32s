module MEM_WB_Register #(
    parameter XLEN = 32;
)(
    // pipeline register control signals
    input wire clk,
    input wire reset,
    input wire flush,

    // signals from EX/MEM register
    input wire [XLEN-1:0] MEM_pc_plus_4,

    input wire [2:0] MEM_register_file_write_data_select,
    input wire [XLEN-1:0] MEM_imm,
    input wire [XLEN-1:0] MEM_csr_read_data,
    input wire [XLEN-1:0] MEM_alu_result,

    // signals from MEM phase
    input wire [XLEN-1:0] MEM_register_file_write_data,

    // signals to MEM register
    output reg [XLEN-1:0] WB_pc_plus_4,

    output reg [2:0] WB_register_file_write_data_select,
    output reg [XLEN-1:0] WB_register_file_write_data,
    output reg [XLEN-1:0] WB_imm,
    output reg [XLEN-1:0] WB_csr_read_data,

    output reg [XLEN-1:0] WB_alu_result
);

always @(posedge clk or posedge reset) begin
    if (reset or flush) begin
        WB_pc_plus_4 <= {XLEN{1'b0}};

        WB_register_file_write_data_select <= 3'b0;
        WB_register_file_write_data <= {XLEN{1'b0}};
        WB_imm <= {XLEN{1'b0}};
        WB_csr_read_data <= {XLEN{1'b0}};

        WB_alu_result <= {XLEN{1'b0}};
    end else begin
        WB_pc_plus_4 <= MEM_pc_plus_4;

        WB_register_file_write_data_select <= MEM_register_file_write_data_select;
        WB_register_file_write_data <= MEM_register_file_write_data;
        WB_imm <= MEM_imm;
        WB_csr_read_data <= MEM_csr_read_data;

        WB_alu_result <= MEM_alu_result;
    end
end

endmodule

`include "modules/headers/opcode.vh"

module ForwardUnit #(
    parameter XLEN = 32
)(
    input wire [1:0] hazard_op,                    // signal indicating data hazard has been occured
    input wire [XLEN-1:0] MEM_imm,              // from EX/MEM Register for LUI
    input wire [XLEN-1:0] MEM_alu_result,       
    input wire [XLEN-1:0] MEM_csr_read_data,
    input wire [XLEN-1:0] MEM_byte_enable_logic_register_file_write_data,
    input wire [XLEN-1:0] MEM_pc_plus_4,        // from EX/MEM Register
    input wire [6:0] MEM_opcode,            // from EX/MEM Register

    output wire [XLEN-1:0] alu_forward_source_data_a,    // Forwarded source A data signal
    output wire [XLEN-1:0] alu_forward_source_data_b,    // Forwarded source B data signal
    output wire [1:0] alu_forward_source_select_a, // ALU source A selection between normal source and forwarded source
    output wire [1:0] alu_forward_source_select_b // ALU source B selection between normal source and forwarded source
);
    reg [31:0] forward_data_value;

    assign alu_forward_source_select_a = hazard_op[0] ? 2'b10 : 2'b01;
    assign alu_forward_source_select_b = hazard_op[1] ? 2'b10 : 2'b01;

    assign alu_forward_source_data_a = hazard_op[0] ? forward_data_value : {XLEN{1'b0}};
    assign alu_forward_source_data_b = hazard_op[1] ? forward_data_value : {XLEN{1'b0}};

    always @(*) begin
        case (MEM_opcode)
            `OPCODE_LOAD : forward_data_value = MEM_byte_enable_logic_register_file_write_data;
            `OPCODE_ENVIRONMENT : forward_data_value = MEM_csr_read_data;
            `OPCODE_LUI : forward_data_value = MEM_imm;
            `OPCODE_JAL :  forward_data_value = MEM_pc_plus_4;
            `OPCODE_JALR : forward_data_value = MEM_pc_plus_4;
            default: forward_data_value = MEM_alu_result;
        endcase
    end

endmodule
`include "modules/headers/opcode.vh"

module ForwardUnit #(
    parameter XLEN = 32
)(
    // Hazard signals from Hazard Unit - ALU forwarding
    input wire [1:0] hazard_mem,
    input wire [1:0] hazard_wb,

    // Hazard signals from Hazard Unit - Store data forwarding
    input wire store_hazard_mem,
    input wire store_hazard_wb,

    // MEM stage signals 
    input wire [XLEN-1:0] MEM_imm,              // from EX/MEM Register for LUI
    input wire [XLEN-1:0] MEM_alu_result,       
    input wire [XLEN-1:0] MEM_csr_read_data,
    input wire [XLEN-1:0] byte_enable_logic_register_file_write_data,
    input wire [XLEN-1:0] MEM_pc_plus_4,        // from EX/MEM Register
    input wire [6:0] MEM_opcode,            // from EX/MEM Register

    // WB stage signals 
    input wire [XLEN-1:0] WB_imm,              // from EX/MEM Register for LUI
    input wire [XLEN-1:0] WB_alu_result,       
    input wire [XLEN-1:0] WB_csr_read_data,
    input wire [XLEN-1:0] WB_byte_enable_logic_register_file_write_data,
    input wire [XLEN-1:0] WB_pc_plus_4,        // from EX/MEM Register
    input wire [6:0] WB_opcode,            // from EX/MEM Register

    // CSR hazard signals
    input wire csr_hazard_mem,
    input wire csr_hazard_wb,
    input wire [31:0] MEM_csr_write_data,
    input wire [31:0] WB_csr_write_data,
    input wire [31:0] csr_read_data,

    // ALU forwarding signals 
    output wire [XLEN-1:0] alu_forward_source_data_a,    // Forwarded source A data signal
    output wire [XLEN-1:0] alu_forward_source_data_b,    // Forwarded source B data signal
    output wire [1:0] alu_forward_source_select_a, // ALU source A selection between normal source and forwarded source
    output wire [1:0] alu_forward_source_select_b, // ALU source B selection between normal source and forwarded source

    // Store data forwarding outputs
    output wire [XLEN-1:0] store_forward_data,
    output wire store_forward_enable,

    // CSR forward output
    output wire [31:0] csr_forward_data
);
    reg [31:0] MEM_forward_data_value;
    reg [31:0] WB_forward_data_value;
    reg [31:0] csr_forward_data_value;

    // ALU source A forwarding
    assign alu_forward_source_select_a = 
            hazard_mem[0] ? 2'b10 : 
            hazard_wb[0] ? 2'b11 : 2'b00;
    assign alu_forward_source_select_b = 
            hazard_mem[1] ? 2'b10 :
            hazard_wb[1] ? 2'b11 : 2'b00;

    assign alu_forward_source_data_a = 
            hazard_mem[0] ? MEM_forward_data_value : 
            hazard_wb[0] ? WB_forward_data_value : {XLEN{1'b0}};
    assign alu_forward_source_data_b = 
            hazard_mem[1] ? MEM_forward_data_value : 
            hazard_wb[1] ? WB_forward_data_value : {XLEN{1'b0}};

    // Store data forwarding
    assign store_forward_enable = store_hazard_mem || store_hazard_wb;
    assign store_forward_data = store_hazard_mem ? MEM_forward_data_value : 
                                store_hazard_wb ? WB_forward_data_value : {XLEN{1'b0}};

    assign csr_forward_data = csr_forward_data_value;

    always @(*) begin
        case (MEM_opcode)
            `OPCODE_LOAD : MEM_forward_data_value = byte_enable_logic_register_file_write_data;
            `OPCODE_ENVIRONMENT : MEM_forward_data_value = MEM_csr_read_data;
            `OPCODE_LUI : MEM_forward_data_value = MEM_imm;
            `OPCODE_JAL :  MEM_forward_data_value = MEM_pc_plus_4;
            `OPCODE_JALR : MEM_forward_data_value = MEM_pc_plus_4;
            default: MEM_forward_data_value = MEM_alu_result;
        endcase

        case (WB_opcode)
            `OPCODE_LOAD : WB_forward_data_value = WB_byte_enable_logic_register_file_write_data;
            `OPCODE_ENVIRONMENT : WB_forward_data_value = WB_csr_read_data;
            `OPCODE_LUI : WB_forward_data_value = WB_imm;
            `OPCODE_JAL :  WB_forward_data_value = WB_pc_plus_4;
            `OPCODE_JALR : WB_forward_data_value = WB_pc_plus_4;
            default: WB_forward_data_value = WB_alu_result;
        endcase

    // CSR Forwarding
        if (csr_hazard_mem) begin
            csr_forward_data_value = MEM_csr_write_data;
        end else if (csr_hazard_wb) begin
            csr_forward_data_value = WB_csr_write_data;
        end else begin
            csr_forward_data_value = csr_read_data;
        end
    end

endmodule
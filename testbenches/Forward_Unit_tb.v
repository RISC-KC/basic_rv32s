`timescale 1ns/1ps
`include "modules/headers/opcode.vh"

module ForwardUnit_tb;
localparam XLEN = 32;

reg [1:0]  hazard_op;
reg [XLEN-1:0] MEM_imm;
reg [XLEN-1:0] MEM_alu_result;
reg [XLEN-1:0] MEM_csr_read_data;
reg [XLEN-1:0] MEM_byte_enable_logic_register_file_write_data;
reg [XLEN-1:0] MEM_pc_plus_4;
reg [6:0] MEM_opcode;

wire [XLEN-1:0] alu_forward_source_data_a;
wire [XLEN-1:0] alu_forward_source_data_b;
wire [1:0] alu_forward_source_select_a;
wire [1:0] alu_forward_source_select_b;

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

initial begin
    $dumpfile("testbenches/results/waveforms/ForwardUnit_tb.vcd");
    $dumpvars(0, ForwardUnit_tb);

    $display("==================== Forward Unit Test START ====================");
    // Initialize signals
    hazard_op = 2'b00;
    MEM_imm   = 32'hAAAA_0000;
    MEM_alu_result    = 32'hDEAD_BEEF;
    MEM_csr_read_data = 32'hFACE_CAFE;
    MEM_byte_enable_logic_register_file_write_data = 32'h1111_2222;
    MEM_pc_plus_4     = 32'h0040_1004;

    // Test 0 : no hazard (sel = 01, data = 0)
    MEM_opcode = `OPCODE_RTYPE; // ALU
    #1;
    $display("Test 0 : no hazard (sel = 01, data = 0)");
    $display("selA = %b selB = %b fwdA = %h fwdB = %h\n", alu_forward_source_select_a, alu_forward_source_select_b, alu_forward_source_data_a, alu_forward_source_data_b);

    // Test 1 : rs1 hazard only (LOAD)
    hazard_op = 2'b01;
    MEM_opcode = `OPCODE_LOAD;
    #1;
    $display("Test 1 : rs1 hazard only (LOAD)");
    $display("selA = %b selB = %b fwdA = %h fwdB = %h\n", alu_forward_source_select_a, alu_forward_source_select_b, alu_forward_source_data_a, alu_forward_source_data_b);
    
    // Test 2 : rs2 hazard only (JALR)
    hazard_op = 2'b10;
    MEM_opcode = `OPCODE_JALR;
    #1;
    $display("Test 2 : rs2 hazard only (JALR)");
    $display("selA = %b selB = %b fwdA = %h fwdB = %h\n", alu_forward_source_select_a, alu_forward_source_select_b, alu_forward_source_data_a, alu_forward_source_data_b);

    // Test 0 (again) : no hazard (sel=01, data=0)
    MEM_opcode = `OPCODE_RTYPE; // ALU
    hazard_op = 2'b00;
    #1;
    $display("Test 0 : no hazard (sel = 01, data = 0)");
    $display("selA = %b selB = %b fwdA = %h fwdB = %h\n", alu_forward_source_select_a, alu_forward_source_select_b, alu_forward_source_data_a, alu_forward_source_data_b);

    // Test 3 : both hazards (CSR) ------------
    hazard_op = 2'b11;
    MEM_opcode = `OPCODE_ENVIRONMENT;
    #1;
    $display("Test 3 : both hazards (CSR)");
    $display("selA = %b selB = %b fwdA = %h fwdB = %h\n", alu_forward_source_select_a, alu_forward_source_select_b, alu_forward_source_data_a, alu_forward_source_data_b);

    $display("\n====================  Forward Unit Test END  ====================");
    $finish;
end
endmodule

`include "modules/headers/opcode.vh"

module HazardUnit (
    input wire clk,
    input wire reset,
    input wire trap_done,

    input wire [4:0] ID_rs1,
    input wire [4:0] ID_rs2,
    
    input wire [4:0] MEM_rd,
    input wire MEM_register_write_enable,
    input wire MEM_csr_write_enable,
    input wire [11:0] MEM_csr_write_address,       // MEM_imm[11:0]

    input wire [4:0] WB_rd,
    input wire WB_register_write_enable,
    input wire WB_csr_write_enable,
    input wire [11:0] WB_csr_write_address, // WB_imm[11:0]

    input wire [4:0] EX_rd,
    input wire EX_register_write_enable,
    input wire [6:0] EX_opcode,
    input wire [4:0] EX_rs1,
    input wire [4:0] EX_rs2,
    input wire [11:0] EX_imm,  // EX_imm[11:0]

    input wire EX_jump,
    input wire branch_prediction_miss,

    // to Forward Unit
    output reg [1:0] hazard_mem,
    output reg [1:0] hazard_wb,
    output wire csr_hazard_mem,
    output wire csr_hazard_wb,

    output reg IF_ID_flush,
    output reg ID_EX_flush,
    output reg pipeline_stall
);
    wire load_hazard = (EX_opcode == 7'b0000011 && (EX_rd != 5'd0) && ((EX_rd == ID_rs1) || (EX_rd == ID_rs2)));

    wire mem_hazard_rs1 = MEM_register_write_enable && (MEM_rd != 5'd0) && (MEM_rd == EX_rs1);
    wire mem_hazard_rs2 = MEM_register_write_enable && (MEM_rd != 5'd0) && (MEM_rd == EX_rs2);
    wire wb_hazard_rs1 = WB_register_write_enable && (WB_rd != 5'd0) && (WB_rd == EX_rs1);
    wire wb_hazard_rs2 = WB_register_write_enable && (WB_rd != 5'd0) && (WB_rd == EX_rs2);
    
    assign csr_hazard_mem = MEM_csr_write_enable && (MEM_csr_write_address == EX_imm);
    assign csr_hazard_wb = WB_csr_write_enable && (WB_csr_write_address == EX_imm);

    always @(*) begin
        hazard_mem = 2'b00;
        hazard_wb = 2'b00;
        IF_ID_flush = 1'b0;
        ID_EX_flush = 1'b0;
        pipeline_stall = 1'b0;

        hazard_mem[0] = mem_hazard_rs1;
        hazard_mem[1] = mem_hazard_rs2;
        hazard_wb[0] = wb_hazard_rs1 && !mem_hazard_rs1;
        hazard_wb[1] = wb_hazard_rs2 && !mem_hazard_rs2;

        if (load_hazard) begin
            pipeline_stall = 1'b1;
            ID_EX_flush = 1'b1;
        end


        if (EX_opcode == `OPCODE_ENVIRONMENT && EX_imm == 12'd0) begin
            ID_EX_flush = 1'b1;
        end else if (trap_done && (branch_prediction_miss || EX_jump)) begin
            IF_ID_flush = 1'b1;
            ID_EX_flush = 1'b1;
        end 

        if (!trap_done) begin
            pipeline_stall = 1'b1;
        end
    end


    
endmodule
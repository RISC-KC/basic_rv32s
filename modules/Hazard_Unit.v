`include "modules/headers/opcode.vh"
`include "modules/headers/trap.vh"

module HazardUnit (
    input clk,
    input reset, 

    input wire trap_done,
    input wire csr_ready,
    input wire standby_mode,
    input wire [2:0] trap_status,
    input wire misaligned_instruction_flush,
    input wire misaligned_memory_flush,
    input wire pth_done_flush,

    input wire [4:0] ID_rs1,
    input wire [4:0] ID_rs2,
    input wire [11:0] ID_raw_imm,
    
    input wire [4:0] MEM_rd,
    input wire MEM_register_write_enable,
    input wire MEM_csr_write_enable,
    input wire [11:0] MEM_csr_write_address,       // MEM_imm[11:0]

    input wire [4:0] WB_rd,
    input wire WB_register_write_enable,
    input wire WB_csr_write_enable,
    input wire [11:0] WB_csr_write_address, // WB_imm[11:0]

    input wire [4:0] EX_rd,
    input wire [6:0] EX_opcode,
    input wire [4:0] EX_rs1,
    input wire [4:0] EX_rs2,
    input wire [11:0] EX_imm,  // EX_imm[11:0]

    input wire EX_csr_write_enable,

    input wire EX_jump,
    input wire branch_prediction_miss,

    // to Forward Unit - ALU forwarding
    output reg [1:0] hazard_mem,
    output reg [1:0] hazard_wb,
    output wire csr_hazard_mem,
    output wire csr_hazard_wb,
    //output reg csr_reg_hazard,

    /// to Forward Unit - Store data forwarding
    output wire store_hazard_mem,
    output wire store_hazard_wb,

    output reg IF_ID_flush,
    output reg ID_EX_flush,
    output reg EX_MEM_flush,
    output reg MEM_WB_flush,
    
    output reg IF_ID_stall,
    output reg ID_EX_stall,
    output reg EX_MEM_stall,
    output reg MEM_WB_stall
);
    wire load_hazard = (EX_opcode == `OPCODE_LOAD && (EX_rd != 5'd0) && ((EX_rd == ID_rs1) || (EX_rd == ID_rs2)));

    // Store instruction detection
    wire is_store = (EX_opcode == `OPCODE_STORE);

    // Store instruction rs2 hazard detections
    assign store_hazard_mem = is_store && mem_hazard_rs2;
    assign store_hazard_wb = is_store && wb_hazard_rs2 && !mem_hazard_rs2;

    // wire reg_csr_hazard = (EX_opcode == `OPCODE_ENVIRONMENT && (WB_rd == retire_rd) && (WB_csr_write_address == retire_csr_write_address));

    // Register ALU hazard detections
    wire mem_hazard_rs1 = MEM_register_write_enable && (MEM_rd != 5'd0) && (MEM_rd == EX_rs1);
    wire mem_hazard_rs2 = MEM_register_write_enable && (MEM_rd != 5'd0) && (MEM_rd == EX_rs2);
    wire wb_hazard_rs1 = WB_register_write_enable && (WB_rd != 5'd0) && (WB_rd == EX_rs1);
    wire wb_hazard_rs2 = WB_register_write_enable && (WB_rd != 5'd0) && (WB_rd == EX_rs2);
    
    // CSR hazard detection
    assign csr_hazard_mem = MEM_csr_write_enable && (MEM_csr_write_address == EX_imm);
    assign csr_hazard_wb = WB_csr_write_enable && (WB_csr_write_address == EX_imm);

    reg [4:0] retire_rd;
    reg [11:0] retire_csr_write_address;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            retire_rd <= 5'b0;
            retire_csr_write_address <= 12'b0;    
        end else begin
            retire_rd <= WB_rd;
            retire_csr_write_address <= WB_csr_write_address;
        end
        
    end 

    always @(*) begin
        //csr_reg_hazard = 1'b0;
        hazard_mem = 2'b00;
        hazard_wb = 2'b00;
        IF_ID_flush = 1'b0;
        ID_EX_flush = 1'b0;
        EX_MEM_flush = 1'b0;
        MEM_WB_flush = 1'b0;
        
        IF_ID_stall = 1'b0;
        ID_EX_stall = 1'b0;
        EX_MEM_stall = 1'b0;
        MEM_WB_stall = 1'b0;

        // ALU forwarding hazards
        // For Store instructions, rs2 hazard shouldn't trigger ALUsrcB forwarding.
        // In this case, rs2 is store data, not ALU operand.
        hazard_mem[0] = mem_hazard_rs1;
        hazard_mem[1] = is_store ? 1'b0 : mem_hazard_rs2; // Disables ALUsrcB forwarding for store
        hazard_wb[0] = wb_hazard_rs1 && !mem_hazard_rs1;
        hazard_wb[1] = is_store ? 1'b0 : (wb_hazard_rs2 && !mem_hazard_rs2); // Disables ALUsrcB forwarding for store

        if (load_hazard) begin
            IF_ID_stall = 1'b1;
            ID_EX_stall = 1'b1;
            EX_MEM_stall = 1'b1;
            MEM_WB_stall = 1'b1;
            ID_EX_flush = 1'b1;
        end

        /*if (reg_csr_hazard) begin
            csr_reg_hazard = 1'b1;
        end*/

        if (trap_done && (branch_prediction_miss || EX_jump)) begin
            IF_ID_flush = 1'b1;
            ID_EX_flush = 1'b1;
        end

        if (pth_done_flush) begin
            IF_ID_flush = 1'b1;
            ID_EX_flush = 1'b1;
            EX_MEM_flush = 1'b1;
            MEM_WB_flush = 1'b1;
        end

        if (standby_mode) begin // For ID Phase Excpetion handling
            IF_ID_stall = 1'b1;
            ID_EX_stall = 1'b1;
            EX_MEM_stall = 1'b0;
            MEM_WB_stall = 1'b0;
        end else if (!trap_done || !csr_ready) begin
            IF_ID_stall = 1'b1;
            ID_EX_stall = 1'b1;
            EX_MEM_stall = 1'b1;
            MEM_WB_stall = 1'b1;
        end
    end


    
endmodule
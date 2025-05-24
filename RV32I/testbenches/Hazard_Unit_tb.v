`timescale 1ns/1ps

module HazardUnit_tb;
    reg clk = 0;
    reg reset = 0;
    reg [4:0] ID_rs1;
    reg [4:0] ID_rs2;
    reg [4:0] ID_rd;
    reg branch_prediction_miss; 
    reg EX_jump;

    wire hazard_op;
    wire IF_ID_flush;

    HazardUnit hazard_unit (
        .clk(clk),
        .reset(reset),
        .ID_rs1(ID_rs1),
        .ID_rs2(ID_rs2),
        .ID_rd(ID_rd),
        .branch_prediction_miss(branch_prediction_miss),
        .EX_jump(EX_jump),

        .hazard_op(hazard_op),
        .IF_ID_flush(IF_ID_flush)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/Hazard_Unit_tb_result.vcd");
        $dumpvars(0, HazardUnit_tb.hazard_unit);

        $display("==================== Hazard Unit Test START ====================\n");

        // reset signals
        reset = 1'b1;
        branch_prediction_miss = 0;
        EX_jump = 0;
        ID_rs1 = 0;
        ID_rs2 = 0;
        ID_rd = 0;
        #10;
        
        reset = 1'b0;
        @(posedge clk);

        // Test 1 : No RAW hazard
        ID_rs1 = 5'd1;
        ID_rs2 = 5'd2;
        ID_rd = 5'd3;   // rd = 3 now
        @(posedge clk);
        $display("Test 1 (No hazard)");
        $display("hazard_op = %b", hazard_op);
        $display("IF_ID_flush  = %b\n", IF_ID_flush);
        
        // Test 2 : rs1 hazard (prev rd == rs1)
        ID_rs1 = 5'd3;
        ID_rs2 = 5'd4;
        ID_rd = 5'd5;   // prev rd = 3
        @(posedge clk);
        $display("Test 2 (rs1 hazard) : hazard_op = %b (expect 1)", hazard_op);
        $display("IF_ID_flush  = %b (expect 0)\n", IF_ID_flush);

        // Test 3 : rs2 hazard (prev rd == rs2)
        ID_rs1 = 5'd6;
        ID_rs2 = 5'd5;
        ID_rd = 5'd7;   // prev rd = 5
        @(posedge clk);
        $display("Test 3 (rs2 hazard) : hazard_op = %b (expect 1)", hazard_op);
        $display("IF_ID_flush  = %b (expect 0)\n", IF_ID_flush);

        // Test 4 : no hazard 
        ID_rs1 = 5'd22;
        ID_rs2 = 5'd23;
        ID_rd = 5'd7;   // prev rd = 5
        @(posedge clk);
        $display("Test 4 (no hazard) : hazard_op = %b (expect 0)", hazard_op);
        $display("IF_ID_flush  = %b (expect 0)\n", IF_ID_flush);

        // Test 5 : both rs1/rs2 hazards
        ID_rs1 = 5'd7;
        ID_rs2 = 5'd7;
        ID_rd = 5'd8;   // prev rd = 7
        @(posedge clk);
        $display("Test 5 (both)       : hazard_op = %b (expect 1)", hazard_op);
        $display("IF_ID_flush  = %b (expect 0)\n", IF_ID_flush);

        // Test 6 : Branch‑mispredict flush
        branch_prediction_miss = 1'b1;
        @(posedge clk);
        $display("Test 6 (branch prediction miss): ");
        $display("hazard_op = %b (expect 0)", hazard_op);
        $display("IF_ID_flush  = %b (expect 1)\n", IF_ID_flush);

        branch_prediction_miss = 1'b0;

        // Test 7 : Jump flush
        EX_jump = 1'b1;
        @(posedge clk);
        $display("Test 7 (jump): ");
        $display("hazard_op = %b (expect 0)", hazard_op);
        $display("IF_ID_flush  = %b (expect 1)\n", IF_ID_flush);

        EX_jump = 1'b0;

        $display("==================== Hazard Unit Test END ====================\n");
        $stop;
    end

endmodule

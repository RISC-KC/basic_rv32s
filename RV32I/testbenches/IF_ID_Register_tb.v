`timescale 1ns/1ps

module IF_ID_Register_tb;
    localparam XLEN = 32;

    reg clk = 0;
    reg reset;
    reg flush;

    reg [XLEN-1:0] IF_pc;
    reg [XLEN-1:0] IF_pc_plus_4;
    reg [31:0] IF_instruction;
    reg IF_branch_estimation;

    wire [XLEN-1:0] ID_pc;
    wire [XLEN-1:0] ID_pc_plus_4;
    wire [31:0] ID_instruction;
    wire ID_branch_estimation;

    IF_ID_Register #(.XLEN(32)) if_id_register (
        .clk(clk),
		.reset(reset),
        .flush(flush),

        .IF_pc(IF_pc),
        .IF_pc_plus_4(IF_pc_plus_4),
        .IF_instruction(IF_instruction),
        .IF_branch_estimation(IF_branch_estimation),

        .ID_pc(ID_pc),
        .ID_pc_plus_4(ID_pc_plus_4),
        .ID_instruction(ID_instruction),
        .ID_branch_estimation(ID_branch_estimation)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/IF_ID_Register_tb_result.vcd");
        $dumpvars(0, IF_ID_Register_tb.if_id_register);

        // Test sequence
        $display("==================== IF_ID Register Test START ====================\n");

        // reset
        reset = 1'b1;
        #30;
        reset = 1'b0;
        @(posedge clk);
        $display("Input now\n Initial PC |     PC+4     |   instruction  | branch estimation |\n %h  |   %h   |    %h    |      %h      |\n", ID_pc, ID_pc_plus_4, ID_instruction, ID_branch_estimation);
        #10;
        
        // Test 1
        @(negedge clk); 
        IF_pc = 32'h00000000;
        IF_pc_plus_4 = 32'h0000_0004;
        IF_instruction = 32'h2bc0_0093; // ADDI:  x1 = x0 + 2BC
        IF_branch_estimation = 1'b0;
        @(posedge clk); #1;
        $display("Test 1: Previous value should be output now\n     PC    |     PC+4     |   instruction  | branch estimation |\n %h  |   %h   |    %h    |      %h      |\n", ID_pc, ID_pc_plus_4, ID_instruction, ID_branch_estimation);
        
        // Test 2@(posedge clk); #1;
        @(posedge clk); #1;
        $display("Test 2: No input(should be same)\n     PC    |     PC+4     |   instruction  | branch estimation |\n %h  |   %h   |    %h    |      %h      |\n", ID_pc, ID_pc_plus_4, ID_instruction, ID_branch_estimation);

        // Test 3
        @(negedge clk); 
        IF_pc = 32'h1111_1110;
        IF_pc_plus_4 = 32'h1111_1114;
        IF_instruction = 32'h2bc0_0093; // ADDI:  x1 = x0 + 2BC
        IF_branch_estimation = 1'b1; #1
        $display("Test 3-1: new input now(should be same) \n     PC    |     PC+4     |   instruction  | branch estimation |\n %h  |   %h   |    %h    |      %h      |\n", ID_pc, ID_pc_plus_4, ID_instruction, ID_branch_estimation);

        @(posedge clk); #1;
        $display("Test 3-2: Test 3-1 input should be output now \n     PC    |     PC+4     |   instruction  | branch estimation |\n %h  |   %h   |    %h    |      %h      |\n", ID_pc, ID_pc_plus_4, ID_instruction, ID_branch_estimation);

        flush = 1'b1; #10;
        flush = 1'b0;

        // Test 3
        $display("Test 4: Flushed (should be NOP and zero)\n     PC    |     PC+4     |   instruction  | branch estimation |\n %h  |   %h   |    %h    |      %h      |\n", ID_pc, ID_pc_plus_4, ID_instruction, ID_branch_estimation);
        IF_pc = 32'h1111_1110;
        IF_pc_plus_4 = 32'h1111_1114;
        IF_instruction = 32'h2bc0_0093; // ADDI:  x1 = x0 + 2BC
        IF_branch_estimation = 1'b1;
        $display("Test 5-1: Input begin (should be same)\n     PC    |     PC+4     |   instruction  | branch estimation |\n %h  |   %h   |    %h    |      %h      |\n", ID_pc, ID_pc_plus_4, ID_instruction, ID_branch_estimation);
        #10;
        $display("Test 5-2: Test 5-1's input should be output now\n     PC    |     PC+4     |   instruction  | branch estimation |\n %h  |   %h   |    %h    |      %h      |\n", ID_pc, ID_pc_plus_4, ID_instruction, ID_branch_estimation);

        $display("\n====================  IF_ID Register Test END  ====================");

        $stop;
    end

endmodule

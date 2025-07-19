`timescale 1ns/1ps

module MEM_WB_Register_tb;
    localparam XLEN = 32;

    reg clk = 0;
    reg reset = 0;
    reg flush = 0;

    reg [XLEN-1:0] MEM_pc_plus_4;

    // signals from 
    reg [2:0] MEM_register_file_write_data_select;
    reg [XLEN-1:0] MEM_imm;
    reg [XLEN-1:0] MEM_csr_read_data;
    reg [XLEN-1:0] MEM_alu_result;
    reg MEM_register_write_enable;
    reg MEM_csr_write_enable;
    reg [4:0] MEM_rd;

    // signals from MEM phase
    reg [XLEN-1:0] MEM_byte_enable_logic_register_file_write_data;

    wire [XLEN-1:0] WB_pc_plus_4;

    wire [2:0] WB_register_file_write_data_select;
    wire [XLEN-1:0] WB_imm;
    wire [XLEN-1:0] WB_csr_read_data;
    wire [XLEN-1:0] WB_alu_result;
    wire WB_register_write_enable;
    wire WB_csr_write_enable;
    wire [4:0] WB_rd;

    wire [XLEN-1:0] WB_byte_enable_logic_register_file_write_data;

    MEM_WB_Register #(.XLEN(32)) mem_wb_register (
        .clk(clk),
		.reset(reset),
        .flush(flush),

        .MEM_pc_plus_4(MEM_pc_plus_4),
        .MEM_register_file_write_data_select(MEM_register_file_write_data_select),
        .MEM_imm(MEM_imm),
        .MEM_csr_read_data(MEM_csr_read_data),
        .MEM_alu_result(MEM_alu_result),
        .MEM_register_write_enable(MEM_register_write_enable),
        .MEM_csr_write_enable(MEM_csr_write_enable),
        .MEM_rd(MEM_rd),
        .MEM_byte_enable_logic_register_file_write_data(MEM_byte_enable_logic_register_file_write_data),

        .WB_pc_plus_4(WB_pc_plus_4),
        .WB_register_file_write_data_select(WB_register_file_write_data_select),
        .WB_imm(WB_imm),
        .WB_csr_read_data(WB_csr_read_data),
        .WB_alu_result(WB_alu_result),
        .WB_register_write_enable(WB_register_write_enable),
        .WB_csr_write_enable(WB_csr_write_enable),
        .WB_rd(WB_rd),
        .WB_byte_enable_logic_register_file_write_data(WB_byte_enable_logic_register_file_write_data)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/MEM_WB_Register_tb_result.vcd");
        $dumpvars(0, MEM_WB_Register_tb.mem_wb_register);

        // Test sequence
        $display("==================== MEM_WB_Register Test START ====================\n");

        // reset
        reset = 1'b1;
        #30;
        reset = 1'b0;
        @(posedge clk);
        $display("Input now");
        $display("|     PC+4     | RF_WD select |  CSR Write Enable | RegF Write Enable |");
        $display("|   %h   |      %b     |         %b         |         %b         |", WB_pc_plus_4, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|    BERF_WD   |     imm    | csr_read_data |   ALU result   |   rd   |");
        $display("|   %h   |  %h  |   %h    |    %h    |  %b  |\n", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rd);
        #10;
        
        // Test 1
        @(negedge clk); 
        MEM_pc_plus_4                    = 32'h0000_0004;
        MEM_register_file_write_data_select = 3'b010;       // ALU result -> Register File
        MEM_imm                          = 32'h0000_0000;
        MEM_csr_read_data                = 32'h0000_0000;
        MEM_alu_result                   = 32'h0000_000B;   // ALU result = 11
        MEM_register_write_enable        = 1'b1;            // Register Write Enable
        MEM_csr_write_enable             = 1'b0;
        MEM_rd                           = 5'b00110;
        MEM_byte_enable_logic_register_file_write_data     = 32'h0000_000A;   // Dummy BERF_WD data value

        @(posedge clk); #1;
        $display("Test 1: Previous value should be output now");
        $display("|     PC+4     | RF_WD select |  CSR Write Enable | RegF Write Enable |");
        $display("|   %h   |      %b     |         %b         |         %b         |", WB_pc_plus_4, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|    BERF_WD   |     imm    | csr_read_data |   ALU result   |   rd   |");
        $display("|   %h   |  %h  |   %h    |    %h    |  %b  |\n", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rd);
        
        // Test 2@(posedge clk); #1;
        @(posedge clk); #1;
        $display("Test 2: No input(should be same)");
        $display("|     PC+4     | RF_WD select |  CSR Write Enable | RegF Write Enable |");
        $display("|   %h   |      %b     |         %b         |         %b         |", WB_pc_plus_4, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|    BERF_WD   |     imm    | csr_read_data |   ALU result   |   rd   |");
        $display("|   %h   |  %h  |   %h    |    %h    |  %b  |\n", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rd);

        // Test 3
        @(negedge clk); 
        MEM_pc_plus_4                    = 32'h0000_0008;
        MEM_register_file_write_data_select = 3'b001;       // D_RD → Register File
        MEM_imm                          = 32'h0000_0020;   // offset 32
        MEM_csr_read_data                = 32'h0000_0000;
        MEM_alu_result                   = 32'h1000_0020;   // ALU result = x3 + 32
        MEM_register_write_enable        = 1'b1;
        MEM_csr_write_enable             = 1'b0;
        MEM_rd                           = 5'b00111;
        MEM_byte_enable_logic_register_file_write_data     = 32'hDEAD_BEEF;   // Dummy BERF_WD data value
        $display("Test 3-1: new input now(should be same)");
        $display("|     PC+4     | RF_WD select |  CSR Write Enable | RegF Write Enable |");
        $display("|   %h   |      %b     |         %b         |         %b         |", WB_pc_plus_4, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|    BERF_WD   |     imm    | csr_read_data |   ALU result   |   rd   |");
        $display("|   %h   |  %h  |   %h    |    %h    |  %b  |\n", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rd);

        @(posedge clk); #1;
        $display("Test 3-2: Test 3-1 input should be output now \n");
        $display("|     PC+4     | RF_WD select |  CSR Write Enable | RegF Write Enable |");
        $display("|   %h   |      %b     |         %b         |         %b         |", WB_pc_plus_4, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|    BERF_WD   |     imm    | csr_read_data |   ALU result   |   rd   |");
        $display("|   %h   |  %h  |   %h    |    %h    |  %b  |\n", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rd);

        flush = 1'b1; #10;
        flush = 1'b0;

        // Test 3
        $display("Test 4: Flushed (should be NOP and zero)");
        $display("|     PC+4     | RF_WD select |  CSR Write Enable | RegF Write Enable |");
        $display("|   %h   |      %b     |         %b         |         %b         |", WB_pc_plus_4, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|    BERF_WD   |     imm    | csr_read_data |   ALU result   |   rd   |");
        $display("|   %h   |  %h  |   %h    |    %h    |  %b  |\n", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rd);

        MEM_pc_plus_4                    = 32'h0000_000C;
        MEM_register_file_write_data_select = 3'b011;       // CSR read → Register File
        MEM_imm                          = 32'h0000_0000;
        MEM_csr_read_data                = 32'hCAFE_BABE;   // CSR value
        MEM_alu_result                   = 32'h0000_0000;   // no ALU
        MEM_register_write_enable        = 1'b1;            // rd ← CSR
        MEM_csr_write_enable             = 1'b1;            // CSR write enable
        MEM_rd                           = 5'b10001;
        MEM_byte_enable_logic_register_file_write_data     = 32'hCAFE_BABE;   // Dummy BERF_WD data value
        $display("Test 5-1: Input begin (should be same)");
        $display("|     PC+4     | RF_WD select |  CSR Write Enable | RegF Write Enable |");
        $display("|   %h   |      %b     |         %b         |         %b         |", WB_pc_plus_4, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|    BERF_WD   |     imm    | csr_read_data |   ALU result   |   rd   |");
        $display("|   %h   |  %h  |   %h    |    %h    |  %b  |\n", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rd);
        #10;
        $display("Test 5-2: Test 5-1's input should be output now");
        $display("|     PC+4     | RF_WD select |  CSR Write Enable | RegF Write Enable |");
        $display("|   %h   |      %b     |         %b         |         %b         |", WB_pc_plus_4, WB_register_file_write_data_select, WB_csr_write_enable, WB_register_write_enable);
        $display("|    BERF_WD   |     imm    | csr_read_data |   ALU result   |   rd   |");
        $display("|   %h   |  %h  |   %h    |    %h    |  %b  |\n", WB_byte_enable_logic_register_file_write_data, WB_imm, WB_csr_read_data, WB_alu_result, WB_rd);

        $display("\n====================  MEM_WB_Register Test END  ====================");

        $stop;
    end

endmodule

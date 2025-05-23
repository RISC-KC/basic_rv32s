`timescale 1ns/1ps

module EX_MEM_Register_tb;
    localparam XLEN = 32;

    reg clk = 0;
    reg reset = 0;
    reg flush = 0;

    reg [XLEN-1:0] EX_pc_plus_4;

    reg EX_memory_read;
    reg EX_memory_write;
    reg [2:0] EX_register_file_write_data_select;
    reg EX_register_write_enable;
    reg EX_csr_write_enable;
    reg [6:0] EX_opcode; 
    reg [2:0] EX_funct3;
    reg [XLEN-1:0] EX_read_data2;
    reg [XLEN-1:0] EX_imm;
    reg [XLEN-1:0] EX_csr_read_data;

    reg [XLEN-1:0] EX_alu_result;

    wire [XLEN-1:0] MEM_pc_plus_4;

    wire MEM_memory_read;
    wire MEM_memory_write;
    wire [2:0] MEM_register_file_write_data_select;
    wire MEM_register_write_enable;
    wire MEM_csr_write_enable;
    wire [6:0] MEM_opcode;
    wire [2:0] MEM_funct3;
    wire [XLEN-1:0] MEM_read_data2;
    wire [XLEN-1:0] MEM_imm;
    wire [XLEN-1:0] MEM_csr_read_data;

    wire [XLEN-1:0] MEM_alu_result;

    EX_MEM_Register #(.XLEN(32)) ex_mem_register (
        .clk(clk),
		.reset(reset),
        .flush(flush),

        .EX_pc_plus_4(EX_pc_plus_4),

        .EX_memory_read(EX_memory_read),
        .EX_memory_write(EX_memory_write),
        .EX_register_file_write_data_select(EX_register_file_write_data_select),
        .EX_register_write_enable(EX_register_write_enable),
        .EX_csr_write_enable(EX_csr_write_enable),
        .EX_opcode(EX_opcode),
        .EX_funct3(EX_funct3),
        .EX_read_data2(EX_read_data2),
        .EX_imm(EX_imm),
        .EX_csr_read_data(EX_csr_read_data),

        .EX_alu_result(EX_alu_result),

        .MEM_pc_plus_4(MEM_pc_plus_4),

        .MEM_memory_read(MEM_memory_read),
        .MEM_memory_write(MEM_memory_write),
        .MEM_register_file_write_data_select(MEM_register_file_write_data_select),
        .MEM_register_write_enable(MEM_register_write_enable),
        .MEM_csr_write_enable(MEM_csr_write_enable),
        .MEM_opcode(MEM_opcode),
        .MEM_funct3(MEM_funct3),
        .MEM_read_data2(MEM_read_data2),
        .MEM_imm(MEM_imm),
        .MEM_csr_read_data(MEM_csr_read_data),

        .MEM_alu_result(MEM_alu_result)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/EX_MEM_Register_tb_result.vcd");
        $dumpvars(0, EX_MEM_Register_tb.ex_mem_register);

        // Test sequence
        $display("==================== EX_MEM Register Test START ====================\n");

        // reset
        reset = 1'b1;
        #30;
        reset = 1'b0;
        @(posedge clk);
        $display("Input now");
        $display("|     PC+4     | MEMread | MEMwrite | CSR WE | RegF WE | RF_WD select |  opcode  | funct3 |");
        $display("|   %h   |    %b    |     %b    |    %b   |    %b    |      %b     |  %b  |  %b  |", MEM_pc_plus_4, MEM_memory_read, MEM_memory_write, MEM_register_write_enable, MEM_csr_write_enable, MEM_register_file_write_data_select, MEM_opcode, MEM_funct3);
        $display("| Register RD2 |    imm    | csr_read_data |   ALU result   |");
        $display("|   %h   |  %h |   %h    |    %h    |\n", MEM_read_data2, MEM_imm, MEM_csr_read_data, MEM_alu_result);
        #10;
        
        // Test 1
        @(negedge clk); 
        EX_pc_plus_4               = 32'h0000_0008;   // (PC+4)
        EX_memory_read             = 1'b0;
        EX_memory_write            = 1'b1;            // Store
        EX_register_file_write_data_select = 3'b000;  // don't-care (store)
        EX_register_write_enable = 1'b1;
        EX_csr_write_enable = 1'b0;
        EX_opcode                  = 7'b0100011;      // STORE opcode
        EX_funct3                  = 3'b010;          // SW
        EX_read_data2              = 32'hDEAD_BEEF;   // Write Data
        EX_imm                     = 32'h0000_0010;   // offset 16
        EX_csr_read_data           = 32'h0000_0000;   // no CSR
        EX_alu_result              = 32'h1000_0040;   // Calculation result = x3 + 16

        @(posedge clk); #1;
        $display("Test 1: Previous value should be output now");
        $display("|     PC+4     | MEMread | MEMwrite | CSR WE | RegF WE | RF_WD select |  opcode  | funct3 |");
        $display("|   %h   |    %b    |     %b    |    %b   |    %b    |      %b     |  %b  |  %b  |", MEM_pc_plus_4, MEM_memory_read, MEM_memory_write, MEM_register_write_enable, MEM_csr_write_enable, MEM_register_file_write_data_select, MEM_opcode, MEM_funct3);
        $display("|   %h   |  %h |   %h    |    %h    |\n", MEM_read_data2, MEM_imm, MEM_csr_read_data, MEM_alu_result);
        
        // Test 2@(posedge clk); #1;
        @(posedge clk); #1;
        $display("Test 2: No input(should be same)");
        $display("|     PC+4     | MEMread | MEMwrite | CSR WE | RegF WE | RF_WD select |  opcode  | funct3 |");
        $display("|   %h   |    %b    |     %b    |    %b   |    %b    |      %b     |  %b  |  %b  |", MEM_pc_plus_4, MEM_memory_read, MEM_memory_write, MEM_register_write_enable, MEM_csr_write_enable, MEM_register_file_write_data_select, MEM_opcode, MEM_funct3);
        $display("| Register RD2 |    imm    | csr_read_data |   ALU result   |");
        $display("|   %h   |  %h |   %h    |    %h    |\n", MEM_read_data2, MEM_imm, MEM_csr_read_data, MEM_alu_result);

        // Test 3
        @(negedge clk); 
        EX_pc_plus_4               = 32'h0000_0010;
        EX_memory_read             = 1'b1;            // Load
        EX_memory_write            = 1'b0;
        EX_register_file_write_data_select = 3'b001;  // D_RD -> Register File
        EX_register_write_enable = 1'b0;
        EX_csr_write_enable = 1'b1;
        EX_opcode                  = 7'b0000011;      // LOAD opcode
        EX_funct3                  = 3'b010;          // LW
        EX_read_data2              = 32'h0000_0000;   // no RD2
        EX_imm                     = 32'h0000_0018;   // offset 24
        EX_csr_read_data           = 32'h0000_0000;   // no CSR
        EX_alu_result              = 32'h2000_0030;   // Calculation result = x3 + 24
        $display("Test 3-1: new input now(should be same)");
        $display("|     PC+4     | MEMread | MEMwrite | CSR WE | RegF WE | RF_WD select |  opcode  | funct3 |");
        $display("|   %h   |    %b    |     %b    |    %b   |    %b    |      %b     |  %b  |  %b  |", MEM_pc_plus_4, MEM_memory_read, MEM_memory_write, MEM_register_write_enable, MEM_csr_write_enable, MEM_register_file_write_data_select, MEM_opcode, MEM_funct3);
        $display("| Register RD2 |    imm    | csr_read_data |   ALU result   |");
        $display("|   %h   |  %h |   %h    |    %h    |\n", MEM_read_data2, MEM_imm, MEM_csr_read_data, MEM_alu_result);

        @(posedge clk); #1;
        $display("Test 3-2: Test 3-1 input should be output now \n");
        $display("|     PC+4     | MEMread | MEMwrite | CSR WE | RegF WE | RF_WD select |  opcode  | funct3 |");
        $display("|   %h   |    %b    |     %b    |    %b   |    %b    |      %b     |  %b  |  %b  |", MEM_pc_plus_4, MEM_memory_read, MEM_memory_write, MEM_register_write_enable, MEM_csr_write_enable, MEM_register_file_write_data_select, MEM_opcode, MEM_funct3);
        $display("| Register RD2 |    imm    | csr_read_data |   ALU result   |");
        $display("|   %h   |  %h |   %h    |    %h    |\n", MEM_read_data2, MEM_imm, MEM_csr_read_data, MEM_alu_result);

        flush = 1'b1; #10;
        flush = 1'b0;

        // Test 3
        $display("Test 4: Flushed (should be NOP and zero)");
        $display("|     PC+4     | MEMread | MEMwrite | CSR WE | RegF WE | RF_WD select |  opcode  | funct3 |");
        $display("|   %h   |    %b    |     %b    |    %b   |    %b    |      %b     |  %b  |  %b  |", MEM_pc_plus_4, MEM_memory_read, MEM_memory_write, MEM_register_write_enable, MEM_csr_write_enable, MEM_register_file_write_data_select, MEM_opcode, MEM_funct3);
        $display("| Register RD2 |    imm    | csr_read_data |   ALU result   |");
        $display("|   %h   |  %h |   %h    |    %h    |\n", MEM_read_data2, MEM_imm, MEM_csr_read_data, MEM_alu_result);

        EX_pc_plus_4               = 32'h0000_0018;   // (PC+4)
        EX_memory_read             = 1'b0;            // no MEM
        EX_memory_write            = 1'b0;
        EX_register_file_write_data_select = 3'b000;  // ALU result → Register File
        EX_register_write_enable = 1'b1;
        EX_csr_write_enable = 1'b1;
        EX_opcode                  = 7'b0110011;      // R-type
        EX_funct3                  = 3'b000;          // ADD
        EX_read_data2              = 32'h0000_0006;   // (dont-care)
        EX_imm                     = 32'h0000_0000;
        EX_csr_read_data           = 32'h1234_5678;   // dummy CSR test value for pipeline
        EX_alu_result              = 32'h0000_000B;   // 0x5 + 0x6 = 11
        $display("Test 5-1: Input begin (should be same)");
        $display("|     PC+4     | MEMread | MEMwrite | CSR WE | RegF WE | RF_WD select |  opcode  | funct3 |");
        $display("|   %h   |    %b    |     %b    |    %b   |    %b    |      %b     |  %b  |  %b  |", MEM_pc_plus_4, MEM_memory_read, MEM_memory_write, MEM_register_write_enable, MEM_csr_write_enable, MEM_register_file_write_data_select, MEM_opcode, MEM_funct3);
        $display("| Register RD2 |    imm    | csr_read_data |   ALU result   |");
        $display("|   %h   |  %h |   %h    |    %h    |\n", MEM_read_data2, MEM_imm, MEM_csr_read_data, MEM_alu_result);
        #10;
        $display("Test 5-2: Test 5-1's input should be output now");
        $display("|     PC+4     | MEMread | MEMwrite | CSR WE | RegF WE | RF_WD select |  opcode  | funct3 |");
        $display("|   %h   |    %b    |     %b    |    %b   |    %b    |      %b     |  %b  |  %b  |", MEM_pc_plus_4, MEM_memory_read, MEM_memory_write, MEM_register_write_enable, MEM_csr_write_enable, MEM_register_file_write_data_select, MEM_opcode, MEM_funct3);
        $display("| Register RD2 |    imm    | csr_read_data |   ALU result   |");
        $display("|   %h   |  %h |   %h    |    %h    |\n", MEM_read_data2, MEM_imm, MEM_csr_read_data, MEM_alu_result);

        $display("\n====================  EX_MEM Register Test END  ====================");

        $stop;
    end

endmodule

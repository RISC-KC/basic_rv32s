`timescale 1ns/1ps

module ID_EX_Register_tb;
    localparam XLEN = 32;

    reg clk = 0;
    reg reset = 0;
    reg flush = 0;

    reg [XLEN-1:0] ID_pc;
    reg [XLEN-1:0] ID_pc_plus_4;
    reg ID_branch_estimation;

    reg ID_jump;
    reg ID_branch;
    reg [1:0] ID_alu_src_A_select;
    reg [2:0] ID_alu_src_B_select;
    reg ID_memory_read;
    reg ID_memory_write;
    reg [2:0] ID_register_file_write_data_select;
    reg [6:0] ID_opcode; 
    reg [2:0] ID_funct3;
    reg [6:0] ID_funct7;
    reg [11:0] ID_raw_imm;
    reg [XLEN-1:0] ID_read_data1;
    reg [XLEN-1:0] ID_read_data2;
    reg [4:0] ID_rs1;
    reg [XLEN-1:0] ID_imm;
    reg [XLEN-1:0] ID_csr_read_data;

    wire [XLEN-1:0] EX_pc;
    wire [XLEN-1:0] EX_pc_plus_4;
    wire EX_branch_estimation;

    wire EX_jump;
    wire EX_memory_read;
    wire EX_memory_write;
    wire [2:0] EX_register_file_write_data_select;
    wire EX_branch;
    wire [1:0] EX_alu_src_A_select;
    wire [2:0] EX_alu_src_B_select;
    wire [6:0] EX_opcode;
    wire [2:0] EX_funct3;
    wire [6:0] EX_funct7;
    wire [11:0] EX_raw_imm;
    wire [XLEN-1:0] EX_read_data1;
    wire [XLEN-1:0] EX_read_data2;
    wire [4:0] EX_rs1;
    wire [XLEN-1:0] EX_imm;
    wire [XLEN-1:0] EX_csr_read_data;

    ID_EX_Register #(.XLEN(32)) id_ex_register (
        .clk(clk),
		.reset(reset),
        .flush(flush),

        .ID_pc(ID_pc),
        .ID_pc_plus_4(ID_pc_plus_4),
        .ID_branch_estimation(ID_branch_estimation),

        .ID_jump(ID_jump),
        .ID_branch(ID_branch),
        .ID_alu_src_A_select(ID_alu_src_A_select),
        .ID_alu_src_B_select(ID_alu_src_B_select),
        .ID_memory_read(ID_memory_read),
        .ID_memory_write(ID_memory_write),
        .ID_register_file_write_data_select(ID_register_file_write_data_select),
        .ID_opcode(ID_opcode), 
        .ID_funct3(ID_funct3),
        .ID_funct7(ID_funct7),
        .ID_raw_imm(ID_raw_imm),
        .ID_read_data1(ID_read_data1),
        .ID_read_data2(ID_read_data2),
        .ID_rs1(ID_rs1),
        .ID_imm(ID_imm),
        .ID_csr_read_data(ID_csr_read_data),

        .EX_pc(EX_pc),
        .EX_pc_plus_4(EX_pc_plus_4),
        .EX_branch_estimation(EX_branch_estimation),

        .EX_jump(EX_jump),
        .EX_memory_read(EX_memory_read),
        .EX_memory_write(EX_memory_write),
        .EX_register_file_write_data_select(EX_register_file_write_data_select),
        .EX_branch(EX_branch),
        .EX_alu_src_A_select(EX_alu_src_A_select),
        .EX_alu_src_B_select(EX_alu_src_B_select),
        .EX_opcode(EX_opcode),
        .EX_funct3(EX_funct3),
        .EX_funct7(EX_funct7),
        .EX_raw_imm(EX_raw_imm),
        .EX_read_data1(EX_read_data1),
        .EX_read_data2(EX_read_data2),
        .EX_rs1(EX_rs1),
        .EX_imm(EX_imm),
        .EX_csr_read_data(EX_csr_read_data)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/ID_EX_Register_tb_result.vcd");
        $dumpvars(0, ID_EX_Register_tb.id_ex_register);

        // Test sequence
        $display("==================== ID_EX Register Test START ====================\n");

        // reset
        reset = 1'b1;
        #30;
        reset = 1'b0;
        @(posedge clk);
        $display("Input now\n");
        $display("     PC    |     PC+4     |   branch estimation  | jump | branch | ALUsrcA | ALUsrcB |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_pc, EX_pc_plus_4, EX_branch_estimation, EX_jump, EX_branch, EX_alu_src_A_select, EX_alu_src_B_select);
        $display("| MEMread | MEMwrite | RF_WD select | opcode | funct3 | funct7 | raw_imm |");
        $display("|  %b  |   %b   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_memory_read, EX_memory_write, EX_register_file_write_data_select, EX_opcode, EX_funct3, EX_funct7, EX_raw_imm);
        $display("| Register RD1 | Register RD2 | rs1 | imm | csr_read_data |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %h  |\n", EX_read_data1, EX_read_data2, EX_rs1, EX_imm, EX_csr_read_data);
        #10;
        
        // Test 1
        @(negedge clk); 
        ID_pc = 32'h00000000;
        ID_pc_plus_4 = 32'h0000_0004;
        ID_branch_estimation = 1'b0;

        ID_jump = 1'b1;
        ID_branch = 1'b0;
        ID_alu_src_A_select = 2'b01;
        ID_alu_src_B_select = 2'b10;
        ID_memory_read = 1'b0;
        ID_memory_write = 1'b0;
        ID_register_file_write_data_select = 3'b001;
        ID_opcode = 7'b0011000;
        ID_funct3 = 3'b010;
        ID_funct7 = 7'b0011110;
        ID_raw_imm = 12'b0;
        ID_read_data1 = 32'hAAAA_AAAA;
        ID_read_data2 = 32'hBBBB_BBBB;
        ID_rs1 = 5'b01100;
        ID_imm = 32'h0000_0000;
        ID_csr_read_data = 32'h0000_0000;

        @(posedge clk); #1;
        $display("Test 1: Previous value should be output now\n");
        $display("     PC    |     PC+4     |   branch estimation  | jump | branch | ALUsrcA | ALUsrcB |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_pc, EX_pc_plus_4, EX_branch_estimation, EX_jump, EX_branch, EX_alu_src_A_select, EX_alu_src_B_select);
        $display("| MEMread | MEMwrite | RF_WD select | opcode | funct3 | funct7 | raw_imm |");
        $display("|  %b  |   %b   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_memory_read, EX_memory_write, EX_register_file_write_data_select, EX_opcode, EX_funct3, EX_funct7, EX_raw_imm);
        $display("| Register RD1 | Register RD2 | rs1 | imm | csr_read_data |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %h  |\n", EX_read_data1, EX_read_data2, EX_rs1, EX_imm, EX_csr_read_data);
        
        // Test 2@(posedge clk); #1;
        @(posedge clk); #1;
        $display("Test 2: No input(should be same)\n");
        $display("     PC    |     PC+4     |   branch estimation  | jump | branch | ALUsrcA | ALUsrcB |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_pc, EX_pc_plus_4, EX_branch_estimation, EX_jump, EX_branch, EX_alu_src_A_select, EX_alu_src_B_select);
        $display("| MEMread | MEMwrite | RF_WD select | opcode | funct3 | funct7 | raw_imm |");
        $display("|  %b  |   %b   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_memory_read, EX_memory_write, EX_register_file_write_data_select, EX_opcode, EX_funct3, EX_funct7, EX_raw_imm);
        $display("| Register RD1 | Register RD2 | rs1 | imm | csr_read_data |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %h  |\n", EX_read_data1, EX_read_data2, EX_rs1, EX_imm, EX_csr_read_data);

        // Test 3
        @(negedge clk); 
        ID_pc                         = 32'h0000_0000;
        ID_pc_plus_4                  = 32'h0000_0004;
        ID_branch_estimation          = 1'b0;

        ID_jump                       = 1'b0;
        ID_branch                     = 1'b0;
        ID_alu_src_A_select           = 2'b00;      // rs1
        ID_alu_src_B_select           = 3'b000;     // rs2
        ID_memory_read                = 1'b0;
        ID_memory_write               = 1'b0;
        ID_register_file_write_data_select = 3'b000; // ALU result
        ID_opcode                     = 7'b0110011; // R-type
        ID_funct3                     = 3'b000;     // ADD
        ID_funct7                     = 7'b0000000; 
        ID_raw_imm                    = 12'h000;
        ID_read_data1                 = 32'h0000_0005; 
        ID_read_data2                 = 32'h0000_000A;
        ID_rs1                        = 5'd5;
        ID_imm                        = 32'h0000_0000;
        ID_csr_read_data              = 32'h0000_0000;
        $display("Test 3-1: new input now(should be same) \n");
        $display("     PC    |     PC+4     |   branch estimation  | jump | branch | ALUsrcA | ALUsrcB |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_pc, EX_pc_plus_4, EX_branch_estimation, EX_jump, EX_branch, EX_alu_src_A_select, EX_alu_src_B_select);
        $display("| MEMread | MEMwrite | RF_WD select | opcode | funct3 | funct7 | raw_imm |");
        $display("|  %b  |   %b   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_memory_read, EX_memory_write, EX_register_file_write_data_select, EX_opcode, EX_funct3, EX_funct7, EX_raw_imm);
        $display("| Register RD1 | Register RD2 | rs1 | imm | csr_read_data |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %h  |\n", EX_read_data1, EX_read_data2, EX_rs1, EX_imm, EX_csr_read_data);

        @(posedge clk); #1;
        $display("Test 3-2: Test 3-1 input should be output now \n");
        $display("     PC    |     PC+4     |   branch estimation  | jump | branch | ALUsrcA | ALUsrcB |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_pc, EX_pc_plus_4, EX_branch_estimation, EX_jump, EX_branch, EX_alu_src_A_select, EX_alu_src_B_select);
        $display("| MEMread | MEMwrite | RF_WD select | opcode | funct3 | funct7 | raw_imm |");
        $display("|  %b  |   %b   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_memory_read, EX_memory_write, EX_register_file_write_data_select, EX_opcode, EX_funct3, EX_funct7, EX_raw_imm);
        $display("| Register RD1 | Register RD2 | rs1 | imm | csr_read_data |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %h  |\n", EX_read_data1, EX_read_data2, EX_rs1, EX_imm, EX_csr_read_data);

        flush = 1'b1; #10;
        flush = 1'b0;

        // Test 3
        $display("Test 4: Flushed (should be NOP and zero)\n");
        $display("     PC    |     PC+4     |   branch estimation  | jump | branch | ALUsrcA | ALUsrcB |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_pc, EX_pc_plus_4, EX_branch_estimation, EX_jump, EX_branch, EX_alu_src_A_select, EX_alu_src_B_select);
        $display("| MEMread | MEMwrite | RF_WD select | opcode | funct3 | funct7 | raw_imm |");
        $display("|  %b  |   %b   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_memory_read, EX_memory_write, EX_register_file_write_data_select, EX_opcode, EX_funct3, EX_funct7, EX_raw_imm);
        $display("| Register RD1 | Register RD2 | rs1 | imm | csr_read_data |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %h  |\n", EX_read_data1, EX_read_data2, EX_rs1, EX_imm, EX_csr_read_data);

        ID_pc                         = 32'h1000_1000;
        ID_pc_plus_4                  = 32'h1000_1004;
        ID_branch_estimation          = 1'b1;       // branch predicted taken

        ID_jump                       = 1'b0;
        ID_branch                     = 1'b1;
        ID_alu_src_A_select           = 2'b00;      // rs1 base
        ID_alu_src_B_select           = 3'b001;     // imm
        ID_memory_read                = 1'b1;
        ID_memory_write               = 1'b0;
        ID_register_file_write_data_select = 3'b001; // MEM data
        ID_opcode                     = 7'b0000011; // I-type LOAD
        ID_funct3                     = 3'b010;     // LW
        ID_funct7                     = 7'b0000000;
        ID_raw_imm                    = 12'h0F0;
        ID_read_data1                 = 32'h0000_0004; 
        ID_read_data2                 = 32'h0000_0000; // unused for load
        ID_rs1                        = 5'd2;
        ID_imm                        = 32'h0000_00F0;
        ID_csr_read_data              = 32'h0000_0000;
        $display("Test 5-1: Input begin (should be same)\n");
        $display("     PC    |     PC+4     |   branch estimation  | jump | branch | ALUsrcA | ALUsrcB |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_pc, EX_pc_plus_4, EX_branch_estimation, EX_jump, EX_branch, EX_alu_src_A_select, EX_alu_src_B_select);
        $display("| MEMread | MEMwrite | RF_WD select | opcode | funct3 | funct7 | raw_imm |");
        $display("|  %b  |   %b   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_memory_read, EX_memory_write, EX_register_file_write_data_select, EX_opcode, EX_funct3, EX_funct7, EX_raw_imm);
        $display("| Register RD1 | Register RD2 | rs1 | imm | csr_read_data |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %h  |\n", EX_read_data1, EX_read_data2, EX_rs1, EX_imm, EX_csr_read_data);
        #10;
        $display("Test 5-2: Test 5-1's input should be output now\n");
        $display("     PC    |     PC+4     |   branch estimation  | jump | branch | ALUsrcA | ALUsrcB |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_pc, EX_pc_plus_4, EX_branch_estimation, EX_jump, EX_branch, EX_alu_src_A_select, EX_alu_src_B_select);
        $display("| MEMread | MEMwrite | RF_WD select | opcode | funct3 | funct7 | raw_imm |");
        $display("|  %b  |   %b   |  %b  |  %b  |  %b  |  %b  |  %b  |", EX_memory_read, EX_memory_write, EX_register_file_write_data_select, EX_opcode, EX_funct3, EX_funct7, EX_raw_imm);
        $display("| Register RD1 | Register RD2 | rs1 | imm | csr_read_data |");
        $display("|  %h  |   %h   |  %b  |  %b  |  %h  |\n", EX_read_data1, EX_read_data2, EX_rs1, EX_imm, EX_csr_read_data);

        $display("\n====================  ID_EX Register Test END  ====================");

        $stop;
    end

endmodule

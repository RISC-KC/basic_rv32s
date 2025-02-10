`timescale 1ns/1ps
`include "modules/headers/opcode.vh"
`include "modules/headers/rtype.vh"

module ControlUnit_tb;
    reg write_done;
	reg [6:0] opcode;
	reg [2:0] funct3;
    
	wire jump;
	wire branch;
	wire [1:0] alu_src_A_select;
	wire [1:0] alu_src_B_select;
	wire [2:0] csr_op;
	wire register_file_write;
	wire [2:0] register_file_write_data_select;
	wire memory_read;
	wire memory_write;

    ControlUnit control_unit (
        .write_done(write_done),
        .opcode(opcode),
        .funct3(funct3),

        .jump(jump),
        .branch(branch),
        .alu_src_A_select(alu_src_A_select),
        .alu_src_B_select(alu_src_B_select),
        .csr_op(csr_op),
        .register_file_write(register_file_write),
        .register_file_write_data_select(register_file_write_data_select),
        .memory_read(memory_read),
        .memory_write(memory_write)
    );

    initial begin
        // Test sequence
        $display("==================== Control Unit Test START ====================");

        // Test 1: Writing not done
		$display("\nWriting not done: ");

        write_done = 0;

		opcode = `OPCODE_RTYPE;
        funct3 = `RTYPE_ADDSUB;

        #1;
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_op: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_op);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b\n", memory_read, memory_write);

        write_done = 1;

        // Test 2: R-type
		$display("\nR-type: ");
		
		opcode = `OPCODE_RTYPE;
        
        funct3 = `RTYPE_ADDSUB; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_op: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_op);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b\n", memory_read, memory_write);

        funct3 = `RTYPE_SLL; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_op: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_op);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b\n", memory_read, memory_write);
		
        funct3 = `RTYPE_SLT; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_op: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_op);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b\n", memory_read, memory_write);

        funct3 = `RTYPE_SLTU; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_op: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_op);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b\n", memory_read, memory_write);

        funct3 = `RTYPE_XOR; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_op: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_op);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b\n", memory_read, memory_write);

        funct3 = `RTYPE_SR; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_op: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_op);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b\n", memory_read, memory_write);

        funct3 = `RTYPE_OR; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_op: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_op);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b\n", memory_read, memory_write);

        funct3 = `RTYPE_AND; #1;
        $display("funct3: %b", funct3);
        $display("jump: %b, branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_op: %b", jump, branch, alu_src_A_select, alu_src_B_select, csr_op);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b\n", memory_read, memory_write);

        $display("\n====================  Control Unit Test END  ====================");

        $stop;
    end

endmodule

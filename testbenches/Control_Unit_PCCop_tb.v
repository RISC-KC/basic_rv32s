`timescale 1ns/1ps

`include "modules/headers/branch.vh"
`include "modules/headers/csr.vh"
`include "modules/headers/itype.vh"
`include "modules/headers/load.vh"
`include "modules/headers/opcode.vh"
`include "modules/headers/rtype.vh"
`include "modules/headers/store.vh"

module ControlUnit_tb;
    reg write_done;
    reg trap_done;
	reg [6:0] opcode;
	reg [2:0] funct3;
    reg trapped;
    reg branch_taken;

	wire branch;
	wire [1:0] alu_src_A_select;
	wire [2:0] alu_src_B_select;
	wire csr_write_enable;
	wire register_file_write;
	wire [2:0] register_file_write_data_select;
	wire memory_write;
    wire [2:0] pcc_op;

    ControlUnit control_unit (
        .write_done(write_done),
        .trap_done(trap_done),
        .trapped(trapped),
        .opcode(opcode),
        .funct3(funct3),
        .branch_taken(branch_taken),

        .branch(branch),
        .alu_src_A_select(alu_src_A_select),
        .alu_src_B_select(alu_src_B_select),
        .csr_write_enable(csr_write_enable),
        .register_file_write(register_file_write),
        .register_file_write_data_select(register_file_write_data_select),
        .memory_read(memory_read),
        .memory_write(memory_write),
        .pcc_op(pcc_op)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/Control_Unit_tb_result.vcd");
        $dumpvars(0, control_unit);

        // Test sequence
        $display("==================== Control Unit Test START ====================");

        opcode = `OPCODE_RTYPE;
        funct3 = `RTYPE_ADDSUB;

        // Test 1: Writing not done
		$display("\nWriting not done: ");

        write_done = 0;
        trap_done = 1;

        #1;
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);


        write_done = 1;

        // Test 1-2: Pre-Trap Handling not done
        $display("\nPTH not done: ");

        trapped = 1;
        trap_done = 0;

        #1;
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        trap_done = 1;

        // Test 1-3: Pre-Trap Handling done
        $display("\nPTH done: ");

        trapped = 1;

        #1;
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        trap_done = 1;

        // Test 2: LUI
		$display("\nLUI: ");
		
        trapped = 0;
		opcode = `OPCODE_LUI;
        funct3 = 3'b0; 
        
        #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        // Test 3: AUIPC
		$display("\nAUIPC: ");
		
		opcode = `OPCODE_AUIPC;
        funct3 = 3'b0; 
        
        #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        // Test 4: JAL
		$display("\nJAL: ");
		
		opcode = `OPCODE_JAL;
        funct3 = 3'b0; 
        
        #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        // Test 4-1: JAL race condition (Misaligned JAL)
		$display("\nJAL race condition: ");
		
        fork
		    opcode = `OPCODE_JAL;
            funct3 = 3'b0; 
            trap_done = 0; 
            trapped = 1;
        join
        
        #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        // Test 5: JALR
		$display("\nJALR: ");
		
        trap_done = 1;
        trapped = 0;
		opcode = `OPCODE_JALR;
        funct3 = 3'b0; 
        
        #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        // Test 6: Branch
		$display("\nBranch: ");
		
		opcode = `OPCODE_BRANCH;
        
        funct3 = `BRANCH_BEQ; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `BRANCH_BNE; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);
		
        funct3 = `BRANCH_BLT; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        branch_taken = 1; #10;
        funct3 = `BRANCH_BGE; #1;
        $display("Branch Taken");
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        branch_taken = 0; #10;
        funct3 = `BRANCH_BLTU; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `BRANCH_BGEU; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        // Test 7: Load
		$display("\nLoad: ");
		
		opcode = `OPCODE_LOAD;
        
        funct3 = `LOAD_LB; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `LOAD_LH; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);
		
        funct3 = `LOAD_LW; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `LOAD_LBU; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `LOAD_LHU; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        // Test 9: Store
		$display("\nStore: ");
		
		opcode = `OPCODE_STORE;
        
        funct3 = `STORE_SB; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `STORE_SH; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);
		
        funct3 = `STORE_SW; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        // Test 10: I-type
		$display("\nI-type: ");
		
		opcode = `OPCODE_ITYPE;
        
        funct3 = `ITYPE_ADDI; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `ITYPE_SLLI; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);
		
        funct3 = `ITYPE_SLTI; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `ITYPE_SLTIU; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `ITYPE_XORI; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `ITYPE_SRXI; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `ITYPE_ORI; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `ITYPE_ANDI; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        // Test 11: R-type
		$display("\nR-type: ");
		
		opcode = `OPCODE_RTYPE;
        
        funct3 = `RTYPE_ADDSUB; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `RTYPE_SLL; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);
		
        funct3 = `RTYPE_SLT; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `RTYPE_SLTU; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `RTYPE_XOR; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `RTYPE_SR; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `RTYPE_OR; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `RTYPE_AND; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        // Test 12: Fence
		$display("\nFence: ");
		
		opcode = `OPCODE_FENCE;
        funct3 = 3'b0;
        
        #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        // Test 13: Environment
		$display("\nEnvironment: ");
		
		opcode = `OPCODE_ENVIRONMENT;
        
        funct3 = 3'b0; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `CSR_CSRRW; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);
		
        funct3 = `CSR_CSRRS; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `CSR_CSRRC; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `CSR_CSRRWI; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `CSR_CSRRSI; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b\n", memory_read, memory_write, pcc_op);

        funct3 = `CSR_CSRRCI; #1;
        $display("funct3: %b", funct3);
        $display("branch: %b, alu_src_A_select: %b, alu_src_B_select: %b, csr_write_enable: %b", branch, alu_src_A_select, alu_src_B_select, csr_write_enable);
		$display("RF_write: %b, RF_WD_select: %b", register_file_write, register_file_write_data_select);
        $display("memory_read: %b, memory_write: %b, pcc_op: %b", memory_read, memory_write, pcc_op);

        $display("\n====================  Control Unit Test END  ====================");

        $stop;
    end

endmodule

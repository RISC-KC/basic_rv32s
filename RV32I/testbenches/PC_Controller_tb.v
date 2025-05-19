`include "modules/headers/pcc_op.vh"
`timescale 1ns/1ps

module PCController_tb;
    reg clk;
    reg [2:0]  pcc_op;
    reg [31:0] pc;
    reg [31:0] jump_target;
    reg [31:0] branch_target;
    reg [31:0] trap_target;

    wire [31:0] next_pc;

    PCController pc_controller (
        .pcc_op(pcc_op),
        .pc(pc),
        .jump_target(jump_target),
        .branch_target(branch_target),
        .trap_target(trap_target),

        .next_pc(next_pc)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/PC_Controller_tb_result.vcd");
        $dumpvars(0, pc_controller);

		// Test sequence
        $display("==================== PCController Test START ====================");

        pc = 32'b0;
        jump_target = 32'b0;
        branch_target = 32'b0;
        trap_target = 32'b0;

        // Test 1: Pause PC update
        $display("\nPause PC update: ");

        pcc_op = `PCC_STALL;

        jump_target = 32'h12345678;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        jump_target = 32'b0;

        // Test 2: No jump, no branch, no trap
        $display("\nNo jump, No branch, No trap: ");

        pcc_op = `PCC_NONE;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 3: Jump
		$display("\nJump: ");
		
        pc = next_pc;

        pcc_op = `PCC_JUMP;

        jump_target = 32'hDEAD0000;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 4-1: Misaligned Branch taken
        $display("\nMisaligned Branch taken: (branch target = 0x0000_BEEF)");
        
        pc = next_pc;

		pcc_op = `PCC_BTAKEN;

        branch_target = 32'h0000BEEF;

		#10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 4-2: Aligned Branch taken
        $display("\nAligned Branch taken: ");
        
        pc = next_pc;

		pcc_op = `PCC_BTAKEN;

        branch_target = 32'h0000BEE8;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 5: Trapped
        $display("\nTrapped: ");
        
        pc = next_pc;

		pcc_op = `PCC_TRAPPED;
		
        trap_target = 32'hCAFEBABE;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 6: Normal increment
        $display("\nNormal increment: ");
        
        pc = 32'h00001000;

		pcc_op = `PCC_NONE;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 7: trapped but no address fetched
        $display("\n Trapped but no address: ");
        
        pc = 32'h00001000;
        trap_target = 32'b0;

		pcc_op = `PCC_TRAPPED;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 7: trapped with jump signal but no address fetched.
        $display("\n Trapped with Jump signal, no trap_target fetched: ");
        
        pc = 32'h00001000;
        trap_target = 32'b0;
        jump_target = 32'h1111_1110;

        fork
            pcc_op = `PCC_STALL;
		    pcc_op = `PCC_JUMP;
		    pcc_op = `PCC_TRAPPED;
        join
        
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 7: trapped but with address
        $display("\ntrapped with address: ");
        
        pc = 32'h00001000;
        trap_target = 32'h1000_1000;

        fork
		    pcc_op = `PCC_JUMP;
		    pcc_op = `PCC_TRAPPED;
        join
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        $display("\n====================  PCController Test END  ====================");
        $stop;
    end

endmodule
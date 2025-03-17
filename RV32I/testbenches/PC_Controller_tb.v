`timescale 1ns/1ps

module PCController_tb;
    reg jump;
    reg branch_taken;
    reg trapped;
    reg [31:0] pc;
    reg [31:0] jump_target;
    reg [31:0] imm;
    reg [31:0] trap_target;
	reg pc_stall;

    wire [31:0] next_pc;

    PCController pc_controller (
        .jump(jump),
        .branch_taken(branch_taken),
        .trapped(trapped),
        .pc(pc),
        .jump_target(jump_target),
        .imm(imm),
        .trap_target(trap_target),
		.pc_stall(pc_stall),

        .next_pc(next_pc)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/PC_Controller_tb_result.vcd");
        $dumpvars(0, pc_controller);

		// Test sequence
        $display("==================== PCController Test START ====================");

        pc = 32'b0;
        jump_target = 32'b0;
        imm = 32'b0;
        trap_target = 32'b0;

        // Test 1: Pause PC update
        $display("\nPause PC update: ");

        pc_stall = 1;

        jump = 1;
        branch_taken = 0;
        trapped = 0;

        jump_target = 32'h12345678;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        jump_target = 32'b0;

        // Test 2: No jump, no branch, no trap
        $display("\nNo jump, No branch, No trap: ");

        pc_stall = 0;

        jump = 0;
        branch_taken = 0;
        trapped = 0;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 3: Jump
		$display("\nJump: ");
		
        pc = next_pc;

        jump = 1;
		branch_taken = 0;
		trapped = 0;

        jump_target = 32'hDEAD0000;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 4: Branch taken
        $display("\nBranch taken: ");
        
        pc = next_pc;

		jump = 0;
		branch_taken = 1;
		trapped = 0;

        imm = 32'h0000BEEF;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 5: Trapped
        $display("\nTrapped: ");
        
        pc = next_pc;

		jump = 0;
		branch_taken = 0;
		trapped = 1;
		
        trap_target = 32'hCAFEBABE;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 6: Normal increment
        $display("\nNormal increment: ");
        
        pc = 32'h00001000;

		jump = 0;
		branch_taken = 0;
		trapped = 0;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        $display("\n====================  PCController Test END  ====================");
        $stop;
    end

endmodule

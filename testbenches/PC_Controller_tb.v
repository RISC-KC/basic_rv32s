`timescale 1ns/1ps

module PCController_tb;
    reg jump;
    reg branch_taken;
    reg trapped;
    reg [31:0] pc;
    reg [31:0] jump_target;
    reg [31:0] imm;
    reg [31:0] trap_target;
    reg read_done;
	reg write_done;
    reg pc_stall;

    wire [31:0] next_pc;

    PCController pcc (
        .jump(jump),
        .branch_taken(branch_taken),
        .trapped(trapped),
        .pc(pc),
        .jump_target(jump_target),
        .imm(imm),
        .trap_target(trap_target),
		.write_done(write_done),
        .pc_stall(pc_stall),

        .next_pc(next_pc)
    );

    initial begin
		// Test sequence
        $display("==================== PCController Test START ====================");

        pc = 32'h00000000;
        jump_target = 32'h00000010;
        imm = 32'h00000020;
        trap_target = 32'h00000030;

        // Test 1: Read is (not) done
        $display("\nRead is (not) done: ");

        write_done = 1;
        pc_stall = 1; 

        jump = 0;
        branch_taken = 1;
        trapped = 0;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 2: Read is done
        $display("\nRead is done: ");

        write_done = 1;
        pc_stall = 0;

        jump = 0;
        branch_taken = 0;
        trapped = 1;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 3: Write is (not) done
        $display("\nWrite is (not) done: ");

        write_done = 0;
        pc_stall = 0;

        jump = 1;
        branch_taken = 0;
        trapped = 0;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 4: No jump, no branch, no trap
        $display("\nNo jump, No branch, No trap: ");

        write_done = 1;
        pc_stall = 0;

        jump = 0;
        branch_taken = 0;
        trapped = 0;

        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 5: Jump
		$display("\nJump: ");
		
        jump = 1;
		branch_taken = 0;
		trapped = 0;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 6: Branch taken
        $display("\nBranch taken: ");
        
		jump = 0;
		branch_taken = 1;
		trapped = 0;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 5: Trapped
        $display("\nTrapped: ");
        
		jump = 0;
		branch_taken = 0;
		trapped = 1;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        // Test 6: Normal increment
        $display("\nNormal increment: ");
        
		jump = 0;
		branch_taken = 0;
		trapped = 0;
		
		pc = 32'h00001000;
		
        #10;
        $display("pc = %h => next_pc = %h", pc, next_pc);

        $display("\n====================  PCController Test END  ====================");
        $stop;
    end

endmodule

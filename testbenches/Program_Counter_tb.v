`timescale 1ns/1ps

module ProgramCounter_tb;
    reg clk;
    reg reset;
    reg [31:0] next_pc;
    wire [31:0] pc;

    ProgramCounter program_counter (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $display("==================== ProgramCounter Test START ====================");

        // Initialize signals
        clk     = 0;
        reset   = 0;
        next_pc = 0;

        // Test 1: Reset the PC
        $display("Reset the PC: ");
		
		next_pc = 32'h00000004;
		
		#10;
        $display("Before reset: pc = %h", pc);
		
        reset = 1;
		next_pc = 32'h00000008;
		
		#10;
        $display("After reset = 1, pc = %h", pc);

        // Deassert reset
        reset = 0;
        #10;

        // Test 2: Assigning value to next_pc
        $display("\nAssigning value to next_pc: ");
        
		next_pc = 32'hDEADBEEF;
		
        #10;
        $display("pc = %h", pc);

        next_pc = 32'hCAFEBEBE;
		
        #10;
        $display("pc = %h", pc);

        // Test 3: Sudden reset
        $display("\nSudden reset:");
		
        #5;
		reset = 1; // Reset signal in the middle of the clock cycle
		#5;
		
        $display("pc = %h", pc);

        $display("\n====================  ProgramCounter Test END  ====================");
        $stop;
    end

endmodule

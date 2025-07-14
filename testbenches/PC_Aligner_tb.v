`timescale 1ns/1ps

module PCAligner_tb;
    reg [31:0] raw_next_pc;

    wire [31:0] next_pc;

    PCAligner pc_aligner (
        .raw_next_pc(raw_next_pc),
        .next_pc(next_pc)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/PC_Aligner_tb_result.vcd");
        $dumpvars(0, pc_aligner);

		// Test sequence
        $display("==================== PCAligner Test START ====================");

        // Test 1: Misaligned
        $display("\nMisaligned: ");

        raw_next_pc = 32'hDEADBEEF; #1;
        $display("raw_next_pc = %h => next_pc = %h", raw_next_pc, next_pc);

        // Test 2: Aligned
        $display("\nAligned: ");

        raw_next_pc = 32'hDEADBEE0; #1;
        $display("raw_next_pc = %h => next_pc = %h", raw_next_pc, next_pc);

        $display("\n====================  PCAligner Test END  ====================");
        $stop;
    end

endmodule

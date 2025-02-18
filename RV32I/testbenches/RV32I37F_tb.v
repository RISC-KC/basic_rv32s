`timescale 1ns/1ps

module RV32I37F_tb;
    reg clk;
    reg reset;

    RV32I37F rv32i37f (
        .clk(clk),
        .reset(reset)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $display("==================== RV32I37F Test START ====================");

        // Initialize signals
        clk     = 0;
        reset   = 0;

        $dumpfile("results/waveforms/RV32I37F_tb_result.vcd");
        $dumpvars;

        #3;

        $display("\n====================  RV32I37F Test END  ====================");
        $stop;
    end

endmodule

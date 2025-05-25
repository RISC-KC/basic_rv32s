`timescale 1ns/1ps

module RV32I46F5SP_tb;
    reg clk;
    reg reset;

    RV32I46F5SP rv32i46f_5sp (
        .clk(clk),
        .reset(reset)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/RV32I46F5SP_tb_result.vcd");
        $dumpvars(0, rv32i46f_5sp);

        $display("==================== RV32I46F_5SP Test START ====================");

        clk = 0;
        reset = 1;

        #10;

        reset = 0;

        #795;

        $display("\n====================  RV32I46F_5SP Test END  ====================");
        $stop;
    end

endmodule

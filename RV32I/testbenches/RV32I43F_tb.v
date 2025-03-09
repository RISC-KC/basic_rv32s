`timescale 1ns/1ps

module RV32I43F_tb;
    reg clk;
    reg reset;

    RV32I43F rv32i43f (
        .clk(clk),
        .reset(reset)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/RV32I43F_tb_result.vcd");
        $dumpvars(0, rv32i43f);

        $display("==================== RV32I43F Test START ====================");

        clk = 0;
        reset = 1;

        #10;

        reset = 0;

        #500;

        $display("\n====================  RV32I43F Test END  ====================");
        $stop;
    end

endmodule

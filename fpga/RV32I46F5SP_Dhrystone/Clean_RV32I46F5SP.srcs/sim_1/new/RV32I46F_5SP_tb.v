`timescale 1ns/1ps

module RV32I46F5SP_tb;
    reg clk;
    reg reset;

    RV32I46F5SPDebug rv32i46f_5sp_debug (
        .clk(clk),
        .reset(reset)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $display("==================== RV32I46F_5SP Test START ====================");

        clk = 0;
        reset = 1;

        #10;

        reset = 0;

        #2515;

        $display("\n====================  RV32I46F_5SP Test END  ====================");
        $stop;
    end

endmodule

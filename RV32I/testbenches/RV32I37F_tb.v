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
        $dumpfile("testbenches/results/waveforms/RV32I37F_tb_result.vcd");
        $dumpvars(0, RV32I37F_tb.rv32i37f);

        $readmemb("testbenches/test_code.mem", rv32i37f.instruction_memory.data);

        $display("==================== RV32I37F Test START ====================");

        clk = 0;
        reset = 1;

        #10;

        reset = 0;

        #1000;

        $display("\n====================  RV32I37F Test END  ====================");
        $stop;
    end

endmodule

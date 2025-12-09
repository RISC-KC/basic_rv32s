`timescale 1ns/1ps

module RV32I46F5SPMMIO_tb;
    reg clk;
    reg reset;
    reg UART_busy;
    wire mmio_uart_tx_start;
    wire [7:0] mmio_uart_tx_data;

    RV32I46F5SPMMIO rv32i46f_5sp_mmio (
        .clk(clk),
        .reset(reset),
        .UART_busy(UART_busy),

        .mmio_uart_tx_start(mmio_uart_tx_start),
        .mmio_uart_tx_data(mmio_uart_tx_data)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/RV32I46F5SP_MMIO_tb.vcd");
        $dumpvars(0, rv32i46f_5sp_mmio);

        $display("==================== RV32I46F_5SP Test START ====================");

        clk = 0;
        reset = 1;

        #10;

        reset = 0;
        UART_busy = 0;

        #2265;

        UART_busy = 1;

        #100;

        UART_busy = 0;

        #100;

        UART_busy = 1;

        #50;

        UART_busy = 0;

        #3075;

        $display("\n====================  RV32I46F_5SP Test END  ====================");
        $stop;
    end

endmodule

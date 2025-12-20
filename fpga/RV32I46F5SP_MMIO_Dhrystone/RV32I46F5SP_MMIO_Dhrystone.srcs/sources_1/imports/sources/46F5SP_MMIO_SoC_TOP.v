module RV32I46F5SPMMIOSoCTOP #(
    parameter XLEN = 32
)(
    input clk,                      // 100MHz system clock from Nexys Video
    input reset_n,                  // System reset (active low)
    input btn_up,                   // Benchmark Start FPGA Button

    output [7:0] led,               // LED[0]: Standby, LED[7:1]: OPCODE[6:0]
    output uart_tx_in               // UART TX pin
);

    // Clock Divider: 100MHz -> 50MHz
    reg clk_50mhz_unbuffered;
    wire clk_50mhz;
    wire reset = ~reset_n;
    
    BUFG clk_50mhz_bufg (
        .I(clk_50mhz_unbuffered),
        .O(clk_50mhz)
    );
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_50mhz_unbuffered <= 1'b0;
        end else begin
            clk_50mhz_unbuffered <= ~clk_50mhz_unbuffered;
        end
    end

    // Internal 3-stage Reset Synchronization
    wire internal_reset;
    reg [2:0] reset_sync;
    assign internal_reset = reset_sync[2];

    always @(posedge clk_50mhz or posedge reset) begin
        if (reset) begin
            reset_sync <= 3'b111;
        end else begin
            reset_sync <= {reset_sync[1:0], 1'b0};
        end
    end

    // Clock enable control
    reg cpu_clk_enable;
    wire benchmark_start;

    // Button controlled benchmark execution
    always @(posedge clk_50mhz or posedge internal_reset) begin
        if (internal_reset) begin
            cpu_clk_enable <= 1'b0;
        end else begin
            if (benchmark_start) begin
                cpu_clk_enable <= 1'b1;
            end
        end
    end
    
    // UART signals
    wire tx_start;
    wire [7:0] tx_data;
    wire tx_busy;
    
    // CPU MMIO Interface Signals
    wire [31:0] retire_instruction;
    wire [7:0] mmio_uart_tx_data;
    wire mmio_uart_tx_start;
    wire [6:0] current_opcode;
    assign current_opcode = retire_instruction[6:0];

    // LED Output
    assign led[0] = ~cpu_clk_enable;    // Standby mode when no clk.
    assign led[7:1] = current_opcode;   // retired instruction's opcode

    // Module instances
    UnifiedUARTController unified_uart_controller (
        .clk(clk_50mhz),
        .reset(internal_reset),
        .btn_up(btn_up),
        .mmio_tx_data(mmio_uart_tx_data),
        .mmio_tx_start(mmio_uart_tx_start),

        .tx_start(tx_start),
        .tx_data(tx_data),
        .benchmark_start(benchmark_start)
    );

    // UART Transmitter; UART TX
    UARTTX uart_tx (
        .clk(clk_50mhz),
        .reset(internal_reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(uart_tx_in),
        .tx_busy(tx_busy)
    );
    
    // CPU Core with MMIO Interface
    RV32I46F5SPMMIO #(.XLEN(XLEN)) rv32i46f_5sp_mmio (
        .clk(clk_50mhz),
        .clk_enable(cpu_clk_enable),
        .reset(internal_reset),
        .UART_busy(tx_busy),

        .retire_instruction(retire_instruction),
        .mmio_uart_tx_data(mmio_uart_tx_data),
        .mmio_uart_tx_start(mmio_uart_tx_start)
    );

endmodule
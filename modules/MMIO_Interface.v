module mmio_interface (
    input clk,
    input clk_enable,
    input [31:0] data_memory_write_data,
    input data_memory_write_enable,
    input [31:0] data_memory_write_address,
    input UART_busy,

    output reg [7:0] mmio_uart_tx_data,
    output mmio_uart_tx_start
    output 
);

    localparam UART_TX_ADDR = 32'h10010000;     // Write-Only
    localparam UART_STATUS_ADDR = 32'h10010004; // Read-Only

    wire uart_tx_hit = (data_memory_write_address == UART_TX_ADDR);
    wire uart_stat_hit = (data_memory_write_address == UART_STATUS_ADDR);

    always @ (posedge clk) begin
        if (!clk_enable) begin
            uart_tx_start <= 1'b0;
        end else begin
            if (write_enable && uart_tx_hit && !UART_busy) begin
                mmio_uart_tx_data <= data_memory_write_data[7:0];
                mmio_uart_tx_start <= 1'b1;
            end else begin
                uart_tx_start <= 1'b0;
            end
        end
    end

endmodule
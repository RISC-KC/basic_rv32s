module UnifiedUARTController (
    input clk,
    input reset,
    input btn_up,
    
    // MMIO input from core RV32I46F_5SP_MMIO
    input [7:0] mmio_tx_data,
    input mmio_tx_start,
    
    // UART_TX output
    output tx_start,
    output [7:0] tx_data,
    
    // CPU Control
    output reg benchmark_start
);

    localparam DEBOUNCE_CYCLES = 20'd500000; // 10ms @ 50MHz

    // Button Sync
    reg [2:0] btn_sync;
    reg [19:0] debounce_counter;
    reg btn_stable;
    reg btn_prev;
    wire btn_rising_edge;
    
    assign tx_start = mmio_tx_start;
    assign tx_data = mmio_tx_data;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_sync <= 3'b0;
        end else begin
            btn_sync <= {btn_sync[1:0], btn_up};
        end
    end

    // Debouncer
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            debounce_counter <= 20'b0;
            btn_stable <= 1'b0;
        end else begin
            if (btn_sync[2] != btn_stable) begin
                if (debounce_counter < DEBOUNCE_CYCLES) begin
                    debounce_counter <= debounce_counter + 1;
                end else begin
                    btn_stable <= btn_sync[2];
                    debounce_counter <= 20'b0;
                end
            end else begin
                debounce_counter <= 20'b0;
            end
        end
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_prev <= 1'b0;
        end else begin
            btn_prev <= btn_stable;
        end
    end

    assign btn_rising_edge = btn_stable & ~btn_prev;

    // benchmark_start pulse signal
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            benchmark_start <= 1'b0;
        end else begin
            benchmark_start <= btn_rising_edge;
        end
    end

endmodule
module UARTTX (
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,

    output reg tx,
    output reg tx_busy
);

    localparam BAUD_DIV = 434;
    localparam BITS = 10;

    reg [15:0] baud_counter;
    reg [3:0] bit_counter;
    reg [9:0] shift_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx <= 1'b1;
            tx_busy <= 1'b0;
            baud_counter <= 1'b0;
            bit_counter <= 1'b0;
            shift_reg <= 10'h3FF;
        end else begin
            if (!tx_busy && tx_start) begin
                shift_reg <= {1'b1, tx_data, 1'b0};
                tx_busy <= 1'b1;
                baud_counter <= 1'b0;
                bit_counter <= 1'b0;
            end else if (tx_busy) begin
                if (baud_counter >= BAUD_DIV-1) begin
                    baud_counter <= 0;
                    tx <= shift_reg[0];
                    shift_reg <= {1'b1, shift_reg[9:1]};

                    if (bit_counter >= BITS-1) begin
                        tx_busy <= 1'b0;
                        tx <= 1'b1;
                    end else begin
                        bit_counter <= bit_counter + 1;
                    end
                end else begin
                    baud_counter <= baud_counter +1;
                end
            end
        end
    end
    
endmodule
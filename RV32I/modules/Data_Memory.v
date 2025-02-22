module DataMemory (
    input clk,                      // clock signal
    input read_enable,              // enabling signal for reading Data Memory
    input write_enable,             // enabling signal for writing Data Memory
    input [9:0] address,            // Take address of memory to read/write value
    input [31:0] write_data,        // data to write to Data Memory
    input [3:0] write_mask,         // bitmask for writing data

    output reg [31:0] read_data     // data read from Data Memory
);

    reg [31:0] memory [0:1023]; // 1024 words (4KB)
    reg [31:0] extended_mask;

    initial begin
        $readmemb("modules/initial_data.mem", memory);
    end

    always @(posedge clk) begin
        extended_mask = {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

        if (read_enable) begin
            read_data <= memory[address];
        end
        else if (write_enable) begin
            read_data <= 32'b0;
            memory[address] <= ((memory[address] & ~extended_mask) | (write_data & extended_mask));
        end
        else begin
            read_data <= 32'b0;
        end
    end

endmodule

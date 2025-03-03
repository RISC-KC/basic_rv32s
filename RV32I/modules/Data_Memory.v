module DataMemory (
    input clk,                      // clock signal
    input read_enable,              // enabling signal for reading Data Memory
    input write_enable,             // enabling signal for writing Data Memory
    input [9:0] address,            // Take address of memory to read/write value
    input [31:0] write_data,        // data to write to Data Memory
    input [3:0] write_mask,         // bitmask for writing data

    output reg [31:0] read_data,    // data read from Data Memory
    output reg read_done            // signal indicating if reading is done
);

    reg [31:0] memory [0:1023];     // 1024 words (4KB)
    
    // 32 bit extended mask from 4 bit write_mask
    wire [31:0] extended_mask = {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

    initial begin
        $readmemb("modules/initial_data.mem", memory);
    end

    always @(posedge clk) begin
        if (read_enable) begin
            read_data <= memory[address];
            read_done <= 1'b1;
        end
        else if (write_enable) begin
            memory[address] <= ((memory[address] & ~extended_mask) | (write_data & extended_mask));
            read_data <= 32'b0;
            read_done <= 1'b0;
        end
        else begin
            read_data <= 32'b0;
            read_done <= 1'b0;
        end
    end

endmodule

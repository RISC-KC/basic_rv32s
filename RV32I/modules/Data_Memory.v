module DataMemory (
    input clk,                      // clock signal
    input write_enable,             // enabling signal for writing Data Memory
    input [31:0] address,            // Take address of memory to read/write value
    input [31:0] write_data,        // data to write to Data Memory
    input [3:0] write_mask,         // bitmask for writing data

    output reg [255:0] read_data    // data block (8 words) read from Data Memory
);

    parameter VALID_ADDRESS_WIDTH = 18; // 27 for 512MB, 18 for 1MB

    reg [31:0] memory [0:(2<<VALID_ADDRESS_WIDTH)-1]; // 134217728(2^27) words (512MB)

    integer i;

    initial begin
        for (i=0; i<VALID_ADDRESS_WIDTH; i=i+1) begin
            memory[i] <= 32'b0;
        end
    end
    
    always @(posedge clk) begin
        read_data <= {
            memory[{address[VALID_ADDRESS_WIDTH+1:5], 3'b111}], memory[{address[VALID_ADDRESS_WIDTH+1:5], 3'b110}], 
            memory[{address[VALID_ADDRESS_WIDTH+1:5], 3'b101}], memory[{address[VALID_ADDRESS_WIDTH+1:5], 3'b100}],
            memory[{address[VALID_ADDRESS_WIDTH+1:5], 3'b011}], memory[{address[VALID_ADDRESS_WIDTH+1:5], 3'b010}], 
            memory[{address[VALID_ADDRESS_WIDTH+1:5], 3'b001}], memory[{address[VALID_ADDRESS_WIDTH+1:5], 3'b000}]
        };

        if (write_enable) begin
            for (i=0; i<4; i=i+1) begin
                if (write_mask[i]) begin
                    memory[address[VALID_ADDRESS_WIDTH+1:2]][i*8 +: 8] <= write_data[i*8 +: 8];
                end
            end
        end
    end

endmodule

module DataMemory (
    input clk,                      // clock signal
    input write_enable,             // enabling signal for writing Data Memory
    input [31:0] address,            // Take address of memory to read/write value
    input [31:0] write_data,        // data to write to Data Memory
    input [3:0] write_mask,         // bitmask for writing data (Should receive 4'b1111 in RV32I47F and 50F top module)

    input [31:0] rom_read_data,
    output [31:0] rom_address,

    output reg [31:0] read_data    // data read from Data Memory
);

    reg [31:0] memory [0:1023];     // 1024 words (4KB), FPGA is 32KB = 8192 (0:8191)
    reg [31:0] new_word;
    
    // 32 bit extended mask from 4 bit write_mask
    wire [31:0] extended_mask = {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};
    wire ram_access = (address[31:16] == 16'h1000);
    wire rom_access = (address[31:16] == 16'h0000);
    wire [12:0] ram_address = address[14:2];
    assign rom_address = address;

    integer i;
    initial begin
        for (i=0; i<1024; i=i+1) begin
            memory[i] = 32'b0;
        end // $readmemh("./data_init.mem", memory, 13'h1424);
    end

    always @(*) begin
        if (ram_access) begin
            read_data = memory[ram_address];
        end else if (rom_access) begin
            read_data = rom_read_data;
        end else begin
            read_data = 32'b0; // for wrong address
        end
        
    end

    always @(posedge clk) begin
        if (write_enable && ram_access) begin
            new_word = ((memory[ram_address] & ~extended_mask) | (write_data & extended_mask));
            memory[ram_address] <= new_word;
        end
    end

endmodule

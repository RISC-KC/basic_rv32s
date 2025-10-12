module DataMemory (
    input clk,
    input clk_enable,
    input write_enable,
    input [9:0] address,
    input [31:0] write_data,
    input [3:0] write_mask,
    output reg [31:0] read_data
);

    reg [31:0] memory [0:1023];
    wire [31:0] extended_mask = {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};
    integer i;
    
    initial begin
        for (i=0; i<1024; i=i+1) begin
            memory[i] = 32'b0;
        end
    end

    always @(*) begin
        read_data = memory[address];
    end

    always @(posedge clk) begin
        if (clk_enable && write_enable) begin
            memory[address] <= ((memory[address] & ~extended_mask) | (write_data & extended_mask));
        end
    end
endmodule
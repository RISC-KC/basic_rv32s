module DataMemory (
    input clk,
    input [31:0] address,        // Memory address
    input [31:0] writeData,      // Data to write
    input memWrite,              // Memory write enable
    input memRead,               // Memory read enable
    output reg [31:0] readData   // Data read from memory
);

    reg [31:0] memory [0:255]; // Data memory (8KB, 256 words)

    always @(posedge clk) begin
        if (memWrite) begin
            memory[address[9:2]] <= writeData; // Write operation
        end
    end

    always @(*) begin
        if (memRead) begin
            readData = memory[address[9:2]]; // Read operation
        end else begin
            readData = 32'b0;
        end
    end

endmodule

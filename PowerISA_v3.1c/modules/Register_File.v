module RegisterFile (
    input clk,
    input [4:0] readReg1,        // Source register 1
    input [4:0] readReg2,        // Source register 2
    input [4:0] writeReg,        // Destination register
    input [31:0] writeData,      // Data to write
    input regWrite,              // Write enable
    output reg [31:0] readData1, // Data from source register 1
    output reg [31:0] readData2  // Data from source register 2
);

    reg [31:0] registers [0:31]; // 32 registers

    // Write operation
    always @(posedge clk) begin
        if (regWrite && writeReg != 5'd0) begin
            registers[writeReg] <= writeData; // Write to register if not R0
        end
    end

    // Read operation
    always @(*) begin
        readData1 = (readReg1 == 5'd0) ? 32'd0 : registers[readReg1]; // R0 is always 0
        readData2 = (readReg2 == 5'd0) ? 32'd0 : registers[readReg2]; // R0 is always 0
    end

endmodule

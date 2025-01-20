module RegisterFile (
    input clk,
    input [4:0] read_reg1,        // Take address of register 1 to read stored value
    input [4:0] read_reg2,        // Take address of register 2 to read stored value
    input [4:0] write_reg,        // Take address of register to write value
    input [31:0] write_data,      // Data to write
    input reg_write,              // Enabling signal for writing register
	
    output reg [31:0] read_data1, // Data from register 1
    output reg [31:0] read_data2  // Data from register 2
);

    reg [31:0] registers [0:31]; // 32 registers with 32 bits each

    // Read operation
    always @(*) begin
        read_data1 = (read_reg1 == 5'd0) ? 32'd0 : registers[read_reg1]; // x0 is always 0
        read_data2 = (read_reg2 == 5'd0) ? 32'd0 : registers[read_reg2]; // x0 is always 0
    end

    // Write operation
    always @(posedge clk) begin
        if (reg_write && write_reg != 5'd0) begin
            registers[write_reg] <= write_data; // Write to register if not x0
        end
    end

endmodule

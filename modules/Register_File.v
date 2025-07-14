module RegisterFile (
    input clk,                      // clock signal
    input [4:0] read_reg1,          // take address of register 1 to read stored value
    input [4:0] read_reg2,          // take address of register 2 to read stored value
    input [4:0] write_reg,          // take address of register to write value
    input [31:0] write_data,        // data to write
    input write_enable,             // enabling signal for writing register
	
    output reg [31:0] read_data1,   // data from register 1
    output reg [31:0] read_data2    // data from register 2
);

    reg [31:0] registers [0:31]; // 32 registers with 32 bits each

    // Read operation
    always @(*) begin
        read_data1 = (read_reg1 == 5'd0) ? 32'd0 : registers[read_reg1]; // x0 is always 0
        read_data2 = (read_reg2 == 5'd0) ? 32'd0 : registers[read_reg2]; // x0 is always 0
    end

    // Write operation
    always @(posedge clk) begin
        if (write_enable && write_reg != 5'd0) begin
            registers[write_reg] <= write_data; // write to register if not x0
        end
    end

endmodule

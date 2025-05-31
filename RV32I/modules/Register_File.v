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

    /* If the waveform shows unknown value 'x' in register file's data, deannotate this.
    integer i;
    initial begin
    for (i = 1; i < 32; i = i + 1) registers[i] = 32'b0;
    end*/

    // Read operation
    always @(*) begin
        if (read_reg1 == 5'd0) begin
            read_data1 = 32'd0;
        end

        else if (write_enable && (write_reg == read_reg1)) begin
            read_data1 = write_data;
        end
        else begin
            read_data1 = registers[read_reg1];
        end

        if (read_reg2 == 5'd0) begin
            read_data2 = 32'd0;
        end

        else if (write_enable && (write_reg == read_reg2)) begin
            read_data2 = write_data;
        end
        else begin
            read_data2 = registers[read_reg2];
        end
    end

    // Write operation
    always @(posedge clk) begin
        if (write_enable && write_reg != 5'd0) begin
            registers[write_reg] <= write_data; // write to register if not x0
        end
    end

endmodule
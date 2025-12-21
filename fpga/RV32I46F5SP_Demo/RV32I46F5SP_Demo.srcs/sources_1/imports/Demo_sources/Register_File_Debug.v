module RegisterFileDebug (
    input clk,                      // clock signal
    input clk_enable,
    input [4:0] read_reg1,          // take address of register 1 to read stored value
    input [4:0] read_reg2,          // take address of register 2 to read stored value
    input [4:0] write_reg,          // take address of register to write value
    input [31:0] write_data,        // data to write
    input write_enable,             // enabling signal for writing register
	
    output reg [31:0] read_data1,   // data from register 1
    output reg [31:0] read_data2,    // data from register 2

    // Debug outputs: last-written register and its data from WB Phase
    output [4:0] debug_reg_addr,
    output [31:0] debug_reg_data
);

    reg [31:0] registers [0:31]; // 32 registers with 32 bits each
    
    integer i;
    initial begin
    for (i = 1; i < 32; i = i + 1) registers[i] = 32'b0;
    end

    // Read operation
    always @(*) begin
        if (read_reg1 == 5'd0) begin
            read_data1 = 32'd0;
        end else if (clk_enable && write_enable && (write_reg == read_reg1)) begin
            read_data1 = write_data;
        end else begin
            read_data1 = registers[read_reg1];
        end

        if (read_reg2 == 5'd0) begin
            read_data2 = 32'd0;
        end else if (clk_enable && write_enable && (write_reg == read_reg2)) begin
            read_data2 = write_data;
        end else begin
            read_data2 = registers[read_reg2];
        end
    end

    // Write operation
    always @(posedge clk) begin
        if (clk_enable && write_enable && write_reg != 5'd0) begin
            registers[write_reg] <= write_data; // write to register if not x0
        end
    end

    // Debug output operation
    reg [4:0]  debug_reg_addr_q;
    reg [31:0] debug_reg_data_q;

    always @(posedge clk) begin
        if (clk_enable && write_enable && write_reg != 5'd0) begin
            debug_reg_addr_q <= write_reg;
            debug_reg_data_q <= write_data;
        end
    end
    assign debug_reg_addr = debug_reg_addr_q;
    assign debug_reg_data = debug_reg_data_q;

endmodule
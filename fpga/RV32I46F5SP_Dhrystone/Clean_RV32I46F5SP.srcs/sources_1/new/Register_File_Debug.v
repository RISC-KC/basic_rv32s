module RegisterFileDebug (
    input              clk,
    input              clk_enable,
    input      [4:0]   read_reg1,
    input      [4:0]   read_reg2,
    input              write_enable,
    input      [4:0]   write_reg,
    input      [31:0]  write_data,

    // Standard read outputs
    output reg [31:0]  read_data1,
    output reg [31:0]  read_data2,

    // Debug outputs: last-written register and its data
    output     [4:0]   debug_reg_addr,
    output     [31:0]  debug_reg_data
);

    // 32×32-bit register array
    reg [31:0] registers [0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

    // ------------------------------------------------------------
    // Read ports with write-forwarding and x0 hardwired to 0
    // ------------------------------------------------------------
    always @(*) begin
        // Read port 1
        if (read_reg1 == 5'd0)
            read_data1 = 32'd0;
        else if (clk_enable && write_enable && write_reg == read_reg1)
            read_data1 = write_data;
        else
            read_data1 = registers[read_reg1];

        // Read port 2
        if (read_reg2 == 5'd0)
            read_data2 = 32'd0;
        else if (clk_enable && write_enable && write_reg == read_reg2)
            read_data2 = write_data;
        else
            read_data2 = registers[read_reg2];
    end

    // ------------------------------------------------------------
    // Write port
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (clk_enable && write_enable && write_reg != 5'd0)
            registers[write_reg] <= write_data;
    end

    // ------------------------------------------------------------
    // Debug output: latch last write address & data
    // ------------------------------------------------------------
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

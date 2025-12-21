module DataMemory (
    input clk,
    input clk_enable,
    input write_enable,
    input [31:0] address,
    input [31:0] write_data,
    input [3:0] write_mask,

    input [31:0] rom_read_data,
    output [31:0] rom_address,
    
    output reg [31:0] read_data,
    output reg [31:0] written_data,
    output reg [31:0] written_address
);

    reg [31:0] memory [0:8191];     // 32KB = 8192 words
    reg [31:0] new_word;

    // Address decode = 0x10000000~0x10007FFF → 0~8191
    wire [31:0] extended_mask = {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};
    wire ram_access = (address[31:16] == 16'h1000);
    wire rom_access = (address[31:16] == 16'h0000);
    wire [12:0] ram_address = address[14:2];  // word addressing

    assign rom_address = address;

    integer i;
    initial begin
        for (i=0; i<8192; i=i+1) memory[i] = 32'b0;
        $readmemh("C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_RV32I46F5SP/Clean_RV32I46F5SP.srcs/sim_1/imports/basic_rv32s-31344d35dd9090e10fd692f257ae98d7bf7702a7/data_init.mem", memory, 13'h1424);
        written_data = 32'b0;
        written_address = 32'b0;
    end

    always @(*) begin
        if (ram_access) begin
            read_data = memory[ram_address];
        end else if (rom_access) begin
            read_data = rom_read_data;
        end else begin
            read_data = 32'b0;  // 잘못된 주소 접근 시 0 반환
        end
    end

    always @(posedge clk) begin
        if (clk_enable && write_enable && ram_access) begin
            new_word = ((memory[ram_address] & ~extended_mask) | (write_data & extended_mask));
            memory[ram_address] <= new_word;
            written_data <= new_word;
            written_address <= ram_address;
        end
    end
endmodule
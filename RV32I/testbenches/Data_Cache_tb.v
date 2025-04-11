`timescale 1ns/1ps

module DataCache_tb;
    reg clk;
    reg reset;
    reg [9:0] address;
    reg read_enable;
    reg write_enable;
    reg [31:0] write_data;
    reg [3:0] write_mask;
    reg [31:0] dm_data;

    wire hit;
    wire [31:0] read_data;
    wire [9:0] flush_address;
    wire [31:0] flush_data;
    wire [3:0] flush_mask;
    wire flush_done;

    DataCache data_cache (
        .clk(clk),
        .reset(reset),
        .address(address),
        .read_enable(read_enable),
        .write_enable(write_enable),
        .write_data(write_data),
        .write_mask(write_mask),
        .dm_data(dm_data),

        .hit(hit),
        .read_data(read_data),
        .flush_address(flush_address),
        .flush_data(flush_data),
        .flush_mask(flush_mask),
        .flush_done(flush_done)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/Data_Cache_tb_result.vcd");
        $dumpvars(0, data_cache);

        $display("==================== Data Cache Test START ====================\n");

        clk = 0;
        address = 10'b0;
        write_enable = 0;
        write_data = 32'b0;
        write_mask = 4'b0;
        dm_data = 4'b0;

        reset = 1; #10;
        reset = 0; #10;

        // Scenario:
        // 1. (Read) First line of 10101 index is updated with DEADBEEF. (tag: 00000) [Update -> Read]
        // 2. (Read) Second line of 10101 index is updated with CAFEBABE. (tag: 00001) [Update -> Read]
        // 3. (Write) 0x12 is written in most significant byte of First line of 10101 index. [Write]
        // 4. (Read) First line of 10101 index is updated with 19721121 (tag: 00010) so tag 00000 should be flushed
        //           because we updated from DEADBEEF to 12ADBEEF. [Flush -> Update -> Read]
        // 5. (Read) Second line of 10101 index is updated with 12ADBEEF (tag: 00000) and flush is not required. [Update -> Read]
        // 6. (Read) Read from first line. (tag: 00010) [Read]

        // Test 1: Cache update
        $display("Cache update: ");
        
        read_enable = 1;
        address = 10'b00000_10101; 
        dm_data = 32'hDEADBEEF; #10;

        $display("Before: address: %b, hit: %b, read_data: %h", address, hit, read_data);
        #10; $display("After: address: %b, hit: %b, read_data: %h", address, hit, read_data);

        // Test 2: Update second way at same index
        $display("\nUpdate second way at same index: ");

        address = 10'b00001_10101;
        dm_data = 32'hCAFEBABE; #10;
        
        $display("Before: address: %b, hit: %b, read_data: %h", address, hit, read_data);
        #10; $display("After: address: %b, hit: %b, read_data: %h", address, hit, read_data);
        
        // Test 3: Write cache
        $display("\nWrite cache: ");

        read_enable = 0;
        write_enable = 1;
        address = 10'b00000_10101;
        write_data = 32'h12345678; 
        write_mask = 4'b1000;
        #10;
        
        read_enable = 1;
        write_enable = 0;
        address = 10'b00000_10101; 
        #10;

        $display("address: %b, hit: %b, read_data: %h", address, hit, read_data);

        // Test 4: LRU and flush
        $display("\nLRU and flush: ");

        read_enable = 0;
        write_enable = 1;
        address = 10'b00010_10101;
        write_data = 32'h19721121; 
        write_mask = 4'b0011;
        #10;

        $display("- Flush start: ");
        $display("  - address: %b, hit: %b, read_data: %h", address, hit, read_data);
        $display("  - flush_address: %b, flush_data: %h, flush_done: %b", flush_address, flush_data, flush_done);

        #10;

        $display("\n- Flush done, write start: ");
        $display("  - address: %b, hit: %b, read_data: %h", address, hit, read_data);
        $display("  - flush_address: %b, flush_data: %h, flush_done: %b", flush_address, flush_data, flush_done);

        read_enable = 1;
        write_enable = 0;
        #10;

        $display("\n- Write done: ");
        $display("  - address: %b, hit: %b, read_data: %h", address, hit, read_data);
        $display("  - flush_address: %b, flush_data: %h, flush_done: %b", flush_address, flush_data, flush_done);

        read_enable = 1;
        write_enable = 0;
        address = 10'b00000_10101;
        dm_data = 32'h12adbeef;
        #10;

        $display("\nBefore: address: %b, hit: %b, read_data: %h, flush_address: %b, flush_data: %h, flush_done: %b", address, hit, read_data, flush_address, flush_data, flush_done);
        #10; $display("After: address: %b, hit: %b, read_data: %h, flush_address: %b, flush_data: %h, flush_done: %b", address, hit, read_data, flush_address, flush_data, flush_done);

        address = 10'b00010_10101; #10;
        
        $display("\naddress: %b, hit: %b, read_data: %h", address, hit, read_data);

        $display("\n====================  Data Cache Test END  ====================");
        $stop;
    end

endmodule
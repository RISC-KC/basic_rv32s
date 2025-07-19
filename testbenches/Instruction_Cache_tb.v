`timescale 1ns/1ps

module InstructionCache_tb;
    reg clk;
    reg reset;
    reg [9:0] address;
    reg update_enable;
    reg [31:0] im_data;

    wire hit;
    wire [31:0] data;

    InstructionCache instruction_cache (
        .clk(clk),
        .reset(reset),
        .address(address),
        .update_enable(update_enable),
        .im_data(im_data),
        .hit(hit),
        .data(data)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/Instruction_Cache_tb_result.vcd");
        $dumpvars(0, instruction_cache);

        $display("==================== Instruction Cache Test START ====================\n");

        clk = 0;
        reset = 0;
        address = 10'b0;
        update_enable = 0;
        im_data = 32'b0;

        // Test 1: Before reset
        $display("Before reset: ");
        address = 10'b00000_10101; #10;
        $display("address: %b, hit: %b, data: %h", address, hit, data);

        // Test 2: After reset
        $display("\nAfter reset: ");
        reset = 1; #10;
        address = 10'b00000_10101; #10;
        $display("address: %b, hit: %b, data: %h", address, hit, data);
        reset = 0; #10;

        // Test 3: Cold miss
        $display("\nCold miss: ");
        address = 10'b00000_10101; #10;
        $display("address: %b, hit: %b, data: %h", address, hit, data);

        // Test 4: Cache hit after update
        $display("\nCache hit after update: ");
        
        update_enable = 1;
        im_data = 32'hDEADBEEF;
        #10;

        update_enable = 0;
        address = 10'b00000_10101; #10;
        $display("address: %b, hit: %b, data: %h", address, hit, data);

        // Test 5: Update second way at same index
        $display("\nUpdate second way at same index: ");

        update_enable = 1;
        address = 10'b00001_10101;
        im_data = 32'hCAFEBABE;
        #10;
        
        update_enable = 0; #10;
        $display("address: %b, hit: %b, data: %h", address, hit, data);

        // Test 6: LRU replacement
        $display("\nLRU replacement: ");

        update_enable = 1;
        address = 10'b00010_10101;
        im_data = 32'h12345678;
        #10;

        update_enable = 0;
        address = 10'b00000_10101; #10;
        $display("address: %b, hit: %b, data: %h", address, hit, data);

        address = 10'b00001_10101; #10;
        $display("address: %b, hit: %b, data: %h", address, hit, data);

        address = 10'b00010_10101; #10;
        $display("address: %b, hit: %b, data: %h", address, hit, data);

        $display("\n====================  Instruction Cache Test END  ====================");
        $stop;
    end

endmodule
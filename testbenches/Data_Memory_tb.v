`timescale 1ns/1ps

module DataMemory_tb;
    reg clk;
    reg read_enable;
    reg write_enable;
    reg [9:0] address;
    reg [31:0] write_data;
    reg [3:0] write_mask;

    wire [31:0] read_data;
    wire read_done;

    DataMemory data_memory (
        .clk(clk),
        .read_enable(read_enable),
        .write_enable(write_enable),
        .address(address),
        .write_data(write_data),
        .write_mask(write_mask),
        .read_data(read_data),
        .read_done(read_done)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/Data_Memory_tb_result.vcd");
        $dumpvars(0, data_memory);

        $display("==================== Data Memory Test START ====================");

        // Initialize signals
        clk = 0;
        read_enable = 0;
        write_enable = 0;
        address = 10'd0;
        write_data = 32'h00000000;
        write_mask = 4'b0000;

        // Test 1: Initialization check
        $display("\nInitialization check: ");

        address = 10'd1;
        read_enable = 1;
        #10;

        $display("address: %h, write_data: %h, mask: %b, read_data: %h, read_done: %b", address, write_data, write_mask, read_data, read_done);
        
        // Test 2: Full Write and Read
        $display("\nFull Write and Read: ");

        address = 10'd1;
        write_data = 32'hDEADBEEF;
        write_mask = 4'b1111;  // Full word write
        read_enable = 0;
        write_enable = 1;
        #10;
        
        // Read from the same address
        read_enable = 1;
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h, read_done: %b", address, write_data, write_mask, read_data, read_done);

        // Test 3: Partial Write
        $display("\nPartial Write: ");

        write_data = 32'hCAFECAFE;
        write_mask = 4'b1000;
        read_enable = 0;
        write_enable = 1;
        #10;
        
        read_enable = 1;
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h, read_done: %b", address, write_data, write_mask, read_data, read_done);

        write_data = 32'hCAFECAFE;
        write_mask = 4'b0100;
        read_enable = 0;
        write_enable = 1;
        #10;
        
        read_enable = 1;
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h, read_done: %b", address, write_data, write_mask, read_data, read_done);

        write_data = 32'hCAFECAFE;
        write_mask = 4'b0010;
        read_enable = 0;
        write_enable = 1;
        #10;
        
        read_enable = 1;
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h, read_done: %b", address, write_data, write_mask, read_data, read_done);

        write_data = 32'hCAFECAFE;
        write_mask = 4'b0001;
        read_enable = 0;
        write_enable = 1;
        #10;
        
        read_enable = 1;
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h, read_done: %b", address, write_data, write_mask, read_data, read_done);

        write_data = 32'hDEADBEEF;
        write_mask = 4'b1100;
        read_enable = 0;
        write_enable = 1;
        #10;
        
        read_enable = 1;
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h, read_done: %b", address, write_data, write_mask, read_data, read_done);

        write_data = 32'hDEADBEEF;
        write_mask = 4'b0011;
        read_enable = 0;
        write_enable = 1;
        #10;
        
        read_enable = 1;
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h, read_done: %b", address, write_data, write_mask, read_data, read_done);

        // Test 4: Idle state
        $display("\nIdle state: ");

        write_data = 32'hDEADBEEF;
        write_mask = 4'b1111;
        read_enable = 0;
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h, read_done: %b", address, write_data, write_mask, read_data, read_done);

        read_enable = 1;
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h, read_done: %b", address, write_data, write_mask, read_data, read_done);

        $display("\n====================  Data Memory Test END  ====================");
        $stop;
    end

endmodule

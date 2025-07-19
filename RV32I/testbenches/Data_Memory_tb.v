`timescale 1ns/1ps

module DataMemory_tb;
    reg clk;
    reg write_enable;
    reg [31:0] address;
    reg [31:0] write_data;
    reg [3:0] write_mask;

    wire [31:0] read_data; // If cached structure, modify to cache block size. e.g.) [255:0]

    DataMemory data_memory (
        .clk(clk),
        .write_enable(write_enable),
        .address(address),
        .write_data(write_data),
        .write_mask(write_mask),
        .read_data(read_data)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbenches/results/waveforms/Data_Memory_tb_result.vcd");
        $dumpvars(0, data_memory);

        $display("==================== Data Memory Test START ====================");

        // Initialize signals
        clk = 0;
        write_enable = 0;
        address = 32'd0;
        write_data = 32'h00000000;
        write_mask = 4'b0000;

        // Test 1: Initialization check
        $display("\nInitialization check: ");

        address = 32'd1;
        #10;

        $display("address: %h, write_data: %h, mask: %b, read_data: %h", address, write_data, write_mask, read_data);
        
        // Test 2: Full Write and Read
        $display("\nFull Write and Read: ");

        address = 32'd1;
        write_data = 32'hDEADBEEF;
        write_mask = 4'b1111;  // Full word write
        write_enable = 1;
        #10;
        
        // Read from the same address
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h", address, write_data, write_mask, read_data);

        // Test 3: Partial Write
        $display("\nPartial Write: ");

        write_data = 32'hCAFECAFE;
        write_mask = 4'b1000;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h", address, write_data, write_mask, read_data);

        write_data = 32'hCAFECAFE;
        write_mask = 4'b0100;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h", address, write_data, write_mask, read_data);

        write_data = 32'hCAFECAFE;
        write_mask = 4'b0010;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h", address, write_data, write_mask, read_data);

        write_data = 32'hCAFECAFE;
        write_mask = 4'b0001;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h", address, write_data, write_mask, read_data);

        write_data = 32'hDEADBEEF;
        write_mask = 4'b1100;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h", address, write_data, write_mask, read_data);

        write_data = 32'hDEADBEEF;
        write_mask = 4'b0011;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h", address, write_data, write_mask, read_data);

        // Test 4: Additional Write
        $display("\nAdditional Write: ");

        address = 32'd5;

        write_data = 32'h19721121;
        write_mask = 4'b1100;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h", address, write_data, write_mask, read_data);

        // Test 5: Idle state
        $display("\nIdle state: ");

        write_data = 32'hDEADBEEF;
        write_mask = 4'b1111;
        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h", address, write_data, write_mask, read_data);

        write_enable = 0;
        #10;
        
        $display("address: %h, write_data: %h, mask: %b, read_data: %h", address, write_data, write_mask, read_data);

        $display("\n====================  Data Memory Test END  ====================");
        $stop;
    end

endmodule

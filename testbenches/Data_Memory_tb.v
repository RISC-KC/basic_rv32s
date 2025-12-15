`timescale 1ns/1ps

module DataMemory_tb;
    reg clk;
    reg write_enable;
    reg [31:0] address;
    reg [31:0] write_data;
    reg [3:0] write_mask;
    reg [31:0] rom_read_data;

    wire [31:0] read_data;
    wire [31:0] rom_address;

    DataMemory data_memory (
        .clk(clk),
        .write_enable(write_enable),
        .address(address),
        .write_data(write_data),
        .write_mask(write_mask),
        .rom_read_data(rom_read_data),
        .rom_address(rom_address),
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
        address = 32'h00000000;
        write_data = 32'h00000000;
        write_mask = 4'b0000;
        rom_read_data = 32'h00000000;

        // ========================================================================
        // Test 1: ROM Address Region Test (0x0000xxxx)
        // ========================================================================
        $display("\n[Test 1] ROM Address Region Read (0x0000xxxx):");
        
        // ROM access should output rom_address and use rom_read_data as read_data
        address = 32'h00000004;
        rom_read_data = 32'h12345678;
        #10;
        $display("  address=%h, rom_address=%h, rom_read_data=%h, read_data=%h", 
                 address, rom_address, rom_read_data, read_data);
        $display("  -> Expected: rom_address=00000004, read_data=12345678 (from ROM)");
        
        address = 32'h00001000;
        rom_read_data = 32'hABCDEF01;
        #10;
        $display("  address=%h, rom_address=%h, rom_read_data=%h, read_data=%h", 
                 address, rom_address, rom_read_data, read_data);
        $display("  -> Expected: rom_address=00001000, read_data=ABCDEF01 (from ROM)");
        
        address = 32'h0000FFFC;
        rom_read_data = 32'hCAFEBABE;
        #10;
        $display("  address=%h, rom_address=%h, rom_read_data=%h, read_data=%h", 
                 address, rom_address, rom_read_data, read_data);
        $display("  -> Expected: rom_address=0000FFFC, read_data=CAFEBABE (from ROM)");

        // ========================================================================
        // Test 2: RAM Address Region Initialization (0x1000xxxx)
        // ========================================================================
        $display("\n[Test 2] RAM Address Region Initialization (0x1000xxxx):");

        address = 32'h10000004;
        rom_read_data = 32'hDEADBEEF;  // Should be ignored in RAM region
        #10;
        $display("  address=%h, rom_read_data=%h (ignored), read_data=%h", 
                 address, rom_read_data, read_data);
        $display("  -> Expected: read_data=00000000 (RAM initialized to 0)");
        
        // ========================================================================
        // Test 3: RAM Full Write and Read (0x1000xxxx)
        // ========================================================================
        $display("\n[Test 3] RAM Full Write and Read:");

        address = 32'h10000004;
        write_data = 32'hDEADBEEF;
        write_mask = 4'b1111;
        write_enable = 1;
        rom_read_data = 32'h12345678;  // Should be ignored in RAM region
        #10;
        
        write_enable = 0;
        #10;
        
        $display("  address=%h, write_data=%h, mask=%b, read_data=%h", 
                 address, write_data, write_mask, read_data);
        $display("  -> Expected: read_data=DEADBEEF (written to RAM, ROM data ignored)");

        // ========================================================================
        // Test 4: RAM Partial Write (Byte Masking)
        // ========================================================================
        $display("\n[Test 4] RAM Partial Write (Byte Masking):");

        // Write to MSB only (mask = 1000)
        write_data = 32'hCAFECAFE;
        write_mask = 4'b1000;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("  mask=1000: address=%h, write_data=%h, read_data=%h", 
                 address, write_data, read_data);
        $display("  -> Expected: read_data=CAADBEEF (only byte[31:24] changed)");

        // Write to byte[23:16] (mask = 0100)
        write_data = 32'hCAFECAFE;
        write_mask = 4'b0100;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("  mask=0100: address=%h, write_data=%h, read_data=%h", 
                 address, write_data, read_data);
        $display("  -> Expected: read_data=CAFEBEEF (only byte[23:16] changed)");

        // Write to byte[15:8] (mask = 0010)
        write_data = 32'hCAFECAFE;
        write_mask = 4'b0010;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("  mask=0010: address=%h, write_data=%h, read_data=%h", 
                 address, write_data, read_data);
        $display("  -> Expected: read_data=CAFECAEF (only byte[15:8] changed)");

        // Write to LSB only (mask = 0001)
        write_data = 32'hCAFECAFE;
        write_mask = 4'b0001;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("  mask=0001: address=%h, write_data=%h, read_data=%h", 
                 address, write_data, read_data);
        $display("  -> Expected: read_data=CAFECAFE (only byte[7:0] changed)");

        // Write upper half-word (mask = 1100)
        write_data = 32'hDEADBEEF;
        write_mask = 4'b1100;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("  mask=1100: address=%h, write_data=%h, read_data=%h", 
                 address, write_data, read_data);
        $display("  -> Expected: read_data=DEADCAFE (upper half-word changed)");

        // Write lower half-word (mask = 0011)
        write_data = 32'hDEADBEEF;
        write_mask = 4'b0011;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("  mask=0011: address=%h, write_data=%h, read_data=%h", 
                 address, write_data, read_data);
        $display("  -> Expected: read_data=DEADBEEF (lower half-word changed)");

        // ========================================================================
        // Test 5: RAM Multiple Address Write/Read
        // ========================================================================
        $display("\n[Test 5] RAM Multiple Address Write/Read:");

        address = 32'h10000014;
        write_data = 32'h19721121;
        write_mask = 4'b1111;
        write_enable = 1;
        #10;
        
        write_enable = 0;
        #10;
        
        $display("  address=%h, write_data=%h, mask=%b, read_data=%h", 
                 address, write_data, write_mask, read_data);

        // Read from previously written address (0x10000004)
        address = 32'h10000004;
        #10;
        $display("  address=%h (previous), read_data=%h", address, read_data);
        $display("  -> Expected: read_data=DEADBEEF (previously written)");

        // ========================================================================
        // Test 6: Address Region Boundary Test
        // ========================================================================
        $display("\n[Test 6] Address Region Boundary Test:");
        
        // ROM region upper boundary (0x0000FFFF)
        address = 32'h0000FFFC;
        rom_read_data = 32'hFFFFFFFF;
        write_enable = 0;
        #10;
        $display("  ROM boundary: address=%h, rom_address=%h, read_data=%h", 
                 address, rom_address, read_data);
        $display("  -> Expected: read_data=FFFFFFFF (from ROM)");
        
        // RAM region lower boundary (0x10000000)
        address = 32'h10000000;
        write_data = 32'h11111111;
        write_mask = 4'b1111;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        $display("  RAM boundary: address=%h, write_data=%h, read_data=%h", 
                 address, write_data, read_data);
        $display("  -> Expected: read_data=11111111 (written to RAM)");

        // ========================================================================
        // Test 7: Invalid Address Region (not ROM or RAM)
        // ========================================================================
        $display("\n[Test 7] Invalid Address Region:");
        
        address = 32'h20000000;  // Invalid region
        rom_read_data = 32'h12345678;
        #10;
        $display("  address=%h, rom_read_data=%h, read_data=%h", 
                 address, rom_read_data, read_data);
        $display("  -> Expected: read_data=00000000 (invalid address returns 0)");
        
        address = 32'hFFFFFFFF;  // Invalid region
        #10;
        $display("  address=%h, read_data=%h", address, read_data);
        $display("  -> Expected: read_data=00000000 (invalid address returns 0)");

        // ========================================================================
        // Test 8: ROM vs RAM Read Priority Test
        // ========================================================================
        $display("\n[Test 8] ROM vs RAM Read Priority:");
        
        // Write to RAM address
        address = 32'h10000020;
        write_data = 32'hAAAAAAAA;
        write_mask = 4'b1111;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        $display("  RAM write: address=%h, write_data=%h, read_data=%h", 
                 address, write_data, read_data);
        
        // Switch to ROM address with different data
        address = 32'h00000020;
        rom_read_data = 32'hBBBBBBBB;
        #10;
        $display("  ROM read:  address=%h, rom_read_data=%h, read_data=%h", 
                 address, rom_read_data, read_data);
        $display("  -> Expected: read_data=BBBBBBBB (ROM data, not RAM data)");

        // ========================================================================
        // Test 9: RAM Write Enable Control
        // ========================================================================
        $display("\n[Test 9] RAM Write Enable Control:");

        address = 32'h10000024;
        write_data = 32'hDEADBEEF;
        write_mask = 4'b1111;
        write_enable = 0;  // Write disabled
        #10;
        
        $display("  write_enable=0: address=%h, write_data=%h, read_data=%h", 
                 address, write_data, read_data);
        $display("  -> Expected: read_data=00000000 (write not performed)");
        
        write_enable = 1;  // Write enabled
        #10;
        write_enable = 0;
        #10;
        
        $display("  write_enable=1: address=%h, write_data=%h, read_data=%h", 
                 address, write_data, read_data);
        $display("  -> Expected: read_data=DEADBEEF (write performed)");

        // ========================================================================
        // Test 10: ROM Address Output Verification
        // ========================================================================
        $display("\n[Test 10] ROM Address Output Verification:");
        
        address = 32'h00000100;
        #10;
        $display("  address=%h, rom_address=%h", address, rom_address);
        $display("  -> Expected: rom_address=00000100 (same as input address)");
        
        address = 32'h00002000;
        #10;
        $display("  address=%h, rom_address=%h", address, rom_address);
        $display("  -> Expected: rom_address=00002000 (same as input address)");

        $display("\n====================  Data Memory Test END  ====================");
        $stop;
    end

endmodule
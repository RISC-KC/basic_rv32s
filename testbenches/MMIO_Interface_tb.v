`timescale 1ns/1ps

module mmio_interface_tb;
    reg clk;
    reg reset;
    reg clk_enable;
    reg [31:0] data_memory_write_data;
    reg [31:0] data_memory_address;
    reg data_memory_write_enable;
    reg UART_busy;

    wire [7:0] mmio_uart_tx_data;
    wire [31:0] mmio_uart_status;
    wire mmio_uart_tx_start;
    wire mmio_uart_status_hit;

    mmio_interface MMIO_Interface (
        .clk(clk),
        .reset(reset),
        .clk_enable(clk_enable),
        .data_memory_write_data(data_memory_write_data),
        .data_memory_address(data_memory_address),
        .data_memory_write_enable(data_memory_write_enable),
        .UART_busy(UART_busy),
        .mmio_uart_tx_data(mmio_uart_tx_data),
        .mmio_uart_status(mmio_uart_status),
        .mmio_uart_tx_start(mmio_uart_tx_start),
        .mmio_uart_status_hit(mmio_uart_status_hit)
    );

    // Clock generation (50MHz, 20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        $dumpfile("testbenches/results/waveforms/mmio_interface_tb_result.vcd");
        $dumpvars(0, MMIO_Interface);

        // Initialize signals
        reset = 1;
        clk_enable = 1;
        data_memory_write_data = 32'h0;
        data_memory_address = 32'h0;
        data_memory_write_enable = 0;
        UART_busy = 0;
        #10;
        reset = 0;
        #10;

        // Wait for initial clock edge
        @(posedge clk);
        #1;

        // Test sequence
        $display("==================== MMIO Interface Test START ====================");

        // Test 1: Write 'A' to UART TX (UART_busy = 0)
        $display("\n[Test 1] Write 'A' (0x41) to UART TX (busy=0):");
        
        @(posedge clk);
        data_memory_address = 32'h10010000;
        data_memory_write_data = 32'h00000041;
        data_memory_write_enable = 1;
        UART_busy = 0;
        
        @(posedge clk);
        #1;
        $display("  addr=%h, wd=%h, we=%b, busy=%b", 
                 data_memory_address, data_memory_write_data, 
                 data_memory_write_enable, UART_busy);
        $display("  => tx_data=%h, tx_start=%b, status_hit=%b", 
                 mmio_uart_tx_data, mmio_uart_tx_start, mmio_uart_status_hit);
        
        if (mmio_uart_tx_data == 8'h41 && mmio_uart_tx_start == 1'b1)
            $display("  [PASS] TX data stored, start pulse generated");
        else
            $display("  [FAIL] Expected tx_data=0x41, tx_start=1");

        data_memory_write_enable = 0;

        // Test 2: Verify tx_start pulse is 1 cycle only
        $display("\n[Test 2] Verify tx_start pulse (should be 0 now):");
        
        @(posedge clk);
        #1;
        $display("  tx_start=%b", mmio_uart_tx_start);
        
        if (mmio_uart_tx_start == 1'b0)
            $display("  [PASS] tx_start returned to 0 (1 cycle pulse)");
        else
            $display("  [FAIL] tx_start should be 0");

        // Test 3: Write 'B' to UART TX while busy=1 (Write Drop)
        $display("\n[Test 3] Write 'B' (0x42) to UART TX (busy=1, should drop):");
        
        @(posedge clk);
        data_memory_address = 32'h10010000;
        data_memory_write_data = 32'h00000042;
        data_memory_write_enable = 1;
        UART_busy = 1;
        
        @(posedge clk);
        #1;
        $display("  addr=%h, wd=%h, we=%b, busy=%b", 
                 data_memory_address, data_memory_write_data, 
                 data_memory_write_enable, UART_busy);
        $display("  => tx_data=%h, tx_start=%b", 
                 mmio_uart_tx_data, mmio_uart_tx_start);
        
        if (mmio_uart_tx_data == 8'h41 && mmio_uart_tx_start == 1'b0)
            $display("  [PASS] Write dropped, tx_data unchanged (0x41)");
        else
            $display("  [FAIL] Expected tx_data=0x41 (unchanged), tx_start=0");

        data_memory_write_enable = 0;

        // Test 4: Read UART Status (busy=0)
        $display("\n[Test 4] Read UART Status (busy=0):");
        
        @(posedge clk);
        data_memory_address = 32'h10010004;
        UART_busy = 0;
        
        #1;
        $display("  addr=%h, busy=%b", data_memory_address, UART_busy);
        $display("  => status=%h, status_hit=%b", 
                 mmio_uart_status, mmio_uart_status_hit);
        
        if (mmio_uart_status == 32'h00000000 && mmio_uart_status_hit == 1'b1)
            $display("  [PASS] Status=0x00000000 (ready)");
        else
            $display("  [FAIL] Expected status=0x00000000");

        // Test 5: Read UART Status (busy=1)
        $display("\n[Test 5] Read UART Status (busy=1):");
        
        @(posedge clk);
        data_memory_address = 32'h10010004;
        UART_busy = 1;
        
        #1;
        $display("  addr=%h, busy=%b", data_memory_address, UART_busy);
        $display("  => status=%h, status_hit=%b", 
                 mmio_uart_status, mmio_uart_status_hit);
        
        if (mmio_uart_status == 32'h00000001 && mmio_uart_status_hit == 1'b1)
            $display("  [PASS] Status=0x00000001 (busy)");
        else
            $display("  [FAIL] Expected status=0x00000001");

        // Test 6: Non-UART address (should not trigger)
        $display("\n[Test 6] Non-UART address (RAM region 0x10000000):");
        
        @(posedge clk);
        data_memory_address = 32'h10000000;
        data_memory_write_data = 32'h000000FF;
        data_memory_write_enable = 1;
        UART_busy = 0;
        
        @(posedge clk);
        #1;
        $display("  addr=%h, wd=%h, we=%b", 
                 data_memory_address, data_memory_write_data, 
                 data_memory_write_enable);
        $display("  => tx_start=%b, status_hit=%b", 
                 mmio_uart_tx_start, mmio_uart_status_hit);
        
        if (mmio_uart_tx_start == 1'b0 && mmio_uart_status_hit == 1'b0)
            $display("  [PASS] No UART activity (status_hit=0)");
        else
            $display("  [FAIL] Expected status_hit=0, tx_start=0");

        data_memory_write_enable = 0;

        // Test 7: clk_enable = 0 (should freeze)
        $display("\n[Test 7] clk_enable=0 (should freeze):");
        
        @(posedge clk);
        clk_enable = 0;
        data_memory_address = 32'h10010000;
        data_memory_write_data = 32'h00000043;
        data_memory_write_enable = 1;
        UART_busy = 0;
        
        @(posedge clk);
        #1;
        $display("  clk_enable=%b, addr=%h, wd=%h, we=%b", 
                 clk_enable, data_memory_address, 
                 data_memory_write_data, data_memory_write_enable);
        $display("  => tx_data=%h, tx_start=%b", 
                 mmio_uart_tx_data, mmio_uart_tx_start);
        
        if (mmio_uart_tx_data == 8'h41 && mmio_uart_tx_start == 1'b0)
            $display("  [PASS] Module frozen, tx_data unchanged (0x41)");
        else
            $display("  [FAIL] Expected tx_data=0x41 (unchanged), tx_start=0");

        clk_enable = 1;
        data_memory_write_enable = 0;

        // Test 8: Write 'C' to UART TX after enable
        $display("\n[Test 8] Write 'C' (0x43) to UART TX (normal operation):");
        
        @(posedge clk);
        data_memory_address = 32'h10010000;
        data_memory_write_data = 32'h00000043;
        data_memory_write_enable = 1;
        UART_busy = 0;
        
        @(posedge clk);
        #1;
        $display("  addr=%h, wd=%h, we=%b, busy=%b", 
                 data_memory_address, data_memory_write_data, 
                 data_memory_write_enable, UART_busy);
        $display("  => tx_data=%h, tx_start=%b", 
                 mmio_uart_tx_data, mmio_uart_tx_start);
        
        if (mmio_uart_tx_data == 8'h43 && mmio_uart_tx_start == 1'b1)
            $display("  [PASS] TX data updated to 'C' (0x43)");
        else
            $display("  [FAIL] Expected tx_data=0x43, tx_start=1");

        data_memory_write_enable = 0;

        // Test 9: Multiple writes simulation
        $display("\n[Test 9] Multiple writes (simulating putchar loop):");
        
        repeat(3) begin
            @(posedge clk);
            data_memory_address = 32'h10010000;
            data_memory_write_data = data_memory_write_data + 1;
            data_memory_write_enable = 1;
            UART_busy = 0;
            
            @(posedge clk);
            #1;
            $display("  Write data=%h => tx_data=%h, tx_start=%b", 
                     data_memory_write_data, mmio_uart_tx_data, mmio_uart_tx_start);
            
            data_memory_write_enable = 0;
            
            @(posedge clk);
            #1;
            $display("  Next cycle => tx_start=%b (should be 0)", mmio_uart_tx_start);
        end

        // Wait a few cycles
        repeat(5) @(posedge clk);

        $display("\n====================  MMIO Interface Test END  ====================");
        $finish;
    end

endmodule
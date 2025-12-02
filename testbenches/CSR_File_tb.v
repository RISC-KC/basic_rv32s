`timescale 1ns/1ps

module CSRFile_tb;
    reg         clk;
    reg         reset;
    reg         trapped;
    reg         csr_write_enable;
    reg  [11:0] csr_read_address;
    reg  [11:0] csr_write_address;
    reg  [31:0] csr_write_data;

    wire [31:0] csr_read_out;
    wire        csr_ready;

    CSRFile csr_file (
        .clk(clk),
        .reset(reset),
        .trapped(trapped),
        .csr_write_enable(csr_write_enable),
        .csr_read_address(csr_read_address),
        .csr_write_address(csr_write_address),
        .csr_write_data(csr_write_data),

        .csr_read_out(csr_read_out),
        .csr_ready(csr_ready)
    );

    // Generate clock signal, 10ns.
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("==================== CSR File Test START ====================");
        
        // Reset to DEFAULT value, Initialize signals.
        reset = 1;
        trapped = 0;
        csr_write_enable = 0;
        csr_read_address = 12'h000;
        csr_write_address = 12'h000;
        csr_write_data = 32'h0;
        #10;
        reset = 0;
        #10;
        
        // Test 1: Read-only CSRs read.
        csr_read_address = 12'hF11; #10; 
        $display("mvendorid = %h (expected 52564B43)", csr_read_out);
        
        csr_read_address = 12'hF12; #10; 
        $display("marchid = %h (expected 34365335)", csr_read_out);
        
        csr_read_address = 12'hF13; #10;
        $display("mimpid = %h (expected 34364931)", csr_read_out);

        csr_read_address = 12'hF14; #10; 
        $display("mhartid = %h (expected 524B4330)", csr_read_out);

        csr_read_address = 12'h300; #10; 
        $display("mstatus = %h (expected 00001800)", csr_read_out);

        csr_read_address = 12'h301; #10; 
        $display("misa = %h (expected 40000100)", csr_read_out);
        
        // Test 2: MRW CSRs' reset value check
        csr_read_address = 12'h305; #10; 
        $display("mtvec (reset) = %h (expected 00001000)", csr_read_out);
        csr_read_address = 12'h341; #10; 
        $display("mepc  (reset) = %h (expected 00000000)", csr_read_out);
        csr_read_address = 12'h342; #10; 
        $display("mcause(reset) = %h (expected 00000000)", csr_read_out);

        // Test 3: csrrw; mtvec
        csr_read_address = 12'h305; #10; 
        $display("mtvec = %h (expected 00001000)", csr_read_out);

        csr_write_address = 12'h305;
        csr_write_data = 32'h00003000;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #10;

        csr_read_address = 12'h305; #10; 
        $display("mtvec = %h (expected 00003000)", csr_read_out);
        
        // Test 4: csrrw; mepc
        csr_read_address = 12'h341; #10;
        $display("mepc = %h (expected 00000000)", csr_read_out);

        csr_write_address = 12'h341;
        csr_write_data = 32'h00004000;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #10;

        csr_read_address = 12'h341; #10; 
        $display("mepc = %h (expected 00004000)", csr_read_out);
        
        // Test 5: csrrw; mcause
        csr_read_address = 12'h342; #10; 
        $display("mcause = %h (expected 00000000)", csr_read_out);

        csr_write_address = 12'h342;
        csr_write_data = 32'h00000004;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #10;

        csr_read_address = 12'h342;
        #10;

        $display("mcause = %h (expected 00000004)", csr_read_out);
        
        // Test 6: csrrw; Read-only's write ignore test.
        csr_read_address = 12'hF11; #10; 
        $display("Read-only test : mvendorid = %h (expected 52564B43)", csr_read_out);

        csr_write_address = 12'hF11;
        csr_write_data = 32'h00003000;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #10;

        csr_read_address = 12'hF11;
        #10;

        $display("Write ignored : mvendorid = %h (expected 52564B43)", csr_read_out);
        
        // Test 7: mcycle/minstret reset value check
        csr_read_address = 12'hB00; #10;
        $display("mcycle (lower 32-bit, reset) = %h (expected 00000000)", csr_read_out);
        
        csr_read_address = 12'hB80; #10;
        $display("mcycleh (upper 32-bit, reset) = %h (expected 00000000)", csr_read_out);
        
        csr_read_address = 12'hB02; #10;
        $display("minstret (lower 32-bit, reset) = %h (expected 00000000)", csr_read_out);
        
        csr_read_address = 12'hB82; #10;
        $display("minstreth (upper 32-bit, reset) = %h (expected 00000000)", csr_read_out);

        // Test 8: csrrw; mcycle lower 32-bit
        csr_read_address = 12'hB00; #10;
        $display("mcycle (before write) = %h (expected 00000000)", csr_read_out);

        csr_write_address = 12'hB00;
        csr_write_data = 32'h12345678;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #10;

        csr_read_address = 12'hB00; #10;
        $display("mcycle (after write) = %h (expected 12345678)", csr_read_out);
        
        // Test 9: csrrw; mcycleh upper 32-bit
        csr_read_address = 12'hB80; #10;
        $display("mcycleh (before write) = %h (expected 00000000)", csr_read_out);

        csr_write_address = 12'hB80;
        csr_write_data = 32'hABCDEF00;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #10;

        csr_read_address = 12'hB80; #10;
        $display("mcycleh (after write) = %h (expected ABCDEF00)", csr_read_out);
        
        csr_read_address = 12'hB00; #10;
        $display("mcycle (should remain) = %h (expected 12345678)", csr_read_out);
        
        $display("Full 64-bit mcycle = %h_%h (expected ABCDEF00_12345678)", 
                 csr_file.mcycle[63:32], csr_file.mcycle[31:0]);

        // Test 10: csrrw; minstret lower 32-bit
        csr_read_address = 12'hB02; #10;
        $display("minstret (before write) = %h (expected 00000000)", csr_read_out);

        csr_write_address = 12'hB02;
        csr_write_data = 32'hDEADBEEF;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #10;

        csr_read_address = 12'hB02; #10;
        $display("minstret (after write) = %h (expected DEADBEEF)", csr_read_out);
        
        // Test 11: csrrw; minstreth upper 32-bit
        csr_read_address = 12'hB82; #10;
        $display("minstreth (before write) = %h (expected 00000000)", csr_read_out);

        csr_write_address = 12'hB82;
        csr_write_data = 32'hCAFEBABE;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #10;

        csr_read_address = 12'hB82; #10;
        $display("minstreth (after write) = %h (expected CAFEBABE)", csr_read_out);
        
        csr_read_address = 12'hB02; #10;
        $display("minstret (should remain) = %h (expected DEADBEEF)", csr_read_out);
        
        $display("Full 64-bit minstret = %h_%h (expected CAFEBABE_DEADBEEF)", 
                 csr_file.minstret[63:32], csr_file.minstret[31:0]);

        // Test 12: Full 64-bit value integrity check
        csr_read_address = 12'hB00; #10;
        $display("Final mcycle[31:0] = %h", csr_read_out);
        
        csr_read_address = 12'hB80; #10;
        $display("Final mcycle[63:32] = %h", csr_read_out);
        $display("Final Full mcycle = 0x%h_%h", csr_file.mcycle[63:32], csr_file.mcycle[31:0]);
        
        csr_read_address = 12'hB02; #10;
        $display("Final minstret[31:0] = %h", csr_read_out);
        
        csr_read_address = 12'hB82; #10;
        $display("Final minstret[63:32] = %h", csr_read_out);
        $display("Final Full minstret = 0x%h_%h", csr_file.minstret[63:32], csr_file.minstret[31:0]);
        
        $display("\n====================  Register File Test END  ====================");
        $stop;
    end
    
endmodule
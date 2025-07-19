`timescale 1ns/1ps

module CSRFile_tb;
    reg         clk;
    reg         rst;
    reg         csr_write_enable;
    reg  [11:0] csr_address;
    reg  [31:0] csr_write_data;

    wire [31:0] csr_read_data;

    CSRFile csr_file (
        .clk(clk),
        .rst(rst),
        .csr_write_enable(csr_write_enable),
        .csr_address(csr_address),
        .csr_write_data(csr_write_data),

        .csr_read_data(csr_read_data)
    );

    // Generate clock signal, 10ns.
    always #5 clk = ~clk;

    initial begin
        $display("==================== CSR File Test START ====================");
        
        // Reset to DEFAULT value, Initialize signals.
        rst = 1;
        csr_write_enable = 0;
        csr_address = 12'h000;
        csr_write_data = 32'h0;
        #10;
        rst = 0;
        #10;
        
        // Test 1: Read-only CSRs read.
        csr_address = 12'hF11; #5; 
        $display("mvendorid = %h (expected 52564B43)", csr_read_data);
        
        csr_address = 12'hF12; #5; 
        $display("marchid = %h (expected 62616E61)", csr_read_data);
        
        csr_address = 12'hF13; #5;
        $display("mimpid = %h (expected 49355232)", csr_read_data);

        csr_address = 12'hF14; #5; 
        $display("mhartid = %h (expected 626E6130)", csr_read_data);

        csr_address = 12'h300; #5; 
        $display("mstatus = %h (expected 00001800)", csr_read_data);

        csr_address = 12'h301; #5; 
        $display("misa = %h (expected 40000100)", csr_read_data);
        
        // Test 2: MRW CSRs' reset value check
        csr_address = 12'h305; #5; 
        $display("mtvec (reset) = %h (expected 00001000)", csr_read_data);
        csr_address = 12'h341; #5; 
        $display("mepc  (reset) = %h (expected 00000000)", csr_read_data);
        csr_address = 12'h343; #5; 
        $display("mcause(reset) = %h (expected 00000000)", csr_read_data);

        // Test 3: csrrw; mtvec
        csr_address = 12'h305; #5; 
        $display("mtvec = %h (expected 00001000)", csr_read_data);

        csr_write_data = 32'h00003000;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #5;

        csr_address = 12'h305; #5; 
        $display("mtvec = %h (expected 00003000)", csr_read_data);
        
        // Test 4: csrrw; mepc
        csr_address = 12'h341; #5;
        $display("mepc = %h (expected 00000000)", csr_read_data);

        csr_write_data = 32'h00004000;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #5;

        csr_address = 12'h341; #5; 
        $display("mepc = %h (expected 00004000)", csr_read_data);
        
        // Test 5: csrrw; mcause
        csr_address = 12'h343; #5; 
        $display("mcause = %h (expected 00000000)", csr_read_data);

        csr_write_data = 32'h00000004;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #5;

        csr_address = 12'h343;
        #5;

        $display("mcause = %h (expected 00000004)", csr_read_data);
        
        // Test 6: csrrw; Read-only's write ignore test.
        csr_address = 12'hF11; #5; 
        $display("Read-only test : mvendorid = %h (expected 52564B43)", csr_read_data);

        csr_write_data = 32'h00003000;
        csr_write_enable = 1;
        #10;

        csr_write_enable = 0;
        #5;

        csr_address = 12'hF11;
        #5;

        $display("Write ignored : mvendorid = %h (expected 52564B43)", csr_read_data);
        
        $display("\n====================  Register File Test END  ====================");
        $stop;
    end
    
endmodule
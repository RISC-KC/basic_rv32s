`timescale 1ns/1ps

module RegisterFile_tb;
    reg clk;
	reg [4:0] read_reg1;
	reg [4:0] read_reg2;
	reg [4:0] write_reg;
	reg [31:0] write_data;
	reg write_enable;

	wire [31:0] read_data1;
	wire [31:0] read_data2;

    RegisterFile register_file (
        .clk(clk),
		.read_reg1(read_reg1),
		.read_reg2(read_reg2),
		.write_reg(write_reg),
		.write_data(write_data),
		.write_enable(write_enable),

		.read_data1(read_data1),
		.read_data2(read_data2)
    );

    // Generate clock signal (period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $display("==================== Register File Test START ====================");

        // Initialize signals
        clk = 0;
        read_reg1 = 5'b00000;
        read_reg2 = 5'b00000;
        write_reg = 5'b00000;
        write_data = 32'h00000000;
        write_enable = 0;

        // Test 1: Write and read
        $display("Write and read: ");
		
		write_reg = 5'b00001;
		write_data = 32'hDEADBEEF;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00001;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b: %h", read_reg1, read_data1);
		
		write_reg = 5'b00001;
		write_data = 32'hCAFEBEBE;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00001;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b: %h", read_reg1, read_data1);
		
		write_reg = 5'b00010;
		write_data = 32'hDEADBEEF;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00001;
		read_reg2 = 5'b00010;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b, %b: %h, %h", read_reg1, read_reg2, read_data1, read_data2);
		
		write_reg = 5'b00010;
		write_data = 32'hDEADCAFE;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00001;
		read_reg2 = 5'b00010;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b, %b: %h, %h", read_reg1, read_reg2, read_data1, read_data2);
		
		write_reg = 5'b00001;
		write_data = 32'hBEEFBEBE;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00001;
		read_reg2 = 5'b00010;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b, %b: %h, %h", read_reg1, read_reg2, read_data1, read_data2);
		
		// Test 2: Zero address
        $display("\nZero address: ");
		
		write_reg = 5'b00000;
		write_data = 32'hDEADCAFE;
		write_enable = 1;
		
		#10;
        
		read_reg1 = 5'b00000;
		read_reg2 = 5'b00010;
		write_enable = 0;
		
		#1;
		
		$display("Value at address %b, %b: %h, %h", read_reg1, read_reg2, read_data1, read_data2);
		
        $display("\n====================  Register File Test END  ====================");
        $stop;
    end

endmodule

`timescale 1ns/1ps

`include "modules/headers/load.vh"
`include "modules/headers/store.vh"

module ByteEnableLogic_tb;
	reg memory_read;
    reg memory_write;
    reg [2:0] funct3;
	reg [31:0] register_file_read_data;
	reg [31:0] data_memory_read_data;
	reg [1:0] address;
	
	reg [31:0] original_data;
	
	wire [31:0] register_file_write_data;
	wire [31:0] data_memory_write_data;
    wire [3:0] write_mask;

    ByteEnableLogic byte_enable_logic (
        .memory_read(memory_read),
		.memory_write(memory_write),
		.funct3(funct3),
		.register_file_read_data(register_file_read_data),
		.data_memory_read_data(data_memory_read_data),
		.address(address),

		.register_file_write_data(register_file_write_data),
		.data_memory_write_data(data_memory_write_data),
		.write_mask(write_mask)
    );

    initial begin
        // Test sequence
        $display("==================== Byte Enable Logic Test START ====================");

        memory_read = 0;
		memory_write = 0;
		funct3 = 3'b0;
		register_file_read_data = 32'b0;
		data_memory_read_data = 32'b0;
		address = 2'b0;
		
        // ========================================================================
        // Test 1: Load - Basic functionality (address = 2'b00)
        // ========================================================================
		$display("\n[Test 1] Load - Basic (address[1:0] = 2'b00):");
		
		data_memory_read_data = 32'hCAFEBEBE;
		address = 2'b00;
		
		#10;
		$display("  Full data: %h, Loaded data: %h (load disabled)", data_memory_read_data, register_file_write_data);
		
		memory_read = 1;
		
		funct3 = `LOAD_LB; #10;
        $display("  LOAD_LB  (funct3=%b): Full=%h, Loaded=%h (Expected: FFFFFFBE - sign-extended from byte[7:0])", 
                 funct3, data_memory_read_data, register_file_write_data);
		
		funct3 = `LOAD_LH; #10;
        $display("  LOAD_LH  (funct3=%b): Full=%h, Loaded=%h (Expected: FFFFBEBE - sign-extended from half[15:0])", 
                 funct3, data_memory_read_data, register_file_write_data);
		
		funct3 = `LOAD_LW; #10;
        $display("  LOAD_LW  (funct3=%b): Full=%h, Loaded=%h (Expected: CAFEBEBE - full word)", 
                 funct3, data_memory_read_data, register_file_write_data);
		
		funct3 = `LOAD_LBU; #10;
        $display("  LOAD_LBU (funct3=%b): Full=%h, Loaded=%h (Expected: 000000BE - zero-extended from byte[7:0])", 
                 funct3, data_memory_read_data, register_file_write_data);
		
		funct3 = `LOAD_LHU; #10;
        $display("  LOAD_LHU (funct3=%b): Full=%h, Loaded=%h (Expected: 0000BEBE - zero-extended from half[15:0])", 
                 funct3, data_memory_read_data, register_file_write_data);

        // ========================================================================
        // Test 2: Load Byte - Address alignment test (all 4 positions)
        // ========================================================================
		$display("\n[Test 2] Load Byte - Address Alignment (LB/LBU):");
		data_memory_read_data = 32'hDEADBEEF;  // Byte3=DE, Byte2=AD, Byte1=BE, Byte0=EF
		
		// LB tests
		funct3 = `LOAD_LB;
		
		address = 2'b00; #10;
		$display("  LB addr[1:0]=00: Data=%h, Loaded=%h (Expected: FFFFFFEF - byte[7:0]=EF, sign-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		address = 2'b01; #10;
		$display("  LB addr[1:0]=01: Data=%h, Loaded=%h (Expected: FFFFFFBE - byte[15:8]=BE, sign-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		address = 2'b10; #10;
		$display("  LB addr[1:0]=10: Data=%h, Loaded=%h (Expected: FFFFFFAD - byte[23:16]=AD, sign-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		address = 2'b11; #10;
		$display("  LB addr[1:0]=11: Data=%h, Loaded=%h (Expected: FFFFFFDE - byte[31:24]=DE, sign-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		// LBU tests
		funct3 = `LOAD_LBU;
		
		address = 2'b00; #10;
		$display("  LBU addr[1:0]=00: Data=%h, Loaded=%h (Expected: 000000EF - byte[7:0]=EF, zero-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		address = 2'b01; #10;
		$display("  LBU addr[1:0]=01: Data=%h, Loaded=%h (Expected: 000000BE - byte[15:8]=BE, zero-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		address = 2'b10; #10;
		$display("  LBU addr[1:0]=10: Data=%h, Loaded=%h (Expected: 000000AD - byte[23:16]=AD, zero-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		address = 2'b11; #10;
		$display("  LBU addr[1:0]=11: Data=%h, Loaded=%h (Expected: 000000DE - byte[31:24]=DE, zero-extended)", 
		         data_memory_read_data, register_file_write_data);

        // ========================================================================
        // Test 3: Load Halfword - Address alignment test (2 positions)
        // ========================================================================
		$display("\n[Test 3] Load Halfword - Address Alignment (LH/LHU):");
		data_memory_read_data = 32'h12345678;  // Upper half=1234, Lower half=5678
		
		// LH tests
		funct3 = `LOAD_LH;
		
		address = 2'b00; #10;  // addr[1]=0 -> select lower half
		$display("  LH addr[1:0]=00: Data=%h, Loaded=%h (Expected: 00005678 - half[15:0]=5678, sign-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		address = 2'b10; #10;  // addr[1]=1 -> select upper half
		$display("  LH addr[1:0]=10: Data=%h, Loaded=%h (Expected: 00001234 - half[31:16]=1234, sign-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		// LHU tests
		funct3 = `LOAD_LHU;
		
		address = 2'b00; #10;  // addr[1]=0 -> select lower half
		$display("  LHU addr[1:0]=00: Data=%h, Loaded=%h (Expected: 00005678 - half[15:0]=5678, zero-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		address = 2'b10; #10;  // addr[1]=1 -> select upper half
		$display("  LHU addr[1:0]=10: Data=%h, Loaded=%h (Expected: 00001234 - half[31:16]=1234, zero-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		// Test with negative values (sign extension test)
		$display("\n[Test 3-1] Load Halfword - Sign Extension Test:");
		data_memory_read_data = 32'h8000ABCD;  // Upper half=8000 (negative), Lower half=ABCD (negative)
		
		funct3 = `LOAD_LH;
		
		address = 2'b00; #10;  // addr[1]=0 -> select lower half (ABCD)
		$display("  LH addr[1:0]=00: Data=%h, Loaded=%h (Expected: FFFFABCD - half[15:0]=ABCD, sign-extended)", 
		         data_memory_read_data, register_file_write_data);
		
		address = 2'b10; #10;  // addr[1]=1 -> select upper half (8000)
		$display("  LH addr[1:0]=10: Data=%h, Loaded=%h (Expected: FFFF8000 - half[31:16]=8000, sign-extended)", 
		         data_memory_read_data, register_file_write_data);

        // ========================================================================
        // Test 4: Store - Byte alignment test
        // ========================================================================
		$display("\n[Test 4] Store Byte - Address Alignment:");
		
		memory_read = 0;
		memory_write = 1;
		register_file_read_data = 32'hDEADBEEF;
		
		funct3 = `STORE_SB;
		
		address = 2'b00; #10;
		$display("  SB addr[1:0]=00: Register=%h, Duplicated=%h, Mask=%b (Expected: EFEFEFEF, mask=0001)", 
		         register_file_read_data, data_memory_write_data, write_mask);
		
		address = 2'b01; #10;
		$display("  SB addr[1:0]=01: Register=%h, Duplicated=%h, Mask=%b (Expected: EFEFEFEF, mask=0010)", 
		         register_file_read_data, data_memory_write_data, write_mask);
		
		address = 2'b10; #10;
		$display("  SB addr[1:0]=10: Register=%h, Duplicated=%h, Mask=%b (Expected: EFEFEFEF, mask=0100)", 
		         register_file_read_data, data_memory_write_data, write_mask);
		
		address = 2'b11; #10;
		$display("  SB addr[1:0]=11: Register=%h, Duplicated=%h, Mask=%b (Expected: EFEFEFEF, mask=1000)", 
		         register_file_read_data, data_memory_write_data, write_mask);

        // ========================================================================
        // Test 5: Store - Halfword alignment test
        // ========================================================================
		$display("\n[Test 5] Store Halfword - Address Alignment:");
		
		funct3 = `STORE_SH;
		
		address = 2'b00; #10;
		$display("  SH addr[1:0]=00: Register=%h, Duplicated=%h, Mask=%b (Expected: BEEFBEEF, mask=0011)", 
		         register_file_read_data, data_memory_write_data, write_mask);
		
		address = 2'b01; #10;  // Misaligned - should result in mask=0000
		$display("  SH addr[1:0]=01: Register=%h, Duplicated=%h, Mask=%b (Expected: BEEFBEEF, mask=0000 - misaligned)", 
		         register_file_read_data, data_memory_write_data, write_mask);
		
		address = 2'b10; #10;
		$display("  SH addr[1:0]=10: Register=%h, Duplicated=%h, Mask=%b (Expected: BEEFBEEF, mask=1100)", 
		         register_file_read_data, data_memory_write_data, write_mask);
		
		address = 2'b11; #10;  // Misaligned - should result in mask=0000
		$display("  SH addr[1:0]=11: Register=%h, Duplicated=%h, Mask=%b (Expected: BEEFBEEF, mask=0000 - misaligned)", 
		         register_file_read_data, data_memory_write_data, write_mask);

        // ========================================================================
        // Test 6: Store - Word alignment test
        // ========================================================================
		$display("\n[Test 6] Store Word - Address Alignment:");
		
		funct3 = `STORE_SW;
		
		address = 2'b00; #10;
		$display("  SW addr[1:0]=00: Register=%h, Duplicated=%h, Mask=%b (Expected: DEADBEEF, mask=1111)", 
		         register_file_read_data, data_memory_write_data, write_mask);
		
		address = 2'b01; #10;  // Misaligned - should result in mask=0000
		$display("  SW addr[1:0]=01: Register=%h, Duplicated=%h, Mask=%b (Expected: DEADBEEF, mask=0000 - misaligned)", 
		         register_file_read_data, data_memory_write_data, write_mask);
		
		address = 2'b10; #10;  // Misaligned - should result in mask=0000
		$display("  SW addr[1:0]=10: Register=%h, Duplicated=%h, Mask=%b (Expected: DEADBEEF, mask=0000 - misaligned)", 
		         register_file_read_data, data_memory_write_data, write_mask);
		
		address = 2'b11; #10;  // Misaligned - should result in mask=0000
		$display("  SW addr[1:0]=11: Register=%h, Duplicated=%h, Mask=%b (Expected: DEADBEEF, mask=0000 - misaligned)", 
		         register_file_read_data, data_memory_write_data, write_mask);
		
		$display("\n====================  Byte Enable Logic Test END  ====================");
		
		$stop;
    end

endmodule
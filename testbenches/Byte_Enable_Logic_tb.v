`timescale 1ns/1ps

`include "modules/headers/load.vh"
`include "modules/headers/store.vh"

module ByteEnableLogic_tb;
	reg memory_read;
    reg memory_write;
    reg [2:0] funct3;
	reg [31:0] register_file_read_data;
	reg [31:0] data_memory_read_data;
	reg [31:0] address;
	
	reg [31:0] original_data;
	
	wire [31:0] register_file_write_data;
	wire [31:0] data_memory_write_data;
    wire [3:0] write_mask;
	wire misaligned;

    ByteEnableLogic byte_enable_logic (
        .memory_read(memory_read),
		.memory_write(memory_write),
		.funct3(funct3),
		.register_file_read_data(register_file_read_data),
		.data_memory_read_data(data_memory_read_data),
		.address(address),

		.register_file_write_data(register_file_write_data),
		.data_memory_write_data(data_memory_write_data),
		.write_mask(write_mask),
		.misaligned(misaligned)
    );

    initial begin
        // Test sequence
        $display("==================== Byte Enable Logic Test START ====================");

        memory_read = 0;
		memory_write = 0;
		funct3 = 3'b0;
		register_file_read_data = 32'b0;
		data_memory_read_data = 32'b0;
		address = 32'b0;
		
        // Test 1: Load
		$display("\nLoad: ");
		
		data_memory_read_data = 32'hCAFEBEBE;
		
		#10;
		$display("Full data to load: %h, Actual data loaded: %h (load disabled)", data_memory_read_data, register_file_write_data);
		
		memory_read = 1;
		
		funct3 = `LOAD_LB; #10;
        $display("Full data to load: %h, Actual data loaded: %h (funct3: %b)", data_memory_read_data, register_file_write_data, funct3);
		
		funct3 = `LOAD_LH; #10;
        $display("Full data to load: %h, Actual data loaded: %h (funct3: %b)", data_memory_read_data, register_file_write_data, funct3);
		
		funct3 = `LOAD_LW; #10;
        $display("Full data to load: %h, Actual data loaded: %h (funct3: %b)", data_memory_read_data, register_file_write_data, funct3);
		
		funct3 = `LOAD_LBU; #10;
        $display("Full data to load: %h, Actual data loaded: %h (funct3: %b)", data_memory_read_data, register_file_write_data, funct3);
		
		funct3 = `LOAD_LHU; #10;
        $display("Full data to load: %h, Actual data loaded: %h (funct3: %b)", data_memory_read_data, register_file_write_data, funct3);
		
		// Test 2: Store
		$display("\nStore: ");
		
		original_data = 32'hCCCCCCCC;
		
		memory_read = 0;
		funct3 = 3'b0;
		data_memory_read_data = 32'b0;
		address = 32'h000000F0;
		
		register_file_read_data = 32'hDEADBEEF;
		
		#10;
		$display("%h (register) -> %h (duplicated), store disabled, address: %h, write_mask: %b, misaligned: %b\n", register_file_read_data, data_memory_write_data, address, write_mask, misaligned);
		
		memory_write = 1;
		
		funct3 = `STORE_SB;
		
		address = 32'h000000F0; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F1; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F2; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F3; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F4; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b\n", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		funct3 = `STORE_SH;
		
		address = 32'h000000F0; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F1; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F2; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F3; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F4; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b\n", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		funct3 = `STORE_SW; 
		
		address = 32'h000000F0; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F1; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F2; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F3; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		address = 32'h000000F4; #10;
		$display("%h (register) -> %h (duplicated), funct3: %b, address: %h, write_mask: %b, misaligned: %b", register_file_read_data, data_memory_write_data, funct3, address, write_mask, misaligned);
		
		$display("\n====================  Byte Enable Logic Test END  ====================");
		
		$stop;
    end

endmodule

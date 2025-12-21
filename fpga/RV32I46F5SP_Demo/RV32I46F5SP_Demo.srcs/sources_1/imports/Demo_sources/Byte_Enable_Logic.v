`include "./load.vh"
`include "./store.vh"

module ByteEnableLogic (
    input memory_read,							// signal indicating that register file should read from data memory
    input memory_write,							// signal indicating that register file should write to data memory
    input [2:0] funct3,							// funct3
	input [31:0] register_file_read_data,		// data read from register file
	input [31:0] data_memory_read_data,			// data read from data memory
	input [1:0] address,						// address for checking alignment
	
	output reg [31:0] register_file_write_data,	// data to write at register file
	output reg [31:0] data_memory_write_data,	// data to write at data memory
    output reg [3:0] write_mask				// bitmask for writing data
);

    always @(*) begin
        if (memory_read) begin
			data_memory_write_data = 32'b0;
			write_mask = 4'b0;
			
			case (funct3)
				`LOAD_LB: begin
					register_file_write_data = {{24{data_memory_read_data[7]}}, data_memory_read_data[7:0]};
				end
				`LOAD_LH: begin
					register_file_write_data = {{16{data_memory_read_data[15]}}, data_memory_read_data[15:0]};
				end
				`LOAD_LW: begin
					register_file_write_data = data_memory_read_data;
				end
				`LOAD_LBU: begin
					register_file_write_data = {24'b0, data_memory_read_data[7:0]};
				end
				`LOAD_LHU: begin
					register_file_write_data = {16'b0, data_memory_read_data[15:0]};
				end
				default: begin
					register_file_write_data = 32'b0;
				end
			endcase
		end
		else if (memory_write) begin
			register_file_write_data = 32'b0;
						
			case (funct3)
				`STORE_SB: begin
					data_memory_write_data = {4{register_file_read_data[7:0]}};
					
					case (address[1:0])
						2'b00: begin
							write_mask = 4'b0001;
						end
						2'b01: begin
							write_mask = 4'b0010;
						end
						2'b10: begin
							write_mask = 4'b0100;
						end
						2'b11: begin
							write_mask = 4'b1000;
						end
					endcase
				end
				`STORE_SH: begin
					data_memory_write_data = {2{register_file_read_data[15:0]}};
					
					case (address[1:0])
						2'b00: begin
							write_mask = 4'b0011;
						end
						2'b10: begin
							write_mask = 4'b1100;
						end
						default: begin
							write_mask = 4'b0;
						end
					endcase
				end
				`STORE_SW: begin
					data_memory_write_data = register_file_read_data;
					
					if (address[1:0] == 2'b00) begin
						write_mask = 4'b1111;
					end
					else begin
						write_mask = 4'b0;
					end
				end
				default: begin
					data_memory_write_data = 32'b0;
					write_mask = 4'b0;
				end
			endcase
		end
		else begin
			register_file_write_data = 32'b0;
			data_memory_write_data = 32'b0;
			write_mask = 4'b0;
		end
    end

endmodule

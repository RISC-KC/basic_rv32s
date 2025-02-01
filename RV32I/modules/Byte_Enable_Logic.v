`include "modules/headers/load.vh"
`include "modules/headers/store.vh"

module ByteEnableLogic (
    input memory_read,							// signal indicating that register file should read from data memory
    input memory_write,							// signal indicating that register file should write to data memory
    input [2:0] funct3,							// funct3
	input [31:0] register_file_read_data,		// data read from register file
	input [31:0] data_memory_read_data,			// data read from data memory
	input [31:0] address,						// address to load or save data
	
	output [31:0] reg register_file_write_data,	// data to write at register file
	output [31:0] reg data_memory_write_data,	// data to write at data memory
    output [31:0] reg write_mask,				// bitmask for writing data
);

    always @(*) begin
        if (memory_read) begin
			data_memory_write_data = 32'b0;
			write_mask = 32'b0;
			
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
					write_mask = 32'h000000FF;
				end
				`STORE_SH: begin
					write_mask = 32'h0000FFFF;
				end
				`STORE_SW: begin
					write_mask = 32'hFFFFFFFF;
				end
				default: begin
				end
			endcase
		end
		else begin
			register_file_write_data = 32'b0;
			data_memory_write_data = 32'b0;
			write_mask = 32'b0;
		end
    end

endmodule

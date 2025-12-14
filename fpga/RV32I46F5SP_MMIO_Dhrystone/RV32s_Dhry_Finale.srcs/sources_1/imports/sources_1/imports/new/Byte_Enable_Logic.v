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
    output reg [3:0] write_mask					// bit-mask for writing data
);

    reg  [7:0]  byte_sel;
    reg [15:0] half_sel;

    always @(*) begin
        if (memory_read) begin
			data_memory_write_data = 32'b0;
			write_mask = 4'b0;
			
			case (funct3)
				`LOAD_LB , `LOAD_LBU : begin
					case (address[1:0])
						2'b00: byte_sel = data_memory_read_data[ 7: 0];
						2'b01: byte_sel = data_memory_read_data[15: 8];
						2'b10: byte_sel = data_memory_read_data[23:16];
						2'b11: byte_sel = data_memory_read_data[31:24];
					endcase

					if (funct3 == `LOAD_LBU) begin
						register_file_write_data = {24'b0, byte_sel};               // zero-extend
					end else begin
						register_file_write_data = {{24{byte_sel[7]}}, byte_sel};   // sign-extend
					end
				end

				`LOAD_LH , `LOAD_LHU : begin
					case (address[1])
						1'b0 : half_sel = data_memory_read_data[15:0];
						1'b1 : half_sel = data_memory_read_data[31:16];
					endcase

					if (funct3 == `LOAD_LHU) begin
						register_file_write_data = {16'b0, half_sel};                // zero-extend
					end else begin
						register_file_write_data = {{16{half_sel[15]}}, half_sel};   // sign-extend
					end
				end

				`LOAD_LW : begin
					register_file_write_data = data_memory_read_data;
				end

				default: begin
					register_file_write_data = 32'b0;
				end
			endcase
		end
		else if (memory_write) begin
			register_file_write_data = 32'b0;
						
			case (funct3)
				// ───────────── STORE ─────────────
				`STORE_SB: begin
					data_memory_write_data = {4{register_file_read_data[7:0]}};
					
					case (address[1:0])
						2'b00: write_mask = 4'b0001;
						2'b01: write_mask = 4'b0010;
						2'b10: write_mask = 4'b0100;
						2'b11: write_mask = 4'b1000;
					endcase
				end
				`STORE_SH: begin
					data_memory_write_data = {2{register_file_read_data[15:0]}};
					
					case (address[1:0])
						2'b00: write_mask = 4'b0011;
						2'b10: write_mask = 4'b1100;
						default: write_mask = 4'b0000;
					endcase
				end
				`STORE_SW: begin
					data_memory_write_data = register_file_read_data;
					
					if (address[1:0] == 2'b00)
						write_mask = 4'b1111;
					else
						write_mask = 4'b0000;
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

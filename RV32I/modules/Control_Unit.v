`include "modules/headers/opcode.vh"

module ControlUnit (
	input [6:0] opcode, // opcode from Instruction Decoder
	input [2:0] funct3, // funct3 from Instruction Decoder
    
	output reg jump,
	output reg branch,
	output [1:0] reg alu_src_A_select,
	output [1:0] reg alu_src_B_select,
	output reg [2:0] csr_op,
	output reg [1:0] csr_address_src_select,
	output reg [1:0] csr_data_src_select,
	output reg [2:0] register_file_write_data_select,
	output reg memory_read,
	output reg memory_write,
	output reg register_file_write
);

    always @(*) begin
        case (opcode)
            `OPCODE_LUI: begin
                // WIP
            end

            // WIP
			
        endcase
    end

endmodule

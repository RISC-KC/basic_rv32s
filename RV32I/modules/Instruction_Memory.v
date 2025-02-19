`include "modules/headers/opcode.vh"

module InstructionMemory (
    input [31:0] pc,
    output reg [31:0] instruction
);
    
	reg [31:0] data [0:2];
	
	initial begin
		data[0] = {12'd10, 5'b0, 3'b0, 5'b00001, `OPCODE_ITYPE}; // R[1] = R[0] + 10
		data[1] = {12'd20, 5'b0, 3'b0, 5'b00010, `OPCODE_ITYPE}; // R[2] = R[0] + 20
		data[2] = {7'b0, 5'b00010, 5'b00001, 3'b0, 5'b00011, `OPCODE_RTYPE}; // R[3] = R[1] + R[2]
	end
	
    always @(*) begin
		instruction = data[pc / 4];
    end

endmodule

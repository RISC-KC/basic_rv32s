`include "modules/headers/opcode.vh"

module InstructionMemory (
    input [31:0] pc,
    output reg [31:0] instruction
);
    
	reg [31:0] data [0:7];
	
	initial begin
		data[0] = {12'd1, 5'b0, 3'b0, 5'b00001, `OPCODE_ITYPE}; // R[1] = R[0] + 1
		data[1] = {12'd1, 5'b0, 3'b0, 5'b00010, `OPCODE_ITYPE}; // R[2] = R[0] + 1
		data[2] = {7'b0, 5'b00010, 5'b00001, 3'b0, 5'b00011, `OPCODE_RTYPE}; // R[3] = R[1] + R[2]
		data[3] = {7'b0, 5'b00011, 5'b00010, 3'b0, 5'b00100, `OPCODE_RTYPE}; // R[4] = R[2] + R[3]
		data[4] = {7'b0, 5'b00100, 5'b00011, 3'b0, 5'b00101, `OPCODE_RTYPE}; // R[5] = R[3] + R[4]
		data[5] = {7'b0, 5'b00101, 5'b00100, 3'b0, 5'b00110, `OPCODE_RTYPE}; // R[6] = R[4] + R[5]
		data[6] = {7'b0, 5'b00110, 5'b00101, 3'b0, 5'b00111, `OPCODE_RTYPE}; // R[7] = R[5] + R[6]
		data[7] = {7'b0, 5'b00111, 5'b00110, 3'b0, 5'b01000, `OPCODE_RTYPE}; // R[8] = R[6] + R[7]
	end
	
    always @(*) begin
		instruction = data[pc[31:2]];
    end

endmodule

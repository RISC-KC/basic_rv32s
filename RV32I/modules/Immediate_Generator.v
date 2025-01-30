`include "modules/headers/opcode.vh"

module ImmediateGenerator (
    input [31:0] imm, 			// immediate value from Instruction Decoder
	input [6:0] opcode,			// opcode from Instruction Decoder
    output reg [31:0] ex_imm	// sign-extension of the immediate value
);
	
	always @(*) begin
		case (opcode)
			`OPCODE_JALR, `OPCODE_LOAD, `OPCODE_ITYPE, `OPCODE_FENCE, `OPCODE_ENVIRONMENT: begin // I-type
				ex_imm = {{20{imm[11]}}, imm[11:0]};
			end
			`OPCODE_STORE: begin // S-Type
				ex_imm = {{20{imm[11]}}, imm[11:0]};
			end
			`OPCODE_LUI, `OPCODE_AUIPC: begin // U-Type
				ex_imm = imm;
			end
			`OPCODE_BRANCH: begin // B-Type
				ex_imm = {{20{imm[11]}}, imm[11:0]};
			end
			`OPCODE_JAL: begin // J-Type
				ex_imm = {{11{imm[20]}}, imm[20:0]};
			end
			default: begin
				ex_imm = 32'b0;
			end
        endcase
	end
	
endmodule

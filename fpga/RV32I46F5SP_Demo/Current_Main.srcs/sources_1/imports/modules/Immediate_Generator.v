`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Current_Main/Current_Main.srcs/sources_1/imports/modules/headers/opcode.vh"

module ImmediateGenerator (
    input [19:0] raw_imm, 	// raw immediate value from Instruction Decoder
	input [6:0] opcode,		// opcode from Instruction Decoder
    output reg [31:0] imm	// sign-extension of the raw immediate value
);
	
	always @(*) begin
		case (opcode)
			`OPCODE_JALR, `OPCODE_LOAD, `OPCODE_ITYPE, `OPCODE_FENCE, `OPCODE_ENVIRONMENT: begin // I-type
				imm = {{20{raw_imm[11]}}, raw_imm[11:0]};
			end
			`OPCODE_STORE: begin // S-Type
				imm = {{20{raw_imm[11]}}, raw_imm[11:0]};
			end
			`OPCODE_LUI, `OPCODE_AUIPC: begin // U-Type
				imm = {raw_imm, 12'b0};
			end
			`OPCODE_BRANCH: begin // B-Type
				imm = {{19{raw_imm[11]}}, raw_imm[11:0], 1'b0};
			end
			`OPCODE_JAL: begin // J-Type
				imm = {{11{raw_imm[19]}}, raw_imm[19:0], 1'b0};
			end
			default: begin
				imm = 32'b0;
			end
        endcase
	end
	
endmodule

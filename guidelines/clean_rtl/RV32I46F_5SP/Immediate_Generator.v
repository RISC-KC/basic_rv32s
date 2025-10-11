`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/opcode.vh"

module ImmediateGenerator (
    input [19:0] raw_imm,
	input [6:0] opcode,
    output reg [31:0] imm
);
	always @(*) begin
		case (opcode)
			`OPCODE_JALR, `OPCODE_LOAD, `OPCODE_ITYPE, `OPCODE_FENCE, `OPCODE_ENVIRONMENT: begin
				imm = {{20{raw_imm[11]}}, raw_imm[11:0]};
			end
			`OPCODE_STORE: begin
				imm = {{20{raw_imm[11]}}, raw_imm[11:0]};
			end
			`OPCODE_LUI, `OPCODE_AUIPC: begin
				imm = {raw_imm, 12'b0};
			end
			`OPCODE_BRANCH: begin
				imm = {{19{raw_imm[11]}}, raw_imm[11:0], 1'b0};
			end
			`OPCODE_JAL: begin
				imm = {{11{raw_imm[19]}}, raw_imm[19:0], 1'b0};
			end
			default: begin
				imm = 32'b0;
			end
        endcase
	end
endmodule

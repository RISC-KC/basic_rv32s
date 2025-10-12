`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/branch.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/itype.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/load.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/rtype.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/store.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/opcode.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/csr.vh"

module InstructionMemory (
    input [31:0] pc,
    output reg [31:0] instruction
);

	reg [31:0] data [0:2047];
	
	initial begin
		data[0] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd1, `OPCODE_ITYPE};
		data[1] = {12'd24,  5'd1, `ITYPE_SLLI, 5'd2, `OPCODE_ITYPE};
		data[2] = {12'd0,  5'd2, `ITYPE_SLTI, 5'd3, `OPCODE_ITYPE};
		data[3] = {12'd0,  5'd2, `ITYPE_SLTIU, 5'd4, `OPCODE_ITYPE};
		data[4] = {12'h653,  5'd1, `ITYPE_XORI, 5'd5, `OPCODE_ITYPE};
		data[5] = {7'b0000000, 5'd4, 5'd2, `ITYPE_SRXI, 5'd6, `OPCODE_ITYPE};
		data[6] = {7'b0100000, 5'd4, 5'd2, `ITYPE_SRXI, 5'd7, `OPCODE_ITYPE};
		data[7] = {12'h0BC, 5'd2, `ITYPE_ORI, 5'd8, `OPCODE_ITYPE};
		data[8] = {12'h0EC, 5'd5, `ITYPE_ANDI, 5'd9, `OPCODE_ITYPE};
		data[9]  = {7'b0000000, 5'd9, 5'd1, `RTYPE_ADDSUB, 5'd10, `OPCODE_RTYPE};
		data[10] = {7'b0100000, 5'd5, 5'd6, `RTYPE_ADDSUB, 5'd11, `OPCODE_RTYPE};
		data[11] = {7'b0000000, 5'd3, 5'd7, `RTYPE_SLL, 5'd12, `OPCODE_RTYPE};
		data[12] = {7'b0000000, 5'd2, 5'd1, `RTYPE_SLT, 5'd13, `OPCODE_RTYPE};
		data[13] = {7'b0000000, 5'd2, 5'd1, `RTYPE_SLTU, 5'd14, `OPCODE_RTYPE};
		data[14] = {7'b0000000, 5'd8, 5'd12, `RTYPE_XOR, 5'd15, `OPCODE_RTYPE};
		data[15] = {7'b0000000, 5'd3, 5'd12, `RTYPE_SR, 5'd16, `OPCODE_RTYPE};
		data[16] = {7'b0100000, 5'd3, 5'd12, `RTYPE_SR, 5'd17, `OPCODE_RTYPE};
		data[17] = {7'b0000000, 5'd7, 5'd11, `RTYPE_OR, 5'd18, `OPCODE_RTYPE};
		data[18] = {7'b0000000, 5'd11, 5'd7, `RTYPE_AND, 5'd19, `OPCODE_RTYPE};
		data[19] = {7'd0, 5'd11, 5'd1, `STORE_SW, 5'd4, `OPCODE_STORE};	
		data[20] = {7'd0, 5'd10, 5'd1, `STORE_SH, 5'd7, `OPCODE_STORE};
		data[21] = {7'd0, 5'd15, 5'd1, `STORE_SB, 5'd4, `OPCODE_STORE};
		data[22] = {12'd5, 5'd1, `LOAD_LW, 5'd20, `OPCODE_LOAD};	
		data[23] = {12'd4, 5'd1, `LOAD_LH, 5'd21, `OPCODE_LOAD};
		data[24] = {12'd4, 5'd1, `LOAD_LB, 5'd22, `OPCODE_LOAD};
		data[25] = {12'd4, 5'd1, `LOAD_LHU, 5'd23, `OPCODE_LOAD};
		data[26] = {12'd4, 5'd1, `LOAD_LBU, 5'd24, `OPCODE_LOAD};
		data[27] = {20'd1, 5'd25, `OPCODE_LUI};		
		data[28] = {20'd1, 5'd26, `OPCODE_AUIPC};
		data[29] = {20'b0_0000001111_0_00000000, 5'd27, `OPCODE_JAL};
		data[36] = {12'd0, 5'd27, 3'b000, 5'd28, `OPCODE_JALR};
		data[30] = {1'b0, 6'd0, 5'd2, 5'd1, `BRANCH_BEQ, 4'b0100, 1'b0, `OPCODE_BRANCH};	
		data[31] = {1'b0, 6'd0, 5'd13, 5'd0, `BRANCH_BNE, 4'b0100, 1'b0, `OPCODE_BRANCH};
		data[32] = {1'b0, 6'd0, 5'd2, 5'd1, `BRANCH_BLT, 4'b0100, 1'b0, `OPCODE_BRANCH};
		data[33] = {1'b0, 6'd0, 5'd1, 5'd2, `BRANCH_BGE, 4'b0100, 1'b0, `OPCODE_BRANCH};
		data[34] = {1'b0, 6'd0, 5'd1, 5'd2, `BRANCH_BLTU, 4'b0100, 1'b0, `OPCODE_BRANCH}; 
		data[35] = {1'b0, 6'd0, 5'd1, 5'd2, `BRANCH_BGEU, 4'b0100, 1'b0, `OPCODE_BRANCH};
		data[37] = {12'hF11, 5'd28, `CSR_CSRRW, 5'd20, `OPCODE_ENVIRONMENT};
		data[38] = {12'h341, 5'd1, `CSR_CSRRS, 5'd21, `OPCODE_ENVIRONMENT};
		data[39] = {12'h341, 5'd20, `CSR_CSRRC, 5'd21, `OPCODE_ENVIRONMENT}; 
		data[40] = {12'h342, 5'd3, `CSR_CSRRWI, 5'd22, `OPCODE_ENVIRONMENT};
		data[41] = {12'h305, 5'd7, `CSR_CSRRSI, 5'd22, `OPCODE_ENVIRONMENT};
		data[42] = {12'h305, 5'b11111, `CSR_CSRRCI, 5'd23, `OPCODE_ENVIRONMENT};
		data[43] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};
		data[44] = {12'd0, 5'd0, 3'd0, 5'd0, `OPCODE_ENVIRONMENT};
		data[45] = {12'd1, 5'd27, 3'b000, 5'd28, `OPCODE_JALR};
		data[46] = {7'b0, 5'd5, 5'd1, `STORE_SH, 5'd1, `OPCODE_STORE};
		data[47] = {20'd0, 5'd22, `OPCODE_LUI};
		data[48] = {12'hFBC, 5'd22, `ITYPE_ADDI, 5'd22, `OPCODE_ITYPE};
		data[49] = {20'hABADC, 5'd23, `OPCODE_LUI};
		data[50] = {12'hB02, 5'd23, `ITYPE_ADDI, 5'd23, `OPCODE_ITYPE};
		data[51] = {12'd1, 5'd0, 3'd0, 5'd0, `OPCODE_ENVIRONMENT};
		data[52] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};
		data[1024] = {12'h342, 5'd0, 3'b010, 5'd6, `OPCODE_ENVIRONMENT};
		data[1025] = {12'd11, 5'd0, `ITYPE_ADDI, 5'd7, `OPCODE_ITYPE};	
		data[1026] = {12'd2, 5'd0, `ITYPE_ADDI, 5'd8, `OPCODE_ITYPE};
		data[1027] = {1'b0, 6'd0, 5'd7, 5'd6, `BRANCH_BEQ, 4'b1000, 1'b0, `OPCODE_BRANCH};
		data[1028] = {1'b0, 6'd0, 5'd0, 5'd6, `BRANCH_BEQ, 4'b1010, 1'b0, `OPCODE_BRANCH};
		data[1029] = {1'b0, 6'd0, 5'd0, 5'd6, `BRANCH_BEQ, 4'b1000, 1'b0, `OPCODE_BRANCH};
		data[1030] = {1'b0, 10'b000_0001_000, 1'b0, 8'b0, 5'd0, `OPCODE_JAL};
		data[1031] = {12'd0, 5'd0, `ITYPE_ADDI, 5'd1, `OPCODE_ITYPE};
		data[1032] = {1'b0, 10'b000_0000_100, 1'b0, 8'b0, 5'd0, `OPCODE_JAL};
		data[1033] = {12'hFF, 5'd2, `ITYPE_ADDI, 5'd30, `OPCODE_ITYPE};
		data[1034] = {12'b001100000010, 5'b0, 3'b0, 5'b0, `OPCODE_ENVIRONMENT};
		data[1035] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};
	end
	
	always @(*) begin
		instruction = data[pc[31:2]];
	end
endmodule
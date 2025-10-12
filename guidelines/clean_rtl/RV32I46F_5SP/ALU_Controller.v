`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/alu_op.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/branch.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/csr.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/itype.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/opcode.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/rtype.vh"

module ALUController (
    input [6:0] opcode,
	input [2:0] funct3,
    input funct7_5,
    input imm_10,
	
    output reg [3:0] alu_op
);

    always @(*) begin
        case (opcode)
			`OPCODE_AUIPC: begin
				alu_op = `ALU_OP_ADD;
			end
			`OPCODE_JAL: begin
				alu_op = `ALU_OP_ADD;
			end
			`OPCODE_JALR: begin
				alu_op = `ALU_OP_ADD;
			end
			`OPCODE_BRANCH: begin
				case (funct3)
					`BRANCH_BEQ: begin
						alu_op = `ALU_OP_SUB;
					end
					`BRANCH_BNE: begin
						alu_op = `ALU_OP_SUB;
					end
					`BRANCH_BLT: begin
						alu_op = `ALU_OP_SLT;
					end
					`BRANCH_BGE: begin
						alu_op = `ALU_OP_SLT;
					end
					`BRANCH_BLTU: begin
						alu_op = `ALU_OP_SLTU;
					end
					`BRANCH_BGEU: begin
						alu_op = `ALU_OP_SLTU;
					end
					default: begin
					   alu_op = `ALU_OP_NOP;
					end
				endcase
			end
			`OPCODE_LOAD: begin
				alu_op = `ALU_OP_ADD;
			end
			`OPCODE_STORE: begin
				alu_op = `ALU_OP_ADD;
			end
			`OPCODE_ITYPE: begin
				case (funct3)
					`ITYPE_ADDI: begin
						alu_op = `ALU_OP_ADD;
					end
					`ITYPE_SLLI: begin
						alu_op = `ALU_OP_SLL;
					end
					`ITYPE_SLTI: begin
						alu_op = `ALU_OP_SLT;
					end
					`ITYPE_SLTIU: begin
						alu_op = `ALU_OP_SLTU;
					end
					`ITYPE_XORI: begin
						alu_op = `ALU_OP_XOR;
					end
					`ITYPE_SRXI: begin
						if (imm_10) begin
							alu_op = `ALU_OP_SRA;
						end else begin
							alu_op = `ALU_OP_SRL;
						end
					end
					`ITYPE_ORI: begin
						alu_op = `ALU_OP_OR; 
					end
					`ITYPE_ANDI: begin
						alu_op = `ALU_OP_AND;
					end
					default: begin
					   alu_op = `ALU_OP_NOP;
					end
				endcase
			end
			`OPCODE_RTYPE: begin
                case (funct3)
					`RTYPE_ADDSUB: begin
						if (funct7_5) begin
							alu_op = `ALU_OP_SUB;
						end else begin
							alu_op = `ALU_OP_ADD; 
						end
					end
					`RTYPE_SLL: begin 
						alu_op = `ALU_OP_SLL;
					end
					`RTYPE_SLT: begin 
						alu_op = `ALU_OP_SLT;
					end
					`RTYPE_SLTU: begin
						alu_op = `ALU_OP_SLTU;
					end
					`RTYPE_XOR: begin
						alu_op = `ALU_OP_XOR;
					end
					`RTYPE_SR: begin
						if (funct7_5) begin
							alu_op = `ALU_OP_SRA;
						end else begin
							alu_op = `ALU_OP_SRL;
						end
					end
					`RTYPE_OR: begin
						alu_op = `ALU_OP_OR;
					end
					`RTYPE_AND: begin
						alu_op = `ALU_OP_AND;
					end
					default: begin
					   alu_op = `ALU_OP_NOP;
                    end
				endcase
            end
			`OPCODE_ENVIRONMENT: begin
				case (funct3)
					`CSR_CSRRW: begin
						alu_op = `ALU_OP_BPA;
					end
					`CSR_CSRRS: begin
						alu_op = `ALU_OP_OR;
					end
					`CSR_CSRRC: begin
						alu_op = `ALU_OP_ABJ;
					end
					`CSR_CSRRWI: begin
						alu_op = `ALU_OP_BPA;
					end
					`CSR_CSRRSI: begin
						alu_op = `ALU_OP_OR;
					end
					`CSR_CSRRCI: begin
						alu_op = `ALU_OP_ABJ;
					end
					default: begin
						alu_op = `ALU_OP_NOP;
					end
				endcase
			end
			default: begin
				alu_op = `ALU_OP_NOP;
			end
        endcase
    end
endmodule
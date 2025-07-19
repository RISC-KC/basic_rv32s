`include "modules/headers/alu_op.vh"
`include "modules/headers/branch.vh"
`include "modules/headers/csr.vh"
`include "modules/headers/itype.vh"
`include "modules/headers/opcode.vh"
`include "modules/headers/rtype.vh"

module ALUController (
    input [6:0] opcode,        		// opcode
	input [2:0] funct3,				// funct3
    input funct7_5,					// 5th index of funct7 (starting from 0th index)
    input imm_10,					// 10th index of imm (starting from 0th index)
	
    output reg [3:0] alu_op		// ALU operation signal
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
				alu_op = `ALU_OP_ADD; // JALR instruction requires addition
			end
			`OPCODE_BRANCH: begin
				case (funct3)
					`BRANCH_BEQ: begin
						alu_op = `ALU_OP_SUB; // If subtraction result is zero, equal
					end
					`BRANCH_BNE: begin
						alu_op = `ALU_OP_SUB; // If subtraction result is not zero, not equal
					end
					`BRANCH_BLT: begin
						alu_op = `ALU_OP_SLT; // If SLT result is not zero, less
					end
					`BRANCH_BGE: begin
						alu_op = `ALU_OP_SLT; // If SLT result is zero, greater or equal
					end
					`BRANCH_BLTU: begin
						alu_op = `ALU_OP_SLTU; // If SLTU result is not zero, less (unsigned)
					end
					`BRANCH_BGEU: begin
						alu_op = `ALU_OP_SLTU; // If SLTU result is zero, greater or equal (unsigned)
					end
					default: begin
					   alu_op = `ALU_OP_NOP;
					end
				endcase
			end
			`OPCODE_LOAD: begin
				alu_op = `ALU_OP_ADD; // Every load instruction requires addition
			end
			`OPCODE_STORE: begin
				alu_op = `ALU_OP_ADD; // Every store instruction requires addition
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
					`ITYPE_SRXI: begin // srli or srai
						if (imm_10) begin
							alu_op = `ALU_OP_SRA; // srai : imm[10] = 1
						end
						else begin
							alu_op = `ALU_OP_SRL; // srli : imm[10] = 0
						end
					end
					`ITYPE_ORI: begin
						alu_op = `ALU_OP_OR; // ori : 110 ; - 
					end
					`ITYPE_ANDI: begin
						alu_op = `ALU_OP_AND; // andi : 111 ; -
					end
					default: begin
					   alu_op = `ALU_OP_NOP;
					end
				endcase
			end
			`OPCODE_RTYPE: begin
                case (funct3)
					`RTYPE_ADDSUB: begin // add or sub
						if (funct7_5) begin
							alu_op = `ALU_OP_SUB; // sub : funct7 = 0100000
						end
						else begin
							alu_op = `ALU_OP_ADD; // add : funct7 = 0000000 
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
					`RTYPE_SR: begin // srl or sra
						if (funct7_5) begin
							alu_op = `ALU_OP_SRA; // sra : funct7 = 0100000
						end
						else begin
							alu_op = `ALU_OP_SRL; // srl : funct7 = 0000000
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
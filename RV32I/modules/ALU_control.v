module ALUControl (
    input [6:0] opcode,        		// opcode
	input [2:0] funct3,				// funct3
    input funct7_5,					// 5th index of funct7 (starting from 0th index)
    input imm_10,					// 10th index of imm (starting from 0th index)
	
    output reg [3:0] alu_op		// ALU operation signal
);

    always @(*) begin
        case (opcode)
			7'b0110011: begin // R-type
                case (funct3)
					3'b000: begin // add or sub
						alu_op = {3'b000, funct7_5};
						// add : 000 ; 0000000 
						// sub : 000 ; 0100000
					end
					3'b001: begin // sll
						alu_op = 4'b0111; // sll : 001 ; 0000000 
					end
					3'b010: begin // slt
						alu_op = 4'b0101; // slt : 010 ; 0000000
					end
					3'b011: begin // sltu
						alu_op = 4'b0110; // sltu : 011 ; 0000000
					end
					3'b100: begin // xor
						alu_op = 4'b0100; // xor : 100 ; 0000000 
					end
					3'b101: begin // srl or sra
						alu_op = {3'b100, funct7_5};
						// srl : 101 ; 0000000
						// sra : 101 ; 0100000 
					end
					3'b110: begin // or
						alu_op = 4'b0011; // or : 110 ; 0000000
					end
					3'b111: begin // and
						alu_op = 4'b0010; // and : 111 ; 0000000
					end
				endcase
            end
			7'b0010011: begin // I-type
				case (funct3)
					3'b000: begin
						alu_op = 4'b0000; // addi : 000 ; - 
					end
					3'b001: begin
						alu_op = 4'b0111; // slli : 001 ; imm[5:11]=0000000 
					end
					3'b010: begin
						alu_op = 4'b0101; // slti : 010 ; - 
					end
					3'b011: begin
						alu_op = 4'b0110; // sltiu : 011 ; -
					end
					3'b100: begin
						alu_op = 4'b0100; // xori : 100 ; - 
					end
					3'b101: begin
						alu_op = {3'b100, imm_10};
						// srli : 101 ; imm[5:11]=0000000 
						// srai : 101 ; imm[5:11]=0100000 
					end
					3'b110: begin
						alu_op = 4'b0011; // ori : 110 ; - 
					end
					3'b111: begin
						alu_op = 4'b0010; // andi : 111 ; -
					end
				endcase
			end
			7'b0000011: begin // I-Type load
				alu_op = 4'b0000;
				// lb : 000 ; - 
				// lh : 001 ; - 
				// lw : 010 ; - 
				// lbu : 100 ; - 
				// lhu : 101 ; -
				// Every 5 of them requires addition
			end
			7'b1100111: begin // I-Type jump
				alu_op = 4'b0000; // jalr : 000 ; -
			end
			7'b1100011: begin // B-Type
				alu_op = 4'b0000;
				// beq : 000 ; - 
				// bne : 001 ; - 
				// blt : 100 ; - 
				// bge : 101 ; - 
				// bltu : 110 ; - 
				// bgeu : 111 ; -
				// Every 6 of them requires addition
			end
			7'b1110011: begin // I-Type CSR
				case (funct3)
					3'b001: begin // csrrw : 001 ; -
						alu_op = 4'b1111;
					end
					3'b010: begin // csrrs : 010 ; -
						alu_op = 4'b0011;
					end
					3'b011: begin // csrrc : 011 ; -
						alu_op = 4'b1010;
					end
					3'b101: begin // csrrwi : 101 ; -
						alu_op = 4'b1111;
					end
					3'b110: begin // csrrsi : 110 ; -
						alu_op = 4'b0011;
					end
					3'b111: begin // csrrci : 111 ; -
						alu_op = 4'b1010;
					end
					default: begin
						alu_op = 4'b1111;
					end
				endcase
			end
			default: begin
				alu_op = 4'b1111;
			end
        endcase
    end

endmodule

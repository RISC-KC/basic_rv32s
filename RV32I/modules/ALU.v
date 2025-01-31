module ALU (
    input [31:0] src_A,             // Source operand A
    input [31:0] src_B,             // Source operand B
    input [3:0] alu_op,        		// ALU operation signal (from ALU Control module)
    
    output reg [31:0] alu_result,   // ALU result
    output reg alu_zero             // Zero flag
);

    always @(*) begin
        case (alu_op)
            4'b0000: begin // ADD
                alu_result = src_A + src_B;
            end

            4'b0001: begin // SUB
                alu_result = src_A - src_B;
            end
            
            4'b0010: begin // AND
                alu_result = src_A & src_B;
            end
            
            4'b0011: begin // OR
                alu_result = src_A | src_B;
            end
            
            4'b0100: begin // XOR
                alu_result = src_A ^ src_B;
            end
            
            4'b0101: begin // SLT (Set Less Than)
                alu_result = ($signed(src_A) < $signed(src_B)) ? 32'd1 : 32'd0;
            end

            4'b0110: begin // SLTU (Set Less Than Unsigned)
                alu_result = (src_A < src_B) ? 32'd1 : 32'd0;
            end
			
			4'b0111: begin // SLL (Shift Left Logic)
				alu_result = src_A << src_B;
			end
			
			4'b1000: begin // SRL (Shift Right Logic)
				alu_result = src_A >> src_B;
			end
			
			4'b1001: begin // SRA (Shift Right Arithmetic)
				alu_result = $signed(src_A) >>> src_B;
			end
			
			4'b1010: begin // ABJ (Abjunction, or Material nonimplication)
				alu_result = src_A & (~src_B);
			end

			4'b1111: begin // NOP (Do nothing)
				alu_result = 32'd0;
			end

            default: begin
                alu_result = 32'd0; // Default case: zero result
            end
        endcase

        alu_zero = (alu_result == 32'd0); // Zero flag: set if result is zero
    end

endmodule

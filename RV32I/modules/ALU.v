module ALU (
    input [31:0] src_A,             // Source operand A
    input [31:0] src_B,             // Source operand B
    input [3:0] alu_control,        // ALU control signal (from Control Unit)
    
    output reg [31:0] alu_result,   // ALU result
    output reg zero                 // Zero flag
);

    always @(*) begin
        case (alu_control)
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

            default: begin
                alu_result = 32'd0; // Default case: zero result
            end
        endcase

        zero = (alu_result == 32'd0); // Zero flag: set if result is zero
    end

endmodule

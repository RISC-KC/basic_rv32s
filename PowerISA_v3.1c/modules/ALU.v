module ALU (
    input [31:0] srcA,           // Source operand A
    input [31:0] srcB,           // Source operand B
    input [3:0] aluOp,      // ALU control signal (from Control Unit)
    input signedOperation,       // Flag to indicate whether to use signed operations or unsigned
    output reg [31:0] aluResult, // ALU result
    output reg zero              // Zero flag
);

    always @(*) begin
        case (aluOp)
            4'b0000: begin // ADD
                if (signedOperation)
                    aluResult = $signed(srcA) + $signed(srcB);  // Signed ADD
                else
                    aluResult = srcA + srcB;  // Unsigned ADD
            end
            4'b0001: begin // SUB
                if (signedOperation)
                    aluResult = $signed(srcA) - $signed(srcB);  // Signed SUB
                else
                    aluResult = srcA - srcB;  // Unsigned SUB
            end
            4'b0010: begin // MUL
                aluResult = srcA * srcB;  // MUL (always treated as signed or unsigned depending on inputs)
            end
            4'b0011: begin // DIV
                if (signedOperation)
                    aluResult = $signed(srcA) / $signed(srcB);  // Signed DIV
                else
                    aluResult = srcA / srcB;  // Unsigned DIV
            end
            4'b0100: begin // AND
                aluResult = srcA & srcB;  // AND
            end
            4'b0101: begin // OR
                aluResult = srcA | srcB;  // OR
            end
            4'b0110: begin // XOR
                aluResult = srcA ^ srcB;  // XOR
            end
            4'b0111: begin // SLT (Set Less Than)
                if (signedOperation)
                    aluResult = ($signed(srcA) < $signed(srcB)) ? 32'd1 : 32'd0; // Signed SLT
                else
                    aluResult = (srcA < srcB) ? 32'd1 : 32'd0; // Unsigned SLT
            end
            default: begin
                aluResult = 0; // Default case: zero result
            end
        endcase

        zero = (aluResult == 0); // Zero flag: set if result is zero
    end

endmodule

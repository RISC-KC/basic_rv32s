module ControlUnit (
    input [5:0] opcode,          // Opcode from instruction
    output reg regDst,           // Register destination select
    output reg aluSrc,           // ALU source select
    output reg memToReg,         // Memory to register select
    output reg regWrite,         // Register write enable
    output reg memRead,          // Memory read enable
    output reg memWrite,         // Memory write enable
    output reg branch,           // Branch control
    output reg [3:0] aluOp,      // ALU operation select
    output reg signedOperation   // Signed or unsigned operation flag
);

    always @(*) begin
        case (opcode)
            // R-type instructions
            6'b011111: begin // ADD (R-type, signed by default)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0000; signedOperation = 1;
            end
            6'b011110: begin // SUB (R-type, signed by default)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0001; signedOperation = 1;
            end
            6'b011101: begin // MUL (R-type, signed by default)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0010; signedOperation = 1;
            end
            6'b011100: begin // DIV (R-type, signed by default)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0011; signedOperation = 1;
            end
            6'b010000: begin // AND (R-type)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0100; signedOperation = 0;
            end
            6'b010001: begin // OR (R-type)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0101; signedOperation = 0;
            end
            6'b010010: begin // XOR (R-type)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0110; signedOperation = 0;
            end
            6'b010011: begin // SLT (R-type, signed)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0111; signedOperation = 1;
            end

            // I-type instructions
            6'b100001: begin // LOAD (I-type)
                regDst = 0; aluSrc = 1; memToReg = 1; regWrite = 1;
                memRead = 1; memWrite = 0; branch = 0; aluOp = 4'b0000; signedOperation = 0; // Unsigned addition for address calculation
            end
            6'b101010: begin // STORE (I-type)
                regDst = 0; aluSrc = 1; memToReg = 0; regWrite = 0;
                memRead = 0; memWrite = 1; branch = 0; aluOp = 4'b0000; signedOperation = 0; // Unsigned addition for address calculation
            end

            // Default case: No operation
            default: begin
                regDst = 0; aluSrc = 0; memToReg = 0; regWrite = 0;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0000; signedOperation = 0;
            end
        endcase
    end

endmodule

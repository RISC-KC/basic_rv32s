module ControlUnit (
    input [5:0] opcode,     // Opcode from instruction
    output reg regDst,      // Register destination select
    output reg aluSrc,      // ALU source select
    output reg memToReg,    // Memory to register select
    output reg regWrite,    // Register write enable
    output reg memRead,     // Memory read enable
    output reg memWrite,    // Memory write enable
    output reg branch,      // Branch control
    output reg [3:0] aluOp  // ALU operation select
);

    always @(*) begin
        case (opcode)
            6'b011111: begin // ADD (R-type)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0000;
            end
            6'b011110: begin // SUB (R-type)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0001;
            end
            6'b011101: begin // MUL (R-type, hypothetical opcode for MUL)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0010;  // Assuming aluOp for MUL
            end
            6'b011100: begin // DIV (R-type, hypothetical opcode for DIV)
                regDst = 1; aluSrc = 0; memToReg = 0; regWrite = 1;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0011;  // Assuming aluOp for DIV
            end
            6'b100001: begin // LOAD (I-type)
                regDst = 0; aluSrc = 1; memToReg = 1; regWrite = 1;
                memRead = 1; memWrite = 0; branch = 0; aluOp = 4'b0000;
            end
            6'b101010: begin // STORE (I-type)
                regDst = 0; aluSrc = 1; memToReg = 0; regWrite = 0;
                memRead = 0; memWrite = 1; branch = 0; aluOp = 4'b0000;
            end
            default: begin // Default case: No operation
                regDst = 0; aluSrc = 0; memToReg = 0; regWrite = 0;
                memRead = 0; memWrite = 0; branch = 0; aluOp = 4'b0000;
            end
        endcase
    end

endmodule

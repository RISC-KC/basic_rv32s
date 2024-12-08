module InstructionDecoder (
    input [31:0] instruction,  // Input instruction
    output [5:0] opcode,       // Opcode field
    output [4:0] rs,           // Source register 1
    output [4:0] rt,           // Source register 2
    output [4:0] rd,           // Destination register
    output [15:0] immediate    // Immediate field
);

    assign opcode = instruction[31:26];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign immediate = instruction[15:0];

endmodule

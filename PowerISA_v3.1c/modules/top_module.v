module SingleCycled_PowerCPU (
    input clk,                  // Clock signal
    input reset,                // Reset signal
    input [31:0] instruction,   // Instruction input
    output [31:0] aluResult,    // ALU result output
    output [31:0] memData       // Data memory output (optional for memory operations)
);

    // Internal signals for control and data path
    wire regDst, aluSrc, memToReg, regWrite, memRead, memWrite, branch;
    wire [3:0] aluOp;
    wire signedOperation;  // Flag to indicate signed or unsigned operations
    wire [31:0] srcA, srcB; // ALU operands
    wire [31:0] writeData;  // Data to write into register file or memory
    wire zero;              // Zero flag for ALU

    // Control Unit (CU)
    ControlUnit cu (
        .opcode(instruction[31:26]),   // Opcode from instruction
        .regDst(regDst),
        .aluSrc(aluSrc),
        .memToReg(memToReg),
        .regWrite(regWrite),
        .memRead(memRead),
        .memWrite(memWrite),
        .branch(branch),
        .aluOp(aluOp),
        .signedOperation(signedOperation)  // Send signedOperation flag to ALU
    );

    // Register File
    RegisterFile rf (
        .clk(clk),
        .readReg1(instruction[25:21]),  // Register 1 address
        .readReg2(instruction[20:16]),  // Register 2 address
        .writeReg(instruction[15:11]),  // Register to write data
        .writeData(writeData),
        .regWrite(regWrite),
        .readData1(srcA),  // Operand A
        .readData2(srcB)   // Operand B
    );

    // ALU (Arithmetic Logic Unit)
    ALU alu (
        .srcA(srcA),
        .srcB(srcB),
        .aluControl(aluOp),
        .signedOperation(signedOperation),
        .aluResult(aluResult),
        .zero(zero)
    );

    // Data Memory (optional for load/store operations)
    DataMemory dataMem (
        .clk(clk),
        .memWrite(memWrite),
        .memRead(memRead),
        .address(aluResult),
        .writeData(srcB),
        .readData(memData)
    );

    // Write-back logic (decides whether to write data to register or from memory)
    assign writeData = memToReg ? memData : aluResult;

    // Control signals from instruction
    // Handle instruction fetch and decode logic (if needed, based on your instruction format)
    // Additional logic for handling branch, jump, etc.

endmodule

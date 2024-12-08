module InstructionMemory (
    input [31:0] address,       // Address to read instruction from
    output reg [31:0] instruction // Instruction to be fetched
);

    // Memory array (32-bit wide, 256 entries)
    reg [31:0] memory [0:255];

    always @(*) begin
        instruction = memory[address[31:2]]; // Word-aligned access
    end

    // Initialize the instruction memory with some sample instructions
    initial begin
        // Initialize all memory to a known value (e.g., NOP or zero)
        integer i;
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'b0;  // Initializing all memory locations to 0 (NOP instruction)
        end
        
        // Now, you can set some test instructions in the memory
        memory[0] = 32'h00000000;  // NOP
        memory[1] = 32'h01000000;  // Example instruction (ADD or other)
        memory[2] = 32'h02000000;  // Another example instruction
        // Add more instructions as needed for testing
    end
endmodule

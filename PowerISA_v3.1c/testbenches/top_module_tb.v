module TopModule_tb;

    reg clk;
    reg reset;
    reg [31:0] instruction;
    wire [31:0] aluResult;
    wire [31:0] memData;

    // Instantiate the CPU Top Module
    SingleCycled_PowerCPU cpu (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .aluResult(aluResult),
        .memData(memData)
    );

    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        instruction = 32'b0;

        // Reset the CPU
        reset = 1;
        #5 reset = 0;
        
        // Test 1: ADD instruction
        instruction = 32'b011111_00000_00001_00010_000000_000000; // Example ADD instruction
        #10;
        $display("ALU Result for ADD: %d", aluResult);

        // Test 2: SUB instruction
        instruction = 32'b011110_00000_00001_00010_000000_000000; // Example SUB instruction
        #10;
        $display("ALU Result for SUB: %d", aluResult);

        // Test 3: Load instruction (memRead)
        instruction = 32'b100001_00000_00001_00010_000000_000000; // Example LOAD instruction
        #10;
        $display("ALU Result for LOAD: %d, MemData: %d", aluResult, memData);

        // Test 4: Store instruction (memWrite)
        instruction = 32'b101010_00000_00001_00010_000000_000000; // Example STORE instruction
        #10;
        $display("ALU Result for STORE: %d, MemData: %d", aluResult, memData);

        // Add more tests as needed
        $stop;
    end

    // Generate clock
    always #5 clk = ~clk;

endmodule

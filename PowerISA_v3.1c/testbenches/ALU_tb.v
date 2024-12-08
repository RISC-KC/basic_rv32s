module ALU_tb;

    reg [31:0] srcA, srcB;
    reg [3:0] aluControl;
    reg signedOperation;  // Flag to select signed or unsigned operation
    wire [31:0] aluResult;
    wire zero;

    // DUT: Device Under Test
    ALU dut (
        .srcA(srcA),
        .srcB(srcB),
        .aluControl(aluControl),
        .signedOperation(signedOperation),
        .aluResult(aluResult),
        .zero(zero)
    );

    initial begin
        // Test sequence
        $display("Starting ALU Test...");

        // Test 1: Addition (Signed and Unsigned)
        srcA = 32'd10;
        srcB = 32'd20;
        aluControl = 4'b0000; // ADD
        signedOperation = 1; // Signed
        #10;
        $display("Signed ADD Result: %d, Zero: %b", aluResult, zero);
        
        signedOperation = 0; // Unsigned
        #10;
        $display("Unsigned ADD Result: %d, Zero: %b", aluResult, zero);

        // Test 2: Subtraction (Signed and Unsigned)
        aluControl = 4'b0001; // SUB
        signedOperation = 1; // Signed
        #10;
        $display("Signed SUB Result: %d, Zero: %b", aluResult, zero);
        
        signedOperation = 0; // Unsigned
        #10;
        $display("Unsigned SUB Result: %d, Zero: %b", aluResult, zero);

        // Test 3: AND
        srcA = 32'hFFFF_0000;
        srcB = 32'h0F0F_0F0F;
        aluControl = 4'b0100; // AND
        signedOperation = 1; // Signed
        #10;
        $display("AND Result (Signed): %h, Zero: %b", aluResult, zero);

        // Test 4: OR
        srcA = 32'h0000_FFFF;
        srcB = 32'h0F0F_0F0F;
        aluControl = 4'b0101; // OR
        signedOperation = 0; // Unsigned
        #10;
        $display("OR Result (Unsigned): %h, Zero: %b", aluResult, zero);

        // Test 5: XOR
        srcA = 32'hFFFFFFFF;
        srcB = 32'h00000000;
        aluControl = 4'b0110; // XOR
        signedOperation = 1; // Signed
        #10;
        $display("XOR Result (Signed): %h, Zero: %b", aluResult, zero);

        // Test 6: SLT (Signed and Unsigned)
        srcA = 32'd5;
        srcB = 32'd10;
        aluControl = 4'b0111; // SLT
        signedOperation = 1; // Signed
        #10;
        $display("Signed SLT Result: %d, Zero: %b", aluResult, zero);
        
        signedOperation = 0; // Unsigned
        #10;
        $display("Unsigned SLT Result: %d, Zero: %b", aluResult, zero);

        // Test 7: MUL
        srcA = 32'd6;
        srcB = 32'd7;
        aluControl = 4'b0010; // MUL
        signedOperation = 1; // Signed
        #10;
        $display("MUL Result: %d, Zero: %b", aluResult, zero);

        // Test 8: DIV
        srcA = 32'd10;
        srcB = 32'd2;
        aluControl = 4'b0011; // DIV
        signedOperation = 0; // Unsigned
        #10;
        $display("DIV Result: %d, Zero: %b", aluResult, zero);

        $stop;
    end

endmodule

module ALU_tb;

    reg [31:0] src_A, src_B;
    reg [3:0] alu_control;

    wire [31:0] alu_result;
    wire zero;

    ALU alu (
        .src_A(src_A),
        .src_B(src_B),
        .alu_control(alu_control),

        .alu_result(alu_result),
        .zero(zero)
    );

    initial begin
        // Test sequence
        $display("Starting ALU Test...");

        // Test 1: Addition
        src_A = 32'd10;
        src_B = 32'd20;
        alu_control = 4'b0000; // ADD

        #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 2: Subtraction
        src_A = 32'd20;
        src_B = 32'd10;
        alu_control = 4'b0001; // SUB
        
        #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 3: AND
        src_A = 32'hFFFF_0000;
        src_B = 32'h0F0F_0F0F;
        alu_control = 4'b0010; // AND

        #10;
        $display("%h & %h = %h, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 4: OR
        src_A = 32'h0000_FFFF;
        src_B = 32'h0F0F_0F0F;
        alu_control = 4'b0011; // OR

        #10;
        $display("%h | %h = %h, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 5: XOR
        src_A = 32'hFFFFFFFF;
        src_B = 32'h00000000;
        alu_control = 4'b0100; // XOR
        
        #10;
        $display("%h ^ %h = %h, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 6: SLT
        src_A = 32'h00000000;
        src_B = 32'hF0000001;
        alu_control = 4'b0101; // SLT
        
        #10;
		$display("Is %d < %d ? : %d, Zero: %b (signed)", $signed(src_A), $signed(src_B), alu_result, zero);

        // Test 7: SLTU
        src_A = 32'hF0000000;
        src_B = 32'hF0000001;
        alu_control = 4'b0110; // SLTU
        
        #10;
		$display("Is %d < %d ? : %d, Zero: %b (unsigned)", src_A, src_B, alu_result, zero);

        $stop;
    end

endmodule

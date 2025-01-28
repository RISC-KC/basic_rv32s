module ALU_tb;

    reg [31:0] src_A;
	reg [31:0] src_B;
    reg [3:0] alu_op;

    wire [31:0] alu_result;
    wire zero;

    ALU alu (
        .src_A(src_A),
        .src_B(src_B),
        .alu_op(alu_op),

        .alu_result(alu_result),
        .zero(zero)
    );

    initial begin
        // Test sequence
        $display("==================== ALU Test START ====================");

        // Test 1: Addition
		$display("\nAddition Test: ");
		
        src_A = 32'd0;
        src_B = 32'd0;
        alu_op = 4'b0000; // ADD

        #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'd1000;
        src_B = 32'd2000;
        alu_op = 4'b0000; // ADD

        #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'd1972;
        src_B = 32'd1121;
        alu_op = 4'b0000; // ADD

        #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 2: Subtraction
		$display("\nSubtraction Test: ");
		
        src_A = 32'd30;
        src_B = 32'd30;
        alu_op = 4'b0001; // SUB
        
        #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'd10;
        src_B = 32'd20;
        alu_op = 4'b0001; // SUB
        
        #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, $signed(alu_result), zero);
		
		src_A = 32'd1972;
        src_B = 32'd1121;
        alu_op = 4'b0001; // SUB
        
        #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 3: AND
		$display("\nAnd Test: ");
		
		src_A = 32'hF0F0_F0F0;
        src_B = 32'h0F0F_0F0F;
        alu_op = 4'b0010; // AND

        #10;
        $display("%h & %h = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
        src_A = 32'hFFFF_0000;
        src_B = 32'h0F0F_0F0F;
        alu_op = 4'b0010; // AND

        #10;
        $display("%h & %h = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'h7777_7777;
        src_B = 32'hEF07_189A;
        alu_op = 4'b0010; // AND

        #10;
        $display("%h & %h = %h, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 4: OR
		$display("\nOr Test: ");
		
		src_A = 32'h0000_0000;
        src_B = 32'h0000_0000;
        alu_op = 4'b0011; // OR

        #10;
        $display("%h | %h = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'hF0F0_F0F0;
        src_B = 32'h0F0F_0F0F;
        alu_op = 4'b0011; // OR
		
		#10;
        $display("%h | %h = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'h7777_7777;
        src_B = 32'hEF07_189A;
        alu_op = 4'b0011; // OR

        #10;
        $display("%h | %h = %h, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 5: XOR
		$display("\nXor Test: ");
		
		src_A = 32'hFFFF_FFFF;
        src_B = 32'hFFFF_FFFF;
        alu_op = 4'b0100; // XOR
        
        #10;
        $display("%h ^ %h = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
        src_A = 32'hFFFF_FFFF;
        src_B = 32'h0F0F_0F0F;
        alu_op = 4'b0100; // XOR
        
        #10;
        $display("%h ^ %h = %h, Zero: %b", src_A, src_B, alu_result, zero);

        src_A = 32'h7777_7777;
        src_B = 32'hEF07_189A;
		alu_op = 4'b0100; // XOR
        
        #10;
        $display("%h ^ %h = %h, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 6: SLT
		$display("\nSet Less Than Test: ");
		
		src_A = 32'd30;
        src_B = 32'd30;
        alu_op = 4'b0101; // SLT
        
        #10;
		$display("Is %d < %d ? : %d, Zero: %b", $signed(src_A), $signed(src_B), alu_result, zero);
		
        src_A = 32'h0000_0000;
        src_B = 32'hF000_0001;
        alu_op = 4'b0101; // SLT
        
        #10;
		$display("Is %d < %d ? : %d, Zero: %b", $signed(src_A), $signed(src_B), alu_result, zero);

		src_A = 32'd1121;
        src_B = 32'd1972;
        alu_op = 4'b0101; // SLT
        
        #10;
		$display("Is %d < %d ? : %d, Zero: %b", $signed(src_A), $signed(src_B), alu_result, zero);

        // Test 7: SLTU
		$display("\nSet Less Than Unsigned Test: ");
		
        src_A = 32'hF000_0000;
        src_B = 32'hF000_0001;
        alu_op = 4'b0110; // SLTU
        
        #10;
		$display("Is %d < %d ? : %d, Zero: %b", src_A, src_B, alu_result, zero);

		src_A = 32'd1972;
        src_B = 32'h1121;
        alu_op = 4'b0110; // SLTU
        
        #10;
		$display("Is %d < %d ? : %d, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'd31011;
        src_B = 32'd31011;
        alu_op = 4'b0110; // SLTU
        
        #10;
		$display("Is %d < %d ? : %d, Zero: %b", src_A, src_B, alu_result, zero);

		// Test 8: SLL
		$display("\nShift Left Logic Test: ");
		
		src_A = 32'h1234_5679;
        src_B = 32'd31;
        alu_op = 4'b0111; // SLL
        
        #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
        src_A = 32'h0FFF_FFFF;
        src_B = 32'd3;
        alu_op = 4'b0111; // SLL
        
        #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'h0F0F_FF00;
        src_B = 32'd1972;
        alu_op = 4'b0111; // SLL
        
        #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
		// Test 9: SRL
		$display("\nShift Right Logic Test: ");
		
        src_A = 32'hFDEA_DBEF;
        src_B = 32'd4;
        alu_op = 4'b1000; // SRL
        
        #10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'hDEAD_BEEF;
        src_B = 32'd8;
        alu_op = 4'b1000; // SRL
		
		#10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'hFFFF_FFFF;
        src_B = 32'd1972;
        alu_op = 4'b1000; // SRL
        
        #10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 10: SRA
		$display("\nShift Right Arithmetic Test: ");

        src_A = 32'hFDEA_DBEF;
        src_B = 32'd4;
        alu_op = 4'b1001; // SRA
        
        #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, zero);

        src_A = 32'h8000_0000;
        src_B = 32'd1972;
        alu_op = 4'b1001; // SRA
        
        #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'h0000_0000;
        src_B = 32'd31011;
        alu_op = 4'b1001; // SRA
        
        #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 11: ABJ
		$display("\nAbjunction Test: ");
		
        src_A = 32'hFFFF_FFFF;
        src_B = 32'h0FF0_0FF0;
        alu_op = 4'b1010; // ABJ
        
        #10;
        $display("%h & ~%h = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'hFFFF_FFFF;
        src_B = 32'h7812_AEB5;
        alu_op = 4'b1010; // ABJ
        
        #10;
        $display("%h & ~%h = %h, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'hFFFF_FFFF;
        src_B = 32'hFFFF_FFFF;
        alu_op = 4'b1010; // ABJ
        
        #10;
        $display("%h & ~%h = %h, Zero: %b", src_A, src_B, alu_result, zero);

        // Test 12: NOP
		$display("\nNOP Test: ");
		
        src_A = 32'hDEAD_BEEF;
        src_B = 32'hCAFE_BEBE;
        alu_op = 4'b1111; // NOP
        
        #10;
        $display("%h NOP %h = %h, Zero: %b", src_A, src_B, alu_result, zero);

        src_A = 32'd1972;
        src_B = 32'd1121;
        alu_op = 4'b1111; // NOP
        
        #10;
        $display("%d NOP %d = %d, Zero: %b", src_A, src_B, alu_result, zero);
		
		src_A = 32'd31011;
        src_B = 32'd31011;
        alu_op = 4'b1111; // NOP
        
        #10;
        $display("%d NOP %d = %d, Zero: %b", src_A, src_B, alu_result, zero);

        $display("\n====================  ALU Test END  ====================");

        $stop;
    end

endmodule

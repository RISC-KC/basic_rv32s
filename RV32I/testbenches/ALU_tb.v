`timescale 1ns/1ps

`include "modules/headers/alu_op.vh"

module ALU_tb;
    reg [31:0] src_A;
	reg [31:0] src_B;
    reg [3:0] alu_op;

    wire [31:0] alu_result;
    wire alu_zero;

    ALU alu (
        .src_A(src_A),
        .src_B(src_B),
        .alu_op(alu_op),

        .alu_result(alu_result),
        .alu_zero(alu_zero)
    );

    initial begin
        // Test sequence
        $display("==================== ALU Test START ====================");

        // Test 1: Addition
		$display("\nAddition Test: ");
		
        alu_op = `ALU_OP_ADD;

        src_A = 32'd0; src_B = 32'd0; #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'd1000; src_B = 32'd2000; #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'd1972; src_B = 32'd1121; #10;
        $display("%d + %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 2: Subtraction
		$display("\nSubtraction Test: ");
		
        alu_op = `ALU_OP_SUB;

        src_A = 32'd30; src_B = 32'd30; #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'd10; src_B = 32'd20; #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, $signed(alu_result), alu_zero);
		
		src_A = 32'd1972; src_B = 32'd1121; #10;
        $display("%d - %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 3: AND
		$display("\nAnd Test: ");
		
        alu_op = `ALU_OP_AND;

		src_A = 32'hF0F0_F0F0; src_B = 32'h0F0F_0F0F; #10;
        $display("%h & %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
        src_A = 32'hFFFF_0000; src_B = 32'h0F0F_0F0F; #10;
        $display("%h & %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'h7777_7777; src_B = 32'hEF07_189A; #10;
        $display("%h & %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 4: OR
		$display("\nOr Test: ");
		
        alu_op = `ALU_OP_OR;

		src_A = 32'h0000_0000; src_B = 32'h0000_0000; #10;
        $display("%h | %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'hF0F0_F0F0; src_B = 32'h0F0F_0F0F; #10;
        $display("%h | %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'h7777_7777; src_B = 32'hEF07_189A; #10;
        $display("%h | %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 5: XOR
		$display("\nXor Test: ");
		
        alu_op = `ALU_OP_XOR;

		src_A = 32'hFFFF_FFFF; src_B = 32'hFFFF_FFFF; #10;
        $display("%h ^ %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
        src_A = 32'hFFFF_FFFF; src_B = 32'h0F0F_0F0F; #10;
        $display("%h ^ %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 32'h7777_7777; src_B = 32'hEF07_189A; #10;
        $display("%h ^ %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 6: SLT
		$display("\nSet Less Than Test: ");
		
        alu_op = `ALU_OP_SLT;

		src_A = 32'd30; src_B = 32'd30;  #10;
		$display("Is %d < %d ? : %d, Zero: %b", $signed(src_A), $signed(src_B), alu_result, alu_zero);
		
        src_A = 32'h0000_0000; src_B = 32'hF000_0001; #10;
		$display("Is %d < %d ? : %d, Zero: %b", $signed(src_A), $signed(src_B), alu_result, alu_zero);

		src_A = 32'd1121; src_B = 32'd1972; #10;
		$display("Is %d < %d ? : %d, Zero: %b", $signed(src_A), $signed(src_B), alu_result, alu_zero);

        // Test 7: SLTU
		$display("\nSet Less Than Unsigned Test: ");
		
        alu_op = `ALU_OP_SLTU;

        src_A = 32'hF000_0000; src_B = 32'hF000_0001; #10;
		$display("Is %d < %d ? : %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

		src_A = 32'd1972; src_B = 32'h1121; #10;
		$display("Is %d < %d ? : %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'd31011; src_B = 32'd31011; #10;
		$display("Is %d < %d ? : %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

		// Test 8: SLL
		$display("\nShift Left Logic Test: ");
		
        alu_op = `ALU_OP_SLL;

		src_A = 32'h1234_5679; src_B = 32'd31; #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
        src_A = 32'h0FFF_FFFF; src_B = 32'd3; #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'h0F0F_FF00; src_B = 32'd1972; #10;
        $display("%h << %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		// Test 9: SRL
		$display("\nShift Right Logic Test: ");
		
        alu_op = `ALU_OP_SRL;

        src_A = 32'hFDEA_DBEF; src_B = 32'd4; #10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'hDEAD_BEEF; src_B = 32'd8; #10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'hFFFF_FFFF; src_B = 32'd1972; #10;
        $display("%h >> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 10: SRA
		$display("\nShift Right Arithmetic Test: ");

        alu_op = `ALU_OP_SRA;

        src_A = 32'hFDEA_DBEF; src_B = 32'd4; #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 32'h8000_0000; src_B = 32'd1972; #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'h0000_0000; src_B = 32'd31011; #10;
        $display("%h >>> %d = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 11: ABJ
		$display("\nAbjunction Test: ");
		
        alu_op = `ALU_OP_ABJ;

        src_B = 32'hFFFF_FFFF; src_A = 32'h0FF0_0FF0; #10;
        $display("%h & ~%h = %h, Zero: %b", src_B, src_A, alu_result, alu_zero);
		
		src_B = 32'hFFFF_FFFF; src_A = 32'h7812_AEB5; #10;
        $display("%h & ~%h = %h, Zero: %b", src_B, src_A, alu_result, alu_zero);
		
		src_B = 32'hFFFF_FFFF; src_A = 32'hFFFF_FFFF;  #10;
        $display("%h & ~%h = %h, Zero: %b", src_B, src_A, alu_result, alu_zero);

        // Test 12: Bypass src_A
		$display("\nBypass src_A Test: ");
		
        alu_op = `ALU_OP_BPA;

        src_A = 32'hDEAD_BEEF; src_B = 32'hCAFE_BEBE; #10;
        $display("%h BPA %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 32'd1972; src_B = 32'd1121; #10;
        $display("%d BPA %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'd31011; src_B = 32'd31011; #10;
        $display("%d BPA %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

        // Test 13: NOP
		$display("\nNOP Test: ");
		
        alu_op = `ALU_OP_NOP;

        src_A = 32'hDEAD_BEEF; src_B = 32'hCAFE_BEBE; #10;
        $display("%h NOP %h = %h, Zero: %b", src_A, src_B, alu_result, alu_zero);

        src_A = 32'd1972; src_B = 32'd1121; #10;
        $display("%d NOP %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);
		
		src_A = 32'd31011; src_B = 32'd31011; #10;
        $display("%d NOP %d = %d, Zero: %b", src_A, src_B, alu_result, alu_zero);

        $display("\n====================  ALU Test END  ====================");

        $stop;
    end

endmodule

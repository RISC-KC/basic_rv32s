`timescale 1ns/1ps
`include "modules/headers/opcode.vh"

module ImmediateGenerator_tb;
    reg [31:0] raw_imm;
	reg [6:0] opcode;
    wire [31:0] imm;

    ImmediateGenerator immediate_generator (
        .raw_imm(raw_imm),
		.opcode(opcode),
		.imm(imm)
    );

    initial begin
        // Test sequence
        $display("==================== Immediate Generator Test START ====================");

        raw_imm = 32'b0;
		opcode = 7'b0;

        // Test 1: I-type
		$display("\nI-type: ");
		
        raw_imm = 32'd1972;
		opcode = `OPCODE_JALR;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
        raw_imm = -32'd1121;
		opcode = `OPCODE_LOAD;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
		raw_imm = 32'd310;
		opcode = `OPCODE_ITYPE;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
		raw_imm = 32'd0;
		opcode = `OPCODE_FENCE;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
		raw_imm = -32'd2025;
		opcode = `OPCODE_ENVIRONMENT;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));

        // Test 2: S-type
		$display("\nS-type: ");
		
		raw_imm = 32'd1972;
		opcode = `OPCODE_STORE;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
		raw_imm = -32'd1121;
		opcode = `OPCODE_STORE;

        #1;
		$display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));

        // Test 3: U-type
		$display("\nU-type: ");
		
		raw_imm = 32'h0000BEEF;
		opcode = `OPCODE_LUI;

        #1;
        $display("raw_imm: %h, imm: %h", raw_imm, imm);
		
		raw_imm = 32'hDEADBEEF;
		opcode = `OPCODE_AUIPC;

        #1;
        $display("raw_imm: %h, imm: %h", raw_imm, imm);
		
		// Test 4: B-type
		$display("\nB-type: ");
		
		raw_imm = 32'd1972;
		opcode = `OPCODE_BRANCH;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
		raw_imm = -32'd1121;

        #1;
		$display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));

        // Test 5: J-type
		$display("\nJ-type: ");
		
		raw_imm = 32'd1972;
		opcode = `OPCODE_JAL;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[20:0], $signed(raw_imm[20:0]), imm, $signed(imm));
		
		raw_imm = -32'd1121;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[20:0], $signed(raw_imm[20:0]), imm, $signed(imm));

        // Test 6: R-type (which should return 0)
		$display("\nR-type (which should return 0): ");
		
		raw_imm = 32'd1972;
		opcode = `OPCODE_RTYPE;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[20:0], $signed(raw_imm[20:0]), imm, $signed(imm));
		
		raw_imm = -32'd1121;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[20:0], $signed(raw_imm[20:0]), imm, $signed(imm));

        $display("\n====================  Immediate Generator Test END  ====================");

        $stop;
    end

endmodule

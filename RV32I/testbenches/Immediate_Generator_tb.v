`timescale 1ns/1ps
`include "modules/headers/opcode.vh"

module ImmediateGenerator_tb;
    reg [31:0] imm;
	reg [6:0] opcode;
    wire [31:0] ex_imm;

    ImmediateGenerator immediate_generator (
        .imm(imm),
		.opcode(opcode),
		.ex_imm(ex_imm)
    );

    initial begin
        // Test sequence
        $display("==================== Immediate Generator Test START ====================");

        imm = 32'b0;
		opcode = 7'b0;

        // Test 1: I-type
		$display("\nI-type: ");
		
        imm = 32'd1972;
		opcode = `OPCODE_JALR;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[11:0], $signed(imm[11:0]), ex_imm, $signed(ex_imm));
		
        imm = -32'd1121;
		opcode = `OPCODE_LOAD;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[11:0], $signed(imm[11:0]), ex_imm, $signed(ex_imm));
		
		imm = 32'd310;
		opcode = `OPCODE_ITYPE;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[11:0], $signed(imm[11:0]), ex_imm, $signed(ex_imm));
		
		imm = 32'd0;
		opcode = `OPCODE_FENCE;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[11:0], $signed(imm[11:0]), ex_imm, $signed(ex_imm));
		
		imm = -32'd2025;
		opcode = `OPCODE_ENVIRONMENT;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[11:0], $signed(imm[11:0]), ex_imm, $signed(ex_imm));

        // Test 2: S-type
		$display("\nS-type: ");
		
		imm = 32'd1972;
		opcode = `OPCODE_STORE;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[11:0], $signed(imm[11:0]), ex_imm, $signed(ex_imm));
		
		imm = -32'd1121;
		opcode = `OPCODE_STORE;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[11:0], $signed(imm[11:0]), ex_imm, $signed(ex_imm));

        // Test 3: U-type
		$display("\nU-type: ");
		
		imm = 32'h0000BEEF;
		opcode = `OPCODE_LUI;

        #1;
        $display("imm: %h, ex_imm: %h", imm, ex_imm);
		
		imm = 32'hDEADBEEF;
		opcode = `OPCODE_AUIPC;

        #1;
        $display("imm: %h, ex_imm: %h", imm, ex_imm);
		
		// Test 4: B-type
		$display("\nB-type: ");
		
		imm = 32'd1972;
		opcode = `OPCODE_BRANCH;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[11:0], $signed(imm[11:0]), ex_imm, $signed(ex_imm));
		
		imm = -32'd1121;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[11:0], $signed(imm[11:0]), ex_imm, $signed(ex_imm));

        // Test 5: J-type
		$display("\nJ-type: ");
		
		imm = 32'd1972;
		opcode = `OPCODE_JAL;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[20:0], $signed(imm[20:0]), ex_imm, $signed(ex_imm));
		
		imm = -32'd1121;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[20:0], $signed(imm[20:0]), ex_imm, $signed(ex_imm));

        // Test 6: R-type (which should return 0)
		$display("\nR-type (which should return 0): ");
		
		imm = 32'd1972;
		opcode = `OPCODE_RTYPE;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[20:0], $signed(imm[20:0]), ex_imm, $signed(ex_imm));
		
		imm = -32'd1121;

        #1;
        $display("imm: %h (%d), ex_imm: %h (%d)", imm[20:0], $signed(imm[20:0]), ex_imm, $signed(ex_imm));

        $display("\n====================  Immediate Generator Test END  ====================");

        $stop;
    end

endmodule

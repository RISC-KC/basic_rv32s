`timescale 1ns/1ps
`include "modules/headers/opcode.vh"

module ImmediateGenerator_tb;
    reg [19:0] raw_imm;
	reg [6:0] opcode;
    wire [31:0] imm;

    ImmediateGenerator immediate_generator (
        .raw_imm(raw_imm),
		.opcode(opcode),
		.imm(imm)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/Immediate_Generator_tb_result.vcd");
        $dumpvars(0, immediate_generator);

        // Test sequence
        $display("==================== Immediate Generator Test START ====================");

        raw_imm = 20'b0;
		opcode = 7'b0;

        // Test 1: I-type
		$display("\nI-type: ");
		
        raw_imm = 20'd1972;
		opcode = `OPCODE_JALR;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
        raw_imm = -20'd1121;
		opcode = `OPCODE_LOAD;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
		raw_imm = 20'd310;
		opcode = `OPCODE_ITYPE;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
		raw_imm = 20'd0;
		opcode = `OPCODE_FENCE;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
		raw_imm = -20'd2025;
		opcode = `OPCODE_ENVIRONMENT;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));

        // Test 2: S-type
		$display("\nS-type: ");
		
		raw_imm = 20'd1972;
		opcode = `OPCODE_STORE;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
		raw_imm = -20'd1121;
		opcode = `OPCODE_STORE;

        #1;
		$display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));

        // Test 3: U-type
		$display("\nU-type: ");
		
		raw_imm = 20'h0BEEF;
		opcode = `OPCODE_LUI;

        #1;
        $display("raw_imm: %h, imm: %h", raw_imm, imm);
		
		raw_imm = 20'hDBEEF;
		opcode = `OPCODE_AUIPC;

        #1;
        $display("raw_imm: %h, imm: %h", raw_imm, imm);
		
		// Test 4: B-type
		$display("\nB-type: ");
		
		raw_imm = 20'd1972;
		opcode = `OPCODE_BRANCH;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));
		
		raw_imm = -20'd1121;

        #1;
		$display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[11:0], $signed(raw_imm[11:0]), imm, $signed(imm));

        // Test 5: J-type
		$display("\nJ-type: ");
		
		raw_imm = 20'd1972;
		opcode = `OPCODE_JAL;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[19:0], $signed(raw_imm[19:0]), imm, $signed(imm));
		
		raw_imm = -20'd1121;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[19:0], $signed(raw_imm[19:0]), imm, $signed(imm));

        // Test 6: R-type (which should return 0)
		$display("\nR-type (which should return 0): ");
		
		raw_imm = 20'd1972;
		opcode = `OPCODE_RTYPE;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[19:0], $signed(raw_imm[19:0]), imm, $signed(imm));
		
		raw_imm = -20'd1121;

        #1;
        $display("raw_imm: %h (%d), imm: %h (%d)", raw_imm[19:0], $signed(raw_imm[19:0]), imm, $signed(imm));

        $display("\n====================  Immediate Generator Test END  ====================");

        $stop;
    end

endmodule

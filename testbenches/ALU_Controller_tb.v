`timescale 1ns/1ps

`include "modules/headers/branch.vh"
`include "modules/headers/csr.vh"
`include "modules/headers/itype.vh"
`include "modules/headers/load.vh"
`include "modules/headers/opcode.vh"
`include "modules/headers/rtype.vh"
`include "modules/headers/store.vh"

module ALUController_tb;
	reg [6:0] opcode;
	reg [2:0] funct3;
    reg [6:0] funct7;
    reg [31:0] imm;
	
    wire [3:0] alu_op;

    ALUController alu_controller (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7[5]),
		.imm_10(imm[10]),

        .alu_op(alu_op)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/ALU_Controller_tb_result.vcd");
        $dumpvars(0, alu_controller);

        opcode = 7'b0;
		funct3 = 3'b0;
		funct7 = 7'b0;
        imm = 32'b0;

        // Test sequence
        $display("==================== ALU Controller Test START ====================");

        // Test 1: AUIPC
		$display("\nAUIPC: ");
		
		opcode = `OPCODE_AUIPC; #10;
        $display("opcode: %b -> alu_op: %b", opcode, alu_op);

        // Test 2: JAL
		$display("\nJAL: ");
		
		opcode = `OPCODE_JAL; #10;
        $display("opcode: %b -> alu_op: %b", opcode, alu_op);

        // Test 3: JALR
        $display("\nJALR: ");
		
		opcode = `OPCODE_JALR;
        funct3 = 3'b0;
		funct7 = 7'b0;
		imm = 32'h0;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);

        // Test 4: Branch instructions
        $display("\nBranch instructions: ");
		
		opcode = `OPCODE_BRANCH;
		funct7 = 7'b0;
		imm = 32'b0;

        funct3 = `BRANCH_BEQ; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `BRANCH_BNE; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `BRANCH_BLT; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `BRANCH_BGE; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `BRANCH_BLTU; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `BRANCH_BGEU; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);

        // Test 5: Load instructions
        $display("\nLoad instructions: ");
		
		opcode = `OPCODE_LOAD;
		funct7 = 7'b0;
		imm = 32'b0;

        funct3 = `LOAD_LB; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `LOAD_LH; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `LOAD_LW; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `LOAD_LBU; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `LOAD_LHU; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		// Test 6: Store instructions
        $display("\nStore instructions: ");
		
		opcode = `OPCODE_STORE;
		funct7 = 7'b0;
		imm = 32'b0;

        funct3 = `STORE_SB; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
        funct3 = `STORE_SH; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
        funct3 = `STORE_SW; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);

		// Test 7: I-type instructions
        $display("\nI-type instructions: ");
		
		opcode = `OPCODE_ITYPE;
		imm = 32'b0;

        funct3 = `ITYPE_ADDI;
		funct7 = 7'b0000000; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		funct3 = `ITYPE_SLLI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		funct3 = `ITYPE_SLTI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		funct3 = `ITYPE_SLTIU; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);

        funct3 = `ITYPE_XORI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);

		funct3 = `ITYPE_SRXI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		imm = 32'h00000400; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		funct3 = `ITYPE_ORI;
		imm = 32'h00000000; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
		funct3 = `ITYPE_ANDI; #10;
        $display("imm: %h funct3: %b opcode: %b -> alu_op: %b", imm, funct3, opcode, alu_op);
		
        // Test 8: R-type instructions
		$display("\nR-type instructions: ");
		
		opcode = `OPCODE_RTYPE;
		imm = 32'h00000000;

		funct3 = `RTYPE_ADDSUB;
		funct7 = 7'b0000000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
        
		funct7 = 7'b0100000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = `RTYPE_SLL;
		funct7 = 7'b0000000;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = `RTYPE_SLT; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = `RTYPE_SLTU; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = `RTYPE_XOR; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = `RTYPE_SR; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct7 = 7'b0100000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = `RTYPE_OR;
		funct7 = 7'b0000000; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);
		
		funct3 = `RTYPE_AND; #10;
        $display("funct7: %b funct3: %b opcode: %b -> alu_op: %b", funct7, funct3, opcode, alu_op);

		// Test 9: CSR instructions
        $display("\nCSR instructions: ");
		
		opcode = `OPCODE_ENVIRONMENT;
		funct7 = 7'b0;
		imm = 32'b0;

        funct3 = `CSR_CSRRW; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `CSR_CSRRS; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `CSR_CSRRC; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `CSR_CSRRWI; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `CSR_CSRRSI; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		funct3 = `CSR_CSRRCI; #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		// Test 10: Invalid
        $display("\nInvalid instruction: ");
			
		opcode = 7'b0101010; // Doesn't exist!
        funct3 = 3'b000;
		funct7 = 7'b0000000;
		imm = 32'h00000000;

        #10;
        $display("funct3: %b opcode: %b -> alu_op: %b", funct3, opcode, alu_op);
		
		$display("\n====================  ALU Controller Test END  ====================");
		
		$stop;
    end

endmodule

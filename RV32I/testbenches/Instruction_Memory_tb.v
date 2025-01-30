`timescale 1ns/1ps

module InstructionMemory_tb;
    reg [31:0] pc;
    wire [31:0] instruction;

    InstructionMemory instruction_memory (
        .pc(pc),
		.instruction(instruction)
    );

    initial begin
        // Test sequence
        $display("==================== Instruction Memory Test START ====================\n");

        pc = 32'd0; #10;
        $display("Instruction: %b", instruction);
		
		pc = 32'd4; #10;
        $display("Instruction: %b", instruction);
		
		pc = 32'd8; #10;
        $display("Instruction: %b", instruction);

        $display("\n====================  Instruction Memory Test END  ====================");

        $stop;
    end

endmodule

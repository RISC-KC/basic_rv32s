`timescale 1ns/1ps

module InstructionMemory_tb;
    reg [31:0] pc;
    wire [31:0] instruction;

    InstructionMemory instruction_memory (
        .pc(pc),
		.instruction(instruction)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/Instruction_Memory_tb_result.vcd");
        $dumpvars(0, InstructionMemory_tb.instruction_memory);

        $writememb("testbenches/test_code.mem", instruction_memory.data);

        // Test sequence
        $display("==================== Instruction Memory Test START ====================\n");

        pc = 32'h00000000; #10;
        $display("Instruction: %b", instruction);
		
		pc = 32'h00000004; #10;
        $display("Instruction: %b", instruction);
		
		pc = 32'h00000008; #10;
        $display("Instruction: %b", instruction);

        pc = 32'h0000000C; #10;
        $display("Instruction: %b", instruction);

        $display("\n====================  Instruction Memory Test END  ====================");

        $stop;
    end

endmodule

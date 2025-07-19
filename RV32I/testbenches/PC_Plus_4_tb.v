`timescale 1ns/1ps

module PCPlus4_tb;
	reg [31:0] pc;
	wire [31:0] pc_plus_4;

    PCPlus4 dut (
        .pc(pc),
		.pc_plus_4(pc_plus_4)
    );

    initial begin
        // Test sequence
        $display("==================== PCPlus4 Test START ====================\n");

        pc = 32'h00000000; #1;
        $display("PC: %h, PC+4: %h", pc, pc_plus_4);
        
		pc = 32'hDEADBEEF; #1;
        $display("PC: %h, PC+4: %h", pc, pc_plus_4);
		
		pc = 32'hCAFEBEBE; #1;
        $display("PC: %h, PC+4: %h", pc, pc_plus_4);
		
		$display("\n====================  PCPlus4 Test END  ====================");
		
		$stop;
    end

endmodule

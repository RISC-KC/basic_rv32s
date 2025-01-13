module ALUControl (
    input [3:0] alu_op,        		// ALU operation signal (from Control Unit)
	input [2:0] funct3,				// funct3
    input [6:0] funct7,				// funct7
    
    output reg [3:0] alu_control,	// ALU control signal
);

    always @(*) begin
        case (alu_op)
            4'b0000: begin
                // WIP
            end
        endcase
    end

endmodule

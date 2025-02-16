module PCPlus4 (
    input [31:0] pc,            // Current pc value
	  output reg [31:0] pc_plus_4 // pc+4 value
);

    always @(*) begin
		  pc_plus_4 = pc + 4;
    end

endmodule

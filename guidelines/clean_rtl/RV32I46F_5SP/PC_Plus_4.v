module PCPlus4 (
    input [31:0] pc,
	  output reg [31:0] pc_plus_4
);

    always @(*) begin
		  pc_plus_4 = pc + 4;
    end
endmodule

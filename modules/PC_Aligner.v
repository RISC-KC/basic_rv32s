module PCAligner (
    input [31:0] raw_next_pc,
	output reg [31:0] next_pc
);

    always @(*) begin
		next_pc = {raw_next_pc[31:2], 2'b0};
    end

endmodule

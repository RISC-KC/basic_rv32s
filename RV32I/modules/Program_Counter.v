module ProgramCounter (
    input clk,
    input reset,
    input [31:0] next_pc, // Next pc value
    output reg [31:0] pc // Current pc value
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'b0; // Reset to 0
        end 
		else begin
            pc <= next_pc; // Update pc value
        end
    end

endmodule
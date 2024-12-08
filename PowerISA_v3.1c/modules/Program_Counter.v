
module ProgramCounter (
    input clk,
    input reset,
    input [31:0] nextPC, // Next PC value
    output reg [31:0] pc // Current PC value
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'b0; // Reset to 0
        end else begin
            pc <= nextPC; // Update PC
        end
    end

endmodule

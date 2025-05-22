module IF_ID_Reg #(
    parameter XLEN = 32;
)(
    // pipeline register control signals
    input wire clk,
    input wire reset,
    input wire flush,

    // signals from IF phase
    input wire [XLEN-1:0] IF_pc,
    input wire [XLEN-1:0] IF_pc_plus_4,
    input wire [XLEN-1:0] IF_instruction,
    input wire IF_branch_estimation

    // signals to ID/EX register
    output reg [XLEN-1:0] ID_pc,
    output reg [XLEN-1:0] ID_pcplus4,
    output reg [XLEN-1:0] ID_instruction,
    output reg ID_branch_estimation
);

always @(posedge clk or posedge reset) begin
    if (reset or flush) begin
        ID_pc <= {XLEN{1'b0}};
        ID_pcplus4 <= {XLEN{1'b0}};
        ID_instruction <= {XLEN{1'b0}};
        ID_branch_estimation <= 1'b0;
    end else begin
        ID_pc <= IF_pc;
        ID_pc_plus_4 <= IF_pc_plus_4;
        ID_instruction <= IF_instruction;
        ID_branch_estimation <= IF_branch_estimation;
    end
end

endmodule

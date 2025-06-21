module IF_ID_Register #(
    parameter XLEN = 32
)(
    // pipeline register control signals
    input wire clk,
    input wire clk_enable,
    input wire reset,
    input wire flush,
    input wire IF_ID_stall,

    // signals from IF phase
    input wire [XLEN-1:0] IF_pc,
    input wire [XLEN-1:0] IF_pc_plus_4,
    input wire [31:0] IF_instruction,
    input wire IF_branch_estimation,

    // signals to ID/EX register
    output reg [XLEN-1:0] ID_pc,
    output reg [XLEN-1:0] ID_pc_plus_4,
    output reg [31:0] ID_instruction,
    output reg ID_branch_estimation
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        ID_pc <= {XLEN{1'b0}};
        ID_pc_plus_4 <= {XLEN{1'b0}};
        ID_instruction <= 32'h0000_0013;
        ID_branch_estimation <= 1'b0;
    end 
    else if (clk_enable) begin
        if (flush) begin   
            ID_pc <= {XLEN{1'b0}};
            ID_pc_plus_4 <= {XLEN{1'b0}};
            ID_instruction <= 32'h0000_0013; // ADDI x0, x0, 0 = RISC-V NOP, HINT
            ID_branch_estimation <= 1'b0;
        end else if (!IF_ID_stall) begin
            ID_pc <= IF_pc;
            ID_pc_plus_4 <= IF_pc_plus_4;
            ID_instruction <= IF_instruction;
            ID_branch_estimation <= IF_branch_estimation;
        end
    end
end

endmodule
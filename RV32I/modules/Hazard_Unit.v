module HazardUnit (
    input wire clk,
    input wire reset,

    input wire [4:0] ID_rs1,
    input wire [4:0] ID_rs2,
    input wire [4:0] ID_rd,

    input wire branch_prediction_miss,
    input wire EX_jump,

    output reg [1:0] hazard_op,
    output reg IF_ID_flush,
    output reg ID_EX_flush
);
    reg [1:0] hazard_flag;
    reg [4:0] previous_rd;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            previous_rd <= 5'b0;
            hazard_op <= 2'b0;
            IF_ID_flush <= 1'b0;
            ID_EX_flush <= 1'b0;
        end else begin
            previous_rd <= ID_rd;
        end
    end

    always @(*) begin
        IF_ID_flush = 1'b0;
        ID_EX_flush = 1'b0;
        hazard_op = hazard_flag;
        if (previous_rd != 5'b0) begin
            if (previous_rd == ID_rs1) hazard_flag[0] = 1'b1;
            else hazard_flag[0] = 1'b0;
            if (previous_rd == ID_rs2) hazard_flag[1] = 1'b1;
            else hazard_flag[1] = 1'b0;
        end else hazard_flag = 2'b0;

        if (EX_jump || branch_prediction_miss) begin
            IF_ID_flush = 1'b1;
            ID_EX_flush = 1'b1;
        end
    end


    
endmodule
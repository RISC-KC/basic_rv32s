module HazardUnit (
    input wire clk,
    input wire reset,

    input wire [4:0] ID_rs1,
    input wire [4:0] ID_rs2,
    input wire [4:0] ID_rd,

    input wire branch_prediction_miss,
    input wire EX_jump,

    output reg hazard_op,
    output reg IF_ID_flush
);
    reg hazard_flag;
    reg [4:0] previous_rd;
    // assign hazard_op = ((previous_rd != 5'b0) && (previous_rd == ID_rs1 || previous_rd == ID_rs2));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            previous_rd <= 5'b0;
            hazard_op <= 1'b0;
            IF_ID_flush <= 1'b0;
        end else begin
            previous_rd <= ID_rd;
        end
    end

    always @(*) begin
        hazard_op = hazard_flag;
        if ((previous_rd != 5'b0) && ((previous_rd == ID_rs1) || (previous_rd == ID_rs2))) begin
                hazard_flag = 1'b1;
        end else hazard_flag = 1'b0;
        if (EX_jump || branch_prediction_miss) begin
            IF_ID_flush <= 1'b1;
        end
    end


    
endmodule
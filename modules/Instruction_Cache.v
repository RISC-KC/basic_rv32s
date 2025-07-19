module InstructionCache (
    input clk,
    input reset,
    input [9:0] address,
    input update_enable,
    input [31:0] im_data,

    output reg hit,
    output reg [31:0] data
);

    reg valid1 [0:31];
    reg [4:0] tag1 [0:31];
    reg [31:0] data1 [0:31];

    reg valid2 [0:31];
    reg [4:0] tag2 [0:31];
    reg [31:0] data2 [0:31];

    reg lru [0:31];

    wire [4:0] index = address[4:0];
    wire [4:0] tag = address[9:5];

    wire hit1 = valid1[index] && (tag1[index] == tag);
    wire hit2 = valid2[index] && (tag2[index] == tag);

    always @(*) begin
        hit = hit1 || hit2;
    end

    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<32; i=i+1) begin
                valid1[i] <= 0;
                tag1[i] <= 5'b0;
                data1[i] <= 32'b0;

                valid2[i] <= 0;
                tag2[i] <= 5'b0;
                data2[i] <= 32'b0;
                
                lru[i] <= 0;
            end
            
            data <= 32'b0;
        end 
        else begin
            if (hit1) begin
                data <= data1[index];
            end
            else if (hit2) begin
                data <= data2[index];
            end
            else begin
                if (update_enable) begin
                    if (!valid1[index]) begin
                        valid1[index] <= 1;
                        tag1[index] <= tag;
                        data1[index] <= im_data;
                    end
                    else if (!valid2[index]) begin
                        valid2[index] <= 1;
                        tag2[index] <= tag;
                        data2[index] <= im_data;
                    end
                    else if (lru[index] == 0) begin
                        tag1[index] <= tag;
                        data1[index] <= im_data;
                        lru[index] <= 1;
                    end
                    else begin
                        tag2[index] <= tag;
                        data2[index] <= im_data;
                        lru[index] <= 0;
                    end
                end
                data <= 32'b0;
            end
        end
    end

endmodule
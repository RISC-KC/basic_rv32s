module InstructionCache (
    input clk,
    input [9:0] address,
    input update_enable,
    input [9:0] im_address,
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
    reg status; // 0 for idle status, 1 for update status

    wire [4:0] index = address[4:0];
    wire [4:0] tag = address[9:5];

    wire [4:0] im_index = im_address[4:0];
    wire [4:0] im_tag = im_address[9:5];

    wire hit1 = valid1[index] && (tag1[index] == tag);
    wire hit2 = valid2[index] && (tag2[index] == tag);

	initial begin
        $readmemb("modules/initial_data.mem", valid1);
        $readmemb("modules/initial_data.mem", tag1);
		$readmemb("modules/initial_data.mem", data1);
        
        $readmemb("modules/initial_data.mem", valid2);
        $readmemb("modules/initial_data.mem", tag2);
		$readmemb("modules/initial_data.mem", data2);

        $readmemb("modules/initial_data.mem", lru);
	end
	
    always @(*) begin
        hit = hit1 || hit2;
    end

	always @(posedge clk) begin
        if (status == 0) begin // idle status
            if (hit1) begin
                data <= data1[index];
            end
            else if (hit2) begin
                data <= data2[index];
            end
            else begin
                data <= 32'b0;
                status <= 1;
            end
        end
        else begin
            if (update_enable) begin
                if (valid1[im_index] == 0) begin
                    valid1[im_index] <= 1;
                    tag1[im_index] <= im_tag;
                    data1[im_index] <= im_data;
                end
                else if (valid2[im_index] == 0) begin
                    valid2[im_index] <= 1;
                    tag2[im_index] <= im_tag;
                    data2[im_index] <= im_data;
                end
                else if (lru[im_index] == 0) begin
                    tag1[im_index] <= im_tag;
                    data1[im_index] <= im_data;
                    lru[im_index] <= 1;
                end
                else begin
                    tag2[im_index] <= im_tag;
                    data2[im_index] <= im_data;
                    lru[im_index] <= 0;
                end
                status <= 0;
            end
        end
	end

endmodule

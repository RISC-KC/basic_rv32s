module DataCache (
    input clk,
    input reset,
    input [31:0] address,
    input read_enable,
    input write_enable,
    input [31:0] write_data,
    input [3:0] write_mask,
    input [255:0] dm_data,

    output reg hit,
    output reg [31:0] read_data,
    output reg [31:0] flush_address,
    output reg [255:0] flush_data,
    output reg flush_done
);

    reg valid1 [0:511];
    reg updated1 [0:511];
    reg [17:0] tag1 [0:511];
    reg [255:0] data1 [0:511];

    reg valid2 [0:511];
    reg updated2 [0:511];
    reg [17:0] tag2 [0:511];
    reg [255:0] data2 [0:511];

    reg lru [0:511];

    wire [4:0] offset = address[4:0];
    wire [8:0] index = address[13:5];
    wire [17:0] tag = address[31:14];

    wire hit1 = valid1[index] && (tag1[index] == tag);
    wire hit2 = valid2[index] && (tag2[index] == tag);

    integer i;

    always @(*) begin
        hit = hit1 || hit2;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<512; i=i+1) begin
                valid1[i] <= 0;
                updated1[i] <= 0;
                tag1[i] <= 18'b0;
                data1[i] <= 256'b0;

                valid2[i] <= 0;
                updated2[i] <= 0;
                tag2[i] <= 18'b0;
                data2[i] <= 256'b0;
                
                lru[i] <= 0;
            end
            
            read_data <= 32'b0;
            flush_address <= 32'b0;
            flush_data <= 256'b0;
            flush_done <= 1;
        end 
        else if (read_enable) begin
            if (hit1) begin
                read_data <= data1[index][32 * offset[4:2] +: 32];
                lru[index] <= 1;

                flush_address <= 32'b0;
                flush_data <= 256'b0;
                flush_done <= 1;
            end
            else if (hit2) begin
                read_data <= data2[index][32 * offset[4:2] +: 32];
                lru[index] <= 0;

                flush_address <= 32'b0;
                flush_data <= 256'b0;
                flush_done <= 1;
            end
            else begin
                read_data <= 32'b0;

                if (!valid1[index]) begin
                    valid1[index] <= 1;
                    tag1[index] <= tag;
                    data1[index] <= dm_data;
                    lru[index] <= 1;

                    flush_address <= 32'b0;
                    flush_data <= 256'b0;
                    flush_done <= 1;
                end
                else if (!valid2[index]) begin
                    valid2[index] <= 1;
                    tag2[index] <= tag;
                    data2[index] <= dm_data;
                    lru[index] <= 0;

                    flush_address <= 32'b0;
                    flush_data <= 256'b0;
                    flush_done <= 1;
                end
                else if (lru[index] == 0) begin
                    if (updated1[index]) begin
                        flush_address <= {tag1[index], index, 5'b0};
                        flush_data <= data1[index];
                        flush_done <= 0;

                        updated1[index] <= 0;
                    end
                    else begin
                        tag1[index] <= tag;
                        data1[index] <= dm_data;
                        lru[index] <= 1;

                        flush_address <= 32'b0;
                        flush_data <= 256'b0;
                        flush_done <= 1;
                    end
                end
                else begin
                    if (updated2[index]) begin
                        flush_address <= {tag2[index], index, 5'b0};
                        flush_data <= data2[index];
                        flush_done <= 0;

                        updated2[index] <= 0;
                    end
                    else begin
                        tag2[index] <= tag;
                        data2[index] <= dm_data;
                        lru[index] <= 0;

                        flush_address <= 32'b0;
                        flush_data <= 256'b0;
                        flush_done <= 1;
                    end
                end
            end
        end
        else if (write_enable) begin
            read_data <= 32'b0;

            if (hit1) begin
                // Now we use for loop based assignment instead of using bitmasking
                for (i=0; i<4; i=i+1) begin
                    if (write_mask[i]) begin
                        data1[index][32 * offset[4:2] + i*8 +: 8] <= write_data[i*8 +: 8];
                    end
                end

                updated1[index] <= 1;
                lru[index] <= 1;

                flush_address <= 32'b0;
                flush_data <= 256'b0;
                flush_done <= 1;
            end
            else if (hit2) begin
                for (i=0; i<4; i=i+1) begin
                    if (write_mask[i]) begin
                        data2[index][32 * offset[4:2] + i*8 +: 8] <= write_data[i*8 +: 8];
                    end
                end

                updated2[index] <= 1;
                lru[index] <= 0;
                
                flush_address <= 32'b0;
                flush_data <= 256'b0;
                flush_done <= 1;
            end
            else begin
                if (!valid1[index]) begin
                    valid1[index] <= 1;
                    tag1[index] <= tag;
                    
                    for (i=0; i<4; i=i+1) begin
                        if (write_mask[i]) begin
                            data1[index][32 * offset[4:2] + i*8 +: 8] <= write_data[i*8 +: 8];
                        end
                        else begin
                            data1[index][32 * offset[4:2] + i*8 +: 8] <= dm_data[32 * offset[4:2] + i*8 +: 8];
                        end
                    end
                    
                    updated1[index] <= 1;
                    lru[index] <= 1;

                    flush_address <= 32'b0;
                    flush_data <= 256'b0;
                    flush_done <= 1;
                end
                else if (!valid2[index]) begin
                    valid2[index] <= 1;
                    tag2[index] <= tag;
                    
                    for (i=0; i<4; i=i+1) begin
                        if (write_mask[i]) begin
                            data2[index][32 * offset[4:2] + i*8 +: 8] <= write_data[i*8 +: 8];
                        end
                        else begin
                            data2[index][32 * offset[4:2] + i*8 +: 8] <= dm_data[32 * offset[4:2] + i*8 +: 8];
                        end
                    end

                    updated2[index] <= 1;
                    lru[index] <= 0;

                    flush_address <= 32'b0;
                    flush_data <= 256'b0;
                    flush_done <= 1;
                end
                else if (lru[index] == 0) begin
                    if (updated1[index]) begin
                        flush_address <= {tag1[index], index, 5'b0};
                        flush_data <= data1[index];
                        flush_done <= 0;

                        updated1[index] <= 0;
                    end
                    else begin
                        tag1[index] <= tag;
                        
                        for (i=0; i<4; i=i+1) begin
                            if (write_mask[i]) begin
                                data1[index][32 * offset[4:2] + i*8 +: 8] <= write_data[i*8 +: 8];
                            end
                            else begin
                                data1[index][32 * offset[4:2] + i*8 +: 8] <= dm_data[32 * offset[4:2] + i*8 +: 8];
                            end
                        end
                        
                        updated1[index] <= 1;
                        lru[index] <= 1;

                        flush_address <= 32'b0;
                        flush_data <= 256'b0;
                        flush_done <= 1;
                    end
                end
                else begin
                    if (updated2[index]) begin
                        flush_address <= {tag2[index], index, 5'b0};
                        flush_data <= data2[index];
                        flush_done <= 0;

                        updated2[index] <= 0;
                    end
                    else begin
                        tag2[index] <= tag;
                        
                        for (i=0; i<4; i=i+1) begin
                            if (write_mask[i]) begin
                                data2[index][32 * offset[4:2] + i*8 +: 8] <= write_data[i*8 +: 8];
                            end
                            else begin
                                data2[index][32 * offset[4:2] + i*8 +: 8] <= dm_data[32 * offset[4:2] + i*8 +: 8];
                            end
                        end

                        updated2[index] <= 1;
                        lru[index] <= 0;

                        flush_address <= 32'b0;
                        flush_data <= 256'b0;
                        flush_done <= 1;
                    end
                end
            end
        end
        else begin
            read_data <= 32'b0;
            flush_address <= 32'b0;
            flush_data <= 256'b0;
            flush_done <= 1;
        end
    end

endmodule
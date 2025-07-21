module AutoUARTController (
    input clk,
    input reset,
    input benchmark_done,
    input [63:0] final_cycles,
    input [63:0] final_instructions,
    
    input tx_busy,
    output reg tx_start,
    output reg [7:0] tx_data,
    output reg output_complete
);

    // 상태 정의
    localparam IDLE = 3'd0;
    localparam SEND_CYCLES_LABEL = 3'd1;
    localparam SEND_CYCLES_VALUE = 3'd2;
    localparam SEND_INST_LABEL = 3'd3;
    localparam SEND_INST_VALUE = 3'd4;
    localparam SEND_NEWLINE = 3'd5;
    localparam WAIT_TX = 3'd6;
    
    reg [2:0] state;
    reg [7:0] byte_counter;
    reg [7:0] message_data [0:63]; // 최대 64바이트 메시지
    reg [5:0] message_length;
    
    // HEX to ASCII 함수
    function [7:0] hex2ascii;
        input [3:0] hex;
        begin
            hex2ascii = (hex < 10) ? (hex + 8'h30) : (hex + 8'h37);
        end
    endfunction
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx_start <= 1'b0;
            tx_data <= 8'b0;
            output_complete <= 1'b0;
            byte_counter <= 8'b0;
        end else begin
            tx_start <= 1'b0; // 기본값
            
            case (state)
                IDLE: begin
                    if (benchmark_done) begin
                        // "Cycles: " 메시지 준비
                        message_data[0] = 8'h43; // 'C'
                        message_data[1] = 8'h79; // 'y'
                        message_data[2] = 8'h63; // 'c'
                        message_data[3] = 8'h6C; // 'l'
                        message_data[4] = 8'h65; // 'e'
                        message_data[5] = 8'h73; // 's'
                        message_data[6] = 8'h3A; // ':'
                        message_data[7] = 8'h20; // ' '
                        
                        // Cycles 값을 HEX로 변환
                        message_data[8]  = hex2ascii(final_cycles[31:28]);
                        message_data[9]  = hex2ascii(final_cycles[27:24]);
                        message_data[10] = hex2ascii(final_cycles[23:20]);
                        message_data[11] = hex2ascii(final_cycles[19:16]);
                        message_data[12] = hex2ascii(final_cycles[15:12]);
                        message_data[13] = hex2ascii(final_cycles[11:8]);
                        message_data[14] = hex2ascii(final_cycles[7:4]);
                        message_data[15] = hex2ascii(final_cycles[3:0]);
                        
                        message_data[16] = 8'h0D; // '\r'
                        message_data[17] = 8'h0A; // '\n'
                        
                        // "Instructions: " 메시지
                        message_data[18] = 8'h49; // 'I'
                        message_data[19] = 8'h6E; // 'n'
                        message_data[20] = 8'h73; // 's'
                        message_data[21] = 8'h74; // 't'
                        message_data[22] = 8'h72; // 'r'
                        message_data[23] = 8'h75; // 'u'
                        message_data[24] = 8'h63; // 'c'
                        message_data[25] = 8'h74; // 't'
                        message_data[26] = 8'h69; // 'i'
                        message_data[27] = 8'h6F; // 'o'
                        message_data[28] = 8'h6E; // 'n'
                        message_data[29] = 8'h73; // 's'
                        message_data[30] = 8'h3A; // ':'
                        message_data[31] = 8'h20; // ' '
                        
                        // Instructions 값을 HEX로 변환
                        message_data[32] = hex2ascii(final_instructions[31:28]);
                        message_data[33] = hex2ascii(final_instructions[27:24]);
                        message_data[34] = hex2ascii(final_instructions[23:20]);
                        message_data[35] = hex2ascii(final_instructions[19:16]);
                        message_data[36] = hex2ascii(final_instructions[15:12]);
                        message_data[37] = hex2ascii(final_instructions[11:8]);
                        message_data[38] = hex2ascii(final_instructions[7:4]);
                        message_data[39] = hex2ascii(final_instructions[3:0]);
                        
                        message_data[40] = 8'h0D; // '\r'
                        message_data[41] = 8'h0A; // '\n'
                        
                        message_length = 42;
                        byte_counter = 0;
                        state <= SEND_CYCLES_LABEL;
                    end
                end
                
                SEND_CYCLES_LABEL: begin
                    if (!tx_busy) begin
                        tx_data <= message_data[byte_counter];
                        tx_start <= 1'b1;
                        byte_counter <= byte_counter + 1;
                        state <= WAIT_TX;
                    end
                end
                
                WAIT_TX: begin
                    if (!tx_busy) begin
                        if (byte_counter >= message_length) begin
                            state <= IDLE;
                            output_complete <= 1'b1;
                        end else begin
                            state <= SEND_CYCLES_LABEL;
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
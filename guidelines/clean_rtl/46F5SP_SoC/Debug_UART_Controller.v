module DebugUARTController (
    input clk,
    input reset,
    input pc_inst_trigger,
    input reg_trigger,
    input alu_trigger,
    input [31:0] debug_pc,
    input [31:0] debug_instruction,
    input [4:0]  debug_reg_addr,
    input [31:0] debug_reg_data,
    input [31:0] debug_alu_result,
    input             tx_busy,
    
    output reg        tx_start,
    output reg [7:0]  tx_data
);
    localparam ST_IDLE  = 2'd0,
               ST_SEND  = 2'd1,
               ST_WAIT  = 2'd2;

    localparam MODE_PC  = 2'd0;
    localparam MODE_REG = 2'd1;
    localparam MODE_ALU = 2'd2;

    function [4:0] max_len;
        input [1:0] mode;
        begin
            case(mode)
            MODE_PC : max_len = 19;
            MODE_REG: max_len = 13;
            MODE_ALU: max_len = 10;
            default : max_len = 19;
            endcase
        end
    endfunction

    localparam BUF_WIDTH = 19 * 8;

    reg [1:0] state;
    reg [1:0] mode;
    reg [4:0] byte_cnt;
    reg [BUF_WIDTH-1:0] send_buf;

    function [7:0] hex2asc;
        input [3:0] h;
        begin
            hex2asc = (h < 10) ? (h + 8'h30) : (h + 8'h37);
        end
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= ST_IDLE;
            tx_start  <= 1'b0;
            byte_cnt  <= 5'd0;
            mode      <= MODE_PC;
        end else begin
            tx_start <= 1'b0;

            case (state)
            ST_IDLE: begin
                byte_cnt <= 5'd0;
                if (pc_inst_trigger) begin
                    mode <= MODE_PC;
                    send_buf <= {
                        hex2asc(debug_pc[31:28]),  hex2asc(debug_pc[27:24]),
                        hex2asc(debug_pc[23:20]),  hex2asc(debug_pc[19:16]),
                        hex2asc(debug_pc[15:12]),  hex2asc(debug_pc[11:8]),
                        hex2asc(debug_pc[7:4]),    hex2asc(debug_pc[3:0]),
                        8'h20,
                        hex2asc(debug_instruction[31:28]), hex2asc(debug_instruction[27:24]),
                        hex2asc(debug_instruction[23:20]), hex2asc(debug_instruction[19:16]),
                        hex2asc(debug_instruction[15:12]), hex2asc(debug_instruction[11:8]),
                        hex2asc(debug_instruction[7:4]),   hex2asc(debug_instruction[3:0]),
                        8'h0D, 8'h0A
                    };
                    state <= ST_SEND;
                end else if (reg_trigger) begin
                    mode <= MODE_REG;
                    send_buf <= {
                        8'h78,
                        hex2asc({3'b000, debug_reg_addr[4]}),
                        hex2asc(debug_reg_addr[3:0]),
                        8'h20,
                        hex2asc(debug_reg_data[31:28]), hex2asc(debug_reg_data[27:24]),
                        hex2asc(debug_reg_data[23:20]), hex2asc(debug_reg_data[19:16]),
                        hex2asc(debug_reg_data[15:12]), hex2asc(debug_reg_data[11:8]),
                        hex2asc(debug_reg_data[7:4]),   hex2asc(debug_reg_data[3:0]),
                        8'h0D, 8'h0A,
                        {48{1'b0}}
                    };
                    state <= ST_SEND;
                end else if (alu_trigger) begin
                    mode <= MODE_ALU;
                    send_buf <= {
                        hex2asc(debug_alu_result[31:28]), hex2asc(debug_alu_result[27:24]),
                        hex2asc(debug_alu_result[23:20]), hex2asc(debug_alu_result[19:16]),
                        hex2asc(debug_alu_result[15:12]), hex2asc(debug_alu_result[11:8]),
                        hex2asc(debug_alu_result[7:4]),   hex2asc(debug_alu_result[3:0]),
                        8'h0D, 8'h0A,
                        {72{1'b0}}
                    };
                    state <= ST_SEND;
                end
            end

            ST_SEND: begin
                if (!tx_busy) begin
                    tx_data  <= send_buf[BUF_WIDTH-1 : BUF_WIDTH-8];
                    tx_start <= 1'b1;
                    send_buf <= {send_buf[BUF_WIDTH-9:0], 8'h00};
                    if (byte_cnt == max_len(mode)-1) begin
                        state    <= ST_IDLE;
                        byte_cnt <= 5'd0;
                    end else begin
                        byte_cnt <= byte_cnt + 1'b1;
                        state    <= ST_WAIT;
                    end
                end
            end
            
            ST_WAIT: begin
                if (!tx_busy)
                    state <= ST_SEND;
            end
            default: state <= ST_IDLE;
            endcase
        end
    end
endmodule
module DebugUARTController (
    input             clk,
    input             reset,

    // button pulses (1-cycle, 디바운스·싱글샷 완료된 신호)
    input             pc_inst_trigger,   // BTN-DOWN
    input             reg_trigger,       // BTN-LEFT
    input             result_trigger,       // BTN-RIGHT

    // debug data from core
    input      [31:0] debug_pc,
    input      [31:0] debug_instruction,
    input      [4:0]  debug_reg_addr,    // 실제 쓰기 대상 레지스터 번호
    input      [31:0] debug_reg_data,
    // input      [31:0] debug_alu_result,
    input      [63:0] final_cycles,
    input      [63:0] final_instructions,

    // UART interface
    input             tx_busy,
    output reg        tx_start,
    output reg [7:0]  tx_data
);
    // ------------------------------------------------------------
    // localparams
    // ------------------------------------------------------------
    localparam ST_IDLE  = 2'd0,
               ST_SEND  = 2'd1,
               ST_WAIT  = 2'd2;

    localparam MODE_PC  = 2'd0;   // PC + INST (19B)
    localparam MODE_REG = 2'd1;   // xNN + REG  (13B)
    localparam MODE_ALU = 2'd2;   // ALU RES    (10B)
    localparam MODE_CSR = 2'd3;

    // 각 모드별 전송 길이
    function [5:0] max_len;
        input [1:0] mode;
        begin
            case(mode)
            MODE_PC : max_len = 19;  // 152 bit = 19 Bytes
            MODE_REG: max_len = 13;  // 104 bit = 13 Bytes
            MODE_ALU: max_len = 10;  // 80  bit = 10 Bytes
            MODE_CSR: max_len = 40;  // Cycles + Instructions = 40 Bytes
            default : max_len = 19;
            endcase
        end
    endfunction

    localparam BUF_WIDTH = 40 * 8;   // 320bit buffer

    // ------------------------------------------------------------
    // registers
    // ------------------------------------------------------------
    reg [1:0]          state;
    reg [1:0]          mode;          // 현재 전송 모드
    reg [5:0]          byte_cnt;      // 0 … max_len-1
    reg [BUF_WIDTH-1:0]send_buf;      // 시프트 버퍼 (MSB 먼저 송신)

    // ------------------------------------------------------------
    // HEX → ASCII 함수
    // ------------------------------------------------------------
    function [7:0] hex2asc;
        input [3:0] h;
        begin
            hex2asc = (h < 10) ? (h + 8'h30) : (h + 8'h37);
        end
    endfunction

    // ------------------------------------------------------------
    // main FSM
    // ------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= ST_IDLE;
            tx_start  <= 1'b0;
            byte_cnt  <= 5'd0;
            mode      <= MODE_PC;
        end
        else begin
            //------------------------------------------------------
            // 기본값
            //------------------------------------------------------
            tx_start <= 1'b0;

            case (state)
            //================================================== IDLE
            ST_IDLE: begin
                byte_cnt <= 5'd0;

                //--------------------------------------------------
                // 1) BTN-DOWN  : PC + INST
                //--------------------------------------------------
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
                end
                //--------------------------------------------------
                // 2) BTN-LEFT : xNN + REG VALUE
                //--------------------------------------------------
                else if (reg_trigger) begin
                    mode <= MODE_REG;
                    send_buf <= {
                        8'h78,                                         // 'x'
                        hex2asc({3'b000, debug_reg_addr[4]}),          // upper hex digit
                        hex2asc(debug_reg_addr[3:0]),                  // lower hex digit
                        8'h20,
                        hex2asc(debug_reg_data[31:28]), hex2asc(debug_reg_data[27:24]),
                        hex2asc(debug_reg_data[23:20]), hex2asc(debug_reg_data[19:16]),
                        hex2asc(debug_reg_data[15:12]), hex2asc(debug_reg_data[11:8]),
                        hex2asc(debug_reg_data[7:4]),   hex2asc(debug_reg_data[3:0]),
                        8'h0D, 8'h0A,
                        {48{1'b0}}                       // 남는 비트 48 → 0으로 패딩
                    };
                    state <= ST_SEND;
                end
                //--------------------------------------------------
                // 3) BTN-RIGHT : mcycle, minstret output
                //--------------------------------------------------
                else if (result_trigger) begin
                    mode <= MODE_CSR;
                    send_buf <= {
                        // "Cycles: "
                        8'h43,8'h79,8'h63,8'h6C,8'h65,8'h73,8'h3A,8'h20,
                        // 16 hex of mcycle[63:0] (MSB 먼저)
                        hex2asc(final_cycles[63:60]), hex2asc(final_cycles[59:56]),
                        hex2asc(final_cycles[55:52]), hex2asc(final_cycles[51:48]),
                        hex2asc(final_cycles[47:44]), hex2asc(final_cycles[43:40]),
                        hex2asc(final_cycles[39:36]), hex2asc(final_cycles[35:32]),
                        hex2asc(final_cycles[31:28]), hex2asc(final_cycles[27:24]),
                        hex2asc(final_cycles[23:20]), hex2asc(final_cycles[19:16]),
                        hex2asc(final_cycles[15:12]), hex2asc(final_cycles[11:8]),
                        hex2asc(final_cycles[7:4]),   hex2asc(final_cycles[3:0]),
                        8'h0D, 8'h0A,                       // "\r\n"
                        // "Instr: "
                        8'h49,8'h6E,8'h73,8'h74,8'h72,8'h3A,8'h20,
                        // 16 hex of minstret[63:0]
                        hex2asc(final_instructions[63:60]), hex2asc(final_instructions[59:56]),
                        hex2asc(final_instructions[55:52]), hex2asc(final_instructions[51:48]),
                        hex2asc(final_instructions[47:44]), hex2asc(final_instructions[43:40]),
                        hex2asc(final_instructions[39:36]), hex2asc(final_instructions[35:32]),
                        hex2asc(final_instructions[31:28]), hex2asc(final_instructions[27:24]),
                        hex2asc(final_instructions[23:20]), hex2asc(final_instructions[19:16]),
                        hex2asc(final_instructions[15:12]), hex2asc(final_instructions[11:8]),
                        hex2asc(final_instructions[7:4]),   hex2asc(final_instructions[3:0]),
                        8'h0D, 8'h0A                     // "\r\n"
                        // 남는 비트는 자동 0 (상위 unused 자리)
                    };
                    state <= ST_SEND;
                end
            end

            //================================================= SEND
            ST_SEND: begin
                if (!tx_busy) begin
                    // MSByte 전송
                    tx_data  <= send_buf[BUF_WIDTH-1 : BUF_WIDTH-8];
                    tx_start <= 1'b1;
                    // 8비트 왼쪽 시프트
                    send_buf <= {send_buf[BUF_WIDTH-9:0], 8'h00};

                    if (byte_cnt == max_len(mode)-1) begin
                        state    <= ST_IDLE;
                        byte_cnt <= 5'd0;
                    end
                    else begin
                        byte_cnt <= byte_cnt + 1'b1;
                        state    <= ST_WAIT;
                    end
                end
            end

            //================================================= WAIT
            ST_WAIT: begin
                if (!tx_busy)
                    state <= ST_SEND;
            end

            default: state <= ST_IDLE;
            endcase
        end
    end
endmodule

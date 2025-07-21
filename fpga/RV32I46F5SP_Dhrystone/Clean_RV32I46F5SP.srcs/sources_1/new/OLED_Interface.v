// OLED Interface Module for SSD1306 128x32 Display (PmodOLED)
module OLEDInterface (
    input clk,                      // 50MHz system clock
    input reset,
    
    // CPU state input
    input [31:0] pc_value,          // current PC value
    input [31:0] instruction,       // current instruction
    input [31:0] register_value,    // selected Register value
    input [4:0] selected_register,  // selected register number (0-31)
    input [1:0] display_mode,       
    input update_display,           // Display update signal
    
    // OLED SPI interface
    output oled_sclk,               // SPI Clock
    output oled_sdin,               // SPI Data (MOSI)
    output oled_dc,                 // Data/Command select
    output oled_res,                // Reset (active low)
    output oled_vbat,               // VBAT enable (active low)
    output oled_vdd,                // VDD enable (active low)
    
    // state output
    output ready                    // initialization complete and ready to go
);

    // FSM
    localparam [3:0] 
        S_POWER_UP    = 4'd0,
        S_RESET       = 4'd1,
        S_INIT_CMD    = 4'd2,
        S_READY       = 4'd3,
        S_UPDATE      = 4'd4,
        S_RENDER      = 4'd5,
        S_SEND_DATA   = 4'd6,
        S_WAIT        = 4'd7;

    // Display modes
    localparam [1:0]
        MODE_PC_INST    = 2'd0,     // PC & Instructions
        MODE_REGISTER   = 2'd1,     // Display Register value
        MODE_PIPELINE   = 2'd2,     // Display pipeline states
        MODE_DEBUG      = 2'd3;     // Display debug informations

    // FSM
    reg [3:0] state, next_state;
    
    // Timing control
    reg [23:0] delay_counter;       // 최대 1ms 지연용
    reg [23:0] init_delay_counter;       // 최대 1ms 지연용
    reg [7:0] init_step;            // 초기화 단계
    reg [9:0] update_step;          // 업데이트 단계 (더 큰 범위)
    
    // SPI 제어
    reg [7:0] spi_data;
    reg spi_start;
    reg spi_dc_select;              // 0: Command, 1: Data
    reg spi_done_reg;
    wire spi_done;
    
    // SPI 클럭 분주기 (50MHz -> 5MHz)
    reg [3:0] spi_clk_div;
    
    // 출력 제어
    reg oled_sck_reg, oled_sdi_reg, oled_dc_reg;
    reg oled_res_reg, oled_vbat_reg, oled_vdd_reg;
    reg ready_reg;
    
    // 초기화 instruction ROM
    reg [7:0] init_commands [0:31];
    
    // 디스플레이 버퍼 (4 lines x 21 characters = 84 chars total)
    reg [7:0] text_buffer [0:83];   // 텍스트 버퍼 (ASCII codes)
    reg [7:0] frame_buffer [0:511]; // 픽셀 버퍼 (128x32 = 4096 bits = 512 bytes)
    
    // 텍스트 렌더링 상태
    reg [6:0] render_char_addr;     // current 렌더링중인 문자 주소
    reg [2:0] render_row;           // current 렌더링중인 문자의 행 (0-7)
    reg [4:0] render_col;           // current 렌더링중인 문자의 열 (0-20)
    reg [1:0] render_line;          // current 렌더링중인 라인 (0-3)
    reg render_complete;            // 렌더링 완료 플래그
    
    // OLED 전송 상태
    reg [8:0] oled_send_addr;       // 전송할 프레임 버퍼 주소
    reg oled_send_complete;         // OLED 전송 완료 플래그
    reg send_addr_set;              // 주소 설정 완료 플래그
    reg [2:0] addr_cmd_step;        // 주소 설정 단계
    
    // 문자 ROM (6x8 폰트, ASCII 32-127)
    reg [7:0] char_rom [0:767]; // 96 characters x 8 bytes each
    
    // SPI 제어 상태
    reg [3:0] spi_state;
    reg [7:0] spi_shift_reg;
    reg [2:0] spi_bit_count;
    
    // 초기화 instruction들
    initial begin
        init_commands[0]  = 8'hAE; // Display OFF
        init_commands[1]  = 8'hD5; // Set Display Clock Divide Ratio
        init_commands[2]  = 8'h80; // Default ratio
        init_commands[3]  = 8'hA8; // Set Multiplex Ratio
        init_commands[4]  = 8'h1F; // 32 rows
        init_commands[5]  = 8'hD3; // Set Display Offset
        init_commands[6]  = 8'h00; // No offset
        init_commands[7]  = 8'h40; // Set Start Line
        init_commands[8]  = 8'h8D; // Charge Pump Setting
        init_commands[9]  = 8'h14; // Enable charge pump
        init_commands[10] = 8'h20; // Set Memory Addressing Mode
        init_commands[11] = 8'h00; // Horizontal addressing mode
        init_commands[12] = 8'hA1; // Set Segment Re-map
        init_commands[13] = 8'hC8; // Set COM Output Scan Direction
        init_commands[14] = 8'hDA; // Set COM Pins Hardware Configuration
        init_commands[15] = 8'h02; // Alternative COM pin config
        init_commands[16] = 8'h81; // Set Contrast Control
        init_commands[17] = 8'h8F; // Contrast value
        init_commands[18] = 8'hD9; // Set Pre-charge Period
        init_commands[19] = 8'hF1; // Pre-charge value
        init_commands[20] = 8'hDB; // Set VCOMH Deselect Level
        init_commands[21] = 8'h40; // VCOMH value
        init_commands[22] = 8'hA4; // Entire Display ON (normal)
        init_commands[23] = 8'hA6; // Set Normal Display
        init_commands[24] = 8'hAF; // Display ON
        init_commands[25] = 8'h21; // Set Column Address
        init_commands[26] = 8'h00; // Start column = 0
        init_commands[27] = 8'h7F; // End column = 127
        init_commands[28] = 8'h22; // Set Page Address
        init_commands[29] = 8'h00; // Start page = 0
        init_commands[30] = 8'h03; // End page = 3
        init_commands[31] = 8'h00; // Dummy
    end
    
    integer i;
    // 문자 ROM 초기화 (ASCII 32-127)
    initial begin
        // 모든 문자를 0으로 초기화
        for (i = 0; i < 768; i = i + 1) begin
            char_rom[i] = 8'h00;
        end
        
        // ASCII 32: Space (all zeros)
        // 이미 0으로 초기화됨
        
        // ASCII 48-57: '0'-'9'
        // '0' (ASCII 48)
        char_rom[128] = 8'b00111100; char_rom[129] = 8'b01100110; char_rom[130] = 8'b01101110; char_rom[131] = 8'b01111110;
        char_rom[132] = 8'b01110110; char_rom[133] = 8'b01100110; char_rom[134] = 8'b00111100; char_rom[135] = 8'b00000000;
        
        // '1' (ASCII 49)
        char_rom[136] = 8'b00011000; char_rom[137] = 8'b00111000; char_rom[138] = 8'b00011000; char_rom[139] = 8'b00011000;
        char_rom[140] = 8'b00011000; char_rom[141] = 8'b00011000; char_rom[142] = 8'b01111110; char_rom[143] = 8'b00000000;
        
        // '2' (ASCII 50)
        char_rom[144] = 8'b00111100; char_rom[145] = 8'b01100110; char_rom[146] = 8'b00000110; char_rom[147] = 8'b00001100;
        char_rom[148] = 8'b00110000; char_rom[149] = 8'b01100000; char_rom[150] = 8'b01111110; char_rom[151] = 8'b00000000;
        
        // '3' (ASCII 51)
        char_rom[152] = 8'b00111100; char_rom[153] = 8'b01100110; char_rom[154] = 8'b00000110; char_rom[155] = 8'b00011100;
        char_rom[156] = 8'b00000110; char_rom[157] = 8'b01100110; char_rom[158] = 8'b00111100; char_rom[159] = 8'b00000000;
        
        // '4' (ASCII 52)
        char_rom[160] = 8'b00001100; char_rom[161] = 8'b00011100; char_rom[162] = 8'b00111100; char_rom[163] = 8'b01101100;
        char_rom[164] = 8'b01111110; char_rom[165] = 8'b00001100; char_rom[166] = 8'b00001100; char_rom[167] = 8'b00000000;
        
        // '5' (ASCII 53)
        char_rom[168] = 8'b01111110; char_rom[169] = 8'b01100000; char_rom[170] = 8'b01111100; char_rom[171] = 8'b00000110;
        char_rom[172] = 8'b00000110; char_rom[173] = 8'b01100110; char_rom[174] = 8'b00111100; char_rom[175] = 8'b00000000;
        
        // '6' (ASCII 54)
        char_rom[176] = 8'b00111100; char_rom[177] = 8'b01100110; char_rom[178] = 8'b01100000; char_rom[179] = 8'b01111100;
        char_rom[180] = 8'b01100110; char_rom[181] = 8'b01100110; char_rom[182] = 8'b00111100; char_rom[183] = 8'b00000000;
        
        // '7' (ASCII 55)
        char_rom[184] = 8'b01111110; char_rom[185] = 8'b00000110; char_rom[186] = 8'b00001100; char_rom[187] = 8'b00011000;
        char_rom[188] = 8'b00110000; char_rom[189] = 8'b00110000; char_rom[190] = 8'b00110000; char_rom[191] = 8'b00000000;
        
        // '8' (ASCII 56)
        char_rom[192] = 8'b00111100; char_rom[193] = 8'b01100110; char_rom[194] = 8'b01100110; char_rom[195] = 8'b00111100;
        char_rom[196] = 8'b01100110; char_rom[197] = 8'b01100110; char_rom[198] = 8'b00111100; char_rom[199] = 8'b00000000;
        
        // '9' (ASCII 57)
        char_rom[200] = 8'b00111100; char_rom[201] = 8'b01100110; char_rom[202] = 8'b01100110; char_rom[203] = 8'b00111110;
        char_rom[204] = 8'b00000110; char_rom[205] = 8'b01100110; char_rom[206] = 8'b00111100; char_rom[207] = 8'b00000000;
        
        // ASCII 58: ':' (colon)
        char_rom[208] = 8'b00000000; char_rom[209] = 8'b00011000; char_rom[210] = 8'b00011000; char_rom[211] = 8'b00000000;
        char_rom[212] = 8'b00000000; char_rom[213] = 8'b00011000; char_rom[214] = 8'b00011000; char_rom[215] = 8'b00000000;
        
        // ASCII 65-70: 'A'-'F'
        // 'A' (ASCII 65)
        char_rom[264] = 8'b00111100; char_rom[265] = 8'b01100110; char_rom[266] = 8'b01100110; char_rom[267] = 8'b01111110;
        char_rom[268] = 8'b01100110; char_rom[269] = 8'b01100110; char_rom[270] = 8'b01100110; char_rom[271] = 8'b00000000;
        
        // 'B' (ASCII 66)
        char_rom[272] = 8'b01111100; char_rom[273] = 8'b01100110; char_rom[274] = 8'b01100110; char_rom[275] = 8'b01111100;
        char_rom[276] = 8'b01100110; char_rom[277] = 8'b01100110; char_rom[278] = 8'b01111100; char_rom[279] = 8'b00000000;
        
        // 'C' (ASCII 67)
        char_rom[280] = 8'b00111100; char_rom[281] = 8'b01100110; char_rom[282] = 8'b01100000; char_rom[283] = 8'b01100000;
        char_rom[284] = 8'b01100000; char_rom[285] = 8'b01100110; char_rom[286] = 8'b00111100; char_rom[287] = 8'b00000000;
        
        // 'D' (ASCII 68)
        char_rom[288] = 8'b01111000; char_rom[289] = 8'b01101100; char_rom[290] = 8'b01100110; char_rom[291] = 8'b01100110;
        char_rom[292] = 8'b01100110; char_rom[293] = 8'b01101100; char_rom[294] = 8'b01111000; char_rom[295] = 8'b00000000;
        
        // 'E' (ASCII 69)
        char_rom[296] = 8'b01111110; char_rom[297] = 8'b01100000; char_rom[298] = 8'b01100000; char_rom[299] = 8'b01111100;
        char_rom[300] = 8'b01100000; char_rom[301] = 8'b01100000; char_rom[302] = 8'b01111110; char_rom[303] = 8'b00000000;
        
        // 'F' (ASCII 70)
        char_rom[304] = 8'b01111110; char_rom[305] = 8'b01100000; char_rom[306] = 8'b01100000; char_rom[307] = 8'b01111100;
        char_rom[308] = 8'b01100000; char_rom[309] = 8'b01100000; char_rom[310] = 8'b01100000; char_rom[311] = 8'b00000000;
        
        // 더 많은 문자들 추가 가능 (I, N, S, T, P, x 등)
        // ASCII 73: 'I'
        char_rom[328] = 8'b01111110; char_rom[329] = 8'b00011000; char_rom[330] = 8'b00011000; char_rom[331] = 8'b00011000;
        char_rom[332] = 8'b00011000; char_rom[333] = 8'b00011000; char_rom[334] = 8'b01111110; char_rom[335] = 8'b00000000;
        
        // ASCII 78: 'N'
        char_rom[368] = 8'b01100110; char_rom[369] = 8'b01110110; char_rom[370] = 8'b01111110; char_rom[371] = 8'b01101110;
        char_rom[372] = 8'b01100110; char_rom[373] = 8'b01100110; char_rom[374] = 8'b01100110; char_rom[375] = 8'b00000000;
        
        // ASCII 80: 'P'
        char_rom[384] = 8'b01111100; char_rom[385] = 8'b01100110; char_rom[386] = 8'b01100110; char_rom[387] = 8'b01111100;
        char_rom[388] = 8'b01100000; char_rom[389] = 8'b01100000; char_rom[390] = 8'b01100000; char_rom[391] = 8'b00000000;
        
        // ASCII 83: 'S'
        char_rom[408] = 8'b00111100; char_rom[409] = 8'b01100110; char_rom[410] = 8'b01100000; char_rom[411] = 8'b00111100;
        char_rom[412] = 8'b00000110; char_rom[413] = 8'b01100110; char_rom[414] = 8'b00111100; char_rom[415] = 8'b00000000;
        
        // ASCII 84: 'T'
        char_rom[416] = 8'b01111110; char_rom[417] = 8'b00011000; char_rom[418] = 8'b00011000; char_rom[419] = 8'b00011000;
        char_rom[420] = 8'b00011000; char_rom[421] = 8'b00011000; char_rom[422] = 8'b00011000; char_rom[423] = 8'b00000000;
        
        // ASCII 120: 'x'
        char_rom[704] = 8'b00000000; char_rom[705] = 8'b01100110; char_rom[706] = 8'b00111100; char_rom[707] = 8'b00011000;
        char_rom[708] = 8'b00111100; char_rom[709] = 8'b01100110; char_rom[710] = 8'b00000000; char_rom[711] = 8'b00000000;
    end
    
    // 메인 상태 머신
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_POWER_UP;
            delay_counter <= 0;
            init_delay_counter <= 0;
            init_step <= 0;
            update_step <= 0;
            oled_res_reg <= 1'b0;
            oled_vbat_reg <= 1'b1;
            oled_vdd_reg <= 1'b1;
            ready_reg <= 1'b0;
            spi_start <= 1'b0;
            render_complete <= 1'b0;
            oled_send_complete <= 1'b0;
            send_addr_set <= 1'b0;
            addr_cmd_step <= 0;
            
            // 렌더링 상태 초기화
            render_char_addr <= 0;
            render_row <= 0;
            render_col <= 0;
            render_line <= 0;
        end else begin
            case (state)
                S_POWER_UP: begin
                    // VDD 먼저 켜기
                    oled_vdd_reg <= 1'b0;    // VDD ON (active low)
                    
                    if (delay_counter >= 24'd500000) begin  // 10ms 대기 (1ms에서 증가)
                        oled_vbat_reg <= 1'b0;  // VBAT ON
                        delay_counter <= 0;
                        state <= S_RESET;
                    end else begin
                        delay_counter <= delay_counter + 1;
                    end
                end
                
                // S_RESET 상태 지연 시간 증가
                S_RESET: begin
                    // Reset pulse
                    if (delay_counter < 24'd50000) begin    // 1ms reset pulse
                        oled_res_reg <= 1'b0;  // Reset active
                    end else begin
                        oled_res_reg <= 1'b1;  // Reset inactive
                    end
                    
                    if (delay_counter >= 24'd1000000) begin  // 20ms 대기 (4ms에서 증가)
                        delay_counter <= 0;
                        state <= S_INIT_CMD;
                    end else begin
                        delay_counter <= delay_counter + 1;
                    end
                end
                
                S_INIT_CMD: begin
                    // 초기화 커맨드 전송
                    if (init_step < 31) begin
                        if (init_delay_counter < 24'd5000) begin  // 100us 지연 (각 명령어 사이)
                            init_delay_counter <= init_delay_counter + 1;
                        end else if (!spi_start && spi_done_reg) begin  // SPI가 준비되었을 때만
                            spi_data <= init_commands[init_step];
                            spi_dc_select <= 1'b0;  // Command mode
                            spi_start <= 1'b1;
                            init_delay_counter <= 0;
                        end else if (spi_start && !spi_done_reg) begin
                            spi_start <= 1'b0;  // 전송 시작 후 start 신호 해제
                        end else if (!spi_start && spi_done_reg && init_step < 31) begin
                            init_step <= init_step + 1;  // 다음 커맨드로
                        end
                    end else begin
                        state <= S_READY;
                        ready_reg <= 1'b1;
                    end
                end
                
                S_READY: begin
                    ready_reg <= 1'b1;
                    if (update_display) begin
                        state <= S_UPDATE;
                        update_step <= 0;
                    end
                end
                
                S_UPDATE: begin
                    // 디스플레이 내용 업데이트
                    format_display_content();
                    update_step <= update_step + 1;
                    if (update_step >= 1) begin
                        state <= S_RENDER;
                        render_complete <= 1'b0;
                        render_char_addr <= 0;
                        render_row <= 0;
                        render_col <= 0;
                        render_line <= 0;
                    end
                end
                
                S_RENDER: begin
                    // 텍스트를 픽셀로 렌더링
                    if (!render_complete) begin
                       render_text_step();
                    end else begin
                        state <= S_SEND_DATA;
                        oled_send_addr <= 0;
                        oled_send_complete <= 1'b0;
                        send_addr_set <= 1'b0;
                        addr_cmd_step <= 0;
                    end
                end
                
                S_SEND_DATA: begin
                    // 프레임 버퍼를 OLED로 전송
                    if (!send_addr_set) begin
                        // 주소 설정 커맨드 전송
                        case (addr_cmd_step)
                            0: begin
                                if (!spi_start && spi_done_reg) begin
                                    spi_data <= 8'h21;  // Set Column Address
                                    spi_dc_select <= 1'b0;
                                    spi_start <= 1'b1;
                                end else if (spi_start && !spi_done_reg) begin
                                    spi_start <= 1'b0;
                                    addr_cmd_step <= 1;
                                end
                            end
                            1: begin
                                if (!spi_start && spi_done_reg) begin
                                    spi_data <= 8'h00;  // Start column = 0
                                    spi_dc_select <= 1'b0;
                                    spi_start <= 1'b1;
                                end else if (spi_start && !spi_done_reg) begin
                                    spi_start <= 1'b0;
                                    addr_cmd_step <= 2;
                                end
                            end
                            2: begin
                                if (!spi_start && spi_done_reg) begin
                                    spi_data <= 8'h7F;  // End column = 127
                                    spi_dc_select <= 1'b0;
                                    spi_start <= 1'b1;
                                end else if (spi_start && !spi_done_reg) begin
                                    spi_start <= 1'b0;
                                    addr_cmd_step <= 3;
                                end
                            end
                            3: begin
                                if (!spi_start && spi_done_reg) begin
                                    spi_data <= 8'h22;  // Set Page Address
                                    spi_dc_select <= 1'b0;
                                    spi_start <= 1'b1;
                                end else if (spi_start && !spi_done_reg) begin
                                    spi_start <= 1'b0;
                                    addr_cmd_step <= 4;
                                end
                            end
                            4: begin
                                if (!spi_start && spi_done_reg) begin
                                    spi_data <= 8'h00;  // Start page = 0
                                    spi_dc_select <= 1'b0;
                                    spi_start <= 1'b1;
                                end else if (spi_start && !spi_done_reg) begin
                                    spi_start <= 1'b0;
                                    addr_cmd_step <= 5;
                                end
                            end
                            5: begin
                                if (!spi_start && spi_done_reg) begin
                                    spi_data <= 8'h03;  // End page = 3
                                    spi_dc_select <= 1'b0;
                                    spi_start <= 1'b1;
                                end else if (spi_start && !spi_done_reg) begin
                                    spi_start <= 1'b0;
                                    addr_cmd_step <= 6;
                                end
                            end
                            6: begin
                                if (spi_done_reg) begin
                                    send_addr_set <= 1'b1;
                                end
                            end
                        endcase
                    end else if (!oled_send_complete) begin
                        send_frame_step();
                    end else begin
                        state <= S_READY;
                    end
                end
                
                default: begin
                    state <= S_POWER_UP;
                end
            endcase
        end
    end
    
    // 다음 상태 결정 로직
    always @(*) begin
        next_state = state;
        case (state)
            S_POWER_UP: 
                if (delay_counter >= 20'd50000)
                    next_state = S_RESET;
            
            S_RESET:
                if (delay_counter >= 20'd200000)
                    next_state = S_INIT_CMD;
            
            S_INIT_CMD:
                if (init_step >= 31 && spi_done)
                    next_state = S_READY;
            
            S_READY:
                if (update_display)
                    next_state = S_UPDATE;
            
            S_UPDATE:
                if (update_step >= 1)
                    next_state = S_RENDER;
            
            S_RENDER:
                if (render_complete)
                    next_state = S_SEND_DATA;
            
            S_SEND_DATA:
                if (oled_send_complete)
                    next_state = S_READY;
            
            default:
                next_state = S_POWER_UP;
        endcase
    end
    
        // SPI 전송 로직 (5MHz로 분주)
        always @(posedge clk or posedge reset) begin
        if (reset) begin
            spi_state <= 0;
            spi_bit_count <= 0;
            spi_done_reg <= 1'b1;
            oled_sck_reg <= 1'b0;
            oled_sdi_reg <= 1'b0;
            oled_dc_reg <= 1'b0;
            spi_clk_div <= 0;
        end else begin
            spi_clk_div <= spi_clk_div + 1;
            if (spi_clk_div == 4'd9) begin  // 50MHz / 10 = 5MHz (10MHz에서 5MHz로 변경)
                spi_clk_div <= 0;
                
                case (spi_state)
                    0: begin // Idle
                        spi_done_reg <= 1'b1;
                        if (spi_start) begin
                            spi_shift_reg <= spi_data;
                            oled_dc_reg <= spi_dc_select;
                            spi_bit_count <= 0;
                            spi_state <= 1;
                            spi_done_reg <= 1'b0;
                        end
                    end
                    
                    1: begin // Clock low, setup data
                        oled_sck_reg <= 1'b0;
                        oled_sdi_reg <= spi_shift_reg[7];
                        spi_state <= 2;
                    end
                    
                    2: begin // Clock high, shift data
                        oled_sck_reg <= 1'b1;
                        spi_shift_reg <= {spi_shift_reg[6:0], 1'b0};
                        if (spi_bit_count == 7) begin
                            spi_done_reg <= 1'b1;
                            spi_state <= 0;
                        end else begin
                            spi_bit_count <= spi_bit_count + 1;
                            spi_state <= 1;
                        end
                    end
                    
                    default: spi_state <= 0;
                endcase
            end
        end
    end
    
    // 디스플레이 내용 포맷팅
    task format_display_content;
        integer i;
        begin
            // 먼저 텍스트 버퍼를 공백으로 초기화
            for (i = 0; i < 84; i = i + 1) begin
                text_buffer[i] = 8'h20; // 공백
            end
            
            case (display_mode)
                MODE_PC_INST: begin
                    format_pc_instruction();
                end
                
                MODE_REGISTER: begin
                    format_register_value();
                end
                
                MODE_PIPELINE: begin
                    format_pipeline_status();
                end
                
                MODE_DEBUG: begin
                    format_debug_info();
                end
            endcase
        end
    endtask
    
    // PC와 instruction 포맷팅 (수정된 버전)
    task format_pc_instruction;
        integer i;
        begin
            // 첫 번째 라인: "PC: xxxxxxxx"
            text_buffer[0] = 8'h50;   // 'P'
            text_buffer[1] = 8'h43;   // 'C'
            text_buffer[2] = 8'h3A;   // ':'
            text_buffer[3] = 8'h20;   // 공백
            
            // PC value을 16진수로 변환
            for (i = 0; i < 8; i = i + 1) begin
                text_buffer[4 + i] = hex_to_ascii(pc_value[31-i*4 -: 4]);
            end
            
            // 나머지는 공백으로
            for (i = 12; i < 21; i = i + 1) begin
                text_buffer[i] = 8'h20;
            end
            
            // 두 번째 라인: "INST: xxxxxxxx"
            text_buffer[21] = 8'h49;  // 'I'
            text_buffer[22] = 8'h4E;  // 'N'
            text_buffer[23] = 8'h53;  // 'S'
            text_buffer[24] = 8'h54;  // 'T'
            text_buffer[25] = 8'h3A;  // ':'
            text_buffer[26] = 8'h20;  // 공백
            
            // instruction value을 16진수로 변환
            for (i = 0; i < 8; i = i + 1) begin
                text_buffer[27 + i] = hex_to_ascii(instruction[31-i*4 -: 4]);
            end
            
            // 나머지 라인은 공백
            for (i = 35; i < 84; i = i + 1) begin
                text_buffer[i] = 8'h20;
            end
        end
    endtask
    
    // 레지스터 값 포맷팅
    task format_register_value;
        integer i;
        begin
            // "Rxx: xxxxxxxx" 형식
            text_buffer[0] = 8'h52;   // 'R'
            text_buffer[1] = hex_to_ascii(selected_register[4:1]);
            text_buffer[2] = hex_to_ascii({3'b0, selected_register[0]});
            text_buffer[3] = 8'h3A;   // ':'
            text_buffer[4] = 8'h20;   // 공백
            
            // 레지스터 값을 16진수로 변환
            for (i = 0; i < 8; i = i + 1) begin
                text_buffer[5 + i] = hex_to_ascii(register_value[31-i*4 -: 4]);
            end
            
            // 나머지는 공백
            for (i = 13; i < 84; i = i + 1) begin
                text_buffer[i] = 8'h20;
            end
        end
    endtask
    
    // 파이프라인 상태 포맷팅
    task format_pipeline_status;
        begin
            // TODO: 파이프라인 상태 표시 구현
            text_buffer[0] = 8'h50;   // 'P'
            text_buffer[1] = 8'h49;   // 'I'
            text_buffer[2] = 8'h50;   // 'P'
            text_buffer[3] = 8'h45;   // 'E'
        end
    endtask
    
    // 디버그 정보 포맷팅
    task format_debug_info;
        begin
            // TODO: 디버그 정보 표시 구현
            text_buffer[0] = 8'h44;   // 'D'
            text_buffer[1] = 8'h45;   // 'E'
            text_buffer[2] = 8'h42;   // 'B'
            text_buffer[3] = 8'h55;   // 'U'
            text_buffer[4] = 8'h47;   // 'G'
        end
    endtask
    
    // 텍스트를 픽셀로 렌더링하는 스텝 수정
    task render_text_step;
        reg [7:0] char_code;
        reg [9:0] char_rom_addr;
        reg [7:0] char_pattern;
        reg [8:0] fb_addr;
        reg [2:0] pixel_col;
        begin
            // 현재 문자 가져오기
            char_code = text_buffer[render_char_addr];
            
            // 문자 ROM 주소 계산 (ASCII 코드에서 32를 뺀 값 * 8 + 행)
            if (char_code >= 32)
                char_rom_addr = ((char_code - 32) << 3) + render_row;
            else
                char_rom_addr = 0; // 공백 처리
            
            // 문자 패턴 가져오기
            char_pattern = char_rom[char_rom_addr];
            
            // 프레임 버퍼에 쓰기
            // SSD1306은 수직 바이트 모드: 각 바이트는 수직 8픽셀을 나타냄
            // 페이지(0-3) * 128 + 컬럼 위치
            fb_addr = (render_line * 128) + (render_col * 6);
            
            // 6픽셀 폭으로 문자 쓰기 (한 문자당 6컬럼 사용)
            if (fb_addr < 512) begin
                // 각 행의 데이터를 올바른 페이지와 비트 위치에 배치
                for (pixel_col = 0; pixel_col < 6; pixel_col = pixel_col + 1) begin
                    if (fb_addr + pixel_col < 512) begin
                        if (pixel_col < 5) begin
                            // 문자 데이터 (5픽셀 폭)
                            if (char_pattern[6-pixel_col])  // MSB부터 사용
                                frame_buffer[fb_addr + pixel_col][render_row] = 1'b1;
                            else
                                frame_buffer[fb_addr + pixel_col][render_row] = 1'b0;
                        end else begin
                            // 문자 사이 간격 (6번째 픽셀은 공백)
                            frame_buffer[fb_addr + pixel_col][render_row] = 1'b0;
                        end
                    end
                end
            end
            
            // 다음 행으로
            if (render_row < 7) begin
                render_row <= render_row + 1;
            end else begin
                render_row <= 0;
                
                // 다음 문자로
                if (render_col < 20) begin
                    render_col <= render_col + 1;
                    render_char_addr <= render_char_addr + 1;
                end else begin
                    render_col <= 0;
                    
                    // 다음 라인으로
                    if (render_line < 3) begin
                        render_line <= render_line + 1;
                        render_char_addr <= (render_line + 1) * 21; // 다음 라인의 시작
                    end else begin
                        render_complete <= 1'b1;
                    end
                end
            end
        end
    endtask
    
    // 초기 테스트 패턴 추가 (디버깅용)
    integer i;
    initial begin
        // 프레임 버퍼를 테스트 패턴으로 초기화
        for (i = 0; i < 512; i = i + 1) begin
            if (i < 128) 
                frame_buffer[i] = 8'hFF;  // 첫 페이지는 모두 켜기
            else if (i < 256)
                frame_buffer[i] = 8'hAA;  // 두 번째 페이지는 체커보드
            else if (i < 384)
                frame_buffer[i] = 8'h55;  // 세 번째 페이지는 반대 체커보드
            else
                frame_buffer[i] = 8'h0F;  // 네 번째 페이지는 아래쪽만
        end
    end
    
    // 프레임 버퍼를 OLED로 전송하는 스텝
    task send_frame_step;
        begin
            if (oled_send_addr < 512) begin
                if (!spi_start && spi_done_reg) begin
                    // 프레임 버퍼 데이터 전송
                    spi_data <= frame_buffer[oled_send_addr];
                    spi_dc_select <= 1'b1;  // Data mode
                    spi_start <= 1'b1;
                end else if (spi_start && !spi_done_reg) begin
                    spi_start <= 1'b0;
                end else if (!spi_start && spi_done_reg) begin
                    oled_send_addr <= oled_send_addr + 1;
                end
            end else begin
                oled_send_complete <= 1'b1;
            end
        end
    endtask
    
    // 16진수를 ASCII 문자로 변환하는 함수
    function [7:0] hex_to_ascii;
        input [3:0] hex_value;
        begin
            if (hex_value < 10)
                hex_to_ascii = hex_value + 8'h30; // '0' to '9' (ASCII 48-57)
            else
                hex_to_ascii = hex_value - 10 + 8'h41; // 'A' to 'F' (ASCII 65-70)
        end
    endfunction
    
    // 출력 할당
    assign oled_sclk = oled_sck_reg;
    assign oled_sdin = oled_sdi_reg;
    assign oled_dc = oled_dc_reg;
    assign oled_res = oled_res_reg;
    assign oled_vbat = oled_vbat_reg;
    assign oled_vdd = oled_vdd_reg;
    assign ready = ready_reg;
    assign spi_done = spi_done_reg;

endmodule
module UnifiedUARTController (
    input clk,
    input reset,
    
    // 버튼 입력 (btn_up만 사용)
    input btn_up,
    
    // MMIO 입력 (CPU에서)
    input [7:0] mmio_tx_data,
    input mmio_tx_start,
    
    // UART 출력 (UART_TX로)
    output tx_start,
    output [7:0] tx_data,
    
    // CPU 제어 출력
    output reg benchmark_start
);

    // ============================================================
    // 디바운싱 파라미터
    // ============================================================
    localparam DEBOUNCE_CYCLES = 20'd500000; // 10ms @ 50MHz

    // ============================================================
    // 버튼 동기화 및 디바운싱 레지스터
    // ============================================================
    reg [2:0] btn_sync;
    reg [19:0] debounce_counter;
    reg btn_stable;
    reg btn_prev;
    wire btn_rising_edge;

    // ============================================================
    // MMIO → UART 직접 연결 (ASCII 변환 불필요)
    // printf가 이미 ASCII 문자를 전송하므로 그대로 전달
    // ============================================================
    assign tx_start = mmio_tx_start;
    assign tx_data = mmio_tx_data;

    // ============================================================
    // 3단계 동기화 (메타스태빌리티 방지)
    // ============================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_sync <= 3'b0;
        end else begin
            btn_sync <= {btn_sync[1:0], btn_up};
        end
    end

    // ============================================================
    // 디바운싱 로직
    // ============================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            debounce_counter <= 20'b0;
            btn_stable <= 1'b0;
        end else begin
            if (btn_sync[2] != btn_stable) begin
                // 버튼 상태 변화 감지 시 카운터 증가
                if (debounce_counter < DEBOUNCE_CYCLES) begin
                    debounce_counter <= debounce_counter + 1;
                end else begin
                    // 디바운스 시간 경과 후 상태 확정
                    btn_stable <= btn_sync[2];
                    debounce_counter <= 20'b0;
                end
            end else begin
                // 상태 안정 시 카운터 리셋
                debounce_counter <= 20'b0;
            end
        end
    end

    // ============================================================
    // 엣지 검출
    // ============================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_prev <= 1'b0;
        end else begin
            btn_prev <= btn_stable;
        end
    end

    assign btn_rising_edge = btn_stable & ~btn_prev;

    // ============================================================
    // benchmark_start 펄스 생성 (1 클럭 펄스)
    // ============================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            benchmark_start <= 1'b0;
        end else begin
            benchmark_start <= btn_rising_edge;
        end
    end

endmodule
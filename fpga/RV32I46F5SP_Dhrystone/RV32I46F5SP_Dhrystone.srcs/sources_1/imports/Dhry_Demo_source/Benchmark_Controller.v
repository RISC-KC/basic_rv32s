module BenchmarkController (
    input clk,
    input reset,
    input benchmark_start,      // 버튼에서 시작 신호
    input [31:0] pc,           // 현재 PC
    input clk_enable,
    input [31:0] WB_instruction,
    input [63:0] mcycle,       // CSR에서 가져오기
    input [63:0] minstret,     // CSR에서 가져오기
    
    output reg benchmark_running,
    output reg benchmark_done,
    output reg [63:0] final_cycles,
    output reg [63:0] final_instructions
);

    // 상태 정의
    localparam IDLE = 2'b00;
    localparam RUNNING = 2'b01;
    localparam DONE = 2'b10;
    
    reg [1:0] state;
    reg [31:0] prev_pc;
    reg [31:0] stuck_counter;
    reg [63:0] start_cycles;
    reg [63:0] start_instructions;

    wire infinite_loop = (WB_instruction == 32'h0000006F);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            benchmark_running <= 1'b0;
            benchmark_done <= 1'b0;
            stuck_counter <= 32'b0;
            prev_pc <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    benchmark_done <= 1'b0;
                    if (benchmark_start) begin
                        state <= RUNNING;
                        benchmark_running <= 1'b1;
                        start_cycles <= mcycle;
                        start_instructions <= minstret;
                        stuck_counter <= 32'b0;
                        prev_pc <= pc;
                    end
                end
                
                RUNNING: begin
                    if (pc == prev_pc && clk_enable) begin
                        stuck_counter <= stuck_counter + 1;
                    end else begin
                        stuck_counter <= 32'b0;
                        prev_pc <= pc;
                    end
                    
                    if (infinite_loop) begin
                        state <= DONE;
                        benchmark_running <= 1'b0;
                        benchmark_done <= 1'b1;
                        final_cycles <= mcycle - start_cycles;
                        final_instructions <= minstret - start_instructions;
                    end
                end
                
                DONE: begin
                    benchmark_done <= 1'b0;
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
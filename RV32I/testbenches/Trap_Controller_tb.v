`timescale 1ns/1ps
`include "modules/headers/trap.vh"

module tb;
  // 1) 신호 선언
  reg         clk;
  reg         rst;
  reg  [31:0] pc;
  reg  [2:0]  trap_status;
  reg  [31:0] csr_read_data;

  wire [31:0] trap_target;
  wire        ic_clean;
  wire        debug_mode;
  wire [11:0] csr_trap_address;
  wire [31:0] csr_trap_write_data;

  // 2) DUT 인스턴스
  TrapController dut (
    .clk               (clk),
    .rst               (rst),
    .pc                (pc),
    .trap_status       (trap_status),
    .csr_read_data     (csr_read_data),
    .trap_target       (trap_target),
    .ic_clean          (ic_clean),
    .debug_mode        (debug_mode),
    .csr_trap_address  (csr_trap_address),
    .csr_trap_write_data(csr_trap_write_data)
  );

  // 3) 클록 생성
  initial clk = 0;
  always #5 clk = ~clk;

  // 4) VCD 덤프 (파형 확인용)
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  // 5) 모니터 설정: 내부 state, CSR 쓰기/읽기, 출력 신호 변화
  initial begin
    $display("time | state | csr_addr | csr_wdata | trap_tgt  | ic_clean | debug");
    $monitor("%4t |  %b   |   %h   |    %h    |   %h   |     %b    |   %b",
             $time,
             dut.trap_handle_state,
             csr_trap_address,
             csr_trap_write_data,
             trap_target,
             ic_clean,
             debug_mode);
  end

  // 6) 자극(stimulus) 흐름
  initial begin
    // 초기화
    rst          = 1;
    trap_status  = `TRAP_NONE;
    pc           = 32'h0000_0000;
    csr_read_data= 32'h0000_0000;
    #20 rst = 0;

    // ── ECALL 테스트 ──
    pc           = 32'h0000_1000;
    trap_status  = `TRAP_ECALL;
    // mtvec 읽기 시뮬레이션: next state에서 csr_read_data를 mtvec 값으로 설정
    #10 csr_read_data = 32'h0000_2000;
    #10 trap_status = `TRAP_NONE;
    #20;

    // ── MRET 테스트 ──
    // 먼저 mepc에 리턴할 주소를 써 두었다 가정하고...
    trap_status   = `TRAP_MRET;
    csr_read_data = 32'h0000_3000;  // mepc에서 읽혀야 할 값
    #10 trap_status = `TRAP_NONE;
    #20;

    // ── EBREAK 테스트 ──
    pc           = 32'h0000_6000;
    trap_status  = `TRAP_EBREAK;
    // mtvec 읽기 시뮬레이션: next state에서 csr_read_data를 mtvec 값으로 설정
    #10 csr_read_data = 32'h0000_2000;
    #10 trap_status = `TRAP_NONE;
    #20;

    // ── FENCE.I 테스트 ──
    trap_status = `TRAP_FENCEI;
    #10 trap_status = `TRAP_NONE;
    #20;

    // ── MRET 테스트 ──
    // 먼저 mepc에 리턴할 주소를 써 두었다 가정하고...
    trap_status   = `TRAP_MRET;
    csr_read_data = 32'h0000_3000;  // mepc에서 읽혀야 할 값
    #10 trap_status = `TRAP_NONE;
    #20;

    // ── MISALIGNED 테스트 ──
    // 먼저 mepc에 리턴할 주소를 써 두었다 가정하고...
    trap_status   = `TRAP_MISALIGNED;
    csr_read_data = 32'h0000_3000;  // mepc에서 읽혀야 할 값
    // mtvec 읽기 시뮬레이션: next state에서 csr_read_data를 mtvec 값으로 설정
    #10 csr_read_data = 32'h0000_2000;
    #10 trap_status = `TRAP_NONE;
    #20;

    // ── NONE 상태 확인 ──
    trap_status = `TRAP_NONE;
    #10;

    $finish;
  end
endmodule
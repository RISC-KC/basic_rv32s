`timescale 1ns/1ps
`include "modules/headers/trap.vh"

module TrapController_tb;
  // Signal Declaration
  reg         clk;
  reg         rst;
  reg  [31:0] pc;
  reg  [2:0]  trap_status;
  reg  [31:0] csr_read_data;

  wire [31:0] trap_target;
  wire        ic_clean;
  wire        debug_mode;
  wire        trap_done;
  wire        csr_write_enable;
  wire [11:0] csr_trap_address;
  wire [31:0] csr_trap_write_data;

  // DUT instance
  TrapController trap_controller (
    .clk                (clk),
    .rst                (rst),
    .pc                 (pc),
    .trap_status        (trap_status),
    .csr_read_data      (csr_read_data),

    .trap_target        (trap_target),
    .ic_clean           (ic_clean),
    .debug_mode         (debug_mode),
    .csr_write_enable   (csr_write_enable),
    .csr_trap_address   (csr_trap_address),
    .csr_trap_write_data(csr_trap_write_data),
    .trap_done          (trap_done)
  );

  // Generate clock signal (period = 10ns)
  initial clk = 0;
  always #5 clk = ~clk;

  // VCD dump
  initial begin
    $dumpfile("testbenches/results/waveforms/Trap_Controller_tb_result2.vcd");
    $dumpvars(0, TrapController_tb);
  end

  // Monitor setup :  internal state, CSR Read/Write, output changes
  initial begin
    $display("time | th_state | csr_addr | csr_wd | csr_we |  trap_tgt  | ic_clean | debug | trap_done");
    $monitor("%4t |  %b   |   %h   |    %h    |   %b   |     %h     |     %b    |   %b   |  %b  |",
             $time,
             trap_controller.trap_handle_state,
             csr_trap_address,
             csr_trap_write_data,
             csr_write_enable,
             trap_target,
             ic_clean,
             debug_mode,
             trap_done);
  end

  // Testbench
  initial begin
    $display("==================== Register File Test START ====================");
    // Initialize signals
    rst          = 1;
    trap_status  = `TRAP_NONE;
    pc           = 32'h0000_0000;
    csr_read_data= 32'h0000_0000;
    #20 rst = 0;

    // ── ECALL Test ──
    pc           = 32'h0000_1100;
    trap_status  = `TRAP_ECALL;
    // mtvec base address = 1000_AA00
    #25; csr_read_data = 32'h1000_AA00;
    #30;

    /* expected values
    CSR_T.Addr = 12'h341
    CSR_T.WD = 0000_1100
    trap_handle_state = IDLE -> WRITE_MEPC

    CSR_T.Addr = 12'h342
    CSR_T.WD = 32'd11
    trap_handle_state = WRITE_MEPC -> WRITE_MCAUSE

    trap_target = 1000_AA00
    */

    // ── MRET Test ──
    // Assumes that mepc already has the value
    trap_status   = `TRAP_MRET;
    csr_read_data = 32'h0000_1100;  // mepc
    #10;
    /* expected values
    CSR_T.Addr = 12'h341
    trap_target = 32'h0000_1104
    debug_mode = 0
    trap_handle_state = IDLE
    */

    // ── MISALIGNED Test ──
    pc           = 32'h0000_1111;
    trap_status   = `TRAP_MISALIGNED;
    // mtvec, go to trap_handler address
    csr_read_data = 32'h1000_AA00; 
    #30;
    // expected trap_target = 1000_AA00
    // mepc = 0000_1111
    // mcause = 32'd0

    // ── MRET Test ──
    // Assumes that mepc already has the value
    trap_status   = `TRAP_MRET;
    csr_read_data = 32'h0000_1110;  // mepc
    #10;
    /* expected values
    CSR_T.Addr = 12'h341
    trap_target = 32'h0000_1114
    debug_mode = 0
    trap_handle_state = IDLE
    */

    // ── EBREAK Test ──
    pc           = 32'h0000_BBB0;
    trap_status  = `TRAP_EBREAK;
    #20;
    // expected debug_mode = 1
    // mepc = 0000_BBB0
    // mcause = 32'd3

    // ── MRET Test ──
    // Assumes that mepc already has the value
    trap_status   = `TRAP_MRET;
    csr_read_data = 32'h0000_BBB0;  // mepc
    #10;
    /* expected values
    CSR_T.Addr = 12'h341
    trap_target = 32'h0000_BBB4
    debug_mode = 0
    trap_handle_state = IDLE
    */

    // ── FENCE.I Test ──
    trap_status = `TRAP_FENCEI;
    #10;
    // expected ic_clean <= 1'b1

    // ── NONE Test ──
    trap_status = `TRAP_NONE;
    #10;
    $display("\n====================  Register File Test END  ====================");
    $finish;
  end
endmodule
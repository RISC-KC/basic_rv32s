`include "./csr.vh"

module CSRFile #(
    parameter XLEN = 32
)(
    input clk,                    // clock signal
    input clk_enable,
    input reset,                  // reset signal
    input trapped,
    input csr_write_enable,       // write enable signal
    input [11:0] csr_read_address,       // address to read
    input [11:0] csr_write_address,      // address to write
    input [XLEN-1:0] csr_write_data,         // data to write
    input instruction_retired,

    output reg [XLEN-1:0] csr_read_out,          // data from CSR Unit
    output reg csr_ready,
    output [63:0] debug_mcycle,
    output [63:0] debug_minstret
    );
    
    assign debug_mcycle = mcycle;
    assign debug_minstret = minstret;

    wire [XLEN-1:0] mvendorid = 32'h52_56_4B_43;    // "RVKC" ; "R"ISC-"V", "K"HWL & "C"hoiCube84.
    wire [XLEN-1:0] marchid   = 32'h34_36_53_35;    // "46S5" ; "46"F arch based "S"uper scalar "5"-Stage Pipeline Architecture.
    wire [XLEN-1:0] mimpid    = 32'h34_36_49_31;    // "46I1" ; "46" instructions RISC-V RV32"I" Revision "1".
    wire [XLEN-1:0] mhartid   = 32'h52_4B_43_30;    // "RKC0" ; "R"oad to "K"AIST "C"ore 0.
    wire [XLEN-1:0] mstatus   = 32'h00001800;    // MPP[12:11] = 11
    wire [XLEN-1:0] misa      = 32'h40000100;    // MXL = 32; misa[31:30] = 01. RV32"I"; misa[8] = 1.

    reg [XLEN-1:0] mtvec;
    reg [XLEN-1:0] mepc;
    reg [XLEN-1:0] mcause;

    reg [63:0] mcycle;
    reg [63:0] minstret;

    reg csr_processing;
    reg [XLEN-1:0] csr_read_data;

    reg csr_write_enable_buffer;

    wire csr_access;
    wire valid_csr_address;
    wire csr_write_enable_edge = csr_write_enable && !csr_write_enable_buffer;

    assign csr_access = valid_csr_address;
    assign valid_csr_address = (csr_read_address == 12'hB00) || // mcycle
                               (csr_read_address == 12'hB02) || // minstret
                               (csr_read_address == 12'hB80) || // mcycleh
                               (csr_read_address == 12'hB82) || // minstreth
                               (csr_read_address == 12'hF11) || // mvendorid
                               (csr_read_address == 12'hF12) || // marchid  
                               (csr_read_address == 12'hF13) || // mimpid
                               (csr_read_address == 12'hF14) || // mhartid
                               (csr_read_address == 12'h300) || // mstatus
                               (csr_read_address == 12'h301) || // misa
                               (csr_read_address == 12'h305) || // mtvec
                               (csr_read_address == 12'h341) || // mepc
                               (csr_read_address == 12'h342);   // mcause

    localparam [XLEN-1:0] DEFAULT_mtvec  = 32'h00006D60;
    localparam [XLEN-1:0] DEFAULT_mepc   = {XLEN{1'b0}};
    localparam [XLEN-1:0] DEFAULT_mcause = {XLEN{1'b0}};

    // Read Operation.
    always @(*) begin
      case (csr_read_address)
        12'hB00: csr_read_data = mcycle[31:0];
        12'hB02: csr_read_data = minstret[31:0];
        12'hB80: csr_read_data = mcycle[63:32];
        12'hB82: csr_read_data = minstret[63:32];
        12'hF11: csr_read_data = mvendorid;
        12'hF12: csr_read_data = marchid;
        12'hF13: csr_read_data = mimpid;
        12'hF14: csr_read_data = mhartid;
        12'h300: csr_read_data = mstatus;
        12'h301: csr_read_data = misa;
        12'h305: csr_read_data = mtvec;
        12'h341: csr_read_data = mepc;
        12'h342: csr_read_data = mcause;
        default: csr_read_data = {XLEN{1'b0}};
      endcase

      if (reset) begin
        csr_ready = 1'b1;
      end else begin
        if (csr_access && !csr_processing) begin
          csr_ready = 1'b0;
        end else if (csr_processing) begin
          csr_ready = 1'b1;
        end else begin
          csr_ready = 1'b1;
        end
      end
    end

    // Reset Operation
    always @(posedge clk or posedge reset) begin
      if (reset) begin
        mtvec   <= DEFAULT_mtvec;
        mepc    <= DEFAULT_mepc;
        mcause  <= DEFAULT_mcause;
        mcycle <= 64'b0;
        minstret <= 64'b0;
        csr_processing <= 1'b0;
        csr_read_out <= {XLEN{1'b0}};
        csr_write_enable_buffer <= 1'b0;
      end else if (clk_enable) begin
        mcycle <= mcycle + 1;
        if (instruction_retired) begin
          minstret <= minstret + 1;
        end

        if (csr_access && !csr_processing) begin
          csr_processing <= 1'b1;
          csr_read_out <= csr_read_data;
        end else if (csr_processing) begin
          csr_processing <= 1'b0;
          csr_read_out <= csr_read_data;
        end else if (csr_write_enable) begin
          csr_read_out <= csr_read_data;
        end

        csr_write_enable_buffer <= csr_write_enable;

        // Write Operation
        if ((trapped && csr_write_enable_edge) || (csr_write_enable_edge)) begin
        case (csr_write_address)
          12'h305: mtvec  <= csr_write_data;
          12'h341: mepc   <= csr_write_data;
          12'h342: mcause <= csr_write_data;
          default: ;
        endcase
        end
      end
    end


endmodule
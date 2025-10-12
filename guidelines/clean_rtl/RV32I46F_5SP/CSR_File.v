`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/csr.vh"

module CSRFile #(
    parameter XLEN = 32
)(
    input clk,
    input clk_enable,
    input reset,
    input trapped,
    input csr_write_enable,
    input [11:0] csr_read_address,
    input [11:0] csr_write_address,
    input [XLEN-1:0] csr_write_data,

    output reg [XLEN-1:0] csr_read_out,
    output reg csr_ready
    );

    wire [XLEN-1:0] mvendorid = 32'h52_56_4B_43;
    wire [XLEN-1:0] marchid   = 32'h34_36_53_35;
    wire [XLEN-1:0] mimpid    = 32'h34_36_49_31;
    wire [XLEN-1:0] mhartid   = 32'h52_4B_43_30;
    wire [XLEN-1:0] mstatus   = 32'h00001800;
    wire [XLEN-1:0] misa      = 32'h40000100;
    reg [XLEN-1:0] mtvec;
    reg [XLEN-1:0] mepc;
    reg [XLEN-1:0] mcause;
    reg csr_processing;
    reg [XLEN-1:0] csr_read_data;
    reg csr_write_enable_buffer;
    wire csr_access;
    wire valid_csr_address;
    wire csr_write_enable_edge = csr_write_enable && !csr_write_enable_buffer;

    assign csr_access = valid_csr_address;
    assign valid_csr_address = (csr_read_address == 12'hF11) ||
                               (csr_read_address == 12'hF12) ||  
                               (csr_read_address == 12'hF13) ||
                               (csr_read_address == 12'hF14) ||
                               (csr_read_address == 12'h300) ||
                               (csr_read_address == 12'h301) ||
                               (csr_read_address == 12'h305) ||
                               (csr_read_address == 12'h341) ||
                               (csr_read_address == 12'h342);

    localparam [XLEN-1:0] DEFAULT_mtvec  = 32'h00001000;
    localparam [XLEN-1:0] DEFAULT_mepc   = {XLEN{1'b0}};
    localparam [XLEN-1:0] DEFAULT_mcause = {XLEN{1'b0}};

    always @(*) begin
      case (csr_read_address)
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

    always @(posedge clk or posedge reset) begin
      if (reset) begin
        mtvec   <= DEFAULT_mtvec;
        mepc    <= DEFAULT_mepc;
        mcause  <= DEFAULT_mcause;
        csr_processing <= 1'b0;
        csr_read_out <= {XLEN{1'b0}};
        csr_write_enable_buffer <= 1'b0;
      end else if (clk_enable) begin
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
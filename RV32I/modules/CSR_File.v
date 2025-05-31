module CSRFile (
    input               clk,                    // clock signal
    input               reset,                  // reset signal
    input       [11:0]  csr_read_address,       // address to read
    input               csr_write_enable,       // write enable signal
    input       [11:0]  csr_write_address,      // address to write
    input       [31:0]  csr_write_data,         // data to write

    output reg  [31:0]  csr_read_data          // data from CSR Unit
    );

    wire [31:0] mvendorid = 32'h52564B43;    // "RVKC" ; RISC-V, KHWL & ChoiCube84.
    wire [31:0] marchid   = 32'h62616E61;    // "bana" ; KHWL & ChoiCube84's RISC-V RV32I 50 Instruction processor. Cache, Trap, Debug. "3250" CTD5.
    wire [31:0] mimpid    = 32'h49355232;    // "I5R2" ; RISC-V RV32"I" "5"0 Instructions Final, "R"evision "2".
    wire [31:0] mhartid   = 32'h626E6130;    // "bna0"
    wire [31:0] mstatus   = 32'h00001800;    // MPP[12:11] = 11
    wire [31:0] misa      = 32'h40000100;    // MXL = 32; misa[31:30] = 01. RV32"I"; misa[8] = 1.

    reg [31:0] mtvec;
    reg [31:0] mepc;
    reg [31:0] mcause;

    localparam [31:0] DEFAULT_mtvec  = 32'h00001000;
    localparam [31:0] DEFAULT_mepc   = 32'h00000000;
    localparam [31:0] DEFAULT_mcause = 32'h00000000;

    // Read Operation.
    always @(*) begin
      case (csr_read_address)
        12'hF11: csr_read_data = mvendorid;
        12'hF12: csr_read_data = marchid;
        12'hF13: csr_read_data = mimpid;
        12'hF14: csr_read_data = mhartid;
        12'h300: csr_read_data = mstatus;
        12'h301: csr_read_data = misa;
        12'h305: csr_read_data = mtvec;
        12'h341: csr_read_data = (csr_write_enable && csr_write_address == 12'h341) ? csr_write_data : mepc;
        12'h343: csr_read_data = (csr_write_enable && csr_write_address == 12'h343) ? csr_write_data : mcause;
        default: csr_read_data = 32'b0;
      endcase
    end

    // Reset Operation
    always @(posedge clk or posedge reset) begin
      if (reset) begin
        mtvec   <= DEFAULT_mtvec;
        mepc    <= DEFAULT_mepc;
        mcause  <= DEFAULT_mcause;
      end
    // Write Operation
      else if (csr_write_enable) begin
        case (csr_write_address)
          12'h341: mepc   <= csr_write_data;
          12'h343: mcause <= csr_write_data;
          default: ; //NOP
        endcase
      end
    end


endmodule
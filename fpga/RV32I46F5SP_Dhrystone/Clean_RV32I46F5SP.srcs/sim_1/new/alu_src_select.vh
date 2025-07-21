`ifndef ALU_SRC_SELECT_VH
`define ALU_SRC_SELECT_VH

`define ALU_SRC_A_NONE  2'b00
`define ALU_SRC_A_RD1   2'b01
`define ALU_SRC_A_PC    2'b10
`define ALU_SRC_A_RS1   2'b11

`define ALU_SRC_B_NONE  3'b000
`define ALU_SRC_B_RD2   3'b001
`define ALU_SRC_B_IMM   3'b010
`define ALU_SRC_B_CSR   3'b011
`define ALU_SRC_B_SHAMT 3'b100

`endif // ALU_SRC_SELECT_VH
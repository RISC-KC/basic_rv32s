`ifndef TRAP_VH
`define TRAP_VH

`define TRAP_NONE		3'b000
`define TRAP_EBREAK		3'b001
`define TRAP_ECALL		3'b010
`define TRAP_MISALIGNED	3'b011
`define TRAP_MRET       3'b100
`define TRAP_FENCEI     3'b101

`endif // TRAP_VH
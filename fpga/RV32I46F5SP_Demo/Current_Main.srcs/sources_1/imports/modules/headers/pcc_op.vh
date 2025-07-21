`ifndef PCCOP_VH
`define PCCOP_VH

`define PCC_NONE    3'b000 // next_pc = pc + 4
`define PCC_BTAKEN  3'b001 // next_pc = pc + imm
`define PCC_JUMP    3'b010 // next_pc = jump_target
`define PCC_TRAPPED 3'b011 // next_pc = trap_target
`define PCC_STALL   3'b100 // next_pc = pc

`endif // PCCOP_VH
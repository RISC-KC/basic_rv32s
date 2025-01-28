★ = Must be implemented in ALU Logic in RV32I.

- [R-Type ; 0110011]★ ; 10 instr.s

inst : funct3 ; funct7

add : 000 ; 0000000
sub : 000 ; 0100000

xor : 100 ; 0000000
or : 110 ; 0000000
and : 111 ; 0000000

sll : 001 ; 0000000
srl : 101 ; 0000000
sra : 101 ; 0100000
slt : 010 ; 0000000
sltu : 011 ; 0000000

- [I-Type ; 0010011]★ ; 9 instr.s

addi : 000 ; -
xori : 100 ; -
ori : 110 ; -
andi : 111 ; -

slli : 001 ; imm[5:11]=0000000
srli : 101 ; imm[5:11]=0000000
srai : 101 ; imm[5:11]=0100000
slti : 010 ; -
sltiu : 011 ; -

- [I-Type_load ; 0000011] ; 5 instr.s

lb : 000 ; -
lh : 001 ; -
lw : 010 ; -
lbu : 100 ; -
lhu : 101 ; -

- [I-Type_jump ; 1100111] ; 1 instr.
jalr : 000 ; -

- [I-Type_debug ; 1110011] ; 2 instr.s
ecall : 000 ; imm=0x0=000
ebreak : 000 ; imm=0x1=001

- [B-Type ; 1100011] ★ ; 6 instr.s
beq : 000 ; -
bne : 001 ; -
blt : 100 ; -
bge : 101 ; -
bltu : 110 ; -
bgeu : 111 ; -


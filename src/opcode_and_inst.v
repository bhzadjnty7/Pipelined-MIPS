`timescale 1ns / 1ns

//ALU instructions  
`define ALU_ADD 6'b100000
`define ALU_SUB 6'b100010
`define ALU_AND 6'b100100
`define ALU_OR 6'b100101
`define ALU_XOR 6'b100110
`define ALU_NOR 6'b100111 
`define ALU_SLT 6'b101010  // set less than
`define ALU_SLL 6'b000000  // shift left logical
`define ALU_SLLV 6'b000100 // shift left logical variable
`define ALU_SRL 6'b000010  // shift right logical
`define ALU_SRLV 6'b000110 // shift right ligical variable
`define ALU_SRA 6'b000011  // shift right arithmatic 
`define ALU_SRAV 6'b000111 // shift right arithmatic variable
`define ALU_LUI 6'b001001  // load upper immediate
`define ALU_BEQZ 6'b001011 // branch equal zero
`define ALU_ADDU 6'b100001 // add unsigned
`define ALU_SUBU 6'b100011 // subtract unsigned
`define ALU_SLTU 6'b101011 // set less than unsigned 
`define ALU_BEQ 6'b111111  // branch equal

// instructions opcodes and functions operand
`define RT 6'b000000
`define addi 6'b001000
`define addiu 6'b001001
`define slti 6'b001010
`define sltiu 6'b001011
`define lw 6'b100011
`define lui 6'b001111
`define sw 6'b101011
`define beq 6'b000100
`define beqz 6'b000111
`define j 6'b000110
`define jal 6'b000011
`define jr 6'b001000
`define jalr 6'b001001
`define andi 6'b001100
`define ori 6'b001001
`define xori 6'b001001
`define bne 6'b001001


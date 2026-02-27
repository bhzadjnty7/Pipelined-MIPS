`timescale 1ns / 1ns
`include "opcode_and_inst.v"

module data_path (
    input clk, // clock
    input rst, // reset 
    input [1:0] RegDst, // register destination (selector of mux reg-file (select between 31 ,rt, rd(register destination ))
    input [1:0] Jmp, // jump ( selector of mux3 jump )
    input DataC, // datac ) selector of mux2 ( select between pc+4 and memory data from write back proc)
    input RegWrite,// register file writer activator 
    input AluSrc, // selector of mux of alu component
    input Branch, // branch activator
    input MemRead, // enable pin for data memory reading 
    input MemWrite, // enable pin for data writing 
    input MemtoReg, // selector of mux between alu result and readed data from data-memory in writeback stage 
    input [5:0] AluOperation, // select operation in code instructions
    output wire [5:0] func, // select operation in r-type instructions
    output wire [5:0] opcode, // opcode operand of instruction 
    output wire [31:0] out1, // output 1 
    output wire [31:0] out2 // output2 
);

  // every nets described in reports images
  wire [31:0]   in_pc,out_pc,
		instruction,
		write_data_reg,
		read_data1_reg,
		read_data2_reg,
		pc_adder,
		mem_read_data,
		inst_extended,
		alu_input2,
		alu_result,
		read_data_mem,
		shifted_inst_extended,
		out_adder2,
		out_branch;


  wire [31:0]   IR_instruction,
		RD1_reg,RD2_reg,
		RD2_reg2,
		alu_input2_reg,
		alu_result_reg,
		mem_read_data_reg,
		inst_extended_reg;

  wire [13:0] out_cntrl_ex;  //reg cntrl pipe line _ex 
  wire [ 5:0] out_cntrl_mem;  //reg cntrl pipeline _mem
  wire [ 2:0] out_cntrl_wb;  //erg cntrl pipe line _wb

  wire [25:0] shl2_inst;
  wire and_z_b, zero;

  wire [4:0] RT_reg,RD3_reg,register_write_address,register_write_address_reg,register_write_address_reg2;


	
  adder adder2 (
      .data1(shifted_inst_extended),
      .data2(pc_adder),
      .sum  (out_adder2)
  );



  shl2 #32 shl2_of_adder2 (
      .adr(inst_extended_reg),
      .sh_adr(shifted_inst_extended)
  );
  shl2 #26 shl2_1 (
      .adr(instruction[25:0]),
      .sh_adr(shl2_inst)
  );
  
  // adder pc+4 
  adder pc_adder_comp (
      .data1(out_pc),
      .data2(32'd4),
      .sum  (pc_adder)
  );

  assign and_z_b = out_cntrl_ex[7] & zero;

  mux2_to_1 #32 mux2_branch (
      .data1(pc_adder),
      .data2(out_adder2),
      .sel  (and_z_b),
      .out  (out_branch)
  );


  mux3_to_1 #32 mux3_jmp (
      .data1(out_branch),
      .data2({pc_adder[31:26], shl2_inst}),
      .data3(read_data1_reg),
      .sel  (Jmp),
      .out  (in_pc)
  );

  pc PC (
      .clk(clk),
      .rst(rst),
      .in (in_pc),
      .out(out_pc)
  );

//for fetch stage
  fetch fetchStage (
      .clk(clk),
      .rst(rst),
      .address(out_pc),
      .instruction(instruction)
  ); 

//IR register for pipeline
  register IR_register (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(instruction),
      .read_data(IR_instruction)
  );

//for decode stage
  decode decodeStage (
      .clk(clk),
      .rst(rst),
      .IR_instruction(IR_instruction),
      .func(func),
      .opcode(opcode),
      .read_data1(read_data1_reg),
      .read_data2(read_data2_reg),
      .inst_extended(inst_extended),
      .mem_read_data_reg(mem_read_data_reg),
      .pc_adder(pc_adder),
      .out_cntrl_wb(out_cntrl_wb),
      .register_write_address_reg2(register_write_address_reg2)
  );


// for branch instructions
  register reg_inst_extended ( 
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(inst_extended),
      .read_data(inst_extended_reg)
  );
  mux2_to_1 #32 alu_mux (
      .data1(read_data2_reg),
      .data2(inst_extended),
      .sel  (AluSrc),
      .out  (alu_input2)
  );


// controller register one (has all of the control signals)
  register #(
      .WIDTH(14)
  ) reg_cntrl_ex (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data({AluOperation, Branch, RegDst, DataC, MemRead, MemWrite, MemtoReg, RegWrite}),
      .read_data(out_cntrl_ex)
  );


 //register that holds the data that came from register file for pipeline
  register regfile_rd1_register (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(read_data1_reg),
      .read_data(RD1_reg)
  );


 //register come from mux2 of rd2 and imm
  register alu_mux_register (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(alu_input2),
      .read_data(alu_input2_reg)
  );

 //register that holds the data that came from register file for pipeline
  register reg_rd2_ex (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(read_data2_reg),
      .read_data(RD2_reg)
  );

 // register that hold rt for WB
  register #(
      .WIDTH(5)
  ) reg_rt_wb (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(IR_instruction[20:16]),
      .read_data(RT_reg)
  );

  // register that hold rd for WB
  register #(
      .WIDTH(5)
  ) reg_rd_wb (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(IR_instruction[15:11]),
      .read_data(RD3_reg)
  );

//for execute stage
  execute executeStage (
      .data1(RD1_reg),
      .data2(alu_input2_reg),
      .alu_op(out_cntrl_ex[13:8]),
      .alu_result(alu_result),
      .zero_flag(zero)
  );


  // mux for choosing between rd or rt for WB 
  mux2_to_1 #5 rd_or_rt_mux (
      .data1(RT_reg),
      .data2(RD3_reg),
      .sel  (out_cntrl_ex[5]),
      .out  (register_write_address)
  );

  // controller register two (has three bits of the control signals)
  register #(
      .WIDTH(6)
  ) reg_cntrl_mem (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data({out_cntrl_ex[6], out_cntrl_ex[4:0]}),
      .read_data(out_cntrl_mem)
  );


  //register that holds the data that came from ALU for pipeline
  register reg_alu_out_mem (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(alu_result),
      .read_data(alu_result_reg)
  );

  //register come from register file but go to the two next stage in memory stage for pipeline
  register reg_rd2_mem (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(RD2_reg),
      .read_data(RD2_reg2)
  );
  //register that holds the write register address
  register #(
      .WIDTH(5)
  ) reg_wb_address (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(register_write_address),
      .read_data(register_write_address_reg)
  );


  data_memory data_mem (
      .clk(clk),
      .rst(rst),
      .mem_read(out_cntrl_mem[3]),
      .mem_write(out_cntrl_mem[2]),
      .adr(alu_result_reg),
      .write_data(RD2_reg2),
      .read_data(read_data_mem),
      .out1(out1),
      .out2(out2)
  );

  mux2_to_1 #32 data_mux_mem (
      .data1(alu_result_reg),
      .data2(read_data_mem),
      .sel  (out_cntrl_mem[1]),
      .out  (mem_read_data)
  );


  // controller register three (has 1 bit of the control signals)
  register #(
      .WIDTH(3)
  ) reg_cntrl_wb (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data({out_cntrl_mem[5:4], out_cntrl_mem[0]}),
      .read_data(out_cntrl_wb)
  );

  //the output come from mux_2 memory output and alu output
  register reg_mem_out_wb (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(mem_read_data),
      .read_data(mem_read_data_reg)
  );



  //register that holds the write register address
  register #(
      .WIDTH(5)
  ) reg_wb_address2 (
      .clk(clk),
      .RegWrite(1'b1),
      .reset(rst),
      .write_data(register_write_address_reg),
      .read_data(register_write_address_reg2)
  );
endmodule
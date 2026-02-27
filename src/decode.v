module decode (
    input clk,
    input rst,
    input [31:0] IR_instruction,
    input [31:0] mem_read_data_reg,
    input  [31:0] pc_adder,
    input  [2:0] out_cntrl_wb,
    input  [4:0] register_write_address_reg2,
    output [5:0] func,
    output [5:0] opcode,
    output [31:0] read_data1,
    output [31:0] read_data2,
    output [31:0] inst_extended
);

  wire [31:0] write_data_reg;
  wire [ 4:0] reg_address;




  decoder decoder (
      .rst(rst),
      .instruction(IR_instruction),
      .func(func),
      .opcode(opcode)
  );


  mux2_to_1 #32 mux2_reg_file (
      .data1(mem_read_data_reg),
      .data2(pc_adder),
      .sel  (out_cntrl_wb[1]),
      .out  (write_data_reg)
  );

  mux2_to_1 #5 mux3_reg_file (
      .data1(register_write_address_reg2),
      .data2(5'd31),
      .sel  (out_cntrl_wb[2]),
      .out  (reg_address)
  );

  reg_file RegFile (
      .clk(clk),
      .rst(rst),
      .RegWrite(out_cntrl_wb[0]),
      .read_reg1(IR_instruction[25:21]),
      .read_reg2(IR_instruction[20:16]),
      .write_reg(reg_address),
      .write_data(write_data_reg),
      .read_data1(read_data1),
      .read_data2(read_data2)
  );


  sign_extension sign_ext (
      .clk(clk),
      .primary (IR_instruction[15:0]),
      .extended(inst_extended)
  );

endmodule
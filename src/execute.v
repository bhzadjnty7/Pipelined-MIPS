
module execute (
    input [31:0] data1,
    input [31:0] data2,
    input [5:0] alu_op,
    output zero_flag,
    output [31:0] alu_result
);


  alu ALU (
      .clk(clk),
      .data1(data1),
      .data2(data2),
      .alu_op(alu_op),
      .alu_result(alu_result),
      .zero_flag(zero_flag)
  );

endmodule
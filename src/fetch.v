module fetch (
	    input clk,
	    input rst,
	    input [31:0] address,
	    output [31:0] instruction
);



  inst_memory InstMem (
      .rst(rst),
      .adr(address),
      .instruction(instruction)
  );
endmodule
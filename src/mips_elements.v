`timescale 1ns/1ns
`include "opcode_and_inst.v"

//mux
//component: 3to1 multiplexer
module mux3_to_1 #(parameter num_bit)(input clk,input [num_bit-1:0]data1,data2,data3, input [1:0]sel,output [num_bit-1:0]out);
	
	assign out=~sel[1] ? (sel[0] ? data2 : data1 ) : data3;	
endmodule

//component: 2to1 multiplexer
module mux2_to_1 #(parameter num_bit)(input clk,input [num_bit-1:0]data1,data2, input sel,output [num_bit-1:0]out);
	
	assign out=~sel?data1:data2;
endmodule




//bitwise components
//component: sign extender to 32bit

//component: sign extender 
module sign_extension (
    input clk,
    input [15:0] primary,
    output [31:0] extended
);
  assign extended = $signed(primary);
endmodule

//component :shift left 2bits
module shl2 #(
    parameter num_bit
) (
    input [num_bit-1:0] adr,
    output [num_bit-1:0] sh_adr
);

  assign sh_adr = adr << 2;
endmodule

//Arithmatics Units
//adder
module adder (
    input [31:0] data1,
    data2,
    output [31:0] sum
);

  wire co;
  assign {co, sum} = data1 + data2;
endmodule

//arithmatics logical unit (ALU)
module alu (
    input        clk,
    input [31:0] data1,
    input [31:0] data2,
    input [5:0] alu_op,
    output zero_flag,
    output reg greather_flag,
    output reg [31:0] alu_result
);

  always @(alu_op, data1, data2) begin
    alu_result = 32'b0;
    greather_flag = 1'b0;

    case (alu_op)
      `ALU_AND:  alu_result = data1 & data2;
      `ALU_OR:   alu_result = data1 | data2;
      `ALU_ADD:  alu_result = data1 + data2;
      `ALU_SUB:  alu_result = data1 - data2;
      `ALU_SLT:  alu_result = (data1 < data2) ? 32'b1 : 32'b0;
      `ALU_XOR:  alu_result = data1 ^ data2;
      `ALU_NOR:  alu_result = ~(data1 | data2);
      `ALU_SLL:  alu_result = data2 << data1[4:0];
      `ALU_SLLV: alu_result = data1 << data2[4:0];
      `ALU_SRL:  alu_result = data1 >> data2[4:0];
      `ALU_SRLV: alu_result = data1 >> data2[4:0];
      `ALU_SRA:  alu_result = data1 >>> data2[4:0];
      `ALU_SRAV: alu_result = data1 >>> data2[4:0];
      `ALU_LUI:  alu_result = data2 << 5'd16;
      `ALU_BEQ:   alu_result = (data1 == data2) ? 32'b1 : 32'b0;
      `ALU_ADDU: alu_result = $unsigned(data1) + $unsigned(data2);
      `ALU_SUBU: alu_result = $unsigned(data1) - $unsigned(data2);
      `ALU_SLTU: alu_result = ($unsigned(data1) < $unsigned(data2)) ? 32'b1 : 32'b0;

      `ALU_BEQZ:
      if ($signed(data1) > $signed(data2)) begin
        alu_result = 32'b0;
      end else alu_result = 32'b11;  
    endcase
  end
  assign zero_flag = (alu_result == 32'b0) ? 1'b1 : 1'b0;
endmodule




//memories

//register file ( memory off registers )
module reg_file(input clk,rst,
	RegWrite,
	input [4:0] read_reg1,
	read_reg2,write_reg,
	input [31:0]write_data,
	output [31:0]read_data1,read_data2);

	reg [31:0] register[0:31];
	integer i;
	always@(posedge clk,rst) begin
		if(rst) begin
			for(i=0;i<32;i=i+1) register[i]<=32'b0;
		end
		else begin
			if(RegWrite) register[write_reg]<=write_data;
		end
	end
	assign read_data1=register[read_reg1];
	assign read_data2=register[read_reg2];
endmodule

// data memory ( memory of data for saving result or execution tasks)
module data_memory (
    input clk,
    rst,
    mem_read,
    mem_write,
    input [31:0] adr,
    write_data,
    output reg [31:0] read_data,
    output [31:0] out1,
    out2
);

  reg [31:0] mem_data[0:511];//declearing data memory :512 row 32bits every row
  integer i, f;

  initial begin
    $readmemb("datamemory.txt", mem_data);
  end

  always @(posedge clk) begin
    if (mem_write) 
	mem_data[adr>>2] <= write_data;
  end

  always @(mem_read, adr) begin
    if (mem_read) read_data <= mem_data[adr>>2];
    else read_data <= 32'b0;
  end

  initial begin
    $writememb("datamemory.txt", mem_data);
  end

  initial begin
    f = $fopen("datamemory.txt", "w");
    for (i = 0; i < 512; i = i + 1) begin
      $fwrite(f, "%b\n", mem_data[i]);
    end
    $fclose(f);
  end

  assign out1 = mem_data[500];
  assign out2 = mem_data[501];

endmodule

//instruction memory ( to save instructions ) 
module inst_memory(input clk,rst,input [31:0]adr,output [31:0]instruction);

	reg [31:0]mem_inst[0:255];
	initial begin
		$readmemb("instructionmemory.txt",mem_inst);//read instructions from text file and feed instruction memory with them
  	end
	assign instruction=mem_inst[adr>>2];
endmodule





//decoding process
module decoder(input rst,[31:0] instruction,output [5:0]func,opcode); 

	assign func=instruction[5:0];

	assign opcode=instruction[31:26];

endmodule



//program counter
module pc(input clk,rst,input [31:0]in,output reg[31:0]out);

	always @(posedge clk,rst) begin
		if(rst) out<=32'b0;
		else out<=in;
	end
endmodule
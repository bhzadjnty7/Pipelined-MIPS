module register#( parameter WIDTH = 32)
(
	input clk,
	input RegWrite,
	input reset,
	input [WIDTH-1:0]write_data,
	output reg [WIDTH-1:0] read_data);

always@(posedge clk, reset) 
	begin
		if(reset) 
			begin 
				read_data = 0;
			end
		else if(RegWrite)
			begin	
	 			read_data<=write_data;
			end	
	end
endmodule 



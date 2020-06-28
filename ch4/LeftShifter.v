`include "define.h"

module LeftShifter(Amt_Left, D_in, D_Left);
	
	// how many shifters will be needed
	input [4:0] Amt_Left;
	// data in
	input [31:0] D_in;
	// data left out
	output reg [31:0] D_Left;

	LeftShifter_1 Left_1(Amt_Left, D_in, D_Left);
	

	always @* begin
		// 16 bit shifter
		if(Amt_in[4] == 1'b1) begin
			
			
		end
		// 8 bit shifter
		if(Amt_in[3] == 1'b1) begin
			
			
		end
		// 4 bit shifter
		if(Amt_in[2] == 1'b1) begin
			
			
		end
		// 2 bit shifter
		if(Amt_in[1] == 1'b1) begin
			
			
		end
		// 1 bit shifter
		if(Amt_in[0] == 1'b1) begin
			
			
		end
	end
	
endmodule

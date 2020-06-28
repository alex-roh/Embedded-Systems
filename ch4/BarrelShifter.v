`timescale 1 ns/1 ns

module BarrelShifter(Dir, Amt_in, D_in, D_Left, D_Right);

	// shift left or shift right	
	input Dir;
	// how many shifters will be needed
	input [4:0] Amt_in;
	// data in
	input [31:0] D_in;
	// data left out
	output reg [31:0] D_Left;
	// data right out
	output reg [31:0] D_Right;

	// internal reg variable
	reg Amt_Left, Amt_Right; // less dynamic power

	LeftShifter Left(Amt_Left, D_in, D_Left);
	RightShifter Right(Amt_Right, D_in, D_out);

	always@* begin
		case(Dir)
		`RIGHT: begin
			Amt_Left <= {5{1'b0}};
			Amt_Right <= Amt_in;
		end
		`LEFT: begin
			Amt_Left <= Amt_in;
			Amt_Right <= {5{1'b0}};
		end
	end
		
endmodule

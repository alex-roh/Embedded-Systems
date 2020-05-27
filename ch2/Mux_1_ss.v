
`timescale 1 ns/1 ns


module Mux_1_ss(A, B, C, D, S0, S1, F);

	input A, B, C, D;
	input S0, S1;
	output F;
	reg F;
	
	always @*
	begin
		if(S0 == 0 && S1 == 0)
		begin
			F <= A;
		end
		else if(S0 == 0 && S1 == 1)
		begin
			F <= B;
		end
		else if(S0 == 1 && S1 == 0)
		begin
			F <= C;
		end
		else
		begin
			F <= D;
		end
	end
	


endmodule
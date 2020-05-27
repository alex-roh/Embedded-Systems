
`timescale 1 ns/1 ns


module Mux_bs(A0, A1, B0, B1, C0, C1, D0, D1, S0, S1, F0, F1);

	input A0, A1, B0, B1, C0, C1, D0, D1;
	input S0, S1;
	output F0, F1;
	reg F0, F1;

	always @*
	begin
		if(S0 == 0 && S1 == 0)
		begin
			F0 <= A0;
			F1 <= A1;
		end
		else if(S0 == 0 && S1 == 1)
		begin
			F0 <= B0;
			F1 <= B1;
		end
		else if(S0 == 1 && S1 == 0)
		begin
			F0 <= C0;
			F1 <= C1;
		end
		else
		begin
			F0 <= D0;
			F1 <= D1;
		end
	end

endmodule
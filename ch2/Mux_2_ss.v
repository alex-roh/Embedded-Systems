
`timescale 1 ns/1 ns


module Mux_2_ss(A0, A1, B0, B1, C0, C1, D0, D1, S0, S1, F0, F1);

	input A0, A1, B0, B1, C0, C1, D0, D1;
	input S0, S1;
	output F0, F1;
	wire F0, F1;

	Mux_1_ss Mux_one(A0, B0, C0, D0, S0, S1, F0);
	Mux_1_ss Mux_two(A1, B1, C1, D1, S0, S1, F1);

endmodule
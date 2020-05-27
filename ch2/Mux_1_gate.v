
`timescale 1 ns/1 ns

module Mux_1_gate(A, B, C, D, S0, S1, F);
	input A, B, C, D;
	input S0, S1;
	output F;

	wire N0, N1, N2, N3, N4, N5; 
			
	and And_A(N2, A, N0, N1);
	and And_B(N3, B, N0, S1);
	and And_C(N4, C, S0, N1);
	and And_D(N5, D, S0, S1);
	not Inv_0(N0, S0);
	not Inv_1(N1, S1);
	or Output(F, N2, N3, N4, N5);

endmodule
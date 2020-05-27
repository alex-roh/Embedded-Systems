// ***********************************************************************
// TITLE       : Testbench for 2-bit 4x1 Multiplexer   
// AUTHOR      : Yoonjin Kim 
// AFFILIATION : Dept. of CS, Sookmyung Women's University 
// DESCRIPTION : Testbench simulating both hehavioral-level and gate-level                    
// ***********************************************************************

`timescale 1 ns/1 ns

module Testbench();
    
   reg A1_s, A0_s, B1_s, B0_s, C1_s, C0_s, D1_s, D0_s, S1_s, S0_s;
   wire Out1_bs, Out0_bs;
   wire Out1_gs, Out0_gs;
   Mux_bs CompToTest_beh(A1_s, A0_s, B1_s, B0_s, C1_s, C0_s, 
	                           D1_s, D0_s, S1_s, S0_s,Out1_bs, Out0_bs);
   Mux_2_ss CompToTest_gate(A1_s, A0_s, B1_s, B0_s, C1_s, C0_s, 
	                             D1_s, D0_s, S1_s, S0_s,Out1_gs, Out0_gs);
   
   initial begin
    A1_s <= 0; A0_s <= 0; 
	  B1_s <= 0; B0_s <= 1; 
	  C1_s <= 1; C0_s <= 0; 
	  D1_s <= 1; D0_s <= 1;
	  S1_s <= 0; S0_s <= 0;
      
      #10 A1_s <= 0; A0_s <= 0; 
	  B1_s <= 0; B0_s <= 1; 
	  C1_s <= 1; C0_s <= 0; 
	  D1_s <= 1; D0_s <= 1;
	  S1_s <= 0; S0_s <= 1;
      
      #10 A1_s <= 0; A0_s <= 0; 
	  B1_s <= 0; B0_s <= 1; 
	  C1_s <= 1; C0_s <= 0; 
	  D1_s <= 1; D0_s <= 1;
	  S1_s <= 1; S0_s <= 0;

      #10 A1_s <= 0; A0_s <= 0; 
	  B1_s <= 0; B0_s <= 1; 
	  C1_s <= 1; C0_s <= 0; 
	  D1_s <= 1; D0_s <= 1;
	  S1_s <= 1; S0_s <= 1;
      #10 ; 
  end

endmodule

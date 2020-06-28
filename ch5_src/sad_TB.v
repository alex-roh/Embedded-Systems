// ***********************************************************************
// TITLE       : Testbench for SAD_128   
// AUTHOR      : Yoonjin Kim 
// AFFILIATION : Dept. of CS, Sookmyung Women's University 
// DESCRIPTION : Testbench simulating SAD_128                     
// ***********************************************************************
`timescale 1 ns/1 ns
`define A_WIDTH 15
`define D_WIDTH 8
`define ITR     128
`define CA_WIDTH 7

module ykim_Testbench();
   reg Go_s;
   wire [(`A_WIDTH-1):0] A_Addr_s, B_Addr_s;
   wire [(`CA_WIDTH-1):0] C_Addr_s;
   wire [(`D_WIDTH-1):0] A_Data_s, B_Data_s, A_Di_s, B_Di_s;
   wire I_RW_s, I_En_s, O_RW_s, O_En_s, Done_s; 
   reg Clk_s, Rst_s, Rst_sm;
   reg [31:0] Ref[0:(`ITR-1)];
   wire [31:0] SAD_Out_s, C_Data_s;
   integer Index; 
   parameter ClkPeriod = 20;
   
   SAD CompToTest(Go_s, A_Addr_s, A_Data_s,
                  B_Addr_s, B_Data_s, C_Addr_s, 
		  I_RW_s, I_En_s, O_RW_s, O_En_s, 
                  Done_s, SAD_Out_s, Clk_s, Rst_s);
   
   Sram_Operand SADMemA(A_Di_s, A_Data_s, A_Addr_s, I_RW_s, 
                        I_En_s, Clk_s, Rst_sm);
   Sram_Operand SADMemB(B_Di_s, B_Data_s, B_Addr_s, I_RW_s, 
                        I_En_s, Clk_s, Rst_sm);
   Sram_Result  SADMemC(SAD_Out_s, C_Data_s, C_Addr_s, O_RW_s, 
                        O_En_s, Clk_s, Rst_s);		

   // Clock Procedure
   always begin
      Clk_s <= 1'b0; #(ClkPeriod/2);
      Clk_s <= 1'b1; #(ClkPeriod/2);
   end

   // Initialize Arrays
   initial $readmemh("MemA.txt", SADMemA.Memory);
   initial $readmemh("MemB.txt", SADMemB.Memory);
   initial $readmemh("sw_result.txt", Ref);
   // Vector Procedure
   initial begin
      Rst_sm <= 1'b0; Rst_s <= 1'b1; Go_s <= 1'b0; 
      @(posedge Clk_s);
      Rst_s <= 1'b0; Go_s <= 1'b1;
      @(posedge Clk_s);
      Go_s <= 1'b0;
      @(posedge Clk_s);
      
      while(Done_s != 1'b1) 
      	     @(posedge Clk_s);
      
      @(posedge Clk_s);
            
      for(Index=0;Index<`ITR;Index=Index+1) begin 
      	
	if (SADMemC.Memory[Index] != Ref[Index]) 
         	$display("%d. SAD failed with %x from HW -- should equal %x from SW.", Index, SADMemC.Memory[Index], Ref[Index]);
      	else 
	 	$display("%d. SAD is %x from HW -- It is equal to %x from SW", Index, SADMemC.Memory[Index], Ref[Index]);
      
       end  
      
      $stop; 
  
  end

endmodule


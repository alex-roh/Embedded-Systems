`timescale 1 ns/1 ns
`define A_WIDTH 13
`define D_WIDTH 8

module Testbench_Reg();
	
	reg Go_s;
	reg Clk_s, Rst_s, Rst_m;
	wire [(`D_WIDTH - 1):0] L_In_s, M_In_s;
	wire [(`D_WIDTH - 1):0] L_Out_s, P_Out_s;
	wire [(`D_WIDTH - 1):0] M_Data_s, P_Data_s;
	wire [(`A_WIDTH - 1):0] M_Addr_s, L_Addr_s, P_Addr_s;
	wire M_En_s, M_Rw_s, L_En_s, L_Rw_s, P_En_s, P_Rw_s, Done_s;
	integer Index;
	reg Error_Flag;
	reg [(`D_WIDTH-1):0] Ref [0:(2**`A_WIDTH-1)];

	ShortestPath_4 CompToTest(Go_s, Clk_s, Rst_s, L_In_s, M_In_s,
				L_Out_s, P_Out_s, 
				M_Addr_s, L_Addr_s, P_Addr_s, 
				M_En_s, M_Rw_s, L_En_s, L_Rw_s, P_En_s, P_Rw_s, Done_s);
	
	// module SRAM(Data_In, Data_Out, Addr, RW, En, Clk, Rst);
	SRAM_Memory L_Memory(L_Out_s, L_In_s, L_Addr_s, L_Rw_s, L_En_s, Clk_s, Rst_s);
	SRAM_Memory M_Memory(M_Data_s, M_In_s, M_Addr_s, M_Rw_s, M_En_s, Clk_s, Rst_m);
	SRAM_Memory P_Memory(P_Out_s, P_Data_s, P_Addr_s, P_Rw_s, P_En_s, Clk_s, Rst_s);

	// Clock Procedure
	always begin
		Clk_s <= 1'b0; #10;
		Clk_s <= 1'b1; #10;
	end

	// Initialize Array
	initial $readmemh("memM.txt", M_Memory.Memory);
	initial $readmemh("sw_output.txt", Ref);

	// Vector Procedure
	initial begin
		// reset L, P, and Module, and do not reset M
		Error_Flag <= 1'b0;
		Rst_s <= 1'b1;
		Go_s <= 1'b0; // don't start Module here
		Rst_m <= 1'b0;
		@(posedge Clk_s);
		// Start Module
		Rst_s <= 1'b0;
		Go_s <= 1'b1;
		@(posedge Clk_s);
		Go_s <= 1'b0;
		// run Module until it ends
		while(Done_s != 1'b1) @(posedge Clk_s);
		@(posedge Clk_s);
		// check results
		for(Index=0;Index<(2**`A_WIDTH);Index=Index+1) begin
			#5; if(P_Memory.Memory[Index] != Ref[Index]) begin
				Error_Flag <= 1'b1;
				$display("%d. failed with : %x from HW -- should equal to %x from SW.", Index, P_Memory.Memory[Index], Ref[Index]);
			end
			else begin
				$display("%d. succeeded with : %x from HW -- is equal to %x from SW.", Index, P_Memory.Memory[Index], Ref[Index]);
			end
		end
		if(Error_Flag == 1'b1) begin
			$display("Hardware Failed");
		end
		else begin
			$display("Hardware Succeeded");
		end
		$stop;
	end

endmodule
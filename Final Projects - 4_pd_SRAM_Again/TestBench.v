
`timescale 1 ns/1 ns
`define A_WIDTH 13
`define D_WIDTH 8
`define A_INIT_WIDTH 11
`define D_INIT_WIDTH 32

module Testbench();
	
	reg Go_s;
	reg Clk_s; // clka, clkb
	wire Done_s;

	// for A port (module)
	wire [(`A_WIDTH - 1):0] L_Addr_A_s, M_Addr_A_s, P_Addr_A_s; // addra
	wire [(`D_WIDTH - 1):0] L_Out_A_s, M_Out_A_s, P_Out_A_s; // dina
	wire [(`D_WIDTH - 1):0] L_In_A_s, M_In_A_s, P_In_A_s; // douta
 	wire L_En_A_s, M_En_A_s, P_En_A_s; // ena
	reg  Rst_A_s, M_Rst_A_s; // sinita
	wire L_We_A_s, M_We_A_s, P_We_A_s; // wea 

	// for B port (initialization)
	reg [(`A_INIT_WIDTH - 1):0] L_Addr_B_s, M_Addr_B_s, P_Addr_B_s; // addra
	reg [(`D_INIT_WIDTH - 1):0] L_Out_B_s, M_Out_B_s, P_Out_B_s; // dina ('Out' from module's point of view)
	wire [(`D_INIT_WIDTH - 1):0] L_In_B_s, M_In_B_s, P_In_B_s; // douta ('In' from module's point of view)
 	reg L_En_B_s, M_En_B_s, P_En_B_s; // ena
	reg Rst_B_s, M_Rst_B_s; // sinita
	reg L_We_B_s, M_We_B_s, P_We_B_s; // wea 

	// internal variable for TestBench
	integer Index, P_Temp;
	reg Error_Flag;
	
	reg [(`D_INIT_WIDTH-1):0] M [0:(2**`A_INIT_WIDTH-1)];
	reg [(`D_INIT_WIDTH-1):0] Ref [0:(2**`A_INIT_WIDTH-1)];

	// (use A port) module ShortestPath(Go, Clk, Rst, L_In, M_In, L_Out, P_Out, M_Addr, L_Addr, P_Addr, M_En, M_Rw, L_En, L_Rw, P_En, P_Rw, Done);
	ShortestPath_4 CompToTest(Go_s, Clk_s, Rst_A_s, L_In_A_s, M_In_A_s, L_Out_A_s, P_Out_A_s, M_Addr_A_s, L_Addr_A_s, P_Addr_A_s, M_En_A_s, M_We_A_s,
				L_En_A_s, L_We_A_s, P_En_A_s, P_We_A_s, Done_s);
	
	// module dp_sram_coregen( addra, addrb, clka, clkb, dina, dinb, douta, doutb, ena, enb, sinita, sinitb, wea, web);
	dp_sram_coregen L_Memory(L_Addr_A_s, L_Addr_B_s, Clk_s, Clk_s, L_Out_A_s, L_Out_B_s, L_In_A_s, L_In_B_s, L_En_A_s, L_En_B_s, Rst_A_s, Rst_B_s, L_We_A_s, L_We_B_s);
	dp_sram_coregen M_Memory(M_Addr_A_s, M_Addr_B_s, Clk_s, Clk_s, M_Out_A_s, M_Out_B_s, M_In_A_s, M_In_B_s, M_En_A_s, M_En_B_s, M_Rst_A_s, M_Rst_B_s, M_We_A_s, M_We_B_s);
	dp_sram_coregen P_Memory(P_Addr_A_s, P_Addr_B_s, Clk_s, Clk_s, P_Out_A_s, P_Out_B_s, P_In_A_s, P_In_B_s, P_En_A_s, P_En_B_s, Rst_A_s, Rst_B_s, P_We_A_s, P_We_B_s);

	// Clock Procedure
	always begin
		Clk_s <= 1'b0; #10;
		Clk_s <= 1'b1; #10;
	end

	// Initialize Array
	initial $readmemh("Memory_M.txt", M);
	initial $readmemh("SW_Result.txt", Ref);

	// Vector Procedure
	initial begin
		// TestBench Start
		Error_Flag <= 1'b0;
		Rst_B_s <= 1'b0;
		@(posedge Clk_s);
		
		// Input Data
		for(Index = 0; Index < (2**`A_INIT_WIDTH); Index = Index+1) begin
			M_En_B_s <= 1'b1;
			M_We_B_s <= 1'b1; // write M
			M_Addr_B_s <= Index;
			M_Out_B_s <= M[Index];
			@(posedge Clk_s);
		end
		
		// Input Data Ended
		M_En_B_s <= 1'b0;
		M_We_B_s <= 1'b0;
		@(posedge Clk_s);

		// Run Module
		Rst_A_s = 1'b1;
		Go_s <= 1'b0;
		@(posedge Clk_s);
		Rst_A_s = 1'b0;
		Go_s <= 1'b1;
		@(posedge Clk_s);
		Go_s <= 1'b0;
		// Run Module until it ends
		while(Done_s != 1'b1) #5; @(posedge Clk_s);
		@(posedge Clk_s);

		// Check Results
		for(Index = 0; Index < (2**`A_INIT_WIDTH); Index = Index+1) begin
			P_En_B_s <= 1'b1;
			P_We_B_s <= 1'b0; // read P
			P_Addr_B_s <= Index;
			@(posedge Clk_s);
			#5; if(P_In_B_s != Ref[Index]) begin
				Error_Flag <= 1'b1;
				$display("%d. failed with : %x from HW -- should equal to %x from SW.", Index, P_In_B_s, Ref[Index]);
			end
			@(posedge Clk_s);
		end
		// Check Error
		if(Error_Flag == 1'b1) begin
			$display("Hardware Failed");
		end
		else begin
			$display("Hardware Succeeded");
		end
		$stop;
	end

endmodule
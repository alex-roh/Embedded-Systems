`timescale 1 ns/1 ns

module TestBench();

	// internal variables
	reg [12:0] Index;

	// for store time
	reg [31:0] Time;
	reg [12:0] Correct;

	// For Module
	reg [2:0] In_s;
	reg S_s, Clk_s, Reset_s;
	wire U_s;

	// Module Instantiation	
	CodeDetector CompToTest(S_s, In_s, U_s, Clk_s, Reset_s);
	
	// Clock Procedure
	always begin
		Clk_s <= 0;
		#10;
		Clk_s <= 1;
		#10;
	end

	// Vector Procedure
	initial begin
		for(Index = 13'b0_000_000_000_000; Index < 13'b1_000_000_000_000; Index = Index + 1'b1)
		begin
			// Synchronous Reset
			Reset_s <= 1;
			@(posedge Clk_s);
			// current: Wait State
			#5 S_s <= 1; Reset_s <= 0;
			@(posedge Clk_s);
			// current: Start State
			#5 In_s <= Index[2:0]; S_s <= 0;
			@(posedge Clk_s);
			// current: (idealy) Red1 State, (otherwise) Wait/Red1 State
			#5 In_s <= Index[5:3];
			@(posedge Clk_s);
			// current: (idealy) Blue State, (otherwise) Wait/Blue State
			#5 In_s <= Index[8:6];
			@(posedge Clk_s);
			// current: (idealy) Green State, (otherwise) Wait/Green State
			#5 In_s <= Index[11:9];
			@(posedge Clk_s);
			// current: (idealy) Red2 State, (otherwise) Wait/Red2 State
			// Check if output U = 1 or not
			#5;
			if(U_s == 1) begin
				$display("%t: %b is correct!", $time, Index);
				Time <= $time;
				Correct <= Index;
			end
			else begin
				$display("%t: %b is incorrect!", $time, Index);
			end
		end
		$display("%t: %b is correct!", Time, Correct);
		$stop;
	end


endmodule

`timescale 1 ns/1 ns

module CodeDetector(S, In, U, Clk, Reset);

	input S;
	input [2:0] In;
	output reg U;
	input Clk, Reset;
 
	// State encoding
	parameter Wait = 0, Start = 1,
		  Red1 = 2, Blue = 3,
		  Green = 4, Red2 = 5;
             
	reg [2:0] State, StateNext;
   
	// State Register 
	always @(posedge Clk) begin
		if (Reset == 1) begin // Synchronous Reset
			State <= Wait;
		end
		else begin
			State <= StateNext;
		end
	end

	// Combinational Logic
	always @(State, S, In) begin
		case(State)
		Wait: begin
			U <= 0;
			if(S == 1'b1) begin
				StateNext <= Start;
			end
		end
		Start: begin
			U <= 0;
			if(In == 3'b100) begin // red-blue'-green'
				StateNext <= Red1;
			end
			else if(In == 3'b000) begin
				StateNext <= Start;
			end
			else begin
				StateNext <= Wait;
			end
		end
		Red1: begin
			U <= 0;
			if(In == 3'b010) begin // red'-blue-green'
				StateNext <= Blue;
			end
			else if(In == 3'b000) begin
				StateNext <= Red1;
			end
			else begin
				StateNext <= Wait;
			end
		end
		Blue: begin
			U <= 0;
			if(In == 3'b001) begin // red'-blue'-green
				StateNext <= Green;
			end
			else if(In == 3'b000) begin
				StateNext <= Blue;
			end
			else begin
				StateNext <= Wait;
			end
		end
		Green: begin
			U <= 0;
			if(In == 3'b100) begin // red-blue'-green'
				StateNext <= Red2;
			end
			else if(In == 3'b000) begin
				StateNext <= Green;
			end
			else begin
				StateNext <= Wait;
			end
		end
		Red2: begin
			U <= 1;
			StateNext <= Wait;
		end
		default: begin // initialize input ports and go to Wait state
			StateNext <= Wait;
		end
		endcase
	end
endmodule
  

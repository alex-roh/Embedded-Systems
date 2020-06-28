`timescale 1 ns/1 ns

module ModifiedSAD(A_in, B_in, Rst, Go, Sad_Out, A_Addr, B_Addr, AB_En, AB_Rw, C_Addr, C_En, C_Rw, Clk, Done);

	// input
	input Go;
	input [7:0] A_in, B_in;
	input Rst;
	input Clk;
	
	// output
	output reg [31:0] Sad_Out;
	output reg [14:0] A_Addr, B_Addr;
	output reg AB_En, AB_Rw, C_En, C_Rw, Done;
	output reg [6:0] C_Addr;

	// internal variables
	integer I, J, K;
	integer Sum;
	
	// State Encoding
	parameter S0 = 0, S1 = 1, S2 = 2, S2a = 3, S3 = 4, S4 = 5; 

	// State Register
	reg [2:0] State;

	always@(posedge Clk) begin
		// reset
		if(Rst == 1'b1) begin
			I <= 0; J <= 0; K <= 0;
			Sad_Out <= 0;
			Sum <= 0;
			A_Addr <= 0;	
			B_Addr <= 0;
			AB_En <= 0;
			AB_Rw <= 0;
			C_En <= 0;
			C_Rw <= 0;
			Done <= 0;
			State <= S0;
		end
		else begin
			// set values to default before every state
			A_Addr <= 0;
			B_Addr <= 0;
			C_Addr <= 0;
			AB_En <= 0;
			AB_Rw <= 0;
			C_En <= 0;
			C_Rw <= 0;
			Sad_Out <= 0;
			Done <= 0;
			case(State)
				// after rising edge of clock : S0
				S0: begin
					if(Go == 1'b1) begin
						State <= S1;
						I <= 0; J <= 0; K <= 0;
					end
					else
						State <= S0;
				end
				// after rising edge of clock : S1
				S1: begin
					Sum <= 0;
					J <= 0;
					State <= S2;
				end
				// after rising edge of clock : S2
				S2: begin
					if(J < 256) begin
						A_Addr <= I;
						B_Addr <= I;
						AB_En <= 1; // en == 1 && rd == 0 : read
						AB_Rw <= 0;
						State <= S2a;
					end
					else
						State <= S4;
				end
				S2a: begin
				// after rising edge of clock : S2a
				// Memory reads AB_Addr, AB_En, AB_Rd
					State <= S3;
				end
				S3: begin
				// after rising edge of clock : S3
				// Memory yields output
					if (A_in > B_in)
						Sum <= Sum + (A_in - B_in);
					else				
						Sum <= Sum + (B_in - A_in);
					I <= I + 1;
					J <= J + 1;
					State <= S2;
				end
				S4: begin
				// after rising edge of clock : S4
					Sad_Out <= Sum;
					C_En <= 1; // en == 1 && rd == 1 : write
					C_Rw <= 1;
					C_Addr = K;
					K = K + 1;
					if(I < 32768) begin
						State <= S1;
					end
					else begin
						State <= S0;
						Done <= 1'b1;
					end
				end
			endcase
		end
	end

endmodule

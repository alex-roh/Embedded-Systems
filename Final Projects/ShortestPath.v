`timescale 1 ns/1 ns
`define MAX 8192
`define SIZE_ROW 4
`define D_WIDTH 8
`define A_WIDTH 13

module ShortestPath(Go, Clk, Rst, L_In, M_In, L_Out, P_Out, M_Addr, L_Addr, P_Addr, 
				M_En, M_Rw, L_En, L_Rw, P_En, P_Rw, Done);

	input Go;
	input Clk, Rst;
	input [(`D_WIDTH - 1):0] L_In, M_In;
	output reg [(`D_WIDTH - 1):0] L_Out;
	output reg [(`D_WIDTH - 1):0] P_Out;
	output reg [(`A_WIDTH - 1):0] M_Addr, L_Addr, P_Addr;
	output reg M_En, M_Rw, L_En, L_Rw, P_En, P_Rw, Done;

	
	reg [(`D_WIDTH - 1):0] M_Reg, L_Reg, L_Temp_Reg;
	reg [3:0] State;
	integer I, I_Base, J, Addr0, Addr1, Addr2;

	parameter S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011,
		  S4a = 4'b0100, S4b = 4'b0101, S4c = 4'b0110,
		  S5a = 4'b0111, S5b = 4'b1000, S5c = 4'b1001,
		  S6a = 4'b1010, S6b = 4'b1011, S6c = 4'b1100, S6d = 4'b1101, S7 = 4'b1110;
	parameter Start = 8'b0000_1000, Right = 8'b0000_1001, Down = 8'b0000_1010;

	always @(posedge Clk) begin
		if(Rst == 1) begin
			// output regs
			L_Out <= {`D_WIDTH{1'b0}}; 
			P_Out <= {`D_WIDTH{1'b0}};
			M_Addr <= {`A_WIDTH{1'b0}};
			L_Addr <= {`A_WIDTH{1'b0}};
			P_Addr <= {`A_WIDTH{1'b0}};
			M_En <= 1'b0;
			M_Rw <= 1'b0;
			L_En <= 1'b0;
			L_Rw <= 1'b0;
			P_En <= 1'b0;
			P_Rw <= 1'b0;
			Done <= 1'b0;
			// internal reg
			M_Reg <= {`D_WIDTH - 1{1'b0}};
			L_Reg <= {`D_WIDTH - 1{1'b0}};
			L_Temp_Reg <={`D_WIDTH - 1{1'b0}};
			State <= S0;
			I <= 0;
			J <= 0;
			I_Base <= 0;
			Addr0 <= 0;
			Addr1 <= 0;
			Addr2 <= 0;
		end
		else begin
			// outputs
			L_Out <= {`D_WIDTH{1'b0}}; 
			P_Out <= {`D_WIDTH{1'b0}};
			M_Addr <= {`A_WIDTH{1'b0}};
			L_Addr <= {`A_WIDTH{1'b0}};
			P_Addr <= {`A_WIDTH{1'b0}};
			M_En <= 1'b0;
			M_Rw <= 1'b0;
			L_En <= 1'b0;
			L_Rw <= 1'b0;
			P_En <= 1'b0;
			P_Rw <= 1'b0;
			Done <= 1'b0;
			
			case(State)
				// Initial State
				S0: begin // 0
					if(Go == 1'b1) begin
						State <= S1;
					end
					else begin
						State <= S0;
					end
				end
				// I loop
				S1: begin // 1
					if(I_Base <= 100) begin
						$display("S1: I : %d, J : %d, I_Base = %d", I, J, I_Base);
					end
					if(I_Base >= `MAX) begin
						// algorithm ended
						Done <= 1'b1;
						State <= S0;
					end
					else if(I_Base + I < I_Base + `SIZE_ROW) begin
						J <= 0;
						State <= S2;
					end
					else begin
						I_Base = I_Base + I;
						I <= 0;
						State <= S1;
					end
				end
				S2: begin // 2
					// Inside of J loop
					if(J < `SIZE_ROW) begin
						Addr0 <= (I_Base + I) * `SIZE_ROW + J;
						Addr1 <= (I_Base + I - 1) * `SIZE_ROW + J;
						Addr2 <= (I_Base + I) * `SIZE_ROW + (J - 1);
						State <= S3;
					end
					else begin
						I = I + 1;
						State <= S1;
					end
				end
				S3: begin // 3
					if(I == 0 && J == 0) begin
						// prepare to write output memory P
						P_Out <= Start;
						P_En <= 1'b1;
						P_Rw <= 1'b1; // write P
						P_Addr <= Addr0;
						// prepare to read input memory M
						M_En <= 1'b1;
						M_Rw <= 1'b0; // read M	
						M_Addr <= Addr0;				
						State <= S4a;
					end
					else if(I == 0) begin
						// prepare to write output memory P
						P_Out <= Right;
						P_En <= 1'b1;
						P_Rw <= 1'b1; // write P
						P_Addr <= Addr0;
						// prepare to read input memory M
						M_En <= 1'b1;
						M_Rw <= 1'b0; // read M	
						M_Addr <= Addr0;				
						// prepare to read in/out memory L
						L_En <= 1'b1;
						L_Rw <= 1'b0; // read L
						L_Addr <= Addr2;				
						State <= S5a;
					end
					else if(J == 0) begin
						// prepare to write output memory P
						P_Out <= Down;
						P_En <= 1'b1;
						P_Rw <= 1'b1; // write P
						P_Addr <= Addr0;
						// prepare to read input memory M
						M_En <= 1'b1;
						M_Rw <= 1'b0; // read M	
						M_Addr <= Addr0;				
						// prepare to read in/out memory L
						L_En <= 1'b1;
						L_Rw <= 1'b0; // read L
						L_Addr <= Addr1;				
						State <= S5a;	
					end
					else begin
						// prepare to read in/out memory L
						L_En <= 1'b1;
						L_Rw <= 1'b0; // read L
						L_Addr <= Addr1;				
						State <= S6a;		
					end
				end
				// i == 0 && j == 0
				S4a: begin // 4
					// input memory M will be ready in one state
					State <= S4b;	
				end
				S4b: begin // 5
					// M_reg will be ready in one state
					M_Reg <= M_In;	
					State <= S4c;
				end
				S4c: begin // 6
					// prepare to write in/out memory L
					L_Out <= M_Reg;
					L_En <= 1'b1;
					L_Rw <= 1'b1; // write L
					L_Addr <= Addr0;
					// plus J by 1
					J = J + 1;
					State <= S2;
				end
				// i == 0 || j == 0
				S5a: begin // 7
					// output memory P will be ready in one state
					// input memory M will be ready in one state
					// in/out memory L will be ready in one state
					State <= S5b;		
				end
				S5b: begin // 8
					M_Reg <= M_In;	
					L_Reg <= L_In;
					State <= S5c;	
				end
				S5c: begin // 9
					// prepare to write in/out memory L
					L_Out <= M_Reg + L_Reg;
					L_En <= 1'b1;
					L_Rw <= 1'b1; // write L
					L_Addr <= Addr0;
					// plus J by 1
					J = J + 1;
					State <= S2;
				end
				// else : preparation
				S6a: begin // 10
					// in/out memory L will be ready in one state	
					State <= S6b;	
				end
				S6b: begin // 11
					L_Reg <= L_In;
					// prepare to read in/out memory L
					L_En <= 1'b1;
					L_Rw <= 1'b0; // read L
					L_Addr <= Addr2;				
					State <= S6c;		
				end
				S6c: begin // 12
					State <= S6d;
				end
				S6d: begin // 13
					L_Temp_Reg <= L_In;
					State <= S7;
				end
				// else : starts
				S7: begin // 14
					if(L_Reg < L_Temp_Reg) begin
						// prepare to write output memory P
						P_Out <= Down;
						P_En <= 1'b1;
						P_Rw <= 1'b1; // write P
						P_Addr <= Addr0;
						// prepare to read input memory M
						M_En <= 1'b1;
						M_Rw <= 1'b0; // read M	
						M_Addr <= Addr0;				
						// prepare to read in/out memory L
						L_En <= 1'b1;
						L_Rw <= 1'b0; // read L
						L_Addr <= Addr1;				
						State <= S5a;	
					end
					else begin
						// prepare to write output memory P
						P_Out <= Right;
						P_En <= 1'b1;
						P_Rw <= 1'b1; // write P
						P_Addr <= Addr0;
						// prepare to read input memory M
						M_En <= 1'b1;
						M_Rw <= 1'b0; // read M	
						M_Addr <= Addr0;				
						// prepare to read in/out memory L
						L_En <= 1'b1;
						L_Rw <= 1'b0; // read L
						L_Addr <= Addr2;				
						State <= S5a;
					end
				end
			endcase
		end
	end
	
endmodule 

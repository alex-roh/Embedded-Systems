`timescale 1 ns/1 ns
`define MAX 65536
`define SIZE_ROW 4
`define D_WIDTH 8
`define A_WIDTH 16

module ShortestPath_4(Go, Clk, Rst, L_In, M_In, L_Out, P_Out, M_Addr, L_Addr, P_Addr, 
				M_En, M_Rw, L_En, L_Rw, P_En, P_Rw, Done);
	// Inputs
	input Go;
	input Clk, Rst;

	// Outputs
	input [(`D_WIDTH - 1):0] L_In, M_In;
	output reg [(`D_WIDTH - 1):0] L_Out;
	output reg [(`D_WIDTH - 1):0] P_Out;
	output reg [(`A_WIDTH - 1):0] M_Addr, L_Addr, P_Addr;
	output reg M_En, M_Rw, L_En, L_Rw, P_En, P_Rw, Done;

	// Controller Variables	
	reg [(`D_WIDTH - 1):0] M_Reg, L_Reg, L_Temp_Reg;
	reg [3:0] State, StateNext;
	reg [3:0] Flag, FlagNext;
	
	// Shared Variables
	integer I, I_Base, J;
	
	// Datapath Variables
	integer Addr0, Addr1, Addr2, Addr0Next, Addr1Next, Addr2Next;

	// parameters
	parameter S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011,
		  S4 = 4'b0100, S4a = 4'b0101, S5 = 4'b0110,
		  S5a = 4'b0111, S6 = 4'b1000, S6a = 4'b1001, S7 = 4'b1010;
	parameter Start = 8'b0000_1000, Right = 8'b0000_1001, Down = 8'b0000_1010;
	parameter Default = 4'b1111, S1_Second = 4'b0000, S1_Third = 4'b0001;

	// State Register : Clock Procedure
	always @(posedge Clk) begin
		if(Rst == 1'b1) begin
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
			I <= 0;
			J <= 0;
			I_Base <= 0;
			Addr0 <= 0;
			Addr1 <= 0;
			Addr2 <= 0;
			// goto S0
			State <= S0;
			Flag <= Default;
			FlagNext <= Default;
		end
		else begin
			Flag <= FlagNext;
			State <= StateNext;
		end
	end
	
	// State Register : Combinational Logic
	always @(State, Flag) begin
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
		FlagNext <= 1'b0;
		case(State)
			S0: begin
				if(Go == 1'b1) begin
					StateNext <= S2;
				end
				else begin
					StateNext <= S0;
				end
			end
			S1: begin
				if(I_Base >= `MAX) begin
					Done <= 1'b1;
					StateNext <= S0;
				end
				else if(I_Base + I < I_Base + `SIZE_ROW) begin
					J <= 0;
					StateNext <= S2;
					FlagNext <= S1_Second;
				end
				else begin
					I_Base = I_Base + I;
					I <= 0; 
					StateNext <= S1;
					FlagNext <= S1_Third;	
				end
			end
			S2: begin
				if(J < `SIZE_ROW) begin
					StateNext <= S3;
				end
				else begin
					I = I + 1;
					StateNext <= S1;
				end
			end
			S3: begin
				if(I == 0 && J == 0) begin
					P_Out <= Start;
					P_En <= 1'b1;
					P_Rw <= 1'b1; // write P
					P_Addr <= Addr0;
					M_En <= 1'b1;
					M_Rw <= 1'b0; // read M	
					M_Addr <= Addr0;				
					StateNext <= S4;
				end
				else if(I == 0) begin
					P_Out <= Right;
					P_En <= 1'b1;
					P_Rw <= 1'b1; // write P
					P_Addr <= Addr0;
					M_En <= 1'b1;
					M_Rw <= 1'b0; // read M	
					M_Addr <= Addr0;				
					L_En <= 1'b1;
					L_Rw <= 1'b0; // read L
					L_Addr <= Addr2;				
					StateNext <= S5;
					end
				else if(J == 0) begin
					P_Out <= Down;
					P_En <= 1'b1;
					P_Rw <= 1'b1; // write P
					P_Addr <= Addr0;
					M_En <= 1'b1;
					M_Rw <= 1'b0; // read M	
					M_Addr <= Addr0;			
					L_En <= 1'b1;
					L_Rw <= 1'b0; // read L
					L_Addr <= Addr1;				
					StateNext <= S5;	
				end
				else begin
					L_En <= 1'b1;
					L_Rw <= 1'b0; // read L
					L_Addr <= Addr1;				
					StateNext <= S6;
				end
			end
			S4: begin
				L_Reg <= M_In;
				StateNext <= S4a;
			end
			S4a: begin
				L_Out <= L_Reg;
				L_En <= 1'b1;
				L_Rw <= 1'b1; // write L
				L_Addr <= Addr0;
				J <= J + 1; // plus J by 1
				StateNext <= S2;
			end
			S5: begin
				M_Reg <= M_In;
				L_Reg <= L_In;
				StateNext <= S5a;
			end
			S5a: begin
				L_Out <= M_Reg + L_Reg;
				L_En <= 1'b1;
				L_Rw <= 1'b1; // write L
				L_Addr <= Addr0;
				J <= J + 1; // plus J by 1
				StateNext <= S2;
			end
			S6: begin
				L_Reg <= L_In;
				L_En <= 1'b1;
				L_Rw <= 1'b0; // read L
				L_Addr <= Addr2;				
				StateNext <= S6a;	
			end
			S6a: begin
				L_Temp_Reg <= L_In;
				StateNext <= S7;
			end
			S7: begin
				if(L_Reg < L_Temp_Reg) begin
					P_Out <= Down;
					P_En <= 1'b1;
					P_Rw <= 1'b1; // write P
					P_Addr <= Addr0;
					M_En <= 1'b1;
					M_Rw <= 1'b0; // read M 
					M_Addr <= Addr0;			
					L_En <= 1'b1;
					L_Rw <= 1'b0; // read L 
					L_Addr <= Addr1;				
					StateNext <= S5;	
				end
				else begin
					P_Out <= Right;
					P_En <= 1'b1;
					P_Rw <= 1'b1; // write P
					P_Addr <= Addr0;
					M_En <= 1'b1;
					M_Rw <= 1'b0; // read M	
					M_Addr <= Addr0;			
					L_En <= 1'b1;
					L_Rw <= 1'b0; // read L
					L_Addr <= Addr2;				
					StateNext <= S5;
				end	
			end
			default: begin
				$display("Fatal Error Occurred!");
				$stop;
			end
		endcase
	end

	// Datapath Register : Clock Procedure
	always @(posedge Clk) begin
		if(Rst == 1'b1) begin
			Addr0 <= 0;
			Addr0Next <= 0;
			Addr1 <= 0;
			Addr1Next <= 0;
			Addr2 <= 0;
			Addr2Next <= 0;
		end
		else begin
			Addr0 <= Addr0Next;
			Addr1 <= Addr1Next;
			Addr2 <= Addr2Next;
		end
	end

	// Datapath : Combinational Logic
	always @(J, I, I_Base) begin
		Addr0Next <= (I_Base + I) * `SIZE_ROW + J;
		Addr1Next <= (I_Base + I - 1) * `SIZE_ROW + J;
		Addr2Next <= (I_Base + I) * `SIZE_ROW + (J - 1);
	end

endmodule
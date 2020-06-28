
`timescale 1 ns/1 ns

module SRAM_result(Data_in, Addr, Rw, En, Clk, Rst, Data_out);
	
	input [31:0] Data_in; // 1 data unit = 4 byte
	input [6:0] Addr; // 2**7 = 128
	input Rw;
	input En;
	input Clk;
	input Rst;
	output reg [31:0] Data_out;
	reg [31:0] Memory [0:127];
	reg Index;

	always @(posedge Clk) begin
	Data_out <= 0;
	// synchronous reset
	if(Rst == 1) begin
		for(Index = 0; Index < 128; Index = Index + 1)
			Memory[Index] <= 0;		
	end
	// synchronous write
	else if(En == 1'b1 && Rw == 1'b1)
		Memory[Addr] <= Data_in;	
	// synchronous read	
	else if(En == 1'b1 && Rw == 1'b0)
		Data_out <= Memory[Addr];	
	end
	
endmodule

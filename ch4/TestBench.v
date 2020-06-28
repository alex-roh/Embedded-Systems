`timescale 1 ns/1 ns

module TestBench();

	reg Sh_dir_s;
	reg [31:0] Sh_amt_s;
	reg signed [31:0] D_in_s;
	wire [31:0] D_out_s;

	ArithmeticShifter ArithShift(Sh_dir_s, Sh_amt_s, D_in_s, D_out_s);

	initial begin
		$display("1.Shift-Right Operation Test with Negative Value!"); 
		D_in_s <= 32'b1000_0000_0000_0000_0000_0000_0000_0000;
		Sh_dir_s <= 0; // 0: shift right 
		Sh_amt_s <= 1;
		#10 $display("shift-right with amount %d is %4b_%4b_%4b_%4b_%4b_%4b_%4b_%4b", Sh_amt_s, 
			D_out_s[31:28], D_out_s[27:24], D_out_s[23:20], D_out_s[19:16], D_out_s[15:12],
			D_out_s[11:8], D_out_s[7:4], D_out_s[3:0]);
		Sh_amt_s <= 2;
		#10 $display("shift-right with amount %d is %4b_%4b_%4b_%4b_%4b_%4b_%4b_%4b", Sh_amt_s, 
			D_out_s[31:28], D_out_s[27:24], D_out_s[23:20], D_out_s[19:16], D_out_s[15:12],
			D_out_s[11:8], D_out_s[7:4], D_out_s[3:0]);
	end


endmodule

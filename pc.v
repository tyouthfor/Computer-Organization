`timescale 1ns / 1ps

module pc (
	input 	wire 			clk, rst, en, clear,
	input 	wire[31:0] 		pcnext,
	input	wire[31:0]		pc_except,
	output 	reg [31:0] 		q
    );
	
	always @(posedge clk) begin
		if (rst) begin
			q <= 32'hBFC00000;
		end
		else if (clear) begin
			q <= pc_except;
		end
		else if (en) begin
			q <= pcnext;
		end
	end
	
endmodule
`timescale 1ns / 1ps

/*
	模块名称: flopenrc
	模块功能: D 触发器
	输入:
		clk 			时钟信号
		rst 			复位信号
		en 				使能信号
		clear 			清空信号
		din 			输入数据
	输出:
		dout 			输出数据
*/
module flopenrc #(parameter WIDTH = 8)(
	input 	wire 				clk, rst, en, clear,
	input 	wire[WIDTH-1:0] 	din,
	output 	reg [WIDTH-1:0] 	dout
    );
	
	always @(posedge clk) begin
		if (rst) begin
			dout <= 0;
		end
		else if (clear) begin
			dout <= 0;
		end
		else if (en) begin
			dout <= din;
		end
	end
	
endmodule
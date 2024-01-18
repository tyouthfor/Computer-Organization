`timescale 1ns / 1ps

/*
	模块名称: mux2
	模块功能: 两路选择器
	输入:
		d0			1'b0-数据
		d1			1'b1-数据
		s			选择信号
	输出:
		y			选择数据
*/
module mux2 #(parameter WIDTH = 8)(
	input 	wire[WIDTH-1:0] 	d0, d1,
	input 	wire 				s,
	output 	wire[WIDTH-1:0] 	y
    );
	
	assign y = s ? d1 : d0;
	
endmodule
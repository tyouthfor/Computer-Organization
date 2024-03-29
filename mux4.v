`timescale 1ns / 1ps

/*
	模块名称: mux4
	模块功能: 四路选择器
	输入:
		d0			2'b00-数据
		d1			2'b01-数据
		d2			2'b10-数据
		d3			2'b11-数据
		s			选择信号
	输出:
		y			选择数据
*/
module mux4 #(parameter WIDTH = 8)(
	input 	wire[WIDTH-1:0] 	d0, d1, d2, d3,
	input 	wire[1:0] 			s,
	output 	wire[WIDTH-1:0] 	y
    );

	assign y = (
		(s == 2'b00) ? d0 :
		(s == 2'b01) ? d1 :
		(s == 2'b10) ? d2 : 
        (s == 2'b11) ? d3 : d0
	);
	
endmodule
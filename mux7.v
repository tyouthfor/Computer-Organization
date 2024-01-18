`timescale 1ns / 1ps

/*
	模块名称: mux7
	模块功能: 七路选择器
	输入:
		d0			3'b000-数据
		d1			3'b001-数据
		d2			3'b010-数据
		d3			3'b011-数据
		d4			3'b100-数据
		d5			3'b101-数据
		d6			3'b110-数据
		s			选择信号
	输出:
		y			选择数据
*/
module mux7 #(parameter WIDTH = 8)(
	input 	wire[WIDTH-1:0] 	d0, d1, d2, d3, d4, d5, d6,
	input 	wire[2:0] 			s,
	output 	wire[WIDTH-1:0] 	y
    );

	assign y = (
		(s == 3'b000) ? d0 :
		(s == 3'b001) ? d1 :
		(s == 3'b010) ? d2 : 
        (s == 3'b011) ? d3 : 
        (s == 3'b100) ? d4 :
        (s == 3'b101) ? d5 :
        (s == 3'b110) ? d6 : d0
	);
			   
endmodule
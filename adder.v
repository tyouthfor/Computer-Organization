`timescale 1ns / 1ps

/*
	模块名称: adder
	模块功能: 两位加法器
	输入:
		a		第一操作数
		b		第二操作数
	输出:
		y		加法运算结果
*/
module adder(
	input 	wire[31:0] 	a, b,
	output 	wire[31:0] 	y
    );

	assign y = a + b;
	
endmodule
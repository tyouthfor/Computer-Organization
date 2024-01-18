`timescale 1ns / 1ps

/*
	模块名称: signext
	模块功能: 立即数扩展单元
	输入:
		a			16 位立即数
		sign		0-无符号扩展, 1-符号扩展
	输出:
		y			32 位扩展结果
*/
module signext(
	input 	wire[15:0] 	a,
	input	wire		sign,
	output 	wire[31:0] 	y
    );

	assign y = sign ? {{16{a[15]}}, a} : {16'b0, a};

endmodule
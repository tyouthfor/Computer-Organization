`timescale 1ns / 1ps

module signext(
	/*
		模块坝称: signext
		模块功能: 立坳数扩展
		输入:
			a 		16 佝立坳数
			op 		0-无符坷扩展, 1-符坷扩展
		输出:
			y 		32 佝输出
	*/
	input 	wire[15:0] 	a,
	input	wire		op,
	output 	wire[31:0] 	y
    );

	assign y = op ? {{16{a[15]}}, a} : {16'b0, a};

endmodule

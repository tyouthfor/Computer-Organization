`timescale 1ns / 1ps

/*
	模块名称: pc
	模块功能: PC 寄存器
	输入:
		clk					时钟信号
		rst					复位信号
		en					使能信号
		clear				清空信号
		pcnext				正常情况下的下一条指令地址
		pc_except			触发例外时的下一条指令地址
	输出:
		q					指令地址
*/
module pc(
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
`timescale 1ns / 1ps

module regfile(
	/*
		模块名称: regfile
		模块功能: 寄存器堆
		输入:
			clk 	时钟信号
			we3 	写信号
			ra1 	读寄存器号-1
			ra2	 	读寄存器号-2
			wa3 	写寄存器号
			wd3		写入数据
		输出:
			rd1 	读出数据-1
			rd2 	读出数据-2
	*/
	input 	wire 		clk,
	input 	wire 		we3,
	input 	wire[4:0] 	ra1, ra2, wa3,
	input 	wire[31:0] 	wd3,
	output 	wire[31:0] 	rd1, rd2
    );

	reg[31:0] rf[31:0];

	always @(negedge clk) begin
		if (we3) begin
			rf[wa3] <= wd3;
		end
	end

	assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
	assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
	
endmodule

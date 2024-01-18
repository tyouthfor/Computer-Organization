`timescale 1ns / 1ps

/*
	模块名称: regfile
	模块功能: 通用寄存器堆
	输入:
		clk				时钟信号
		rst				复位信号
		we3				寄存器堆的写信号
		ra1				读寄存器堆地址-1
		ra2				读寄存器堆地址-2
		wa3				写寄存器堆地址
		wd3				写寄存器堆数据
	输出:
		rd1				从寄存器堆读出的数据-1
		rd2				从寄存器堆读出的数据-2
*/
module regfile(
	input 	wire 		clk, rst,
	input 	wire 		we3,
	input 	wire[4:0] 	ra1, ra2, wa3,
	input 	wire[31:0] 	wd3,
	output 	wire[31:0] 	rd1, rd2
    );

	integer t;
	reg[31:0] rf[31:0];

	always @(negedge clk) begin
		if (rst) begin
			rf <= '{default: '0};
            // for (t = 0; t < 31; t = t + 1) begin   
            //     rf[t] <= 0;
            // end
		end
		else if (we3) begin
			rf[wa3] <= wd3;
		end
	end

	assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
	assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
	
endmodule
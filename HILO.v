`timescale 1ns / 1ps
`include "defines.vh"

/*
    模块名称: HILO
    模块功能: HILO 寄存器
    输入:
        clk         时钟信号
        rst         复位信号
        we          HILO 寄存器的写信号
        wd          写 HILO 寄存器数据
    输出:
        rd          从 HILO 寄存器读出的数据
*/
module HILO(
	input 	wire 		clk, rst,
    input 	wire 		we,
	input 	wire[31:0] 	wd,
	output 	wire[31:0] 	rd
    );

	reg[31:0] register;

    always @(negedge clk) begin
		if (rst) begin
			register <= 0;
		end
        else if (we) begin
            register <= wd;
        end
    end

    assign rd = register;

endmodule
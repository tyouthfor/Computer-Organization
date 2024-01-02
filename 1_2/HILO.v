`timescale 1ns / 1ps
`include "defines.vh"

module HILO(
	/*
		模块名称: HILO
		模块功能: HILO 寄存器
		输入:
			clk 	时钟信号
			we 	    写信号
			wd		写入数据
		输出:
            rd      读出数据
	*/
	input 	wire 		clk,
    input 	wire 		we,
	input 	wire[31:0] 	wd,
	output 	wire[31:0] 	rd
    );

	reg[31:0] register;

    always @(negedge clk) begin
        if (we) begin
            register <= wd;
        end
    end

    assign rd = register;

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module maindec(
	/*
		模块名称: maindec
		模块功能: 主译码器
		输入:
			op instr[31:26]
		输出:
			regdst 		选择写寄存器号的来源. 0-rt, 1-rd
			alusrc 		选择 ALU 第二操作数的来源. 0-寄存器堆, 1-立即数
			memtoreg 	选择写入寄存器堆的数据来源. 0-ALU, 1-内存
			branch 		执行分支指令时置 1
			jump 		执行跳转指令时置 1
			memwrite 	内存的写信号
			regwrite 	寄存器堆的写信号
			aluop 		传给 aludec 的信号
	*/
	input 	wire[5:0] 	op,
	output 	wire 		memtoreg,memwrite,
	output 	wire 		branch,alusrc,
	output 	wire 		regdst,regwrite,
	output 	wire 		jump,
	output 	wire[1:0] 	aluop
    );

	`define R_TYPE 	~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0]
	`define LW 		op[5]  & ~op[4] & ~op[3] & ~op[2] & op[1]  & op[0]
	`define SW 		op[5]  & ~op[4] & op[3]  & ~op[2] & op[1]  & op[0]
	`define BEQ 	~op[5] & ~op[4] & ~op[3] & op[2]  & ~op[1] & ~op[0]
	`define J 		~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1]  & ~op[0]
	`define ADDI 	~op[5] & ~op[4] & op[3]  & ~op[2] & ~op[1] & ~op[0]

	assign regdst 	= `R_TYPE;
	assign alusrc 	= `LW | `SW | `ADDI;
	assign memtoreg = `LW;
	assign branch 	= `BEQ;
	assign jump		= `J;
	assign memwrite = `SW;
	assign regwrite = `R_TYPE | `LW | `ADDI;

	// LW/SW:  00
	// BEQ:    01
	// R_TYPE: 10
	// ADDI:   11
	assign aluop[1] = `R_TYPE | `ADDI;
	assign aluop[0] = `BEQ | `ADDI;

endmodule

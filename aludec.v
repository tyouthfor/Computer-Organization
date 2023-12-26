`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec
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


module aludec(
	/*
		模块名称: aludec
		模块功能: ALU 译码器
		输入:
			funct 		instr[5:0]
			aluop 		maindec 的输出
		输出:
			alucontrol 	ALU 的选择信号
	*/
	input 	wire[5:0] 	funct,
	input 	wire[1:0] 	aluop,
	output 	wire[2:0] 	alucontrol
    );

	`define ADD 	aluop[1]  & ~aluop[0] & funct[5] & ~funct[4] & ~funct[3] & ~funct[2] & ~funct[1] & ~funct[0]
	`define SUB 	aluop[1]  & ~aluop[0] & funct[5] & ~funct[4] & ~funct[3] & ~funct[2] & funct[1]  & ~funct[0]
	`define AND 	aluop[1]  & ~aluop[0] & funct[5] & ~funct[4] & ~funct[3] & funct[2]  & ~funct[1] & ~funct[0]
	`define OR  	aluop[1]  & ~aluop[0] & funct[5] & ~funct[4] & ~funct[3] & funct[2]  & ~funct[1] & funct[0]
	`define SLT 	aluop[1]  & ~aluop[0] & funct[5] & ~funct[4] & funct[3]  & ~funct[2] & funct[1]  & ~funct[0]
	`define LW  	~aluop[1] & ~aluop[0]
	`define SW  	~aluop[1] & ~aluop[0]
	`define BEQ 	~aluop[1] & aluop[0]
	`define ADDI 	aluop[1]  & aluop[0]

	// add: 010 (ADD, LW/SW, ADDI)
	// sub: 110 (SUB, BEQ)
	// and: 000 (AND)
	// or:  001 (OR)
	// slt: 111 (SLT)
	assign alucontrol[2] = `SUB | `BEQ | `SLT;
	assign alucontrol[1] = `ADD | `LW | `SW | `ADDI | `SUB | `BEQ | `SLT;
	assign alucontrol[0] = `OR | `SLT;

endmodule

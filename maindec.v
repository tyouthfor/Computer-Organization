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
		ģ������: maindec
		ģ�鹦��: ��������
		����:
			op instr[31:26]
		���:
			regdst 		ѡ��д�Ĵ����ŵ���Դ. 0-rt, 1-rd
			alusrc 		ѡ�� ALU �ڶ�����������Դ. 0-�Ĵ�����, 1-������
			memtoreg 	ѡ��д��Ĵ����ѵ�������Դ. 0-ALU, 1-�ڴ�
			branch 		ִ�з�ָ֧��ʱ�� 1
			jump 		ִ����תָ��ʱ�� 1
			memwrite 	�ڴ��д�ź�
			regwrite 	�Ĵ����ѵ�д�ź�
			aluop 		���� aludec ���ź�
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

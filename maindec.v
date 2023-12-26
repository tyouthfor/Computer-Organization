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

	reg[8:0] controls;
	always @(*) begin
		case (op)
			6'b000000: controls <= 9'b110000010;  // R-TYRE
			6'b100011: controls <= 9'b101001000;  // LW
			6'b101011: controls <= 9'b001010000;  // SW
			6'b000100: controls <= 9'b000100001;  // BEQ
			6'b001000: controls <= 9'b101000000;  // ADDI
			6'b000010: controls <= 9'b000000100;  // J
			default:   controls <= 9'b000000000;  // illegal op
		endcase
	end

	assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} = controls;
	
endmodule

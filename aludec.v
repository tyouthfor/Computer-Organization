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
		ģ������: aludec
		ģ�鹦��: ALU ������
		����:
			funct 		instr[5:0]
			aluop 		maindec �����
		���:
			alucontrol 	ALU ��ѡ���ź�
	*/
	input 	wire[5:0] 	funct,
	input 	wire[1:0] 	aluop,
	output 	reg [2:0] 	alucontrol
    );

	// add: 010
	// sub: 110
	// and: 000
	// or:  001
	// slt: 111
	// 011
	// 100
	// 101
	// ���λ: 1-����, 0-����
	always @(*) begin
		case (aluop)
			2'b00: alucontrol <= 3'b010;  // LW/SW/ADDI
			2'b01: alucontrol <= 3'b110;  // BEQ
			default: case (funct)
				6'b100000: alucontrol <= 3'b010;  // ADD
				6'b100010: alucontrol <= 3'b110;  // SUB
				6'b100100: alucontrol <= 3'b000;  // AND
				6'b100101: alucontrol <= 3'b001;  // OR
				6'b101010: alucontrol <= 3'b111;  // SLT
				default:   alucontrol <= 3'b000;
			endcase
		endcase
	end

endmodule

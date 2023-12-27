`timescale 1ns / 1ps
`include "defines.vh"

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
	output	wire		regdst, alusrc, memtoreg, branch, jump,
	output	wire		memwrite, regwrite,
	output 	reg [3:0] 	aluop
    );

	reg[6:0] controls;
	assign {regdst, alusrc, memtoreg, branch, jump, memwrite, regwrite} = controls;

	always @(*) begin
		case (op)
			// R-TYPE
			`op_RTYPE: 	begin controls <= 7'b1000001; aluop <= `aluop_RTYPE; end

			// I-TYPE ����������
			`op_ADDI: 	begin controls <= 7'b0100001; aluop <= `aluop_add; end
			`op_ADDIU: 	begin controls <= 7'b0100001; aluop <= `aluop_add; end
			`op_SLTI: 	begin controls <= 7'b0100001; aluop <= `aluop_slt; end
			`op_SLTIU: 	begin controls <= 7'b0100001; aluop <= `aluop_sltu; end
			`op_ANDI: 	begin controls <= 7'b0100001; aluop <= `aluop_and; end
			`op_LUI: 	begin controls <= 7'b0100001; aluop <= `aluop_LUI; end
			`op_ORI: 	begin controls <= 7'b0100001; aluop <= `aluop_or; end
			`op_XORI: 	begin controls <= 7'b0100001; aluop <= `aluop_xor; end
			
			// I-TYPE ��֧��ת
			`op_BEQ: 	begin controls <= 7'b0001000; aluop <= `aluop_sub; end
			`op_BNE: 	begin controls <= 7'b0001000; aluop <= `aluop_sub; end
			`op_BGEZ: 	begin controls <= 7'b0001000; aluop <= `aluop_sub; end
			`op_BLTZ: 	begin controls <= 7'b0001000; aluop <= `aluop_sub; end
			`op_BLEZ: 	begin controls <= 7'b0001000; aluop <= `aluop_sub; end
			`op_BGTZ: 	begin controls <= 7'b0001000; aluop <= `aluop_sub; end
			`op_BGEZ: 	begin controls <= 7'b0001000; aluop <= `aluop_sub; end
			`op_BGEZAL: begin controls <= 7'b0001000; aluop <= `aluop_sub; end
			`op_BLTZAL: begin controls <= 7'b0001000; aluop <= `aluop_sub; end
			
			// J-TYPE
			`op_J: 		begin controls <= 7'b0000100; aluop <= 4'b0000; end
			`op_JAL: 	begin controls <= 7'b0000100; aluop <= 4'b0000; end
			
			// I-TYPE �ô�
			`op_LB: 	begin controls <= 7'b0110001; aluop <= `aluop_add; end
			`op_LBU: 	begin controls <= 7'b0110001; aluop <= `aluop_add; end
			`op_LH: 	begin controls <= 7'b0110001; aluop <= `aluop_add; end
			`op_LHU: 	begin controls <= 7'b0110001; aluop <= `aluop_add; end
			`op_LW: 	begin controls <= 7'b0110001; aluop <= `aluop_add; end
			`op_SB: 	begin controls <= 7'b0100010; aluop <= `aluop_add; end
			`op_SH: 	begin controls <= 7'b0100010; aluop <= `aluop_add; end
			`op_SW: 	begin controls <= 7'b0100010; aluop <= `aluop_add; end

			// ����

			default: 	begin controls <= 7'b0000000; aluop <= 4'b0000; end
		endcase
	end
	
endmodule

`timescale 1ns / 1ps
`include "defines.vh"

module maindec(
	/*
		ģ������: maindec
		ģ�鹦��: ��������
		����:
			op 			instr[31:26]
			funct		instr[5:0]
		���:
			regdst 		ѡ��д�Ĵ����ŵ���Դ. 0-rt, 1-rd
			alusrc 		ѡ�� ALU �ڶ�����������Դ. 0-�Ĵ�����, 1-������
			memtoreg 	ѡ��д��Ĵ����ѵ�������Դ. 0-ALU, 1-�ڴ�
			branch 		ִ�з�ָ֧��ʱ�� 1
			jump 		ִ����תָ��ʱ�� 1
			memwrite 	�ڴ��д�ź�
			regwrite 	�Ĵ����ѵ�д�ź�
			hilotoreg	ѡ��д��Ĵ����ѵ�������Դ, 0-ALU/�ڴ�, 1-HILO
			hiorlo		ѡ�� MFHI �� MFLO, 0-MFHI, 1-MFLO
			hiwrite		HI �Ĵ�����д�ź�
			lowrite		LO �Ĵ�����д�ź�
			aluop 		���� aludec ���ź�
	*/
	input 	wire[5:0] 	op, funct,
	output	wire		regdst, alusrc, memtoreg, branch, jump,
	output	wire		memwrite, regwrite,
	output	wire		hilotoreg, hiorlo, hiwrite, lowrite,
	output 	reg [3:0] 	aluop
    );

	reg[10:0] controls;
	assign {regdst, alusrc, memtoreg, branch, jump, memwrite, regwrite, 
			hilotoreg, hiorlo, hiwrite, lowrite}
			= controls;

	always @(*) begin
		case (funct)
			`funct_MFHI:	begin controls <= 11'b1000001_1000; aluop <= 4'b0000; end
			`funct_MFLO:	begin controls <= 11'b1000001_1100; aluop <= 4'b0000; end
			`funct_MTHI:	begin controls <= 11'b0000000_0010; aluop <= 4'b0000; end
			`funct_MTLO:	begin controls <= 11'b0000000_0001; aluop <= 4'b0000; end

			default: case (op)
				// R-TYPE
				`op_RTYPE: 	begin controls <= 11'b1000001_0000; aluop <= `aluop_RTYPE; end

				// I-TYPE ����������
				`op_ADDI: 	begin controls <= 11'b0100001_0000; aluop <= `aluop_add; end
				`op_ADDIU: 	begin controls <= 11'b0100001_0000; aluop <= `aluop_add; end
				`op_SLTI: 	begin controls <= 11'b0100001_0000; aluop <= `aluop_slt; end
				`op_SLTIU: 	begin controls <= 11'b0100001_0000; aluop <= `aluop_sltu; end
				`op_ANDI: 	begin controls <= 11'b0100001_0000; aluop <= `aluop_and; end
				`op_LUI: 	begin controls <= 11'b0100001_0000; aluop <= `aluop_LUI; end
				`op_ORI: 	begin controls <= 11'b0100001_0000; aluop <= `aluop_or; end
				`op_XORI: 	begin controls <= 11'b0100001_0000; aluop <= `aluop_xor; end
				
				// I-TYPE ��֧��ת
				`op_BEQ: 	begin controls <= 11'b0001000_0000; end
				`op_BNE: 	begin controls <= 11'b0001000_0000; end
				`op_BGEZ: 	begin controls <= 11'b0001000_0000; end
				`op_BLTZ: 	begin controls <= 11'b0001000_0000; end
				`op_BLEZ: 	begin controls <= 11'b0001000_0000; end
				`op_BGTZ: 	begin controls <= 11'b0001000_0000; end
				`op_BGEZ: 	begin controls <= 11'b0001000_0000; end
				`op_BGEZAL: begin controls <= 11'b0001001_0000; end
				`op_BLTZAL: begin controls <= 11'b0001001_0000; end
				
				// J-TYPE
				`op_J: 		begin controls <= 11'b0000100_0000; aluop <= 4'b0000; end
				`op_JAL: 	begin controls <= 11'b0000100_0000; aluop <= 4'b0000; end
				
				// I-TYPE �ô�
				`op_LB: 	begin controls <= 11'b0110001_0000; aluop <= `aluop_add; end
				`op_LBU: 	begin controls <= 11'b0110001_0000; aluop <= `aluop_add; end
				`op_LH: 	begin controls <= 11'b0110001_0000; aluop <= `aluop_add; end
				`op_LHU: 	begin controls <= 11'b0110001_0000; aluop <= `aluop_add; end
				`op_LW: 	begin controls <= 11'b0110001_0000; aluop <= `aluop_add; end
				`op_SB: 	begin controls <= 11'b0100010_0000; aluop <= `aluop_add; end
				`op_SH: 	begin controls <= 11'b0100010_0000; aluop <= `aluop_add; end
				`op_SW: 	begin controls <= 11'b0100010_0000; aluop <= `aluop_add; end

				// ����

				default: 	begin controls <= 11'b0000000_0000; aluop <= 4'b0000; end
			endcase
		endcase
	end
	
endmodule

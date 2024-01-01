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
<<<<<<< HEAD
=======
			immse		ѡ����������չ����, 0-�޷�����չ, 1-�з�����չ
			ismult
			signedmult
			isdiv
			signeddiv
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
			aluop 		���� aludec ���ź�
	*/
	input 	wire[5:0] 	op, funct,
	output	wire		regdst, alusrc, memtoreg, branch, jump,
	output	wire		memwrite, regwrite,
	output	wire		hilotoreg, hiorlo, hiwrite, lowrite,
<<<<<<< HEAD
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
=======
	output	wire		immse,
	output	wire		ismult, signedmult, isdiv, signeddiv,
	output 	reg [3:0] 	aluop
    );

	reg[7:0] controls;
	assign {regdst, alusrc, memtoreg, branch, jump, memwrite, regwrite, 
			immse} = controls;

	assign hilotoreg = ((funct == `funct_MFHI || funct == `funct_MFLO) && op == `op_RTYPE);
	assign hiorlo = (funct == `funct_MFLO && op == `op_RTYPE);
	assign hiwrite = ((funct == `funct_MTHI || funct == `funct_MULT || funct == `funct_MULTU ||
					   funct == `funct_DIV || funct == `funct_DIVU) && op == `op_RTYPE);
	assign lowrite = ((funct == `funct_MTLO || funct == `funct_MULT || funct == `funct_MULTU ||
					   funct == `funct_DIV || funct == `funct_DIVU) && op == `op_RTYPE);
	assign ismult = ((funct == `funct_MULT || funct == `funct_MULTU) && op == `op_RTYPE);
	assign signedmult = (funct == `funct_MULT && op == `op_RTYPE);
	assign isdiv = ((funct == `funct_DIV || funct == `funct_DIVU) && op == `op_RTYPE);
	assign signeddiv = (funct == `funct_DIV && op == `op_RTYPE);

	always @(*) begin
		case (op)
			// R-TYPE
			`op_RTYPE: 	begin controls <= 8'b1000001_0; aluop <= `aluop_RTYPE; end

			// I-TYPE ����������
			`op_ADDI: 	begin controls <= 8'b0100001_1; aluop <= `aluop_add; end
			`op_ADDIU: 	begin controls <= 8'b0100001_1; aluop <= `aluop_add; end
			`op_SLTI: 	begin controls <= 8'b0100001_1; aluop <= `aluop_slt; end
			`op_SLTIU: 	begin controls <= 8'b0100001_1; aluop <= `aluop_sltu; end
			`op_ANDI: 	begin controls <= 8'b0100001_0; aluop <= `aluop_and; end
			`op_LUI: 	begin controls <= 8'b0100001_0; aluop <= `aluop_LUI; end
			`op_ORI: 	begin controls <= 8'b0100001_0; aluop <= `aluop_or; end
			`op_XORI: 	begin controls <= 8'b0100001_0; aluop <= `aluop_xor; end
			
			// I-TYPE ��֧��ת
			`op_BEQ: 	begin controls <= 8'b0001000_1; aluop <= `aluop_sub; end
			`op_BNE: 	begin controls <= 8'b0001000_1; aluop <= `aluop_sub; end
			`op_BGEZ: 	begin controls <= 8'b0001000_1; aluop <= `aluop_sub; end
			`op_BLTZ: 	begin controls <= 8'b0001000_1; aluop <= `aluop_sub; end
			`op_BLEZ: 	begin controls <= 8'b0001000_1; aluop <= `aluop_sub; end
			`op_BGTZ: 	begin controls <= 8'b0001000_1; aluop <= `aluop_sub; end
			`op_BGEZ: 	begin controls <= 8'b0001000_1; aluop <= `aluop_sub; end
			`op_BGEZAL: begin controls <= 8'b0001000_1; aluop <= `aluop_sub; end
			`op_BLTZAL: begin controls <= 8'b0001000_1; aluop <= `aluop_sub; end
			
			// J-TYPE
			`op_J: 		begin controls <= 8'b0000100_0; aluop <= 0; end
			`op_JAL: 	begin controls <= 8'b0000100_0; aluop <= 0; end
			
			// I-TYPE �ô�
			`op_LB: 	begin controls <= 8'b0110001_1; aluop <= `aluop_add; end
			`op_LBU: 	begin controls <= 8'b0110001_1; aluop <= `aluop_add; end
			`op_LH: 	begin controls <= 8'b0110001_1; aluop <= `aluop_add; end
			`op_LHU: 	begin controls <= 8'b0110001_1; aluop <= `aluop_add; end
			`op_LW: 	begin controls <= 8'b0110001_1; aluop <= `aluop_add; end
			`op_SB: 	begin controls <= 8'b0100010_1; aluop <= `aluop_add; end
			`op_SH: 	begin controls <= 8'b0100010_1; aluop <= `aluop_add; end
			`op_SW: 	begin controls <= 8'b0100010_1; aluop <= `aluop_add; end

			// ����

			default: 	begin controls <= 0; aluop <= 0; end
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
		endcase
	end
	
endmodule

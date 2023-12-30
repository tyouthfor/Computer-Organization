`timescale 1ns / 1ps
`include "defines.vh"

module aludec(
	/*
		模块名称: aludec
		模块功能: ALU 译码器
		输入:
			funct 			instr[5:0]
			aluop 			maindec 的输出
		输出:
			alucontrol 		ALU 的选择信号
	*/
	input 	wire[5:0] 	funct,
	input 	wire[3:0] 	aluop,
	output 	reg [5:0] 	alucontrol
    );

	always @(*) begin
		case (aluop)
			`aluop_add:			alucontrol <= `alu_add;
			`aluop_sub:			alucontrol <= `alu_sub;
			`aluop_slt:			alucontrol <= `alu_slt;
			`aluop_sltu:		alucontrol <= `alu_sltu;
			`aluop_and:			alucontrol <= `alu_and;
			`aluop_LUI:			alucontrol <= `alu_LUI;
			`aluop_or:			alucontrol <= `alu_or;
			`aluop_xor:			alucontrol <= `alu_xor;

			default: case (funct)
				`funct_ADD: 	alucontrol <= `alu_add;
				`funct_ADDU: 	alucontrol <= `alu_add;
				`funct_SUB: 	alucontrol <= `alu_sub;
				`funct_SUBU: 	alucontrol <= `alu_sub;
				`funct_SLT: 	alucontrol <= `alu_slt;
				`funct_SLTU: 	alucontrol <= `alu_sltu;
				`funct_DIV: 	alucontrol <= 0;
				`funct_DIVU: 	alucontrol <= 0;
				`funct_MULT: 	alucontrol <= `alu_mult;
				`funct_MULTU: 	alucontrol <= `alu_multu;
				`funct_AND: 	alucontrol <= `alu_and;
				`funct_NOR: 	alucontrol <= `alu_nor;
				`funct_OR: 		alucontrol <= `alu_or;
				`funct_XOR: 	alucontrol <= `alu_xor;
				`funct_SLLV: 	alucontrol <= `alu_sllv;
				`funct_SLL: 	alucontrol <= `alu_sll;
				`funct_SRAV: 	alucontrol <= `alu_srav;
				`funct_SRA:		alucontrol <= `alu_sra;
				`funct_SRLV: 	alucontrol <= `alu_srlv;
				`funct_SRL: 	alucontrol <= `alu_srl;
				default:   		alucontrol <= 0;
			endcase
		endcase
	end

endmodule
`timescale 1ns / 1ps
`include "defines.vh"

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

			// I-TYPE 立即数运算
			`op_ADDI: 	begin controls <= 7'b0100001; aluop <= `aluop_add; end
			`op_ADDIU: 	begin controls <= 7'b0100001; aluop <= `aluop_add; end
			`op_SLTI: 	begin controls <= 7'b0100001; aluop <= `aluop_slt; end
			`op_SLTIU: 	begin controls <= 7'b0100001; aluop <= `aluop_sltu; end
			`op_ANDI: 	begin controls <= 7'b0100001; aluop <= `aluop_and; end
			`op_LUI: 	begin controls <= 7'b0100001; aluop <= `aluop_LUI; end
			`op_ORI: 	begin controls <= 7'b0100001; aluop <= `aluop_or; end
			`op_XORI: 	begin controls <= 7'b0100001; aluop <= `aluop_xor; end
			
			// I-TYPE 分支跳转
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
			
			// I-TYPE 访存
			`op_LB: 	begin controls <= 7'b0110001; aluop <= `aluop_add; end
			`op_LBU: 	begin controls <= 7'b0110001; aluop <= `aluop_add; end
			`op_LH: 	begin controls <= 7'b0110001; aluop <= `aluop_add; end
			`op_LHU: 	begin controls <= 7'b0110001; aluop <= `aluop_add; end
			`op_LW: 	begin controls <= 7'b0110001; aluop <= `aluop_add; end
			`op_SB: 	begin controls <= 7'b0100010; aluop <= `aluop_add; end
			`op_SH: 	begin controls <= 7'b0100010; aluop <= `aluop_add; end
			`op_SW: 	begin controls <= 7'b0100010; aluop <= `aluop_add; end

			// 特殊

			default: 	begin controls <= 7'b0000000; aluop <= 4'b0000; end
		endcase
	end
	
endmodule

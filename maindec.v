`timescale 1ns / 1ps
`include "defines.vh"

/*
	模块名称: maindec
	模块功能: 主译码器
	输入:
		instr					指令
		stallD					ID 阶段的流水线暂停信号
	输出:
		regdst					当写寄存器堆的寄存器号来自 rd 时置 1
		alusrc					当 ALU 的第二操作数来自立即数时置 1
		regwrite				寄存器堆的写信号
		memtoreg				当写寄存器堆的数据来自 data ram 时置 1
		memwe					data ram 的写信号
		immse					0-无符号扩展, 1-有符号扩展

		branch					当执行分支跳转指令时置 1
		jump					当执行直接跳转指令时置 1
		jumpreg					当执行寄存器跳转指令时置 1

		linkreg					当写寄存器堆的寄存器号为 31 时置 1
		linkdata				当写寄存器堆的数据为 pc+8 时置 1

		ismult					当执行乘法指令时置 1
		signedmult				当执行有符号乘法指令时置 1
		isdiv					当执行除法指令时置 1
		signeddiv				当执行有符号除法指令时置 1

		hilotoreg				当写寄存器堆的数据来自 HILO 寄存器时置 1
		hiorlo					0-MFHI, 1-MFLO
		hiwrite					HI 寄存器的写信号
		lowrite					LO 寄存器的写信号

		cp0toreg				当写寄存器堆的数据来自 CP0 寄存器时置 1
		cp0write				CP0 寄存器的写信号

		is_overflow_detect 		当指令需要检测算术运算溢出时置 1
		invalid					0-指令译码有效, 1-指令译码无效
		aluop 					二级控制信号
*/
module maindec(
	input	wire[31:0]		instr,
	input	wire			stallD,
	output	wire			regdst, alusrc, regwrite, memtoreg, memwe,
	output	wire			immse,
	output	wire			branch, jump, jumpreg,
	output	wire			linkreg, linkdata,
	output	wire			ismult, signedmult, isdiv, signeddiv,
	output	wire			hilotoreg, hiorlo, hiwrite, lowrite,
	output	wire			cp0toreg, cp0write,
	output	wire			is_overflow_detect,
	output	reg				invalid,
	output 	reg [3:0] 		aluop
    );

	wire[5:0] 				op, funct;
	wire[4:0] 				rs, rt;
	
	assign op = instr[31:26];
	assign rs = instr[25:21];
	assign rt = instr[20:16];
	assign funct = instr[5:0];
	
	assign regwrite	= stallD ? 1'b0 : (
		(op == `op_RTYPE & instr != 0 & funct != `funct_MULT & funct != `funct_MULTU & 
		funct != `funct_DIV & funct != `funct_DIVU & funct != `funct_MFHI & funct != `funct_MFLO) |
		(op == `op_ADDI) | (op == `op_ADDIU) | (op == `op_SLTI) | (op == `op_SLTIU) |
		(op == `op_ANDI) | (op == `op_LUI) | (op == `op_ORI) | (op == `op_XORI) |
		(op == `op_BGEZAL & rt == 5'b10001) | (op == `op_BLTZAL & rt == 5'b10000) | (op == `op_JAL) |
		(op == `op_LB) | (op == `op_LBU) | (op == `op_LH) | (op == `op_LHU) | (op == `op_LW)
	);

	assign memtoreg = stallD ? 1'b0 : (
		op == `op_LB | op == `op_LBU | op == `op_LH | op == `op_LHU | op == `op_LW
	);
	assign memwe = stallD ? 1'b0 : (
		op == `op_SB | op == `op_SH | op == `op_SW
	);

	assign jumpreg = (
		op == `op_RTYPE & (funct == `funct_JR | funct == `funct_JALR)
	);
	assign linkreg = (
		(op == `op_BGEZAL & rt == 5'b10001) | (op == `op_BLTZAL && rt == 5'b10000) | op == `op_JAL
	);
	assign linkdata = (
		linkreg | (op == `op_RTYPE & funct == `funct_JALR)
	);

	assign ismult = stallD ? 1'b0 : (
		op == `op_RTYPE & (funct == `funct_MULT | funct == `funct_MULTU)
	);
	assign signedmult = stallD ? 1'b0 : (
		op == `op_RTYPE & funct == `funct_MULT
	);
	assign isdiv = stallD ? 1'b0 : (
		op == `op_RTYPE & (funct == `funct_DIV | funct == `funct_DIVU)
	);
	assign signeddiv = stallD ? 1'b0 : (
		op == `op_RTYPE & funct == `funct_DIV
	);

	assign hilotoreg = stallD ? 1'b0 : (
		op == `op_RTYPE & (funct == `funct_MFHI | funct == `funct_MFLO)
	);
	assign hiorlo = stallD ? 1'b0 : (
		op == `op_RTYPE & funct == `funct_MFLO
	);
	assign hiwrite = stallD ? 1'b0 : (
		op == `op_RTYPE & (funct == `funct_MTHI | funct == `funct_MULT | funct == `funct_MULTU | 
		funct == `funct_DIV | funct == `funct_DIVU)
	);
	assign lowrite = stallD ? 1'b0 : (
		op == `op_RTYPE & (funct == `funct_MTLO | funct == `funct_MULT | funct == `funct_MULTU | 
		funct == `funct_DIV | funct == `funct_DIVU)
	);

	assign cp0toreg	= stallD ? 1'b0 : (
		op == `op_MFC0 & rs == 5'b00000
	);
	assign cp0write = stallD ? 1'b0 : (
		op == `op_MTC0 & rs == 5'b00100
	);

	assign is_overflow_detect = (
		(op == `op_RTYPE & (funct == `funct_ADD | funct == `funct_SUB)) | op == `op_ADDI
	);

	reg [4:0] controls;
	assign {regdst, alusrc, branch, jump, immse} = controls;
	always @(*) begin
		controls = 0;
		aluop = 0;
		invalid = 0;
		case (op)
			// R-TYPE
			`op_RTYPE: 	begin controls = 5'b10000; aluop = `aluop_RTYPE; end

			// I-TYPE 立即数运算
			`op_ADDI: 	begin controls = 5'b01001; aluop = `aluop_add; end
			`op_ADDIU: 	begin controls = 5'b01001; aluop = `aluop_add; end
			`op_SLTI: 	begin controls = 5'b01001; aluop = `aluop_slt; end
			`op_SLTIU: 	begin controls = 5'b01001; aluop = `aluop_sltu; end
			`op_ANDI: 	begin controls = 5'b01000; aluop = `aluop_and; end
			`op_LUI: 	begin controls = 5'b01000; aluop = `aluop_LUI; end
			`op_ORI: 	begin controls = 5'b01000; aluop = `aluop_or; end
			`op_XORI: 	begin controls = 5'b01000; aluop = `aluop_xor; end
			
			// I-TYPE 分支跳转
			`op_BEQ: 	begin controls = 5'b00101; aluop = 0; end
			`op_BNE: 	begin controls = 5'b00101; aluop = 0; end
			`op_BGEZ: 	begin controls = 5'b00101; aluop = 0; end  // BLTZ、BGEZAL、BLTZAL
			`op_BLEZ: 	begin controls = 5'b00101; aluop = 0; end
			`op_BGTZ: 	begin controls = 5'b00101; aluop = 0; end
			
			// J-TYPE
			`op_J: 		begin controls = 5'b00010; aluop = 0; end
			`op_JAL: 	begin controls = 5'b00010; aluop = 0; end
			
			// I-TYPE 访存
			`op_LB: 	begin controls = 5'b01001; aluop = `aluop_add; end
			`op_LBU: 	begin controls = 5'b01001; aluop = `aluop_add; end
			`op_LH: 	begin controls = 5'b01001; aluop = `aluop_add; end
			`op_LHU: 	begin controls = 5'b01001; aluop = `aluop_add; end
			`op_LW: 	begin controls = 5'b01001; aluop = `aluop_add; end
			`op_SB: 	begin controls = 5'b01001; aluop = `aluop_add; end
			`op_SH: 	begin controls = 5'b01001; aluop = `aluop_add; end
			`op_SW: 	begin controls = 5'b01001; aluop = `aluop_add; end

			// CP0
			`op_ERET:	begin controls = 0; aluop = 0; end  // ERET、MFC0、MTC0

			default: 	begin controls = 0; aluop = 0; invalid = 1; end
		endcase
	end
	
endmodule
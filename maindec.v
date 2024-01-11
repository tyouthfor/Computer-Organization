`timescale 1ns / 1ps
`include "defines.vh"

module maindec(
	/*
		模块名称: maindec
		模块功能: 主译码器
		输入:
			instr
		输出:
			regdst 		选择写寄存器号的来源. 0-rt, 1-rd
			alusrc 		选择 ALU 第二操作数的来源. 0-寄存器堆, 1-立即数
			memtoreg 	选择写入寄存器堆的数据来源. 0-ALU, 1-内存
			branch 		执行分支指令时置 1
			jump 		执行跳转指令时置 1
			regwrite 	寄存器堆的写信号
			hilotoreg	选择写入寄存器堆的数据来源, 0-ALU/内存, 1-HILO  执行 MFHI/MFLO 指令时置 1
			hiorlo		0-MFHI, 1-MFLO
			hiwrite		HI 寄存器的写信号
			lowrite		LO 寄存器的写信号
			immse		选择立即数扩展类型, 0-无符号扩展, 1-有符号扩展
			ismult
			signedmult
			isdiv
			signeddiv
			invalid		1-指令无效, 0-指令有效
			aluop 		传给 aludec 的信号
	*/
	input	wire[31:0]		instr,
	input	wire			stallD,
	output	wire			regdst, alusrc, memtoreg, branch, jump, jumpreg,
	output	wire			regwrite,
	output	wire			hilotoreg, hiorlo, hiwrite, lowrite,
	output	wire			immse, linkreg, linkdata,
	output	wire			ismult, signedmult, isdiv, signeddiv,
	output	reg				invalid,
	output	wire			cp0toreg, cp0write,
	output	wire			is_overflow_detect,
	output	wire			memwe,
	output 	reg [3:0] 		aluop
    );

	wire[5:0] 				op, funct;
	wire[4:0] 				rs, rt;
	reg [4:0] 				controls;

	assign op = instr[31:26];
	assign rs = instr[25:21];
	assign rt = instr[20:16];
	assign funct = instr[5:0];

	assign {regdst, alusrc, branch, jump, immse} = controls;

	assign hilotoreg 		= stallD ? 1'b0 : ((funct == `funct_MFHI | funct == `funct_MFLO) & op == `op_RTYPE);
	assign hiorlo 			= stallD ? 1'b0 : (funct == `funct_MFLO & op == `op_RTYPE);
	assign hiwrite 			= stallD ? 1'b0 : ((funct == `funct_MTHI | funct == `funct_MULT | funct == `funct_MULTU |
					   			funct == `funct_DIV | funct == `funct_DIVU) & op == `op_RTYPE);
	assign lowrite 			= stallD ? 1'b0 : ((funct == `funct_MTLO | funct == `funct_MULT | funct == `funct_MULTU |
					   			funct == `funct_DIV | funct == `funct_DIVU) & op == `op_RTYPE);

	assign ismult 			= stallD ? 1'b0 : ((funct == `funct_MULT | funct == `funct_MULTU) & op == `op_RTYPE);
	assign signedmult 		= stallD ? 1'b0 : (funct == `funct_MULT & op == `op_RTYPE);
	assign isdiv 			= stallD ? 1'b0 : ((funct == `funct_DIV | funct == `funct_DIVU) & op == `op_RTYPE);
	assign signeddiv 		= stallD ? 1'b0 : (funct == `funct_DIV & op == `op_RTYPE);

	assign linkreg 			= ((op == `op_BGEZAL & rt == 5'b10001) | (op == `op_BLTZAL && rt == 5'b10000) | (op == `op_JAL));
	assign linkdata			= (linkreg | (funct == `funct_JALR & op == `op_RTYPE));
	assign jumpreg			= ((funct == `funct_JR | funct == `funct_JALR) & op == `op_RTYPE);

	assign regwrite			= stallD ? 1'b0 : ((op == `op_RTYPE & instr != 0 & funct != `funct_MULT & funct != `funct_MULTU & 
								funct != `funct_DIV & funct != `funct_DIVU & funct != `funct_MFHI & funct != `funct_MFLO) |
							    op == `op_ADDI | op == `op_ADDIU | op == `op_SLTI | op == `op_SLTIU |
							    op == `op_ANDI |  op == `op_LUI | op == `op_ORI | op == `op_XORI |
							   (op == `op_BGEZAL & rt == 5'b10001) | (op == `op_BLTZAL & rt == 5'b10000) | op == `op_JAL |
							    op == `op_LB | op == `op_LBU | op == `op_LH | op == `op_LHU | op == `op_LW);

	assign cp0toreg			= stallD ? 1'b0 : (op == `op_MFC0 & rs == 5'b00000);
	assign cp0write			= stallD ? 1'b0 : (op == `op_MTC0 & rs == 5'b00100);

	assign is_overflow_detect = ((op == `op_RTYPE & (funct == `funct_ADD | funct == `funct_SUB)) | op == `op_ADDI);

	assign memtoreg = stallD ? 1'b0 : (op == `op_LB | op == `op_LBU | op == `op_LH | op == `op_LHU | op == `op_LW);
	assign memwe = stallD ? 1'b0 : (op == `op_SB | op == `op_SH | op == `op_SW);

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
			`op_ERET:	begin controls = 0; aluop = 0; end

			default: 	begin controls = 0; aluop = 0; invalid = 1; end
		endcase
	end
	
endmodule

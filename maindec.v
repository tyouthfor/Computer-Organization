`timescale 1ns / 1ps
`include "defines.vh"

module maindec(
	/*
		模块名称: maindec
		模块功能: 主译码器
		输入:
			op 			instr[31:26]
			funct		instr[5:0]
		输出:
			regdst 		选择写寄存器号的来源. 0-rt, 1-rd
			alusrc 		选择 ALU 第二操作数的来源. 0-寄存器堆, 1-立即数
			memtoreg 	选择写入寄存器堆的数据来源. 0-ALU, 1-内存
			branch 		执行分支指令时置 1
			jump 		执行直接跳转指令时置 1
			jumpreg		执行寄存器跳转指令时置 1
			regwrite 	寄存器堆的写信号
			hilotoreg	选择写入寄存器堆的数据来源, 0-ALU/内存, 1-HILO
			hiorlo		选择 MFHI 或 MFLO, 0-MFHI, 1-MFLO
			hiwrite		HI 寄存器的写信号
			lowrite		LO 寄存器的写信号
			immse		选择立即数扩展类型, 0-无符号扩展, 1-有符号扩展
			ismult
			signedmult
			isdiv
			signeddiv
			aluop 		传给 aludec 的信号
	*/
	input 	wire[5:0] 	op, funct, rt,
	output	wire		regdst, alusrc, memtoreg, branch, jump, jumpreg, regwrite,
	output	wire		hilotoreg, hiorlo, hiwrite, lowrite,
	output	wire		immse, linkreg, linkdata,
	output	wire		ismult, signedmult, isdiv, signeddiv,
	output 	reg [3:0] 	aluop
    );

	reg[5:0] controls;
	assign {regdst, alusrc, memtoreg, branch, jump, immse} = controls;

	assign hilotoreg 		= ((funct == `funct_MFHI || funct == `funct_MFLO) && op == `op_RTYPE);
	assign hiorlo 			= (funct == `funct_MFLO && op == `op_RTYPE);
	assign hiwrite 			= ((funct == `funct_MTHI || funct == `funct_MULT || funct == `funct_MULTU ||
					   			funct == `funct_DIV || funct == `funct_DIVU) && op == `op_RTYPE);
	assign lowrite 			= ((funct == `funct_MTLO || funct == `funct_MULT || funct == `funct_MULTU ||
					   			funct == `funct_DIV || funct == `funct_DIVU) && op == `op_RTYPE);

	assign ismult 			= ((funct == `funct_MULT || funct == `funct_MULTU) && op == `op_RTYPE);
	assign signedmult 		= (funct == `funct_MULT && op == `op_RTYPE);
	assign isdiv 			= ((funct == `funct_DIV || funct == `funct_DIVU) && op == `op_RTYPE);
	assign signeddiv 		= (funct == `funct_DIV && op == `op_RTYPE);

	assign linkreg 			= ((op == `op_BGEZAL && rt == 5'b10001) || (op == `op_BLTZAL && rt == 5'b10000) || (op == `op_JAL));
	assign linkdata			= (linkreg || (funct == `funct_JALR && op == `op_RTYPE));
	assign jumpreg			= ((funct == `funct_JR || funct == `funct_JALR) && op == `op_RTYPE);

	assign regwrite			= (op == `op_RTYPE || op == `op_ADDI || op == `op_ADDIU || op == `op_SLTI || op == `op_SLTIU ||
							   op == `op_ANDI ||  op == `op_LUI || op == `op_ORI || op == `op_XORI || 
							   (op == `op_BGEZAL && rt == 5'b10001) || (op == `op_BLTZAL && rt == 5'b10000) || op == `op_JAL ||
							   op == `op_LB || op == `op_LBU || op == `op_LH || op == `op_LHU || op == `op_LW);

	always @(*) begin
		case (op)
			// R-TYPE
			`op_RTYPE: 	begin controls <= 6'b100000; aluop <= `aluop_RTYPE; end

			// I-TYPE 立即数运算
			`op_ADDI: 	begin controls <= 6'b010001; aluop <= `aluop_add; end
			`op_ADDIU: 	begin controls <= 6'b010001; aluop <= `aluop_add; end
			`op_SLTI: 	begin controls <= 6'b010001; aluop <= `aluop_slt; end
			`op_SLTIU: 	begin controls <= 6'b010001; aluop <= `aluop_sltu; end
			`op_ANDI: 	begin controls <= 6'b010000; aluop <= `aluop_and; end
			`op_LUI: 	begin controls <= 6'b010000; aluop <= `aluop_LUI; end
			`op_ORI: 	begin controls <= 6'b010000; aluop <= `aluop_or; end
			`op_XORI: 	begin controls <= 6'b010000; aluop <= `aluop_xor; end
			
			// I-TYPE 分支跳转
			`op_BEQ: 	begin controls <= 6'b000101; aluop <= 0; end
			`op_BNE: 	begin controls <= 6'b000101; aluop <= 0; end
			`op_BGEZ: 	begin controls <= 6'b000101; aluop <= 0; end  // BLTZ、BGEZAL、BLTZAL
			`op_BLEZ: 	begin controls <= 6'b000101; aluop <= 0; end
			`op_BGTZ: 	begin controls <= 6'b000101; aluop <= 0; end
			`op_BGEZ: 	begin controls <= 6'b000101; aluop <= 0; end
			
			// J-TYPE
			`op_J: 		begin controls <= 6'b000010; aluop <= 0; end
			`op_JAL: 	begin controls <= 6'b000010; aluop <= 0; end
			
			// I-TYPE 访存
			`op_LB: 	begin controls <= 6'b011001; aluop <= `aluop_add; end
			`op_LBU: 	begin controls <= 6'b011001; aluop <= `aluop_add; end
			`op_LH: 	begin controls <= 6'b011001; aluop <= `aluop_add; end
			`op_LHU: 	begin controls <= 6'b011001; aluop <= `aluop_add; end
			`op_LW: 	begin controls <= 6'b011001; aluop <= `aluop_add; end
			`op_SB: 	begin controls <= 6'b010001; aluop <= `aluop_add; end
			`op_SH: 	begin controls <= 6'b010001; aluop <= `aluop_add; end
			`op_SW: 	begin controls <= 6'b010001; aluop <= `aluop_add; end

			// 特殊

			default: 	begin controls <= 0; aluop <= 0; end
		endcase
	end
	
endmodule

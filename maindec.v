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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name: 
// Module Name: hazard
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


module hazard(
	/*
		模块名称: hazard
		模块功能: 冒险处理
		输入:
			(1) fetch stage

			(2) decode stage
			rsD
			rtD
			branchD

			(3) execute stage
			rsE
			rtE
			writeregE 	写寄存器号
			regwriteE 	寄存器堆写信号
			memtoregE

			(4) mem stage
			writeregM
			regwriteM
			memtoregM

			(5)write back stage
			writeregW
			regwriteW
		输出:
			(1) fetch stage
			stallF 		1-PC 工作, 0-PC 暂停

			(2) decode stage
			forwardaD 	选择 equal 模块第一操作数来源, 1-aluoutM, 0-srcaD
			forwardbD 	选择 equal 模块第二操作数来源, 1-aluoutM, 0-srcbD
			stallD 		1-IF/ID 流水线暂停, 0-IF/ID 流水线工作

			(3) execute stage
			forwardaE 	选择 ALU 模块第一操作数来源, 00-srcaE, 01-resultW, 10-aluoutM
			forwardbE 	选择 ALU 模块第二操作数来源, 00-srcbE, 01-resultW, 10-aluoutM
			flushE 		1-ID/EX 流水线暂停, 0-ID/EX 流水线暂停
	*/

	//fetch stage
	output wire stallF,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire branchD,
	output wire forwardaD,forwardbD,
	output wire stallD,
	//execute stage
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	output reg[1:0] forwardaE,forwardbE,
	output wire flushE,
	//mem stage
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW
    );

	wire lwstallD,branchstallD;

	// forwarding 解决 branch equality 数据冒险
	// (1) ADD, x, BEQ -- aluoutM
	//     ADD: IF ID EX ME WB
	//     x:      IF ID EX ME WB
	//     BEQ:       IF ID EX ME WB
	// (2) LW, x, x, BEQ 似乎不需要, 因为 WB 就是要写回寄存器堆(如果寄存器堆写优先的话就没问题)
	//     LW:  IF ID EX ME WB
	//     x:      IF ID EX ME WB
	//     x:         IF ID EX ME WB
	//     BEQ:          IF ID EX ME WB
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	
	// forwarding 解决 ALU 数据冒险
	// (1) ADD, ADD -- aluoutM
	//     ADD: IF ID EX ME WB
	//     ADD:    IF ID EX ME WB
	// (2) ADD, LW -- aluoutM
	//     ADD: IF ID EX ME WB
	//     LW:     IF ID EX ME WB
	// (3) ADD, x, ADD -- resultW
	//     ADD: IF ID EX ME WB
	//     x:      IF ID EX ME WB
	//     ADD:       IF ID EX ME WB
	// (4) ADD, x, LW -- resultW
	//     ADD: IF ID EX ME WB
	//     x:      IF ID EX ME WB
	//     LW:        IF ID EX ME WB
	// (5) LW, x, ADD -- resultW
	//     LW:  IF ID EX ME WB
	//     x:      IF ID EX ME WB
	//     ADD:       IF ID EX ME WB
	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			if(rsE == writeregM & regwriteM) begin
				forwardaE = 2'b10;  // aluoutM
			end else if(rsE == writeregW & regwriteW) begin
				forwardaE = 2'b01;  // resultW
			end else begin
				forwardaE = 2'b00;
			end
		end
		if(rtE != 0) begin
			if(rtE == writeregM & regwriteM) begin
				forwardbE = 2'b10;  // aluoutM
			end else if(rtE == writeregW & regwriteW) begin
				forwardbE = 2'b01;  // resultW
			end else begin
				forwardbE = 2'b00;
			end
		end
	end

	// stall 解决 branch equality 数据冒险(在 ID 检测)
	// (1) ADD, BEQ
	//     ADD: IF ID EX ME WB
	//     BEQ:    IF x  ID EX ME WB
	// (2) LW, x, BEQ
	//     LW:  IF ID EX ME WB
	//     x:      IF ID EX ME WB
	//     BEQ:       IF x  ID EX ME WB
	assign #1 branchstallD = branchD &
				(regwriteE & (writeregE == rsD | writeregE == rtD) |  // ADD, BEQ
				 memtoregM & (writeregM == rsD | writeregM == rtD));  // LW, x, BEQ

	// stall 解决 ALU 数据冒险(在 ID 检测)
	// (1) LW, ADD
	//     LW:  IF ID EX ME WB
	//     ADD:    IF x  ID EX ME WB
	assign #1 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	
	// stallD & stallF: 流水线暂停, 寄存器中的值保持不变
	// flushE: 流水线刷新, 寄存器中的值清零
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
	assign #1 stallD = lwstallD | branchstallD;
	assign #1 stallF = stallD;
	assign #1 flushE = stallD;
	
endmodule

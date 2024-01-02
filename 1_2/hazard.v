`timescale 1ns / 1ps

module hazard(
	/*
		模块名称: hazard
		模块功能: 冒险处理
		输入:

		输出:
			(1) IF
			stallF 		1-PC 工作, 0-PC 暂停

			(2) ID
			forwardaD 	选择 equal 模块第一操作数来源, 1-aluoutM, 0-srcaD
			forwardbD 	选择 equal 模块第二操作数来源, 1-aluoutM, 0-srcbD
			stallD 		1-IF/ID 流水线暂停, 0-IF/ID 流水线工作

			(3) EX
			forwardaE 	选择 ALU 模块第一操作数来源, 00-srcaE, 01-resultW, 10-aluoutM
			forwardbE 	选择 ALU 模块第二操作数来源, 00-srcbE, 01-resultW, 10-aluoutM
			stallE		1-ID/EX 流水线暂停, 0-ID/EX 流水线工作
			flushE 		1-ID/EX 流水线冲刷, 0-ID/EX 流水线工作

			(4) ME
			flushM		1-EX/ME 流水线冲刷, 0-EX/ME 流水线工作
	*/

	// IF
	output 	wire 		stallF, flushF,
	// ID
	input 	wire[4:0] 	rsD, rtD, rdD,
	input 	wire 		branchD, hilotoregD,
	output 	wire 		forwardaD, forwardbD,
	output 	wire 		stallD, flushD,
	// EX
	input 	wire[4:0] 	rsE, rtE,
	input 	wire[4:0] 	writeregE,
	input 	wire 		regwriteE, memtoregE,
	input	wire		hilotoregE, hiorloE,
	input	wire		isdivE, divreadyE,
	output 	reg [1:0] 	forwardaE, forwardbE,
	output	reg [1:0]	forwardhiloE,
	output 	wire 		stallE, flushE,
	// ME
	input 	wire[4:0] 	writeregM,
	input 	wire 		regwriteM, memtoregM,
	input	wire		hiwriteM, lowriteM,
	input	wire		ismultM, isdivM,
	output	wire		stallM, flushM,
	// WB
	input 	wire[4:0] 	writeregW,
	input 	wire 		regwriteW,
	output	wire		stallW, flushW
    );

	wire 				lwstallD, branchstallD, mfhistallD, divstallE;
	
	// forwarding 解决 ALU 的 RAW 数据冒险
		// (1) ADD, ADD/LW -- aluoutM (ME --> EX)
		//     ADD:    IF ID EX ME WB
		//     ADD/LW:    IF ID EX ME WB
		// (2) ADD/LW, x, ADD/LW -- resultW (WB --> EX)
		//     ADD/LW: IF ID EX ME WB
		//     x:         IF ID EX ME WB
		//     ADD/LW:       IF ID EX ME WB
	always @(*) begin
		if (rsE != 0) begin
			if (rsE == writeregM & regwriteM) begin
				forwardaE = 2'b10;  // aluoutM
			end 
			else if (rsE == writeregW & regwriteW) begin
				forwardaE = 2'b01;  // resultW
			end
			else begin
				forwardaE = 2'b00;
			end
		end 
		else begin
			forwardaE = 2'b00;
		end

		if (rtE != 0) begin
			if (rtE == writeregM & regwriteM) begin
				forwardbE = 2'b10;  // aluoutM
			end 
			else if (rtE == writeregW & regwriteW) begin
				forwardbE = 2'b01;  // resultW
			end 
			else begin
				forwardbE = 2'b00;
			end
		end
		else begin
			forwardbE = 2'b00;
		end
	end

	// forwarding 解决 branch equality 的 RAW 数据冒险
		// (1) ADD, x, BEQ -- aluoutM (ME --> ID)
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

	// forwarding 解决 HILO 的 RAW 数据冒险
		// (1) DIV, MFHI -- multdivresultM (ME --> EX)
		//     DIV:  IF ID EX ME WB
		//     MFHI:    IF ID EX ME WB
		// (2) MTHI, MFHI -- srcaM (ME --> EX)
		//     MTHI: IF ID EX ME WB
		//     MFHI:    IF ID EX ME WB
	always @(*) begin
		if ((ismultM | isdivM) & hilotoregE & hiorloE == 1'b0) begin
			forwardhiloE <= 2'b01;  // multdivresultM 高 32 位
		end
		else if ((ismultM | isdivM) & hilotoregE & hiorloE == 1'b1) begin
			forwardhiloE <= 2'b10;  // multdivresultM 低 32 位
		end
		else if ((hiwriteM | lowriteM) & hilotoregE) begin
			forwardhiloE <= 2'b11;  // srcaM
		end
		else begin
			forwardhiloE <= 2'b00;  // hiloresultaE
		end
	end

	// stall 解决 ALU 的 RAW 数据冒险
		// (1) LW, ADD
		//     LW:  IF ID EX ME WB
		//     ADD:    IF x  ID EX ME WB
	assign #1 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);

	// stall 解决 branch equality 的 RAW 数据冒险
		// (1) ADD, BEQ
		//     ADD: IF ID EX ME WB
		//     BEQ:    IF x  ID EX ME WB
		// (2) LW, x, BEQ
		//     LW:  IF ID EX ME WB
		//     x:      IF ID EX ME WB
		//     BEQ:       IF x  ID EX ME WB
	assign #1 branchstallD = branchD &
				(regwriteE & (writeregE == rsD | writeregE == rtD) |
				 memtoregM & (writeregM == rsD | writeregM == rtD));

	// stall 解决 MFHI 的 WAW 数据冒险
		// (1) ADD/LW: IF ID EX ME WB
		//     x:         IF ID EX ME WB
		//     MFHI:         IF x  ID EX ME WB
		// (2) ADD/LW: IF ID EX ME WB
		//     MFHI:      IF x  x  ID EX ME WB
	assign #1 mfhistallD = hilotoregD &
				(regwriteM & (writeregM == rdD) |
				 regwriteE & (writeregE == rdD));

	// 除法器流水线暂停
	assign #1 divstallE = isdivE & ~divreadyE;
	
	// stall: 流水线暂停, 寄存器中的值保持不变
	assign #1 stallF = stallD;
	assign #1 stallD = stallE | lwstallD | branchstallD | mfhistallD;
	assign #1 stallE = stallM | divstallE;
	assign #1 stallM = stallW;
	assign #1 stallW = 1'b0;

	// flush: 流水线刷新, 寄存器中的值清零
	assign #1 flushF = 1'b0;
	assign #1 flushD = 1'b0;
	assign #1 flushE = lwstallD | branchstallD | mfhistallD;
	assign #1 flushM = divstallE;
	assign #1 flushW = 1'b0;
	
endmodule

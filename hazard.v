`timescale 1ns / 1ps
`include "defines.vh"

/*
	模块名称: hazard
	模块功能: 数据冒险检测及处理模块, 产生数据前推的选择信号以及必要的流水线暂停信号
*/
module hazard(
	// IF
	input	wire		i_stallF,
	output 	wire 		stallF, flushF,
	// ID
	input 	wire[4:0] 	rsD, rtD, rdD,
	input 	wire 		branchD, jumpregD,
	input	wire		hilotoregD,
	output 	reg	[2:0]	forward_branchjraD, forward_branchjrbD, 
	output 	wire 		stallD, flushD,
	// EX
	input 	wire[4:0] 	rsE, rtE, rdE,
	input 	wire[4:0] 	writeregE,
	input 	wire 		regwriteE, memtoregE,
	input	wire		isdivE, divreadyE,
	input	wire		hilotoregE, hiorloE, hiwriteE, lowriteE,
	input	wire		cp0toregE,
	output 	reg [2:0] 	forwardaE, forwardbE,
	output	reg [2:0]	forward_mfhiloE,
	output	reg [1:0]	forward_mthiloE,
	output 	wire 		stallE, flushE,
	// ME
	input	wire		d_stallM,
	input	wire[4:0]	rsM, rdM,
	input 	wire[4:0] 	writeregM,
	input 	wire 		regwriteM, memtoregM,
	input	wire		ismultM, isdivM,
	input	wire		hilotoregM, hiwriteM, lowriteM,
	input	wire		cp0toregM, cp0writeM,
	input	wire[31:0]	excepttypeM,
	output	reg			forward_mthiloM,
	output	wire		forwardcp0M,
	output	wire		stallM, flushM,
	// WB
	input 	wire[4:0] 	writeregW,
	input 	wire 		regwriteW,
	input	wire		ismultW, isdivW,
	input	wire		hiwriteW, lowriteW,
	input	wire		cp0toregW,
	output	wire		stallW, flushW,
	// except
	output	wire		exceptflush
    );

	wire 				lwstallD, branchjrstallD, mfhistallD, divstallE;
	
	// 1. ALU 的 RAW 数据冒险
		// (1) ADD, ADD/LW -- aluoutM (ME --> EX)
		//     ADD:    IF ID EX ME WB
		//     ADD/LW:    IF ID EX ME WB
		
		// (2) ADD/LW, x, ADD/LW -- resultW (WB --> EX)
		//     ADD/LW: IF ID EX ME WB
		//     x:         IF ID EX ME WB
		//     ADD/LW:       IF ID EX ME WB

		// (3) LW, ADD/LW -- lwstallD
		//     LW:     IF ID EX ME WB
		//     ADD/LW:    IF x  ID EX ME WB

		// (4) MFC0, ADD/LW -- cp0data2M (ME --> EX)
		//     MFC0:   IF ID EX ME WB
		//     ADD/LW:    IF ID EX ME WB

		// (5) MFC0, x, ADD/LW -- cp0data2W (WB --> EX)
		//     MFC0:   IF ID EX ME WB
		//     x:         IF ID EX ME WB
		//     ADD/LW:       IF ID EX ME WB
	always @(*) begin
		forwardaE = 3'b000;
		forwardbE = 3'b000;
		if (rsE != 0) begin
			if (rsE == writeregM & regwriteM) begin
				forwardaE = 3'b001;  // aluoutM
			end 
			else if (rsE == writeregW & regwriteW) begin
				forwardaE = 3'b010;  // resultW
			end
			else if (rsE == writeregM & cp0toregM) begin
				forwardaE = 3'b011;  // cp0data2M
			end
			else if (rsE == writeregW & cp0toregW) begin
				forwardaE = 3'b100;  // cp0data2W
			end
			else begin
				forwardaE = 3'b000;  // srcaE
			end
		end 
		if (rtE != 0) begin
			if (rtE == writeregM & regwriteM) begin
				forwardbE = 3'b001;  // aluoutM
			end 
			else if (rtE == writeregW & regwriteW) begin
				forwardbE = 3'b010;  // resultW
			end
			else if (rtE == writeregM & cp0toregM) begin
				forwardbE = 3'b011;  // cp0data2M
			end
			else if (rtE == writeregW & cp0toregW) begin
				forwardbE = 3'b100;  // cp0data2W
			end
			else begin
				forwardbE = 3'b000;  // srcbE
			end
		end
	end

	assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD);

	// 2. eqcmp 与 JR 的 RAW 数据冒险
		// (1) ADD, x, BEQ/JR -- aluoutM (ME --> ID)
		//     ADD:    IF ID EX ME WB
		//     x:         IF ID EX ME WB
		//     BEQ/JR:       IF ID EX ME WB

		// (2) ADD, BEQ/JR -- branchjrstallD
		//     ADD:    IF ID EX ME WB
		//     BEQ/JR:    IF x  ID EX ME WB

		// (3) LW, x, BEQ/JR -- branchjrstallD
		//     LW:     IF ID EX ME WB
		//     x:         IF ID EX ME WB
		//     BEQ/JR:       IF x  ID EX ME WB

		// (4) LW, BEQ/JR -- branchjrstallD
		//     LW:     IF ID EX ME WB
		//     BEQ/JR:    IF x  x  ID EX ME WB

		// (5) MFHI, BEQ/JR -- hiloresultbE (EX --> ID)
		//     MFHI:   IF ID EX ME WB
		//     BEQ/JR:    IF ID EX ME WB

		// (6) MFHI, x, BEQ/JR -- hiloresultbM (ME --> ID)
		//     MFHI:   IF ID EX ME WB
		//     x:         IF ID EX ME WB
		//     BEQ/JR:       IF ID EX ME WB

		// (7) MFC0, x, BEQ/JR -- cp0data2M (ME --> ID)
		//     MFC0:   IF ID EX ME WB
		//     x:         IF ID EX ME WB
		//     BEQ/JR:       IF ID EX ME WB

		// (8) MFC0, BEQ/JR -- branchjrstallD
		//     MFC0:   IF ID EX ME WB
		//     BEQ/JR:    IF x  ID EX ME WB
	always @(*) begin
		forward_branchjraD = 3'b000;
		forward_branchjrbD = 3'b000;
		if (rsD != 0) begin
			if (rsD == writeregM & regwriteM & ~memtoregM) begin
				forward_branchjraD = 3'b001;  // aluoutM
			end
			else if (rsD == writeregE & hilotoregE) begin
				forward_branchjraD = 3'b010;  // hiloresultbE
			end
			else if (rsD == writeregM & hilotoregM) begin
				forward_branchjraD = 3'b011;  // hiloresultbM
			end
			else if (rsD == writeregM & cp0toregM) begin
				forward_branchjraD = 3'b100;  // cp0data2M
			end
			else begin
				forward_branchjraD = 3'b000;  // srcaD
			end
		end
		if (rtD != 0) begin
			if (rtD == writeregM & regwriteM & ~memtoregM) begin
				forward_branchjrbD = 3'b001;  // aluoutM
			end
			else if (rtD == writeregE & hilotoregE) begin
				forward_branchjrbD = 3'b010;  // hiloresultbE
			end
			else if (rtD == writeregM & hilotoregM) begin
				forward_branchjrbD = 3'b011;  // hiloresultbM
			end
			else if (rtD == writeregM & cp0toregM) begin
				forward_branchjrbD = 3'b100;  // cp0data2M
			end
			else begin
				forward_branchjrbD = 3'b000;  // srcbD
			end
		end
	end

	assign branchjrstallD = (
		(branchD | jumpregD) & (
			(regwriteE & (writeregE == rsD | writeregE == rtD)) |
			(memtoregM & (writeregM == rsD | writeregM == rtD)) |
			(memtoregE & (writeregE == rsD | writeregE == rtD)) |
			(cp0toregE & (writeregE == rsD | writeregE == rtD))
		)
	);

	// 4. MFHI 的数据冒险
		// (1) DIV, MFHI -- multdivresultM (ME --> EX)
		//     DIV:  IF ID EX ME WB
		//     MFHI:    IF ID EX ME WB

		// (2) DIV, x, MFHI -- multdivresultW (WB --> EX)
		//     DIV:  IF ID EX ME WB
		//     x:       IF ID EX ME WB
		//     MFHI:       IF ID EX ME WB

		// (3) MTHI, MFHI -- src_mthiloM (ME --> EX)
		//     MTHI: IF ID EX ME WB
		//     MFHI:    IF ID EX ME WB

		// (4) MTHI, x, MFHI -- src_mthiloW (WB --> EX)
		//     MTHI: IF ID EX ME WB
		//     x:       IF ID EX ME WB
		//     MFHI:       IF ID EX ME WB

		// (5) ADD/LW, x, MFHI -- mfhistallD
		//     ADD/LW: IF ID EX ME WB 
		//     x:         IF ID EX ME WB
		//     MFHI:         IF x  ID EX ME WB

		// (6) ADD/LW, MFHI -- mfhistallD
		//     ADD/LW: IF ID EX ME WB -- mfhistallD
		//     MFHI:      IF x  x  ID EX ME WB
	always @(*) begin
		forward_mfhiloE = 3'b000;
		if ((ismultM | isdivM) & hilotoregE & ~hiorloE) begin
			forward_mfhiloE = 3'b001;  // multdivresultM 高 32 位
		end
		else if ((ismultM | isdivM) & hilotoregE & hiorloE) begin
			forward_mfhiloE = 3'b010;  // multdivresultM 低 32 位
		end
		else if ((ismultW | isdivW) & hilotoregE & ~hiorloE) begin
			forward_mfhiloE = 3'b011;  // multdivresultW 高 32 位
		end
		else if ((ismultW | isdivW) & hilotoregE & hiorloE) begin
			forward_mfhiloE = 3'b100;  // multdivresultW 低 32 位
		end
		else if ((hiwriteM & hilotoregE & ~hiorloE) | (lowriteM & hilotoregE & hiorloE)) begin
			forward_mfhiloE = 3'b101;  // src_mthiloM
		end
		else if ((hiwriteW & hilotoregE & ~hiorloE) | (lowriteW & hilotoregE & hiorloE)) begin
			forward_mfhiloE = 3'b110;  // src_mthiloW
		end
		else begin
			forward_mfhiloE = 3'b000;  // hiloresultaE
		end
	end

	// assign mfhistallD = hilotoregD & (regwriteM | regwriteE) & (~isdivE);
	assign mfhistallD = 1'b0;

	// 5. MTHI 的数据冒险
		// (1) ADD, MTHI -- aluoutM (ME --> EX)
		//     ADD:  IF ID EX ME WB
		//     MTHI:    IF ID EX ME WB

		// (2) ADD, x, MTHI -- resultW (WB --> EX)
		//     ADD:  IF ID EX ME WB
		//     x:       IF ID EX ME WB
		//     MTHI:       IF ID EX ME WB

		// (3) LW, MTHI -- resultW (WB --> ME)
		//     LW:   IF ID EX ME WB
		//     MTHI:    IF ID EX ME WB

		// (4) LW, x, MTHI -- resultW (WB --> EX)
		//     LW:   IF ID EX ME WB
		//     x:       IF ID EX ME WB
		//     MTHI:       IF ID EX ME WB
	always @(*) begin
		forward_mthiloE = 2'b00;
		if (regwriteM & rsE == writeregM & (hiwriteE | lowriteE)) begin
			forward_mthiloE = 2'b01;  // aluoutM
		end
		else if (regwriteW & rsE == writeregW & (hiwriteE | lowriteE)) begin
			forward_mthiloE = 2'b10;  // resultW
		end
		else begin
			forward_mthiloE = 2'b00;  // srcaE
		end
	end

	always @(*) begin
		forward_mthiloM = 1'b0;
		if (regwriteW & rsM == writeregW & (hiwriteM | lowriteM)) begin
			forward_mthiloM = 1'b1;  // resultW
		end
		else begin
			forward_mthiloM = 1'b0;  // srcaM
		end
	end

	// 6. CP0 的数据冒险
		// (1) MTC0, MFC0 -- writedataM (ME --> EX)
		//     MTC0: IF ID EX ME WB
		//     MFC0:    IF ID EX ME WB
	assign forwardcp0M = cp0writeM & cp0toregE & rdM == rdE;


	// 除法器工作流水线暂停
	assign divstallE = isdivE & ~divreadyE;

	// 触发例外流水线刷新
	assign exceptflush = (excepttypeM != 0) ? 1'b1 : 1'b0;
	
	// stall: 流水线暂停, 寄存器中的值保持不变
	assign stallF = stallD;
	assign stallD = stallE | lwstallD | branchjrstallD | mfhistallD | i_stallF;
	assign stallE = stallM | divstallE;
	assign stallM = stallW;
	assign stallW = d_stallM;

	// flush: 流水线刷新, 寄存器中的值清零
	assign flushF = exceptflush;
	assign flushD = exceptflush;
	assign flushE = lwstallD | branchjrstallD | mfhistallD | exceptflush;
	assign flushM = divstallE | exceptflush;
	assign flushW = exceptflush;
	
endmodule
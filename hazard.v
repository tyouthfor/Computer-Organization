`timescale 1ns / 1ps

module hazard(
	/*
		ģ������: hazard
		ģ�鹦��: ð�մ���
		����:

		���:
			(1) IF
			stallF 		1-PC ����, 0-PC ��ͣ

			(2) ID
			forwardaD 	ѡ�� equal ģ���һ��������Դ, 1-aluoutM, 0-srcaD
			forwardbD 	ѡ�� equal ģ��ڶ���������Դ, 1-aluoutM, 0-srcbD
			stallD 		1-IF/ID ��ˮ����ͣ, 0-IF/ID ��ˮ�߹���

			(3) EX
			forwardaE 	ѡ�� ALU ģ���һ��������Դ, 00-srcaE, 01-resultW, 10-aluoutM
			forwardbE 	ѡ�� ALU ģ��ڶ���������Դ, 00-srcbE, 01-resultW, 10-aluoutM
<<<<<<< HEAD
			flushE 		1-ID/EX ��ˮ����ͣ, 0-ID/EX ��ˮ����ͣ
	*/

	// IF
	output 	wire 		stallF,
=======
			stallE		1-ID/EX ��ˮ����ͣ, 0-ID/EX ��ˮ�߹���
			flushE 		1-ID/EX ��ˮ�߳�ˢ, 0-ID/EX ��ˮ�߹���

			(4) ME
			flushM		1-EX/ME ��ˮ�߳�ˢ, 0-EX/ME ��ˮ�߹���
	*/

	// IF
	output 	wire 		stallF, flushF,
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	// ID
	input 	wire[4:0] 	rsD, rtD, rdD,
	input 	wire 		branchD, hilotoregD,
	output 	wire 		forwardaD, forwardbD,
<<<<<<< HEAD
	output 	wire 		stallD,
=======
	output 	wire 		stallD, flushD,
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	// EX
	input 	wire[4:0] 	rsE, rtE,
	input 	wire[4:0] 	writeregE,
	input 	wire 		regwriteE, memtoregE,
	input	wire		hilotoregE, hiorloE,
<<<<<<< HEAD
	output 	reg [1:0] 	forwardaE, forwardbE,
	output	wire		forwardhiloE,
	output 	wire 		flushE,
=======
	input	wire		isdivE, divreadyE,
	output 	reg [1:0] 	forwardaE, forwardbE,
	output	reg [1:0]	forwardhiloE,
	output 	wire 		stallE, flushE,
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	// ME
	input 	wire[4:0] 	writeregM,
	input 	wire 		regwriteM, memtoregM,
	input	wire		hiwriteM, lowriteM,
<<<<<<< HEAD
	// WB
	input 	wire[4:0] 	writeregW,
	input 	wire 		regwriteW
    );

	wire 				lwstallD, branchstallD, mfhistallD;
=======
	input	wire		ismultM, isdivM,
	output	wire		stallM, flushM,
	// WB
	input 	wire[4:0] 	writeregW,
	input 	wire 		regwriteW,
	output	wire		stallW, flushW
    );

	wire 				lwstallD, branchstallD, mfhistallD, divstallE;
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	
	// forwarding ��� ALU �� RAW ����ð��
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
<<<<<<< HEAD
			end 
=======
			end
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
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
<<<<<<< HEAD
		end 
=======
		end
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
		else begin
			forwardbE = 2'b00;
		end
	end

	// forwarding ��� branch equality �� RAW ����ð��
		// (1) ADD, x, BEQ -- aluoutM (ME --> ID)
		//     ADD: IF ID EX ME WB
		//     x:      IF ID EX ME WB
		//     BEQ:       IF ID EX ME WB
		// (2) LW, x, x, BEQ �ƺ�����Ҫ, ��Ϊ WB ����Ҫд�ؼĴ�����(����Ĵ�����д���ȵĻ���û����)
		//     LW:  IF ID EX ME WB
		//     x:      IF ID EX ME WB
		//     x:         IF ID EX ME WB
		//     BEQ:          IF ID EX ME WB
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);

<<<<<<< HEAD
	// forwarding ��� MFHI �� RAW ����ð��
		// (1) MTHI, MFHI -- srcaM
		//     MTHI: IF ID EX ME WB
		//     MFHI:    IF ID EX ME WB
	assign forwardhiloE = (hiwriteM & hilotoregE & hiorloE == 1'b0 |
						   lowriteM & hilotoregE & hiorloE == 1'b1);
=======
	// forwarding ��� HILO �� RAW ����ð��
		// (1) DIV, MFHI -- multdivresultM (ME --> EX)
		//     DIV:  IF ID EX ME WB
		//     MFHI:    IF ID EX ME WB
		// (2) MTHI, MFHI -- srcaM (ME --> EX)
		//     MTHI: IF ID EX ME WB
		//     MFHI:    IF ID EX ME WB
	always @(*) begin
		if ((ismultM | isdivM) & hilotoregE & hiorloE == 1'b0) begin
			forwardhiloE <= 2'b01;  // multdivresultM �� 32 λ
		end
		else if ((ismultM | isdivM) & hilotoregE & hiorloE == 1'b1) begin
			forwardhiloE <= 2'b10;  // multdivresultM �� 32 λ
		end
		else if ((hiwriteM | lowriteM) & hilotoregE) begin
			forwardhiloE <= 2'b11;  // srcaM
		end
		else begin
			forwardhiloE <= 2'b00;  // hiloresultaE
		end
	end
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9

	// stall ��� ALU �� RAW ����ð��
		// (1) LW, ADD
		//     LW:  IF ID EX ME WB
		//     ADD:    IF x  ID EX ME WB
	assign #1 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);

	// stall ��� branch equality �� RAW ����ð��
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

	// stall ��� MFHI �� WAW ����ð��
		// (1) ADD/LW: IF ID EX ME WB
		//     x:         IF ID EX ME WB
		//     MFHI:         IF x  ID EX ME WB
		// (2) ADD/LW: IF ID EX ME WB
		//     MFHI:      IF x  x  ID EX ME WB
	assign #1 mfhistallD = hilotoregD &
				(regwriteM & (writeregM == rdD) |
				 regwriteE & (writeregE == rdD));
<<<<<<< HEAD
	
	// stallD & stallF: ��ˮ����ͣ, �Ĵ����е�ֵ���ֲ���
	// flushE: ��ˮ��ˢ��, �Ĵ����е�ֵ����
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
	assign #1 stallD = lwstallD | branchstallD | mfhistallD;
	assign #1 stallF = stallD;
	assign #1 flushE = stallD;
=======

	// ��������ˮ����ͣ
	assign #1 divstallE = isdivE & ~divreadyE;
	
	// stall: ��ˮ����ͣ, �Ĵ����е�ֵ���ֲ���
	assign #1 stallF = stallD;
	assign #1 stallD = stallE | lwstallD | branchstallD | mfhistallD;
	assign #1 stallE = stallM | divstallE;
	assign #1 stallM = stallW;
	assign #1 stallW = 1'b0;

	// flush: ��ˮ��ˢ��, �Ĵ����е�ֵ����
	assign #1 flushF = 1'b0;
	assign #1 flushD = 1'b0;
	assign #1 flushE = lwstallD | branchstallD | mfhistallD;
	assign #1 flushM = divstallE;
	assign #1 flushW = 1'b0;
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	
endmodule

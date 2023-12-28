`timescale 1ns / 1ps

module datapath(
	input 	wire 		clk, rst,
	// IF
	output 	wire[31:0] 	pcF,
	input 	wire[31:0] 	instrF,
	// ID
	input 	wire 		pcsrcD, branchD, jumpD,
	input	wire		hilotoregD, hiorloD,
	output 	wire 		equalD,
	output 	wire[5:0] 	opD, functD,
	// EX
	input	wire		regdstE, alusrcE, memtoregE, regwriteE, 
	input	wire		hilotoregE, hiorloE,
	input 	wire[5:0] 	alucontrolE,
	output 	wire 		flushE,
	// ME
	input 	wire 		memtoregM, regwriteM,
	input	wire		hiwriteM, lowriteM,
	input 	wire[31:0] 	readdataM,
	output 	wire[31:0] 	aluoutM, writedataM,
	// WB
	input 	wire 		memtoregW, regwriteW,
	input	wire		hiwriteW, lowriteW
    );
	
	// IF
	wire [31:0]			pcplus4F;
	wire [31:0] 		pcnextFD;
	wire 				stallF;
	// ID
	wire [31:0]			instrD;
	wire [4:0]			rsD, rtD, rdD, shamtD;
	wire [31:0] 		pcplus4D, pcbranchD, pcnextbrFD;
	wire [31:0] 		srcaD, srca2D, srcbD, srcb2D;
	wire [31:0] 		signimmD, signimmshD;
	wire [31:0]			hiresultD, loresultD, hiloresultaD;
	wire 				forwardaD, forwardbD;
	wire 				flushD, stallD;
	// EX
	wire [1:0] 			forwardaE, forwardbE;
	wire [4:0] 			rsE, rtE, rdE, shamtE;
	wire [4:0] 			writeregE;
	wire [31:0] 		srcaE, srca2E, srcbE, srcb2E, srcb3E;
	wire [31:0] 		signimmE;
	wire [31:0] 		aluoutE;
	wire [31:0]			hiloresultaE, hiloresultbE, resultWE;
	wire				forwardhiloE;
	// ME
	wire [4:0] 			writeregM;
	wire [31:0]			srcaM;
	// WB
	wire [4:0] 			writeregW;
	wire [31:0] 		aluoutW, readdataW, resultW;
	wire [31:0]			srcaW;

	hazard h(
		// IF
		stallF,
		// ID
		rsD, rtD, rdD,
		branchD, hilotoregD,
		forwardaD, forwardbD,
		stallD,
		// EX
		rsE, rtE,
		writeregE,
		regwriteE, memtoregE,
		hilotoregE, hiorloE,
		forwardaE, forwardbE,
		forwardhiloE,
		flushE,
		// ME
		writeregM, 
		regwriteM, memtoregM,
		hiwriteM, lowriteM,
		// WB
		writeregW,
		regwriteW
	);

	assign opD = instrD[31:26];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign shamtD = instrD[10:6];
	assign functD = instrD[5:0];

	// 1.IF
	// (1) PC Óë PC + 4
	pc 			#(32) 	pcreg(clk, rst, ~stallF, pcnextFD, pcF);
	adder 				pcadd1(pcF, 32'b100, pcplus4F);

	// 2.ID
	// (1) Á÷Ë®Ïß¼Ä´æÆ÷
	flopenr 	#(32) 	r1D(clk, rst, ~stallD, pcplus4F, pcplus4D);
	flopenrc 	#(32) 	r2D(clk, rst, ~stallD, flushD, instrF, instrD);

	// (2) ¼Ä´æÆ÷¶ÑÓë HILO ¼Ä´æÆ÷
	mux2		#(32)	hilomux(resultW, hiloresultbE, hilotoregE, resultWE);
	regfile 			rf(clk, regwriteW, rsD, rtD, writeregW, resultWE, srcaD, srcbD);
	HILO				hi(clk, hiwriteW, srcaW, hiresultD);
	HILO 				lo(clk, lowriteW, srcaW, loresultD);
	mux2		#(32)	hiorlomux(hiresultD, loresultD, hiorloD, hiloresultaD);

	// (3) PC next
	signext 			se(instrD[15:0], signimmD);
	sl2 				immsh(signimmD, signimmshD);
	adder 				pcadd2(pcplus4D, signimmshD, pcbranchD);
	mux2 		#(32) 	pcbrmux(pcplus4F, pcbranchD, pcsrcD, pcnextbrFD);
	mux2 		#(32) 	pcmux(pcnextbrFD, {pcplus4D[31:28], instrD[25:0], 2'b00}, jumpD, pcnextFD);

	// (4) branch ±È½Ï
	mux2 		#(32) 	forwardamux(srcaD, aluoutM, forwardaD, srca2D);
	mux2 		#(32) 	forwardbmux(srcbD, aluoutM, forwardbD, srcb2D);
	eqcmp 				comp(srca2D, srcb2D, equalD);

	// 3.EX
	// (1) Á÷Ë®Ïß¼Ä´æÆ÷
	floprc 		#(32) 	r1E(clk, rst, flushE, srcaD, srcaE);
	floprc 		#(32) 	r2E(clk, rst, flushE, srcbD, srcbE);
	floprc 		#(32) 	r3E(clk, rst, flushE, signimmD, signimmE);
	floprc 		#(5) 	r4E(clk, rst, flushE, rsD, rsE);
	floprc 		#(5) 	r5E(clk, rst, flushE, rtD, rtE);
	floprc 		#(5) 	r6E(clk, rst, flushE, rdD, rdE);
	floprc 		#(5) 	r7E(clk, rst, flushE, shamtD, shamtE);
	floprc		#(32)	r8E(clk, rst, flushE, hiloresultaD, hiloresultaE);

	// (2) ALU
	mux3 		#(32) 	forwardaemux(srcaE, resultW, aluoutM, forwardaE, srca2E);
	mux3		#(32) 	forwardbemux(srcbE, resultW, aluoutM, forwardbE, srcb2E);
	mux2 		#(32) 	srcbmux(srcb2E, signimmE, alusrcE, srcb3E);
	alu 				alu(srca2E, srcb3E, shamtE, alucontrolE, aluoutE);

	// (3) Ð´¼Ä´æÆ÷ºÅÑ¡ÔñÆ÷
	mux2 		#(5) 	wrmux(rtE, rdE, regdstE, writeregE);

	// (4) MFHI Ð´¼Ä´æÆ÷Êý¾ÝÑ¡ÔñÆ÷
	mux2		#(32)	forwardhilomux(hiloresultaE, srcaM, forwardhiloE, hiloresultbE);

	// 4.ME
	// (1) Á÷Ë®Ïß¼Ä´æÆ÷
	flopr 		#(32) 	r1M(clk, rst, srcb2E, writedataM);
	flopr		#(32) 	r2M(clk, rst, aluoutE, aluoutM);
	flopr 		#(5) 	r3M(clk, rst, writeregE, writeregM);
	flopr		#(32)	r4M(clk, rst, srcaE, srcaM);

	// 5.WB
	// (1) Á÷Ë®Ïß¼Ä´æÆ÷
	flopr 		#(32) 	r1W(clk, rst, aluoutM, aluoutW);
	flopr 		#(32) 	r2W(clk, rst, readdataM, readdataW);
	flopr 		#(5) 	r3W(clk, rst, writeregM, writeregW);
	flopr		#(32)	r4W(clk, rst, srcaM, srcaW);

	// (2) Ð´¼Ä´æÆ÷Êý¾ÝÑ¡ÔñÆ÷
	mux2 		#(32) 	resmux(aluoutW, readdataW, memtoregW, resultW);

endmodule

`timescale 1ns / 1ps

module datapath(
	input 	wire 		clk, rst,
	// IF
	output 	wire[31:0] 	pcF,
	input 	wire[31:0] 	instrF,
	// ID
	input 	wire 		pcsrcD, branchD, jumpD,
	input	wire		hilotoregD, hiorloD,
	input	wire		immseD,
	output 	wire 		equalD,
	output 	wire[5:0] 	opD, functD,
	// EX
	input	wire		regdstE, alusrcE, memtoregE, regwriteE, 
	input	wire		hilotoregE, hiorloE,
	input 	wire[5:0] 	alucontrolE,
	input	wire		ismultE, signedmultE,
	input	wire		isdivE, signeddivE,
	output 	wire 		stallE, flushE,
	// ME
	input 	wire 		memtoregM, regwriteM,
	input	wire		hiwriteM, lowriteM,
	input	wire		ismultM, isdivM,
	input 	wire[31:0] 	readdataM,
	output 	wire[31:0] 	aluoutM, writedataM,
	output	wire		stallM, flushM,
	// WB
	input 	wire 		memtoregW, regwriteW,
	input	wire		hiwriteW, lowriteW,
	input	wire		ismultW, isdivW,
	output	wire		stallW, flushW
    );
	
	// IF
	wire [31:0]			pcplus4F;
	wire [31:0] 		pcnextFD;
	wire 				stallF, flushF;
	// ID
	wire [31:0]			instrD;
	wire [4:0]			rsD, rtD, rdD, shamtD;
	wire [31:0] 		pcplus4D, pcbranchD, pcnextbrFD;
	wire [31:0] 		srcaD, srca2D, srcbD, srcb2D;
	wire [31:0] 		signimmD, signimmshD;
	wire [31:0]			hiresultD, loresultD, hiloresultaD;
	wire 				forwardaD, forwardbD;
	wire 				stallD, flushD;
	// EX
	wire [1:0] 			forwardaE, forwardbE;
	wire [4:0] 			rsE, rtE, rdE, shamtE;
	wire [4:0] 			writeregE;
	wire [31:0] 		srcaE, srca2E, srcbE, srcb2E, srcb3E;
	wire [31:0] 		signimmE;
	wire [31:0] 		aluoutE;
	wire [31:0]			hiloresultaE, hiloresultbE, resultWE;
	wire [1:0]			forwardhiloE;
	wire [63:0]			multresultE, divresultE;
	wire [63:0]			multdivresultE;
	wire				divreadyE;
	// ME
	wire [4:0] 			writeregM;
	wire [31:0]			srcaM;
	wire [63:0]			multdivresultM;
	wire				divreadyM;
	// WB
	wire [4:0] 			writeregW;
	wire [31:0] 		aluoutW, readdataW, resultW;
	wire [31:0]			srcaW;
	wire [63:0]			multdivresultW;
	wire [31:0]			hiwritedataW, lowritedataW;
	wire				divreadyW;

	hazard h(
		// IF
		stallF, flushF,
		// ID
		rsD, rtD, rdD,
		branchD, hilotoregD,
		forwardaD, forwardbD,
		stallD, flushD,
		// EX
		rsE, rtE,
		writeregE,
		regwriteE, memtoregE,
		hilotoregE, hiorloE,
		isdivE, divreadyE,
		forwardaE, forwardbE,
		forwardhiloE,
		stallE, flushE,
		// ME
		writeregM, 
		regwriteM, memtoregM,
		hiwriteM, lowriteM,
		ismultM, isdivM,
		stallM, flushM,
		// WB
		writeregW,
		regwriteW,
		stallW, flushW
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
	flopenrc 	#(32) 	r1D(clk, rst, ~stallD, flushD, pcplus4F, pcplus4D);
	flopenrc 	#(32) 	r2D(clk, rst, ~stallD, flushD, instrF, instrD);

	// (2) ¼Ä´æÆ÷¶Ñ
	mux2		#(32)	hilomux(resultW, hiloresultbE, hilotoregE, resultWE);
	regfile 			rf(clk, regwriteW, rsD, rtD, writeregW, resultWE, srcaD, srcbD);

	// (3) HILO ¼Ä´æÆ÷
	mux2		#(32)	himux(srcaW, multdivresultW[63:32], ismultW | isdivW, hiwritedataW);
	mux2		#(32)	lomux(srcaW, multdivresultW[31:0], ismultW | isdivW, lowritedataW);
	HILO				hi(clk, hiwriteW, hiwritedataW, hiresultD);
	HILO 				lo(clk, lowriteW, lowritedataW, loresultD);
	mux2		#(32)	hiorlomux(hiresultD, loresultD, hiorloD, hiloresultaD);

	// (4) Á¢¼´ÊýÀ©Õ¹
	signext 			se(instrD[15:0], immseD, signimmD);

	// (5) PC next
	sl2 				immsh(signimmD, signimmshD);
	adder 				pcadd2(pcplus4D, signimmshD, pcbranchD);
	mux2 		#(32) 	pcbrmux(pcplus4F, pcbranchD, pcsrcD, pcnextbrFD);
	mux2 		#(32) 	pcmux(pcnextbrFD, {pcplus4D[31:28], instrD[25:0], 2'b00}, jumpD, pcnextFD);

	// (6) branch equality ±È½Ï
	mux2 		#(32) 	forwardamux(srcaD, aluoutM, forwardaD, srca2D);
	mux2 		#(32) 	forwardbmux(srcbD, aluoutM, forwardbD, srcb2D);
	eqcmp 				comp(srca2D, srcb2D, equalD);

	// 3.EX
	// (1) Á÷Ë®Ïß¼Ä´æÆ÷
	flopenrc	#(32)	r1E(clk, rst, ~stallE, flushE, srcaD, srcaE);
	flopenrc 	#(32) 	r2E(clk, rst, ~stallE, flushE, srcbD, srcbE);
	flopenrc 	#(32) 	r3E(clk, rst, ~stallE, flushE, signimmD, signimmE);
	flopenrc 	#(5) 	r4E(clk, rst, ~stallE, flushE, rsD, rsE);
	flopenrc 	#(5) 	r5E(clk, rst, ~stallE, flushE, rtD, rtE);
	flopenrc 	#(5) 	r6E(clk, rst, ~stallE, flushE, rdD, rdE);
	flopenrc 	#(5) 	r7E(clk, rst, ~stallE, flushE, shamtD, shamtE);
	flopenrc	#(32)	r8E(clk, rst, ~stallE, flushE, hiloresultaD, hiloresultaE);

	// (2) ALU
	mux3 		#(32) 	forwardaemux(srcaE, resultW, aluoutM, forwardaE, srca2E);
	mux3		#(32) 	forwardbemux(srcbE, resultW, aluoutM, forwardbE, srcb2E);
	mux2 		#(32) 	srcbmux(srcb2E, signimmE, alusrcE, srcb3E);
	alu 				alu(srca2E, srcb3E, shamtE, alucontrolE, aluoutE);

	// (3) ³Ë³ý·¨Æ÷
	mult				mult(srca2E, srcb3E, signedmultE, multresultE);
	div					div(clk, rst, signeddivE, srca2E, srcb3E, isdivE & ~divreadyE, 1'b0, divresultE, divreadyE);
	mux2		#(64)	multordivmux(multresultE, divresultE, isdivE, multdivresultE);

	// (3) Ð´¼Ä´æÆ÷ºÅÑ¡ÔñÆ÷
	mux2 		#(5) 	wrmux(rtE, rdE, regdstE, writeregE);

	// (4) MFHI/MFLO Ð´¼Ä´æÆ÷Êý¾ÝÑ¡ÔñÆ÷
	mux4		#(32)	forwardhilomux(hiloresultaE, multdivresultM[63:32], multdivresultM[31:0], srcaM, forwardhiloE, hiloresultbE);

	// 4.ME
	// (1) Á÷Ë®Ïß¼Ä´æÆ÷
	flopenrc 	#(32) 	r1M(clk, rst, ~stallM, flushM, srcb2E, writedataM);
	flopenrc	#(32) 	r2M(clk, rst, ~stallM, flushM, aluoutE, aluoutM);
	flopenrc 	#(5) 	r3M(clk, rst, ~stallM, flushM, writeregE, writeregM);
	flopenrc	#(32)	r4M(clk, rst, ~stallM, flushM, srcaE, srcaM);
	flopenrc	#(65)	r5M(clk, rst, ~stallM, flushM, {multdivresultE, divreadyE}, {multdivresultM, divreadyM});

	// 5.WB
	// (1) Á÷Ë®Ïß¼Ä´æÆ÷
	flopenrc 	#(32) 	r1W(clk, rst, ~stallW, flushW, aluoutM, aluoutW);
	flopenrc 	#(32) 	r2W(clk, rst, ~stallW, flushW, readdataM, readdataW);
	flopenrc 	#(5) 	r3W(clk, rst, ~stallW, flushW, writeregM, writeregW);
	flopenrc	#(32)	r4W(clk, rst, ~stallW, flushW, srcaM, srcaW);
	flopenrc	#(65)	r5W(clk, rst, ~stallW, flushW, {multdivresultM, divreadyM}, {multdivresultW, divreadyW});

	// (2) Ð´¼Ä´æÆ÷Êý¾ÝÑ¡ÔñÆ÷
	mux2 		#(32) 	resmux(aluoutW, readdataW, memtoregW, resultW);

endmodule

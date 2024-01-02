`timescale 1ns / 1ps

module datapath(
	input 	wire 		clk, rst,
	// IF
	output 	wire[31:0] 	pcF,
	input 	wire[31:0] 	instrF,
	// ID
	input 	wire 		pcsrcD, branchD, jumpD, jumpregD,
	input	wire		hilotoregD, hiorloD,
	input	wire		immseD,
	output 	wire 		equalD,
	output 	wire[5:0] 	opD, functD, rtD,
	// EX
	input	wire		regdstE, alusrcE, memtoregE, regwriteE, 
	input	wire		hilotoregE, hiorloE,
	input 	wire[5:0] 	alucontrolE,
	input	wire		ismultE, signedmultE,
	input	wire		isdivE, signeddivE,
	input	wire		linkregE,
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
	input	wire		linkdataW,
	output	wire		stallW, flushW
    );
	
	// IF
	wire [31:0]			pcplus4F, pcplus8F;
	wire [31:0] 		pcnextFD;
	wire 				stallF, flushF;
	wire				branchjumpF;
	// ID
	wire [31:0]			instrD;
	wire [4:0]			rsD, rdD, shamtD;
	wire [31:0] 		pcplus4D, pcplus8D, pcbranchD, pcnextbrFD, pcnextjdFD;
	wire [31:0] 		srcaD, srca2D, srcbD, srcb2D;
	wire [31:0] 		signimmD, signimmshD;
	wire [31:0]			hiresultD, loresultD, hiloresultaD;
	wire 				forwardaD, forwardbD;
	wire 				stallD, flushD;
	// EX
	wire [1:0] 			forwardaE, forwardbE;
	wire [4:0] 			rsE, rtE, rdE, shamtE;
	wire [5:0]         opE;
	wire [4:0] 			writeregE, writereg_brE, writeregWE;
	wire [31:0] 		srcaE, srca2E, srcbE, srcb2E, srcb3E;
	wire [31:0] 		signimmE;
	wire [31:0] 		aluoutE;
	wire [31:0]			hiloresultaE, hiloresultbE, resultWE;
	wire [1:0]			forwardhiloE;
	wire [63:0]			multresultE, divresultE;
	wire [63:0]			multdivresultE;
	wire				divreadyE;
	wire [31:0] 		pcplus8E;
	// ME
	wire [4:0] 			writereg_brM;
	wire [31:0]			srcaM;
	wire [5:0]         opM;
	wire [63:0]			multdivresultM;
	wire [31:0] 		pcplus8M;
	// WB
	wire [4:0] 			writereg_brW;
	wire [5:0]         opW;
	wire [31:0] 		aluoutW, readdataW, result_nolinkW, resultW;
	wire [31:0]			srcaW;
	wire [63:0]			multdivresultW;
	wire [31:0]			hiwritedataW, lowritedataW;
	wire [31:0] 		pcplus8W;
	wire [31:0] 		lwresultW;

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
		writereg_brE,
		regwriteE, memtoregE,
		hilotoregE, hiorloE,
		isdivE, divreadyE,
		forwardaE, forwardbE,
		forwardhiloE,
		stallE, flushE,
		// ME
		writereg_brM, 
		regwriteM, memtoregM,
		hiwriteM, lowriteM,
		ismultM, isdivM,
		stallM, flushM,
		// WB
		writereg_brW,
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
	adder				pcadd2(pcF, 32'b1000, pcplus8F);

	// 2.ID
	// (1) Á÷Ë®Ïß¼Ä´æÆ÷
	flopenrc 	#(32) 	r1D(clk, rst, ~stallD, flushD, pcplus4F, pcplus4D);
	flopenrc 	#(32) 	r2D(clk, rst, ~stallD, flushD, instrF, instrD);
	flopenrc 	#(32) 	r4D(clk, rst, ~stallD, flushD, pcplus8F, pcplus8D);

	// (2) ¼Ä´æÆ÷¶Ñ
	mux2		#(32)	hiloregmux(writereg_brW, writereg_brE, hilotoregE, writeregWE);
	mux2		#(32)	hilodatamux(resultW, hiloresultbE, hilotoregE, resultWE);
	regfile 			rf(clk, regwriteW, rsD, rtD, writeregWE, resultWE, srcaD, srcbD);

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
	adder 				pcadd3(pcplus4D, signimmshD, pcbranchD);
	mux2 		#(32) 	pcbrmux(pcplus4F, pcbranchD, pcsrcD, pcnextbrFD);
	mux2 		#(32) 	pcjdmux(pcnextbrFD, {pcplus4D[31:28], instrD[25:0], 2'b00}, jumpD, pcnextjdFD);
	mux2		#(32)	pcjrmux(pcnextjdFD, srca2D, jumpregD, pcnextFD);

	// (6) branch ±È½Ï
	mux2 		#(32) 	forwardamux(srcaD, aluoutM, forwardaD, srca2D);
	mux2 		#(32) 	forwardbmux(srcbD, aluoutM, forwardbD, srcb2D);
	eqcmp 				comp(srca2D, srcb2D, opD, rtD, equalD);

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
	flopenrc	#(32)	r9E(clk, rst, ~stallE, flushE, pcplus8D, pcplus8E);
	flopenrc 	#(6) 	r10E(clk, rst, ~stallE, flushE, opD, opE);

	// (2) ALU
	mux3 		#(32) 	forwardaemux(srcaE, resultW, aluoutM, forwardaE, srca2E);
	mux3		#(32) 	forwardbemux(srcbE, resultW, aluoutM, forwardbE, srcb2E);
	mux2 		#(32) 	srcbmux(srcb2E, signimmE, alusrcE, srcb3E);
	alu 				alu(srca2E, srcb3E, shamtE, alucontrolE, aluoutE);

	// (3) ³Ë³ý·¨Æ÷
	mult				mult(srca2E, srcb3E, signedmultE, multresultE);
	div					div(clk, rst, signeddivE, srca2E, srcb3E, isdivE & ~divreadyE, 1'b0, divresultE, divreadyE);
	mux2		#(64)	multordivmux(multresultE, divresultE, isdivE, multdivresultE);

	// (4) Ð´¼Ä´æÆ÷ºÅÑ¡ÔñÆ÷
	mux2 		#(5) 	wr1mux(rtE, rdE, regdstE, writeregE);
	mux2		#(5)	wr2mux(writeregE, 5'b11111, linkregE, writereg_brE);

	// (5) MFHI/MFLO Ð´¼Ä´æÆ÷Êý¾ÝÑ¡ÔñÆ÷
	mux4		#(32)	forwardhilomux(hiloresultaE, multdivresultM[63:32], multdivresultM[31:0], srcaM, forwardhiloE, hiloresultbE);

	// 4.ME
	// (1) Á÷Ë®Ïß¼Ä´æÆ÷
	flopenrc 	#(32) 	r1M(clk, rst, ~stallM, flushM, srcb2E, writedataM);
	flopenrc	#(32) 	r2M(clk, rst, ~stallM, flushM, aluoutE, aluoutM);
	flopenrc 	#(5) 	r3M(clk, rst, ~stallM, flushM, writereg_brE, writereg_brM);
	flopenrc	#(32)	r4M(clk, rst, ~stallM, flushM, srcaE, srcaM);
	flopenrc	#(64)	r5M(clk, rst, ~stallM, flushM, multdivresultE, multdivresultM);
	flopenrc	#(32)	r6M(clk, rst, ~stallM, flushM, pcplus8E, pcplus8M);
	flopenrc 	#(6) 	r7M(clk, rst, ~stallM, flushM, opE, opM);
	
//	sw_sel              swsel(aluoutM,opM,);

	// 5.WB
	// (1) Á÷Ë®Ïß¼Ä´æÆ÷
	flopenrc 	#(32) 	r1W(clk, rst, ~stallW, flushW, aluoutM, aluoutW);
	flopenrc 	#(32) 	r2W(clk, rst, ~stallW, flushW, readdataM, readdataW);
	flopenrc 	#(5) 	r3W(clk, rst, ~stallW, flushW, writereg_brM, writereg_brW);
	flopenrc	#(32)	r4W(clk, rst, ~stallW, flushW, srcaM, srcaW);
	flopenrc	#(64)	r5W(clk, rst, ~stallW, flushW, multdivresultM, multdivresultW);
	flopenrc	#(32)	r6W(clk, rst, ~stallW, flushW, pcplus8M, pcplus8W);
	flopenrc 	#(6) 	r7W(clk, rst, ~stallW, flushW, opM, opW);

	// (2) Ð´¼Ä´æÆ÷Êý¾ÝÑ¡ÔñÆ÷
	lw_sel              lwsel(aluoutW, readdataW,opW, lwresultW);
	mux2 		#(32) 	res1mux(aluoutW, lwresultW, memtoregW, result_nolinkW);
	mux2		#(32)	res2mux(result_nolinkW, pcplus8W, linkdataW, resultW);

endmodule

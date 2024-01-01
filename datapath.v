`timescale 1ns / 1ps

module datapath(
	input 	wire 		clk, rst,
	// IF
	output 	wire[31:0] 	pcF,
	input 	wire[31:0] 	instrF,
	// ID
	input 	wire 		pcsrcD, branchD, jumpD,
	input	wire		hilotoregD, hiorloD,
<<<<<<< HEAD
=======
	input	wire		immseD,
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	output 	wire 		equalD,
	output 	wire[5:0] 	opD, functD,
	// EX
	input	wire		regdstE, alusrcE, memtoregE, regwriteE, 
	input	wire		hilotoregE, hiorloE,
	input 	wire[5:0] 	alucontrolE,
<<<<<<< HEAD
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
	wire [31:0]			pcplus4F,pcplus8F;
	wire [31:0] 		pcnextFD;
	wire 				stallF;
	wire               branchjumpF;
	// ID
	wire [31:0]			instrD;
	wire [4:0]			rsD, rtD, rdD, shamtD;
	wire [31:0] 		pcplus4D, pcbranchD, pcnextbrFD, pcD,pcplus8D;
	wire               branchjumpD;
=======
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
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	wire [31:0] 		srcaD, srca2D, srcbD, srcb2D;
	wire [31:0] 		signimmD, signimmshD;
	wire [31:0]			hiresultD, loresultD, hiloresultaD;
	wire 				forwardaD, forwardbD;
<<<<<<< HEAD
	wire 				flushD, stallD;
	// EX
	wire [1:0] 			forwardaE, forwardbE;
	wire [4:0] 			rsE, rtE, rdE, shamtE;
	wire [31:0] 		pcplusED, pcE,pcplus8E;
	wire [4:0] 			writeregE,writereg_brE;
	wire [5:0] 			opE;
=======
	wire 				stallD, flushD;
	// EX
	wire [1:0] 			forwardaE, forwardbE;
	wire [4:0] 			rsE, rtE, rdE, shamtE;
	wire [4:0] 			writeregE;
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	wire [31:0] 		srcaE, srca2E, srcbE, srcb2E, srcb3E;
	wire [31:0] 		signimmE;
	wire [31:0] 		aluoutE;
	wire [31:0]			hiloresultaE, hiloresultbE, resultWE;
<<<<<<< HEAD
	wire				forwardhiloE;
	wire                branchjumpE;
	// ME
	wire [4:0] 			writeregM;
	wire [31:0]			srcaM;
	wire [31:0]			pcM;
	wire                branchjumpM;
=======
	wire [1:0]			forwardhiloE;
	wire [63:0]			multresultE, divresultE;
	wire [63:0]			multdivresultE;
	wire				divreadyE;
	// ME
	wire [4:0] 			writeregM;
	wire [31:0]			srcaM;
	wire [63:0]			multdivresultM;
	wire				divreadyM;
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	// WB
	wire [4:0] 			writeregW;
	wire [31:0] 		aluoutW, readdataW, resultW;
	wire [31:0]			srcaW;
<<<<<<< HEAD

	hazard h(
		// IF
		stallF,
=======
	wire [63:0]			multdivresultW;
	wire [31:0]			hiwritedataW, lowritedataW;
	wire				divreadyW;

	hazard h(
		// IF
		stallF, flushF,
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
		// ID
		rsD, rtD, rdD,
		branchD, hilotoregD,
		forwardaD, forwardbD,
<<<<<<< HEAD
		stallD,
=======
		stallD, flushD,
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
		// EX
		rsE, rtE,
		writeregE,
		regwriteE, memtoregE,
		hilotoregE, hiorloE,
<<<<<<< HEAD
		forwardaE, forwardbE,
		forwardhiloE,
		flushE,
=======
		isdivE, divreadyE,
		forwardaE, forwardbE,
		forwardhiloE,
		stallE, flushE,
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
		// ME
		writeregM, 
		regwriteM, memtoregM,
		hiwriteM, lowriteM,
<<<<<<< HEAD
		// WB
		writeregW,
		regwriteW
=======
		ismultM, isdivM,
		stallM, flushM,
		// WB
		writeregW,
		regwriteW,
		stallW, flushW
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	);

	assign opD = instrD[31:26];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign shamtD = instrD[10:6];
	assign functD = instrD[5:0];

	// 1.IF
	// (1) PC 与 PC + 4
	pc 			#(32) 	pcreg(clk, rst, ~stallF, pcnextFD, pcF);
<<<<<<< HEAD
	adder 				pcadd1(pcF, 32'b100, pcplus4F);  //顺序执行PC+4
	adder 				pcadd2(pcF, 32'b1000, pcplus8F); //JAL/JALR/BGEZAL/BLTZAL指令的PC,GPR[31] = PC+8
	
	//(2) 确定下一条PC
	mux2 		#(32) 	pcbrmux(pcplus4F, pcbranchD, pcsrcD, pcnextbrFD);    //PCnext = PC+4 or branch
	mux2 		#(32) 	pcmux(pcnextbrFD, {pcplus4D[31:28], instrD[25:0], 2'b00}, jumpD, pcnextFD); ////PCnext = PCnext or j/jal
	
	//(3)是否是跳转指令
	assign branchjumpF = branchD | jumpD;
=======
	adder 				pcadd1(pcF, 32'b100, pcplus4F);
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9

	// 2.ID
	// (1) 流水线寄存器
	flopenrc 	#(32) 	r1D(clk, rst, ~stallD, flushD, pcplus4F, pcplus4D);
	flopenrc 	#(32) 	r2D(clk, rst, ~stallD, flushD, instrF, instrD);
<<<<<<< HEAD
	flopenrc 	#(32) 	r3D(clk, rst, ~stallD, flushD, pcF, pcD);
	flopenrc 	#(32) 	r4D(clk, rst, ~stallD, flushD, pcplus8F, pcplus8D);
	flopenrc    #(1)    r5D(clk, rst, ~stallD, flushD, branchjumpF, branchjumpD);

	// (2) 寄存器堆与 HILO 寄存器
	mux2		#(32)	hilomux(resultW, hiloresultbE, hilotoregE, resultWE);
	regfile 			rf(clk, regwriteW, rsD, rtD, writeregW, resultWE, srcaD, srcbD);
	HILO				hi(clk, hiwriteW, srcaW, hiresultD);
	HILO 				lo(clk, lowriteW, srcaW, loresultD);
	mux2		#(32)	hiorlomux(hiresultD, loresultD, hiorloD, hiloresultaD);

	// (3) PC next
	signext 			se(instrD[15:0], signimmD); //instrD扩展
	sl2 				immsh(signimmD, signimmshD);  //扩展后左移
	adder 				pcadd3(pcplus4D, signimmshD, pcbranchD);  //计算branch指令的跳转地址:PC+Sign_extend({offset,00})

	// (4) branch 比较
	mux2 		#(32) 	forwardamux(srcaD, aluoutM, forwardaD, srca2D);
	mux2 		#(32) 	forwardbmux(srcbD, aluoutM, forwardbD, srcb2D);
	eqcmp 				comp(srca2D, srcb2D, opD, rtD, equalD);

	// 3.EX
	// (1) 流水线寄存器
	flopenrc 		#(32) 	r1E(clk, rst, flushE, pcD, pcE);
	flopenrc        #(32) 	r2E(clk,rst,~stallE,flushE,instrD,instrE);
	flopenrc        #(32) 	r3E(clk,rst,~stallE,flushE,pcplus4D,pcplus4E);
	flopenrc        #(32) 	r4E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);
	flopenrc        #(1) 	r5E(clk,rst,~stallE,flushE,branchjumpD,branchjumpE);
	flopenrc 		#(32) 	r6E(clk, rst, flushE, srcaD, srcaE);
	flopenrc 		#(32) 	r7E(clk, rst, flushE, srcbD, srcbE);
	flopenrc 		#(32) 	r8E(clk, rst, flushE, signimmD, signimmE);
	flopenrc 		#(5) 	r9E(clk, rst, flushE, rsD, rsE);
	flopenrc 		#(5) 	r10E(clk, rst, flushE, rtD, rtE);
	flopenrc 		#(5) 	r11E(clk, rst, flushE, rdD, rdE);
	flopenrc 		#(5) 	r12E(clk, rst, flushE, shamtD, shamtE);
	flopenrc		#(32)	r13E(clk, rst, flushE, hiloresultaD, hiloresultaE);
	flopenrc 		#(5) 	r14E(clk, rst, flushE, opD, opE);
=======

	// (2) 寄存器堆
	mux2		#(32)	hilomux(resultW, hiloresultbE, hilotoregE, resultWE);
	regfile 			rf(clk, regwriteW, rsD, rtD, writeregW, resultWE, srcaD, srcbD);

	// (3) HILO 寄存器
	mux2		#(32)	himux(srcaW, multdivresultW[63:32], ismultW | isdivW, hiwritedataW);
	mux2		#(32)	lomux(srcaW, multdivresultW[31:0], ismultW | isdivW, lowritedataW);
	HILO				hi(clk, hiwriteW, hiwritedataW, hiresultD);
	HILO 				lo(clk, lowriteW, lowritedataW, loresultD);
	mux2		#(32)	hiorlomux(hiresultD, loresultD, hiorloD, hiloresultaD);

	// (4) 立即数扩展
	signext 			se(instrD[15:0], immseD, signimmD);

	// (5) PC next
	sl2 				immsh(signimmD, signimmshD);
	adder 				pcadd2(pcplus4D, signimmshD, pcbranchD);
	mux2 		#(32) 	pcbrmux(pcplus4F, pcbranchD, pcsrcD, pcnextbrFD);
	mux2 		#(32) 	pcmux(pcnextbrFD, {pcplus4D[31:28], instrD[25:0], 2'b00}, jumpD, pcnextFD);

	// (6) branch equality 比较
	mux2 		#(32) 	forwardamux(srcaD, aluoutM, forwardaD, srca2D);
	mux2 		#(32) 	forwardbmux(srcbD, aluoutM, forwardbD, srcb2D);
	eqcmp 				comp(srca2D, srcb2D, equalD);

	// 3.EX
	// (1) 流水线寄存器
	flopenrc	#(32)	r1E(clk, rst, ~stallE, flushE, srcaD, srcaE);
	flopenrc 	#(32) 	r2E(clk, rst, ~stallE, flushE, srcbD, srcbE);
	flopenrc 	#(32) 	r3E(clk, rst, ~stallE, flushE, signimmD, signimmE);
	flopenrc 	#(5) 	r4E(clk, rst, ~stallE, flushE, rsD, rsE);
	flopenrc 	#(5) 	r5E(clk, rst, ~stallE, flushE, rtD, rtE);
	flopenrc 	#(5) 	r6E(clk, rst, ~stallE, flushE, rdD, rdE);
	flopenrc 	#(5) 	r7E(clk, rst, ~stallE, flushE, shamtD, shamtE);
	flopenrc	#(32)	r8E(clk, rst, ~stallE, flushE, hiloresultaD, hiloresultaE);
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9

	// (2) ALU
	mux3 		#(32) 	forwardaemux(srcaE, resultW, aluoutM, forwardaE, srca2E);
	mux3		#(32) 	forwardbemux(srcbE, resultW, aluoutM, forwardbE, srcb2E);
	mux2 		#(32) 	srcbmux(srcb2E, signimmE, alusrcE, srcb3E);
	alu 				alu(srca2E, srcb3E, shamtE, alucontrolE, aluoutE);

<<<<<<< HEAD
	// (3) 写寄存器号选择器
	assign writereg_brE = ( ((opE==6'b000001 & rtE==5'b10001)|(opE==6'b000001 & rtE==5'b10000)) & writeregE == 0)? 5'b11111 : writeregE; //选择写寄存器号，没有指定时默认为31
	mux2        #(5)    wrmux2(writereg_brE,5'b11111,branchjumpE,writereg2E);   //选择link类指令的写寄存器
	mux2 		#(5) 	wrmux(rtE, rdE, regdstE, writeregE);
	mux2        #(32)   wrmux3(aluoutW,pcplus8E,branchjumpE,aluout2E); 
	
	// (4) MFHI 写寄存器数据选择器
	mux2		#(32)	forwardhilomux(hiloresultaE, srcaM, forwardhiloE, hiloresultbE);

	// 4.ME
	// (1) 流水线寄存器
	flopr 		#(32) 	r1M(clk, rst, srcb2E, writedataM);
	flopr		#(32) 	r2M(clk, rst, aluoutE, aluoutM);
	flopr 		#(5) 	r3M(clk, rst, writeregE, writeregM);
	flopr		#(32)	r4M(clk, rst, srcaE, srcaM);
	floprc      #(32)   r8M(clk,rst,flushM,pcE,pcM);
	floprc      #(1)    r9M(clk,rst,flushM,branchjumpE,branchjumpM);

	// 5.WB
	// (1) 流水线寄存器
	flopr 		#(32) 	r1W(clk, rst, aluoutM, aluoutW);
	flopr 		#(32) 	r2W(clk, rst, readdataM, readdataW);
	flopr 		#(5) 	r3W(clk, rst, writeregM, writeregW);
	flopr		#(32)	r4W(clk, rst, srcaM, srcaW);
=======
	// (3) 乘除法器
	mult				mult(srca2E, srcb3E, signedmultE, multresultE);
	div					div(clk, rst, signeddivE, srca2E, srcb3E, isdivE & ~divreadyE, 1'b0, divresultE, divreadyE);
	mux2		#(64)	multordivmux(multresultE, divresultE, isdivE, multdivresultE);

	// (3) 写寄存器号选择器
	mux2 		#(5) 	wrmux(rtE, rdE, regdstE, writeregE);

	// (4) MFHI/MFLO 写寄存器数据选择器
	mux4		#(32)	forwardhilomux(hiloresultaE, multdivresultM[63:32], multdivresultM[31:0], srcaM, forwardhiloE, hiloresultbE);

	// 4.ME
	// (1) 流水线寄存器
	flopenrc 	#(32) 	r1M(clk, rst, ~stallM, flushM, srcb2E, writedataM);
	flopenrc	#(32) 	r2M(clk, rst, ~stallM, flushM, aluoutE, aluoutM);
	flopenrc 	#(5) 	r3M(clk, rst, ~stallM, flushM, writeregE, writeregM);
	flopenrc	#(32)	r4M(clk, rst, ~stallM, flushM, srcaE, srcaM);
	flopenrc	#(65)	r5M(clk, rst, ~stallM, flushM, {multdivresultE, divreadyE}, {multdivresultM, divreadyM});

	// 5.WB
	// (1) 流水线寄存器
	flopenrc 	#(32) 	r1W(clk, rst, ~stallW, flushW, aluoutM, aluoutW);
	flopenrc 	#(32) 	r2W(clk, rst, ~stallW, flushW, readdataM, readdataW);
	flopenrc 	#(5) 	r3W(clk, rst, ~stallW, flushW, writeregM, writeregW);
	flopenrc	#(32)	r4W(clk, rst, ~stallW, flushW, srcaM, srcaW);
	flopenrc	#(65)	r5W(clk, rst, ~stallW, flushW, {multdivresultM, divreadyM}, {multdivresultW, divreadyW});
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9

	// (2) 写寄存器数据选择器
	mux2 		#(32) 	resmux(aluoutW, readdataW, memtoregW, resultW);

endmodule

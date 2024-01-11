`timescale 1ns / 1ps
`include "defines.vh"

module datapath(
	input 	wire 		clk, rst,
	input	wire[5:0]	ext_int,
	// IF
	output 	wire[31:0] 	pcF,
	input 	wire[31:0] 	instrF,
	input	wire		i_stallF,
	// ID
	input 	wire 		branchD, jumpD, jumpregD,
	input	wire		hilotoregD, hiorloD,
	input	wire		immseD,
	input	wire		invalidD,
	output	wire[31:0]	instrD,
	output	wire		stallD,
	// EX
	input	wire		regdstE, alusrcE, memtoregE, regwriteE, 
	input	wire		hilotoregE, hiorloE, hiwriteE, lowriteE,
	input 	wire[5:0] 	alucontrolE,
	input	wire		ismultE, signedmultE,
	input	wire		isdivE, signeddivE,
	input	wire		linkregE,
	input	wire		cp0toregE,
	output	wire		divstallE,
	output 	wire 		stallE, flushE,
	// ME
	input 	wire 		memtoregM, regwriteM,
	input	wire		hiwriteM, lowriteM, hilotoregM,
	input	wire		ismultM, isdivM,
	input 	wire[31:0] 	readdataM,
	input	wire		cp0toregM, cp0writeM,
	input	wire		is_overflow_detectM,
	output 	wire[31:0] 	aluoutM, writedata2M,
	output	wire[3:0]	memwriteM,
	output	wire		stallM, flushM,
	input	wire		d_stallM,
	// WB
	input 	wire 		memtoregW, regwriteW,
	input	wire		hiwriteW, lowriteW, hilotoregW,
	input	wire		ismultW, isdivW,
	input	wire		linkdataW,
	input	wire		cp0toregW,
	output	wire[31:0]	pcW,
	output	wire[4:0]	writereg,
	output	wire[31:0]	result,
	output	wire		stallW, flushW,
	// except
	output	wire		exceptflush,
	output	wire		dataram_except
    );
	
	// IF
	wire [31:0]			pcplus4F, pcplus8F;
	wire				is_in_delayslotF;
	wire				instram_exceptF;
	wire 				stallF, flushF;
	// ID
	wire[5:0]			opD, functD;
	wire[4:0]			rsD, rtD, rdD, shamtD;
	wire[31:0] 			pcplus4D, pcplus8D, pcbranchD, pcnextbrFD, pcnextjdFD, pcnextFD;
	wire[31:0] 			srcaD, srca2D, srcbD, srcb2D;
	wire[31:0] 			signimmD, signimmshD;
	wire[31:0]			hiresultD, loresultD, hiloresultaD;
	wire[2:0] 			forward_branchjraD, forward_branchjrbD;
	wire[31:0]			pcD;
	wire				equalD;
	wire				instram_exceptD, break_exceptD, syscall_exceptD, eretD;
	wire				is_in_delayslotD;
	wire 				flushD;
	// EX
	wire[2:0] 			forwardaE, forwardbE;
	wire[4:0] 			rsE, rtE, rdE, shamtE;
	wire[5:0]			opE;
	wire[4:0] 			writeregE, writereg2E;
	wire[31:0] 			srcaE, srca2E, srcbE, srcb2E, srcb3E;
	wire[31:0] 			signimmE;
	wire[31:0] 			aluoutE;
	wire[31:0]			hiloresultaE, hiloresultbE;
	wire[31:0]			src_mthiloE;
	wire[2:0]			forward_mfhiloE;
	wire[1:0]			forward_mthiloE;
	wire[63:0]			multresultE, divresultE;
	wire[63:0]			multdivresultE;
	wire				divreadyE;
	wire[31:0] 			pcplus8E, pcE;
	wire				instram_exceptE, break_exceptE, syscall_exceptE, eretE, invalidE, overflowE;
	wire				is_in_delayslotE;
	wire[31:0]			cp0dataE;
	// ME
	wire[5:0]			opM;
	wire[4:0] 			writereg2M;
	wire[31:0]			writedataM;
	wire[63:0]			multdivresultM;
	wire[31:0] 			pcplus8M, pcM;
	wire[4:0]			rsM, rdM;
	wire[31:0]			hiloresultbM;
	wire[31:0]			src_mthiloM, src_mthilo2M;
	wire				forward_mthiloM;
	wire				instram_exceptM, dataramload_exceptM, dataramstore_exceptM, break_exceptM, syscall_exceptM, eretM, invalidM, overflowM;
	wire				is_in_delayslotM;
	wire[31:0] 			cp0dataM, cp0data2M, cp0countM, cp0compareM, cp0statusM, cp0causeM, cp0epcM, cp0configM, cp0pridM, cp0badvaddrM;
	wire 				timer_interruptM;
	wire[31:0] 			excepttypeM, badramaddrM, pc_exceptM;
	wire				forwardcp0M;
	// WB
	wire[4:0] 			writereg2W, writeregWE;
	wire[5:0]			opW;
	wire[31:0] 			aluoutW, readdataW, resultaW, resultbW, resultW;
	wire[63:0]			multdivresultW;
	wire[31:0]			hiwritedataW, lowritedataW;
	wire[31:0]			src_mthiloW;
	wire[31:0] 			pcplus8W;
	wire[31:0]			lwresultW;
	wire[31:0]			hiloresultbW, resultWE;
	wire[31:0]			cp0data2W, writedataW;

	hazard h(
		// IF
		i_stallF,
		stallF, flushF,
		// ID
		rsD, rtD, rdD,
		branchD, hilotoregD, jumpregD,
		forward_branchjraD, forward_branchjrbD,
		stallD, flushD,
		// EX
		rsE, rtE, rdE,
		writereg2E,
		regwriteE, memtoregE,
		hilotoregE, hiorloE, hiwriteE, lowriteE,
		isdivE, divreadyE,
		cp0toregE,
		forwardaE, forwardbE,
		forward_mfhiloE,
		forward_mthiloE,
		divstallE,
		stallE, flushE,
		// ME
		rsM, rdM,
		writereg2M, 
		regwriteM, memtoregM,
		hiwriteM, lowriteM, hilotoregM,
		ismultM, isdivM,
		cp0toregM, cp0writeM,
		excepttypeM,
		forward_mthiloM,
		forwardcp0M,
		d_stallM,
		stallM, flushM,
		// WB
		writereg2W,
		regwriteW,
		hiwriteW, lowriteW,
		ismultW, isdivW,
		cp0toregW,
		stallW, flushW,
		// except
		exceptflush
	);

	assign opD = instrD[31:26];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign shamtD = instrD[10:6];
	assign functD = instrD[5:0];

	// 例外
	// (1) 取指地址错例外
	assign instram_exceptF = (pcF[1:0] != 2'b00);
	// (2) 访存地址错例外
	assign dataramload_exceptM = ((opM == `op_LW & aluoutM[1:0] != 2'b00) | ((opM == `op_LH | opM == `op_LHU) & aluoutM[0] != 1'b0));
	assign dataramstore_exceptM = ((opM == `op_SW & aluoutM[1:0] != 2'b00) | (opM == `op_SH & aluoutM[0] != 1'b0));
	// (3) BREAK 指令例外
	assign break_exceptD = (opD == `op_RTYPE & functD == `funct_BREAK);
	// (4) SYSCALL 指令例外
	assign syscall_exceptD = (opD == `op_RTYPE & functD == `funct_SYSCALL);
	// (5) ERET 指令
	assign eretD = (instrD == 32'b01000010000000000000000000011000);
	// (6) 保留指令例外: invalidD
	// (7) ALU 溢出例外: overflowE

	assign dataram_except = dataramload_exceptM | dataramstore_exceptM;

	// 1.IF
	// (1) PC 与 PC 自增
	pc 			 		pcreg(clk, rst, ~stallF, flushF, pcnextFD, pc_exceptM, pcF);
	adder 				pcadd1(pcF, 32'b100, pcplus4F);
	adder				pcadd2(pcF, 32'b1000, pcplus8F);

	// (2) 判断当前指令是否为延迟槽指令
	assign is_in_delayslotF = branchD | jumpD | jumpregD;

	// 2.ID
	// (1) 流水线寄存器
	flopenrc 	#(32) 	r1D(clk, rst, ~stallD, flushD, pcplus4F, pcplus4D);
	flopenrc 	#(32) 	r2D(clk, rst, ~stallD, flushD, instrF, instrD);
	flopenrc 	#(32) 	r3D(clk, rst, ~stallD, flushD, pcplus8F, pcplus8D);
	flopenrc	#(32)	r4D(clk, rst, ~stallD, flushD, pcF, pcD);
	flopenrc	#(2)	r5D(clk, rst, ~stallD, flushD, 
							{instram_exceptF, is_in_delayslotF}, 
							{instram_exceptD, is_in_delayslotD});

	// (2) 寄存器堆
	mux2		#(5)	hiloregmux(writereg2W, writereg2E, hilotoregE, writeregWE);  // 写寄存器号
	mux2		#(32)	hilodatamux(resultW, hiloresultbE, hilotoregE, resultWE);    // 写寄存器数据
	regfile 			rf(clk, rst, regwriteW | hilotoregE | cp0toregW, rsD, rtD, writeregWE, resultWE, srcaD, srcbD);

	// (3) HILO 寄存器
	mux2		#(32)	himux(src_mthiloW, multdivresultW[63:32], ismultW | isdivW, hiwritedataW);
	mux2		#(32)	lomux(src_mthiloW, multdivresultW[31:0], ismultW | isdivW, lowritedataW);
	HILO				hi(clk, rst, hiwriteW, hiwritedataW, hiresultD);
	HILO 				lo(clk, rst, lowriteW, lowritedataW, loresultD);
	mux2		#(32)	hiorlomux(hiresultD, loresultD, hiorloD, hiloresultaD);

	// (4) 立即数扩展
	signext 			se(instrD[15:0], immseD, signimmD);

	// (5) PC next
	sl2 				immsh(signimmD, signimmshD);
	adder 				pcadd3(pcplus4D, signimmshD, pcbranchD);
	mux2 		#(32) 	pcbrmux(pcplus4F, pcbranchD, branchD & equalD, pcnextbrFD);
	mux2 		#(32) 	pcjdmux(pcnextbrFD, {pcplus4D[31:28], instrD[25:0], 2'b00}, jumpD, pcnextjdFD);
	mux2		#(32)	pcjrmux(pcnextjdFD, srca2D, jumpregD, pcnextFD);

	// (6) branch 比较
	mux5 		#(32) 	forward_branchjramux(srcaD, aluoutM, hiloresultbE, hiloresultbM, cp0data2M, forward_branchjraD, srca2D);
	mux5 		#(32) 	forward_branchjrbmux(srcbD, aluoutM, hiloresultbE, hiloresultbM, cp0data2M, forward_branchjrbD, srcb2D);
	eqcmp 				comp(srca2D, srcb2D, opD, rtD, equalD);

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
	flopenrc	#(32)	r9E(clk, rst, ~stallE, flushE, pcplus8D, pcplus8E);
	flopenrc	#(32)	r10E(clk, rst, ~stallE, flushE, pcD, pcE);
	flopenrc	#(6)	r11E(clk, rst, ~stallE, flushE, 
							 {instram_exceptD, break_exceptD, syscall_exceptD, eretD, invalidD, is_in_delayslotD}, 
							 {instram_exceptE, break_exceptE, syscall_exceptE, eretE, invalidE, is_in_delayslotE});
	flopenrc	#(6)	r12E(clk, rst, ~stallE, flushE, opD, opE);

	// (2) ALU
	mux5 		#(32) 	forwardaemux(srcaE, aluoutM, resultW, cp0data2M, cp0data2W, forwardaE, srca2E);
	mux5		#(32) 	forwardbemux(srcbE, aluoutM, resultW, cp0data2M, cp0data2W, forwardbE, srcb2E);
	mux2 		#(32) 	srcbmux(srcb2E, signimmE, alusrcE, srcb3E);
	alu 				alu(srca2E, srcb3E, shamtE, alucontrolE, aluoutE, overflowE);

	// (3) 乘除法器
	mult				mult(srca2E, srcb3E, signedmultE, multresultE);
	div					div(clk, rst, signeddivE, srca2E, srcb3E, isdivE & ~divreadyE, 1'b0, divresultE, divreadyE);
	mux2		#(64)	multordivmux(multresultE, divresultE, isdivE, multdivresultE);

	// (4) 写寄存器号选择器
	mux2 		#(5) 	wr1mux(rtE, rdE, regdstE, writeregE);
	mux2		#(5)	wr2mux(writeregE, 5'b11111, linkregE, writereg2E);

	// (5) MFHI/MFLO 数据前推
	mux7		#(32)	forward_mfhilomux(hiloresultaE, multdivresultM[63:32], multdivresultM[31:0], multdivresultW[63:32], multdivresultW[31:0], 
									   src_mthiloM, src_mthiloW, forward_mfhiloE, hiloresultbE);

	// (6) MTHI/MTLO 数据前推
	mux3		#(32)	forward_mthiloEmux(srcaE, aluoutM, resultW, forward_mthiloE, src_mthiloE);

	// 4.ME
	// (1) 流水线寄存器
	flopenrc 	#(32) 	r1M(clk, rst, ~stallM, flushM, srcb2E, writedataM);
	flopenrc	#(32) 	r2M(clk, rst, ~stallM, flushM, aluoutE, aluoutM);
	flopenrc 	#(5) 	r3M(clk, rst, ~stallM, flushM, writereg2E, writereg2M);
	flopenrc	#(32)	r4M(clk, rst, ~stallM, flushM, src_mthiloE, src_mthiloM);
	flopenrc	#(64)	r5M(clk, rst, ~stallM, flushM, multdivresultE, multdivresultM);
	flopenrc	#(32)	r6M(clk, rst, ~stallM, flushM, pcplus8E, pcplus8M);
	flopenrc	#(32)	r7M(clk, rst, ~stallM, flushM, pcE, pcM);
	flopenrc	#(10)	r8M(clk, rst, ~stallM, flushM, {rsE, rdE}, {rsM, rdM});
	flopenrc	#(7)	r9M(clk, rst, ~stallM, flushM, 
							{instram_exceptE, break_exceptE, syscall_exceptE, eretE, invalidE, overflowE, is_in_delayslotE}, 
							{instram_exceptM, break_exceptM, syscall_exceptM, eretM, invalidM, overflowM, is_in_delayslotM});
	flopenrc	#(6)	r10M(clk, rst, ~stallM, flushM, opE, opM);
	flopenrc	#(32)	r11M(clk, rst, ~stallM, flushM, cp0dataE, cp0dataM);
	flopenrc	#(32)	r12M(clk, rst, ~stallM, flushM, hiloresultbE, hiloresultbM);

	// (2) store 指令写使能信号与写数据
	sw_sel              swsel(aluoutM, opM, excepttypeM, memwriteM);
	
	assign writedata2M = (opM == `op_SB) ? {{writedataM[7:0]}, {writedataM[7:0]}, {writedataM[7:0]}, {writedataM[7:0]}} : 
						 (opM == `op_SH) ? {{writedataM[15:0]}, {writedataM[15:0]}} :  
						 writedataM;

	// (3) MTHI/MTLO 数据前推
	mux2		#(32)	forward_mthiloMmux(src_mthiloM, resultW, forward_mthiloM, src_mthilo2M);

	// (4) 异常处理与 CP0 协寄存器
	exception 			except(rst, instram_exceptM, dataramload_exceptM, dataramstore_exceptM, break_exceptM, syscall_exceptM, 
							   eretM, invalidM, overflowM & is_overflow_detectM,
							   cp0statusM, cp0causeM, cp0epcM,
							   pcM, aluoutM,
							   excepttypeM, badramaddrM, pc_exceptM);

	cp0_reg 			cp0reg(clk, rst, cp0writeM, rdM, rdE, writedataM, ext_int, excepttypeM, pcM, is_in_delayslotM, badramaddrM,
							   cp0dataE, cp0countM, cp0compareM, cp0statusM, cp0causeM, cp0epcM, cp0configM, cp0pridM, cp0badvaddrM, timer_interruptM);
	
	mux2		#(32)	forwardcp0mux(cp0dataM, writedataW, forwardcp0M, cp0data2M);

	// 5.WB
	// (1) 流水线寄存器
	flopenrc 	#(32) 	r1W(clk, rst, ~stallW, flushW, aluoutM, aluoutW);
	flopenrc 	#(32) 	r2W(clk, rst, ~stallW, flushW, readdataM, readdataW);
	flopenrc 	#(5) 	r3W(clk, rst, ~stallW, flushW, writereg2M, writereg2W);
	flopenrc	#(32)	r4W(clk, rst, ~stallW, flushW, src_mthilo2M, src_mthiloW);
	flopenrc	#(64)	r5W(clk, rst, ~stallW, flushW, multdivresultM, multdivresultW);
	flopenrc	#(32)	r6W(clk, rst, ~stallW, flushW, pcplus8M, pcplus8W);
	flopenrc	#(32)	r7W(clk, rst, ~stallW, flushW, cp0data2M, cp0data2W);
	flopenrc	#(32)	r8W(clk, rst, ~stallW, flushW, writedataM, writedataW);
	flopenrc	#(6)	r9W(clk, rst, ~stallW, flushW, opM, opW);
	flopenrc	#(32)	r10W(clk, rst, ~stallW, flushW, pcM, pcW);
	flopenrc	#(32)	r11W(clk, rst, ~stallW, flushW, hiloresultbM, hiloresultbW);

	// (2) 写寄存器数据选择器
	lw_sel				lwsel(aluoutW, readdataW, opW, lwresultW);
	mux2 		#(32) 	res1mux(aluoutW, lwresultW, memtoregW, resultaW);
	mux2		#(32)	res2mux(resultaW, pcplus8W, linkdataW, resultbW);
	mux2		#(32)	res3mux(resultbW, cp0data2W, cp0toregW, resultW);

	// (3) debug
	assign result = hilotoregW ? hiloresultbW : resultWE;
	assign writereg = hilotoregW ? writereg2W : writeregWE;

endmodule

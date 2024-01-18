`timescale 1ns / 1ps
`include "defines.vh"

/*
	模块名称: datapath
	模块功能: 数据通路, MIPS CPU 主逻辑
*/
module datapath(
	input 	wire 		clk, rst,
	input	wire[5:0]	ext_int,
	// IF
	input	wire		i_stallF,
	input 	wire[31:0] 	instrF,
	output 	wire[31:0] 	pcF,
	// ID
	input	wire		immseD,
	input 	wire 		branchD, jumpD, jumpregD,
	input	wire		hilotoregD, hiorloD,
	input	wire		invalidD,
	output	wire[31:0]	instrD,
	output	wire		stallD,
	// EX
	input	wire		regdstE, alusrcE, regwriteE, memtoregE,
	input 	wire[5:0] 	alucontrolE,
	input	wire		linkregE,
	input	wire		ismultE, signedmultE, isdivE, signeddivE,
	input	wire		hilotoregE, hiorloE, hiwriteE, lowriteE,
	input	wire		cp0toregE,
	output 	wire 		stallE, flushE,
	// ME
	input	wire		d_stallM,
	input 	wire[31:0] 	readdataM,
	input 	wire 		regwriteM, memtoregM,
	input	wire		ismultM, isdivM,
	input	wire		hilotoregM, hiwriteM, lowriteM,
	input	wire		cp0toregM, cp0writeM,
	input	wire		is_overflow_detectM,
	output 	wire[31:0] 	aluoutM, writedata2M,
	output	wire[3:0]	memwriteM,
	output	wire		stallM, flushM,
	// WB
	input 	wire 		regwriteW, memtoregW,
	input	wire		linkdataW,
	input	wire		ismultW, isdivW,
	input	wire		hilotoregW, hiwriteW, lowriteW,
	input	wire		cp0toregW,
	output	wire		stallW, flushW,
	// debug
	output	wire[31:0]	pcW,
	output	wire[4:0]	writereg,
	output	wire[31:0]	result,
	// except
	output	wire		exceptflush,
	output	wire		dataram_except
    );
	
	// IF
	wire [31:0]			pcplus4F, pcplus8F;
	wire				instram_exceptF;
	wire				is_in_delayslotF;
	wire 				stallF, flushF;
	// ID
	wire[5:0]			opD, functD;
	wire[4:0]			rsD, rtD, rdD, shamtD;
	wire[31:0] 			pcD, pcplus4D, pcplus8D, pcbranchD, pcnextbrFD, pcnextjdFD, pcnextFD;
	wire[31:0] 			signimmD;
	wire				equalD;
	wire[2:0] 			forward_branchjraD, forward_branchjrbD;
	wire[31:0] 			srcaD, srca2D, srcbD, srcb2D;
	wire[31:0]			hiresultD, loresultD, hiloresultaD;
	wire				instram_exceptD, break_exceptD, syscall_exceptD, eretD;
	wire				is_in_delayslotD;
	wire 				flushD;
	// EX
	wire[5:0]			opE;
	wire[4:0] 			rsE, rtE, rdE, shamtE;
	wire[31:0] 			pcE, pcplus8E;
	wire[4:0] 			writeregE, writereg2E;
	wire[2:0] 			forwardaE, forwardbE;
	wire[31:0] 			srcaE, srca2E, srcbE, srcb2E, srcb3E;
	wire[31:0] 			aluoutE, signimmE;
	wire[63:0]			multresultE, divresultE, multdivresultE;
	wire				divreadyE;
	wire[2:0]			forward_mfhiloE;
	wire[31:0]			hiloresultaE, hiloresultbE;
	wire[1:0]			forward_mthiloE;
	wire[31:0]			src_mthiloE;
	wire[31:0]			cp0dataE;
	wire				instram_exceptE, break_exceptE, syscall_exceptE, eretE, invalidE, overflowE;
	wire				is_in_delayslotE;
	// ME
	wire[5:0]			opM;
	wire[4:0]			rsM, rdM;
	wire[31:0] 			pcM, pcplus8M;
	wire[4:0] 			writereg2M;
	wire[31:0]			writedataM;
	wire[63:0]			multdivresultM;
	wire[31:0]			hiloresultbM;
	wire				forward_mthiloM;
	wire[31:0]			src_mthiloM, src_mthilo2M;
	wire				forwardcp0M;
	wire[31:0] 			cp0dataM, cp0data2M, cp0countM, cp0compareM, cp0statusM, cp0causeM, cp0epcM, cp0configM, cp0pridM, cp0badvaddrM;
	wire[31:0] 			excepttypeM, badramaddrM, pc_exceptM;
	wire				instram_exceptM, dataramload_exceptM, dataramstore_exceptM, break_exceptM, syscall_exceptM, eretM, invalidM, overflowM;
	wire				is_in_delayslotM;
	wire 				timer_interruptM;
	// WB
	wire[5:0]			opW;
	wire[31:0] 			pcplus8W;
	wire[4:0] 			writereg2W, writeregWE;
	wire[31:0] 			aluoutW, readdataW, lwresultW, resultaW, resultbW, resultW, hiloresultbW, resultWE;
	wire[63:0]			multdivresultW;
	wire[31:0]			src_mthiloW, hiwritedataW, lowritedataW;
	wire[31:0]			cp0data2W, writedataW;

	hazard h(
		// IF
		i_stallF,
		stallF, flushF,
		// ID
		rsD, rtD, rdD,
		branchD, jumpregD,
		hilotoregD,
		forward_branchjraD, forward_branchjrbD,
		stallD, flushD,
		// EX
		rsE, rtE, rdE,
		writereg2E,
		regwriteE, memtoregE,
		isdivE, divreadyE,
		hilotoregE, hiorloE, hiwriteE, lowriteE,
		cp0toregE,
		forwardaE, forwardbE,
		forward_mfhiloE,
		forward_mthiloE,
		stallE, flushE,
		// ME
		d_stallM,
		rsM, rdM,
		writereg2M, 
		regwriteM, memtoregM,
		ismultM, isdivM,
		hilotoregM, hiwriteM, lowriteM,
		cp0toregM, cp0writeM,
		excepttypeM,
		forward_mthiloM,
		forwardcp0M,
		stallM, flushM,
		// WB
		writereg2W,
		regwriteW,
		ismultW, isdivW,
		hiwriteW, lowriteW,
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
	assign dataram_except = dataramload_exceptM | dataramstore_exceptM;
	// (3) BREAK 指令例外
	assign break_exceptD = (opD == `op_RTYPE & functD == `funct_BREAK);
	// (4) SYSCALL 指令例外
	assign syscall_exceptD = (opD == `op_RTYPE & functD == `funct_SYSCALL);
	// (5) ERET 指令
	assign eretD = (instrD == 32'b01000010000000000000000000011000);
	// (6) 保留指令例外: invalidD
	// (7) ALU 溢出例外: overflowE

	// 判断当前指令是否为延迟槽指令
	assign is_in_delayslotF = branchD | jumpD | jumpregD;


	// 1.IF
	// (1) PC 寄存器与 PC 自增
	pc pcreg(
		.clk(clk), .rst(rst), .en(~stallF), .clear(flushF),
		.pcnext(pcnextFD), .pc_except(pc_exceptM), 
		.q(pcF)
	);
	adder pcadd1(
		.a(pcF), .b(32'b100), .y(pcplus4F)
	);
	adder pcadd2(
		.a(pcF), .b(32'b1000), .y(pcplus8F)
	);
	

	// 2.ID
	// (1) 流水线寄存器
	flopenrc #(96) r1D(
		.clk(clk), .rst(rst), .en(~stallD), .clear(flushD),
		.din({pcF, pcplus4F, pcplus8F}),
		.dout({pcD, pcplus4D, pcplus8D})
	);
	flopenrc #(34) r2D(
		.clk(clk), .rst(rst), .en(~stallD), .clear(flushD),
		.din({instrF, instram_exceptF, is_in_delayslotF}),
		.dout({instrD, instram_exceptD, is_in_delayslotD})
	);

	// (2) 通用寄存器堆
	mux2 #(5) hiloregmux(  // 写寄存器号
		.d0(writereg2W), .d1(writereg2E), .s(hilotoregE), .y(writeregWE)
	);  
	mux2 #(32) hilodatamux(  // 写寄存器数据
		.d0(resultW), .d1(hiloresultbE), .s(hilotoregE), .y(resultWE)
	);
	regfile rf(
		.clk(clk), .rst(rst), 
		.we3(regwriteW | hilotoregE | cp0toregW), 
		.ra1(rsD), .ra2(rtD), .wa3(writeregWE), .wd3(resultWE), 
		.rd1(srcaD), .rd2(srcbD)
	);

	// (3) HILO 寄存器
	mux2 #(32) himux(
		.d0(src_mthiloW), .d1(multdivresultW[63:32]), .s(ismultW | isdivW), .y(hiwritedataW)
	);
	mux2 #(32) lomux(
		.d0(src_mthiloW), .d1(multdivresultW[31:0]), .s(ismultW | isdivW), .y(lowritedataW)
	);
	HILO hi(
		.clk(clk), .rst(rst), 
		.we(hiwriteW), .wd(hiwritedataW), 
		.rd(hiresultD)
	);
	HILO lo(
		.clk(clk), .rst(rst), 
		.we(lowriteW), .wd(lowritedataW), 
		.rd(loresultD)
	);
	mux2 #(32) hiorlomux(
		.d0(hiresultD), .d1(loresultD), .s(hiorloD), .y(hiloresultaD)
	);

	// (4) 立即数扩展
	signext se(
		.a(instrD[15:0]), .sign(immseD), .y(signimmD)
	);

	// (5) PC next
	adder pcadd3(
		.a(pcplus4D), .b({signimmD[29:0], 2'b00}), .y(pcbranchD)
	);
	mux2 #(32) pcbrmux(
		.d0(pcplus4F), .d1(pcbranchD), .s(branchD & equalD), .y(pcnextbrFD)
	);
	mux2 #(32) pcjdmux(
		.d0(pcnextbrFD), .d1({pcplus4D[31:28], instrD[25:0], 2'b00}), .s(jumpD), .y(pcnextjdFD)
	);
	mux2 #(32) pcjrmux(
		.d0(pcnextjdFD), .d1(srca2D), .s(jumpregD), .y(pcnextFD)
	);

	// (6) 分支跳转条件判断
	mux5 #(32) forward_branchjramux(
		.d0(srcaD), .d1(aluoutM), .d2(hiloresultbE), .d3(hiloresultbM), .d4(cp0data2M), 
		.s(forward_branchjraD), .y(srca2D)
	);
	mux5 #(32) forward_branchjrbmux(
		.d0(srcbD), .d1(aluoutM), .d2(hiloresultbE), .d3(hiloresultbM), .d4(cp0data2M), 
		.s(forward_branchjrbD), .y(srcb2D)
	);
	eqcmp comp(
		.a(srca2D), .b(srcb2D), .op(opD), .rt(rtD), .y(equalD)
	);


	// 3.EX
	// (1) 流水线寄存器
	flopenrc #(32) r1E(
		.clk(clk), .rst(rst), .en(~stallE), .clear(flushE),
		.din({opD, rsD, rtD, rdD, shamtD}),
		.dout({opE, rsE, rtE, rdE, shamtE})
	);
	flopenrc #(64) r2E(
		.clk(clk), .rst(rst), .en(~stallE), .clear(flushE),
		.din({pcD, pcplus8D}),
		.dout({pcE, pcplus8E})
	);
	flopenrc #(128) r3E(
		.clk(clk), .rst(rst), .en(~stallE), .clear(flushE),
		.din({srcaD, srcbD, signimmD, hiloresultaD}),
		.dout({srcaE, srcbE, signimmE, hiloresultaE})
	);
	flopenrc #(32) r4E(
		.clk(clk), .rst(rst), .en(~stallE), .clear(flushE),
		.din({instram_exceptD, break_exceptD, syscall_exceptD, eretD, invalidD, is_in_delayslotD}),
		.dout({instram_exceptE, break_exceptE, syscall_exceptE, eretE, invalidE, is_in_delayslotE})
	);

	// (2) ALU
	mux5 #(32) forwardaemux(
		.d0(srcaE), .d1(aluoutM), .d2(resultW), .d3(cp0data2M), .d4(cp0data2W), 
		.s(forwardaE), .y(srca2E)
	);
	mux5 #(32) forwardbemux(
		.d0(srcbE), .d1(aluoutM), .d2(resultW), .d3(cp0data2M), .d4(cp0data2W), 
		.s(forwardbE), .y(srcb2E)
	);
	mux2 #(32) srcbmux(
		.d0(srcb2E), .d1(signimmE), .s(alusrcE), .y(srcb3E)
	);
	alu alu(
		.a(srca2E), .b(srcb3E), .shamt(shamtE), .op(alucontrolE), 
		.y(aluoutE), .overflow(overflowE)
	);

	// (3) 乘除法器
	mult mult(
		.a(srca2E), .b(srcb3E), .sign(signedmultE), .y(multresultE)
	);
	div div(
		.clk(clk), .rst(rst), 
		.signed_div_i(signeddivE), .opdata1_i(srca2E), .opdata2_i(srcb3E), 
		.start_i(isdivE & ~divreadyE), .annul_i(1'b0), 
		.result_o(divresultE), .ready_o(divreadyE)
	);
	mux2 #(64) multordivmux(
		.d0(multresultE), .d1(divresultE), .s(isdivE), .y(multdivresultE)
	);

	// (4) 写寄存器号选择器
	mux2 #(5) wr1mux(
		.d0(rtE), .d1(rdE), .s(regdstE), .y(writeregE)
	);
	mux2 #(5) wr2mux(
		.d0(writeregE), .d1(5'b11111), .s(linkregE), .y(writereg2E)
	);

	// (5) MFHI/MFLO 数据前推
	mux7 #(32) forward_mfhilomux(
		.d0(hiloresultaE), .d1(multdivresultM[63:32]), .d2(multdivresultM[31:0]), 
		.d3(multdivresultW[63:32]), .d4(multdivresultW[31:0]), 
		.d5(src_mthiloM), .d6(src_mthiloW), 
		.s(forward_mfhiloE), .y(hiloresultbE)
	);

	// (6) MTHI/MTLO 数据前推
	mux3 #(32) forward_mthiloEmux(
		.d0(srcaE), .d1(aluoutM), .d2(resultW), 
		.s(forward_mthiloE), .y(src_mthiloE)
	);


	// 4.ME
	// (1) 流水线寄存器
	flopenrc #(32) r1M(
		.clk(clk), .rst(rst), .en(~stallM), .clear(flushM),
		.din({opE, rsE, rdE, writereg2E}),
		.dout({opM, rsM, rdM, writereg2M})
	);
	flopenrc #(64) r2M(
		.clk(clk), .rst(rst), .en(~stallM), .clear(flushM),
		.din({pcE, pcplus8E}),
		.dout({pcM, pcplus8M})
	);
	flopenrc #(64) r3M(
		.clk(clk), .rst(rst), .en(~stallM), .clear(flushM),
		.din({srcb2E, aluoutE}),
		.dout({writedataM, aluoutM})
	);
	flopenrc #(160) r4M(
		.clk(clk), .rst(rst), .en(~stallM), .clear(flushM),
		.din({multdivresultE, hiloresultbE, src_mthiloE, cp0dataE}),
		.dout({multdivresultM, hiloresultbM, src_mthiloM, cp0dataM})
	);
	flopenrc #(32) r5M(
		.clk(clk), .rst(rst), .en(~stallM), .clear(flushM),
		.din({instram_exceptE, break_exceptE, syscall_exceptE, eretE, invalidE, overflowE, is_in_delayslotE}),
		.dout({instram_exceptM, break_exceptM, syscall_exceptM, eretM, invalidM, overflowM, is_in_delayslotM})
	);

	// (2) Store 指令写使能信号与写数据
	sw_sel swsel(
		.aluoutM(aluoutM), .opM(opM), .excepttypeM(excepttypeM), .memwriteM(memwriteM)
	);
	
	assign writedata2M = (
		(opM == `op_SB) ? {{writedataM[7:0]}, {writedataM[7:0]}, {writedataM[7:0]}, {writedataM[7:0]}} : 
		(opM == `op_SH) ? {{writedataM[15:0]}, {writedataM[15:0]}} :  
		writedataM
	);

	// (3) MTHI/MTLO 数据前推
	mux2 #(32) forward_mthiloMmux(
		.d0(src_mthiloM), .d1(resultW), .s(forward_mthiloM), .y(src_mthilo2M)
	);

	// (4) 异常处理与 CP0 协寄存器
	exception except(
		.rst(rst), 
		.instram_except(instram_exceptM), .dataramload_except(dataramload_exceptM), .dataramstore_except(dataramstore_exceptM), 
		.break_except(break_exceptM), .syscall_except(syscall_exceptM), 
		.eret(eretM), .invalid(invalidM), .overflow(overflowM & is_overflow_detectM),
		.cp0status(cp0statusM), .cp0cause(cp0causeM), .cp0epc(cp0epcM),
		.pc(pcM), .aluout(aluoutM),
		.excepttype(excepttypeM), .badramaddr(badramaddrM), .pc_except(pc_exceptM)
	);
	cp0_reg cp0reg(
		.clk(clk), .rst(rst), 
		.we_i(cp0writeM), .waddr_i(rdM), .raddr_i(rdE), .data_i(writedataM), 
		.int_i(ext_int), .excepttype_i(excepttypeM), 
		.current_inst_addr_i(pcM), .is_in_delayslot_i(is_in_delayslotM), .bad_addr_i(badramaddrM),
		.data_o(cp0dataE), .count_o(cp0countM), .compare_o(cp0compareM), 
		.status_o(cp0statusM), .cause_o(cp0causeM), .epc_o(cp0epcM), .config_o(cp0configM), .prid_o(cp0pridM), 
		.badvaddr(cp0badvaddrM), .timer_int_o(timer_interruptM)
	);
	mux2 #(32) forwardcp0mux(
		.d0(cp0dataM), .d1(writedataW), .s(forwardcp0M), .y(cp0data2M)
	);


	// 5.WB
	// (1) 流水线寄存器
	flopenrc #(32) r1W(
		.clk(clk), .rst(rst), .en(~stallW), .clear(flushW), 
		.din({opM, writereg2M}),
		.dout({opW, writereg2W})
	);
	flopenrc #(64) r2W(
		.clk(clk), .rst(rst), .en(~stallW), .clear(flushW), 
		.din({pcM, pcplus8M}),
		.dout({pcW, pcplus8W})
	);
	flopenrc #(96) r3W(
		.clk(clk), .rst(rst), .en(~stallW), .clear(flushW), 
		.din({aluoutM, writedataM, readdataM}),
		.dout({aluoutW, writedataW, readdataW})
	);
	flopenrc #(160) r4W(
		.clk(clk), .rst(rst), .en(~stallW), .clear(flushW), 
		.din({multdivresultM, hiloresultbM, src_mthilo2M, cp0data2M}),
		.dout({multdivresultW, hiloresultbW, src_mthiloW, cp0data2W})
	);

	// (2) 写寄存器数据选择器
	lw_sel lwsel(
		.aluoutW(aluoutW), .readdataW(readdataW), .opW(opW), .lwresultW(lwresultW)
	);
	mux2 #(32) res1mux(
		.d0(aluoutW), .d1(lwresultW), .s(memtoregW), .y(resultaW)
	);
	mux2 #(32) res2mux(
		.d0(resultaW), .d1(pcplus8W), .s(linkdataW), .y(resultbW)
	);
	mux2 #(32) res3mux(
		.d0(resultbW), .d1(cp0data2W), .s(cp0toregW), .y(resultW)
	);

	// (3) debug
	assign result = hilotoregW ? hiloresultbW : resultWE;
	assign writereg = hilotoregW ? writereg2W : writeregWE;

endmodule
`timescale 1ns / 1ps

/*
	模块名称: controller
	模块功能: 控制单元, 在 ID 阶段根据指令产生相应的控制信号, 并在需要时传给数据通路
*/
module controller(
	input 	wire 		clk, rst,
	// 1.IF
	// 2.ID
	input 	wire[31:0]	instrD,
	input	wire		stallD,
	output	wire		immseD,
	output 	wire 		branchD, jumpD, jumpregD,
	output	wire		hilotoregD, hiorloD,
	output	wire		invalidD,
	// 3.EX
	input 	wire 		stallE, flushE,
	output	wire		regdstE, alusrcE, regwriteE, memtoregE,
	output	wire		linkregE,
	output	wire		ismultE, signedmultE, isdivE, signeddivE,
	output	wire		hilotoregE, hiorloE, hiwriteE, lowriteE,
	output	wire		cp0toregE,
	output 	wire[4:0] 	alucontrolE,
	// 4.ME
	input	wire		stallM, flushM,
	output	wire		regwriteM, memtoregM, memweM,
	output	wire		ismultM, isdivM,
	output	wire		hiwriteM, lowriteM, hilotoregM,
	output	wire		cp0toregM, cp0writeM,
	output	wire		is_overflow_detectM,
	// 5.WB
	input	wire		stallW, flushW,
	output 	wire 		regwriteW, memtoregW,
	output	wire		linkdataW,
	output	wire		ismultW, isdivW,
	output	wire		hiwriteW, lowriteW, hilotoregW,
	output	wire		cp0toregW
    );
	
	// 1.IF
	// 2.ID
	wire[5:0]			functD;
	wire[3:0] 			aluopD;
	wire[4:0] 			alucontrolD;
	wire				regdstD, alusrcD, regwriteD, memtoregD, memweD;
	wire				linkregD, linkdataD;
	wire				ismultD, signedmultD, isdivD, signeddivD;
	wire				hiwriteD, lowriteD;
	wire				cp0toregD, cp0writeD;
	wire				is_overflow_detectD;
	// 3.EX
	wire				memweE;
	wire				linkdataE;
	wire				cp0writeE;
	wire				is_overflow_detectE;
	// 4.ME
	wire				linkdataM;
	// 5.WB

	assign functD = instrD[5:0];

	// 主译码器
	maindec md(
		.instr(instrD), .stallD(stallD),
		.regdst(regdstD), .alusrc(alusrcD), .regwrite(regwriteD), .memtoreg(memtoregD), .memwe(memweD),
		.immse(immseD),
		.branch(branchD), .jump(jumpD), .jumpreg(jumpregD), 
		.linkreg(linkregD), .linkdata(linkdataD),
		.ismult(ismultD), .signedmult(signedmultD), .isdiv(isdivD), .signeddiv(signeddivD),
		.hilotoreg(hilotoregD), .hiorlo(hiorloD), .hiwrite(hiwriteD), .lowrite(lowriteD),
		.cp0toreg(cp0toregD), .cp0write(cp0writeD),
		.is_overflow_detect(is_overflow_detectD), .invalid(invalidD), .aluop(aluopD)
	);

	// ALU 译码器
	aludec ad(
		.funct(functD), .aluop(aluopD), .alucontrol(alucontrolD)
	);

	// 流水线寄存器
	flopenrc #(32) regE(
		.clk(clk), .rst(rst), .en(~stallE), .clear(flushE),
		.din(
			{regdstD, alusrcD, regwriteD, memtoregD, memweD, linkregD, linkdataD, alucontrolD,
			ismultD, signedmultD, isdivD, signeddivD, hilotoregD, hiorloD, hiwriteD, lowriteD,
			cp0toregD, cp0writeD, is_overflow_detectD}
		),
		.dout(
			{regdstE, alusrcE, regwriteE, memtoregE, memweE, linkregE, linkdataE, alucontrolE,
			ismultE, signedmultE, isdivE, signeddivE, hilotoregE, hiorloE, hiwriteE, lowriteE,
			cp0toregE, cp0writeE, is_overflow_detectE}
		)
	);
	flopenrc #(32) regM(
		.clk(clk), .rst(rst), .en(~stallM), .clear(flushM),
		.din(
			{regwriteE, memtoregE, memweE, linkdataE,
			ismultE, isdivE, hilotoregE, hiwriteE, lowriteE,
			cp0toregE, cp0writeE, is_overflow_detectE}
		),
		.dout(
			{regwriteM, memtoregM, memweM, linkdataM,
			ismultM, isdivM, hilotoregM, hiwriteM, lowriteM,
			cp0toregM, cp0writeM, is_overflow_detectM}
		)
	);
	flopenrc #(32) regW(
		.clk(clk), .rst(rst), .en(~stallW), .clear(flushW),
		.din(
			{regwriteM, memtoregM, linkdataM, ismultM, isdivM,
			hilotoregM, hiwriteM, lowriteM, cp0toregM}
		),
		.dout(
			{regwriteW, memtoregW, linkdataW, ismultW, isdivW, 
			hilotoregW, hiwriteW, lowriteW, cp0toregW}
		)
	);

endmodule
`timescale 1ns / 1ps

module controller(
	input 	wire 		clk, rst,
	// 1.IF
	// 2.ID
	input 	wire[5:0] 	opD, functD, rtD,
	output 	wire 		pcsrcD, branchD, equalD, jumpD, jumpregD,memenD,
	output	wire		hilotoregD, hiorloD,
	output	wire		immseD,
	// 3.EX
	input 	wire 		stallE, flushE,
	output 	wire 		memtoregE, alusrcE,
	output 	wire 		regdstE, regwriteE,	memenE,
	output 	wire[5:0] 	alucontrolE,
	output	wire		hilotoregE, hiorloE,
	output	wire		ismultE, signedmultE,
	output	wire		isdivE, signeddivE,
	output	wire		linkregE,
	// 4.ME
	input	wire		stallM, flushM,
	output 	wire 		memtoregM, regwriteM,memenM,
	output	wire		hiwriteM, lowriteM,
	output	wire		ismultM, isdivM,
	// 5.WB
	input	wire		stallW, flushW,
	output 	wire 		memtoregW, regwriteW, 
	output	wire		hiwriteW, lowriteW,
	output	wire		ismultW, isdivW,
	output	wire		linkdataW
    );
	
	// 1.IF
	// 2.ID
	wire[3:0] 			aluopD;
	wire 				memtoregD, alusrcD, regdstD, regwriteD;
	wire				hiwriteD, lowriteD;
	wire[5:0] 			alucontrolD;
	wire				ismultD, signedmultD;
	wire				isdivD, signeddivD;
	wire				linkregD, linkdataD;
	// 3.EX
	wire				hiwriteE, lowriteE;
	wire				linkdataE;
	// 4.ME
	wire				linkdataM;
	// 5.WB

	// main decoder 和 ALU decoder
	maindec md(
		opD, functD, rtD,
		regdstD, alusrcD, memtoregD, branchD, jumpD, jumpregD,
		memenD, regwriteD,
		hilotoregD, hiorloD, hiwriteD, lowriteD,
		immseD, linkregD, linkdataD,
		ismultD, signedmultD, isdivD, signeddivD,
		aluopD
	);
	aludec ad(functD, aluopD, alucontrolD);

	assign pcsrcD = branchD & equalD;

	// 流水线寄存器
	// ID/EX
	flopenrc #(11) reg1E(
		clk, rst, ~stallE, flushE,
		{memtoregD, memenD, alusrcD, regdstD, regwriteD, alucontrolD},
		{memtoregE, memenE, alusrcE, regdstE, regwriteE, alucontrolE}
	);
	flopenrc #(4) reg2E(
		clk, rst, ~stallE, flushE,
		{hilotoregD, hiorloD, hiwriteD, lowriteD},
		{hilotoregE, hiorloE, hiwriteE, lowriteE}
	);
	flopenrc #(4) reg3E(
		clk, rst, ~stallE, flushE,
		{ismultD, signedmultD, isdivD, signeddivD},
		{ismultE, signedmultE, isdivE, signeddivE}
	);
	flopenrc #(2) reg4E(
		clk, rst, ~stallE, flushE,
		{linkregD, linkdataD},
		{linkregE, linkdataE}
	);

	// EX/ME
	flopenrc #(3) reg1M(
		clk, rst, ~stallM, flushM,
		{memtoregE, memenE, regwriteE},
		{memtoregM, memenM, regwriteM}
	);
	flopenrc #(2) reg2M(
		clk, rst, ~stallM, flushM,
		{hiwriteE, lowriteE},
		{hiwriteM, lowriteM}
	);
	flopenrc #(2) reg3M(
		clk, rst, ~stallM, flushM,
		{ismultE, isdivE},
		{ismultM, isdivM}
	);
	flopenrc #(1) reg4M(
		clk, rst, ~stallM, flushM,
		{linkdataE},
		{linkdataM}
	);

	// ME/WB
	flopenrc #(2) reg1W(
		clk, rst, ~stallW, flushW,
		{memtoregM, regwriteM},
		{memtoregW, regwriteW}
	);
	flopenrc #(2) reg2W(
		clk, rst, ~stallW, flushW,
		{hiwriteM, lowriteM},
		{hiwriteW, lowriteW}
	);
	flopenrc #(2) reg3W(
		clk, rst, ~stallW, flushW,
		{ismultM, isdivM},
		{ismultW, isdivW}
	);
	flopenrc #(1) reg4W(
		clk, rst, ~stallW, flushW,
		{linkdataM},
		{linkdataW}
	);

endmodule

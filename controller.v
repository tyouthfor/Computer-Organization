`timescale 1ns / 1ps

module controller(
	input 	wire 		clk, rst,
	// 1.IF
	// 2.ID
	input 	wire[31:0]	instrD,
	input	wire		stallD,
	output 	wire 		branchD, jumpD, jumpregD,
	output	wire		hilotoregD, hiorloD,
	output	wire		immseD,
	output	wire		invalidD,
	// 3.EX
	input 	wire 		stallE, flushE,
	output 	wire 		memtoregE, alusrcE,
	output 	wire 		regdstE, regwriteE,
	output 	wire[5:0] 	alucontrolE,
	output	wire		hilotoregE, hiorloE, hiwriteE, lowriteE,
	output	wire		ismultE, signedmultE,
	output	wire		isdivE, signeddivE,
	output	wire		linkregE,
	output	wire		cp0toregE,
	// 4.ME
	input	wire		stallM, flushM,
	output 	wire 		memtoregM, regwriteM,
	output	wire		hiwriteM, lowriteM, hilotoregM,
	output	wire		ismultM, isdivM,
	output	wire		cp0toregM, cp0writeM,
	output	wire		is_overflow_detectM,
	output	wire		memweM,
	// 5.WB
	input	wire		stallW, flushW,
	output 	wire 		memtoregW, regwriteW, 
	output	wire		hiwriteW, lowriteW, hilotoregW,
	output	wire		ismultW, isdivW,
	output	wire		linkdataW,
	output	wire		cp0toregW
    );
	
	// 1.IF
	// 2.ID
	wire[5:0]			functD;
	wire[3:0] 			aluopD;
	wire 				memtoregD, alusrcD, regdstD, regwriteD;
	wire				hiwriteD, lowriteD;
	wire[5:0] 			alucontrolD;
	wire				ismultD, signedmultD;
	wire				isdivD, signeddivD;
	wire				linkregD, linkdataD;
	wire				cp0toregD, cp0writeD;
	wire				is_overflow_detectD;
	wire				memweD;
	// 3.EX
	wire				linkdataE;
	wire				cp0writeE;
	wire				is_overflow_detectE;
	wire				memweE;
	// 4.ME
	wire				linkdataM;
	// 5.WB

	// main decoder 和 ALU decoder
	maindec md(
		instrD,
		stallD,
		regdstD, alusrcD, memtoregD, branchD, jumpD, jumpregD,
		regwriteD,
		hilotoregD, hiorloD, hiwriteD, lowriteD,
		immseD, linkregD, linkdataD,
		ismultD, signedmultD, isdivD, signeddivD,
		invalidD, cp0toregD, cp0writeD,
		is_overflow_detectD,
		memweD,
		aluopD
	);
	aludec ad(functD, aluopD, alucontrolD);

	assign functD = instrD[5:0];
	// assign pcsrcD = branchD & equalD;

	// 流水线寄存器
	// ID/EX
	flopenrc #(10) reg1E(
		clk, rst, ~stallE, flushE,
		{memtoregD, alusrcD, regdstD, regwriteD, alucontrolD},
		{memtoregE, alusrcE, regdstE, regwriteE, alucontrolE}
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
	flopenrc #(2) reg5E(
		clk, rst, ~stallE, flushE,
		{cp0toregD, cp0writeD}, 
		{cp0toregE, cp0writeE}
	);
	flopenrc #(1) reg6E(
		clk, rst, ~stallE, flushE,
		{is_overflow_detectD},
		{is_overflow_detectE}
	);
	flopenrc #(1) reg7E(
		clk, rst, ~stallE, flushE,
		{memweD},
		{memweE}
	);

	// EX/ME
	flopenrc #(2) reg1M(
		clk, rst, ~stallM, flushM,
		{memtoregE, regwriteE},
		{memtoregM, regwriteM}
	);
	flopenrc #(3) reg2M(
		clk, rst, ~stallM, flushM,
		{hiwriteE, lowriteE, hilotoregE},
		{hiwriteM, lowriteM, hilotoregM}
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
	flopenrc #(2) reg5M(
		clk, rst, ~stallM, flushM,
		{cp0toregE, cp0writeE}, 
		{cp0toregM, cp0writeM}
	);
	flopenrc #(1) reg6M(
		clk, rst, ~stallM, flushM,
		{is_overflow_detectE},
		{is_overflow_detectM}
	);
	flopenrc #(1) reg7M(
		clk, rst, ~stallM, flushM,
		{memweE},
		{memweM}
	);

	// ME/WB
	flopenrc #(2) reg1W(
		clk, rst, ~stallW, flushW,
		{memtoregM, regwriteM},
		{memtoregW, regwriteW}
	);
	flopenrc #(3) reg2W(
		clk, rst, ~stallW, flushW,
		{hiwriteM, lowriteM, hilotoregM},
		{hiwriteW, lowriteW, hilotoregW}
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
	flopenrc #(1) reg5W(
		clk, rst, ~stallW, flushW,
		{cp0toregM},
		{cp0toregW}
	);

endmodule

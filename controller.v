`timescale 1ns / 1ps

module controller(
	input 	wire 		clk, rst,
	// 1.IF
	// 2.ID
	input 	wire[5:0] 	opD, functD,
	output 	wire 		pcsrcD, branchD, equalD, jumpD, 
	output	wire		hilotoregD, hiorloD,
<<<<<<< HEAD
	// 3.EX
	input 	wire 		flushE,
=======
	output	wire		immseD,
	// 3.EX
	input 	wire 		stallE, flushE,
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	output 	wire 		memtoregE, alusrcE,
	output 	wire 		regdstE, regwriteE,	
	output 	wire[5:0] 	alucontrolE,
	output	wire		hilotoregE, hiorloE,
<<<<<<< HEAD
	// 4.ME
	output 	wire 		memtoregM, memwriteM, regwriteM,
	output	wire		hiwriteM, lowriteM,
	// 5.WB
	output 	wire 		memtoregW, regwriteW, 
	output	wire		hiwriteW, lowriteW
=======
	output	wire		ismultE, signedmultE,
	output	wire		isdivE, signeddivE,
	// 4.ME
	input	wire		stallM, flushM,
	output 	wire 		memtoregM, memwriteM, regwriteM,
	output	wire		hiwriteM, lowriteM,
	output	wire		ismultM, isdivM,
	// 5.WB
	input	wire		stallW, flushW,
	output 	wire 		memtoregW, regwriteW, 
	output	wire		hiwriteW, lowriteW,
	output	wire		ismultW, isdivW
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
    );
	
	// 1.IF
	// 2.ID
	wire[3:0] 			aluopD;
	wire 				memtoregD, memwriteD, alusrcD, regdstD, regwriteD;
	wire				hiwriteD, lowriteD;
	wire[5:0] 			alucontrolD;
<<<<<<< HEAD
=======
	wire				ismultD, signedmultD;
	wire				isdivD, signeddivD;
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	// 3.EX
	wire 				memwriteE;
	wire				hiwriteE, lowriteE;
	// 4.ME
	// 5.WB

	// main decoder 和 ALU decoder
	maindec md(
		opD, functD,
		regdstD, alusrcD, memtoregD, branchD, jumpD,
		memwriteD, regwriteD,
		hilotoregD, hiorloD, hiwriteD, lowriteD,
<<<<<<< HEAD
=======
		immseD,
		ismultD, signedmultD, isdivD, signeddivD,
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
		aluopD
	);
	aludec ad(functD, aluopD, alucontrolD);

	assign pcsrcD = branchD & equalD;

	// 流水线寄存器
	// ID/EX
<<<<<<< HEAD
	floprc #(11) reg1E(
		clk, rst, flushE,
		{memtoregD, memwriteD, alusrcD, regdstD, regwriteD, alucontrolD},
		{memtoregE, memwriteE, alusrcE, regdstE, regwriteE, alucontrolE}
	);
	floprc #(4) reg2E(
		clk, rst, flushE,
		{hilotoregD, hiorloD, hiwriteD, lowriteD},
		{hilotoregE, hiorloE, hiwriteE, lowriteE}
	);

	// EX/ME
	flopr #(3) reg1M(
		clk, rst,
		{memtoregE, memwriteE, regwriteE},
		{memtoregM, memwriteM, regwriteM}
	);
	flopr #(2) reg2M(
		clk, rst,
		{hiwriteE, lowriteE},
		{hiwriteM, lowriteM}
	);

	// ME/WB
	flopr #(2) reg1W(
		clk, rst,
		{memtoregM, regwriteM},
		{memtoregW, regwriteW}
	);
	flopr #(2) reg2W(
		clk, rst,
		{hiwriteM, lowriteM},
		{hiwriteW, lowriteW}
	);
=======
	flopenrc #(11) reg1E(
		clk, rst, ~stallE, flushE,
		{memtoregD, memwriteD, alusrcD, regdstD, regwriteD, alucontrolD},
		{memtoregE, memwriteE, alusrcE, regdstE, regwriteE, alucontrolE}
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

	// EX/ME
	flopenrc #(3) reg1M(
		clk, rst, ~stallM, flushM,
		{memtoregE, memwriteE, regwriteE},
		{memtoregM, memwriteM, regwriteM}
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
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9

endmodule

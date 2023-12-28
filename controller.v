`timescale 1ns / 1ps

module controller(
	input 	wire 		clk, rst,
	// 1.IF
	// 2.ID
	input 	wire[5:0] 	opD, functD,
	output 	wire 		pcsrcD, branchD, equalD, jumpD, 
	output	wire		hilotoregD, hiorloD,
	// 3.EX
	input 	wire 		flushE,
	output 	wire 		memtoregE, alusrcE,
	output 	wire 		regdstE, regwriteE,	
	output 	wire[5:0] 	alucontrolE,
	output	wire		hilotoregE, hiorloE,
	// 4.ME
	output 	wire 		memtoregM, memwriteM, regwriteM,
	output	wire		hiwriteM, lowriteM,
	// 5.WB
	output 	wire 		memtoregW, regwriteW, 
	output	wire		hiwriteW, lowriteW
    );
	
	// 1.IF
	// 2.ID
	wire[3:0] 			aluopD;
	wire 				memtoregD, memwriteD, alusrcD, regdstD, regwriteD;
	wire				hiwriteD, lowriteD;
	wire[5:0] 			alucontrolD;
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
		aluopD
	);
	aludec ad(functD, aluopD, alucontrolD);

	assign pcsrcD = branchD & equalD;

	// 流水线寄存器
	// ID/EX
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

endmodule

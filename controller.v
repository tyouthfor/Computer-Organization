`timescale 1ns / 1ps

module controller(
	input 	wire 		clk,rst,
	//decode stage
	input 	wire[5:0] 	opD,functD,
	output 	wire 		pcsrcD,branchD,equalD,jumpD,
	
	//execute stage
	input 	wire 		flushE,
	output 	wire 		memtoregE,alusrcE,
	output 	wire 		regdstE,regwriteE,	
	output 	wire[5:0] 	alucontrolE,

	//mem stage
	output 	wire 		memtoregM,memwriteM,regwriteM,
	//write back stage
	output 	wire 		memtoregW,regwriteW

    );
	
	//decode stage
	wire[3:0] 			aluopD;
	wire 				memtoregD,memwriteD,alusrcD,regdstD,regwriteD;
	wire[5:0] 			alucontrolD;

	//execute stage
	wire 				memwriteE;

	// main decoder 和 ALU decoder
	maindec md(
		opD,
		regdstD, alusrcD, memtoregD, branchD, jumpD,
		memwriteD, regwriteD,
		aluopD
	);
	aludec ad(functD, aluopD, alucontrolD);

	assign pcsrcD = branchD & equalD;

	// 流水线寄存器
	floprc #(16) regE(
		clk, rst, flushE,
		{memtoregD, memwriteD, alusrcD, regdstD, regwriteD, alucontrolD},
		{memtoregE, memwriteE, alusrcE, regdstE, regwriteE, alucontrolE}
	);
	flopr #(4) regM(
		clk, rst,
		{memtoregE, memwriteE, regwriteE},
		{memtoregM, memwriteM, regwriteM}
	);
	flopr #(4) regW(
		clk, rst,
		{memtoregM, regwriteM},
		{memtoregW, regwriteW}
	);
endmodule

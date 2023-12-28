`timescale 1ns / 1ps

module mips(
	input 	wire 		clk, rst,
	output 	wire[31:0] 	pcF,
	input 	wire[31:0] 	instrF,
	output 	wire 		memwriteM,
	output 	wire[31:0] 	aluoutM, writedataM,
	input 	wire[31:0] 	readdataM 
    );
	
	wire[5:0] 			opD, functD;
	wire 				regdstE, alusrcE, pcsrcD, memtoregE, memtoregM, memtoregW;
	wire				regwriteE, regwriteM, regwriteW;
	wire				hilotoregD, hiorloD, hilotoregE, hiorloE, hiwriteM, lowriteM, hiwriteW, lowriteW;
	wire[5:0] 			alucontrolE;
	wire 				flushE, equalD;

	controller c(
		clk, rst,
		// ID
		opD, functD,
		pcsrcD, branchD, equalD, jumpD, 
		hilotoregD, hiorloD,
		// EX
		flushE,
		memtoregE, alusrcE,
		regdstE, regwriteE,	
		alucontrolE,
		hilotoregE, hiorloE,
		// ME
		memtoregM, memwriteM, regwriteM,
		hiwriteM, lowriteM,
		// WB
		memtoregW, regwriteW, 
		hiwriteW, lowriteW
	);
	datapath dp(
		clk, rst,
		// IF
		pcF,
		instrF,
		// ID
		pcsrcD, branchD, jumpD,
		hilotoregD, hiorloD,
		equalD,
		opD, functD,
		// EX
		regdstE, alusrcE, memtoregE, regwriteE,
		hilotoregE, hiorloE,
		alucontrolE,
		flushE,
		// ME
		memtoregM, regwriteM,
		hiwriteM, lowriteM,
		readdataM,
		aluoutM, writedataM,
		// WB
		memtoregW, regwriteW,
		hiwriteW, lowriteW
	);
	
endmodule

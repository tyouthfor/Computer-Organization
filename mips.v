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
	wire				immseD;
	wire				ismultE, ismultM, ismultW, isdivE, isdivM, isdivW, signedmultE, signeddivE;
	wire[5:0] 			alucontrolE;
	wire 				equalD;
	wire				stallE, flushE, stallM, flushM, stallW, flushW;

	controller c(
		clk, rst,
		// ID
		opD, functD,
		pcsrcD, branchD, equalD, jumpD, 
		hilotoregD, hiorloD,
		immseD,
		// EX
		stallE, flushE,
		memtoregE, alusrcE,
		regdstE, regwriteE,	
		alucontrolE,
		hilotoregE, hiorloE,
		ismultE, signedmultE,
		isdivE, signeddivE,
		// ME
		stallM, flushM,
		memtoregM, memwriteM, regwriteM,
		hiwriteM, lowriteM,
		ismultM, isdivM,
		// WB
		stallW, flushW,
		memtoregW, regwriteW, 
		hiwriteW, lowriteW,
		ismultW, isdivW
	);
	datapath dp(
		clk, rst,
		// IF
		pcF,
		instrF,
		// ID
		pcsrcD, branchD, jumpD,
		hilotoregD, hiorloD,
		immseD,
		equalD,
		opD, functD,
		// EX
		regdstE, alusrcE, memtoregE, regwriteE,
		hilotoregE, hiorloE,
		alucontrolE,
		ismultE, signedmultE,
		isdivE, signeddivE,
		stallE, flushE,
		// ME
		memtoregM, regwriteM,
		hiwriteM, lowriteM,
		ismultM, isdivM,
		readdataM,
		aluoutM, writedataM,
		stallM, flushM,
		// WB
		memtoregW, regwriteW,
		hiwriteW, lowriteW,
		ismultW, isdivW,
		stallW, flushW
	);
	
endmodule

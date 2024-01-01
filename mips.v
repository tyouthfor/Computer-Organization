`timescale 1ns / 1ps

module mips(
	input 	wire 		clk, rst,
	output 	wire[31:0] 	pcF,
	input 	wire[31:0] 	instrF,
	output 	wire 		memwriteM,
	output 	wire[31:0] 	aluoutM, writedataM,
	input 	wire[31:0] 	readdataM 
    );
	
<<<<<<< HEAD
	//D½×¶Î
	wire[5:0] 			opD;
	wire                pcsrcD;
	wire 				regdstE, alusrcE, memtoregE, memtoregM, memtoregW;
	wire				regwriteE, regwriteM, regwriteW;
	wire				hilotoregD, hiorloD, hilotoregE, hiorloE, hiwriteM, lowriteM, hiwriteW, lowriteW;
	wire[5:0] 			alucontrolE;
	wire 				flushE, equalD;
=======
	wire[5:0] 			opD, functD;
	wire 				regdstE, alusrcE, pcsrcD, memtoregE, memtoregM, memtoregW;
	wire				regwriteE, regwriteM, regwriteW;
	wire				hilotoregD, hiorloD, hilotoregE, hiorloE, hiwriteM, lowriteM, hiwriteW, lowriteW;
	wire				immseD;
	wire				ismultE, ismultM, ismultW, isdivE, isdivM, isdivW, signedmultE, signeddivE;
	wire[5:0] 			alucontrolE;
	wire 				equalD;
	wire				stallE, flushE, stallM, flushM, stallW, flushW;
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9

	controller c(
		clk, rst,
		// ID
		opD, functD,
		pcsrcD, branchD, equalD, jumpD, 
		hilotoregD, hiorloD,
<<<<<<< HEAD
		// EX
		flushE,
=======
		immseD,
		// EX
		stallE, flushE,
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
		memtoregE, alusrcE,
		regdstE, regwriteE,	
		alucontrolE,
		hilotoregE, hiorloE,
<<<<<<< HEAD
		// ME
		memtoregM, memwriteM, regwriteM,
		hiwriteM, lowriteM,
		// WB
		memtoregW, regwriteW, 
		hiwriteW, lowriteW
=======
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
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	);
	datapath dp(
		clk, rst,
		// IF
		pcF,
		instrF,
		// ID
		pcsrcD, branchD, jumpD,
		hilotoregD, hiorloD,
<<<<<<< HEAD
=======
		immseD,
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
		equalD,
		opD, functD,
		// EX
		regdstE, alusrcE, memtoregE, regwriteE,
		hilotoregE, hiorloE,
		alucontrolE,
<<<<<<< HEAD
		flushE,
		// ME
		memtoregM, regwriteM,
		hiwriteM, lowriteM,
		readdataM,
		aluoutM, writedataM,
		// WB
		memtoregW, regwriteW,
		hiwriteW, lowriteW
=======
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
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	);
	
endmodule

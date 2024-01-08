`timescale 1ns / 1ps

module mips(
	input 	wire 			clk, rst,
	// IF
	output 	wire[31:0] 		pc_pF,
	input 	wire[31:0] 		instrF,
	// ME
	output	wire			data_sram_enM,
	output 	wire[3:0] 		memwriteM,
	output 	wire[31:0] 		aluout_pM, writedataM,
	input 	wire[31:0] 		readdataM,
	// stall
	input	wire			i_stallF,
	input	wire			d_stallM,
	output	wire			div_stallE,
	// debug
	output	wire[31:0]		pcW,
	output					regwrite,
	output	wire[4:0]		writeregW,
	output	wire[31:0]		resultW
    );
	
	wire[31:0]				instrD;
	wire					stallD;
	wire 					regdstE, alusrcE, pcsrcD, memtoregE, memtoregM, memtoregW, regwriteW;
	wire					regwriteE, regwriteM;
	wire					hilotoregD, hiorloD, hilotoregE, hiorloE, hiwriteE, lowriteE, hiwriteM, lowriteM, hiwriteW, lowriteW, hilotoregM, hilotoregW;
	wire					immseD;
	wire					invalidD;
	wire					ismultE, ismultM, ismultW, isdivE, isdivM, isdivW, signedmultE, signeddivE;
	wire[5:0] 				alucontrolE;
	wire 					branchD, equalD, jumpD, jumpregD;
	wire					linkregE, linkdataW;
	wire					cp0toregE, cp0toregM, cp0toregW, cp0writeM;
	wire					stallE, flushE, stallM, flushM, stallW, flushW;
	wire[31:0]				pcF, aluoutM;
	wire					no_dcache;
	wire					is_overflow_detectM;
	wire					memweM;

	assign regwrite = regwriteW | hilotoregW | cp0toregW;
	assign data_sram_enM = memtoregM | memweM;

	mmu mmu(
		.inst_vaddr(pcF),
		.inst_paddr(pc_pF),
		.data_vaddr(aluoutM),
		.data_paddr(aluout_pM),
		.no_dcache(no_dcache)
	);

	controller c(
		clk, rst,
		// ID
		instrD,
		stallD,
		equalD,
		pcsrcD, branchD, jumpD, jumpregD,
		hilotoregD, hiorloD,
		immseD,
		invalidD,
		// EX
		stallE, flushE,
		memtoregE, alusrcE,
		regdstE, regwriteE,	
		alucontrolE,
		hilotoregE, hiorloE, hiwriteE, lowriteE,
		ismultE, signedmultE,
		isdivE, signeddivE,
		linkregE,
		cp0toregE,
		// ME
		stallM, flushM,
		memtoregM, regwriteM,
		hiwriteM, lowriteM, hilotoregM,
		ismultM, isdivM,
		cp0toregM, cp0writeM,
		is_overflow_detectM,
		memweM,
		// WB
		stallW, flushW,
		memtoregW, regwriteW, 
		hiwriteW, lowriteW, hilotoregW,
		ismultW, isdivW,
		linkdataW,
		cp0toregW
	);

	datapath dp(
		clk, rst,
		// IF
		pcF,
		instrF,
		i_stallF,
		// ID
		pcsrcD, branchD, jumpD, jumpregD,
		hilotoregD, hiorloD,
		immseD,
		invalidD,
		equalD,
		instrD,
		stallD,
		// EX
		regdstE, alusrcE, memtoregE, regwriteE,
		hilotoregE, hiorloE, hiwriteE, lowriteE,
		alucontrolE,
		ismultE, signedmultE,
		isdivE, signeddivE,
		linkregE,
		cp0toregE,
		div_stallE,
		stallE, flushE,
		// ME
		memtoregM, regwriteM,
		hiwriteM, lowriteM, hilotoregM,
		ismultM, isdivM,
		readdataM,
		cp0toregM, cp0writeM,
		is_overflow_detectM,
		aluoutM, writedataM,
		memwriteM,
		stallM, flushM,
		d_stallM,
		// WB
		memtoregW, regwriteW,
		hiwriteW, lowriteW, hilotoregW,
		ismultW, isdivW,
		linkdataW,
		cp0toregW,
		pcW, writeregW, resultW,
		stallW, flushW
	);
	
endmodule
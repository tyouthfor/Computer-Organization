`timescale 1ns / 1ps

/*
	模块名称: mips
	模块功能: 将数据通路与控制单元封装成普通 MIPS CPU 接口
	inst ram 接口:
		pcF					inst ram 的访问地址
		instrF				从 inst ram 读出的指令
	data ram 接口
		data_sram_enM		data ram 的使能信号
		memwriteM			data ram 的写使能信号
		aluoutM				data ram 的访问地址
		writedataM			写 data ram 的数据
		readdataM			从 data ram 读出的数据
*/
module mips(
	input 	wire 			clk, rst,
	input	wire[5:0]		ext_int,
	// inst ram
	output 	wire[31:0] 		pcF,
	input 	wire[31:0] 		instrF,
	// data ram
	output	wire			data_sram_enM,
	output 	wire[3:0] 		memwriteM,
	output 	wire[31:0] 		aluoutM,
	output	wire[31:0]		writedataM,
	input 	wire[31:0] 		readdataM,
	// stall
	input	wire			i_stallF,
	input	wire			d_stallM,
	// debug
	output	wire[31:0]		pcW,
	output					regwrite,
	output	wire[4:0]		writeregW,
	output	wire[31:0]		resultW,
	// except
	output	wire			exceptflush,
	output	wire			dataram_except
    );
	
	// IF
	// ID
	wire[31:0]				instrD;
	wire					stallD;
	wire					immseD;
	wire 					branchD, jumpD, jumpregD;
	wire					hilotoregD, hiorloD;
	wire					invalidD;
	// EX
	wire 					regdstE, alusrcE, regwriteE, memtoregE;
	wire[5:0] 				alucontrolE;
	wire					linkregE;
	wire					ismultE, signedmultE, isdivE, signeddivE;
	wire					hilotoregE, hiorloE, hiwriteE, lowriteE;
	wire					cp0toregE;
	wire					stallE, flushE;
	// ME
	wire					regwriteM, memtoregM, memweM;
	wire					ismultM, isdivM;
	wire					hilotoregM, hiwriteM, lowriteM;
	wire					cp0toregM, cp0writeM;
	wire					is_overflow_detectM;
	wire					stallM, flushM;
	// WB
	wire					regwriteW, memtoregW;
	wire					linkdataW;
	wire					ismultW, isdivW;
	wire					hilotoregW, hiwriteW, lowriteW;
	wire					cp0toregW;
	wire					stallW, flushW;

	assign regwrite = regwriteW | hilotoregW | cp0toregW;
	assign data_sram_enM = memtoregM | memweM;

	// ASCII
	wire[39:0] ascii;
    instdec instdec(
        .instr(instrF),
        .ascii(ascii)
    );

	// 控制单元
	controller c(
		clk, rst,
		// IF
		// ID
		instrD,
		stallD,
		immseD,
		branchD, jumpD, jumpregD,
		hilotoregD, hiorloD,
		invalidD,
		// EX
		stallE, flushE,
		regdstE, alusrcE, regwriteE, memtoregE,
		linkregE,
		ismultE, signedmultE, isdivE, signeddivE,
		hilotoregE, hiorloE, hiwriteE, lowriteE,
		cp0toregE,
		alucontrolE,
		// ME
		stallM, flushM,
		regwriteM, memtoregM, memweM,
		ismultM, isdivM,
		hiwriteM, lowriteM, hilotoregM,
		cp0toregM, cp0writeM,
		is_overflow_detectM,
		// WB
		stallW, flushW,
		regwriteW, memtoregW,
		linkdataW,
		ismultW, isdivW,
		hiwriteW, lowriteW, hilotoregW,
		cp0toregW
	);

	// 数据通路
	datapath dp(
		clk, rst,
		ext_int,
		// IF
		i_stallF,
		instrF,
		pcF,
		// ID
		immseD,
		branchD, jumpD, jumpregD,
		hilotoregD, hiorloD,
		invalidD,
		instrD,
		stallD,
		// EX
		regdstE, alusrcE, regwriteE, memtoregE,
		alucontrolE,
		linkregE,
		ismultE, signedmultE, isdivE, signeddivE,
		hilotoregE, hiorloE, hiwriteE, lowriteE,
		cp0toregE,
		stallE, flushE,
		// ME
		d_stallM,
		readdataM,
		regwriteM, memtoregM,
		ismultM, isdivM,
		hilotoregM, hiwriteM, lowriteM,
		cp0toregM, cp0writeM,
		is_overflow_detectM,
		aluoutM, writedataM,
		memwriteM,
		stallM, flushM,
		// WB
		regwriteW, memtoregW,
		linkdataW,
		ismultW, isdivW,
		hilotoregW, hiwriteW, lowriteW,
		cp0toregW,
		stallW, flushW,
		// debug
		pcW, writeregW, resultW,
		// except
		exceptflush,
		dataram_except
	);
	
endmodule
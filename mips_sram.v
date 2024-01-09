`timescale 1ns / 1ps

module mips_sram(
    /*
        模块名称: mips_sram
        模块功能: 将 MIPS CPU 封装成 sram 接口
    */
    input   wire            clk,
    input   wire            rst,
    // inst sram
    output  wire            inst_sram_en,
    output  wire[3:0]       inst_sram_wen,
    output  wire[31:0]      inst_sram_addr,
    output  wire[31:0]      inst_sram_wdata,
    input   wire[31:0]      inst_sram_rdata,
    input   wire            i_stall,
    // data sram
    output  wire            data_sram_en,
    output  wire[3:0]       data_sram_wen,
    output  wire[31:0]      data_sram_addr,
    output  wire[31:0]      data_sram_wdata,
    input   wire[31:0]      data_sram_rdata,
    input   wire            d_stall,
    // debug
    output  wire[31:0]      debug_wb_pc,
    output  wire[3:0]       debug_wb_rf_wen,
    output  wire[4:0]       debug_wb_rf_wnum,
    output  wire[31:0]      debug_wb_rf_wdata,
    // stall
    output  wire            div_stall,
    // except
    output  wire            exceptflush
    );

	wire [31:0]     pc;             // 读 inst_sram 的地址
	wire [31:0]     instr;          // 从 inst_sram 中读出的指令

	wire [3:0]      memwrite;       // data_sram 的写使能信号
	wire [31:0]     aluout;         // 读/写 data_sram 的地址
    wire [31:0]     writedata;      // 写入 data_sram 的数据
    wire [31:0]     readdata;       // 从 data_sram 中读出的数据

    wire [31:0]     pcW;
    wire            regwriteW;
    wire [4:0]      writeregW;
    wire [31:0]     resultW;

    wire [39:0]     ascii;

    mips mips(
        .clk(clk),
        .rst(rst),
        // IF
        .pc_pF(pc), 
        .instrF(instr), 
        // ME
        .data_sram_enM(data_sram_en),
        .memwriteM(memwrite),
        .aluout_pM(aluout),
        .writedataM(writedata),
        .readdataM(readdata),
        // stall
        .i_stallF(i_stall),
        .d_stallM(d_stall),
        .div_stallE(div_stall),
        // debug
        .pcW(pcW),
        .regwrite(regwriteW),
        .writeregW(writeregW),
        .resultW(resultW),
        // except
        .exceptflush(exceptflush)
    );

    // inst_sram
    assign inst_sram_en         = 1'b1;
    assign inst_sram_wen        = 4'b0;
    assign inst_sram_addr       = pc;
    assign inst_sram_wdata      = 32'b0;
    assign instr                = inst_sram_rdata;

    // data_sram
    assign data_sram_wen        = memwrite;
    assign data_sram_addr       = aluout;
    assign data_sram_wdata      = writedata;
    assign readdata             = data_sram_rdata;

    // debug
    assign debug_wb_pc          = pcW;
    assign debug_wb_rf_wen      = {4{regwriteW}};
    assign debug_wb_rf_wnum     = writeregW;
    assign debug_wb_rf_wdata    = resultW;

    // ascii
    instdec instdec(
        .instr(instr),
        .ascii(ascii)
    );

endmodule
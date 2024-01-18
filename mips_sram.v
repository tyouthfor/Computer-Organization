`timescale 1ns / 1ps

/*
    模块名称: mips_sram
    模块功能: 将 MIPS CPU 封装成 sram 接口
    inst sram 接口:
        inst_sram_en        inst ram 的使能信号
        inst_sram_wen       inst ram 的写使能信号
        inst_sram_addr      inst ram 的访问地址
        inst_sram_wdata     写 inst ram 的数据
        inst_sram_rdata     从 inst ram 读出的数据
    data sram 接口:
        data_sram_en        data ram 的使能信号
        data_sram_wen       data ram 的写使能信号
        data_sram_addr      data ram 的访问地址
        data_sram_wdata     写 data ram 的数据
        data_sram_rdata     从 data ram 读出的数据
*/
module mips_sram(
    input   wire            clk, rst,
    input	wire[5:0]		ext_int,
    // inst sram
    output  wire            inst_sram_en,
    output  wire[3:0]       inst_sram_wen,
    output  wire[31:0]      inst_sram_addr,
    output  wire[31:0]      inst_sram_wdata,
    input   wire[31:0]      inst_sram_rdata,
    // data sram
    output  wire            data_sram_en,
    output  wire[3:0]       data_sram_wen,
    output  wire[31:0]      data_sram_addr,
    output  wire[31:0]      data_sram_wdata,
    input   wire[31:0]      data_sram_rdata,
    // debug
    output  wire[31:0]      debug_wb_pc,
    output  wire[3:0]       debug_wb_rf_wen,
    output  wire[4:0]       debug_wb_rf_wnum,
    output  wire[31:0]      debug_wb_rf_wdata,
    // stall
    input   wire            i_stall,
    input   wire            d_stall,
    // except
    output  wire            exceptflush,
    output  wire            dataram_except
    );

    wire regwriteW;

    assign inst_sram_en = 1'b1;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_wdata = 32'b0;
    assign debug_wb_rf_wen = {4{regwriteW}};

    mips mips(
        .clk(clk), .rst(rst),
        .ext_int(ext_int),
        // inst ram
        .pcF(inst_sram_addr), 
        .instrF(inst_sram_rdata), 
        // data ram
        .data_sram_enM(data_sram_en),
        .memwriteM(data_sram_wen),
        .aluoutM(data_sram_addr),
        .writedataM(data_sram_wdata),
        .readdataM(data_sram_rdata),
        // stall
        .i_stallF(i_stall),
        .d_stallM(d_stall),
        // debug
        .pcW(debug_wb_pc),
        .regwrite(regwriteW),
        .writeregW(debug_wb_rf_wnum),
        .resultW(debug_wb_rf_wdata),
        // except
        .exceptflush(exceptflush),
        .dataram_except(dataram_except)
    );

endmodule
`timescale 1ns / 1ps

module mips_sramlike(
    /*
        模块名称: mips_sramlike
        模块功能: 将 MIPS CPU 封装成 sram-like 接口
    */
    input   wire            clk,
    input   wire            rst,
    // inst sram-like
    output  wire            inst_req,
    output  wire            inst_wr,
    output  wire[1:0]       inst_size,
    output  wire[31:0]      inst_addr,
    output  wire[31:0]      inst_wdata,
    input   wire[31:0]      inst_rdata,
    input   wire            inst_addr_ok,
    input   wire            inst_data_ok,
    // data sram-like
    output  wire            data_req,
    output  wire            data_wr,
    output  wire[1:0]       data_size,
    output  wire[31:0]      data_addr,
    output  wire[31:0]      data_wdata,
    input   wire[31:0]      data_rdata,
    input   wire            data_addr_ok,
    input   wire            data_data_ok,
    // debug
    output  wire[31:0]      debug_wb_pc,
    output  wire[3:0]       debug_wb_rf_wen,
    output  wire[4:0]       debug_wb_rf_wnum,
    output  wire[31:0]      debug_wb_rf_wdata
    );

    // sram
    wire                    inst_sram_en;
    wire[3:0]               inst_sram_wen;
    wire[31:0]              inst_sram_addr;
    wire[31:0]              inst_sram_wdata;
    wire[31:0]              inst_sram_rdata;
    wire                    i_stall;
    wire                    data_sram_en;
    wire[3:0]               data_sram_wen;
    wire[31:0]              data_sram_addr;
    wire[31:0]              data_sram_wdata;
    wire[31:0]              data_sram_rdata;
    wire                    d_stall;

    mips_sram mips_sram(
        .clk(clk),
        .rst(~rst),
        // inst sram
        .inst_sram_en(inst_sram_en),
        .inst_sram_wen(inst_sram_wen),
        .inst_sram_addr(inst_sram_addr),
        .inst_sram_wdata(inst_sram_wdata),
        .inst_sram_rdata(inst_sram_rdata),
        .i_stall(i_stall),
        // data sram
        .data_sram_en(data_sram_en),
        .data_sram_wen(data_sram_wen),
        .data_sram_addr(data_sram_addr),
        .data_sram_wdata(data_sram_wdata),
        .data_sram_rdata(data_sram_rdata),
        .d_stall(d_stall),
        // debug
        .debug_wb_pc(debug_wb_pc),
        .debug_wb_rf_wen(debug_wb_rf_wen),
        .debug_wb_rf_wnum(debug_wb_rf_wnum),
        .debug_wb_rf_wdata(debug_wb_rf_wdata),
        .div_stall(div_stall)
    );

    inst_sramlike_interface inst_sramlike_interface(
        .clk(clk),
        .rst(~rst),
        // inst sram
        .inst_sram_en(inst_sram_en),
        .inst_sram_wen(inst_sram_wen),
        .inst_sram_addr(inst_sram_addr),
        .inst_sram_wdata(inst_sram_wdata),
        .inst_sram_rdata(inst_sram_rdata),
        .i_stall(i_stall),
        // inst sram-like
        .inst_req(inst_req),
        .inst_wr(inst_wr),
        .inst_size(inst_size),
        .inst_addr(inst_addr),
        .inst_wdata(inst_wdata),
        .inst_rdata(inst_rdata),
        .inst_addr_ok(inst_addr_ok),
        .inst_data_ok(inst_data_ok),
        .div_stall(div_stall)
    );

    data_sramlike_interface data_sramlike_interface(
        .clk(clk),
        .rst(~rst),
        // data sram
        .data_sram_en(data_sram_en),
        .data_sram_wen(data_sram_wen),
        .data_sram_addr(data_sram_addr),
        .data_sram_wdata(data_sram_wdata),
        .data_sram_rdata(data_sram_rdata),
        .d_stall(d_stall),
        // data sram-like
        .data_req(data_req),
        .data_wr(data_wr),
        .data_size(data_size),
        .data_addr(data_addr),
        .data_wdata(data_wdata),
        .data_rdata(data_rdata),
        .data_addr_ok(data_addr_ok),
        .data_data_ok(data_data_ok),
        .div_stall(div_stall)
    );

endmodule
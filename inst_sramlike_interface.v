`timescale 1ns / 1ps

module inst_sramlike_interface (
    input wire              clk, rst,
    // inst sram
    input   wire            inst_sram_en,
    input   wire[3:0]       inst_sram_wen,
    input   wire[31:0]      inst_sram_addr,
    input   wire[31:0]      inst_sram_wdata,
    output  wire[31:0]      inst_sram_rdata,
    output  wire            i_stall,
    // inst sram-like
    output  wire            inst_req,
    output  wire            inst_wr,
    output  wire[1:0]       inst_size,
    output  wire[31:0]      inst_addr,
    output  wire[31:0]      inst_wdata,
    input   wire[31:0]      inst_rdata,
    input   wire            inst_addr_ok,
    input   wire            inst_data_ok,

    input   wire            div_stall
    );

    reg                     addr_rcv;
    reg                     data_rcv;
    reg [31:0]              inst_rdata_save;

    // 在处理完整个事务后才将 addr_rcv 和 data_rcv 拉低
    always @(posedge clk) begin
        //保证先inst_req再addr_rcv；如果addr_ok同时data_ok，则优先data_ok
        if (rst) begin
            addr_rcv <= 1'b0;
        end
        else if (inst_req & inst_addr_ok & ~inst_data_ok) begin
            addr_rcv <= 1'b1;  // 地址握手成功
        end
        else if (inst_data_ok) begin
            addr_rcv <= 1'b0;  // 数据握手成功
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            data_rcv <= 1'b0;
        end
        else if (inst_data_ok) begin
            data_rcv <= 1'b1;  // 数据握手成功
        end
        else if (~i_stall | ~div_stall) begin
            data_rcv <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            inst_rdata_save <= 32'b0;
        end
        else if (inst_data_ok) begin
            inst_rdata_save <= inst_rdata;
        end
    end

    // sram-like
    assign inst_req         = inst_sram_en & ~addr_rcv & ~data_rcv;
    assign inst_wr          = 1'b0;
    assign inst_size        = 2'b10;
    assign inst_addr        = inst_sram_addr;
    assign inst_wdata       = 32'b0;

    //sram
    assign inst_sram_rdata  = inst_rdata_save;
    assign i_stall          = inst_sram_en & ~data_rcv;  // 当数据握手成功时不再 stall

endmodule
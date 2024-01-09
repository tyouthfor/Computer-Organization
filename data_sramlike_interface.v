`timescale 1ns / 1ps

module data_sramlike_interface(
    input   wire            clk, rst,
    // data sram
    input   wire            data_sram_en,
    input   wire[3:0]       data_sram_wen,
    input   wire[31:0]      data_sram_addr,
    input   wire[31:0]      data_sram_wdata,
    output  wire[31:0]      data_sram_rdata,
    output  wire            d_stall,
    // data sram-like
    output  wire            data_req,
    output  wire            data_wr,
    output  wire[1:0]       data_size,
    output  wire[31:0]      data_addr,   
    output  wire[31:0]      data_wdata,
    input   wire[31:0]      data_rdata,
    input   wire            data_addr_ok,
    input   wire            data_data_ok,

    input   wire            div_stall
    );

    reg                     addr_rcv;
    reg                     data_rcv;
    reg [31:0]              data_rdata_save;


    always @(posedge clk) begin
        if (rst) begin
            addr_rcv <= 1'b0;
        end
        else if (data_req & data_addr_ok & ~data_data_ok) begin
            addr_rcv <= 1'b1;  // 地址握手成功
        end
        else if (data_data_ok) begin
            addr_rcv <= 1'b0;  // 数据握手成功
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            data_rcv <= 1'b0; 
        end
        else if (data_data_ok) begin
            data_rcv <= 1'b1;  // 数据握手成功
        end
        else if (~d_stall & ~div_stall) begin
            data_rcv <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            data_rdata_save <= 32'b0;
        end
        else if (data_data_ok) begin
            data_rdata_save <= data_rdata;  // 数据握手成功
        end
    end

    // sram-like
    assign data_req         = data_sram_en & ~addr_rcv & ~data_rcv;
    assign data_wr          = data_sram_en & (data_sram_wen != 4'b0000);
    assign data_size        = (data_sram_wen == 4'b0001 | data_sram_wen == 4'b0010 | data_sram_wen == 4'b0100 | data_sram_wen == 4'b1000) ? 2'b00 :
                              (data_sram_wen == 4'b0011 | data_sram_wen == 4'b1100 ) ? 2'b01 : 2'b10;
    assign data_addr        = data_sram_addr;
    assign data_wdata       = data_sram_wdata;

    // sram
    assign data_sram_rdata  = data_rdata_save;
    assign d_stall          = data_sram_en & ~data_rcv;

endmodule
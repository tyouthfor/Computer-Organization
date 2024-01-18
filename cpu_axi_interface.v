`timescale 1ns / 1ps

/*
    模块名称: cpu_axi_interface
    模块功能: sram-like 接口与 AXI 接口的转接桥
*/
module cpu_axi_interface(
    input   wire            clk, rst,
    // inst sram-like
    input   wire            inst_req,
    input   wire            inst_wr,
    input   wire[1:0]       inst_size,
    input   wire[31:0]      inst_addr,
    input   wire[31:0]      inst_wdata,
    output  wire[31:0]      inst_rdata,
    output  wire            inst_addr_ok,
    output  wire            inst_data_ok,
    // data sram-like
    input   wire            data_req,
    input   wire            data_wr,
    input   wire[1:0]       data_size,
    input   wire[31:0]      data_addr,
    input   wire[31:0]      data_wdata,
    output  wire[31:0]      data_rdata,
    output  wire            data_addr_ok,
    output  wire            data_data_ok,
    // AXI
    // (1) ar
    output  wire[3:0]       arid,
    output  wire[31:0]      araddr,
    output  wire[7:0]       arlen,
    output  wire[2:0]       arsize,
    output  wire[1:0]       arburst,
    output  wire[1:0]       arlock,
    output  wire[3:0]       arcache,
    output  wire[2:0]       arprot,
    output  wire            arvalid,
    input   wire            arready,
    // (2) r
    input   wire[3:0]       rid,
    input   wire[31:0]      rdata,
    input   wire[1:0]       rresp,
    input   wire            rlast,
    input   wire            rvalid,
    output  wire            rready,
    // (3) aw
    output  wire[3:0]       awid,
    output  wire[31:0]      awaddr,
    output  wire[7:0]       awlen,
    output  wire[2:0]       awsize,
    output  wire[1:0]       awburst,
    output  wire[1:0]       awlock,
    output  wire[3:0]       awcache,
    output  wire[2:0]       awprot,
    output  wire            awvalid,
    input   wire            awready,
    // (4) w
    output  wire[3:0]       wid,
    output  wire[31:0]      wdata,
    output  wire[3:0]       wstrb,
    output  wire            wlast,
    output  wire            wvalid,
    input   wire            wready,
    // (5) b
    input   wire[3:0]       bid,
    input   wire[1:0]       bresp,
    input   wire            bvalid,
    output  wire            bready
    );

    // sram-like
    reg         do_req;
    reg         do_req_or;  // 0-inst req, 1-data req
    reg         do_wr_r;
    reg [1:0]   do_size_r;
    reg [31:0]  do_addr_r;
    reg [31:0]  do_wdata_r;
    wire        data_back;

    always @(posedge clk) begin
        if (~rst) begin
            do_req <= 1'b0;
        end
        else if ((inst_req | data_req) & ~do_req) begin
            do_req <= 1'b1;
        end
        else if (data_back) begin
            do_req <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (~rst) begin
            do_req_or <= 1'b0;
        end
        else if (~do_req) begin
            do_req_or <= data_req;
        end
    end

    always @(posedge clk) begin
        if (~rst) begin
            do_wr_r <= 1'b0;
            do_size_r <= 1'b0;
            do_addr_r <= 1'b0;
            do_wdata_r <= 1'b0;
        end
        else if (inst_req & inst_addr_ok) begin
            do_wr_r <= inst_wr;
            do_size_r <= inst_size;
            do_addr_r <= inst_addr;
            do_wdata_r <= inst_wdata;
        end
        else if (data_req & data_addr_ok) begin
            do_wr_r <= data_wr;
            do_size_r <= data_size;
            do_addr_r <= data_addr;
            do_wdata_r <= data_wdata;
        end
    end

    assign inst_addr_ok = ~do_req & ~data_req;
    assign data_addr_ok = ~do_req;
    assign inst_data_ok = do_req & ~do_req_or & data_back;
    assign data_data_ok = do_req & do_req_or & data_back;
    assign inst_rdata   = rdata;
    assign data_rdata   = rdata;

    // AXI
    reg addr_rcv;
    reg wdata_rcv;

    assign data_back = addr_rcv & ((rvalid & rready) | (bvalid & bready));

    always @(posedge clk) begin
        if (~rst) begin
            addr_rcv <= 1'b0;
        end
        else if (arvalid & arready) begin
            addr_rcv <= 1'b1;
        end
        else if (awvalid & awready) begin
            addr_rcv <= 1'b1;
        end
        else if (data_back) begin
            addr_rcv <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (~rst) begin
            wdata_rcv <= 1'b0; 
        end
        else if (wvalid & wready) begin
            wdata_rcv <= 1'b1;
        end
        else if (data_back) begin
            wdata_rcv <= 1'b0;
        end
    end

    // (1) ar
    assign arid    = 4'd0;
    assign araddr  = do_addr_r;
    assign arlen   = 8'd0;
    assign arsize  = do_size_r;
    assign arburst = 2'd0;
    assign arlock  = 2'd0;
    assign arcache = 4'd0;
    assign arprot  = 3'd0;
    assign arvalid = do_req & ~do_wr_r & ~addr_rcv;
    // (2) r
    assign rready  = 1'b1;
    // (3) aw
    assign awid    = 4'd0;
    assign awaddr  = do_addr_r;
    assign awlen   = 8'd0;
    assign awsize  = do_size_r;
    assign awburst = 2'd0;
    assign awlock  = 2'd0;
    assign awcache = 4'd0;
    assign awprot  = 3'd0;
    assign awvalid = do_req & do_wr_r & ~addr_rcv;
    // (4) w
    assign wid    = 4'd0;
    assign wdata  = do_wdata_r;
    assign wstrb  = (do_size_r == 2'd0) ? 4'b0001 << do_addr_r[1:0] :
                    (do_size_r == 2'd1) ? 4'b0011 << do_addr_r[1:0] : 4'b1111;
    assign wlast  = 1'd1;
    assign wvalid = do_req & do_wr_r & ~wdata_rcv;
    // (5) b
    assign bready  = 1'b1;

endmodule
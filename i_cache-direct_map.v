`timescale 1ns / 1ps

/*
    模块名称: i_cache_direct_map
    模块功能: 直接映射 i_cache
*/
module i_cache_direct_map(
    input   wire            clk, rst,
    // MIPS CPU 的 inst sram-like 接口
    input   wire            cpu_inst_req,
    input   wire            cpu_inst_wr,
    input   wire[1:0]       cpu_inst_size,
    input   wire[31:0]      cpu_inst_addr,
    input   wire[31:0]      cpu_inst_wdata,
    output  wire[31:0]      cpu_inst_rdata,
    output  wire            cpu_inst_addr_ok,
    output  wire            cpu_inst_data_ok,
    // Cache 的 inst sram-like 接口
    output  wire            cache_inst_req,
    output  wire            cache_inst_wr,
    output  wire[1:0]       cache_inst_size,
    output  wire[31:0]      cache_inst_addr,
    output  wire[31:0]      cache_inst_wdata,
    input   wire[31:0]      cache_inst_rdata,
    input   wire            cache_inst_addr_ok,
    input   wire            cache_inst_data_ok
    );

    // Cache 配置
    parameter   INDEX_WIDTH  = 10;
    parameter   OFFSET_WIDTH = 2;
    localparam  TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    localparam  CACHE_DEEPTH = 1 << INDEX_WIDTH;
    
    // Cache 存储单元
    reg                         cache_valid [CACHE_DEEPTH-1:0];
    reg [TAG_WIDTH-1:0]         cache_tag   [CACHE_DEEPTH-1:0];
    reg [31:0]                  cache_block [CACHE_DEEPTH-1:0];

    // 访问地址分解
    wire[OFFSET_WIDTH-1:0]      offset;
    wire[INDEX_WIDTH-1:0]       index;
    wire[TAG_WIDTH-1:0]         tag;
    
    assign offset   = cpu_inst_addr[OFFSET_WIDTH - 1 : 0];
    assign index    = cpu_inst_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag      = cpu_inst_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];

    // 访问 Cache line 并判断是否命中
    wire                        c_valid;
    wire[TAG_WIDTH-1:0]         c_tag;
    wire[31:0]                  c_block;
    wire                        hit;

    assign c_valid  = cache_valid[index];
    assign c_tag    = cache_tag  [index];
    assign c_block  = cache_block[index];
    assign hit      = c_valid & (c_tag == tag);

    // i_cache 状态机
    parameter IDLE = 2'b00, RM = 2'b01;
    reg [1:0] state;
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    if (cpu_inst_req) begin
                        state <= RM;
                    end
                end

                RM: begin
                    if (hit | cache_inst_data_ok) begin  // Cache 命中或访存成功
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    // 读 inst ram 的握手信号
    reg addr_rcv;
    wire data_rcv;
    always @(posedge clk) begin
        if (rst) begin
            addr_rcv <= 1'b0;
        end
        else if (cache_inst_req & cache_inst_addr_ok) begin
            addr_rcv <= 1'b1;
        end
        else if (data_rcv) begin
            addr_rcv <= 1'b0;
        end
    end

    assign data_rcv = cache_inst_data_ok;

    // output to MIPS CPU
    assign cpu_inst_rdata   = hit ? c_block : cache_inst_rdata;
    assign cpu_inst_addr_ok = (cpu_inst_req & hit) | (cache_inst_req & cache_inst_addr_ok);
    assign cpu_inst_data_ok = (cpu_inst_req & hit) | (cache_inst_data_ok);

    // output to AXI interface
    assign cache_inst_req   = (state == RM) & ~addr_rcv & ~hit;
    assign cache_inst_wr    = cpu_inst_wr;
    assign cache_inst_size  = cpu_inst_size;
    assign cache_inst_addr  = cpu_inst_addr;
    assign cache_inst_wdata = cpu_inst_wdata;

    // 写入 Cache line
    // (1) 保存 tag 和 index
    reg [TAG_WIDTH-1:0]     tag_save;
    reg [INDEX_WIDTH-1:0]   index_save;
    always @(posedge clk) begin
        if (rst) begin
            tag_save <= 0;
            index_save <= 0;
        end
        else if (cpu_inst_req) begin
            tag_save <= tag;
            index_save <= index;
        end
    end

    // (2) 写 Cache
    integer t;
    always @(posedge clk) begin
        if (rst) begin
            cache_valid <= '{default: '0};  // 刚开始将 Cache 置为无效
            // for (t = 0; t < CACHE_DEEPTH; t = t + 1) begin   
            //     cache_valid[t] <= 0;
            // end
        end
        else if (data_rcv) begin  // 读缺失, 在访存结束时写入 Cache
            cache_valid[index_save] <= 1'b1;
            cache_tag  [index_save] <= tag_save;
            cache_block[index_save] <= cache_inst_rdata;
        end
    end

endmodule
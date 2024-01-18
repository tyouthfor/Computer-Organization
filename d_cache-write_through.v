`timescale 1ns / 1ps

/*
    模块名称: d_cache_write_through
    模块功能: 写直达 d_cache
*/
module d_cache_write_through(
    input   wire            clk, rst,
    // MIPS CPU 的 data sram-like 接口
    input   wire            cpu_data_req,
    input   wire            cpu_data_wr,
    input   wire[1:0]       cpu_data_size,
    input   wire[31:0]      cpu_data_addr,
    input   wire[31:0]      cpu_data_wdata,
    output  wire[31:0]      cpu_data_rdata,
    output  wire            cpu_data_addr_ok,
    output  wire            cpu_data_data_ok,
    // Cache 的 data sram-like 接口
    output  wire            cache_data_req,
    output  wire            cache_data_wr,
    output  wire[1:0]       cache_data_size,
    output  wire[31:0]      cache_data_addr,
    output  wire[31:0]      cache_data_wdata,
    input   wire[31:0]      cache_data_rdata,
    input   wire            cache_data_addr_ok,
    input   wire            cache_data_data_ok,
    // except
    input   wire            dataram_except,
    // no_dcache
    input   wire            no_dcache
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
    
    assign offset   = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index    = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag      = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];

    // 访问 Cache line 并判断是否命中
    wire                        c_valid;
    wire[TAG_WIDTH-1:0]         c_tag;
    wire[31:0]                  c_block;
    wire                        hit;

    assign c_valid  = cache_valid[index];
    assign c_tag    = cache_tag  [index];
    assign c_block  = cache_block[index];
    assign hit      = c_valid & (c_tag == tag) & ~no_dcache;

    // 读 d_cache 或写 d_cache
    wire                        read;
    wire                        write;

    assign write    = cpu_data_wr;
    assign read     = ~write;

    // d_cache 状态机
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    reg [1:0] state;
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    if (cpu_data_req & read & ~hit) begin
                        state <= RM;
                    end
                    else if (cpu_data_req & write) begin
                        state <= WM;
                    end
                end

                RM: begin
                    if (read & cache_data_data_ok) begin
                        state <= IDLE;
                    end
                end

                WM: begin
                    if (write & cache_data_data_ok) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    // 读 data ram 的握手信号
    reg read_addr_rcv;
    wire read_data_rcv;
    always @(posedge clk) begin
        if (rst) begin
            read_addr_rcv <= 1'b0;
        end
        else if (read & cache_data_req & cache_data_addr_ok) begin
            read_addr_rcv <= 1'b1;
        end
        else if (read_data_rcv) begin
            read_addr_rcv <= 1'b0;
        end
    end

    assign read_data_rcv = read & cache_data_data_ok;

    // 写 data ram 的握手信号
    reg write_addr_rcv;      
    wire write_data_rcv;   
    always @(posedge clk) begin
        if (rst) begin
            write_addr_rcv <= 1'b0;
        end
        else if (write & cache_data_req & cache_data_addr_ok) begin
            write_addr_rcv <= 1'b1;
        end
        else if (write_data_rcv) begin
            write_addr_rcv <= 1'b0;
        end
    end

    assign write_data_rcv = write & cache_data_data_ok;

    // output to MIPS CPU
    assign cpu_data_rdata   = hit ? c_block : cache_data_rdata;
    assign cpu_data_addr_ok = (read & cpu_data_req & hit) | (cache_data_req & cache_data_addr_ok);
    assign cpu_data_data_ok = (read & cpu_data_req & hit) | (cache_data_data_ok);

    // output to AXI interface
    assign cache_data_req   = ((state == RM) & ~read_addr_rcv) | ((state == WM) & ~write_addr_rcv);
    assign cache_data_wr    = cpu_data_wr;
    assign cache_data_size  = cpu_data_size;
    assign cache_data_addr  = cpu_data_addr;
    assign cache_data_wdata = cpu_data_wdata;

    // 写入 Cache line
    // (1) 保存 tag 和 index
    reg [TAG_WIDTH-1:0]     tag_save;
    reg [INDEX_WIDTH-1:0]   index_save;
    always @(posedge clk) begin
        if (rst) begin
            tag_save <= 0;
            index_save <= 0;
        end
        else if (cpu_data_req) begin
            tag_save <= tag;
            index_save <= index;
        end
    end

    // (2) 生成写掩码
    reg [3:0] write_mask;
    always @(*) begin
        write_mask = 0;
        case (cpu_data_size)
            2'b00: begin
                case (cpu_data_addr[1:0])
                    2'b00: write_mask = 4'b0001;
                    2'b01: write_mask = 4'b0010;
                    2'b10: write_mask = 4'b0100;
                    2'b11: write_mask = 4'b1000;
                    default: write_mask = 0;
                endcase
            end

            2'b01: begin
                case (cpu_data_addr[1])
                    1'b0: write_mask = 4'b0011;
                    1'b1: write_mask = 4'b1100;
                    default: write_mask = 0;
                endcase
            end

            default: write_mask = 4'b1111;
        endcase
    end

    // (3) 生成写数据
    wire [31:0] write_cache_data;

    assign write_cache_data = (
        cache_block[index] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} |
        cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}}
    );                   

    // (4) 写 Cache
    integer t;
    always @(posedge clk) begin
        if (rst) begin
            cache_valid <= '{default: '0};  // 刚开始将 Cache 置为无效
            // for (t = 0; t < CACHE_DEEPTH; t = t + 1) begin   
            //     cache_valid[t] <= 0;
            // end
        end
        else if (read_data_rcv & ~except) begin  // 读缺失, 在访存结束时写入 Cache
            cache_valid[index_save] <= 1'b1;
            cache_tag  [index_save] <= tag_save;
            cache_block[index_save] <= cache_data_rdata;
        end
        else if (write & cpu_data_req & hit) begin  // 写命中时需要写 Cache
            cache_block[index] <= write_cache_data;
        end
    end

    // 例外处理状态机
    reg         except;
    reg [1:0]   exceptstate;
    always @(posedge clk) begin
        if (rst) begin
            except <= 1'b0;
            exceptstate <= 2'b00;
        end
        else begin
            case (exceptstate)
                2'b00: begin
                    if (dataram_except) begin
                        except <= 1'b1;
                        exceptstate <= 2'b01;
                    end
                end

                2'b01: begin
                    if (cache_data_data_ok) begin
                        except <= 1'b1;
                        exceptstate <= 2'b10;
                    end
                end

                2'b10: begin
                    if (cache_data_data_ok) begin
                        except <= 1'b0;
                        exceptstate <= 2'b00;
                    end
                end

                default: begin
                    except <= 1'b0;
                    exceptstate <= 2'b00;
                end
            endcase
        end
    end

endmodule
`timescale 1ns / 1ps

/*
    模块名称: inst_sramlike_interface
    模块功能: inst sram 接口与 inst sram-like 接口的转接桥
*/
module inst_sramlike_interface (
    input   wire            clk, rst,
    // inst sram
    input   wire            inst_sram_en,
    input   wire[3:0]       inst_sram_wen,
    input   wire[31:0]      inst_sram_addr,
    input   wire[31:0]      inst_sram_wdata,
    output  wire[31:0]      inst_sram_rdata,
    // inst sram-like
    output  wire            inst_req,
    output  wire            inst_wr,
    output  wire[1:0]       inst_size,
    output  wire[31:0]      inst_addr,
    output  wire[31:0]      inst_wdata,
    input   wire[31:0]      inst_rdata,
    input   wire            inst_addr_ok,
    input   wire            inst_data_ok,
    // stall
    output  wire            i_stall,
    // except
    input   wire            exceptflush
    );

    reg                     addr_rcv, data_rcv;
    reg [31:0]              inst_rdata_save;

    // 例外处理状态机
    reg                     except;
    reg [1:0]               state;

    always @(posedge clk) begin
        if (rst) begin
            except <= 1'b0;
            state <= 2'b00;
        end
        else begin
            case (state)
                2'b00: begin
                    if (exceptflush) begin
                        except <= 1'b1;
                        state <= 2'b01;
                    end
                end

                2'b01: begin  // 收到第一个 inst_data_ok, 为例外指令下一条指令, 继续 i_stall
                    if (inst_data_ok) begin
                        except <= 1'b1;
                        state <= 2'b10;
                    end
                end

                2'b10: begin  // 收到第二个 inst_data_ok, 为 BFC00380, 不再 i_stall
                    if (inst_data_ok) begin
                        except <= 1'b0;
                        state <= 2'b00;
                    end
                end

                default: begin
                    except <= 1'b0;
                    state <= 2'b00;
                end
            endcase
        end
    end

    // addr_rcv
    always @(posedge clk) begin
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

    // data_rcv
    always @(posedge clk) begin
        if (rst) begin
            data_rcv <= 1'b0;
        end
        else if (inst_data_ok) begin
            data_rcv <= 1'b1;  // 数据握手成功
        end
        else if (~i_stall | except) begin
            data_rcv <= 1'b0;
        end
    end

    // inst_rdata_save
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
    // sram
    assign inst_sram_rdata  = inst_rdata_save;
    // i_stall
    assign i_stall          = (inst_sram_en & ~data_rcv) | except;

endmodule
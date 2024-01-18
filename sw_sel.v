`timescale 1ns / 1ps
`include "defines.vh"

/*
    模块名称: sw_sel
    模块功能: 根据 Store 指令类型何地址产生正确的 data ram 写使能信号
    输入:
        aluoutM             Store 指令写 data ram 的地址
        opM                 Store 指令的 opcode
        excepttypeM         例外类型
    输出:
        memwriteM           data ram 的写使能信号
*/
module sw_sel(
    input   wire[31:0]      aluoutM,
    input   wire[5:0]       opM,
    input   wire[31:0]      excepttypeM,
    output  reg [3:0]       memwriteM
    );

    always @(*) begin
        if (excepttypeM != 0) begin
            memwriteM = 4'b0000;
        end
        else begin
            case (opM)
                `op_SB: begin
                    case (aluoutM[1:0]) 
                        2'b00: memwriteM = 4'b0001;
                        2'b01: memwriteM = 4'b0010;
                        2'b10: memwriteM = 4'b0100;
                        2'b11: memwriteM = 4'b1000;
                        default: memwriteM = 4'b0000;
                    endcase
                end
                `op_SH: begin
                    case (aluoutM[1:0]) 
                        2'b00: memwriteM = 4'b0011;
                        2'b10: memwriteM = 4'b1100;
                        default: memwriteM = 4'b0000;
                    endcase
                end
                `op_SW: begin
                    memwriteM = 4'b1111;
                end
                default: memwriteM = 4'b0000;
            endcase
        end
    end
    
endmodule
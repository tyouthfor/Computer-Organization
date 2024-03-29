`timescale 1ns / 1ps
`include "defines.vh"

/*
    模块名称: lw_sel
    模块功能: 对 Load 指令读出的字数据进行修正
    输入:
        aluoutW             Load 指令读 data ram 的地址
        readdataW           Load 指令从 data ram 读出的字数据
        opW                 Load 指令的 opcode
    输出:
        lwresultW           修正后的字数据
*/
module lw_sel(
    input   wire[31:0]      aluoutW,
    input   wire[31:0]      readdataW,
    input   wire[5:0]       opW,
    output  reg [31:0]      lwresultW
    );
    
    always @(*) begin
        lwresultW = readdataW;
        case (opW)
            `op_LB: begin 
                case (aluoutW[1:0])
                    2'b00: lwresultW = {{24{readdataW[7]}}, readdataW[7:0]};
                    2'b01: lwresultW = {{24{readdataW[15]}}, readdataW[15:8]};
                    2'b10: lwresultW = {{24{readdataW[23]}}, readdataW[23:16]};
                    2'b11: lwresultW = {{24{readdataW[31]}}, readdataW[31:24]};
                    default: lwresultW = readdataW;
                endcase
            end
            `op_LBU: begin 
                case (aluoutW[1:0])
                    2'b00: lwresultW = {{24{1'b0}}, readdataW[7:0]};
                    2'b01: lwresultW = {{24{1'b0}}, readdataW[15:8]};
                    2'b10: lwresultW = {{24{1'b0}}, readdataW[23:16]};
                    2'b11: lwresultW = {{24{1'b0}}, readdataW[31:24]};
                    default: lwresultW = readdataW;
                endcase
            end
            `op_LH: begin 
                case (aluoutW[1:0])
                    2'b00: lwresultW = {{16{readdataW[15]}}, readdataW[15:0]};
                    2'b10: lwresultW = {{16{readdataW[31]}}, readdataW[31:16]};
                    default: lwresultW = readdataW;
                endcase
            end
            `op_LHU: begin 
                case (aluoutW[1:0])
                    2'b00: lwresultW = {{16{1'b0}}, readdataW[15:0]};
                    2'b10: lwresultW = {{16{1'b0}}, readdataW[31:16]};
                    default: lwresultW = readdataW;
                endcase
            end
            default: lwresultW = readdataW;
        endcase
    end
    
endmodule
`timescale 1ns / 1ps

/*
    模块名称: mult
    模块功能: 乘法器
    输入:
        a               第一操作数
        b               第二操作数
        sign            0-无符号乘法, 1-有符号乘法
    输出:
        y               乘法运算结果
*/
module mult(
    input   wire[31:0]      a,
    input   wire[31:0]      b,
    input   wire            sign,
    output  wire[63:0]      y
    );

    wire [31:0] abs_a, abs_b;
    wire [63:0] abs_result, signed_result;

    assign abs_a = (a[31] == 1'b1) ? ~a + 1 : a;
    assign abs_b = (b[31] == 1'b1) ? ~b + 1 : b;
    assign abs_result = abs_a * abs_b;

    assign signed_result = (a[31] ^ b[31] == 1'b1) ? ~abs_result + 1 : abs_result;
    assign y = sign ? signed_result : a * b;

endmodule
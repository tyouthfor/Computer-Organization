`timescale 1ns / 1ps
`include "defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/02 17:07:59
// Design Name: 
// Module Name: sw_sel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module sw_sel(
    input wire[31:0] aluoutM,
    input [5:0] opM,
    output reg [3:0] memwriteM
    );
    always @(*) begin
        case(opM)
            `op_SB:begin
                case(aluoutM[1:0]) 
                2'b00: memwriteM <= 4'b0001;
                2'b01: memwriteM <= 4'b0010;
                2'b10: memwriteM <= 4'b0100;
                2'b11: memwriteM <= 4'b1000;
                default: memwriteM <= 4'b0000;
                endcase
            end
             `op_SH:begin
                case(aluoutM[1:0]) 
                2'b00: memwriteM <= 4'b0011;
                2'b10: memwriteM <= 4'b1100;
                default: memwriteM <= 4'b0000;
                endcase
            end
            `op_SW:
                memwriteM <= 4'b1111;
                default: memwriteM <= 4'b0000;
        endcase
    end
endmodule

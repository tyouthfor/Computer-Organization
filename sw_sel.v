`timescale 1ns / 1ps
`include "defines.vh"

module sw_sel(
    input   wire[31:0]      aluoutM,
    input   wire[5:0]       opM,
    input   wire[31:0]      excepttypeM,
    output  reg [3:0]       memwriteM
    );

    always @(*) begin
        memwriteM = 4'b0000;
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

`timescale 1ns / 1ps
`include "defines.vh"

module lw_sel(
    input wire [31:0] aluoutW,
    input [31:0] readdataW,
    input [5:0] opW,
    output reg [31:0] lwresultW
    );
    always @(*) begin
        case (opW)
            `op_LB: begin 
                case(aluoutW[1:0])
                    2'b00: lwresultW <= {{24{readdataW[7]}}, readdataW[7:0]};
                    2'b01: lwresultW <= {{24{readdataW[15]}}, readdataW[15:8]};
                    2'b10: lwresultW <= {{24{readdataW[23]}}, readdataW[23:16]};
                    2'b11: lwresultW <= {{24{readdataW[31]}}, readdataW[31:24]};
                    default: lwresultW <= readdataW;
                endcase
            end
            `op_LBU: begin 
                case(aluoutW[1:0])
                    2'b00: lwresultW <= {{24{1'b0}}, readdataW[7:0]};
                    2'b01: lwresultW <= {{24{1'b0}}, readdataW[15:8]};
                    2'b10: lwresultW <= {{24{1'b0}}, readdataW[23:16]};
                    2'b11: lwresultW <= {{24{1'b0}}, readdataW[31:24]};
                    default: lwresultW <= readdataW;
                endcase
            end
            `op_LH: begin 
                case(aluoutW[1:0])
                    2'b00: lwresultW <= {{16{readdataW[15]}}, readdataW[15:0]};
                    2'b10: lwresultW <= {{16{readdataW[31]}}, readdataW[31:16]};
                    default: lwresultW <= readdataW;
                endcase
            end
            `op_LHU: begin 
                case(aluoutW[1:0])
                    2'b00: lwresultW <= {{16{1'b0}}, readdataW[15:0]};
                    2'b10: lwresultW <= {{16{1'b0}}, readdataW[31:16]};
                    default: lwresultW <= readdataW;
                endcase
            end
            default: lwresultW <= readdataW;
        endcase
    end
endmodule

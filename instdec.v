`timescale 1ns / 1ps
`include "defines.vh"

/*
    模块名称: instdec
    模块功能: 在波形图中显示指令的 ASCII 码
    输入:
        instr           指令
        ascii           对应 ASCII 码
*/
module instdec(
    input   wire[31:0]      instr,
    output  reg [39:0]      ascii
    );

    always @(*) begin
        ascii = "N-R";
        case (instr[31:26])
            `op_RTYPE: begin
                case (instr[5:0])
                    `funct_AND:     ascii = "AND";
                    `funct_OR:      ascii = "OR";
                    `funct_XOR:     ascii = "XOR";
                    `funct_NOR:     ascii = "NOR";
                    `funct_SLL:     ascii = "SLL";
                    `funct_SRL:     ascii = "SRL";
                    `funct_SRA:     ascii = "SRA";
                    `funct_SLLV:    ascii = "SLLV";
                    `funct_SRLV:    ascii = "SRLV";
                    `funct_SRAV:    ascii = "SRAV";
                    `funct_MFHI:    ascii = "MFHI";
                    `funct_MTHI:    ascii = "MTHI";
                    `funct_MFLO:    ascii = "MFLO";
                    `funct_MTLO:    ascii = "MTLO";
                    `funct_ADD:     ascii = "ADD";
                    `funct_ADDU:    ascii = "ADDU";
                    `funct_SUB:     ascii = "SUB";
                    `funct_SUBU:    ascii = "SUBU";
                    `funct_SLT:     ascii = "SLT";
                    `funct_SLTU:    ascii = "SLTU";
                    `funct_MULT:    ascii = "MULT";
                    `funct_MULTU:   ascii = "MULTU";
                    `funct_DIV:     ascii = "DIV";
                    `funct_DIVU:    ascii = "DIVU";
                    `funct_JR:      ascii = "JR";
                    `funct_JALR:    ascii = "JALR";
                    `funct_SYSCALL: ascii = "SYSC";
                    `funct_BREAK:   ascii = "BRE";
                    default:        ascii = "N-R";
                endcase
            end

            `op_ANDI:               ascii = "ANDI";
            `op_XORI:               ascii = "XORI";
            `op_LUI:                ascii = "LUI";
            `op_ORI:                ascii = "ORI";
            `op_ADDI:               ascii = "ADDI";
            `op_ADDIU:              ascii = "ADDIU";
            `op_SLTI:               ascii = "SLTI";
            `op_SLTIU:              ascii = "SLTIU";
            `op_J:                  ascii = "J";
            `op_JAL:                ascii = "JAL";
            `op_BEQ:                ascii = "BEQ";
            `op_BGTZ:               ascii = "BGTZ";
            `op_BLEZ:               ascii = "BLEZ";
            `op_BNE:                ascii = "BNE";
            `op_LB:                 ascii = "LB";
            `op_LBU:                ascii = "LBU";
            `op_LH:                 ascii = "LH";
            `op_LHU:                ascii = "LHU";
            `op_LW:                 ascii = "LW";
            `op_SB:                 ascii = "SB";
            `op_SH:                 ascii = "SH";
            `op_SW:                 ascii = "SW";

            6'b000001: begin 
                case (instr[20:16])
                    5'b00001: ascii = "BGEZ";
                    5'b10001: ascii = "BGEZAL";
                    5'b00000: ascii = "BLTZ";
                    5'b10000: ascii = "BLTZAL";
                    default : ascii = "N-R";
                endcase
            end

            6'b010000: begin 
                if (instr == 32'b01000010000000000000000000011000) begin
                    ascii = "ERET";
                end
                else begin 
                    case (instr[25:21])
                        5'b00100: ascii = "MTC0";
                        5'b00000: ascii = "MFC0";
                        default: ascii = "N-R";
                    endcase
                end
            end

            default: ascii = "N-R";
       endcase
            
        if (instr == 0) begin
            ascii = "NOP";
        end
    end

endmodule
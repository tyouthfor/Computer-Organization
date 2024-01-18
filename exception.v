`timescale 1ns / 1ps

/*
    模块名称: exception
    模块功能: 例外检测单元
    输入:
        rst                     复位信号
        instram_except          是否触发取指地址错例外
        dataramload_except      是否触发 Load 指令地址错例外
        dataramstore_except     是否触发 Store 指令地址错例外
        break_except            是否触发 BREAK 例外
        syscall_except          是否触发 SYSCALL 例外
        eret                    是否执行 ERET 指令
        invalid                 是否触发保留指令例外
        overflow                是否触发 ALU 算术运算溢出例外
        cp0status               CP0 的 status 寄存器
        cp0cause                CP0 的 cause 寄存器
        cp0epc                  CP0 的 epc 寄存器
        pc                      触发例外的指令地址
        aluout                  触发 Load/Store 指令地址错例外的错误 ram 地址
    输出:
        excepttype              例外类型
        badramaddr              触发 Load/Store 指令地址错例外的错误 ram 地址
        pc_except               触发例外时的下一条指令地址（通常为例外入口 BFC00380, 执行 ERET 指令时为 epc 寄存器值）
*/
module exception(
    input   wire            rst,
    input   wire            instram_except, dataramload_except, dataramstore_except,
    input   wire            break_except, syscall_except,
    input   wire            eret, invalid, overflow,
    input   wire[31:0]      cp0status, cp0cause, cp0epc,
    input   wire[31:0]      pc, aluout,
    output  reg [31:0]      excepttype, badramaddr, pc_except
    );

    always @(*) begin
        if (rst) begin
            excepttype = 0;
            badramaddr = 0;
            pc_except = 0;
        end
        else begin
            if ((cp0cause[15:8] & cp0status[15:8]) != 0 & cp0status[1:0] == 2'b01) begin
                excepttype = 32'h00000001;  // 外中断
                badramaddr = 0;
                pc_except = 32'hBFC00380;
            end 
            else if (instram_except) begin
                excepttype = 32'h00000004;  // 地址错例外（取指）
                badramaddr = pc;
                pc_except = 32'hBFC00380;
            end
            else if (dataramload_except) begin
                excepttype = 32'h00000004;  // 地址错例外（Load）
                badramaddr = aluout;
                pc_except = 32'hBFC00380;
            end
            else if (dataramstore_except) begin
                excepttype = 32'h00000005;  // 地址错例外（Store）
                badramaddr = aluout;
                pc_except = 32'hBFC00380;
            end
            else if (syscall_except) begin
                excepttype = 32'h00000008;  // SYSCALL 指令例外
                badramaddr = 0;
                pc_except = 32'hBFC00380;
            end
            else if (break_except) begin
                excepttype = 32'h00000009;  // BREAK 指令例外
                badramaddr = 0;
                pc_except = 32'hBFC00380;
            end
            else if (invalid) begin
                excepttype = 32'h0000000a;  // 保留指令例外
                badramaddr = 0;
                pc_except = 32'hBFC00380;
            end
            else if (overflow) begin
                excepttype = 32'h0000000c;  // ALU 溢出例外
                badramaddr = 0;
                pc_except = 32'hBFC00380;
            end
            else if (eret) begin
                excepttype = 32'h0000000e;  // ERET 指令
                badramaddr = 0;
                pc_except = cp0epc;
            end
            else begin
                excepttype = 0;
                badramaddr = 0;
                pc_except = 0;
            end
        end
    end

endmodule
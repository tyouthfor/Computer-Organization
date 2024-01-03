`timescale 1ns / 1ps

module exception(
    input   wire            rst,
    input   wire            instram_except,
    input   wire            dataramload_except,
    input   wire            dataramstore_except,
    input   wire            break_except,
    input   wire            syscall_except,
    input   wire            eret,
    input   wire            invalid,
    input   wire            overflow,
    input   wire[31:0]      cp0status,
    input   wire[31:0]      cp0cause,
    input   wire[31:0]      cp0epc,
    input   wire[31:0]      instramaddr,
    input   wire[31:0]      dataramaddr,
	output  reg [31:0]      excepttype,
    output  reg [31:0]      badramaddr,
    output  reg [31:0]      pc_except
    );

    always @(*) begin
        if (rst) begin
            excepttype <= 0;
            badramaddr <= 0;
            pc_except <= 0;
        end
        else begin
            if (cp0status[15:8] != 0 && cp0cause[15:8] != 0 && cp0status[1:0] == 2'b01) begin
                excepttype <= 32'h00000001;  // 外中断
                badramaddr <= 0;
                pc_except <= 32'hBFC00380;
            end
            else if (instram_except) begin
                excepttype <= 32'h00000004;  // 地址错例外（取指）
                badramaddr <= instramaddr;
                pc_except <= 32'hBFC00380;
            end
            else if (dataramload_except) begin
                excepttype <= 32'h00000004;  // 地址错例外（Load）
                badramaddr <= dataramaddr;
                pc_except <= 32'hBFC00380;
            end
            else if (dataramstore_except) begin
                excepttype <= 32'h00000005;  // 地址错例外（Store）
                badramaddr <= dataramaddr;
                pc_except <= 32'hBFC00380;
            end
            else if (syscall_except) begin
                excepttype <= 32'h00000008;  // SYSCALL 指令例外
                badramaddr <= 0;
                pc_except <= 32'hBFC00380;
            end
            else if (break_except) begin
                excepttype <= 32'h00000009;  // BREAK 指令例外
                badramaddr <= 0;
                pc_except <= 32'hBFC00380;
            end
            else if (invalid) begin
                excepttype <= 32'h0000000a;  // 保留指令例外
                badramaddr <= 0;
                pc_except <= 32'hBFC00380;
            end
            else if (overflow) begin
                excepttype <= 32'h0000000c;  // ALU 溢出例外
                badramaddr <= 0;
                pc_except <= 32'hBFC00380;
            end
            else if (eret) begin
                excepttype <= 32'h0000000e;  // ERET 指令
                badramaddr <= 0;
                pc_except <= cp0epc;
            end
            else begin
                excepttype <= 0;
                badramaddr <= 0;
                pc_except <= 0;
            end
        end
    end


endmodule

`timescale 1ns / 1ps
`include "defines.vh"

module cp0_reg(
    /*
        输入:
            clk                     时钟信号
            rst                     复位信号
            we_i                    写 CP0 信号
            waddr_i                 写 CP0 地址
            raddr_i                 读 CP0 地址
            data_i                  写 CP0 数据
            int_i                   待处理硬件中断标识 = 6'b000000
            excepttype_i            例外类型
            current_inst_addr_i     引发例外的指令地址
            is_in_delayslot_i       指令是否为延迟槽指令
            bad_addr_i              触发地址错例外时的错误 ram 地址
        输出:
            data_o                  从 CP0 读出的数据
            count_o                 每两个时钟周期加一. 当和 COMPARE 寄存器的值相等时, 触发时钟中断
            compare_o               
            status_o                发生例外时 status_o[1] 置 1, 此时 CPU 处于核心态, 所有硬件和软件中断被屏蔽
            cause_o                 存储例外的类型
            epc_o                   存储发生例外的指令地址, 用于例外处理完毕后的返回, 即处理完毕后的 PC
										(1) 如果触发例外的指令是延迟槽指令, 则 EPC = current_inst_addr_i - 4
										(2) 如果触发例外的指令不是延迟槽指令, 则 EPC = current_inst_addr_i
            config_o                暂时无用
            prid_o                  暂时无用
            badvaddr                存储触发地址错例外时的错误 ram 地址
            timer_int_o             1-触发时钟中断, 0-未触发时钟中断
    */
	input   wire        clk, rst,
	input   wire        we_i,
	input   wire[4:0]   waddr_i,
	input   wire[4:0]   raddr_i,
	input   wire[31:0]  data_i,
	input   wire[5:0]   int_i,
	input   wire[31:0]  excepttype_i,
	input   wire[31:0]  current_inst_addr_i,
	input   wire        is_in_delayslot_i,
	input   wire[31:0]  bad_addr_i,

    output  reg [31:0]  data_o,
	output  wire[31:0]  count_o,
	output  reg [31:0]  compare_o,
	output  reg [31:0]  status_o,
	output  reg [31:0]  cause_o,
	output  reg [31:0]  epc_o,
	output  reg [31:0]  config_o,
	output  reg [31:0]  prid_o,
	output  reg [31:0]  badvaddr,
	output  reg         timer_int_o
    );

	reg[32:0] count;
	assign count_o = count[32:1];
	
	always @(posedge clk) begin
		if (rst) begin
			count           <= 0;
			compare_o       <= 0;
			status_o        <= 32'b00010000000000000000000000000000;
			cause_o         <= 0;
			epc_o           <= 0;
			config_o        <= 32'b00000000000000001000000000000000;
			prid_o          <= 32'b00000000010011000000000100000010;
			timer_int_o     <= 0;
		end
        else begin
			count <= count + 1;
			cause_o[15:10] <= int_i;  // 待处理硬件中断标识

            // 触发时钟中断
			if (compare_o != 0 && count_o == compare_o) begin
				timer_int_o <= 1'b1;
			end

            // 写 CP0
			if (we_i) begin
				case (waddr_i)
					`CP0_REG_COUNT: begin 
						count[32:1] <= data_i;
					end
					`CP0_REG_COMPARE: begin 
						compare_o <= data_i;
						timer_int_o <= 1'b0;
					end
					`CP0_REG_STATUS: begin 
						status_o <= data_i;
					end
					`CP0_REG_CAUSE: begin 
						cause_o[9:8] <= data_i[9:8];
						cause_o[23] <= data_i[23];
						cause_o[22] <= data_i[22];
					end
					`CP0_REG_EPC: begin 
						epc_o <= data_i;
					end
					default: /* default */;
				endcase
			end

            // 更新异常
			case (excepttype_i)
				32'h00000001: begin  // 中断（其实写入的cause为0）
					if (is_in_delayslot_i) begin
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end
                    else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00000;
				end
				32'h00000004: begin  // 地址错例外（取指非对齐或 Load 非对齐）
					if (is_in_delayslot_i) begin
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00100;
					badvaddr <= bad_addr_i;
				end
				32'h00000005: begin  // 地址错例外（Store 非对齐）
					if (is_in_delayslot_i) begin
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end 
                    else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00101;
					badvaddr <= bad_addr_i;
				end
				32'h00000008: begin  // SYSCALL 例外
					if (is_in_delayslot_i) begin
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end 
                    else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01000;
				end
				32'h00000009: begin  // BREAK 例外
					if (is_in_delayslot_i) begin
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end 
                    else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01001;
				end
				32'h0000000a: begin  // 保留指令例外（译码失败）
					if (is_in_delayslot_i) begin
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end 
                    else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01010;
				end
				32'h0000000c: begin  // ALU 溢出例外
					if (is_in_delayslot_i) begin
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end 
                    else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01100;
				end
				32'h0000000d: begin  // 自陷指令例外（不在57条中）
					if (is_in_delayslot_i) begin
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end 
                    else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01101;
				end
				32'h0000000e: begin  // ERET 例外（准确说不叫异常，但通过这个在跳转到epc的同时清零status的EXL）
					status_o[1] <= 1'b0;
				end
				default: /* default */;
			endcase
		end
	end

    // 读 CP0
	always @(*) begin
		if (rst) begin
			data_o = 0;
		end 
        else begin 
			case (raddr_i)
				`CP0_REG_COUNT: begin 
					data_o = count_o;
				end
				`CP0_REG_COMPARE: begin 
					data_o = compare_o;
				end
				`CP0_REG_STATUS: begin 
					data_o = status_o;
				end
				`CP0_REG_CAUSE: begin 
					data_o = cause_o;
				end
				`CP0_REG_EPC: begin 
					data_o = epc_o;
				end
				`CP0_REG_PRID: begin 
					data_o = prid_o;
				end
				`CP0_REG_CONFIG: begin 
					data_o = config_o;
				end
				`CP0_REG_BADVADDR: begin 
					data_o = badvaddr;
				end
				default: begin 
					data_o = 0;
				end
			endcase
		end
	end
	
endmodule

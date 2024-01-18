`timescale 1ns / 1ps
`include "defines.vh"

/*
	模块名称: div
	模块功能: 除法器（试商法）
	输入:
		clk 			时钟信号
		rst 			复位信号
		signed_div_i 	0-无符号除法, 1-有符号除法
		opdata1_i 		32 位被除数
		opdata2_i 		32 位除数
		start_i 		开始除法运算信号
		annul_i 		取消除法运算信号
	输出:
		result_o 		64 位 除法运算结果, 低 32 位为商, 高 32 位为余数
		ready_o 		除法运算结束信号
*/
module div(
	input 	wire 		    clk, rst,
	input 	wire 		    signed_div_i,
	input 	wire[31:0] 	    opdata1_i, opdata2_i,
	input 	wire 		    start_i, annul_i,
	output 	reg [63:0] 	    result_o,
	output 	reg 		    ready_o
	);

	reg [1:0] 			    state;
	reg [5:0] 			    cnt;
	reg [31:0] 			    temp_op1, temp_op2;
	reg [31:0]				a, b;

	// 第 k 次迭代后 
		// dividend[k-1:0] 		保存商的中间结果
		// dividend[k]			无用 (初始把被除数放在 [32:1] 上, 最低位补的 0 无作用)
		// dividend[31:k+1] 	保存被除数中还未参与运算的数据
		// dividend[63:32] 		保存每次迭代时的被减数
	// 迭代结束后
		// dividend[31:0] 		保存商
		// dividend[64:33] 		保存余数
	reg [64:0] 			dividend;

	// 除数
	reg [31:0] 			divisor;

	// 每次迭代时 div_temp = dividend[63:32] - divisor
	wire[32:0] 			div_temp;

	assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor};  // 最高位为符号位

	always @(posedge clk) begin
		if (rst) begin
			state <= `DivFree;
			result_o <= 0;
			ready_o <= 0;
		end
		else begin
			case (state)

				// 00: 除法器空闲
				`DivFree: begin
					if (start_i & ~annul_i) begin
						if (opdata2_i == 0) begin
							state <= `DivByZero;
						end
						else begin
							state <= `DivOn;
							cnt <= 0;

							// 对被除数取补码
							if (signed_div_i & opdata1_i[31] == 1'b1) begin
								temp_op1 = ~opdata1_i + 1;
							end
							else begin
								temp_op1 = opdata1_i;
							end

							// 对除数取补码
							if (signed_div_i & opdata2_i[31] == 1'b1) begin
								temp_op2 = ~opdata2_i + 1;
							end
							else begin
								temp_op2 = opdata2_i;
							end
						end
						dividend <= 0;
						dividend[32:1] <= temp_op1;  // 被除数
						divisor <= temp_op2;  // 除数
						a <= opdata1_i;
						b <= opdata2_i;
					end
					else begin
						result_o <= 0;
						ready_o <= 0;
					end
				end

				// 01: 除数为 0
				`DivByZero: begin
					dividend <= 0;
					state <= `DivEnd;
				end

				// 10: 除法器工作中
				`DivOn: begin
					if (~annul_i) begin

						// 32 位被除数的除法运算需要 32 个时钟周期
						if (cnt != 6'b100000) begin
							cnt <= cnt + 1;
							
							// 被减数 - 除数 < 0
							// 被除数左移一位, 低位补 0
							if (div_temp[32] == 1'b1) begin
								dividend <= {dividend[63:0], 1'b0};
							end

							// 被减数 - 除数 >= 0
							// 中间结果 : 剩余被除数左移一位, 低位补 1
							else begin
								dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
							end
						end
						else begin
							if (signed_div_i & (a[31] ^ b[31] == 1'b1)) begin
								dividend[31:0] <= ~dividend[31:0] + 1;
							end
							if (signed_div_i & (a[31] ^ dividend[64] == 1'b1)) begin
								dividend[64:33] <= ~dividend[64:33] + 1;
							end
							state <= `DivEnd;
							cnt <= 0;
						end
					end
					else begin
						state <= `DivFree;
					end
				end

				// 11: 除法器工作结束
				`DivEnd: begin
					result_o <= {dividend[64:33], dividend[31:0]};
					ready_o <= 1;
					if (~start_i) begin
						state <= `DivFree;
						result_o <= 0;
						ready_o <= 0;
					end
				end

			endcase
		end
	end

endmodule
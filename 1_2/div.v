`timescale 1ns / 1ps
`include "defines.vh"

module div(
	/*
		ģ������: div
		ģ�鹦��: ������
		����:
			clk 			ʱ���ź�
			rst 			��λ�ź�
			signed_div_i 	0-�޷��ų���, 1-�з��ų���
			opdata1_i 		32 λ ������
			opdata2_i 		32 λ ����
			start_i 		�������������ź�
			annul_i 		ȡ�����������ź�
		���:
			result_o 		64 λ ����������, �� 32 λΪ��, �� 32 λΪ����
			ready_o 		������������ź�
	*/
	input 	wire 		    clk, rst,
	input 	wire 		    signed_div_i,
	input 	wire[31:0] 	    opdata1_i, opdata2_i,
	input 	wire 		    start_i, annul_i,
	output 	reg [63:0] 	    result_o,
	output 	reg 		    ready_o
	);

	reg [1:0] 			    state;
	reg [5:0] 			    cnt;
	reg [31:0] 			    temp_op1;
	reg [31:0] 			    temp_op2;

	// �� k �ε����� 
		// dividend[k-1:0] 		�����̵��м���
		// dividend[k]			���� (��ʼ�ѱ��������� [32:1] ��, ���λ���� 0 ������)
		// dividend[31:k+1] 	���汻�����л�δ�������������
		// dividend[63:32] 		����ÿ�ε���ʱ�ı�����
	// ����������
		// dividend[31:0] 		������
		// dividend[64:33] 		��������
	reg [64:0] 			dividend;

	// ���� = opdata2_i (opdata2 != 0)
	reg [31:0] 			divisor;

	// ÿ�ε���ʱ div_temp = dividend[63:32] - divisor
	wire[32:0] 			div_temp;
	
	assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor};  // ���λΪ����λ

	always @(posedge clk) begin
		if (rst) begin
			state <= `DivFree;
			result_o <= 0;
			ready_o <= 0;
		end
		else begin
			case (state)

				// 00: ����������
				`DivFree: begin
					if (start_i && !annul_i) begin

						// �жϳ����Ƿ�Ϊ 0
						if (opdata2_i == 0) begin
							state <= `DivByZero;
						end
						else begin
							state <= `DivOn;
							cnt <= 0;

							// �Ա�����ȡ����
							if (signed_div_i == 1'b1 && opdata1_i[31] == 1'b1) begin
								temp_op1 = ~opdata1_i + 1;
							end
							else begin
								temp_op1 = opdata1_i;
							end

							// �Գ���ȡ����
							if (signed_div_i == 1'b1 && opdata2_i[31] == 1'b1) begin
								temp_op2 = ~opdata2_i + 1;
							end
							else begin
								temp_op2 = opdata2_i;
							end
						end
						dividend <= 0;
						dividend[32:1] <= temp_op1;  // ������
						divisor <= temp_op2;         // ����
					end
					else begin
						result_o <= 0;
						ready_o <= 0;
					end
				end

				// 01: ����Ϊ 0
				`DivByZero: begin
					dividend <= 0;
					state <= `DivEnd;
				end

				// 10: ������������
				`DivOn: begin
					if (!annul_i) begin

						// 32 λ�������ĳ���������Ҫ 32 ��ʱ������
						if (cnt != 6'b100000) begin
							
							// ������ - ���� < 0
							// ����������һλ, ��λ�� 0
							if (div_temp[32] == 1'b1) begin
								dividend <= {dividend[63:0], 1'b0};
							end

							// ������ - ���� >= 0
							// �м��� : ʣ�౻��������һλ, ��λ�� 1
							else begin
								dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
							end
							cnt <= cnt + 1;
						end
						else begin
							if ((signed_div_i == 1'b1) && (opdata1_i[31] ^ opdata2_i[31] == 1'b1)) begin
								dividend[31:0] <= ~dividend[31:0] + 1;
							end
							if ((signed_div_i == 1'b1) && (opdata1_i[31] ^ dividend[64] == 1'b1)) begin
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

				// 11: ��������������
				`DivEnd: begin
					result_o <= {dividend[64:33], dividend[31:0]};
					ready_o <= 1;
					if (!start_i) begin
						state <= `DivFree;
						result_o <= 0;
						ready_o <= 0;
					end
				end

			endcase
		end
	end

endmodule
`timescale 1ns / 1ps
`include "defines.vh"

module alu(
	input 	wire[31:0] 	a, b,
	input   wire[4:0]   shamt,
	input 	wire[5:0] 	op,
	output 	reg [31:0] 	y,
	output 	reg 		overflow
    );

	always @(*) begin
		y = 0;
		case (op)
			`alu_add: 		y = a + b;
			`alu_sub: 		y = a - b;
			`alu_slt: 		y = $signed(a) < $signed(b) ? 1 : 0;
			`alu_sltu: 		y = a < b ? 1 : 0;
			`alu_and: 		y = a & b;
			`alu_nor: 		y = ~(a | b);
			`alu_or: 		y = a | b;
			`alu_xor: 		y = a ^ b;
			`alu_sllv: 		y = b << a[4:0];
			`alu_sll: 		y = b << shamt;
			`alu_srav: 		y = $signed(b) >>> a[4:0];
			`alu_sra: 		y = $signed(b) >>> shamt;
			`alu_srlv: 		y = b >> a[4:0];
			`alu_srl: 		y = b >> shamt;
			`alu_LUI:		y = {b[15:0], 16'b0};
			
			default:		y = 0;
		endcase
	end

	// 检测溢出
	wire[31:0] s, tempb;
	wire temp;
	
	assign tempb = (op == `alu_sub) ? ~b : b;
	assign temp = (op == `alu_sub) ? 1 : 0;
	assign s = a + tempb + temp;  // 计算 a-b: 将 b 所有位取反后 +1

	always @(*) begin
		overflow = 1'b0;
		case (op)
			`alu_add: overflow = a[31] & b[31] & ~s[31] |  // a>0, b>0, s<0
								 ~a[31] & ~b[31] & s[31];  // a<0, b<0, s>0

			`alu_sub: overflow = ~a[31] & b[31] & s[31] |  // a<0, b>0, s>0
								 a[31] & ~b[31] & ~s[31];  // a>0, b<0, s<0

			default: overflow = 1'b0;
		endcase
	end

endmodule

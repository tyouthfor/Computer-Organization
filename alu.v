`timescale 1ns / 1ps
`include "defines.vh"

module alu(
	input 	wire[31:0] 	a, b,
	input   wire[4:0]   shamt,
	input 	wire[5:0] 	op,
	output 	reg [31:0] 	y,
	output 	reg 		overflow,
	output 	wire 		zero
    );

	wire[31:0] s, bout;
	assign bout = op[2] ? ~b : b;  // op[2]: 1-减法, 0-其他
	assign s = a + bout + op[2];   // 计算 a-b: 将 b 所有位取反后 +1
	assign zero = 1'b0;

	always @(*) begin
		case (op)
			`alu_add: 		y <= a + b;
			`alu_sub: 		y <= a - b;
			`alu_slt: 		y <= $signed(a) < $signed(b) ? a : b;
			`alu_sltu: 		y <= a < b ? a : b;
			`alu_mult: 		y <= $signed(a) * $signed(b);
			`alu_multu: 	y <= {32'b0, a} * {32'b0, b};
			`alu_and: 		y <= a & b;
			`alu_nor: 		y <= ~(a | b);
			`alu_or: 		y <= a | b;
			`alu_xor: 		y <= a ^ b;
			`alu_sllv: 		y <= b << a[4:0];
			`alu_sll: 		y <= b << shamt;
			`alu_srav: 		y <= b >>> a[4:0];
			`alu_sra: 		y <= b >>> shamt;
			`alu_srlv: 		y <= b >> a[4:0];
			`alu_srl: 		y <= b >> shamt;
			`alu_LUI:		y <= {b[15:0], 16'b0};
		endcase
	end

	always @ (*) begin
		overflow <= 1'b0;
	end

	// // 溢出
	// always @(*) begin
	// 	case (op[2:1])
	// 		// a+b
	// 		2'b01: overflow <= a[31] & b[31] & ~s[31] |  // a>0, b>0, s<0
	// 						~a[31] & ~b[31] & s[31];     // a<0, b<0, s>0
	// 		// a-b
	// 		2'b11: overflow <= ~a[31] & b[31] & s[31] |  // a<0, b>0, s>0
	// 						a[31] & ~b[31] & ~s[31];     // a>0, b<0, s<0
	// 		default: overflow <= 1'b0;
	// 	endcase	
	// end
endmodule

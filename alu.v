`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu(
	input wire[31:0] a,b,
	input wire[2:0] op,
	output reg[31:0] y,
	output reg overflow,
	output wire zero
    );

	wire[31:0] s,bout;
	assign bout = op[2] ? ~b : b;  // op[2]: 1-减法, 0-其他
	assign s = a + bout + op[2];   // 计算 a-b: 将 b 所有位取反后 +1
	always @(*) begin
		case (op[1:0])
			2'b00: y <= a & bout;
			2'b01: y <= a | bout;
			2'b10: y <= s;
			2'b11: y <= s[31];
			default : y <= 32'b0;
		endcase	
	end
	assign zero = (y == 32'b0);

	// 溢出
	always @(*) begin
		case (op[2:1])
			// a+b
			2'b01: overflow <= a[31] & b[31] & ~s[31] |  // a>0, b>0, s<0
							~a[31] & ~b[31] & s[31];     // a<0, b<0, s>0
			// a-b
			2'b11: overflow <= ~a[31] & b[31] & s[31] |  // a<0, b>0, s>0
							a[31] & ~b[31] & ~s[31];     // a>0, b<0, s<0
			default: overflow <= 1'b0;
		endcase	
	end
endmodule

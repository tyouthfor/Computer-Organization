`timescale 1ns / 1ps
`include "defines.vh"

module eqcmp(
	input 	wire[31:0] 	a, b,
	input   wire[5:0]  op,
	input   wire[4:0]  rt,
	output 	reg 		y
    );
    	
	always@ (*) begin
		case (op)
			`op_BEQ: y = (a == b) ? 1:0;
			`op_BGTZ: y = ((a[31] == 0) && (a != 32'b0)) ? 1:0;
			`op_BLEZ: y = ((a[31] == 1) || (a == 32'b0)) ? 1:0;
			`op_BNE: y = (a != b) ? 1:0; 
			//BLTZ BLTZAL BGEZ BGEZAL
			6'b000_001: case(rt)
			5'b00001: y = (a[31] == 0) ? 1:0;
			5'b00000: y = (a[31] == 1) ? 1:0;
			5'b10001: y = (a[31] == 0) ? 1:0;
			5'b10000: y = (a[31] == 1) ? 1:0;
			endcase
//			`op_BLTZ: y = (a[31] == 1) ? 1:0;
//			`op_BLTZAL: y = (a[31] == 1) ? 1:0;
//			`op_BGEZ: y = (a[31] == 0) ? 1:0;
//			`op_BGEZAL: y = (a[31] == 0) ? 1:0;
		default: y = 0;
		endcase
	end

endmodule

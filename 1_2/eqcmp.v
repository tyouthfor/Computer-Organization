`timescale 1ns / 1ps
`include "defines.vh"

module eqcmp(
	input 	wire[31:0] 		a, b,
	input   wire[5:0]  		op,
	input   wire[4:0]  		rt,
	output 	reg 			y
    );
    	
	always@ (*) begin
		case (op)
			`op_BEQ:  y <= (a == b) ? 1 : 0;
			`op_BNE:  y <= (a != b) ? 1 : 0;
			`op_BGTZ: y <= ($signed(a) > 0) ? 1 : 0;
			`op_BLEZ: y <= ($signed(a) <= 0) ? 1 : 0;
			6'b000001: case (rt)
				5'b00001: y <= ($signed(a) >= 0) ? 1 : 0;  // BGEZ
				5'b00000: y <= ($signed(a) < 0) ? 1 : 0;   // BLTZ
				5'b10001: y <= ($signed(a) >= 0) ? 1 : 0;  // BGEZAL
				5'b10000: y <= ($signed(a) < 0) ? 1 : 0;   // BLTZAL
				default: y <= 0;
			endcase
			default: y <= 0;
		endcase
	end

endmodule

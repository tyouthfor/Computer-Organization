`timescale 1ns / 1ps

module mux5 #(parameter WIDTH = 8)(
	input 	wire[WIDTH-1:0] 	d0, d1, d2, d3, d4,
	input 	wire[2:0] 			s,
	output 	wire[WIDTH-1:0] 	y
    );

	assign y = (s == 3'b000) ? d0 :
			   (s == 3'b001) ? d1 :
			   (s == 3'b010) ? d2 : 
               (s == 3'b011) ? d3 : 
               (s == 3'b100) ? d4 : d0;
			   
endmodule
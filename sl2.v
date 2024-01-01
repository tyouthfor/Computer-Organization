`timescale 1ns / 1ps

module sl2(
	input 	wire[31:0] 	a,
	output 	wire[31:0] 	y
    );

<<<<<<< HEAD
	assign y = {a[29:0],2'b00};
=======
	assign y = {a[29:0], 2'b00};
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
	
endmodule

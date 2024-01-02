`timescale 1ns / 1ps

module signext(
	/*
		ģ������: signext
		ģ�鹦��: ��������չ
		����:
			a 		16 λ������
			op 		0-�޷�����չ, 1-������չ
		���:
			y 		32 λ���
	*/
	input 	wire[15:0] 	a,
	input	wire		op,
	output 	wire[31:0] 	y
    );

	assign y = op ? {{16{a[15]}}, a} : {16'b0, a};

endmodule

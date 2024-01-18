`timescale 1ns / 1ps

/*
	ģ������: mux4
	ģ�鹦��: ��·ѡ����
	����:
		d0			2'b00-����
		d1			2'b01-����
		d2			2'b10-����
		d3			2'b11-����
		s			ѡ���ź�
	���:
		y			ѡ������
*/
module mux4 #(parameter WIDTH = 8)(
	input 	wire[WIDTH-1:0] 	d0, d1, d2, d3,
	input 	wire[1:0] 			s,
	output 	wire[WIDTH-1:0] 	y
    );

	assign y = (
		(s == 2'b00) ? d0 :
		(s == 2'b01) ? d1 :
		(s == 2'b10) ? d2 : 
        (s == 2'b11) ? d3 : d0
	);
	
endmodule
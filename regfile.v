`timescale 1ns / 1ps

module regfile(
	/*
		ģ������: regfile
		ģ�鹦��: �Ĵ�����
		����:
			clk 	ʱ���ź�
			we3 	д�ź�
			ra1 	���Ĵ�����-1
			ra2	 	���Ĵ�����-2
			wa3 	д�Ĵ�����
			wd3		д������
		���:
			rd1 	��������-1
			rd2 	��������-2
	*/
	input 	wire 		clk,
	input 	wire 		we3,
	input 	wire[4:0] 	ra1, ra2, wa3,
	input 	wire[31:0] 	wd3,
	output 	wire[31:0] 	rd1, rd2
    );

	reg[31:0] rf[31:0];

	always @(negedge clk) begin
		if (we3) begin
			rf[wa3] <= wd3;
		end
	end

	assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
	assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

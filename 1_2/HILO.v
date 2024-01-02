`timescale 1ns / 1ps
`include "defines.vh"

module HILO(
	/*
		ģ������: HILO
		ģ�鹦��: HILO �Ĵ���
		����:
			clk 	ʱ���ź�
			we 	    д�ź�
			wd		д������
		���:
            rd      ��������
	*/
	input 	wire 		clk,
    input 	wire 		we,
	input 	wire[31:0] 	wd,
	output 	wire[31:0] 	rd
    );

	reg[31:0] register;

    always @(negedge clk) begin
        if (we) begin
            register <= wd;
        end
    end

    assign rd = register;

endmodule

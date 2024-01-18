`timescale 1ns / 1ps

/*
    模块名称: mmu
    模块功能: 将访问 ram 的虚地址转换为物理地址, 并判断是否经过 d_cache
    输入:
        inst_vaddr          访问 inst ram 的虚地址
        data_vaddr          访问 data ram 的虚地址
    输出:
        inst_paddr          访问 inst ram 的物理地址
        data_paddr          访问 data ram 的物理地址
        no_dcache           当访问 data ram 的物理地址来自外设而非存储器时置 1, 不经过 d_cache
*/
module mmu (
    input   wire[31:0]      inst_vaddr,
    input   wire[31:0]      data_vaddr,
    output  wire[31:0]      inst_paddr,
    output  wire[31:0]      data_paddr,
    output  wire            no_dcache
    );

    wire inst_kseg0, inst_kseg1;
    wire data_kseg0, data_kseg1;

    assign inst_kseg0 = inst_vaddr[31:29] == 3'b100;
    assign inst_kseg1 = inst_vaddr[31:29] == 3'b101;
    assign data_kseg0 = data_vaddr[31:29] == 3'b100;
    assign data_kseg1 = data_vaddr[31:29] == 3'b101;

    assign inst_paddr = inst_kseg0 | inst_kseg1 ? {3'b0, inst_vaddr[28:0]} : inst_vaddr;
    assign data_paddr = data_kseg0 | data_kseg1 ? {3'b0, data_vaddr[28:0]} : data_vaddr;
    
    assign no_dcache = data_kseg1 ? 1'b1 : 1'b0;

endmodule
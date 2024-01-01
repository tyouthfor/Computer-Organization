// 指令 opcpde 宏定义
`define op_RTYPE        6'b000000
`define op_ADDI         6'b001000
`define op_ADDIU        6'b001001
`define op_SLTI         6'b001010
`define op_SLTIU        6'b001011
`define op_ANDI         6'b001100
`define op_LUI          6'b001111
`define op_ORI          6'b001101
`define op_XORI         6'b001110
`define op_BEQ          6'b000100
`define op_BNE          6'b000101
`define op_BGEZ         6'b000001
`define op_BGTZ         6'b000111
`define op_BLEZ         6'b000110
`define op_BLTZ         6'b000001
`define op_BGEZAL       6'b000001
`define op_BLTZAL       6'b000001
`define op_J            6'b000010
`define op_JAL          6'b000011
`define op_LB           6'b100000
`define op_LBU          6'b100100
`define op_LH           6'b100001
`define op_LHU          6'b100101
`define op_LW           6'b100011
`define op_SB           6'b101000
`define op_SH           6'b101001
`define op_SW           6'b101011
`define op_ERET         6'b010000
`define op_MFC0         6'b010000
`define op_MTC0         6'b010000

// 指令 funct 宏定义
`define funct_ADD       6'b100000
`define funct_ADDU      6'b100001
`define funct_SUB       6'b100010
`define funct_SUBU      6'b100011
`define funct_SLT       6'b101010
`define funct_SLTU      6'b101011
<<<<<<< HEAD
`define funct_DIV       6'b011010
`define funct_DIVU      6'b011011
`define funct_MULT      6'b011000
`define funct_MULTU     6'b011001
=======
`define funct_MULT      6'b011000
`define funct_MULTU     6'b011001
`define funct_DIV       6'b011010
`define funct_DIVU      6'b011011
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9
`define funct_AND       6'b100100
`define funct_NOR       6'b100111
`define funct_OR        6'b100101
`define funct_XOR       6'b100110
`define funct_SLLV      6'b000100
`define funct_SLL       6'b000000
`define funct_SRAV      6'b000111
`define funct_SRA       6'b000011
`define funct_SRLV      6'b000110
`define funct_SRL       6'b000010
`define funct_JR        6'b001000
`define funct_JALR      6'b001001
`define funct_MFHI      6'b010000
`define funct_MFLO      6'b010010
`define funct_MTHI      6'b010001
`define funct_MTLO      6'b010011
`define funct_BREAK     6'b001101
`define funct_SYSCALL   6'b001100

// 二级控制信号 aluop 宏定义
`define aluop_RTYPE     4'b0000
`define aluop_add       4'b0001
`define aluop_sub       4'b0010
`define aluop_slt       4'b0011
`define aluop_sltu      4'b0100
`define aluop_and       4'b0101
`define aluop_LUI       4'b0110
`define aluop_or        4'b0111
`define aluop_xor       4'b1000

// ALU 选择信号宏定义
`define alu_add         6'b000000
`define alu_sub         6'b000001
`define alu_slt         6'b000010
`define alu_sltu        6'b000011
`define alu_div         6'b000100
`define alu_divu        6'b000101
`define alu_mult        6'b000110
`define alu_multu       6'b000111
`define alu_and         6'b001000
`define alu_nor         6'b001001
`define alu_or          6'b001010
`define alu_xor         6'b001011
`define alu_sllv        6'b001100
`define alu_sll         6'b001101
`define alu_srav        6'b001110
`define alu_sra         6'b001111
`define alu_srlv        6'b010000
`define alu_srl         6'b010001
`define alu_LUI         6'b010010

<<<<<<< HEAD
=======
`define DivFree         2'b00
`define DivByZero       2'b01
`define DivOn           2'b10
`define DivEnd          2'b11
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9

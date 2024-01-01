<<<<<<< HEAD
# Computer-Organization

#### 介绍
重庆大学2023秋《硬件综合设计》

#### 进度记录
* 2023/12/26    配置开发环境
* 2023/12/27    用宏定义（defines.vh）重写控制单元，并添加 8 条逻辑运算指令
* 2023/12/28    添加 6 条移位运算指令
* 2023/12/28    添加 4 条数据移动指令与 HILO 寄存器

#### 数据移动指令与 HILO 寄存器的实现

1. HI/LO 寄存器

首先在数据通路的 ID 阶段添加 HI/LO 寄存器，设计 MFHI 指令在 EX 阶段将从 HI 读出的数据写入寄存器堆，MTHI 指令在 WB 阶段将从寄存器堆读出的数据写入 HI。HI/LO 寄存器输入输出端口如下：
* 输入
  * srcaW：写入数据。
  * hiwriteW/lowriteW：写信号。
* 输出
  * hiresultD/loresultD：读出数据。

2. mux

* 在数据通路的 ID 阶段增加一个 mux2 选择 hiresultD（MFHI）与 loresultD（MFLO）。
* 在数据通路的 ID 阶段增加一个 mux2 选择写入寄存器堆的是否为 HI/LO。
* 在数据通路的 EX 阶段增加一个 mux2，解决数据冒险。

3. 新增的控制信号

* 数据通路需要的信号——
  * hilotoregE：选择写入寄存器堆的数据来源，0-ALU/内存，1-HILO。
  * hiorloD：选择 MFHI 或 MFLO，0-MFHI，1-MFLO。
  * hiwriteW：HI 的写信号。
  * lowriteW：LO 的写信号。
  * forwardhiloE：选择写入寄存器堆的数据来源，0-HILO，1-srcaM（数据冒险）。

* 检测冒险需要的信号——
  * hilotoregD
  * hiorloE
  * hiwriteM
  * lowriteM

* 控制单元增加的信号——
  * hilotoregD、hilotoregE
  * hiorloD、hiorloE
  * hiwriteD、hiwriteE、hiwriteM、hiwriteW
  * lowriteD、lowriteE、lowriteM、lowriteW

4. 其他关键点

* 数据移动指令是 R 型指令，而 maindec 中所有 R 型指令产生的控制信号相同。为了在执行移动指令时产生正确的 hilotoreg 等信号，在 maindec 中引入 funct。

#### 参与贡献
1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request
=======
# Computer-Organization

#### 介绍
重庆大学2023秋《硬件综合设计》

#### 进度记录
* 2023/12/26    配置开发环境
* 2023/12/27    用宏定义（defines.vh）重写控制单元，并添加 8 条逻辑运算指令
* 2023/12/28    添加 6 条移位运算指令
* 2023/12/28    添加 4 条数据移动指令与 HILO 寄存器
* 2023/12/30    添加 14 条算术运算指令与乘除法器

#### 参与贡献
1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request
>>>>>>> bd6c523bc0c774f6d9f1648bdb15b37b8b2284a9

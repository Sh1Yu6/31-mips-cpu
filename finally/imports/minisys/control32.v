`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module control32(
   input	[5:0]   Opcode,				// 来自取指单元instruction[31..26]
   input    [5:0]   Function_opcode,    // 来自取指单元r-类型 instructions[5..0]
   output            Jrn,                // 为1表明当前指令是jr
   output            RegDST,                // 为1表明目的寄存器是rd，否则目的寄存器是rt
   output            ALUSrc,                // 为1表明第二个操作数是立即数（beq，bne除外）
   output            MemtoReg,            // 为1表明需要从存储器读数据到寄存器
   output            RegWrite,            // 为1表明该指令需要写寄存器
   output            MemWrite,            // 为1表明该指令需要写存储器
   output            Branch,                // 为1表明是Beq指令
   output            nBranch,            // 为1表明是Bne指令
   output            Jmp,                // 为1表明是J指令
   output            Jal,                // 为1表明是Jal指令
   output            I_format,            // 为1表明该指令是除beq，bne，LW，SW之外的其他I-类型指令
   output            Sftmd,                // 为1表明是移位指令
   output    [1:0]    ALUOp                // 是R-类型或I_format=1时位1为1, beq、bne指令则位0为1
   );

 
      wire R_format;		// 为1表示是R-类型指令
       wire Lw;            // 为1表示是lw指令
       wire Sw;            // 为1表示是sw指令
   
       // 目标寄存器R-类型为rd, I-类型为rt
       // 1为rd, 0为rt
       assign RegDST = R_format;
       
       // R-类型指令
       assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;        //--00h 
       assign Jrn = R_format? ((Function_opcode==6'b001000)? 1'b1:1'b0):1'b0;
   
       // I-类型的指令除了lw sw beq bnq之外都是001xxx
       assign I_format =  (Opcode==6'b001000 || Opcode==6'b001001 || Opcode==6'b001110 || Opcode==6'b001101 || Opcode==6'b001100 ||             
                           Opcode==6'b001111 || Opcode==6'b001010 || Opcode==6'b001011)? 1'b1:1'b0;      
       assign Lw = (Opcode==6'b100011)? 1'b1:1'b0;  
       assign Sw = (Opcode==6'b101011)? 1'b1:1'b0;
       assign Branch = (Opcode==6'b000100)? 1'b1:1'b0;
       assign nBranch = (Opcode==6'b000101)? 1'b1:1'b0;
       
       // J-类型指令
       assign Jal = (Opcode==6'b000011)? 1'b1:1'b0;
       assign Jmp = (Opcode==6'b000010)? 1'b1:1'b0;
       
       // 根据ALUOp的信号, 决定了ALU作什么操作 
       // 是R－type或需要立即数作32位扩展的指令1位为1,beq、bne指令则0位为1
       // 00(Lw,Sw), 01(beq,bne),10(其他R-类型,I类型指令)
       assign ALUOp = {(R_format || I_format),(Branch || nBranch)};  
       
       // 是否需要写入寄存器
       // R-类型除了jr指令之外,都需要写入rd, I-类型除了sw,beq,bne之外都需要写入rt, J-类型jal需要写入31号寄存器
       assign RegWrite =(R_format&&!Jrn || I_format || Lw || Jal)? 1'b1:1'b0;
   
       // ALUSrc决定了第二个操作数是什么
       // 1为立即数(beq,bne除外)
       assign ALUSrc = (I_format || Lw || Sw)? 1'b1:1'b0;
   
       // 向内存写入
       assign MemWrite =  Sw? 1'b1:1'b0;
       
       // 由内存读出
       assign MemtoReg = Lw? 1'b1:1'b0;
       
       // R-类型 sll, sra, srl, sllv, srav, srlv
       assign Sftmd =  R_format?  
                         ((Function_opcode==6'b000000 || Function_opcode==6'b000010 || Function_opcode==6'b000011 || Function_opcode==6'b000100 ||
                         Function_opcode==6'b000110 || Function_opcode==6'b000111)
                         ? 1'b1:1'b0)
                         :1'b0;
                                



endmodule
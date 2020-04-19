`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module control32(Opcode,Function_opcode, Alu_resultHigh, Jrn,RegDST,ALUSrc,
                MemorIOtoReg,RegWrite,MemRead,MemWrite, IORead,IOWrite, Branch,nBranch,
                Jmp,Jal,I_format,Sftmd,ALUOp);
    input[5:0]   Opcode;            // 来自取指单元instruction[31..26]
    input[5:0]   Function_opcode;  	// r-form instructions[5..0]
    output       Jrn;               //为1表名当前是指令是jr
    output       RegDST;            //为1表名目的寄存器是rd, 否则目的寄存器是rt
    output       ALUSrc;            //为1表名第二个操作数是立即数(beq, bne除外)
    output       MemorIOtoReg;      //为1表名从存储器读取指令到寄存器
    output       RegWrite;          //为1表名写到寄存器
    output       MemWrite;          //为1表名写到存储器
    output       MemRead;           //为1表名从存储器读取
    output       Branch;            //为1表名是beq指令
    output       nBranch;           //为1表名是bne指令
    output       Jmp;               //为1表名是j指令
    output       Jal;               //为1表名是jal指令
    output       I_format;          //为1表名除beq, bne, lw, sw之外的I-form 指令
    output       Sftmd;             //为1表名是移位指令
    output[1:0]  ALUOp;             //R-form或者I_format=1时高位为1, beq,bne指令低位为1
    input [21:0] Alu_resultHigh;    //来自执行单元, Alu_Result
    output       IORead;            //为1表名是IO读
    output       IOWrite;           //为1表名是IO写
    
    wire Jmp,I_format,Jal,Branch,nBranch,Jrn;
    wire R_format,Lw,Sw;

    //目标寄存器是rd还是rt
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;    	//--00h 
    assign RegDST = R_format;                               //说明目标是rd，否则是rt
    
    //是否要写入寄存器
    assign I_format = (Opcode==6'b001000 || Opcode==6'b001001 || Opcode==6'b001110 || Opcode==6'b001101 || Opcode==6'b001100 ||             
                       Opcode==6'b001111 || Opcode==6'b001010 || Opcode==6'b001011)
                        ? 1'b1:1'b0;                                                    
    assign Lw = (Opcode==6'b100011)? 1'b1:1'b0;
    assign Jal = (Opcode==6'b000011)? 1'b1:1'b0;
    assign Jrn = R_format?  
                ((Function_opcode==6'b001000)? 1'b1:1'b0)
                :1'b0;
    assign RegWrite =(R_format&!Jrn || I_format || Lw || Jal)? 1'b1:1'b0;
    //是否写入存储器
    assign MemWrite = ((Sw) && (Alu_resultHigh != 22'b11_1111_1111_1111_1111_1111) )? 1'b1:1'b0;
    //是否从存储器读
    assign MemRead = ((Lw) && (Alu_resultHigh != 22'b11_1111_1111_1111_1111_1111) )? 1'b1:1'b0;
    //是否写端口
    assign IOWrite = ((Sw) && (Alu_resultHigh == 22'b11_1111_1111_1111_1111_1111) )? 1'b1:1'b0; 
    //是否读端口
    assign IORead = ((Lw) && (Alu_resultHigh == 22'b11_1111_1111_1111_1111_1111) )? 1'b1:1'b0;
    //是否需要从存储器或IO读数据到寄存器
    assign MemorIOtoReg = (IORead || MemRead)? 1'b1:1'b0;
    
     //第二个操作数是否是立即数(beq, bne除外)
     assign Sw = (Opcode==6'b101011)? 1'b1:1'b0;
     assign ALUSrc = (I_format || Lw || Sw)? 1'b1:1'b0;
    
    
    //beq指令
    assign Branch = (Opcode==6'b000100)? 1'b1:1'b0;
    
    //bne指令
    assign nBranch = (Opcode==6'b000101)? 1'b1:1'b0;
    
    //j指令
    assign Jmp = (Opcode==6'b000010)? 1'b1:1'b0;
    
    //移位指令
    wire Sll, Srl, Sra;              
    assign Sftmd = R_format?  
                   ((Function_opcode==6'b000000 || Function_opcode==6'b000010 || Function_opcode==6'b000011 || Function_opcode==6'b000100 ||
                   Function_opcode==6'b000110 || Function_opcode==6'b000111)
                   ? 1'b1:1'b0)
                   :1'b0;
    
    //ALUOp决定了所做的操作
    assign ALUOp = {(R_format || I_format), (Branch || nBranch)};
    
    

endmodule 










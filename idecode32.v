`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Idecode32(read_data_1,read_data_2,Instruction,read_data,ALU_result,
                 Jal,RegWrite,MemorIOtoReg,RegDst,Sign_extend,clock,reset,
                 opcplus4, read_register_1_address);
    output[31:0] read_data_1;               // rs
    output[31:0] read_data_2;               // rt
    input[31:0]  Instruction;
    input[31:0]  read_data;   				//  从DARA RAM 取出的数据
    input[31:0]  ALU_result;   				//  要被写入寄存器的计算结果
    input        Jal;                       // 来自控制单元
    input        RegWrite;                  // 为1写到寄存器
    input        MemorIOtoReg;                  // 为1存储器到寄存器 lw
    input        RegDst;                    // 为1表名目的寄存器是rd, 否则目的寄存器是rt
    output[31:0] Sign_extend;               // 要被输出的扩展后的32位立即数
    input		 clock,reset;
    input[31:0]  opcplus4;                 // 来自取指单元，JAL中用
    output[4:0] read_register_1_address;
    
    wire sign;                             // 取符号为的值
    
    wire[31:0] read_data_1;                 // 从寄存器中读取的数据 
    wire[31:0] read_data_2;                 // 从寄存器中读取的数据 
    reg[31:0] register[0:31];			   //寄存器组共32个32位寄存器
    reg[4:0] write_register_address;        // 要被写入的寄存器的地址
    reg[31:0] write_data;                   //  被写入寄存器的数据
    
    wire[4:0] read_register_1_address;      // rs
    wire[4:0] read_register_2_address;      // rt
    wire[4:0] write_register_address_1;     // rd(r-form)
    wire[4:0] write_register_address_0;     // rt(i_form)
    wire[15:0] Instruction_immediate_value; // immediate
    wire[5:0] opcode;                       // op 
    
    
    // 指令分离
    assign opcode = Instruction[31:26];
    assign read_register_1_address = Instruction[25:21];      
    assign read_register_2_address = Instruction[20:16];     
    assign write_register_address_1 = Instruction[15:11];     
    assign write_register_address_0 = Instruction[20:16];   
    assign Instruction_immediate_value = Instruction[15:0];
    
    // 寄存器读操作
    assign read_data_1 = register[read_register_1_address];
    assign read_data_2 = register[read_register_2_address];
    
    

    // 选择目标寄存器
    always @* 
    begin                                            
        if(Jal)
            write_register_address <= 5'd31;
        else
        begin
            if(RegDst)
                write_register_address <= write_register_address_1;
            else
                write_register_address <= write_register_address_0;
        end    
    end
    
    // 选择要写入寄存器的数据
    always @* 
    begin  
        if(Jal)
            write_data <= opcplus4;
        else if(MemorIOtoReg)
            write_data <= read_data;
        else
            write_data <= ALU_result;
    end
    
    
    // 写入寄存器
    integer i;
    always @(posedge clock) 
    begin       
        if(reset==1) 
        begin              // 初始化寄存器组
            for(i=0;i<32;i=i+1) 
                register[i] <= 0;
        end 
        else if(RegWrite==1)
        begin  
            if(write_register_address == 5'b00000)
                register[i] <= 0;
            else
                register[write_register_address] <= write_data;
        end
    end
    
    assign sign = Instruction_immediate_value[15];
    assign Sign_extend[31:0] = sign ? {16'hffff, Instruction_immediate_value}: {16'h0000, Instruction_immediate_value};
    
endmodule






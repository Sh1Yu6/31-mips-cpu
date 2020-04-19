`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Idecode32(read_data_1,read_data_2,Instruction,read_data,ALU_result,
                 Jal,RegWrite,MemorIOtoReg,RegDst,Sign_extend,clock,reset,
                 opcplus4, read_register_1_address);
    output[31:0] read_data_1;               // rs
    output[31:0] read_data_2;               // rt
    input[31:0]  Instruction;
    input[31:0]  read_data;   				//  ��DARA RAM ȡ��������
    input[31:0]  ALU_result;   				//  Ҫ��д��Ĵ����ļ�����
    input        Jal;                       // ���Կ��Ƶ�Ԫ
    input        RegWrite;                  // Ϊ1д���Ĵ���
    input        MemorIOtoReg;                  // Ϊ1�洢�����Ĵ��� lw
    input        RegDst;                    // Ϊ1����Ŀ�ļĴ�����rd, ����Ŀ�ļĴ�����rt
    output[31:0] Sign_extend;               // Ҫ���������չ���32λ������
    input		 clock,reset;
    input[31:0]  opcplus4;                 // ����ȡָ��Ԫ��JAL����
    output[4:0] read_register_1_address;
    
    wire sign;                             // ȡ����Ϊ��ֵ
    
    wire[31:0] read_data_1;                 // �ӼĴ����ж�ȡ������ 
    wire[31:0] read_data_2;                 // �ӼĴ����ж�ȡ������ 
    reg[31:0] register[0:31];			   //�Ĵ����鹲32��32λ�Ĵ���
    reg[4:0] write_register_address;        // Ҫ��д��ļĴ����ĵ�ַ
    reg[31:0] write_data;                   //  ��д��Ĵ���������
    
    wire[4:0] read_register_1_address;      // rs
    wire[4:0] read_register_2_address;      // rt
    wire[4:0] write_register_address_1;     // rd(r-form)
    wire[4:0] write_register_address_0;     // rt(i_form)
    wire[15:0] Instruction_immediate_value; // immediate
    wire[5:0] opcode;                       // op 
    
    
    // ָ�����
    assign opcode = Instruction[31:26];
    assign read_register_1_address = Instruction[25:21];      
    assign read_register_2_address = Instruction[20:16];     
    assign write_register_address_1 = Instruction[15:11];     
    assign write_register_address_0 = Instruction[20:16];   
    assign Instruction_immediate_value = Instruction[15:0];
    
    // �Ĵ���������
    assign read_data_1 = register[read_register_1_address];
    assign read_data_2 = register[read_register_2_address];
    
    

    // ѡ��Ŀ��Ĵ���
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
    
    // ѡ��Ҫд��Ĵ���������
    always @* 
    begin  
        if(Jal)
            write_data <= opcplus4;
        else if(MemorIOtoReg)
            write_data <= read_data;
        else
            write_data <= ALU_result;
    end
    
    
    // д��Ĵ���
    integer i;
    always @(posedge clock) 
    begin       
        if(reset==1) 
        begin              // ��ʼ���Ĵ�����
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






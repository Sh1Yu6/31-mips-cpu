`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Ifetc32(clock,reset,Instruction,PC_plus_4_out,Add_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jrn,Zero,opcplus4);

    input			reset;				// ��λ�ź�(�ߵ�ƽ��Ч)
    input           clock;             
    output[31:0] Instruction;			// ���ָ��
    output[31:0] PC_plus_4_out;         // (pc+4)��ִ�е�Ԫ
    input[31:0]  Add_result;            // ����ִ�е�Ԫ,�������ת��ַ
    input[31:0]  Read_data_1;           // �������뵥Ԫ��jrָ���õĵ�ַ
    input        Branch;                // ���Կ��Ƶ�Ԫ
    input        nBranch;               // ���Կ��Ƶ�Ԫ
    input        Jmp;                   // ���Կ��Ƶ�Ԫ
    input        Jal;                   // ���Կ��Ƶ�Ԫ
    input        Jrn;                   // ���Կ��Ƶ�Ԫ
    input        Zero;                  // ���Կ��Ƶ�Ԫ
    output[31:0] opcplus4;              // JALָ��ר�õ�PC+4

    
    wire[31:0]   PC_plus_4;
    reg[31:0]	  PC;
    reg[31:0]    next_PC; 
    wire[31:0]   Jpadr;
    reg[31:0]    opcplus4;
    
    my_rom rom(clock, PC, Jpadr);          // ��romȡָ��

    assign Instruction = Jpadr;              //  ȡ��ָ��

    // PC+4
    assign PC_plus_4[31:2] =  PC[31:2] + 1'b1 ;
    assign PC_plus_4[1:0] = 2'b00;
    assign PC_plus_4_out = PC_plus_4;
    
    // beq bne jr ��ת
    always @* 
    begin                         
        if(Branch && Zero || nBranch && !Zero)
            next_PC = Add_result<<2;
        else if(Jrn)
            next_PC = Read_data_1<<2;
        else 
            next_PC = PC_plus_4;
    end
    
    // �޸�pc (����j, jalָ���reset�Ĵ���)
    always @(negedge clock) 
    begin
         if(reset)
             begin
                PC <= 32'h0000_0000;
             end
         else
            begin
                if(Jal)
                    begin
                        opcplus4 <= PC_plus_4;
                        PC[31:0] <= {4'b0000,Instruction[25:0], 2'b00};
                    end
                else if(Jmp)
                   PC[31:0] <= {4'b0000,Instruction[25:0], 2'b00};
                else
                    PC <= next_PC;
            end   
    end
endmodule

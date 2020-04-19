`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Ifetc32(Instruction,PC_plus_4_out,Add_result,Read_data_1,Branch,nBranch,
                Jmp,Jal,Jrn,Zero,clock,reset,opcplus4);
                
    output[31:0] Instruction;		// ���ָ��
    output[31:0] PC_plus_4_out;     // PC+4���        
    input[31:0]  Add_result;        // ����ִ�е�Ԫ, �����ת�ĵ�ַ
    input[31:0]  Read_data_1;       // �������뵥Ԫ, jrָ���õ���ת��ַ
    input        Branch;            // ���Կ��Ƶ�Ԫ, beqָ��
    input        nBranch;           // ���Կ��Ƶ�Ԫ, bneָ��
    input        Jmp;               // ���Կ��Ƶ�Ԫ, jָ��
    input        Jal;               // ���Կ��Ƶ�Ԫ, jalָ��
    input        Jrn;               // ���Կ��Ƶ�Ԫ, jrָ��
    input        Zero;              // ����ִ�е�Ԫ, ˵��������Ϊ0
    input        clock,reset;
    output[31:0] opcplus4;          // jalָ��ר��

    
    wire[31:0]   PC_plus_4;         // PC+4
    reg[31:0]	  PC;               // 
    reg[31:0]    next_PC;           // ��һ��ָ���PC
    wire[31:0]   Jpadr;
    reg[31:0]    opcplus4;
    
   //����64KB ROM��������ʵ��ֻ�� 64KB ROM
    prgrom instmem(
        .clka(clock),         // input wire clka
        .addra(PC[15:2]),     // 64K��ַ��С 
        .douta(Jpadr)         // output wire [31 : 0] douta
    );
 
    assign Instruction = Jpadr;              //  ȡ��ָ��

    // PC+4
    assign PC_plus_4[31:2] =  PC[31:2] + 1'b1 ;
    assign PC_plus_4[1:0] = 2'b00;
    assign PC_plus_4_out = PC_plus_4;
    
    // beq bne jr ��ת
    always @* 
    begin                         
        if(Branch && Zero || nBranch && !Zero)
            next_PC <= Add_result ;
        else if(Jrn)
            next_PC <= Read_data_1;
        else 
            next_PC <= PC_plus_4 >>2;
    end
    
    // �޸�pc (����j, jalָ���reset�Ĵ���)
    always @(negedge clock) 
    begin
         if(reset)
         begin
            opcplus4 <= 32'h0000_0000;
            PC <= 32'h0000_0000;
         end
         else
         begin
            if(Jal)
            begin
                opcplus4 <= PC_plus_4 >> 2;
                PC[31:0] <= {4'b0000,Instruction[25:0], 2'b00};
            end
            else if(Jmp)
                PC[31:0] <= {4'b0000,Instruction[25:0], 2'b00};
            else
                PC <= next_PC << 2;
          end
            
    end
    
endmodule

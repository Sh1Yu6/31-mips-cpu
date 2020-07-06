`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Ifetc32(clock,reset,Instruction,PC_plus_4_out,Add_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jrn,Zero,opcplus4);

    input			reset;				// 复位信号(高电平有效)
    input           clock;             
    output[31:0] Instruction;			// 输出指令
    output[31:0] PC_plus_4_out;         // (pc+4)送执行单元
    input[31:0]  Add_result;            // 来自执行单元,算出的跳转地址
    input[31:0]  Read_data_1;           // 来自译码单元，jr指令用的地址
    input        Branch;                // 来自控制单元
    input        nBranch;               // 来自控制单元
    input        Jmp;                   // 来自控制单元
    input        Jal;                   // 来自控制单元
    input        Jrn;                   // 来自控制单元
    input        Zero;                  // 来自控制单元
    output[31:0] opcplus4;              // JAL指令专用的PC+4

    
    wire[31:0]   PC_plus_4;
    reg[31:0]	  PC;
    reg[31:0]    next_PC; 
    wire[31:0]   Jpadr;
    reg[31:0]    opcplus4;
    
    my_rom rom(clock, PC, Jpadr);          // 从rom取指令

    assign Instruction = Jpadr;              //  取出指令

    // PC+4
    assign PC_plus_4[31:2] =  PC[31:2] + 1'b1 ;
    assign PC_plus_4[1:0] = 2'b00;
    assign PC_plus_4_out = PC_plus_4;
    
    // beq bne jr 跳转
    always @* 
    begin                         
        if(Branch && Zero || nBranch && !Zero)
            next_PC = Add_result<<2;
        else if(Jrn)
            next_PC = Read_data_1<<2;
        else 
            next_PC = PC_plus_4;
    end
    
    // 修改pc (包括j, jal指令和reset的处理)
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

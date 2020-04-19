`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Ifetc32(Instruction,PC_plus_4_out,Add_result,Read_data_1,Branch,nBranch,
                Jmp,Jal,Jrn,Zero,clock,reset,opcplus4);
                
    output[31:0] Instruction;		// 输出指令
    output[31:0] PC_plus_4_out;     // PC+4输出        
    input[31:0]  Add_result;        // 来自执行单元, 算出跳转的地址
    input[31:0]  Read_data_1;       // 来自译码单元, jr指令用的跳转地址
    input        Branch;            // 来自控制单元, beq指令
    input        nBranch;           // 来自控制单元, bne指令
    input        Jmp;               // 来自控制单元, j指令
    input        Jal;               // 来自控制单元, jal指令
    input        Jrn;               // 来自控制单元, jr指令
    input        Zero;              // 来自执行单元, 说明运算结果为0
    input        clock,reset;
    output[31:0] opcplus4;          // jal指令专用

    
    wire[31:0]   PC_plus_4;         // PC+4
    reg[31:0]	  PC;               // 
    reg[31:0]    next_PC;           // 下一条指令的PC
    wire[31:0]   Jpadr;
    reg[31:0]    opcplus4;
    
   //分配64KB ROM，编译器实际只用 64KB ROM
    prgrom instmem(
        .clka(clock),         // input wire clka
        .addra(PC[15:2]),     // 64K地址大小 
        .douta(Jpadr)         // output wire [31 : 0] douta
    );
 
    assign Instruction = Jpadr;              //  取出指令

    // PC+4
    assign PC_plus_4[31:2] =  PC[31:2] + 1'b1 ;
    assign PC_plus_4[1:0] = 2'b00;
    assign PC_plus_4_out = PC_plus_4;
    
    // beq bne jr 跳转
    always @* 
    begin                         
        if(Branch && Zero || nBranch && !Zero)
            next_PC <= Add_result ;
        else if(Jrn)
            next_PC <= Read_data_1;
        else 
            next_PC <= PC_plus_4 >>2;
    end
    
    // 修改pc (包括j, jal指令和reset的处理)
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

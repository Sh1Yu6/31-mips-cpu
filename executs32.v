`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Executs32(Read_data_1,Read_data_2,Sign_extend,Function_opcode,Exe_opcode,ALUOp,
                 Shamt,ALUSrc,I_format, Zero,Sftmd,ALU_Result,Add_Result,PC_plus_4
                 );
    input[31:0]  Read_data_1;		// 来自译码单元 r-form rs
    input[31:0]  Read_data_2;		// 来自译码单元 r-form rt
    input[31:0]  Sign_extend;		// 来自译码单元 扩展后的立即数 i-form
    input[5:0]   Function_opcode;  	// 来自取指单元, R-类型指令功能
    input[5:0]   Exe_opcode;  		// 来自取指单元, 操作码
    input[1:0]   ALUOp;
    input[4:0]   Shamt;             // 来自取指单元, 指令[10:6] 指定位移次数
    input  		 Sftmd;             // 1表名是移位指令
    input        ALUSrc;            // 来自控制单元, 为1表名第二个数是立即数(beq, bne除外)
    input        I_format;          // 来自控制单元, 为1表名是除了beq,bne,lw,sw之外的I-类型指令
    output       Zero;              // 表名1则为0;
    output[31:0] ALU_Result;        // 运算结果
    output[31:0] Add_Result;		// 计算的地址结果       
    input[31:0]  PC_plus_4;         // 来自取指单元, PC+4

    reg[31:0] ALU_Result;
    wire[31:0] Ainput,Binput;
    reg[31:0] ALU_output_mux;
    wire[32:0] Branch_Add;
    
    wire[2:0] ALU_ctl;             // 组合码
    wire[5:0] Exe_code;            // 操作符
    
    wire[2:0] Sftm;                 // 位移指令类型
    reg[31:0] Sinput;               // 移位指令的最后结果
    
    wire Sftmd;
    
   
    assign Sftm = Function_opcode[2:0];   // 移位的类型, 后三位就能区别

    // 移位运算
    // verilog 逻辑运算 >> << , 算术运算 >>>
    always @* 
    begin  // 6种移位指令
       if(Sftmd)
        case(Sftm)
            3'b000:Sinput <= Read_data_2 << Shamt;			    //Sll rd,rt,shamt  00000
            3'b010:Sinput <= Read_data_2 >> Shamt;		        //Srl rd,rt,shamt  00010
            3'b100:Sinput <= Read_data_2 << Read_data_1;         //Sllv rd,rt,rs 000100
            3'b110:Sinput <= Read_data_2 >> Read_data_1;         //Srlv rd,rt,rs 000110
            3'b011:Sinput <= Read_data_2 >>> Shamt;         	    //Sra rd,rt,shamt 00011
            3'b111:Sinput <= Read_data_2 >>> Read_data_1;		//Srav rd,rt,rs 00111
            default:Sinput <= Binput;
        endcase
       else Sinput <= Binput;
    end
 
 
    // 最终计算赋值
    always @* 
    begin
        if(((ALU_ctl==3'b111) && (Exe_code[3]==1))||             // slti(sub)  处理所有SLT类的问题
            ((ALU_ctl[2:1]==2'b11) && (I_format==1)))
            ALU_Result <=  (ALU_output_mux < 0) ? 32'h0000_0001:32'h0000_0000 ;    
        else if((ALU_ctl==3'b101) && (I_format==1))             // lui
            ALU_Result[31:0] <= {Binput[15:0], 16'h0000_0000}  ;
        else if(Sftmd==1)                                       // 移位
            ALU_Result <=  Sinput ; 
        else                                                    //其他
            ALU_Result <= ALU_output_mux[31:0]; 
    end
    
    
    // bne和beq 跳转地址计算
    assign Branch_Add = PC_plus_4[31:2] + Sign_extend[31:0];
    assign Add_Result = Branch_Add[31:0];   
    assign Zero = (ALU_output_mux[31:0]== 32'h00000000) ? 1'b1 : 1'b0;
    
    
    
    
    assign Ainput = Read_data_1;                               // A端口
    assign Binput = (ALUSrc == 0) ? Read_data_2 : Sign_extend[31:0];        // B端口
    
    // R类型则结果为功能码, 否则为操作码后三位(方便后面计算)
    assign Exe_code = (I_format==0) ? Function_opcode : {3'b000,Exe_opcode[2:0]}; 
    
    // 组合码, 因为有很多运算都是相同的, 如addi 和 add, 而我们的A, B输入都是经过处理的, 就没必要分别计算了 
    // 所以让相同运算的指令有相同的组合码
    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1];      //24H AND 
    assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
    assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];
    
    // 算出运算结果
    always @(ALU_ctl or Ainput or Binput) 
    begin
        case(ALU_ctl)
            3'b000:ALU_output_mux <= Ainput & Binput;               // and, andi
            3'b001:ALU_output_mux <= Ainput | Binput;               // or, ori    
            3'b010:ALU_output_mux <= Ainput + Binput;                // lw, sw , add, addi
            3'b011:ALU_output_mux <= Ainput + Binput;                // addu, addiu
            3'b100:ALU_output_mux <= Ainput ^ Binput;                // xor, xori
            3'b101:ALU_output_mux <= ~(Ainput | Binput);                // nor, lui, 
            3'b110:ALU_output_mux <= Ainput - Binput;                // sub, slti, beq, bne
            3'b111:ALU_output_mux <= Ainput - Binput;                // subu, sltiu, slt, sltu 
            default:ALU_output_mux <= 32'h00000000;
        endcase
    end
endmodule




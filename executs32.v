`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Executs32(Read_data_1,Read_data_2,Sign_extend,Function_opcode,Exe_opcode,ALUOp,
                 Shamt,ALUSrc,I_format, Zero,Sftmd,ALU_Result,Add_Result,PC_plus_4
                 );
    input[31:0]  Read_data_1;		// �������뵥Ԫ r-form rs
    input[31:0]  Read_data_2;		// �������뵥Ԫ r-form rt
    input[31:0]  Sign_extend;		// �������뵥Ԫ ��չ��������� i-form
    input[5:0]   Function_opcode;  	// ����ȡָ��Ԫ, R-����ָ���
    input[5:0]   Exe_opcode;  		// ����ȡָ��Ԫ, ������
    input[1:0]   ALUOp;
    input[4:0]   Shamt;             // ����ȡָ��Ԫ, ָ��[10:6] ָ��λ�ƴ���
    input  		 Sftmd;             // 1��������λָ��
    input        ALUSrc;            // ���Կ��Ƶ�Ԫ, Ϊ1�����ڶ�������������(beq, bne����)
    input        I_format;          // ���Կ��Ƶ�Ԫ, Ϊ1�����ǳ���beq,bne,lw,sw֮���I-����ָ��
    output       Zero;              // ����1��Ϊ0;
    output[31:0] ALU_Result;        // ������
    output[31:0] Add_Result;		// ����ĵ�ַ���       
    input[31:0]  PC_plus_4;         // ����ȡָ��Ԫ, PC+4

    reg[31:0] ALU_Result;
    wire[31:0] Ainput,Binput;
    reg[31:0] ALU_output_mux;
    wire[32:0] Branch_Add;
    
    wire[2:0] ALU_ctl;             // �����
    wire[5:0] Exe_code;            // ������
    
    wire[2:0] Sftm;                 // λ��ָ������
    reg[31:0] Sinput;               // ��λָ��������
    
    wire Sftmd;
    
   
    assign Sftm = Function_opcode[2:0];   // ��λ������, ����λ��������

    // ��λ����
    // verilog �߼����� >> << , �������� >>>
    always @* 
    begin  // 6����λָ��
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
 
 
    // ���ռ��㸳ֵ
    always @* 
    begin
        if(((ALU_ctl==3'b111) && (Exe_code[3]==1))||             // slti(sub)  ��������SLT�������
            ((ALU_ctl[2:1]==2'b11) && (I_format==1)))
            ALU_Result <=  (ALU_output_mux < 0) ? 32'h0000_0001:32'h0000_0000 ;    
        else if((ALU_ctl==3'b101) && (I_format==1))             // lui
            ALU_Result[31:0] <= {Binput[15:0], 16'h0000_0000}  ;
        else if(Sftmd==1)                                       // ��λ
            ALU_Result <=  Sinput ; 
        else                                                    //����
            ALU_Result <= ALU_output_mux[31:0]; 
    end
    
    
    // bne��beq ��ת��ַ����
    assign Branch_Add = PC_plus_4[31:2] + Sign_extend[31:0];
    assign Add_Result = Branch_Add[31:0];   
    assign Zero = (ALU_output_mux[31:0]== 32'h00000000) ? 1'b1 : 1'b0;
    
    
    
    
    assign Ainput = Read_data_1;                               // A�˿�
    assign Binput = (ALUSrc == 0) ? Read_data_2 : Sign_extend[31:0];        // B�˿�
    
    // R��������Ϊ������, ����Ϊ���������λ(����������)
    assign Exe_code = (I_format==0) ? Function_opcode : {3'b000,Exe_opcode[2:0]}; 
    
    // �����, ��Ϊ�кܶ����㶼����ͬ��, ��addi �� add, �����ǵ�A, B���붼�Ǿ��������, ��û��Ҫ�ֱ������ 
    // ��������ͬ�����ָ������ͬ�������
    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1];      //24H AND 
    assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
    assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];
    
    // ���������
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




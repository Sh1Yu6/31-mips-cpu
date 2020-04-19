`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module control32(Opcode,Function_opcode, Alu_resultHigh, Jrn,RegDST,ALUSrc,
                MemorIOtoReg,RegWrite,MemRead,MemWrite, IORead,IOWrite, Branch,nBranch,
                Jmp,Jal,I_format,Sftmd,ALUOp);
    input[5:0]   Opcode;            // ����ȡָ��Ԫinstruction[31..26]
    input[5:0]   Function_opcode;  	// r-form instructions[5..0]
    output       Jrn;               //Ϊ1������ǰ��ָ����jr
    output       RegDST;            //Ϊ1����Ŀ�ļĴ�����rd, ����Ŀ�ļĴ�����rt
    output       ALUSrc;            //Ϊ1�����ڶ�����������������(beq, bne����)
    output       MemorIOtoReg;      //Ϊ1�����Ӵ洢����ȡָ��Ĵ���
    output       RegWrite;          //Ϊ1����д���Ĵ���
    output       MemWrite;          //Ϊ1����д���洢��
    output       MemRead;           //Ϊ1�����Ӵ洢����ȡ
    output       Branch;            //Ϊ1������beqָ��
    output       nBranch;           //Ϊ1������bneָ��
    output       Jmp;               //Ϊ1������jָ��
    output       Jal;               //Ϊ1������jalָ��
    output       I_format;          //Ϊ1������beq, bne, lw, sw֮���I-form ָ��
    output       Sftmd;             //Ϊ1��������λָ��
    output[1:0]  ALUOp;             //R-form����I_format=1ʱ��λΪ1, beq,bneָ���λΪ1
    input [21:0] Alu_resultHigh;    //����ִ�е�Ԫ, Alu_Result
    output       IORead;            //Ϊ1������IO��
    output       IOWrite;           //Ϊ1������IOд
    
    wire Jmp,I_format,Jal,Branch,nBranch,Jrn;
    wire R_format,Lw,Sw;

    //Ŀ��Ĵ�����rd����rt
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;    	//--00h 
    assign RegDST = R_format;                               //˵��Ŀ����rd��������rt
    
    //�Ƿ�Ҫд��Ĵ���
    assign I_format = (Opcode==6'b001000 || Opcode==6'b001001 || Opcode==6'b001110 || Opcode==6'b001101 || Opcode==6'b001100 ||             
                       Opcode==6'b001111 || Opcode==6'b001010 || Opcode==6'b001011)
                        ? 1'b1:1'b0;                                                    
    assign Lw = (Opcode==6'b100011)? 1'b1:1'b0;
    assign Jal = (Opcode==6'b000011)? 1'b1:1'b0;
    assign Jrn = R_format?  
                ((Function_opcode==6'b001000)? 1'b1:1'b0)
                :1'b0;
    assign RegWrite =(R_format&!Jrn || I_format || Lw || Jal)? 1'b1:1'b0;
    //�Ƿ�д��洢��
    assign MemWrite = ((Sw) && (Alu_resultHigh != 22'b11_1111_1111_1111_1111_1111) )? 1'b1:1'b0;
    //�Ƿ�Ӵ洢����
    assign MemRead = ((Lw) && (Alu_resultHigh != 22'b11_1111_1111_1111_1111_1111) )? 1'b1:1'b0;
    //�Ƿ�д�˿�
    assign IOWrite = ((Sw) && (Alu_resultHigh == 22'b11_1111_1111_1111_1111_1111) )? 1'b1:1'b0; 
    //�Ƿ���˿�
    assign IORead = ((Lw) && (Alu_resultHigh == 22'b11_1111_1111_1111_1111_1111) )? 1'b1:1'b0;
    //�Ƿ���Ҫ�Ӵ洢����IO�����ݵ��Ĵ���
    assign MemorIOtoReg = (IORead || MemRead)? 1'b1:1'b0;
    
     //�ڶ����������Ƿ���������(beq, bne����)
     assign Sw = (Opcode==6'b101011)? 1'b1:1'b0;
     assign ALUSrc = (I_format || Lw || Sw)? 1'b1:1'b0;
    
    
    //beqָ��
    assign Branch = (Opcode==6'b000100)? 1'b1:1'b0;
    
    //bneָ��
    assign nBranch = (Opcode==6'b000101)? 1'b1:1'b0;
    
    //jָ��
    assign Jmp = (Opcode==6'b000010)? 1'b1:1'b0;
    
    //��λָ��
    wire Sll, Srl, Sra;              
    assign Sftmd = R_format?  
                   ((Function_opcode==6'b000000 || Function_opcode==6'b000010 || Function_opcode==6'b000011 || Function_opcode==6'b000100 ||
                   Function_opcode==6'b000110 || Function_opcode==6'b000111)
                   ? 1'b1:1'b0)
                   :1'b0;
    
    //ALUOp�����������Ĳ���
    assign ALUOp = {(R_format || I_format), (Branch || nBranch)};
    
    

endmodule 










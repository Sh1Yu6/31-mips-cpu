`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module control32(
   input	[5:0]   Opcode,				// ����ȡָ��Ԫinstruction[31..26]
   input    [5:0]   Function_opcode,    // ����ȡָ��Ԫr-���� instructions[5..0]
   output            Jrn,                // Ϊ1������ǰָ����jr
   output            RegDST,                // Ϊ1����Ŀ�ļĴ�����rd������Ŀ�ļĴ�����rt
   output            ALUSrc,                // Ϊ1�����ڶ�������������������beq��bne���⣩
   output            MemtoReg,            // Ϊ1������Ҫ�Ӵ洢�������ݵ��Ĵ���
   output            RegWrite,            // Ϊ1������ָ����Ҫд�Ĵ���
   output            MemWrite,            // Ϊ1������ָ����Ҫд�洢��
   output            Branch,                // Ϊ1������Beqָ��
   output            nBranch,            // Ϊ1������Bneָ��
   output            Jmp,                // Ϊ1������Jָ��
   output            Jal,                // Ϊ1������Jalָ��
   output            I_format,            // Ϊ1������ָ���ǳ�beq��bne��LW��SW֮�������I-����ָ��
   output            Sftmd,                // Ϊ1��������λָ��
   output    [1:0]    ALUOp                // ��R-���ͻ�I_format=1ʱλ1Ϊ1, beq��bneָ����λ0Ϊ1
   );

 
      wire R_format;		// Ϊ1��ʾ��R-����ָ��
       wire Lw;            // Ϊ1��ʾ��lwָ��
       wire Sw;            // Ϊ1��ʾ��swָ��
   
       // Ŀ��Ĵ���R-����Ϊrd, I-����Ϊrt
       // 1Ϊrd, 0Ϊrt
       assign RegDST = R_format;
       
       // R-����ָ��
       assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;        //--00h 
       assign Jrn = R_format? ((Function_opcode==6'b001000)? 1'b1:1'b0):1'b0;
   
       // I-���͵�ָ�����lw sw beq bnq֮�ⶼ��001xxx
       assign I_format =  (Opcode==6'b001000 || Opcode==6'b001001 || Opcode==6'b001110 || Opcode==6'b001101 || Opcode==6'b001100 ||             
                           Opcode==6'b001111 || Opcode==6'b001010 || Opcode==6'b001011)? 1'b1:1'b0;      
       assign Lw = (Opcode==6'b100011)? 1'b1:1'b0;  
       assign Sw = (Opcode==6'b101011)? 1'b1:1'b0;
       assign Branch = (Opcode==6'b000100)? 1'b1:1'b0;
       assign nBranch = (Opcode==6'b000101)? 1'b1:1'b0;
       
       // J-����ָ��
       assign Jal = (Opcode==6'b000011)? 1'b1:1'b0;
       assign Jmp = (Opcode==6'b000010)? 1'b1:1'b0;
       
       // ����ALUOp���ź�, ������ALU��ʲô���� 
       // ��R��type����Ҫ��������32λ��չ��ָ��1λΪ1,beq��bneָ����0λΪ1
       // 00(Lw,Sw), 01(beq,bne),10(����R-����,I����ָ��)
       assign ALUOp = {(R_format || I_format),(Branch || nBranch)};  
       
       // �Ƿ���Ҫд��Ĵ���
       // R-���ͳ���jrָ��֮��,����Ҫд��rd, I-���ͳ���sw,beq,bne֮�ⶼ��Ҫд��rt, J-����jal��Ҫд��31�żĴ���
       assign RegWrite =(R_format&&!Jrn || I_format || Lw || Jal)? 1'b1:1'b0;
   
       // ALUSrc�����˵ڶ�����������ʲô
       // 1Ϊ������(beq,bne����)
       assign ALUSrc = (I_format || Lw || Sw)? 1'b1:1'b0;
   
       // ���ڴ�д��
       assign MemWrite =  Sw? 1'b1:1'b0;
       
       // ���ڴ����
       assign MemtoReg = Lw? 1'b1:1'b0;
       
       // R-���� sll, sra, srl, sllv, srav, srlv
       assign Sftmd =  R_format?  
                         ((Function_opcode==6'b000000 || Function_opcode==6'b000010 || Function_opcode==6'b000011 || Function_opcode==6'b000100 ||
                         Function_opcode==6'b000110 || Function_opcode==6'b000111)
                         ? 1'b1:1'b0)
                         :1'b0;
                                



endmodule
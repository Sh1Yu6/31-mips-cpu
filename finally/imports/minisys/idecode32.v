`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Idecode32 (
	input			reset,
    input			clock,
    output	[31:0]	read_data_1,	// ����ĵ�һ������
    output	[31:0]	read_data_2,	// ����ĵڶ�������
    input	[31:0]	Instruction,	// ȡָ��Ԫ����ָ��
    input	[31:0]	read_data,		// ��DATA RAM or I/O portȡ��������
    input	[31:0]	ALU_result,		// ��ִ�е�Ԫ��������Ľ������Ҫ��չ��������32λ
    input			Jal,			// ���Կ��Ƶ�Ԫ��˵����JALָ�� 
    input			RegWrite,		// ���Կ��Ƶ�Ԫ
    input			MemtoReg,		// ���Կ��Ƶ�Ԫ
    input			RegDst,			// ���Կ��Ƶ�Ԫ
    output	[31:0]	Sign_extend,	// ���뵥Ԫ�������չ���32λ������
    input	[31:0]	opcplus4		// ����ȡָ��Ԫ��JAL����
);
    
    reg[31:0] register[0:31];			   //�Ĵ����鹲32��32λ�Ĵ���
    
    reg[4:0] write_register_address;        // Ҫд��ļĴ����ĺ�
    reg[31:0] write_data;                   // Ҫд�Ĵ��������ݷ�����

    wire[4:0] read_register_1_address;    // Ҫ���ĵ�һ���Ĵ����ĺţ�rs��
    wire[4:0] read_register_2_address;     // Ҫ���ĵڶ����Ĵ����ĺţ�rt��
    
    wire[4:0] write_register_address_1;   // r-formָ��Ҫд�ļĴ����ĺţ�rd��
    wire[4:0] write_register_address_0;    // i-formָ��Ҫд�ļĴ����ĺ�(rt)
    
    wire[15:0] Instruction_immediate_value;  // ָ���е�������
    wire[5:0] opcode;                       // ָ����
    
    wire sign;                                            // ȡ����λ��ֵ
      
    // ָ�����
    assign opcode = Instruction[31:26];	//OP
    assign read_register_1_address = Instruction[25:21];//rs 
    assign read_register_2_address = Instruction[20:16];//rt 
    assign write_register_address_1 = Instruction[15:11];// rd(r-form)
    assign write_register_address_0 = Instruction[20:16];//rt(i-form)
    assign Instruction_immediate_value = Instruction[15:0];//data,rladr(i-form)
   
    // �Ĵ���������
    assign read_data_1 = register[read_register_1_address];
    assign read_data_2 = register[read_register_2_address];
    
    
     // ѡ��Ŀ��Ĵ���
      always @* 
      begin                                            
          if(Jal)
              write_register_address = 5'd31;
          else
          begin
              if(RegDst)
                  write_register_address = write_register_address_1;
              else
                  write_register_address = write_register_address_0;
          end    
      end
      
      // ѡ��Ҫд��Ĵ���������
      always @* 
      begin  
          if(Jal)
              write_data = opcplus4;
          else if(MemtoReg)
              write_data = read_data;
          else
              write_data = ALU_result;
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
      
      // ������չ
      assign sign = Instruction_immediate_value[15];
      
      // andi ori xori sltiu j jal ��չ, ����������չ
      assign Sign_extend[31:0] = (opcode==6'b001100||opcode==6'b001101||opcode==6'b001110
                                ||opcode==6'b001011||opcode==6'b000010||opcode==6'b000011)
                                ?{16'd0,Instruction_immediate_value}
                               :(sign?{16'd65535,Instruction_immediate_value}:{16'd0,Instruction_immediate_value});
endmodule

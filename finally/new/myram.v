`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/05 11:00:38
// Design Name: 
// Module Name: myram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module my_ram(
       output reg [31:0] read_data,
       input [3:0] address,     //����ִ�е�Ԫ�����alu_result
       input [31:0] write_data,  //�������뵥Ԫ��read_data2
       input  Memwrite,         //���Կ��Ƶ�Ԫ
       input  clock
    );
    
    // 16k ram
     reg [31:0] ramdata [0:3]; 
     always @(posedge clock) 
        #2 begin                            //�ӳ�2ns�ȵ�ַ�ȶ� 
             if(Memwrite==1)                     
                    ramdata[address[3:0]] <= write_data;
         end
         
     always @(*) //���˿�
         begin
             read_data <= ramdata[address[3:0]];
         end
     
endmodule

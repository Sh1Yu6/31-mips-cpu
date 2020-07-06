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
       input [3:0] address,     //来自执行单元算出的alu_result
       input [31:0] write_data,  //来自译码单元的read_data2
       input  Memwrite,         //来自控制单元
       input  clock
    );
    
    // 16k ram
     reg [31:0] ramdata [0:3]; 
     always @(posedge clock) 
        #2 begin                            //延迟2ns等地址稳定 
             if(Memwrite==1)                     
                    ramdata[address[3:0]] <= write_data;
         end
         
     always @(*) //读端口
         begin
             read_data <= ramdata[address[3:0]];
         end
     
endmodule

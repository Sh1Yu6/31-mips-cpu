`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module top(reset,clock,switch,result);
    input reset;               
    input clock;              
    input[3:0] switch;    
    output[31:0] result;      
    
    wire[31:0] write_data;   //写RAM或IO的数据
    wire[31:0] read_data;        //读RAM或IO的数据
    wire[31:0] pc_plus_4;    //PC+4
    wire[31:0] read_data_1;  //
    wire[31:0] read_data_2;  //
    wire[31:0] sign_extend;  //符号扩展
    wire[31:0] add_result;   //
    wire[31:0] alu_result;   //
    wire[31:0] address;
    wire alusrc;
    wire branch;
    wire nbranch,jmp,jal,jrn,i_format;
    wire regdst;
    wire regwrite;
    wire zero;
    wire memwrite;
    wire memtoreg;   
    wire sftmd;
    wire[1:0] aluop;
    wire[31:0] instruction;
    wire[31:0] opcplus4;
   
          
        Ifetc32 ifetch(
            clock, reset,instruction, pc_plus_4, add_result, read_data_1, 
            branch, nbranch, jmp, jal, jrn, zero,opcplus4
        );
    
        Idecode32 idecode(
            reset,clock,read_data_1, read_data_2, instruction, read_data, alu_result,
            jal,regwrite,memtoreg,regdst,sign_extend,opcplus4
        );
    
        control32 control(
            instruction[31:26],instruction[5:0], jrn, regdst, alusrc,
            memtoreg, regwrite, memwrite,branch, nbranch,jmp, jal, i_format, sftmd, aluop
        );
              
        Executs32 execute(
            read_data_1, read_data_2, sign_extend, instruction[5:0], instruction[31:26], aluop,
            instruction[10:6], alusrc, i_format, zero, sftmd, alu_result, add_result, pc_plus_4
         );
         
       assign write_data= read_data_2;
       assign  address = alu_result;
       IOManage iomanage(
            read_data, alu_result, write_data, memwrite, clock,switch, result
        );
        
       
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module IOManage(
    output[31:0] read_data,  // ���ڴ��I/O��ȡ����
    input[31:0] address,     // ����ִ�е�Ԫ�����alu_result
    input[31:0] write_data,  // �������뵥Ԫ��read_data2
    input  Memwrite,         // ���Կ��Ƶ�Ԫ
    input  clock,
    input [3:0] switch,
    output reg [31:0] result
    );
    
    reg [31:0] in_data, out_data;
    wire [31:0] ram_data_out;
    wire ram_we;

    assign ram_we = Memwrite&(~address[4]);                     // �ж��Ƿ�д��ram
           
    my_ram ram(ram_data_out, address[3:0], write_data, ram_we, clock);   
                          
    assign read_data = address[5]?{{28{1'b0}}, switch}: ram_data_out;       // ��I/O����ram��ȡ����
    
    always @(posedge clock)
        begin
            if((address[4] == 1'b1)&&Memwrite)
                result <= write_data;
        end
    
endmodule

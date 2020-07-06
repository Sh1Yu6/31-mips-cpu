`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module IOManage(
    output[31:0] read_data,  // 从内存或I/O读取数据
    input[31:0] address,     // 来自执行单元算出的alu_result
    input[31:0] write_data,  // 来自译码单元的read_data2
    input  Memwrite,         // 来自控制单元
    input  clock,
    input [3:0] switch,
    output reg [31:0] result
    );
    
    reg [31:0] in_data, out_data;
    wire [31:0] ram_data_out;
    wire ram_we;

    assign ram_we = Memwrite&(~address[4]);                     // 判断是否写入ram
           
    my_ram ram(ram_data_out, address[3:0], write_data, ram_we, clock);   
                          
    assign read_data = address[5]?{{28{1'b0}}, switch}: ram_data_out;       // 从I/O或者ram读取数据
    
    always @(posedge clock)
        begin
            if((address[4] == 1'b1)&&Memwrite)
                result <= write_data;
        end
    
endmodule

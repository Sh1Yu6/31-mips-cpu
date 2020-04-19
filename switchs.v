`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module switchs(switclk, switrst, switchread, switchcs, switchaddr, 
                switchrdata, switch_i);
    input switclk;                  // ʱ���ź�
    input switrst;                  // ��λ�ź�
    input switchcs;                 // ��memorio����, �ɵ�����λ�³ǵ�switchƬѡ�ź�
    
    input [1:0] switchaddr;         // ��switchģ��ĵ�ַ�Ͷ�
    input switchread;               // ���ź�
    output [15:0] switchrdata;      // �͵�cpu�Ĳ��뿪��ֵ
            
    input [23:0] switch_i;          // �Ӱ��϶���24λ���ݿ���
    
    reg [15:0] switchrdata;

    always@(negedge switclk or posedge switrst) 
    begin
        if(switrst) 
        begin
            switchrdata <= 0;
        end
        else if(switchcs && switchread) 
        begin
            if(switchaddr==2'b00)
                switchrdata[15:0] <= switch_i[15:0];   
            else if(switchaddr==2'b10)
                switchrdata[15:0] <= { 8'h00, switch_i[23:16] }; 
             else 
                switchrdata <= switchrdata;
        end
        else 
        begin
            switchrdata <= switchrdata;
        end
    end
endmodule





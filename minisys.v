`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module minisys(prst,pclk,led2N4,switch2N4);
    input prst;               //���ϵ�Reset�źţ��͵�ƽ��λ
    input pclk;               //���ϵ�100MHzʱ���ź�
    input[23:0] switch2N4;    //���뿪������
    output[23:0] led2N4;      //led��������Nexys4
    
    wire clock;              //clock: ��Ƶ��ʱ�ӹ���ϵͳ
    wire iowrite,ioread;     //I/O��д�ź�
    wire[31:0] write_data;   //дRAM��IO������
    wire[31:0] rdata;        //��RAM��IO������
    wire[15:0] ioread_data;  //��IO������
    wire[31:0] pc_plus_4;    //PC+4
    wire[31:0] read_data_1;  //
    wire[31:0] read_data_2;  //
    wire[31:0] sign_extend;  //������չ
    wire[31:0] add_result;   //
    wire[31:0] alu_result;   //
    wire[31:0] read_data;    //RAM�ж�ȡ������
    wire[31:0] address;
    wire alusrc;
    wire branch;
    wire nbranch,jmp,jal,jrn,i_format;
    wire regdst;
    wire regwrite;
    wire zero;
    wire memwrite;
    wire memread;
    wire memoriotoreg;
    wire memreg;
    wire sftmd;
    wire[1:0] aluop;
    wire[31:0] instruction;
    wire[31:0] opcplus4;
    wire[4:0] read_register_1_address;
    wire ledctrl,switchctrl;
    wire[15:0] ioread_data_switch;
    
    cpuclk cpuclk(
        .clk_in1(pclk),    //100MHz
        .clk_out1(clock)    //cpuclock
    );
   
    Ifetc32 ifetch(
        instruction, pc_plus_4, add_result, read_data_1, branch, nbranch, 
        jmp, jal, jrn, zero, clock, prst, opcplus4
    );

    Idecode32 idecode(
        read_data_1, read_data_2, instruction, rdata, alu_result,
        jal,regwrite,memoriotoreg,regdst,sign_extend,clock,prst,
        opcplus4, read_register_1_address
    );

    control32 control(
        instruction[31:26],instruction[5:0], alu_result[31:10], jrn, regdst, alusrc,
        memoriotoreg, regwrite, memread, memwrite, ioread, iowrite, branch, nbranch,
        jmp, jal, i_format, sftmd, aluop
    );
          
    Executs32 execute(
        read_data_1, read_data_2, sign_extend, instruction[5:0], instruction[31:26], aluop,
        instruction[10:6], alusrc, i_format, zero, sftmd, alu_result, add_result, pc_plus_4
     );
    
    dmemory32 memory(
        read_data, address, write_data, memwrite, clock
    );
            
    memorio memio(
        alu_result, address, memread, memwrite, ioread, 
        iowrite, read_data, ioread_data, read_data_2, rdata, write_data, ledctrl, switchctrl
    );
    
    ioread multiioread(
        prst, clock, ioread, switchctrl, ioread_data, ioread_data_switch
    );
 
    leds led16(
        clock, prst, iowrite, ledctrl, address[1:0], write_data[15:0], led2N4
     );
     
     switchs switch16(
        clock, prst, ioread, switchctrl, address[1:0], ioread_data_switch, switch2N4
     );
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module my_rom (
	input			clock,		// ROM clock
	input	[31:0]	PC,		    // 指令地址
	output	[31:0]	Jpadr			    // 取出的指令
);
    reg [31:0] rom_data;
    always @(posedge clock)
     #1 case(PC[31:2])                   // 延迟1ns等地址稳定后再从rom取数据

     
            28'h0:  rom_data <= 32'h34100000;    // ori $s0, $0, 0
            28'h1:  rom_data <= 32'h34110001;    // ori $s1, $0, 1
            //28'h2:  rom_data <= 32'h34120010;    // ori $s2, $0, 16
            28'h2:  rom_data <= 32'h8c120020;    // ori $s2, $0, 16
            28'h3:  rom_data <= 32'h02204025;    // or $t0, $s1, $0
            28'h4:  rom_data <= 32'h02308820;    // add $s1, $s1, $s0
            28'h5:  rom_data <= 32'h01008025;    // or $s0, $t0, $0
            28'h6:  rom_data <= 32'h2252ffff;    // addi $s2, $s2, -1
            28'h7:  rom_data <= 32'h1412fffb;    // bne $0, $s2, s
           // 28'h8:  rom_data <= 32'h00102025;    // or $a0, $0, $s0
            28'h8:  rom_data <= 32'hac100010;    // or $a0, $0, $s0
        default: rom_data = 32'h0000_0000;
        endcase
        
    assign Jpadr = rom_data;
	
endmodule

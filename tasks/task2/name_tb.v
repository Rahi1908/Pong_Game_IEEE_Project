`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.12.2025 23:17:28
// Design Name: 
// Module Name: name_tb
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


module name_tb;
    reg clk;
    reg rst;
    wire [3:0] red;
    wire [3:0] blue;
    wire [3:0] grn;
    wire hsync;
    wire vsync;
    
    name dut ( .clk(clk) , .rst(rst), .red(red) , .blue(blue), .grn(grn), .hsync(hsync) , .vsync(vsync) );
    
    initial 
    begin
    clk = 0;
    forever #5 clk = ~clk ;
    end
    
    initial
    begin
    rst = 1;
    #100 rst = 0;
    #20000000 $stop ;
    end
endmodule

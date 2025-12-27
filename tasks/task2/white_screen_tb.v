`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.12.2025 15:24:32
// Design Name: 
// Module Name: white_screen_tb
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


module white_screen_tb;
    reg clk;
    reg rst;
    wire [3:0] red;
    wire [3:0] blue;
    wire [3:0] grn;
    wire hsync;
    wire vsync;
    
    white_screen dut ( .clk(clk) , .rst(rst), .red(red) , .blue(blue), .grn(grn), .hsync(hsync) , .vsync(vsync) );
    
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

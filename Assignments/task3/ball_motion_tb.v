`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.12.2025 12:00:54
// Design Name: 
// Module Name: ball_motion_tb
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


module ball_motion_tb;
reg clk;
reg rst;
wire [3:0] vga_r;
wire [3:0] vga_b;
wire [3:0] vga_g;
wire hsync;
wire vsync;

ball_motion dut ( .clk(clk), .rst(rst), .vga_r(vga_r), .vga_b(vga_b), .vga_g(vga_g), .hsync(hsync), .vsync(vsync) );

initial 
 begin
    clk = 0;
    forever #5 clk = ~clk;
 end
 
initial 
 begin
  rst = 1;
  #50 rst = 0;
 #20000000
  $stop;
 end
endmodule

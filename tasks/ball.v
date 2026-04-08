`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2025 12:41:16
// Design Name: 
// Module Name: ball
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


module ball(
input clk,
input rst,
output [3:0] vga_r,
output [3:0] vga_b,
output [3:0] vga_g,
output hsync,
output vsync,
input [15:0] h,
input [15:0] k
    );
    
    reg [3:0] red;
    reg [3:0] blue;
    reg [3:0] grn;
    wire [15:0] h_count;
    wire [15:0] v_count;
   
   vga_controller ball_color ( .clk(clk) , .rst(rst) , .red(red) , .blue(blue) , .grn(grn)
      , .vga_r(vga_r) , .vga_b(vga_b) , .vga_g(vga_g) , .hsync(hsync) , .vsync(vsync) , 
      .h_count(h_count) , .v_count(v_count) );
      
   wire signed [16:0] x;
   wire signed [16:0] y;
   wire signed [34:0] z;
   
   assign x = $signed(h_count) - $signed(h);
   assign y = $signed(v_count) - $signed(k);
   assign z = (x*x) + (y*y);
      
   always @ (*)
    begin
     if ( z <= 35'sd1600 )
      begin
       red = 4'b1111;
       blue = 4'b0000;
       grn = 4'b0000;
      end
     else
      begin
      red = 4'b0000;
      blue = 4'b0000;
      grn = 4'b0000;
      end
    end 
   
endmodule

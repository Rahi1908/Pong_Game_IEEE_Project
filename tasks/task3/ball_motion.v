`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.12.2025 10:52:12
// Design Name: 
// Module Name: ball_motion
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


module ball_motion(
input clk,
input rst,
output [3:0] vga_r,
output [3:0] vga_b,
output [3:0] vga_g,
output hsync,
output vsync
    );
    
 parameter R = 16'd40;  // Radius of ball 40 px
 wire clk_50HZ;        // clock for ball's motion
 reg signed [16:0] h;        // x co-ordinate of center of the ball
 reg signed [16:0] k;       // y co-ordinate of center of the ball
 reg signed [1:0] dx;  // dx and dy are direction vectors 
 reg signed [1:0] dy;
 wire signed [16:0] h_next = h + dx;
 wire signed [16:0] k_next = k + dy;
    
 clk_divider_50Hz clk_gen ( .clk(clk) , .rst(rst) , .clk_50HZ(clk_50HZ) );
 
 ball uut ( .clk(clk), .rst(rst), .vga_r(vga_r), .vga_b(vga_b), .vga_g(vga_g), .hsync(hsync), 
      .vsync(vsync), .h(h), .k(k) );
      
 always @ (posedge clk_50HZ or posedge rst)
  begin
   if(rst)
    begin
     h <= 17'sd200; // Initialising center of ball as (200,200)px
     k <= 17'sd200;
     dx <= 17'sd1;
     dy <= 17'sd1;
    end
   else
    begin
      if ((k_next - R <= 0) || (k_next + R >= 479))
        dy <= -dy;
      if ((h_next - R <= 0) || (h_next + R >=639))
       dx <= -dx;
      
       h <= h_next; // updating the direction of motion
       k <= k_next;
       
    end
  end
  
 
endmodule

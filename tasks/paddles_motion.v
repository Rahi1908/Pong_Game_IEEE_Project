`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.01.2026 10:27:43
// Design Name: 
// Module Name: paddles_motion
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


module paddles_motion(
input clk,
input rst,
input lu,  // left paddle up motion assigned to P17
input ld,  // left paddle down motion assigned to P18
input ru,  // right paddle up motion assigned to M18
input rd,  // right paddle down motion assigned to M17
output [3:0] vga_r,
output [3:0] vga_b,
output [3:0] vga_g,
output hsync,
output vsync
    );
    
   wire clk_50HZ;  
   reg signed [16:0] lm; // Left paddle mid point
   reg signed [16:0] rm; // Right paddle mid point
   reg signed [16:0] vy_l; // velocity of left paddle in y direction 
   reg signed [16:0] vy_r; // velocity of right paddle in y direction
  
   
   clk_divider_50Hz clk_gen ( .clk(clk) , .rst(rst) , .clk_50HZ(clk_50HZ) );
   
   paddles dut ( .clk(clk), .rst(rst), .vga_r(vga_r), .vga_b(vga_b), .vga_g(vga_g), .hsync(hsync), 
      .vsync(vsync), .lm(lm) , .rm(rm) );
   
   always @ (posedge clk_50HZ or posedge rst)
    begin
     if (rst)
      begin
       lm <= 17'sd240;
       rm <= 17'sd240;
       vy_l <= 17'sd0;
       vy_r <= 17'sd0;
      end
     else
      begin
      
      // ------------LEFT PADDLE-----------------
      
       if (lu && !ld)
        begin
         if (lm + vy_l <= 17'sd50) // if collide on top wall then stop othewise move left paddle up
          vy_l <= 0;
         else
          vy_l <= -17'sd1;
        end
        
      else if (ld && !lu)
        begin
         if (lm + 17'sd50 >= 17'sd479) // if collide on bottom wall then stop othewise move left paddle down
          vy_l <= 0;
         else
          vy_l <= 17'sd1;
        end
      else
       vy_l <= 17'sd0;
       
        // ------------RIGHT PADDLE-----------------
        
       if (ru && !rd)
        begin
         if (rm + vy_r <= 17'sd50) // if collide on top wall then stop othewise move right paddle up
          vy_r <= 0;
         else
          vy_r <= -17'sd1;
        end
        
      else if (rd && !ru)
        begin
         if (rm + 17'sd50 >= 17'sd479) // if collide on bottom wall then stop othewise move right paddle down
          vy_r <= 0;
         else
          vy_r <= 17'sd1;
        end
      else
       vy_r <= 17'sd0;
        
       lm <= lm + vy_l;   //update the position of left paddle
       rm <= rm + vy_r;   //update the position of right paddle
      end
    end   
   
   
endmodule

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

/*

//                     ---------------
    //--------------------/PADDLES MOTION/--------------------------
    //                    ---------------
    
    
    always @ (posedge clk_60HZ or posedge rst)
    begin
     if (rst)
      begin
       lm <= 17'sd240;
       rm <= 17'sd240;
       vy_l <= 17'sd0;
       vy_r <= 17'sd0;
      end
     else if(!game_start)
      begin
      
      if(AI_mode)
        begin
            if (dx < 0) 
                begin  // ball coming towards AI
                     if ( (hard_mode && h < 615) || (!hard_mode && h < 200) ) 
                        begin
                            if (k < lm)
                                begin
                                    if (lm + vy_l <= p1_half + 17'sd7) // if collide on top wall then stop othewise move left paddle up
                                    vy_l <= 0;
                                    else
                                    vy_l <= -17'sd1;
                                end
                            else if (k > lm)
                                begin
                                    if (lm + p1_half >= 17'sd472) // if collide on bottom wall then stop othewise move left paddle down
                                    vy_l <= 0;
                                    else
                                    vy_l <= 17'sd1;
                                    end
                            else vy_l <= 0;
                        end
                     else 
                        begin
                            vy_l <= 0; // idle
                        end
                end 
            else 
                begin
                    vy_l <= 0; // ball going away
                end
      end
      
      else begin
      // ------------LEFT PADDLE-----------------
      
       if (lu && !ld)
        begin
         if (lm + vy_l <= p1_half + 17'sd7) // if collide on top wall then stop othewise move left paddle up
          vy_l <= 0;
         else
          vy_l <= -17'sd1;
        end
        
      else if (ld && !lu)
        begin
         if (lm + p1_half >= 17'sd472) // if collide on bottom wall then stop othewise move left paddle down
          vy_l <= 0;
         else
          vy_l <= 17'sd1;
        end
      else
       vy_l <= 17'sd0;
     end 
        // ------------RIGHT PADDLE-----------------
        
       if (ru && !rd)
        begin
         if (rm + vy_r <= p2_half + 17'sd7) // if collide on top wall then stop othewise move right paddle up
          vy_r <= 0;
         else
          vy_r <= -17'sd1;
        end
        
      else if (rd && !ru)
        begin
         if (rm + p2_half >= 17'sd472) // if collide on bottom wall then stop othewise move right paddle down
          vy_r <= 0;
         else
          vy_r <= 17'sd1;
        end
      else
       vy_r <= 17'sd0;
       
       lm <= lm + (vy_l * speed_y);   //update the position of left paddle
       rm <= rm + (vy_r * speed_y) ;   //update the position of right paddle
      end
    end    
    
*/

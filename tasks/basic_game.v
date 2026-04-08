`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2026 10:55:59
// Design Name: 
// Module Name: basic_game
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


module basic_game(
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
    
    parameter R = 17'sd40;  // Radius of ball 40 px
    wire clk_50HZ;
    wire [3:0] vga_r1;
    wire [3:0] vga_b1;
    wire [3:0] vga_g1;
    wire [3:0] vga_r2;
    wire [3:0] vga_b2;
    wire [3:0] vga_g2;
    reg signed [16:0] h;        // x co-ordinate of center of the ball
    reg signed [16:0] k;        // y co-ordinate of center of the ball
    reg signed [16:0] dx;        // dx and dy are direction vectors 
    reg signed [16:0] dy;
    wire signed [16:0] h_next = h + dx; 
    wire signed [16:0] k_next = k + dy;
    wire signed [16:0] a;
    wire signed [16:0] b;
    wire signed [16:0] c;
    wire signed [16:0] d;
    
    
    clk_divider_50Hz clk_gen ( .clk(clk) , .rst(rst) , .clk_50HZ(clk_50HZ) );
    
    paddles_motion include_paddle ( .clk(clk), .rst(rst), .vga_r(vga_r1), .vga_b(vga_b1), .vga_g(vga_g1), .hsync(hsync), 
      .vsync(vsync), .lu(lu), .ld(ld), .ru(ru), .rd(rd) , .a(a) , .b(b) , .c(c) , .d(d) );
      
    ball include_ball ( .clk(clk), .rst(rst), .vga_r(vga_r2), .vga_b(vga_b2), .vga_g(vga_g2), .hsync(hsync), 
      .vsync(vsync), .h(h), .k(k) );
      
    assign vga_r = vga_r1 | vga_r2;
    assign vga_b = vga_b1 | vga_b2;
    assign vga_g = vga_g1 | vga_g2;
    
    
  always @ (posedge clk_50HZ or posedge rst)
  begin
   if(rst)
    begin
     h <= 17'sd320; // Initialising center of ball as (320,240)px
     k <= 17'sd240;
     dx <= 17'sd1;
     dy <= 17'sd1;
    end
   else
    begin
      if ((k_next - R <= 0) || (k_next + R >= 479))
        dy <= -dy;
        
       if (((h_next - R <= 19) && (k_next + R >= a && k_next - R <= b )) 
         ||
          ((h_next + R >= 621) && (k_next + R >= c && k_next - R <= d )))
        dx <= -dx;
        
      if ((h_next - R <= 0) || (h_next + R >=639))
       begin
        h <= 17'sd320; // Initialising center of ball as (320,240)px
        k <= 17'sd240;
        dx <= 17'sd1;
        dy <= 17'sd1;
       end
      else
       begin 
        h <= h_next; // updating the direction of motion
        k <= k_next;
       end
    end
  end
   
endmodule

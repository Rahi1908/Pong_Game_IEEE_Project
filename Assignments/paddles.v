`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.01.2026 09:29:33
// Design Name: 
// Module Name: paddles
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


module paddles(
input clk,
input rst,
input signed [16:0] lm, // midpoint of a left paddle
input signed [16:0] rm, // midpoint of a right paddle
output [3:0] vga_r,
output [3:0] vga_b,
output [3:0] vga_g,
output hsync,
output vsync
    );
   
    reg [3:0] red;
    reg [3:0] blue;
    reg [3:0] grn;
    wire [15:0] h_count;
    wire [15:0] v_count;
    wire [16:0] a; // top of the left paddle
    wire [16:0] b; // bottom of the left paddle
    wire [16:0] c; // top of the right paddle
    wire [16:0] d; // bottom of the right paddle
    
    vga_controller u_vga ( .clk(clk) , .rst(rst) , .red(red) , .blue(blue) , .grn(grn)
      , .vga_r(vga_r) , .vga_b(vga_b) , .vga_g(vga_g) , .hsync(hsync) , .vsync(vsync) , 
      .h_count(h_count) , .v_count(v_count) );
      
    
    assign a = lm - 17'd50;
    assign b = lm + 17'd50;
    assign c = rm - 17'd50;
    assign d = rm + 17'd50;
      
    always @ (*)
     begin
      if ( (($signed(v_count) >= a && $signed(v_count) <= b) && ($signed(h_count) >= 9 && $signed(h_count) <= 19))         // left paddle
           || 
           (($signed(v_count) >= c && $signed(v_count) <= d) && ($signed(h_count) >= 621 && $signed(h_count) <= 631)) )    // right paddle
         begin
          red = 4'b0000;      
          blue = 4'b1111;     // paddles will look blue
          grn = 4'b0000;
         end
       else
        begin
         red = 4'b0000;
         blue = 4'b0000;    // rest of the screen will be black
         grn = 4'b0000;
        end
     end
   
endmodule

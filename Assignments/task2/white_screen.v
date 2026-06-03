`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.12.2025 14:28:41
// Design Name: 
// Module Name: white_screen
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


module white_screen(
    input clk,
    input rst,
    output reg [3:0] vga_r,
    output reg [3:0] vga_b,
    output reg [3:0] vga_g,
    output reg hsync,
    output reg vsync
    );
    
    wire clk_25MHZ;
    wire v_enable;
    wire [15:0] h_count;
    wire [15:0] v_count;
    reg [3:0] red;
    reg [3:0] blue;
    reg [3:0] grn;
    
   clk_divider vga_clk_gen ( clk , rst, clk_25MHZ );
   horizontal_counter vga_h ( clk_25MHZ , rst, v_enable, h_count );
   vertical_counter vga_v ( clk_25MHZ , rst, v_enable, v_count ); 
   
   //outputs hysnc and vsync are active low
   always @ (posedge clk_25MHZ or posedge rst)
   begin
   if (rst)
   begin
   hsync <= 1'b1;
   vsync <= 1'b1;
   end
   else
   begin
   hsync <= (h_count >= 656 && h_count <= 751) ? 1'b0 : 1'b1;
   vsync <= (v_count >= 490 && v_count <= 491) ? 1'b0 : 1'b1;
   end
   end
   
   //colors- all high = white screen
   always @ (posedge clk_25MHZ or posedge rst)
   begin
    if (rst)
     begin
      vga_r <= 0;
      vga_b <= 0;
      vga_g <= 0;
     end
   else
    begin
     if (h_count <= 639 && v_count <=479)
      begin
       vga_r <= red;
       vga_b <= blue;
       vga_g <= grn;
      end
     else
      begin
       vga_r <= 0;
       vga_b <= 0;
       vga_g <= 0;
      end
    end
   end
  
  //  If you used continuous assignments to red green and blue which make them wires, 
  // But when we are dealing with collisions we need to have them reg type.
  
  always @ (*)
   begin
    red = (h_count <= 639 && v_count <=479) ? 4'b1111 : 4'b0000;
    blue = (h_count <= 639 && v_count <=479) ? 4'b1111 : 4'b0000;
    grn = (h_count <= 639 && v_count <=479) ? 4'b1111 : 4'b0000;
   end
   
endmodule

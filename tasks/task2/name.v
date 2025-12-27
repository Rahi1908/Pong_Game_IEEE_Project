`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.12.2025 21:25:19
// Design Name: 
// Module Name: name
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


module name(
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
     red = 4'b0000;
   
     if (((v_count >= 181 && v_count <= 204) && ((h_count >= 70 && h_count <= 188) || (h_count >= 229 && h_count <= 347)
     || (h_count >= 389 && h_count <= 412)|| (h_count >= 484 && h_count <= 506)|| (h_count >= 547 && h_count <= 570) ))
     || 
     ((v_count >= 205 && v_count <= 228) && ((h_count >= 70 && h_count <= 93) || (h_count >= 166 && h_count <= 188)
     || (h_count >= 229 && h_count <= 252)|| (h_count >= 325 && h_count <= 347)|| (h_count >= 389 && h_count <= 412) 
     || (h_count >= 484 && h_count <= 506) || (h_count >= 547 && h_count <= 570) ))
     ||
     ((v_count >= 229 && v_count <= 252) && ((h_count >= 70 && h_count <= 188) || (h_count >= 229 && h_count <= 347)
     || (h_count >= 389 && h_count <= 506)|| (h_count >= 547 && h_count <= 570) ))
     ||
     ((v_count >= 253 && v_count <= 299) && ((h_count >= 70 && h_count <= 93) || (h_count >= 142 && h_count <= 165)
     || (h_count >= 229 && h_count <= 252)|| (h_count >= 325 && h_count <= 347)|| (h_count >= 389 && h_count <= 412) 
     || (h_count >= 484 && h_count <= 506) || (h_count >= 547 && h_count <= 570) ))
     ) 
     begin
     blue = 4'b1111;
     grn = 4'b1111;
     end
    else
     begin
     blue = 4'b0000;
     grn = 4'b0000;
     end 
   end  
endmodule

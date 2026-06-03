`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2025 11:51:19
// Design Name: 
// Module Name: vga_controller
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


module vga_controller(
input clk,
input rst,
input [3:0] red,
input [3:0] blue,
input [3:0] grn,
output reg [3:0] vga_r,
output reg [3:0] vga_b,
output reg [3:0] vga_g,
output reg hsync,
output reg vsync,
output [15:0] h_count,
output [15:0] v_count
    );
    
     /* VGA 640x480 @ 60Hz timing constants
    parameter H_VISIBLE_AREA = 640;
    parameter H_FRONT_PORCH = 16;
    parameter H_SYNC_PULSE = 96;
    parameter H_BACK_PORCH = 48;
    parameter H_TOTAL = 800;

    parameter V_VISIBLE_AREA = 480;
    parameter V_FRONT_PORCH = 10;
    parameter V_SYNC_PULSE = 2;
    parameter V_BACK_PORCH = 33;
    parameter V_TOTAL = 525; */
  
  wire clk_25MHZ;
  wire v_enable;
  
  clk_divider_25MHz vga_clk_gen ( .clk(clk) , .rst(rst) , .clk_25MHZ(clk_25MHZ) );
  horizontal_counter vga_hor ( .clk(clk_25MHZ) , .rst(rst) , .v_enable(v_enable), .h_count(h_count) );
  vertical_counter vga_ver ( .clk(clk_25MHZ) , .rst(rst) , .v_enable(v_enable) , .v_count(v_count) );
   
  // generation of hsync and vsync
  always @ (posedge clk_25MHZ or posedge rst)
   begin
   
    if(rst)
     begin
      hsync <= 1;
      vsync <= 1;
     end
    else
     begin
      if(h_count >= 655 && h_count < 751)
      hsync <= 0;
      else
      hsync <= 1;
      
      if(v_count >= 489 && v_count < 491)
      vsync <= 0;
      else
      vsync <= 1;
      
     end
   end
  
  // generation of color signals
  always @ (posedge clk_25MHZ or posedge rst)
   begin
    if(rst)
     begin
      vga_r <= 4'b0000;
      vga_b <= 4'b0000;
      vga_g <= 4'b0000;
     end
    else
     begin
      if (h_count < 640 && v_count < 480)
       begin
        vga_r <= red;
        vga_b <= blue;
        vga_g <= grn;
       end
      else
       begin
        vga_r <= 4'b0000;
        vga_b <= 4'b0000;
        vga_g <= 4'b0000;
       end
     end
   end 
   
endmodule

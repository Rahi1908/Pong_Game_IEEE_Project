`timescale 1ns / 1ps

module renderer(
input clk,
input rst,
input signed [16:0] h,
input signed [16:0] k,
input signed [16:0] a,
input signed [16:0] b,
input signed [16:0] c,
input signed [16:0] d,
input [1:0] p1_score,
input [1:0] p2_score,
input game_over_flag,
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
    wire signed [16:0] x;
    wire signed [16:0] y;
    wire signed [34:0] z;
    
    vga_controller dut ( .clk(clk) , .rst(rst) , .red(red) , .blue(blue) , .grn(grn)
      , .vga_r(vga_r) , .vga_b(vga_b) , .vga_g(vga_g) , .hsync(hsync) , .vsync(vsync) , 
      .h_count(h_count) , .v_count(v_count) );
    
   assign x = $signed(h_count) - $signed(h);
   assign y = $signed(v_count) - $signed(k);
   assign z = (x*x) + (y*y);
   
   
   
    
endmodule

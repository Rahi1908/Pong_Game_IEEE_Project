`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.12.2025 13:13:20
// Design Name: 
// Module Name: clk_divider_tb
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


module clk_divider_tb;
    reg clk;
    reg rst;
    wire clk_25MHZ;
    
    clk_divider dut ( .rst(rst), .clk(clk), .clk_25MHZ(clk_25MHZ) );
    
    initial 
     begin
     clk = 0;
     forever #5 clk = ~ clk;
     end 
     
     initial
      begin
      rst = 1;
      #10 rst = 0;
      #200 $stop;
      end
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2025 11:29:21
// Design Name: 
// Module Name: clk_divider_50Hz
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


module clk_divider_50Hz(
    input clk,
    input rst,
    output clk_50HZ
    );
    reg [31:0] count;
    reg clk_temp;
    
    assign clk_50HZ = clk_temp;
    
    always @ (posedge clk or posedge rst)
    begin
     if(rst)
      begin
      count <= 0;
      clk_temp <= 0;
      end
     else
      begin
       if (count == 999999)
        begin
         count <= 0;
         clk_temp <= ~clk_temp;
        end
       else
        count <= count + 1;
      end
    end
endmodule

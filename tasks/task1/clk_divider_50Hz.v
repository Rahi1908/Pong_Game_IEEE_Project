`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.12.2025 10:10:02
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
    input clk_100MHZ,
    input rst,
    output reg clk_50HZ
    );
    
    reg [1:0] count;
    
    always @ (posedge clk_100MHZ or posedge rst)
     begin
      if (rst) 
       begin
        count <= 0;
        clk_50HZ <= 0; 
       end
      else
       begin
        if ( count == 999999 )
         begin
          count <= 0;
          clk_50HZ <= ~ clk_50HZ;
         end
       else
        count <= count + 1;
       end
      
     end
endmodule

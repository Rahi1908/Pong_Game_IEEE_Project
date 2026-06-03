`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.12.2025 14:10:49
// Design Name: 
// Module Name: clk_divider
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


module clk_divider(
    input clk_100MHZ,
    input rst,
    output reg clk_50MHZ,
    output reg clk_25MHZ,
    output reg clk_50HZ
    );
    integer count1, count2 ; // count1 for 25MHZ clk , count2 for 50HZ clk
    
    always @ (posedge clk_100MHZ or posedge rst)
    begin
     if (rst)// When rst is 1 then all outputs set to 0.
      begin
      count1 <= 0;
      count2 <= 0;
      clk_50MHZ <= 0;
      clk_25MHZ <= 0;
      clk_50HZ <= 0;
      end
     else
      begin
      clk_50MHZ <= ~ clk_50MHZ; // At every positive edge of the clk_100MHZ , this clk will toggle.
      
      if ( count1 == 1 ) // Here the division value 1 is found by the formula [100MHZ / 2 * 25MHZ] - 1
       begin
       count1 <= 0;
       clk_25MHZ <= ~ clk_25MHZ; // This clk will toggle after 2 input clk_100MHZ pulses 
       end
      else
       count1 <= count1 + 1;
       
      if ( count2 == 999999 )
       begin
       count2 <= 0;
       clk_50HZ <= ~ clk_50HZ; // This clk will toggle after 1,000,000 input clk_100MHZ pulses
       end
      else
       count2 <= count2 + 1;
       
      end
     end
endmodule

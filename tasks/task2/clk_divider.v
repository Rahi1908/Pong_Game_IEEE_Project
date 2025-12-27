`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.12.2025 12:35:17
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
    input clk,
     input rst,
    output clk_25MHZ
    );
    reg clk_temp;
    reg [1:0] count;
    
    assign clk_25MHZ = clk_temp;
    
    always @ (posedge clk or posedge rst)
     begin
      if (rst) 
       begin
        count <= 0;
        clk_temp <= 0; 
       end
      else
       begin
        if ( count == 1 )
         begin
          count <= 0;
          clk_temp <= ~ clk_temp;
         end
       else
        count <= count + 1;
       end
      
     end
endmodule

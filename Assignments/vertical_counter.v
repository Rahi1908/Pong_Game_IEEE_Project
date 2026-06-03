`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2025 11:44:26
// Design Name: 
// Module Name: vertical_counter
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


module vertical_counter(
    input clk,
    input rst,
    input v_enable,
    output reg [15:0] v_count
    );
    
  always @ (posedge clk or posedge rst )
   begin
    if (rst) 
     v_count <= 0;
    else
     begin
     if (v_enable == 1'b1)
      begin
       if ( v_count == 524 )
         v_count <= 0 ;
       else
        v_count <= v_count + 1 ;
       end
     end
   end
endmodule
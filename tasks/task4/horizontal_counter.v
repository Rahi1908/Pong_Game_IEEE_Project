`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2025 11:43:08
// Design Name: 
// Module Name: horizontal_counter
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


module horizontal_counter(
    input clk, // Input clock we will take as 25MHz from clk_divider module.
    input rst,
    output reg v_enable, // Enable for vertical counter
    output reg [15:0] h_count // horizontal count value
    );
    
 always @ (posedge clk or posedge rst)
  begin
   if (rst) 
    begin
    h_count <= 0;
    v_enable <= 0;
    end
   else
    begin
     if (h_count == 799)
      begin
       h_count <= 0; //reset horizontal counter
       v_enable <= 1'b1; //enable the vertical counter
      end
     else
      begin
       h_count <= h_count + 1;
       v_enable <= 0; //disable the vertical counter
      end
    end
  end   
endmodule

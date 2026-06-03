`timescale 1ns / 1ps

module clk_60Hz (
    input clk,
    input rst,
    output clk_60HZ
    );
    reg [31:0] count;
    reg clk_temp;
    
    assign clk_60HZ = clk_temp;
    
    always @ (posedge clk or posedge rst)
    begin
     if(rst)
      begin
      count <= 0;
      clk_temp <= 0;
      end
     else
      begin
       if (count == 833332)
        begin
         count <= 0;
         clk_temp <= ~clk_temp;
        end
       else
        count <= count + 1;
      end
    end
endmodule
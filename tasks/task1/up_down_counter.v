`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.12.2025 21:45:22
// Design Name: 
// Module Name: up_down_counter
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


module up_down_counter(
    input x, // when x=0 up counter and when x=1 then down counter
    input clk, // input clock from fpga, 100MHz, port E3
    input reset, // count will reset to 0
    output [3:0] led, // output will be shown on leds of fpga
    output reg [6:0] seg, // 7 seg display
    output [ 7:0] an // displaying only one digit
    );
   wire clk_2; // assign it to the output of clk_divider module, 50Hz
     reg [3:0] count;
     
   clk_divider_50Hz dut ( .clk_100MHZ (clk), .rst(reset) , .clk_50HZ (clk_2) ); //instantiate the module
    
    assign an = 8'b11111110;
    assign led = count;
    
    always @ (posedge clk or posedge reset)
     begin
      if (reset)
       count <= 4'b0000;
      else 
      if (x==0)
       begin
        if( count == 4'b1111 )
         count <= 4'b0000;
        else
        count <= count + 1;
       end
      else 
      if (x==1)
       begin
        if (count == 4'b0000)
        count <= 4'b1111;
        else
        count <= count - 1;
       end
     end
     
     always @ (*)
      begin
       case (count)
        4'b0000 : seg = 7'b0000001;
        4'b0001 : seg = 7'b1001111;
        4'b0010 : seg = 7'b0010010;
        4'b0011 : seg = 7'b0000110;
        4'b0100 : seg = 7'b1101100;
        4'b0101 : seg = 7'b0100100;
        4'b0110 : seg = 7'b0100000;
        4'b0111 : seg = 7'b0001111;
        4'b1000 : seg = 7'b0000000;
        4'b1001 : seg = 7'b0000100;
        4'b1010 : seg = 7'b0001000;
        4'b1011 : seg = 7'b0000000;
        4'b1100 : seg = 7'b0110001;
        4'b1101 : seg = 7'b0000001;
        4'b1110 : seg = 7'b0110000;
        4'b1111 : seg = 7'b0111000;
        default : seg = 7'b1111111;
        endcase
      end
     
endmodule

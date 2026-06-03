`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.12.2025 10:32:22
// Design Name: 
// Module Name: up_down_counter_tb
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


module up_down_counter_tb;
reg x;
reg clk;
reg reset;
wire [3:0] led;
wire [6:0] seg;
wire [7:0] an;

up_down_counter dut ( .x(x) , .clk(clk) , .reset(reset) , .led(led) , .seg(seg) , .an(an) );

initial
begin
clk = 0;
forever #5 clk = ~clk;
end

initial
begin
reset = 1;
#100 reset = 0;
x = 0; 
#50000000 x = 1;
#50000000 $stop;
end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.12.2025 15:52:27
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
reg rst;
reg clk_100MHZ;
wire clk_50MHZ;
wire clk_25MHZ;
wire clk_50HZ;

clk_divider dut ( .rst(rst) , .clk_100MHZ(clk_100MHZ), .clk_50MHZ(clk_50MHZ), .clk_25MHZ(clk_25MHZ), .clk_50HZ(clk_50HZ) );

initial 
begin
clk_100MHZ = 0;
forever #5 clk_100MHZ = ~ clk_100MHZ;
end

initial
begin
rst = 1;
#10 rst = 0;
end

initial
begin
#200000000 $stop;
end

endmodule

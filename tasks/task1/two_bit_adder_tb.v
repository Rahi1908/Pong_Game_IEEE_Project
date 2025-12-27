`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.12.2025 18:19:57
// Design Name: 
// Module Name: two_bit_adder_tb
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


module two_bit_adder_tb ;
reg [1:0] a;
reg [1:0] b;
wire [2:0] sum;

two_bit_adder dut ( .a(a) , .b(b) , .sum(sum) );

initial 
begin
$monitor ( " time = %0t , a = %b, b = %b, sum = %b ", $time ,a, b, sum );
#5 a = 2'b01; b = 2'b10;
#5 a = 2'b00; b = 2'b11;
#5 a = 2'b11; b = 2'b10;
#5 a = 2'b01; b = 2'b11;
#5 a = 2'b11; b = 2'b11;
#10 $finish ;
end
endmodule

`timescale 1ns / 1ps

module score_display(
    input clk_500HZ,
    input rst,
    input [1:0] p1_score,
    input [1:0] p2_score,
    output reg [6:0] seg,
    output reg [7:0] an
);

reg digit_counter = 0;
wire [6:0] seg_p1;
wire [6:0] seg_p2;

always @(posedge clk_500HZ or posedge rst)
begin
    if(rst)
        digit_counter <= 0;
    else
        digit_counter <= digit_counter + 1;
end

always @(*) begin
    if(digit_counter == 0) begin
        an  = 8'b1110_1111;
        seg = seg_p1;
    end
    else begin
        an  = 8'b1111_1110;
        seg = seg_p2;
    end
end

seven_seg_display score_seg1(
    .score(p1_score),
    .seg(seg_p1)
);

seven_seg_display score_seg2(
    .score(p2_score),
    .seg(seg_p2)
);

endmodule
  

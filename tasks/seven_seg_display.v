`timescale 1ns / 1ps


module seven_seg_display(
 input  [1:0] score,
 output reg [6:0] seg
    );
    
    always @(*) begin
    case(score)
    
        2'd0: seg = 7'b1000000; // 0
        2'd1: seg = 7'b1111001; // 1
        2'd2: seg = 7'b0100100; // 2
        2'd3: seg = 7'b0110000; // 3
        
        default: seg = 7'b1111111;
        
    endcase
end

endmodule

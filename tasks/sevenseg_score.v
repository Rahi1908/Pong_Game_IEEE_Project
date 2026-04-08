`timescale 1ns / 1ps

module sevenseg_score(
    input clk_500hz,
    input [1:0] pla1_score,
    input [1:0] pla2_score,
    output reg [7:0] an,
    output reg [7:0] digit
    );
    reg digit_counter;
    reg [1:0] digit_display;
    
    always @(posedge clk_500hz) begin
        digit_counter <= digit_counter + 1;
    end
    
    always @(*) begin
        case(digit_counter)
            1'b0 : begin
                an = 8'b1110_1111;
                digit_display = pla1_score;
                end
            1'b1 : begin
                an = 8'b1111_1110;
                digit_display = pla2_score;
                end
        endcase  
    end
    
    always @(*) begin
    case(digit_display)
        // Format: {DP, G, F, E, D, C, B, A} 
        // 0 = ON, 1 = OFF (Active Low)
        0: digit = 8'b11000000; // Zero
        1: digit = 8'b11111001; // One
        2: digit = 8'b10100100; // Two
        3: digit = 8'b10110000; // Three
        default: digit = 8'b11111111; // All OFF
    endcase
end
endmodule

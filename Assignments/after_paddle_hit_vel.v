`timescale 1ns / 1ps


module after_paddle_hit_vel (
    input clk,
    input rst,
    output reg signed [16:0] speed_mag // Outputs 1, 2, or 3
);

    reg [3:0] lfsr;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= 4'b1011; 
        end else begin
            lfsr <= {lfsr[2:0], lfsr[3] ^ lfsr[2]};
        end
    end

    // Map the LFSR to a single magnitude for both axes
    always @(*) begin
        case (lfsr[1:0])
            2'b00:   speed_mag = 17'sd1;
            2'b01:   speed_mag = 17'sd2;
            2'b10:   speed_mag = 17'sd3;
            default: speed_mag = 17'sd2; // Balance the randomness
        endcase
    end

endmodule

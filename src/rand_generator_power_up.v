`timescale 1ns / 1ps

module rand_generator_power_up(
    input clk_60hz,
    input reset,
    output [9:0] pu_x,
    output [9:0] pu_y,
    output [10:0] pu_time
    );
    
    reg [19:0] lfsr;
    wire feedback;
    
    assign feedback = lfsr[19] ^ lfsr[16] ^ lfsr[13] ^ lfsr[12];
    
    always @(posedge clk_60hz or posedge reset) begin
        if (reset) begin
            lfsr <= 20'hABCDE;
        end else begin
            lfsr <= {lfsr[18:0], feedback}; 
        end
    end
    
    assign pu_x = lfsr[19:11] + 64;
    assign pu_y = lfsr[7:0] + 112;
//    assign pu_time = lfsr[18:10] + 600;
    assign pu_time = lfsr[16:10] + 60;
    
endmodule

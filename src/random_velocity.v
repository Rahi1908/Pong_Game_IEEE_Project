`timescale 1ns / 1ps

module random_velocity(
input clk,
input rst,
output signed [16:0] dx_rdm,
output signed [16:0] dy_rdm
    );
    
    // 4-bit LFSR register
    reg [3:0] lfsr;
    
    always @(posedge clk or posedge rst) 
        begin
            if (rst) 
                begin
                    lfsr <= 4'b1101; // Seed value (anything except 4'b0000)
                end 
            else 
                begin
                    // Feedback tap: bit 3 XOR bit 2
                    lfsr <= {lfsr[2:0], lfsr[3] ^ lfsr[2]};
                end
        end
    
    assign dx_rdm = (lfsr[0]) ? -17'sd1 : 17'sd1;
    assign dy_rdm = (lfsr[1]) ? -17'sd1 : 17'sd1;
    
endmodule

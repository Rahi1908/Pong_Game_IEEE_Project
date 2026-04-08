`timescale 1ns / 1ps

module power_ups(
    input clk_60hz,
    input clk_120hz,
    input reset,
    input pu_collected,
    output reg pu_active,
    output reg [9:0] curr_ran_x,
    output reg [9:0] curr_ran_y
    );
    
    wire [9:0] ran_x;
    wire [9:0] ran_y;
    wire [10:0] ran_time;
    
    reg [10:0] timer;

    rand_generator_power_up ran_pu_inst(
        .clk_120hz(clk_120hz),
        .reset(reset),
        .pu_x(ran_x),
        .pu_y(ran_y),
        .pu_time(ran_time)
    );
    
    always @(posedge clk_60hz or posedge reset) begin
        if (reset) begin
            pu_active <= 0;
            timer <= 0;
            curr_ran_x <= 0;
            curr_ran_y <= 0;
        end else begin
            if (pu_collected) begin
                pu_active <= 0;
                timer <= 0;
            end
            else if (pu_active == 0) begin
                timer <= timer + 1;
                if (timer >= ran_time) begin
                    pu_active <= 1;
                    curr_ran_x <= ran_x;
                    curr_ran_y <= ran_y;
                    timer <= 0;
                end
            end
        end
    end
    
    
endmodule
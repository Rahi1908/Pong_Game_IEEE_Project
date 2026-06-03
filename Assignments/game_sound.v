`timescale 1ns / 1ps

module game_sound(
input clk, // 100MHz
input game_over, // high when game ends
output AUD_PWM,
output AUD_SD
    );
 
    
    parameter TONE_COUNT    = 20'd56818; // 880Hz tone: 100MHz / (2 × 880) = 56,818 
    parameter BEEP_DURATION = 27'd100_000_000; // 1 second beep at 100MHz = 50,000,000 cycles
    
    reg [19:0] tone_counter;
    reg [26:0] beep_counter;
    reg beep_active;
    reg clk_tone;
    reg pwm_reg;
    
    assign AUD_SD  = 1'b1;        // always enable amp
    assign AUD_PWM = beep_active ? clk_tone : 1'b0;
    
    reg game_over_d; // detect rising edge of game_over
    wire game_over_pulse = game_over && !game_over_d;

    always @(posedge clk) begin
        game_over_d <= game_over;
    end 
    
    // beep duration control
    always @(posedge clk) begin
        if (game_over_pulse) begin
            beep_active  <= 1'b1;
            beep_counter <= 27'd0;
        end
        else if (beep_active) begin
            if (beep_counter < BEEP_DURATION)
                beep_counter <= beep_counter + 1;
            else
                beep_active <= 1'b0;
        end
    end
    
    // tone generator
    always @(posedge clk) begin
        if (tone_counter >= TONE_COUNT) begin
            tone_counter <= 20'd0;
            clk_tone     <= ~clk_tone;
        end
        else
            tone_counter <= tone_counter + 1;
    end
    
endmodule

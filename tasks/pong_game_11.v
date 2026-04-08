`timescale 1ns / 1ps



`timescale 1ns / 1ps

module pong_game_11 (                 
input clk,
input rst,
input lu,  // left paddle up motion assigned to P17
input ld,  // left paddle down motion assigned to P18
input ru,  // right paddle up motion assigned to M18
input rd,  // right paddle down motion assigned to M17
input game_start,
input AI_mode,  // 1 = CPU mode, 0 = 2-player
input hard_mode,  // 0 = beatable, 1 = unbeatable
input noob_switch, // 1 = slow, 0 = fast
output [3:0] vga_r,
output [3:0] vga_b,
output [3:0] vga_g,
output hsync,
output vsync,
output [7:0] seg,
output [7:0] an
    );
    
    parameter R = 17'sd10;  // Radius of ball 10 px
    parameter IDLE=2'b00, PLAY=2'b01, MISS=2'b10, DELAY=2'b11 ; //finite states
    
    wire clk_120HZ;
    wire clk_500HZ;
    wire clk_60HZ;
    reg [3:0] red;
    reg [3:0] blue;
    reg [3:0] grn;
    wire [15:0] h_count;
    wire [15:0] v_count;
    reg signed [16:0] h;        // x co-ordinate of center of the ball
    reg signed [16:0] k;        // y co-ordinate of center of the ball
    wire signed [16:0] a;       // top of the left paddle
    wire signed [16:0] b;       // bottom of the left paddle
    wire signed [16:0] c;       // top of the right paddle
    wire signed [16:0] d;       // bottom of the right paddle
    reg signed [16:0] lm;       // Left paddle mid point
    reg signed [16:0] rm;       // Right paddle mid point
    reg signed [16:0] vy_l;     // velocity of left paddle in y direction 
    reg signed [16:0] vy_r;     // velocity of right paddle in y direction
    reg signed [16:0] dx;        // dx and dy are direction vectors 
    reg signed [16:0] dy;
    reg signed [16:0] speed_x;
    reg signed [16:0] speed_y;
    wire signed [16:0] h_next = h + (dx * speed_x);
    wire signed [16:0] k_next = k + (dy * speed_y);
    reg [1:0] curr_state;
    reg [1:0] nxt_state;
    reg [1:0] p1_score;
    reg [1:0] p2_score;
    reg game_over_flag;
    reg [26:0] delay_cnt; // To hold roughly 1 second at 100MHz
    wire signed [16:0] dx_rdm;
    wire signed [16:0] dy_rdm;
    wire [9:0]  pu_x_raw;
    wire [9:0]  pu_y_raw;
    wire signed [16:0] pu_x = {7'b0, pu_x_raw};  // zero-extend to 17 bits
    wire signed [16:0] pu_y = {7'b0, pu_y_raw};  // zero-extend to 17 bits
    wire pu_active;
    reg pu_collected;
    reg signed [16:0] p1_half;   // left paddle half-height
    reg signed [16:0] p2_half;   // right paddle half-height
    reg [9:0] p1_big_timer;      // counts down 7 seconds
    reg [9:0] p2_big_timer;      // counts down 7 seconds
    reg [7:0] delay_cnt_pause;
    // 7 seconds at 60Hz = 420 cycles
    parameter BIG_TIME = 10'd420;
    parameter NORMAL_HALF = 17'sd35;   // original half = 35px, full = 70px
    parameter BIG_HALF    = 17'sd70;   // doubled = 70px half, full = 140px
    

  //                              -----------------
  //-----------------------------/INTERNAL MODULES/-------------------------------------
  //                            -----------------
  
    clk_500Hz uut_clk500hz ( .clk(clk), .rst(rst), .clk_500HZ(clk_500HZ) );
    
    clk_divider_120Hz clk_gen ( .clk(clk) , .rst(rst) , .clk_120HZ(clk_120HZ) );
    
    clk_60Hz clk_gen_60hz (.clk(clk), .rst(rst), .clk_60HZ(clk_60HZ));
    
    power_ups pu_inst (.clk_60hz(clk_60HZ), .clk_120hz(clk_120HZ), .reset(rst), 
        .pu_collected(pu_collected), .pu_active(pu_active), .curr_ran_x(pu_x_raw), .curr_ran_y(pu_y_raw));
    
    vga_controller dut ( .clk(clk) , .rst(rst) , .red(red) , .blue(blue) , .grn(grn)
      , .vga_r(vga_r) , .vga_b(vga_b) , .vga_g(vga_g) , .hsync(hsync) , .vsync(vsync) , 
      .h_count(h_count) , .v_count(v_count) );
      
    sevenseg_score scores (.clk_500hz(clk_500HZ), .pla1_score(p1_score), .pla2_score(p2_score), .an(an), .digit(seg) );
   
    random_velocity rdm_vel ( .clk(clk), .rst(rst), .dx_rdm(dx_rdm), .dy_rdm(dy_rdm) );
    
      
   //                     ----------------------------
   // -------------------/GENERATING BALL AND PADDLE/--------------------
   //                   ----------------------------
  
   wire signed [16:0] x;
   wire signed [16:0] y;
   wire signed [34:0] z;
   assign a = lm - p1_half;
   assign b = lm + p1_half;
   assign c = rm - p2_half;
   assign d = rm + p2_half;
   
   assign x = $signed(h_count) - $signed(h);
   assign y = $signed(v_count) - $signed(k);
   assign z = (x*x) + (y*y);
   
  
    always @ (*)
    begin
        red = 4'b0000;
        grn = 4'b0000;
        blue = 4'b0000;
        
    if(game_start)
    begin
       /* if ( z <= 35'sd100 )
            begin
                red = 4'b1111;         // White Ball with radius 10
                blue = 4'b1111;  
                grn = 4'b1111;
            end */
    
        if(
          // Letter P (X: 56 to 104)
                ((h_count >= 56 && h_count < 72) && (v_count >= 164 && v_count < 244)) || // Left Vert
                ((h_count >= 56 && h_count < 88) && (v_count >= 164 && v_count < 180)) || // Top Horiz
                ((h_count >= 88 && h_count < 104) && (v_count >= 180 && v_count < 196)) || // Right Curve
                ((h_count >= 56 && h_count < 88) && (v_count >= 196 && v_count < 212)) || // Middle Horiz
        
                // Letter I (X: 120 to 168)
                ((h_count >= 136 && h_count < 152) && (v_count >= 164 && v_count < 244)) || // Center Vert
                ((h_count >= 120 && h_count < 168) && (v_count >= 164 && v_count < 180)) || // Top Cap
                ((h_count >= 120 && h_count < 168) && (v_count >= 228 && v_count < 244)) || // Bot Cap
        
                // Letter N (X: 184 to 232)
                ((h_count >= 184 && h_count < 200) && (v_count >= 164 && v_count < 244)) || // Left Vert
                ((h_count >= 216 && h_count < 232) && (v_count >= 164 && v_count < 244)) || // Right Vert
                ((h_count >= 184 && h_count < 232) && (v_count >= 164 && v_count < 180)) || // Top Arch
        
                // Letter G (X: 248 to 296)
                ((h_count >= 248 && h_count < 264) && (v_count >= 164 && v_count < 244)) || // Left Vert
                ((h_count >= 248 && h_count < 296) && (v_count >= 164 && v_count < 180)) || // Top Horiz
                ((h_count >= 248 && h_count < 296) && (v_count >= 228 && v_count < 244)) || // Bot Horiz
                ((h_count >= 280 && h_count < 296) && (v_count >= 196 && v_count < 244)) || // Right Lower Vert
                ((h_count >= 264 && h_count < 296) && (v_count >= 196 && v_count < 212)) || // Middle Nub
        
                // Letter P (X: 344 to 392)
                ((h_count >= 344 && h_count < 360) && (v_count >= 164 && v_count < 244)) || // Left Vert
                ((h_count >= 344 && h_count < 376) && (v_count >= 164 && v_count < 180)) || // Top Horiz
                ((h_count >= 376 && h_count < 392) && (v_count >= 180 && v_count < 196)) || // Right Curve
                ((h_count >= 344 && h_count < 376) && (v_count >= 196 && v_count < 212)) || // Middle Horiz
        
                // Letter O (X: 408 to 456)
                ((h_count >= 408 && h_count < 424) && (v_count >= 164 && v_count < 244)) || // Left Vert
                ((h_count >= 440 && h_count < 456) && (v_count >= 164 && v_count < 244)) || // Right Vert
                ((h_count >= 408 && h_count < 456) && (v_count >= 164 && v_count < 180)) || // Top Horiz
                ((h_count >= 408 && h_count < 456) && (v_count >= 228 && v_count < 244)) || // Bot Horiz
        
                // Letter N (X: 472 to 520)
                ((h_count >= 472 && h_count < 488) && (v_count >= 164 && v_count < 244)) || // Left Vert
                ((h_count >= 504 && h_count < 520) && (v_count >= 164 && v_count < 244)) || // Right Vert
                ((h_count >= 472 && h_count < 520) && (v_count >= 164 && v_count < 180)) || // Top Arch
        
                // Letter G (X: 536 to 584)
                ((h_count >= 536 && h_count < 552) && (v_count >= 164 && v_count < 244)) || // Left Vert
                ((h_count >= 536 && h_count < 584) && (v_count >= 164 && v_count < 180)) || // Top Horiz
                ((h_count >= 536 && h_count < 584) && (v_count >= 228 && v_count < 244)) || // Bot Horiz
                ((h_count >= 568 && h_count < 584) && (v_count >= 196 && v_count < 244)) || // Right Lower Vert
                ((h_count >= 552 && h_count < 584) && (v_count >= 196 && v_count < 212))  // Middle Nub
          
            )
        begin
            red = 4'b1111;
            grn = 4'b1111;
            blue = 4'b1111;
        end
        
      else if (
        // Letter I (X: 260 to 284)
                ((h_count >= 268 && h_count < 276) && (v_count >= 276 && v_count < 316)) || // Center Vert
                ((h_count >= 260 && h_count < 284) && (v_count >= 276 && v_count < 284)) || // Top Cap
                ((h_count >= 260 && h_count < 284) && (v_count >= 308 && v_count < 316)) || // Bot Cap
        
                // Letter E (X: 292 to 316)
                ((h_count >= 292 && h_count < 300) && (v_count >= 276 && v_count < 316)) || // Left Vert
                ((h_count >= 292 && h_count < 316) && (v_count >= 276 && v_count < 284)) || // Top Horiz
                ((h_count >= 292 && h_count < 316) && (v_count >= 292 && v_count < 300)) || // Mid Horiz
                ((h_count >= 292 && h_count < 316) && (v_count >= 308 && v_count < 316)) || // Bot Horiz
        
                // Letter E (X: 324 to 348)
                ((h_count >= 324 && h_count < 332) && (v_count >= 276 && v_count < 316)) || // Left Vert
                ((h_count >= 324 && h_count < 348) && (v_count >= 276 && v_count < 284)) || // Top Horiz
                ((h_count >= 324 && h_count < 348) && (v_count >= 292 && v_count < 300)) || // Mid Horiz
                ((h_count >= 324 && h_count < 348) && (v_count >= 308 && v_count < 316)) || // Bot Horiz
        
                // Letter E (X: 356 to 380)
                ((h_count >= 356 && h_count < 364) && (v_count >= 276 && v_count < 316)) || // Left Vert
                ((h_count >= 356 && h_count < 380) && (v_count >= 276 && v_count < 284)) || // Top Horiz
                ((h_count >= 356 && h_count < 380) && (v_count >= 292 && v_count < 300)) || // Mid Horiz
                ((h_count >= 356 && h_count < 380) && (v_count >= 308 && v_count < 316))    // Bot Horiz
      )
        begin
            red = 4'b1000;
            grn = 4'b1000;
            blue = 4'b1000;
        end
        
    end
    else
        begin
        if( game_over_flag )
            begin
             if(p1_score == 2'd3)
                begin
    
                //---------------- GAME OVER ----------------

                if(        // Letter G
                ((h_count > 175 && h_count < 185) && (v_count > 120 && v_count < 220)) || // Left Vertical
                ((h_count > 175 && h_count < 225) && (v_count > 120 && v_count < 130)) || // Top Horizontal
                ((h_count > 175 && h_count < 225) && (v_count > 210 && v_count < 220)) || // Bottom Horizontal
                ((h_count > 215 && h_count < 225) && (v_count > 170 && v_count < 220)) || // Right Lower Vertical
                ((h_count > 200 && h_count < 225) && (v_count > 170 && v_count < 180)) || // Middle Inward Nub
        
                // Letter A
                ((h_count > 255 && h_count < 265) && (v_count > 120 && v_count < 220)) || // Left Vertical
                ((h_count > 295 && h_count < 305) && (v_count > 120 && v_count < 220)) || // Right Vertical
                ((h_count > 255 && h_count < 305) && (v_count > 120 && v_count < 130)) || // Top Horizontal
                ((h_count > 255 && h_count < 305) && (v_count > 165 && v_count < 175)) || // Middle Horizontal
        
                // Letter M
                ((h_count > 335 && h_count < 345) && (v_count > 120 && v_count < 220)) || // Left Vertical
                ((h_count > 375 && h_count < 385) && (v_count > 120 && v_count < 220)) || // Right Vertical
                ((h_count > 345 && h_count < 355) && (v_count > 130 && v_count < 150)) || // Left Diag Block
                ((h_count > 365 && h_count < 375) && (v_count > 130 && v_count < 150)) || // Right Diag Block
                ((h_count > 355 && h_count < 365) && (v_count > 140 && v_count < 160)) || // Center Drop
        
                // Letter E
                ((h_count > 415 && h_count < 425) && (v_count > 120 && v_count < 220)) || // Left Vertical
                ((h_count > 415 && h_count < 465) && (v_count > 120 && v_count < 130)) || // Top Horizontal
                ((h_count > 415 && h_count < 455) && (v_count > 165 && v_count < 175)) || // Middle Horizontal
                ((h_count > 415 && h_count < 465) && (v_count > 210 && v_count < 220)) ||// Bottom Horizontal
        
                // -----------------------------------------------------------
                // ROW 2: "OVER" (Y-Range: 260 to 360)
                // -----------------------------------------------------------
        
                // Letter O
                ((h_count > 175 && h_count < 185) && (v_count > 260 && v_count < 360)) || // Left Vertical
                ((h_count > 215 && h_count < 225) && (v_count > 260 && v_count < 360)) || // Right Vertical
                ((h_count > 175 && h_count < 225) && (v_count > 260 && v_count < 270)) || // Top Horizontal
                ((h_count > 175 && h_count < 225) && (v_count > 350 && v_count < 360)) || // Bottom Horizontal
        
                // Letter V (Approximated with blocks)
                ((h_count > 255 && h_count < 265) && (v_count > 260 && v_count < 340)) || // Left Vertical Top
                ((h_count > 295 && h_count < 305) && (v_count > 260 && v_count < 340)) || // Right Vertical Top
                ((h_count > 265 && h_count < 275) && (v_count > 330 && v_count < 350)) || // Left Step Down
                ((h_count > 285 && h_count < 295) && (v_count > 330 && v_count < 350)) || // Right Step Down
                ((h_count > 275 && h_count < 285) && (v_count > 350 && v_count < 360)) || // Bottom Point
        
                // Letter E
                ((h_count > 335 && h_count < 345) && (v_count > 260 && v_count < 360)) || // Left Vertical
                ((h_count > 335 && h_count < 385) && (v_count > 260 && v_count < 270)) || // Top Horizontal
                ((h_count > 335 && h_count < 375) && (v_count > 305 && v_count < 315)) || // Middle Horizontal
                ((h_count > 335 && h_count < 385) && (v_count > 350 && v_count < 360)) || // Bottom Horizontal
        
                // Letter R
                ((h_count > 415 && h_count < 425) && (v_count > 260 && v_count < 360)) || // Left Vertical
                ((h_count > 415 && h_count < 465) && (v_count > 260 && v_count < 270)) || // Top Horizontal
                ((h_count > 455 && h_count < 465) && (v_count > 260 && v_count < 310)) || // Right Vertical (Top Half)
                ((h_count > 415 && h_count < 465) && (v_count > 300 && v_count < 310)) || // Middle Horizontal
                ((h_count > 445 && h_count < 455) && (v_count > 310 && v_count < 360))    // Diagonal Leg (Blocky)
        
                )
                begin
                red = 4'b1111;
                grn = 4'b1001;
                blue = 4'b0000;
                end
                
                       // Letter P (Small)
                else if ( ((h_count > 220 && h_count < 225) && (v_count > 400 && v_count < 430)) || // Vert
                        ((h_count > 220 && h_count < 240) && (v_count > 400 && v_count < 405)) || // Top
                        ((h_count > 220 && h_count < 240) && (v_count > 415 && v_count < 420)) || // Mid
                        ((h_count > 235 && h_count < 240) && (v_count > 400 && v_count < 420)) || // Right Loop
        
                        // Number 1 (Small)
                        ((h_count > 260 && h_count < 265) && (v_count > 400 && v_count < 430)) || // Vert
        
                        // Letter W (Small)
                        ((h_count > 290 && h_count < 295) && (v_count > 400 && v_count < 430)) || // Left
                        ((h_count > 310 && h_count < 315) && (v_count > 400 && v_count < 430)) || // Right
                        ((h_count > 290 && h_count < 315) && (v_count > 425 && v_count < 430)) || // Bottom
                        ((h_count > 300 && h_count < 305) && (v_count > 415 && v_count < 430)) || // Mid Nub
        
                        // Letter I (Small)
                        ((h_count > 330 && h_count < 335) && (v_count > 400 && v_count < 430)) || // Vert
                        ((h_count > 325 && h_count < 340) && (v_count > 400 && v_count < 405)) || // Top Cap
                        ((h_count > 325 && h_count < 340) && (v_count > 425 && v_count < 430)) || // Bot Cap
        
                        // Letter N (Small)
                        ((h_count > 355 && h_count < 360) && (v_count > 400 && v_count < 430)) || // Left
                        ((h_count > 370 && h_count < 375) && (v_count > 400 && v_count < 430)) || // Right
                        ((h_count > 355 && h_count < 375) && (v_count > 400 && v_count < 405)) || // Top
        
                        // Letter S (Small)
                        ((h_count > 390 && h_count < 405) && (v_count > 400 && v_count < 405)) || // Top Horiz
                        ((h_count > 390 && h_count < 405) && (v_count > 412 && v_count < 417)) || // Mid Horiz
                        ((h_count > 390 && h_count < 405) && (v_count > 425 && v_count < 430)) || // Bot Horiz
                        ((h_count > 390 && h_count < 395) && (v_count > 400 && v_count < 415)) || // Left Vert Top
                        ((h_count > 400 && h_count < 405) && (v_count > 415 && v_count < 430))    // Right Vert Bot
                        )
                        
                         begin
                             red = 4'b0000;
                             grn = 4'b0000;
                             blue = 4'b1111;
                         end 
    
                    end 
    
          
                  else if(p2_score == 2'd3)
                    begin
                    //---------------- GAME OVER ----------------

                     if(
                     // Letter G
                    ((h_count > 175 && h_count < 185) && (v_count > 120 && v_count < 220)) || // Left Vertical
                    ((h_count > 175 && h_count < 225) && (v_count > 120 && v_count < 130)) || // Top Horizontal
                    ((h_count > 175 && h_count < 225) && (v_count > 210 && v_count < 220)) || // Bottom Horizontal
                    ((h_count > 215 && h_count < 225) && (v_count > 170 && v_count < 220)) || // Right Lower Vertical
                    ((h_count > 200 && h_count < 225) && (v_count > 170 && v_count < 180)) || // Middle Inward Nub
        
                    // Letter A
                    ((h_count > 255 && h_count < 265) && (v_count > 120 && v_count < 220)) || // Left Vertical
                    ((h_count > 295 && h_count < 305) && (v_count > 120 && v_count < 220)) || // Right Vertical
                    ((h_count > 255 && h_count < 305) && (v_count > 120 && v_count < 130)) || // Top Horizontal
                    ((h_count > 255 && h_count < 305) && (v_count > 165 && v_count < 175)) || // Middle Horizontal
        
                    // Letter M
                    ((h_count > 335 && h_count < 345) && (v_count > 120 && v_count < 220)) || // Left Vertical
                    ((h_count > 375 && h_count < 385) && (v_count > 120 && v_count < 220)) || // Right Vertical
                    ((h_count > 345 && h_count < 355) && (v_count > 130 && v_count < 150)) || // Left Diag Block
                    ((h_count > 365 && h_count < 375) && (v_count > 130 && v_count < 150)) || // Right Diag Block
                    ((h_count > 355 && h_count < 365) && (v_count > 140 && v_count < 160)) || // Center Drop
        
                     // Letter E
                    ((h_count > 415 && h_count < 425) && (v_count > 120 && v_count < 220)) || // Left Vertical
                    ((h_count > 415 && h_count < 465) && (v_count > 120 && v_count < 130)) || // Top Horizontal
                    ((h_count > 415 && h_count < 455) && (v_count > 165 && v_count < 175)) || // Middle Horizontal
                    ((h_count > 415 && h_count < 465) && (v_count > 210 && v_count < 220)) || // Bottom Horizontal
        
                    // -----------------------------------------------------------
                    // ROW 2: "OVER" (Y-Range: 260 to 360)
                    // -----------------------------------------------------------
        
                    // Letter O
                    ((h_count > 175 && h_count < 185) && (v_count > 260 && v_count < 360)) || // Left Vertical
                    ((h_count > 215 && h_count < 225) && (v_count > 260 && v_count < 360)) || // Right Vertical
                    ((h_count > 175 && h_count < 225) && (v_count > 260 && v_count < 270)) || // Top Horizontal
                    ((h_count > 175 && h_count < 225) && (v_count > 350 && v_count < 360)) || // Bottom Horizontal
        
                    // Letter V (Approximated with blocks)
                    ((h_count > 255 && h_count < 265) && (v_count > 260 && v_count < 340)) || // Left Vertical Top
                    ((h_count > 295 && h_count < 305) && (v_count > 260 && v_count < 340)) || // Right Vertical Top
                    ((h_count > 265 && h_count < 275) && (v_count > 330 && v_count < 350)) || // Left Step Down
                    ((h_count > 285 && h_count < 295) && (v_count > 330 && v_count < 350)) || // Right Step Down
                    ((h_count > 275 && h_count < 285) && (v_count > 350 && v_count < 360)) || // Bottom Point
        
                    // Letter E
                    ((h_count > 335 && h_count < 345) && (v_count > 260 && v_count < 360)) || // Left Vertical
                    ((h_count > 335 && h_count < 385) && (v_count > 260 && v_count < 270)) || // Top Horizontal
                    ((h_count > 335 && h_count < 375) && (v_count > 305 && v_count < 315)) || // Middle Horizontal
                    ((h_count > 335 && h_count < 385) && (v_count > 350 && v_count < 360)) || // Bottom Horizontal
        
                    // Letter R
                    ((h_count > 415 && h_count < 425) && (v_count > 260 && v_count < 360)) || // Left Vertical
                    ((h_count > 415 && h_count < 465) && (v_count > 260 && v_count < 270)) || // Top Horizontal
                    ((h_count > 455 && h_count < 465) && (v_count > 260 && v_count < 310)) || // Right Vertical (Top Half)
                    ((h_count > 415 && h_count < 465) && (v_count > 300 && v_count < 310)) || // Middle Horizontal
                    ((h_count > 445 && h_count < 455) && (v_count > 310 && v_count < 360))   // Diagonal Leg (Blocky)
        
                     )
                     begin
                     red = 4'b1111;
                     grn = 4'b1001;
                     blue = 4'b0000;
                     end
                     
                     else if (
                     // Letter P (Small)
                     ((h_count > 220 && h_count < 225) && (v_count > 400 && v_count < 430)) || // Vert
                     ((h_count > 220 && h_count < 240) && (v_count > 400 && v_count < 405)) || // Top
                     ((h_count > 220 && h_count < 240) && (v_count > 415 && v_count < 420)) || // Mid
                     ((h_count > 235 && h_count < 240) && (v_count > 400 && v_count < 420)) || // Right Loop
        
                      // Number 2 (Small) - REPLACES NUMBER 1
                      ((h_count > 255 && h_count < 270) && (v_count > 400 && v_count < 405)) || // Top Horizontal
                      ((h_count > 265 && h_count < 270) && (v_count > 400 && v_count < 415)) || // Right Vert Top
                      ((h_count > 255 && h_count < 270) && (v_count > 412 && v_count < 417)) || // Mid Horizontal
                      ((h_count > 255 && h_count < 260) && (v_count > 415 && v_count < 430)) || // Left Vert Bot
                      ((h_count > 255 && h_count < 270) && (v_count > 425 && v_count < 430)) || // Bot Horizontal
            
        
                      // Letter W (Small)
                      ((h_count > 290 && h_count < 295) && (v_count > 400 && v_count < 430)) || // Left
                      ((h_count > 310 && h_count < 315) && (v_count > 400 && v_count < 430)) || // Right
                      ((h_count > 290 && h_count < 315) && (v_count > 425 && v_count < 430)) || // Bottom
                      ((h_count > 300 && h_count < 305) && (v_count > 415 && v_count < 430)) || // Mid Nub
        
                      // Letter I (Small)
                      ((h_count > 330 && h_count < 335) && (v_count > 400 && v_count < 430)) || // Vert
                      ((h_count > 325 && h_count < 340) && (v_count > 400 && v_count < 405)) || // Top Cap
                      ((h_count > 325 && h_count < 340) && (v_count > 425 && v_count < 430)) || // Bot Cap
        
                      // Letter N (Small)
                      ((h_count > 355 && h_count < 360) && (v_count > 400 && v_count < 430)) || // Left
                      ((h_count > 370 && h_count < 375) && (v_count > 400 && v_count < 430)) || // Right
                      ((h_count > 355 && h_count < 375) && (v_count > 400 && v_count < 405)) || // Top
        
                      // Letter S (Small)
                      ((h_count > 390 && h_count < 405) && (v_count > 400 && v_count < 405)) || // Top Horiz
                      ((h_count > 390 && h_count < 405) && (v_count > 412 && v_count < 417)) || // Mid Horiz
                      ((h_count > 390 && h_count < 405) && (v_count > 425 && v_count < 430)) || // Bot Horiz
                      ((h_count > 390 && h_count < 395) && (v_count > 400 && v_count < 415)) || // Left Vert Top
                      ((h_count > 400 && h_count < 405) && (v_count > 415 && v_count < 430))    // Right Vert Bot
                      )
                      begin
                        red = 4'b0000;
                        grn = 4'b1001;
                        blue = 4'b1111;         
                      end
     
                  end
             end
       
       else      //Now main game display will be seen
        begin
    
        // --- PLAYER 1 SCORE (X: 259-284, Y: 24-48) ---
            if (h_count >= 259 && h_count <= 284 && v_count >= 24 && v_count <= 48) begin
                 case(p1_score)
                     2'd0: begin //  "0"
                            if ( ((v_count >= 24 && v_count <= 28) && (h_count >= 266 && h_count <= 281)) ||
                                ((v_count >= 29 && v_count <= 44) && ((h_count >= 264 && h_count <= 269) || (h_count >= 279 && h_count <= 284))) ||
                                ((v_count >= 45 && v_count <= 48) && (h_count >= 266 && h_count <= 281))
                                ) 
                            {red, grn, blue} = 12'hFFF; 
                            end
        
                    2'd1: begin // "1"
                         if ( ((v_count >= 24 && v_count <= 28) && (h_count >= 272 && h_count <= 277)) ||
                              ((v_count >= 29 && v_count <= 33) && (h_count >= 268 && h_count <= 277)) ||
                              ((v_count >= 34 && v_count <= 43) && (h_count >= 272 && h_count <= 277)) ||
                              ((v_count >= 44 && v_count <= 48) && (h_count >= 266 && h_count <= 284)) 
                             ) 
                            {red, grn, blue} = 12'hFFF;
                         end
        
                   2'd2: begin //  "2"
                        if ( ((v_count >= 24 && v_count <= 28) && (h_count >= 259 && h_count <= 279)) ||
                            ((v_count >= 29 && v_count <= 33) && (h_count >= 280 && h_count <= 284)) ||
                            ((v_count >= 34 && v_count <= 38) && (h_count >= 266 && h_count <= 284)) ||
                            ((v_count >= 39 && v_count <= 43) && (h_count >= 259 && h_count <= 265)) ||
                            ((v_count >= 44 && v_count <= 48) && (h_count >= 259 && h_count <= 284))
                            )
                            {red, grn, blue} = 12'hFFF;
                         end
        
                 2'd3: begin //  "3"
                        if ( ((v_count >= 24 && v_count <= 28) && (h_count >= 259 && h_count <= 279)) ||
                            ((v_count >= 29 && v_count <= 33) && (h_count >= 280 && h_count <= 284)) ||
                            ((v_count >= 34 && v_count <= 38) && (h_count >= 265 && h_count <= 284)) ||
                            ((v_count >= 39 && v_count <= 43) && (h_count >= 280 && h_count <= 284)) ||
                            ((v_count >= 44 && v_count <= 48) && (h_count >= 259 && h_count <= 279))
                            )
                            {red, grn, blue} = 12'hFFF;
                        end
            endcase
        end

// --- PLAYER 2 SCORE (X: 356-382, Y: 24-48) ---
if (h_count >= 356 && h_count <= 382 && v_count >= 24 && v_count <= 48) begin
    case(p2_score)
        2'd0: begin //  "0"
            if ( ((v_count >= 24 && v_count <= 28) && (h_count >= 359 && h_count <= 373)) ||
                 ((v_count >= 29 && v_count <= 44) && ((h_count >= 356 && h_count <= 361) || (h_count >= 371 && h_count <= 376))) ||
                 ((v_count >= 45 && v_count <= 48) && (h_count >= 359 && h_count <= 373))
                ) 
                {red, grn, blue} = 12'hFFF; // Teal color from your image
        end
        
         2'd1: begin // "1"
            if ( ((v_count >= 24 && v_count <= 28) && (h_count >= 363 && h_count <= 368)) ||
                 ((v_count >= 29 && v_count <= 33) && (h_count >= 358 && h_count <= 368)) ||
                 ((v_count >= 34 && v_count <= 43) && (h_count >= 363 && h_count <= 368)) ||
                 ((v_count >= 44 && v_count <= 48) && (h_count >= 356 && h_count <= 374)) 
                ) 
                {red, grn, blue} = 12'hFFF;
        end 
        
        2'd2: begin //  "2"
            if ( ((v_count >= 24 && v_count <= 28) && (h_count >= 356 && h_count <= 376)) ||
                 ((v_count >= 29 && v_count <= 33) && (h_count >= 377 && h_count <= 382)) ||
                 ((v_count >= 34 && v_count <= 38) && (h_count >= 363 && h_count <= 382)) ||
                 ((v_count >= 39 && v_count <= 43) && (h_count >= 356 && h_count <= 362)) ||
                 ((v_count >= 44 && v_count <= 48) && (h_count >= 356 && h_count <= 382))
                )
                {red, grn, blue} = 12'hFFF;
        end
        
        2'd3: begin //  "3"
            if ( ((v_count >= 24 && v_count <= 28) && (h_count >= 356 && h_count <= 376)) ||
                 ((v_count >= 29 && v_count <= 33) && (h_count >= 377 && h_count <= 382)) ||
                 ((v_count >= 34 && v_count <= 38) && (h_count >= 362 && h_count <= 382)) ||
                 ((v_count >= 39 && v_count <= 43) && (h_count >= 377 && h_count <= 382)) ||
                 ((v_count >= 44 && v_count <= 48) && (h_count >= 356 && h_count <= 376))
                )
                {red, grn, blue} = 12'hFFF;
        end
    endcase
end

     if ( z <= 35'sd100 )
      begin
       red = 4'b1111;         // White Ball with radius 10
       blue = 4'b1111;  
       grn = 4'b1111;
      end
      
     else if ( (($signed(v_count) >= a && $signed(v_count) <= b) && ($signed(h_count) >= 16 && $signed(h_count) <= 23))         // left paddle
           || 
           (($signed(v_count) >= c && $signed(v_count) <= d) && ($signed(h_count) >= 616 && $signed(h_count) <= 623)) )    // right paddle
         begin
          red = 4'b1111;      
          blue = 4'b1111;     // paddles will look white
          grn = 4'b1111;
         end
         
     else if ( ((v_count >= 0 && v_count <= 7) && ( h_count >= 0 && h_count <= 639 ))  
            || (( v_count >= 8 && v_count <= 471 ) && ( ( h_count >= 0 && h_count <= 7 ) || ( h_count >= 632 && h_count <= 639 ) ))
            || ((v_count >= 472 && v_count <= 479) && ( h_count >= 0 && h_count <= 639 ))
              )
        begin
          red = 4'b1111;      
          blue = 4'b1111;     // white border
          grn = 4'b1111;   
        end
        
    else if (pu_active &&
         $signed(h_count) >= pu_x - 10 && $signed(h_count) <= pu_x + 10 &&   //power ups orange color 16x16 square
         $signed(v_count) >= pu_y - 10 && $signed(v_count) <= pu_y + 10)
          begin
            red  = 4'b1111;
            grn  = 4'b0110;
            blue = 4'b0000;
         end
    
    else if ( (h_count >= 316 && h_count <= 323) &&
            ( (v_count >= 8 && v_count <= 15) ||
              (v_count >= 24 && v_count <= 31) ||
              (v_count >= 40 && v_count <= 47) ||
              (v_count >= 56 && v_count <= 63) ||              // Middle dotted line
              (v_count >= 72 && v_count <= 79) ||
              (v_count >= 88 && v_count <= 95) ||
              (v_count >= 104 && v_count <= 111) ||
              (v_count >= 120 && v_count <= 127) ||
              (v_count >= 136 && v_count <= 143) ||
              (v_count >= 152 && v_count <= 159) ||
              (v_count >= 168 && v_count <= 175) ||
              (v_count >= 184 && v_count <= 191) ||
              (v_count >= 200 && v_count <= 207) ||
              (v_count >= 216 && v_count <= 223) ||
              (v_count >= 232 && v_count <= 239) ||
              (v_count >= 248 && v_count <= 255) ||
              (v_count >= 264 && v_count <= 271) ||
              (v_count >= 280 && v_count <= 287) ||
              (v_count >= 296 && v_count <= 303) ||
              (v_count >= 312 && v_count <= 319) ||
              (v_count >= 328 && v_count <= 335) ||
              (v_count >= 344 && v_count <= 351) ||
              (v_count >= 360 && v_count <= 367) ||
              (v_count >= 376 && v_count <= 383) ||
              (v_count >= 392 && v_count <= 399) ||
              (v_count >= 408 && v_count <= 415) ||
              (v_count >= 424 && v_count <= 431) ||
              (v_count >= 440 && v_count <= 447) ||
              (v_count >= 456 && v_count <= 463)            
             )
             )
        begin
          red = 4'b0100;      
          blue = 4'b0100;     // Middle gray dotted line
          grn = 4'b0100;   
        end
     
    end 
   end
  end
 
//                     ---------------
//--------------------/PADDLES MOTION/--------------------------
//                    ---------------

// ── parameters ────────────────────────────────────────────────
// Replace fixed PADDLE_SPEED with conditional:
wire signed [16:0] paddle_spd = noob_switch ? 17'sd6 : 17'sd9;

wire signed [16:0] lm_vel_manual = (lu && !ld) ? -paddle_spd :
                                   (ld && !lu) ?  paddle_spd : 17'sd0;

wire signed [16:0] rm_vel_manual = (ru && !rd) ? -paddle_spd :
                                   (rd && !ru) ?  paddle_spd : 17'sd0;
// ── AI velocity wires ─────────────────────────────────────────

// BEATABLE (hard_mode=0):
// reacts only when ball is close (h < 200) and moving left
// moves at ball speed - can be outrun on sharp angles
// drifts to center slowly when ball is away
wire signed [16:0] lm_vel_ai_easy =
    (dx < 0 && h < 17'sd200) ?
        ((k < lm - speed_y) ? -speed_y :
         (k > lm + speed_y) ?  speed_y : 17'sd0)
    :
        ((lm > 17'sd245) ? -17'sd3 :
         (lm < 17'sd235) ?  17'sd3 : 17'sd0);

// UNBEATABLE (hard_mode=1):
// reacts from halfway across court (h < 320)
// moves at speed_y + 4 - always faster than ball
// drifts to center at medium speed when ball is away
wire signed [16:0] lm_vel_ai_hard =
    (dx < 0 && h < 17'sd320) ?
        ((k < lm - speed_y) ? -(speed_y + 17'sd4) :
         (k > lm + speed_y) ?  (speed_y + 17'sd4) : 17'sd0)
    :
        ((lm > 17'sd245) ? -17'sd7 :
         (lm < 17'sd235) ?  17'sd7 : 17'sd0);

// ── select AI difficulty ───────────────────────────────────────
wire signed [16:0] lm_vel_ai = hard_mode ? lm_vel_ai_hard : lm_vel_ai_easy;

// ── select mode - AI or manual ─────────────────────────────────
wire signed [16:0] lm_vel = AI_mode ? lm_vel_ai : lm_vel_manual;
wire signed [16:0] rm_vel = rm_vel_manual;

// ── next position wires ────────────────────────────────────────
wire signed [16:0] lm_new = lm + lm_vel;
wire signed [16:0] rm_new = rm + rm_vel;

// ── paddle motion block ────────────────────────────────────────
always @ (posedge clk_60HZ or posedge rst) begin
    if (rst) begin
        lm <= 17'sd240;
        rm <= 17'sd240;
    end
    else if (!game_start) begin

        // LEFT - clamp handles top wall, bottom wall, powerup growth, AI
        if      (lm_new - p1_half < 17'sd8)   lm <= 17'sd8   + p1_half;
        else if (lm_new + p1_half > 17'sd471)  lm <= 17'sd471 - p1_half;
        else                                    lm <= lm_new;

        // RIGHT - same
        if      (rm_new - p2_half < 17'sd8)   rm <= 17'sd8   + p2_half;
        else if (rm_new + p2_half > 17'sd471)  rm <= 17'sd471 - p2_half;
        else                                    rm <= rm_new;

    end
end
    
  //                              ------------
  //-----------------------------/BALL MOTION/---------------------------------
  //                             ------------
  
   // ------------------------- collision detection wires -------------------------------
wire hit_right_wall   = (h_next + R >= 632);
wire hit_left_wall    = (h_next - R <= 7);
wire hit_right_paddle = (h + R < 616)
                     && (h_next + R >= 616)
                     && (k_next >= c - (speed_y * 3)) && (k_next <= d + (speed_y * 3));
                     
wire hit_left_paddle  = (h - R > 23)
                     && (h_next - R <= 23)
                     && (k_next >= a - (speed_y * 3)) && (k_next <= b + (speed_y * 3));
                        
wire hit_top_wall     = (k_next - R <= 7);
wire hit_bottom_wall  = (k_next + R >= 472);

wire game_active = !game_over_flag;

reg hit_right_wall_reg;  // remembers which wall was hit into MISS

// -------------------NSL-separate always @(*) block --------------------
always @(*) begin
    nxt_state = curr_state;
    if (!game_start && game_active) begin
        case(curr_state)
            IDLE:    nxt_state = (lu||ld||ru||rd)                ? PLAY : IDLE;
            PLAY:    nxt_state = (hit_right_wall||hit_left_wall) ? MISS : PLAY;
            MISS:    nxt_state = DELAY;
            DELAY:   nxt_state = (delay_cnt_pause >= 8'd120) ? IDLE : DELAY;
            default: nxt_state = IDLE;                                      
        endcase
    end
end

// ------------------ sequential block -------------------------
always @(posedge clk_60HZ or posedge rst) begin
    if (rst) begin
        curr_state        <= IDLE;
        h                 <= 17'sd320;
        k                 <= 17'sd240;
        dx                <= 17'sd0;
        dy                <= 17'sd0;
        speed_x           <= 17'sd5;
        speed_y           <= 17'sd5;
        p1_score          <= 2'd0;
        p2_score          <= 2'd0;
        game_over_flag    <= 1'b0;
        delay_cnt         <= 27'd0;
        hit_right_wall_reg <= 1'b0;
        p1_half      <= NORMAL_HALF;
        p2_half      <= NORMAL_HALF;
        p1_big_timer <= 10'd0;
        p2_big_timer <= 10'd0;
        pu_collected <= 1'b0;
    end
    
    else if (game_start) begin         // hold everything in reset state
        curr_state <= IDLE;
        h          <= 17'sd320;
        k          <= 17'sd240;
        dx         <= 17'sd0;
        dy         <= 17'sd0;
    end
    
    else begin
        curr_state <= nxt_state;

        if (game_active) begin
            case(curr_state)

                IDLE: begin
                    h  <= 17'sd320;
                    k  <= 17'sd240;
                    dx <= 17'sd0;
                    dy <= 17'sd0;
                    speed_x <= noob_switch ? 17'sd5 : 17'sd8;   
                    speed_y <= noob_switch ? 17'sd5 : 17'sd8;
                end

                PLAY: begin
                    // direction flips - independent of each other
                  if (hit_right_paddle) begin
                    dx <= -dx;
                    if (noob_switch) begin
                        // NOOB speeds - slower
                        if      (k >= c        && k < c + (d-c)/5)      begin speed_x<=17'sd8; speed_y<=17'sd8; end
                        else if (k >= c+(d-c)/5   && k < c+2*(d-c)/5)   begin speed_x<=17'sd6; speed_y<=17'sd6; end
                        else if (k >= c+2*(d-c)/5 && k < c+3*(d-c)/5)   begin speed_x<=17'sd5; speed_y<=17'sd5; end
                        else if (k >= c+3*(d-c)/5 && k < c+4*(d-c)/5)   begin speed_x<=17'sd6; speed_y<=17'sd6; end
                        else                                              begin speed_x<=17'sd8; speed_y<=17'sd8; end
                    end else begin
                        // HARD speeds - faster
                        if      (k >= c        && k < c + (d-c)/5)      begin speed_x<=17'sd11; speed_y<=17'sd11; end
                        else if (k >= c+(d-c)/5   && k < c+2*(d-c)/5)   begin speed_x<=17'sd9; speed_y<=17'sd9; end
                        else if (k >= c+2*(d-c)/5 && k < c+3*(d-c)/5)   begin speed_x<=17'sd8; speed_y<=17'sd8; end
                        else if (k >= c+3*(d-c)/5 && k < c+4*(d-c)/5)   begin speed_x<=17'sd9; speed_y<=17'sd9; end
                        else                                              begin speed_x<=17'sd11; speed_y<=17'sd11; end
                   end
               end

               else if (hit_left_paddle) begin
                dx <= -dx;
                if (noob_switch) begin
                    if      (k >= a        && k < a + (b-a)/5)      begin speed_x<=17'sd8; speed_y<=17'sd8; end
                    else if (k >= a+(b-a)/5   && k < a+2*(b-a)/5)   begin speed_x<=17'sd6; speed_y<=17'sd6; end
                    else if (k >= a+2*(b-a)/5 && k < a+3*(b-a)/5)   begin speed_x<=17'sd5; speed_y<=17'sd5; end
                    else if (k >= a+3*(b-a)/5 && k < a+4*(b-a)/5)   begin speed_x<=17'sd6; speed_y<=17'sd6; end
                    else                                              begin speed_x<=17'sd8; speed_y<=17'sd8; end
                end else begin
                    if      (k >= a        && k < a + (b-a)/5)      begin speed_x<=17'sd11; speed_y<=17'sd11; end
                    else if (k >= a+(b-a)/5   && k < a+2*(b-a)/5)   begin speed_x<=17'sd9; speed_y<=17'sd9; end
                    else if (k >= a+2*(b-a)/5 && k < a+3*(b-a)/5)   begin speed_x<=17'sd8; speed_y<=17'sd8; end
                    else if (k >= a+3*(b-a)/5 && k < a+4*(b-a)/5)   begin speed_x<=17'sd9; speed_y<=17'sd9; end
                    else                                              begin speed_x<=17'sd11; speed_y<=17'sd11; end
                end
              end
                   
                   // powerup collection 
                  if (pu_active &&
                     (h_next + R >= pu_x - 10) && (h_next - R <= pu_x + 10) &&
                     (k_next + R >= pu_y - 10) && (k_next - R <= pu_y + 10)) 
                    begin
    
                    pu_collected <= 1'b1;   // signal to power_ups module
    
                    if (dx > 0) 
                        begin       // ball moving RIGHT ,left paddle grows
                            p1_half      <= BIG_HALF;
                            p1_big_timer <= 10'd0;
                        end 
                    else 
                        begin          // ball moving LEFT, right paddle grows
                            p2_half      <= BIG_HALF;
                            p2_big_timer <= 10'd0;
                        end
                    end 
                   else 
                    begin
                        pu_collected <= 1'b0;   // clear every cycle unless hit 
                    end

                 // paddle size timers 
                if (p1_half == BIG_HALF) 
                    begin
                        if (p1_big_timer < BIG_TIME)
                            p1_big_timer <= p1_big_timer + 1;
                        else 
                            begin
                                p1_half      <= NORMAL_HALF;   // shrink back
                                p1_big_timer <= 10'd0;
                            end
                    end

                if (p2_half == BIG_HALF) 
                    begin
                        if (p2_big_timer < BIG_TIME)
                            p2_big_timer <= p2_big_timer + 1;
                        else 
                            begin
                                p2_half      <= NORMAL_HALF;   // shrink back
                                p2_big_timer <= 10'd0;
                            end
                    end
                   
                    if (hit_top_wall || hit_bottom_wall)
                        dy <= -dy;

                    // wall hit - reset position, latch which wall
                    if (hit_right_wall || hit_left_wall) begin
                        hit_right_wall_reg <= hit_right_wall;
                        h  <= 17'sd320;
                        k  <= 17'sd240;
                        dx <= 17'sd0;
                        dy <= 17'sd0;
                    end
                    
                    else begin
                        h <= h_next;
                        k <= k_next;
                    end
                end

                MISS: begin
                    // score update using registered wall flag
                    if (hit_right_wall_reg) begin
                        if (p1_score < 2'd3)
                            p1_score <= p1_score + 2'd1;
                    end
                    else begin
                        if (p2_score < 2'd3)
                            p2_score <= p2_score + 2'd1;
                    end
                end
                
               DELAY: begin
                // freeze everything
                 h  <= h;
                 k  <= k;
                 dx <= 0;
                 dy <= 0;
               end

            endcase
            
            if (curr_state == DELAY) begin
            if (delay_cnt_pause < 8'd120)
            delay_cnt_pause <= delay_cnt_pause + 1;
            end else begin
            delay_cnt_pause <= 0;
end

            // random direction on IDLE→PLAY transition (last assignment wins)
            if (curr_state == IDLE && nxt_state == PLAY) begin
                dx <= (dx_rdm >= 0) ? 17'sd1 : -17'sd1;
                dy <= (dy_rdm >= 0) ? 17'sd1 : -17'sd1;
            end
        end

        // game over delay - runs on clk_60HZ, 60 cycles = 1 second
        if ((p1_score == 2'd3 || p2_score == 2'd3) && !game_over_flag) begin
            if (delay_cnt < 27'd60)
                delay_cnt <= delay_cnt + 1;
            else
                game_over_flag <= 1'b1;
        end
    end
end

endmodule
`timescale 1ns / 1ps

module pong_game_3 (              //HERE MODIFICATIONS TO PONG_GAME_2 ADDED GAME OVER PART NEED TO CHECK WHETHER WORKS OR NOT
input clk,
input rst,
input lu,  // left paddle up motion assigned to P17
input ld,  // left paddle down motion assigned to P18
input ru,  // right paddle up motion assigned to M18
input rd,  // right paddle down motion assigned to M17
output [3:0] vga_r,
output [3:0] vga_b,
output [3:0] vga_g,
output hsync,
output vsync,
output [7:0] seg,
output [7:0] an
    );
    
    parameter R = 17'sd10;  // Radius of ball 10 px
    parameter INT = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100 ; //Finite states
    
    wire clk_120HZ;
    wire clk_500HZ;
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
    wire signed [16:0] h_next = h + dx; 
    wire signed [16:0] k_next = k + dy;
    reg [2:0] curr_state;
    reg [2:0] nxt_state;
    reg [1:0] p1_score;
    reg [1:0] p2_score;
    reg game_over_flag;
    reg [26:0] delay_cnt; // To hold roughly 1 second at 100MHz
    
    
    clk_500Hz uut_clk500hz ( .clk(clk), .rst(rst), .clk_500HZ(clk_500HZ) );
    
    clk_divider_120Hz clk_gen ( .clk(clk) , .rst(rst) , .clk_120HZ(clk_120HZ) );
    
    vga_controller dut ( .clk(clk) , .rst(rst) , .red(red) , .blue(blue) , .grn(grn)
      , .vga_r(vga_r) , .vga_b(vga_b) , .vga_g(vga_g) , .hsync(hsync) , .vsync(vsync) , 
      .h_count(h_count) , .v_count(v_count) );
      
   sevenseg_score scores (.clk_500hz(clk_500HZ), .pla1_score(p1_score), .pla2_score(p2_score), .an(an), .digit(seg) );
    
      
   //                     ----------------------------
   // -------------------/GENERATING BALL AND PADDLE/--------------------
   //                   ----------------------------
  
   wire signed [16:0] x;
   wire signed [16:0] y;
   wire signed [34:0] z;
   assign a = lm - 17'd35;
   assign b = lm + 17'd35;
   assign c = rm - 17'd35;
   assign d = rm + 17'd35;
   
   assign x = $signed(h_count) - $signed(h);
   assign y = $signed(v_count) - $signed(k);
   assign z = (x*x) + (y*y);
   
   always @(posedge clk) begin
    if (rst) begin
        game_over_flag <= 0;
        delay_cnt <= 0;
    end else if ((p1_score == 3 || p2_score == 3) && !game_over_flag) begin
        if (delay_cnt < 100_000_000) // 1 second delay
            delay_cnt <= delay_cnt + 1;
        else
            game_over_flag <= 1; // Now switch the screen
    end else if (p1_score < 3 && p2_score < 3) begin
        game_over_flag <= 0;
        delay_cnt <= 0;
    end
  end 
   
    always @ (*)
    begin
        red = 4'b0000;
        grn = 4'b0000;
        blue = 4'b0000;
    
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
                ((h_count > 445 && h_count < 465) && (v_count > 310 && v_count < 360))    // Diagonal Leg (Blocky)
        
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
                    ((h_count > 445 && h_count < 465) && (v_count > 310 && v_count < 360))   // Diagonal Leg (Blocky)
        
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
                        red = 4'b1111;
                        grn = 4'b1001;
                        blue = 4'b0000;         
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
                            {red, grn, blue} = 12'hFFF; // Teal color from your image
                            end
        
                    2'd1: begin // "1"
                         if ( ((v_count >= 24 && v_count <= 28) && (h_count >= 272 && h_count <= 277)) ||
                              ((v_count >= 29 && v_count <= 33) && (h_count >= 268 && h_count <= 284)) ||
                              ((v_count >= 34 && v_count <= 43) && (h_count >= 272 && h_count <= 277)) ||
                              ((v_count >= 44 && v_count <= 48) && (h_count >= 266 && h_count <= 284)) 
                             ) 
                            {red, grn, blue} = 12'hFFF;
                         end
        
                   2'd2: begin //  "2"
                        if ( ((v_count >= 24 && v_count <= 30) && (h_count >= 259 && h_count <= 279)) ||
                            ((v_count >= 31 && v_count <= 33) && (h_count >= 280 && h_count <= 284)) ||
                            ((v_count >= 34 && v_count <= 38) && (h_count >= 266 && h_count <= 284)) ||
                            ((v_count >= 39 && v_count <= 43) && (h_count >= 259 && h_count <= 265)) ||
                            ((v_count >= 44 && v_count <= 48) && (h_count >= 259 && h_count <= 284))
                            )
                            {red, grn, blue} = 12'hFFF;
                         end
        
                 2'd3: begin //  "3"
                        if ( ((v_count >= 24 && v_count <= 30) && (h_count >= 259 && h_count <= 279)) ||
                            ((v_count >= 31 && v_count <= 33) && (h_count >= 280 && h_count <= 284)) ||
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
            if ( ((v_count >= 24 && v_count <= 30) && (h_count >= 356 && h_count <= 376)) ||
                 ((v_count >= 31 && v_count <= 33) && (h_count >= 377 && h_count <= 382)) ||
                 ((v_count >= 34 && v_count <= 38) && (h_count >= 363 && h_count <= 382)) ||
                 ((v_count >= 39 && v_count <= 43) && (h_count >= 356 && h_count <= 362)) ||
                 ((v_count >= 44 && v_count <= 48) && (h_count >= 356 && h_count <= 382))
                )
                {red, grn, blue} = 12'hFFF;
        end
        
        2'd3: begin //  "3"
            if ( ((v_count >= 24 && v_count <= 30) && (h_count >= 356 && h_count <= 376)) ||
                 ((v_count >= 31 && v_count <= 33) && (h_count >= 377 && h_count <= 382)) ||
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
 
    //                     ---------------
    //--------------------/PADDLES MOTION/--------------------------
    //                    ---------------
    
    
     always @ (posedge clk_120HZ or posedge rst)
    begin
     if (rst)
      begin
       lm <= 17'sd240;
       rm <= 17'sd240;
       vy_l <= 17'sd0;
       vy_r <= 17'sd0;
      end
     else
      begin
      
      // ------------LEFT PADDLE-----------------
      
       if (lu && !ld)
        begin
         if (lm + vy_l <= 17'sd35 + 17'sd7) // if collide on top wall then stop othewise move left paddle up
          vy_l <= 0;
         else
          vy_l <= -17'sd1;
        end
        
      else if (ld && !lu)
        begin
         if (lm + 17'sd35 >= 17'sd472) // if collide on bottom wall then stop othewise move left paddle down
          vy_l <= 0;
         else
          vy_l <= 17'sd1;
        end
      else
       vy_l <= 17'sd0;
       
        // ------------RIGHT PADDLE-----------------
        
       if (ru && !rd)
        begin
         if (rm + vy_r <= 17'sd35 + 17'sd7) // if collide on top wall then stop othewise move right paddle up
          vy_r <= 0;
         else
          vy_r <= -17'sd1;
        end
        
      else if (rd && !ru)
        begin
         if (rm + 17'sd35 >= 17'sd472) // if collide on bottom wall then stop othewise move right paddle down
          vy_r <= 0;
         else
          vy_r <= 17'sd1;
        end
      else
       vy_r <= 17'sd0;
        
       lm <= lm + vy_l;   //update the position of left paddle
       rm <= rm + vy_r;   //update the position of right paddle
      end
    end   
    
  //                              ------------
  //-----------------------------/BALL MOTION/---------------------------------
  //                             ------------
  
  
  always @ ( posedge clk_120HZ or posedge rst )
    begin
        if(rst)
          begin
             curr_state <= INT;
             h <= 17'sd320;
             k <= 17'sd240;
          end
        else
          begin
           curr_state <= nxt_state;
           if (curr_state == INT) 
            begin
                h <= 17'sd320;
                k <= 17'sd240;
            end
          else 
           begin
            h <= h_next;
            k <= k_next;
           end
         end  
    end
   
   always @ ( * )
    begin
     nxt_state = curr_state;
     
     case(curr_state)
     
       INT: if (lu || ld || ru || rd)
             nxt_state = S1;
             
            
      S1: begin
            if (h_next + R >=632)                                         //collision with right wall , resets
                nxt_state = INT; 
           
            else if ((h_next + R >= 616) && (k_next >= c && k_next <= d ))     //collision with right paddle  
                   nxt_state = S4;
                     
            else if (k_next + R >= 472)                                         // collision with bottom wall
                    nxt_state = S2;
                    
           else nxt_state = S1;   
          end
           
       S2: begin
             if (h_next + R >=632)                                        //collision with right wall, resets
                nxt_state = INT;
                
             else  if ((h_next + R >= 616) && (k_next >= c && k_next <= d ))    //collision with right paddle
                nxt_state = S3;
                    
             else if (k_next - R <= 7)                                          //Collision with top wall
                nxt_state = S1;
                
             else nxt_state = S2;
           end 
           
       S3: begin
            if (h_next - R <= 7)                                        //collision with left wall, resets
                nxt_state = INT;
            
            else if ((h_next - R <= 23) && (k_next >= a && k_next <= b ))    //collision with left paddle
                nxt_state = S2;
                   
            else if (k_next - R <= 7)                                        //collision with top wall
                nxt_state = S4;
                
            else nxt_state = S3;  
           end
           
       S4: begin
             if (h_next - R <= 7)                                      //collision with left wall, resets
                nxt_state = INT; 
             
             else if ((h_next - R <= 23) && (k_next >= a && k_next <= b ))  //collision with left padldle
                nxt_state = S1;
                   
            else if (k_next + R >= 472)                                     //collision with bottom wall
                nxt_state = S3;
                
            else nxt_state = S4; 
           end
      
     endcase
    end
    
    always @ (*)
        begin
            dx = 17'sd0;
            dy = 17'sd0;
            
            case(curr_state)
              
                S1: begin
                        dx = 17'sd1;
                        dy = 17'sd1;
                    end
                    
                S2: begin
                        dx = 17'sd1;
                        dy = -17'sd1; 
                    end
                    
                S3: begin
                        dx = -17'sd1;
                        dy = -17'sd1;
                    end
                    
                S4: begin
                        dx = -17'sd1;
                        dy = 17'sd1;
                    end
                    
            endcase
        end
        
always @ (posedge clk_120HZ or posedge rst) //Update scores of players
    begin
        if(rst)
            begin
                p1_score <= 0;
                p2_score <= 0;
            end
        else
            begin
                if (curr_state != INT && nxt_state == INT)
                    begin
                        if (h_next + R >=632)  //collision with right wall
                            begin
                                if(p1_score < 2'd3)
                                    p1_score <= p1_score + 2'd1;
                            end
                    
                        else if (h_next - R <= 7)  //collision with left wall
                            begin
                                if(p2_score < 2'd3)
                                    p2_score <= p2_score + 2'd1;
                            end
                    end
            end
    end
    
endmodule
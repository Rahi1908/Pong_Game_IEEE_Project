`timescale 1ns / 1ps

module pong_game(
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
output vsync
    );
    
    parameter R = 17'sd40;  // Radius of ball 40 px
    parameter INT = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100 ; //Finite states
    
    wire clk_50HZ;
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
    
    
    clk_divider_50Hz clk_gen ( .clk(clk) , .rst(rst) , .clk_50HZ(clk_50HZ) );
    
    vga_controller dut ( .clk(clk) , .rst(rst) , .red(red) , .blue(blue) , .grn(grn)
      , .vga_r(vga_r) , .vga_b(vga_b) , .vga_g(vga_g) , .hsync(hsync) , .vsync(vsync) , 
      .h_count(h_count) , .v_count(v_count) );
    
      
   //                     ----------------------------
   // -------------------/GENERATING BALL AND PADDLE/--------------------
   //                   ----------------------------
  
   wire signed [16:0] x;
   wire signed [16:0] y;
   wire signed [34:0] z;
   assign a = lm - 17'd50;
   assign b = lm + 17'd50;
   assign c = rm - 17'd50;
   assign d = rm + 17'd50;
   
   assign x = $signed(h_count) - $signed(h);
   assign y = $signed(v_count) - $signed(k);
   assign z = (x*x) + (y*y);
   
    always @ (*)
    begin
     if ( z <= 35'sd1600 )
      begin
       red = 4'b1111;         // Red Ball
       blue = 4'b0000;  
       grn = 4'b0000;
      end
      
     else if ( (($signed(v_count) >= a && $signed(v_count) <= b) && ($signed(h_count) >= 9 && $signed(h_count) <= 19))         // left paddle
           || 
           (($signed(v_count) >= c && $signed(v_count) <= d) && ($signed(h_count) >= 621 && $signed(h_count) <= 631)) )    // right paddle
         begin
          red = 4'b0000;      
          blue = 4'b1111;     // paddles will look blue
          grn = 4'b0000;
         end
      else
       begin  
        red = 4'b0000;
        blue = 4'b0000;
        grn = 4'b0000;
       end
    end 
    
 
    //                     ---------------
    //--------------------/PADDLES MOTION/--------------------------
    //                    ---------------
    
    
    always @ (posedge clk_50HZ or posedge rst)
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
         if (lm + vy_l <= 17'sd50) // if collide on top wall then stop othewise move left paddle up
          vy_l <= 0;
         else
          vy_l <= -17'sd1;
        end
        
      else if (ld && !lu)
        begin
         if (lm + 17'sd50 >= 17'sd479) // if collide on bottom wall then stop othewise move left paddle down
          vy_l <= 0;
         else
          vy_l <= 17'sd1;
        end
      else
       vy_l <= 17'sd0;
       
        // ------------RIGHT PADDLE-----------------
        
       if (ru && !rd)
        begin
         if (rm + vy_r <= 17'sd50) // if collide on top wall then stop othewise move right paddle up
          vy_r <= 0;
         else
          vy_r <= -17'sd1;
        end
        
      else if (rd && !ru)
        begin
         if (rm + 17'sd50 >= 17'sd479) // if collide on bottom wall then stop othewise move right paddle down
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
  
   /* //in if-else way
    always @ (posedge clk_50HZ or posedge rst)
  begin
   if(rst)
    begin
     h <= 17'sd320; // Initialising center of ball as (320,240)px
     k <= 17'sd240;
     dx <= 17'sd1;
     dy <= 17'sd1;
    end
   else
    begin
      if ((k_next - R <= 0) || (k_next + R >= 479))
        dy <= -dy;
      
      if (((h_next - R <= 19) && (k_next + R >= a && k_next - R <= b )) 
         ||
          ((h_next + R >= 621) && (k_next + R >= c && k_next - R <= d )))
        dx <= -dx;
          
      if ((h_next - R <= 0) || (h_next + R >=639))
       begin
        h <= 17'sd320; // Initialising center of ball as (320,240)px
        k <= 17'sd240;
        dx <= 17'sd1;
        dy <= 17'sd1;
       end
      else 
       begin
       h <= h_next; // updating the direction of motion
       k <= k_next;
      end 
    end
  end  */
  
  
  // In FSM way
  
  always @ ( posedge clk_50HZ or posedge rst )
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
            if (h_next + R >=639)                                         //collision with right wall , resets
                nxt_state = INT; 
           
            else if ((h_next + R >= 621) && (k_next >= c && k_next <= d ))     //collision with right paddle  
                   nxt_state = S4;
                     
            else if (k_next + R >= 479)                                         // collision with bottom wall
                    nxt_state = S2;
                    
           else nxt_state = S1;   
          end
           
       S2: begin
             if (h_next + R >=639)                                        //collision with right wall, resets
                nxt_state = INT;
                
             else  if ((h_next + R >= 621) && (k_next >= c && k_next <= d ))    //collision with right paddle
                nxt_state = S3;
                    
             else if (k_next - R <= 0)                                          //Ccollision with top wall
                nxt_state = S1;
                
             else nxt_state = S2;
           end 
           
       S3: begin
            if (h_next - R <= 0)                                        //collision with left wall, resets
                nxt_state = INT;
            
            else if ((h_next - R <= 19) && (k_next >= a && k_next <= b ))    //collision with left paddle
                nxt_state = S2;
                   
            else if (k_next - R <= 0)                                        //collision with top wall
                nxt_state = S4;
                
            else nxt_state = S3;  
           end
           
       S4: begin
             if (h_next - R <= 0)                                      //collision with left wall, resets
                nxt_state = INT; 
             
             else if ((h_next - R <= 19) && (k_next >= a && k_next <= b ))  //collision with left padldle
                nxt_state = S1;
                   
            else if (k_next + R >= 479)                                     //collision with bottom wall
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
endmodule

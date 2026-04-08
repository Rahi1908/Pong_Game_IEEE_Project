`timescale 1ns / 1ps

module rough(

    );
    
always @ (*)
    begin
        red = 4'b0000;
        grn = 4'b0000;
        blue = 4'b0000;
        
        if(p1_score == 2'd3 || p2_score == 2'd3)
            begin
                if(p1_score == 2'd3)
                    begin
                        if()
                            begin
                            end
                    end
                    
                if(p2_score == 2'd3)
                    begin
                        if()
                            begin
                            end
                    end
            end
            
        else
            begin
                if()
                    begin
                    end
                    
                else if()
                    begin
                    end
                    
                else if()
                    begin
                    end
                    
                else if()
                    begin
                    end
                  
            end
    end
2'd0: begin //  "0"
            if ( ((v_count >= 24 && v_count <= 28) && (h_count >= 266 && h_count <= 281)) ||
                 ((v_count >= 29 && v_count <= 44) && ((h_count >= 264 && h_count <= 269) || (h_count >= 279 && h_count <= 284))) ||
                 ((v_count >= 24 && v_count <= 28) && (h_count >= 266 && h_count <= 281))
                ) 
                {red, grn, blue} = 12'h4CC; // Teal color from your image
        end

endmodule

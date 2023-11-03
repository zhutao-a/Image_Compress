module Shiftm (
    input  wire [5:0]   CombineLen      ,
    input  wire [63:0]  ShiftqBitstream ,
    input  wire [2:0]   m               ,
    input  wire [4:0]   q               ,

    output reg  [63:0]  NextBitstream   ,
    output wire [5:0]   NextLen         ,
    output reg  [7:0]   r                            
);

assign NextLen=(6'd0==CombineLen)?(6'd0):(CombineLen-((q+1)+((5'd23==q)?8:m)));

always @(*) begin
    if (q==5'd23) begin
        NextBitstream = (ShiftqBitstream<<8);
        r=ShiftqBitstream[63:56];
    end
    else begin
        case (m)
            3'd0:begin
                NextBitstream = (ShiftqBitstream<<0);
                r=8'd0;
            end
            3'd1:begin
                NextBitstream = (ShiftqBitstream<<1);
                r=ShiftqBitstream[63];
            end
            3'd2:begin
                NextBitstream = (ShiftqBitstream<<2);
                r= ShiftqBitstream[63:62];
            end
            3'd3:begin
                NextBitstream = (ShiftqBitstream<<3);
                r=ShiftqBitstream[63:61];  
            end
            3'd4:begin
                NextBitstream = (ShiftqBitstream<<4);
                r=ShiftqBitstream[63:60];   
            end
            3'd5:begin
                NextBitstream = (ShiftqBitstream<<5);
                r=ShiftqBitstream[63:59];  
            end
            3'd6:begin
                NextBitstream = (ShiftqBitstream<<6);
                r=ShiftqBitstream[63:58];   
            end
            3'd7:begin
                NextBitstream = (ShiftqBitstream<<7);
                r=ShiftqBitstream[63:57];  
            end
            default: begin
                NextBitstream = (ShiftqBitstream<<0);
                r=8'd0;
            end
        endcase
    end    
end

endmodule //Shiftm
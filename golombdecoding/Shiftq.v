module Shiftq (
    input  wire [63:0]  CombineBitstream,
    
    output reg  [63:0]  ShiftqBitstream     ,
    output reg  [4:0]   q
);

always @(*) begin
    casex(CombineBitstream[63:41])
        23'b1xxxxxxxxxxxxxxxxxxxxxx:begin 
            q=5'd0;
            ShiftqBitstream=(CombineBitstream<<1);
        end
        23'b01xxxxxxxxxxxxxxxxxxxxx:begin 
            q=5'd1;
            ShiftqBitstream = (CombineBitstream<<2);
        end
        23'b001xxxxxxxxxxxxxxxxxxxx:begin 
            q=5'd2;
            ShiftqBitstream = (CombineBitstream<<3);
        end
        23'b0001xxxxxxxxxxxxxxxxxxx:begin 
            q=5'd3;
            ShiftqBitstream = (CombineBitstream<<4);
        end
        23'b00001xxxxxxxxxxxxxxxxxx:begin
            q=5'd4;
            ShiftqBitstream=(CombineBitstream<<5);
        end
        23'b000001xxxxxxxxxxxxxxxxx:begin
            q=5'd5;
            ShiftqBitstream=(CombineBitstream<<6);
        end
        23'b0000001xxxxxxxxxxxxxxxx:begin
            q=5'd6;
            ShiftqBitstream=(CombineBitstream<<7);
        end
        23'b00000001xxxxxxxxxxxxxxx:begin
            q=5'd7;
            ShiftqBitstream=(CombineBitstream<<8);
        end
        23'b000000001xxxxxxxxxxxxxx:begin
            q=5'd8;
            ShiftqBitstream=(CombineBitstream<<9);
        end
        23'b0000000001xxxxxxxxxxxxx:begin
            q=5'd9;
            ShiftqBitstream=(CombineBitstream<<10);
        end
        23'b00000000001xxxxxxxxxxxx:begin
            q=5'd10;
            ShiftqBitstream=(CombineBitstream<<11);
        end
        23'b000000000001xxxxxxxxxxx:begin
            q=5'd11;
            ShiftqBitstream=(CombineBitstream<<12);
        end
        23'b0000000000001xxxxxxxxxx:begin
            q=5'd12;
            ShiftqBitstream=(CombineBitstream<<13);
        end
        23'b00000000000001xxxxxxxxx:begin
            q=5'd13;
            ShiftqBitstream=(CombineBitstream<<14);
        end
        23'b000000000000001xxxxxxxx:begin
            q=5'd14;
            ShiftqBitstream=(CombineBitstream<<15);
        end
        23'b0000000000000001xxxxxxx:begin
            q=5'd15;
            ShiftqBitstream=(CombineBitstream<<16);
        end
        23'b00000000000000001xxxxxx:begin
            q=5'd16;
            ShiftqBitstream=(CombineBitstream<<17);
        end
        23'b000000000000000001xxxxx:begin
            q=5'd17;
            ShiftqBitstream=(CombineBitstream<<18);
        end
        23'b0000000000000000001xxxx:begin
            q=5'd18;
            ShiftqBitstream=(CombineBitstream<<19);
        end
        23'b00000000000000000001xxx:begin
            q=5'd19;
            ShiftqBitstream=(CombineBitstream<<20);
        end
        23'b000000000000000000001xx:begin
            q=5'd20;
            ShiftqBitstream=(CombineBitstream<<21);
        end
        23'b0000000000000000000001x:begin
            q=5'd21;
            ShiftqBitstream=(CombineBitstream<<22);
        end
        23'b00000000000000000000001:begin
            q=5'd22;
            ShiftqBitstream=(CombineBitstream<<23);
        end
        23'b00000000000000000000000:begin
            q=5'd23;
            ShiftqBitstream=(CombineBitstream<<24);
        end
        default:begin
            q=5'd0;
            ShiftqBitstream=CombineBitstream;
        end
    endcase
end


endmodule //Shiftq
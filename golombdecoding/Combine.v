//对输入比特流进行拼接
module Combine (
    input  wire         clk                 ,
    input  wire         rstn                ,
    input  wire [31:0]  Bitstream           ,//输入进来的比特流
    input  wire         validin             ,//输入有效标志位
    input  wire [5:0]   LastLen             ,//上一轮译码后剩余比特流长度
    input  wire [63:0]  LastBitstream       ,//上一轮译码后比特流

    output reg  [5:0]   CombineLen          ,//拼接后比特流长度
    output reg  [63:0]  CombineBitstream     //拼接后比特流
);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        CombineLen<=6'd0;
    end else if(1'b1==validin) begin
        CombineLen<=LastLen+32;
    end
    else begin
        CombineLen<=LastLen;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        CombineBitstream<='d0;
    end else if(1'b1==validin) begin
        case (LastLen)
            6'd0:CombineBitstream<={Bitstream,32'd0};
            6'd1:CombineBitstream<={LastBitstream[63],Bitstream,31'd0};
            6'd2:CombineBitstream<={LastBitstream[63:62],Bitstream,30'd0};
            6'd3:CombineBitstream<={LastBitstream[63:61],Bitstream,29'd0};
            6'd4:CombineBitstream<={LastBitstream[63:60],Bitstream,28'd0};
            6'd5:CombineBitstream<={LastBitstream[63:59],Bitstream,27'd0};
            6'd6:CombineBitstream<={LastBitstream[63:58],Bitstream,26'd0};
            6'd7:CombineBitstream<={LastBitstream[63:57],Bitstream,25'd0};
            6'd8:CombineBitstream<={LastBitstream[63:56],Bitstream,24'd0};
            6'd9:CombineBitstream<={LastBitstream[63:55],Bitstream,23'd0};
            6'd10:CombineBitstream<={LastBitstream[63:54],Bitstream,22'd0};
            6'd11:CombineBitstream<={LastBitstream[63:53],Bitstream,21'd0};
            6'd12:CombineBitstream<={LastBitstream[63:52],Bitstream,20'd0};
            6'd13:CombineBitstream<={LastBitstream[63:51],Bitstream,19'd0};
            6'd14:CombineBitstream<={LastBitstream[63:50],Bitstream,18'd0};
            6'd15:CombineBitstream<={LastBitstream[63:49],Bitstream,17'd0};
            6'd16:CombineBitstream<={LastBitstream[63:48],Bitstream,16'd0};
            6'd17:CombineBitstream<={LastBitstream[63:47],Bitstream,15'd0};
            6'd18:CombineBitstream<={LastBitstream[63:46],Bitstream,14'd0};
            6'd19:CombineBitstream<={LastBitstream[63:45],Bitstream,13'd0};
            6'd20:CombineBitstream<={LastBitstream[63:44],Bitstream,12'd0};
            6'd21:CombineBitstream<={LastBitstream[63:43],Bitstream,11'd0};
            6'd22:CombineBitstream<={LastBitstream[63:42],Bitstream,10'd0};
            6'd23:CombineBitstream<={LastBitstream[63:41],Bitstream,9'd0};
            6'd24:CombineBitstream<={LastBitstream[63:40],Bitstream,8'd0};
            6'd25:CombineBitstream<={LastBitstream[63:39],Bitstream,7'd0};
            6'd26:CombineBitstream<={LastBitstream[63:38],Bitstream,6'd0};
            6'd27:CombineBitstream<={LastBitstream[63:37],Bitstream,5'd0};
            6'd28:CombineBitstream<={LastBitstream[63:36],Bitstream,4'd0};
            6'd29:CombineBitstream<={LastBitstream[63:35],Bitstream,3'd0};
            6'd30:CombineBitstream<={LastBitstream[63:34],Bitstream,2'd0};
            6'd31:CombineBitstream<={LastBitstream[63:33],Bitstream,1'd0};
            6'd32:CombineBitstream<={LastBitstream[63:32],Bitstream};
            default: CombineBitstream<='d0;
        endcase
    end
    else begin
        CombineBitstream<=LastBitstream;
    end
end

endmodule //Combine
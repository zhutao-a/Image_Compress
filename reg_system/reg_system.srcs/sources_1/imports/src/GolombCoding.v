module GolombCoding#(
    parameter limit = 32,
    parameter width = 8
)
(
    input  wire [width-1:0] n,
    input  wire [2:0]       m,

    output wire [5:0]       stream_len,
    output reg  [31:0]      stream
);

//商的值
reg[width-1:0]  q;
//编码值n - 余数
reg[width-1:0] tmp;
//编码余数
wire[width-1:0] r;
//添加1'b1和余数r的bitstream
reg[31:0] tmp_bitstream;
wire[width-1:0] tmp_n;

assign r          = n-tmp;
assign stream_len = (q>=23)?32:(q+1+m);
assign tmp_n=n-1;

always @(*) begin
    case (m)
        3'd0: q=(n>>0);
        3'd1: q=(n>>1);
        3'd2: q=(n>>2);
        3'd3: q=(n>>3);
        3'd4: q=(n>>4);
        3'd5: q=(n>>5);
        3'd6: q=(n>>6);
        3'd7: q=(n>>7);
        default: q='d0; 
    endcase
end

//编码值n - 余数
always @(*) begin
    case (m)
        3'd0:tmp=(q<<0);
        3'd1:tmp=(q<<1);
        3'd2:tmp=(q<<2);
        3'd3:tmp=(q<<3);
        3'd4:tmp=(q<<4);
        3'd5:tmp=(q<<5);
        3'd6:tmp=(q<<6);
        3'd7:tmp=(q<<7);
        default:tmp='d0; 
    endcase
end

always @(*) begin
    case (m)
        3'd0:tmp_bitstream={1'b1,31'd0};
        3'd1:tmp_bitstream={1'b1,r[0],30'd0};
        3'd2:tmp_bitstream={1'b1,r[1:0],29'd0};
        3'd3:tmp_bitstream={1'b1,r[2:0],28'd0};
        3'd4:tmp_bitstream={1'b1,r[3:0],27'd0};
        3'd5:tmp_bitstream={1'b1,r[4:0],26'd0};
        3'd6:tmp_bitstream={1'b1,r[5:0],25'd0};
        3'd7:tmp_bitstream={1'b1,r[6:0],24'd0};
        default:tmp_bitstream=32'd0;
    endcase
end

always @(*) begin
    if (q>=23) begin
        stream={23'd0,1'b1,tmp_n};
    end
    else begin
        case (q[4:0])
            5'd0:  stream=tmp_bitstream;
            5'd1:  stream=tmp_bitstream>>1;
            5'd2:  stream=tmp_bitstream>>2;
            5'd3:  stream=tmp_bitstream>>3;
            5'd4:  stream=tmp_bitstream>>4;
            5'd5:  stream=tmp_bitstream>>5;
            5'd6:  stream=tmp_bitstream>>6;
            5'd7:  stream=tmp_bitstream>>7;
            5'd8:  stream=tmp_bitstream>>8;
            5'd9:  stream=tmp_bitstream>>9;
            5'd10: stream=tmp_bitstream>>10;
            5'd11: stream=tmp_bitstream>>11;
            5'd12: stream=tmp_bitstream>>12;
            5'd13: stream=tmp_bitstream>>13;
            5'd14: stream=tmp_bitstream>>14;
            5'd15: stream=tmp_bitstream>>15;
            5'd16: stream=tmp_bitstream>>16;
            5'd17: stream=tmp_bitstream>>17;
            5'd18: stream=tmp_bitstream>>18;
            5'd19: stream=tmp_bitstream>>19;
            5'd20: stream=tmp_bitstream>>20;
            5'd21: stream=tmp_bitstream>>21;
            5'd22: stream=tmp_bitstream>>22;
            default: stream=32'd0;
        endcase
    end
end


endmodule //GolombCoding
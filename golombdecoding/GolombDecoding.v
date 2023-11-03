module GolombDecoding (
    input  wire         clk         ,
    input  wire         rstn        ,
    input  wire [31:0]  Bitstream   ,
    input  wire         validin     ,
    input  wire [2:0]   m           ,

    output wire         ready       ,
    output wire [8:0]   n
);

//译码前比特流
wire[63:0] LastBitstream;
//译码前比特流长度
wire[5:0]  LastLen;

//拼接后比特流长度
wire[5:0]  CombineLen;
//拼接后比特流
wire[63:0] CombineBitstream;

//移位商后的比特流
wire[63:0] ShiftqBitstream;
//商的值
wire[4:0]  q;

//编码值n - 余数
reg[7:0] tmp;

//译码后比特流
wire[63:0] NextBitstream;
//译码后比特流长度
wire[5:0] NextLen;
//编码余数
wire[7:0] r;

assign LastBitstream=NextBitstream;
assign LastLen=NextLen;

//输入有效时进行码流拼接
Combine Combine_u(
    .clk                (clk             ),
    .rstn               (rstn            ),
    .Bitstream          (Bitstream       ),
    .validin            (validin         ),
    .LastLen            (LastLen         ),
    .LastBitstream      (LastBitstream   ),
                         
    .CombineLen         (CombineLen      ),
    .CombineBitstream   (CombineBitstream) 
);

//取出商并进行移位
Shiftq Shiftq_u(
    .CombineBitstream   (CombineBitstream),

    .ShiftqBitstream    (ShiftqBitstream ),
    .q                  (q               )   
);

//取出余数并进行移位
Shiftm Shiftm_u(
    .CombineLen      (CombineLen     ),
    .ShiftqBitstream (ShiftqBitstream),
    .m               (m              ),
    .q               (q              ),
                                           
    .NextBitstream   (NextBitstream  ),
    .NextLen         (NextLen        ),
    .r               (r              )             
);

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
        default:tmp=(q<<0);
    endcase
end

assign ready=(LastLen<=32)?1:0;
assign n=(5'd23==q)?(r+1):(tmp+r);

endmodule





// Author : ZhuTao
// Date   : 2023.7.27
// Version: v2.0
module RunModeProcessing#(
    parameter width = 8,
    parameter limit = 32
)
(
	input  wire					clk		    	,
    input  wire					rstn            ,
    //输入因果模板
    input  wire                 start_encode	,
    input  wire                 run_valid       ,//游程编码标志位
    input  wire [width-1:0] 	Ix			   	,
    input  wire [width-1:0] 	Ra			   	,
    input  wire [width-1:0] 	Rb			   	,
    //游程长度
    input  wire [width-1:0]     cnt             ,
    //将游程长度编码和游程误差编码的比特流拼接
    output reg                  stream_valid    ,
    output wire [6:0]           stream_len      ,
    output reg  [2*limit-1:0]   stream	   	    
);

localparam RESET = 64;

reg             [12:0]          A[1:0];//存储变量,0->365,1->366
reg             [6:0]           N[1:0];
reg             [6:0]           Nn[1:0];

//当前clk
wire            [width-1:0] 	run_Ix,run_Ra,run_Rb;//在有效编码才给值
wire                            equal_Ix_Ra;//Ix与Ra是否相等
wire                            RItype;
wire            [8:0]           q;//取值仅有365,366
wire            [width:0]       Errval0;//[-255,255]
wire            [width:0]       Errval1;//[-255,255]
wire                            SIGN;
wire            [width-1:0]     Errval2;//[0,255]
wire            [width-1:0]     Errval;//[-128,127]

wire            [12:0]          A365;
wire            [12:0]          A366;
wire            [6:0]           N366;
wire            [12:0]          Aq;
wire            [6:0]           Nq;
wire            [6:0]           Nnq;
wire            [12:0]          TEMP;

reg             [2:0]           k;//游程误差编码参数
reg                             map;
wire            [width-2:0]     abs_Errval_temp;
reg             [width-1:0]     abs_Errval;
wire            [width-1:0]     EMErrval;//[0,256]

wire            [5:0]           EMErrval_stream_len;//MErrval进行golomb编码长度、比特流
wire            [31:0]          EMErrval_stream;

wire            [6:0]           Nnq0;//变量更新
wire            [12:0]          Aq0;
wire            [12:0]          Aq_out;
wire            [6:0]           Nnq_out;
wire            [6:0]           Nq0;
wire            [6:0]           Nq_out;
//下一个clk
wire            [width-1:0]     run_cnt;
wire            [5:0]           run_cnt_stream_len;//run_cnt进行golomb编码长度、比特流
wire            [31:0]          run_cnt_stream;
reg             [5:0]           EMErrval_stream_len_ff1;
reg             [31:0]          EMErrval_stream_ff1;
reg                             equal_Ix_Ra_ff1;//与stream_valid对齐

//当前clk
assign run_Ix = run_valid?Ix:'d0;
assign run_Ra = run_valid?Ra:'d0;
assign run_Rb = run_valid?Rb:'d0;

assign equal_Ix_Ra = (run_Ix==run_Ra)?1'b1:1'b0;
assign RItype      = (run_Ra==run_Rb)?1'b1:1'b0;
assign q           = RItype+9'd365;//取值仅有365,366

assign Errval0 = RItype?(Ix-Ra):(Ix-Rb);
assign Errval1 = (RItype==1'b0&&Ra>Rb)?(-Errval0):Errval0;
assign SIGN    = (RItype==1'b0&&Ra>Rb)?1'b1:1'b0;
assign Errval2 = Errval1[width]?(Errval1+9'd256):Errval1;
assign Errval  = (Errval2>=8'd128)?$signed(Errval2-9'd256):Errval2;

assign A365 = A[0];
assign A366 = A[1];
assign N366 = N[1];
assign Aq   = A[RItype];
assign Nq   = N[RItype];
assign Nnq  = Nn[RItype];
assign TEMP = RItype?(A366+(N366>>1)):A365;

assign abs_Errval_temp = Errval[width-1]?(-Errval):Errval;
assign EMErrval        = (abs_Errval<<1)-RItype-map;
//变量更新，在下个clk写入
assign Nnq0    = Errval[width-1]?(Nnq+1):Nnq;
assign Aq0     = Aq+((EMErrval+1-RItype)>>1);
assign Aq_out  = (Nq==RESET)?(Aq0>>1):Aq0;
assign Nnq_out = (Nq==RESET)?(Nnq0>>1):Nnq0;
assign Nq0     = (Nq==RESET)?(Nq>>1):Nq;
assign Nq_out  = Nq0+1;
//下一个clk
assign run_cnt    = stream_valid?cnt:'d0;
assign stream_len = (equal_Ix_Ra_ff1)?run_cnt_stream_len:(run_cnt_stream_len+EMErrval_stream_len_ff1);


//游程误差编码参数
always @(*) begin
	case ({(Nq+14'd0)<TEMP,((Nq+14'd0)<<1)<TEMP,((Nq+14'd0)<<2)<TEMP,((Nq+14'd0)<<3)<TEMP,((Nq+14'd0)<<4)<TEMP,((Nq+14'd0)<<5)<TEMP,((Nq+14'd0)<<6)<TEMP,((Nq+14'd0)<<7)<TEMP})
        8'b11111110: k=3'd7;
        8'b11111100: k=3'd6;
        8'b11111000: k=3'd5;
        8'b11110000: k=3'd4;
        8'b11100000: k=3'd3;
        8'b11000000: k=3'd2;
        8'b10000000: k=3'd1;
        8'b00000000: k=3'd0;
        default: k=3'd0;
    endcase
end

//计算MErrval参数
always @(*) begin
    if (k==0&&($signed(Errval)>0)&&(Nnq<<1)<Nq) begin
        map=1'b1;
    end
    else if (Errval[width-1]==1'b1&&(Nnq<<1)>=Nq) begin
        map=1'b1;
    end
    else if (Errval[width-1]==1'b1&&(k!='d0)) begin
        map=1'b1;
    end
    else begin
        map=1'b0; 
    end
end

always @(*) begin
	if (Errval[width-1]&&Errval[width-2:0]=='d0) begin
		abs_Errval=8'd128;
	end
	else begin
		abs_Errval=abs_Errval_temp;
	end
end

//对EMErrval进行golomb编码
GolombCoding#(
    .limit(limit),
    .width(width)
)
GolombCoding_EMErrval
(
    .n         (EMErrval),
    .m         (k),
                              
    .stream_len(EMErrval_stream_len),
    .stream    (EMErrval_stream)     
);

integer i;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for ( i=0 ;i<2 ;i=i+1 ) begin:init0
            A[i]<='d4;
            N[i]<='d1;
            Nn[i]<='d0;
        end
    end
    else if(start_encode) begin
        for ( i=0 ;i<2 ;i=i+1 ) begin:init1
            A[i]<='d4;
            N[i]<='d1;
            Nn[i]<='d0;
        end  
    end
    else if (run_valid&&(equal_Ix_Ra==1'b0)) begin
        A[RItype]<=Aq_out;
        N[RItype]<=Nq_out;
        Nn[RItype]<=Nnq_out;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        stream_valid<=1'b0;
    end
    else if (run_valid) begin
        stream_valid<=1'b1;
    end
	else begin
		stream_valid<=1'b0;
	end
end

//对run_cnt进行golomb编码
GolombCoding#(
    .limit(limit),
    .width(width)
)
GolombCoding_run_cnt
(
    .n         (run_cnt),
    .m         (2),
                              
    .stream_len(run_cnt_stream_len),
    .stream    (run_cnt_stream)     
);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        EMErrval_stream_len_ff1<='d0;
    end
    else if (run_valid) begin
        EMErrval_stream_len_ff1<=EMErrval_stream_len;
    end
    else begin
        EMErrval_stream_len_ff1<='d0;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        EMErrval_stream_ff1<='d0;
    end
    else if (run_valid) begin
        EMErrval_stream_ff1<=EMErrval_stream;
    end
    else begin
        EMErrval_stream_ff1<='d0;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        equal_Ix_Ra_ff1<=1'b0;
    end
    else if (run_valid) begin
        equal_Ix_Ra_ff1<=equal_Ix_Ra;
    end
    else begin
        equal_Ix_Ra_ff1<=1'b0;
    end
end

//将游程长度编码和游程误差编码的比特流拼接
always @(*) begin
    if (stream_valid==1'b0) begin
        stream='d0;
    end
    else if (equal_Ix_Ra_ff1) begin
        stream={run_cnt_stream,32'd0};
    end
    else begin
        case (run_cnt_stream_len)
            6'd0 : stream={EMErrval_stream_ff1,32'd0};
            6'd1 : stream={run_cnt_stream[31],EMErrval_stream_ff1,31'd0};
            6'd2 : stream={run_cnt_stream[31:30],EMErrval_stream_ff1,30'd0};
            6'd3 : stream={run_cnt_stream[31:29],EMErrval_stream_ff1,29'd0};
            6'd4 : stream={run_cnt_stream[31:28],EMErrval_stream_ff1,28'd0};
            6'd5 : stream={run_cnt_stream[31:27],EMErrval_stream_ff1,27'd0};
            6'd6 : stream={run_cnt_stream[31:26],EMErrval_stream_ff1,26'd0};
            6'd7 : stream={run_cnt_stream[31:25],EMErrval_stream_ff1,25'd0};
            6'd8 : stream={run_cnt_stream[31:24],EMErrval_stream_ff1,24'd0};
            6'd9 : stream={run_cnt_stream[31:23],EMErrval_stream_ff1,23'd0};
            6'd10: stream={run_cnt_stream[31:22],EMErrval_stream_ff1,22'd0};
            6'd11: stream={run_cnt_stream[31:21],EMErrval_stream_ff1,21'd0};
            6'd12: stream={run_cnt_stream[31:20],EMErrval_stream_ff1,20'd0};
            6'd13: stream={run_cnt_stream[31:19],EMErrval_stream_ff1,19'd0};
            6'd14: stream={run_cnt_stream[31:18],EMErrval_stream_ff1,18'd0};
            6'd15: stream={run_cnt_stream[31:17],EMErrval_stream_ff1,17'd0};
            6'd16: stream={run_cnt_stream[31:16],EMErrval_stream_ff1,16'd0};
            6'd17: stream={run_cnt_stream[31:15],EMErrval_stream_ff1,15'd0};
            6'd18: stream={run_cnt_stream[31:14],EMErrval_stream_ff1,14'd0};
            6'd19: stream={run_cnt_stream[31:13],EMErrval_stream_ff1,13'd0};
            6'd20: stream={run_cnt_stream[31:12],EMErrval_stream_ff1,12'd0};
            6'd21: stream={run_cnt_stream[31:11],EMErrval_stream_ff1,11'd0};
            6'd22: stream={run_cnt_stream[31:10],EMErrval_stream_ff1,10'd0};
            6'd23: stream={run_cnt_stream[31:9],EMErrval_stream_ff1,9'd0};
            6'd24: stream={run_cnt_stream[31:8],EMErrval_stream_ff1,8'd0};
            6'd25: stream={run_cnt_stream[31:7],EMErrval_stream_ff1,7'd0};
            6'd26: stream={run_cnt_stream[31:6],EMErrval_stream_ff1,6'd0};
            6'd27: stream={run_cnt_stream[31:5],EMErrval_stream_ff1,5'd0};
            6'd28: stream={run_cnt_stream[31:4],EMErrval_stream_ff1,4'd0};
            6'd29: stream={run_cnt_stream[31:3],EMErrval_stream_ff1,3'd0};
            6'd30: stream={run_cnt_stream[31:2],EMErrval_stream_ff1,2'd0};
            6'd31: stream={run_cnt_stream[31:1],EMErrval_stream_ff1,1'd0};
            6'd32: stream={run_cnt_stream,EMErrval_stream_ff1};
            default: stream='d0;
        endcase
    end    
end

endmodule //RunModeProcessing
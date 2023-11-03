// Author : ZhuTao
// Date   : 2023.7.27
// Version: v2.0
module RegularModeProcessing#(
	parameter width = 8,
	parameter limit = 32
)
(
	input  wire						clk				,
	input  wire						rstn	       	,
	//输入因果模板
	input  wire                 	start_encode	,
	input  wire                 	regular_valid   ,//正常编码标志位
	input  wire [width-1:0] 		Ix			   	,
	input  wire [width-1:0] 		Ra			   	,
	input  wire [width-1:0] 		Rb			   	,
	input  wire [width-1:0] 		Rc			   	,
	input  wire [width-1:0] 		Rd			   	,
    //将游程长度编码和游程误差编码的比特流拼接
	output reg                  	stream_valid    ,
	output wire [5:0]           	stream_len      ,
	output wire [limit-1:0]     	stream	   	    
);

localparam RESET = 64	;
localparam MAX_C = 127	;
localparam MIN_C = -128	;

//用寄存器代替数组
reg[13-1:0]	ram_a[365-1:0];
reg[9-1:0]	ram_b[365-1:0];
reg[8-1:0]	ram_c[365-1:0];
reg[7-1:0]	ram_n[365-1:0];

//当前clk
wire 		[width-1:0] regular_Ix,regular_Ra,regular_Rb,regular_Rc,regular_Rd;
wire  		[width:0] 	D0, D1, D2;//[-255,255]
wire 		[width-1:0] D0_abs, D1_abs, D2_abs;
reg  		[2:0] 		Q0_abs, Q1_abs, Q2_abs;//[0,4]
wire 		[5:0] 		temp_q;//9*Q0+Q1的绝对值和符号
wire 					temp_sign;
wire 		[8:0] 		q;
wire 					SIGN;
wire 		[width-1:0] MAX,MIN;//Ra、Rb中的最大值与最小值    
wire 		[width-1:0] Px0;//[0,255]
//下一个clk
//以下是由于ram ip 同一地址先写后读有问题才添加的
//-------------------------------------------------------------
reg  					flag;//对同一地址同时读写标志位
reg			[12:0] 		Aq_updated_ff1;//正值
reg			[8:0] 		Bq_updated_ff1;//[-128,127]
reg			[7:0]		Cq_updated_ff1;//[-128,127]
reg			[6:0] 		Nq_updated_ff1;//[1,64]
wire 		[12:0]      Aq;
wire 		[8:0]		Bq;
wire 		[7:0] 		Cq;//有符号数
wire 		[6:0]       Nq;
reg 	    [12:0] 		Aq_read; 
reg 	    [8:0] 		Bq_read; 
reg 	    [7:0]		Cq_read; 
reg 	    [6:0] 		Nq_read; 

//-------------------------------------------------------------
reg  		[width:0] 	Px0_ff1;//[0,255]
reg  					SIGN_ff1;
wire  		[width+1:0] Px1;//[-128,255+128]
wire 		[width-1:0] Px;//[0,255]
reg  		[width-1:0] Ix_ff1;
wire  		[width:0] 	Errval0;//[-255,255]
reg 	 	[width:0] 	Errval1;//[-255,255]
wire 	 	[width-1:0] Errval2;//[0,255]
wire 	 	[width-1:0] Errval;//[-128,127]

reg 		[2:0] 		k;//预测误差编码参数
reg 		[width-1:0] MErrval;//[0,255]

wire 	 	[9:0] 		Bq0;//变量更新
wire 		[width-2:0] abs_Errval_temp;
reg 		[width-1:0] abs_Errval;
reg  		[8:0]		q_ff1;
wire 		[12:0] 		Aq0;
reg  		[9:0] 		Bq1;
reg 		[6:0] 		Nq0;
wire  		[9:0] 		Bq2;
wire  		[9:0] 		Bq3;

reg  		[12:0]      Aq_updated;
wire 		[6:0]       Nq_updated;
reg  		[width-1:0] Cq_updated;	
reg  		[8:0]		Bq_updated;

assign regular_Ix = regular_valid?Ix:'d0;
assign regular_Ra = regular_valid?Ra:'d0;
assign regular_Rb = regular_valid?Rb:'d0;
assign regular_Rc = regular_valid?Rc:'d0;
assign regular_Rd = regular_valid?Rd:'d0;

assign D0 = regular_Rd - regular_Rb;
assign D1 = regular_Rb - regular_Rc;
assign D2 = regular_Rc - regular_Ra;

assign D0_abs = D0[width] ? (-D0) : D0;
assign D1_abs = D1[width] ? (-D1) : D1;
assign D2_abs = D2[width] ? (-D2) : D2;

assign temp_q    = (D0[width]==D1[width]||Q0_abs=='d0)?((Q0_abs<<3)+Q0_abs+Q1_abs):((Q0_abs<<3)+Q0_abs-Q1_abs);
assign temp_sign = (Q0_abs=='d0)?D1[width]:D0[width];
assign q         = (temp_sign==D2[width]||temp_q=='d0)?((temp_q<<3)+temp_q+Q2_abs):((temp_q<<3)+temp_q-Q2_abs);
assign SIGN      = (temp_q=='d0)?D2[width]:temp_sign;

assign MAX = (regular_Ra >= regular_Rb) ? regular_Ra : regular_Rb;
assign MIN = (regular_Ra <= regular_Rb) ? regular_Ra : regular_Rb;
assign Px0 = (regular_Rc >= MAX) ? MIN : ((regular_Rc <= MIN) ? MAX : (regular_Ra + regular_Rb+{(width){1'b0}} - regular_Rc));

//下一个clk
assign Aq = flag?Aq_updated_ff1:Aq_read;
assign Bq = flag?Bq_updated_ff1:Bq_read;
assign Cq = flag?Cq_updated_ff1:Cq_read;
assign Nq = flag?Nq_updated_ff1:Nq_read;

assign Px1 = (SIGN_ff1==1'b0) ? ($signed(Px0_ff1)+$signed(Cq)) : ($signed(Px0_ff1)-$signed(Cq));
assign Px  = ($signed(Px1)>9'sd255)?8'd255:(($signed(Px1)<0)?8'd0:Px1);
// assign Px  = (Px1[width+1]==1'b0&&Px1[width:0]>8'd255)?8'd255:((Px1[width+1]==1'b1)?8'd0:Px1[width-1:0]);
assign Errval0 = Ix_ff1-Px;
assign Errval2 = ($signed(Errval1)<0)?($signed(Errval1)+9'd256):Errval1;
assign Errval  = (Errval2>=8'd128)?(Errval2-9'd256):Errval2;

assign Bq0             = $signed(Bq)+$signed(Errval);
assign abs_Errval_temp = ($signed(Errval)<0)?(-Errval):Errval;
assign Aq0             = Aq+abs_Errval;
assign Nq_updated  	   = Nq0+1'd1;
assign Bq2 			   = $signed(Bq1)+Nq_updated;
assign Bq3 			   = $signed(Bq1)-Nq_updated;


always@(*) begin
	case ({D0_abs>=21,D0_abs>=7,D0_abs>=3,D0_abs>0})
		4'b1111:Q0_abs = 3'd4;
		4'b0111:Q0_abs = 3'd3;
		4'b0011:Q0_abs = 3'd2;
		4'b0001:Q0_abs = 3'd1;
		4'b0000:Q0_abs = 3'd0; 
		default:Q0_abs = 3'd0; 
	endcase
end

always@(*) begin
	case ({D1_abs>=21,D1_abs>=7,D1_abs>=3,D1_abs>0})
		4'b1111:Q1_abs = 3'd4;
		4'b0111:Q1_abs = 3'd3;
		4'b0011:Q1_abs = 3'd2;
		4'b0001:Q1_abs = 3'd1;
		4'b0000:Q1_abs = 3'd0;
		default:Q1_abs = 3'd0;
	endcase
end

always@(*) begin
	case ({D2_abs>=21,D2_abs>=7,D2_abs>=3,D2_abs>0})
		4'b1111:Q2_abs = 3'd4;
		4'b0111:Q2_abs = 3'd3;
		4'b0011:Q2_abs = 3'd2;
		4'b0001:Q2_abs = 3'd1;
		4'b0000:Q2_abs = 3'd0;
		default:Q2_abs = 3'd0;
	endcase
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		flag<=1'b0;
	end
	else if (q==q_ff1&&stream_valid&&regular_valid) begin
	   flag<=1'b1;
	end
	else begin
	   flag<=1'b0;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		Aq_updated_ff1<='d0;
	end
	else if (stream_valid) begin
	   Aq_updated_ff1<=Aq_updated;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		Bq_updated_ff1<='d0;
	end
	else if (stream_valid) begin
	   Bq_updated_ff1<=Bq_updated;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		Cq_updated_ff1<='d0;
	end
	else if (stream_valid) begin
	   Cq_updated_ff1<=Cq_updated;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		Nq_updated_ff1<='d0;
	end
	else if (stream_valid) begin
	   Nq_updated_ff1<=Nq_updated;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		Px0_ff1<='d0;
	end
	else if (regular_valid) begin
		Px0_ff1<=Px0;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		SIGN_ff1<=1'b0;
	end
	else if (regular_valid) begin
		SIGN_ff1<=SIGN;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		Ix_ff1<='d0;
	end
	else if (regular_valid) begin
		Ix_ff1<=regular_Ix;
	end
end

always @(*) begin
	if (SIGN_ff1) begin
		if (Errval0=='d0) begin
			Errval1='d0;
		end
		else begin
			Errval1=-Errval0;
		end
	end
	else begin
		Errval1=Errval0;
	end
end

//预测误差编码参数
always @(*) begin
	case ({(Nq+14'd0)<Aq,((Nq+14'd0)<<1)<Aq,((Nq+14'd0)<<2)<Aq,((Nq+14'd0)<<3)<Aq,((Nq+14'd0)<<4)<Aq,((Nq+14'd0)<<5)<Aq,((Nq+14'd0)<<6)<Aq,((Nq+14'd0)<<7)<Aq})
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


wire [9:0] twomulBq;
wire [width:0] twomulErrval;
assign twomulBq=$signed(Bq)+$signed(Bq);
assign twomulErrval=$signed(Errval)+$signed(Errval);

always @(*) begin
	if (k==3'd0&&$signed(twomulBq)<=$signed(-(Nq+10'd0))) begin
		if ($signed(Errval)>=0) begin
			MErrval=twomulErrval+1;
		end
		else begin
			MErrval=(-$signed(twomulErrval)-2'd2);
		end
	end
	else begin
		if ($signed(Errval)>=0) begin
			MErrval=twomulErrval;
		end
		else begin
			MErrval=(-$signed(twomulErrval)-1'd1);
		end
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

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		q_ff1<='d0;
	end
	else if(regular_valid) begin
		q_ff1<=q;
	end
end
 
always @(*) begin
	if (Nq==RESET) begin
		Aq_updated =(Aq0>>1);
		if ($signed(Bq0)>=0) begin
			Bq1=(Bq0>>1);
		end
		else begin
			Bq1=-((10'd1-Bq0)>>1);
		end
		Nq0=(Nq>>1);
	end
	else begin
		Aq_updated=Aq0;
		Bq1=Bq0;
		Nq0=Nq;
	end
end

always @(*) begin
	if ($signed(Bq1)<=$signed(-(Nq_updated+10'd0))) begin
		if ($signed(Cq)>MIN_C) begin
			Cq_updated=$signed(Cq)-1'd1;
		end
		else begin
			Cq_updated=Cq;
		end
		if ($signed(Bq2)<=$signed(-(Nq_updated+10'd0))) begin
			Bq_updated=$signed(-(Nq_updated+9'd0))+1'd1;
		end
		else begin
			Bq_updated=Bq2;
		end
	end
	else if ($signed(Bq1)>0) begin
		if ($signed(Cq)<MAX_C) begin
			Cq_updated=$signed(Cq)+1'd1;
		end
		else begin
			Cq_updated=Cq;
		end
		if ($signed(Bq3)>0) begin
			Bq_updated=0;
		end
		else begin
			Bq_updated=Bq3;
		end
	end
	else begin
		Cq_updated=Cq;
		Bq_updated=Bq1;
	end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        stream_valid<=1'b0;
    end
    else if (regular_valid) begin
        stream_valid<=1'b1;
    end
	else begin
		stream_valid<=1'b0;
	end
end

//对MErrval进行golomb编码
GolombCoding#(
    .limit(limit),
    .width(width)
)
GolombCoding_MErrval
(
    .n         (MErrval),
    .m         (k),
                              
    .stream_len(stream_len),
    .stream    (stream)     
);

//写寄存器
integer i;
always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
        for ( i=0 ;i<366 ;i=i+1 ) begin: init0
            ram_a[i]<='d4;
			ram_b[i]<='d0;
			ram_c[i]<='d0;
			ram_n[i]<='d1;
        end
	end
	else if (start_encode) begin
        for ( i=0 ;i<366 ;i=i+1 ) begin: init1
            ram_a[i]<='d4;
			ram_b[i]<='d0;
			ram_c[i]<='d0;
			ram_n[i]<='d1;
        end
	end
	else if (stream_valid) begin
		ram_a[q_ff1]<=Aq_updated;
		ram_b[q_ff1]<=Bq_updated;
		ram_c[q_ff1]<=Cq_updated;
		ram_n[q_ff1]<=Nq_updated;
	end
end

//读寄存器
always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		Aq_read<='d0; 
		Bq_read<='d0; 
		Cq_read<='d0; 
		Nq_read<='d0; 
	end
	else if (regular_valid) begin
		Aq_read<=ram_a[q]; 
		Bq_read<=ram_b[q]; 
		Cq_read<=ram_c[q]; 
		Nq_read<=ram_n[q];
	end
end

endmodule  //RegularModeProcessing

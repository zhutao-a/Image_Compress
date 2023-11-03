// Author : ZhuTao
// Date   : 2023.7.27
// Version: v2.0
module jpegls_encoder#(
	parameter width = 8,
	parameter limit = 32
)
(
	input  wire					clk		    	,
	input  wire					rstn			,
	//输入因果模板
	input  wire                 start_encode	,
	input  wire					sample_valid	,
	input  wire[width-1:0] 		Ix			   	,
	input  wire[width-1:0] 		Ra			   	,
	input  wire[width-1:0] 		Rb			   	,
	input  wire[width-1:0] 		Rc			   	,
	input  wire[width-1:0] 		Rd			   	,
	input  wire                 eoline			,
	//输入宽高通道
	input  wire [9-1:0]         tile_width      ,
	input  wire [9-1:0]         tile_height     ,
	input  wire [9-1:0]         sample_width    ,
	input  wire [9-1:0]         sample_height   ,
	input  wire [1:0]           sample_channel  ,
	
	output wire 				ready			,
	output wire 				stream_valid	,
	output wire [limit-1:0] 	stream			,
	output wire 				encode_done		,
	output wire [8:0] 			byte_count	
);

wire 				zero_gradient;//梯度为0，进入游程中断标志位
wire 				equal_Ix_Ra;

reg 				run_cnt_mode;//起始时equal_Ix_Ra==1,且不是进入runmode时刚好eoline
reg [width-1:0] 	run_cnt;//游程长度

reg 				run_valid;
reg 				regular_valid;

wire              	regular_stream_valid;//正常编码接口
wire [5:0]        	regular_stream_len;
wire [limit-1:0]  	regular_stream;

wire              	run_stream_valid;//游程编码接口
wire [6:0]        	run_stream_len;
wire [2*limit-1:0]	run_stream;


assign zero_gradient = (Rd==Rb&&Rb==Rc&&Rc==Ra)?1'b1:1'b0;
assign equal_Ix_Ra   = (Ix==Ra)?1'b1:1'b0;

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		run_cnt_mode<=1'b0;
	end
	else if (sample_valid) begin
		if (zero_gradient&&!run_cnt_mode&&equal_Ix_Ra&&!eoline) begin
			run_cnt_mode<=1'b1;
		end
		else if (!equal_Ix_Ra||eoline) begin
			run_cnt_mode<=1'b0;
		end
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		run_cnt<='d0;
	end
	else if (sample_valid) begin
		if (run_cnt_mode&&eoline&&equal_Ix_Ra) begin
			run_cnt<=run_cnt+2;
		end
		else if (run_cnt_mode) begin
			run_cnt<=run_cnt+1;
		end
		else if (zero_gradient&&equal_Ix_Ra&&eoline) begin
			run_cnt<='d1;
		end
		else begin
			run_cnt<='d0;
		end
	end
end

always @(*) begin
	if (sample_valid) begin
		if ((zero_gradient&&(!equal_Ix_Ra))||(zero_gradient&&eoline)||(run_cnt_mode&&(!equal_Ix_Ra||eoline))) begin
			run_valid=1'b1;
		end
		else begin
			run_valid=1'b0;
		end
	end
	else begin
		run_valid=1'b0;
	end
end

always @(*) begin
	if (sample_valid) begin
		if (!zero_gradient&&!run_cnt_mode) begin
			regular_valid=1'b1;
		end
		else begin
			regular_valid=1'b0;
		end
	end
	else begin
		regular_valid=1'b0;
	end
end

RegularModeProcessing#(
	.width(width),
	.limit(limit)
)
RegularModeProcessing_u0
(
	.clk		  	(clk		 			),
	.rstn	      	(rstn	     			),
	//输入因果模板
	.start_encode  	(start_encode   		),
	.regular_valid  (regular_valid  		),//正常编码标志位
	.Ix				(Ix						),
	.Ra				(Ra						),
	.Rb				(Rb						),
	.Rc				(Rc						),
	.Rd				(Rd						),
    //将游程长度编码和游程误差编码的比特流拼接
	.stream_valid	(regular_stream_valid	),
	.stream_len		(regular_stream_len		),
	.stream	   		(regular_stream	  		)     	    
);

RunModeProcessing#(
	.width(width),
	.limit(limit)
)
RunModeProcessing_u0
(
	.clk		  	(clk		 		),
	.rstn	      	(rstn	     		),
    //输入因果模板
    .start_encode  	(start_encode   	),
	.run_valid   	(run_valid			),//游程编码标志位
	.Ix				(Ix					),
	.Ra				(Ra					),
	.Rb				(Rb					),
    //游程长度
    .cnt			(run_cnt			),
    //将游程长度编码和游程误差编码的比特流拼接
    .stream_valid	(run_stream_valid	),
	.stream_len  	(run_stream_len  	),
	.stream	   	 	(run_stream	  		)   
);

stream_concat#(
	.width(width),
	.limit(limit)
)
stream_concat_u0
(
	.clk		  			(clk		 			),
	.rstn	      			(rstn	     			),
	.start_encode   		(start_encode   		),
	.tile_width    			(tile_width    			),
    .tile_height   			(tile_height   			),
	
	.sample_valid			(sample_valid			),
	.sample_width  			(sample_width  			),
    .sample_height 			(sample_height 			),
    .sample_channel			(sample_channel			),

	.regular_stream_valid	(regular_stream_valid	),
	.regular_stream_len  	(regular_stream_len  	),
	.regular_stream		 	(regular_stream		 	),
	.run_stream_valid		(run_stream_valid		),
	.run_stream_len  		(run_stream_len  		),
	.run_stream		 		(run_stream		 		),   	
	
	.ready		  			(ready		 			),
	.stream_valid 			(stream_valid			),
	.stream	      			(stream	     			),
	.encode_done  			(encode_done 			),
	.byte_count   			(byte_count  			)			
);


endmodule


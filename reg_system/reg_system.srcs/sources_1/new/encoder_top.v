// Author : ZhuTao
// Date   : 2023.7.27
// Version: v2.0
module encoder_top#(
	parameter width = 8                         ,
	parameter limit = 32
)
(
    input  wire                 clk             ,
    input  wire                 rstn            ,
    input  wire [9-1:0]         tile_width      ,
    input  wire [9-1:0]         tile_height     ,
       
    //输入axis
    input  wire [width*4-1:0]   s_axis_tdata    ,
    input  wire                 s_axis_tlast    ,
    input  wire                 s_axis_tvalid   ,
    output wire                 s_axis_tready   ,
    
    //输出axis
    output wire                 m_axis_tvalid   ,    
    input  wire                 m_axis_tready   ,   
    output wire [31:0]          m_axis_tdata    ,
    output wire                 m_axis_tlast    ,      

	output wire 				encode_done     ,
	output wire [8:0] 		    byte_count          
);

wire                sample_read_done;//从ram中读完一个tile数据
wire                start_encode;//ram接收完一个tile数据,开始编码流程

wire [1:0]          rchannel;
wire                rvalid  ;
wire [9-1:0]        raddr   ;
wire [width-1:0]    rdata   ;//从ram中读到的数据   

wire                sample_valid    ;
wire [width-1:0]    Ix              ;
wire [width-1:0]    Ra			    ;
wire [width-1:0]    Rb		        ;
wire [width-1:0]    Rc			    ;
wire [width-1:0]    Rd		        ;	
wire                sample_eoline   ;
wire [9-1:0]        sample_width    ;
wire [9-1:0]        sample_height   ;
wire [1:0]          sample_channel  ;

wire                ready           ;
wire 				stream_valid    ;
wire [limit-1:0] 	stream			; 


DataRamIn#(
    .width(width)
)
DataRamIn_u0
(
  .clk              (clk                ),
  .rstn             (rstn               ),
  .tile_width       (tile_width         ),
  .tile_height      (tile_height        ),
  .ram_start_receive(sample_read_done   ),
  .rchannel         (rchannel           ),
  .rvalid           (rvalid             ),
  .raddr            (raddr              ),

  //输入axis
  .s_axis_tdata     (s_axis_tdata       ),
  .s_axis_tlast     (s_axis_tlast       ),
  .s_axis_tvalid    (s_axis_tvalid      ),
  .s_axis_tready    (s_axis_tready      ),

  .ram_receive_done (start_encode       ),
  .rdata            (rdata              ) 
);


GetNextSample#(
    .width(width)
)
GetNextSample_u0
(
    .clk           (clk             ),
    .rstn          (rstn            ),
    .tile_width    (tile_width      ),
    .tile_height   (tile_height     ),
    .read_start    (start_encode    ),//开启读取数据
    .ready         (ready           ),//stream_concat传来的是否可以接收数据标志位
    .rdata         (rdata           ),
    
    //控制ram读取
    .rvalid        (rvalid          ),
    .rchannel      (rchannel        ),//0表示B通道1表示G通道2表示R通道3表示A通道
    .raddr         (raddr           ),
    //输出因果模板
    .read_done     (sample_read_done),
    .sample_valid  (sample_valid    ),//得到因果模板
    .sample_width  (sample_width    ),
    .sample_height (sample_height   ),
    .sample_channel(sample_channel  ),
    .sample_eoline (sample_eoline   ),
	.Ix            (Ix              ),
	.Ra			   (Ra			    ),
	.Rb		       (Rb		        ),
	.Rc			   (Rc			    ),
	.Rd			   (Rd		        )
);

jpegls_encoder#(
	.width(width),
	.limit(limit)
)
jpegls_encoder_uo
(
	.clk		    (clk		    ),
	.rstn	        (rstn	        ),
	//输入因果模板
	.start_encode   (start_encode   ),
    .sample_valid   (sample_valid   ),
	.Ix			    (Ix			    ),
	.Ra			    (Ra			    ),
	.Rb			    (Rb			    ),
	.Rc			    (Rc			    ),
	.Rd			    (Rd			    ),
	.eoline		    (sample_eoline  ),
	//输入宽高通道
	.tile_width     (tile_width     ),
    .tile_height    (tile_height    ),
	.sample_width   (sample_width   ),
    .sample_height  (sample_height  ),
    .sample_channel (sample_channel ),
	
	.ready		    (ready		    ),
	.stream_valid   (stream_valid   ),
	.stream		    (stream		    ),
	.encode_done    (encode_done    ),
	.byte_count	    (byte_count	    )    
);

DataRamOut #(
	.width(width),
	.limit(limit)
)
DataRamOut_u0
(
	.clk		    (clk		    ),
	.rstn	        (rstn	        ),
    
	.stream_valid   (stream_valid   ),
	.stream		    (stream		    ),
	.encode_done    (encode_done    ),

    //输出axis
    .m_axis_tvalid  (m_axis_tvalid  ),    
    .m_axis_tready  (m_axis_tready  ),   
    .m_axis_tdata   (m_axis_tdata   ),
    .m_axis_tlast   (m_axis_tlast   )     
);

endmodule

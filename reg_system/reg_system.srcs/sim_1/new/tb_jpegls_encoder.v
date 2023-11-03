`timescale 1ns / 1ps
module tb_jpegls_encoder();

parameter width = 8     ;
parameter limit = 32    ;

reg[32-1:0] pixeldata[8*8-1:0];  //像素数组

reg 				clk		      ;
reg 				rstn	      ;
//输入axis
wire[width*4-1:0]   s_axis_tdata  ;
reg                 s_axis_tlast  ;
reg                 s_axis_tvalid ;
wire                s_axis_tready ;
//输出axis
wire                m_axis_tvalid ;   
reg                 m_axis_tready ;
wire [31:0]         m_axis_tdata  ;
wire                m_axis_tlast  ;     

wire 				encode_done   ;
wire [8:0] 		    byte_count    ; 


reg [9-1:0] addr;

initial begin
    $readmemh("C:/Users/password_is_447/Desktop/image_compress/reg_system/reg_system.srcs/sim_1/new/pixeldata.v",pixeldata);
end

initial begin
    clk<=1'b0;
    rstn<=1'b0;
    m_axis_tready<=1'b1;
    s_axis_tlast<=1'b0;
    s_axis_tvalid<=1'b0;
    #10
    rstn<=1'b1;
    s_axis_tvalid<=1'b1;
end

always#5 clk=~clk;

assign s_axis_tdata=pixeldata[addr];

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        addr<='d0;
    end
    else if (s_axis_tready&&s_axis_tvalid&&addr==63) begin
        addr<='d0;
    end
    else if (s_axis_tready&&s_axis_tvalid) begin
        addr<=addr+1;
    end
end

encoder_top#(
	.width(width),
	.limit(limit)
)
encoder_top_u0
(
    .clk        (clk        )     ,
    .rstn       (rstn       )     ,
    .tile_width (8          )     ,
    .tile_height(8          )     ,
       
    //输入axis
    .s_axis_tdata  (s_axis_tdata )  ,
    .s_axis_tlast  (s_axis_tlast )  ,
    .s_axis_tvalid (s_axis_tvalid)  ,
    .s_axis_tready (s_axis_tready)  ,
    
    //输出axis
    .m_axis_tvalid (m_axis_tvalid )  ,    
    .m_axis_tready (m_axis_tready )  ,   
    .m_axis_tdata  (m_axis_tdata  )  ,
    .m_axis_tlast  (m_axis_tlast  )  ,      

	.encode_done  (encode_done  )   ,
	.byte_count   (byte_count   )       
);

endmodule

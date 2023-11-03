// Author : ZhuTao
// Date   : 2023.7.27
// Version: v2.0
module DataRamOut #(
	parameter width = 8,
	parameter limit = 32
)
(
    input  wire                 clk             ,
    input  wire                 rstn            ,
    
    input  wire 			    stream_valid    ,
    input  wire [limit-1:0] 	stream			,
    input  wire 				encode_done		,

    //输出axis
    output reg                  m_axis_tvalid   ,    
    input  wire                 m_axis_tready   ,   
    output wire [31:0]          m_axis_tdata    ,
    output reg                  m_axis_tlast       
);

reg   [9-1:0]       waddr;//ram写地址
reg   [9-1:0]       waddr_max;

reg                 read_lasting;
reg   [9-1:0]       raddr;

wire  [limit-1:0] 	dataout;

assign m_axis_tdata = {dataout[1*8-1:0*8],dataout[2*8-1:1*8],dataout[3*8-1:2*8],dataout[4*8-1:3*8]};


always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        waddr<='d0;
    end
    else if (encode_done) begin
        waddr<='d0;
    end
    else if (stream_valid) begin
        waddr<=waddr+1;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        waddr_max<='d0;
    end
    else if (encode_done) begin
        waddr_max<=waddr;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        read_lasting<=1'b0;
    end
    else if (encode_done) begin
        read_lasting<=1'b1;
    end
    else if (m_axis_tready&&(raddr==waddr_max-1)) begin
        read_lasting<=1'b0;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        raddr<='d0;
    end
    else if (m_axis_tready&&raddr==waddr_max) begin
        raddr<='d0;
    end
    else if (read_lasting&&m_axis_tready) begin
        raddr<=raddr+1;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        m_axis_tvalid<=1'b0;
    end
    else if (read_lasting&&m_axis_tready) begin
        m_axis_tvalid<=1'b1;
    end
    else if (m_axis_tready&&raddr==waddr_max) begin
        m_axis_tvalid<=1'b0;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        m_axis_tlast<=1'b0;
    end
    else if (m_axis_tready&&(raddr==waddr_max-1)) begin
        m_axis_tlast<=1'b1;
    end
    else if (m_axis_tready&&raddr==waddr_max) begin
        m_axis_tlast<=1'b0;
    end
end

ram_32x256 ram_out32x256 (
  //写端口
  .clka   (clk          ),// input wire clka
  .ena    (1'b1         ),// input wire ena
  .wea    (stream_valid ),// input wire [0 : 0] wea
  .addra  (waddr        ),// input wire [7 : 0] addra
  .dina   (stream       ),// input wire [31 : 0] dina
  //读端口
  .clkb   (clk          ),// input wire clkb
  .enb    (read_lasting&&m_axis_tready ),// input wire enb
  .addrb  (raddr        ),// input wire [7 : 0] addrb
  .doutb  (dataout      ) // output wire [31 : 0] doutb
);


endmodule
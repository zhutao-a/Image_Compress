// Author : ZhuTao
// Date   : 2023.7.27
// Version: v2.0
module DataRamIn#(
  parameter width   = 8
)
(
  input  wire               clk               ,
  input  wire               rstn              ,
  input  wire [9-1:0]       tile_width        ,
  input  wire [9-1:0]       tile_height       ,
  input  wire               ram_start_receive ,
  input  wire [1:0]         rchannel          ,
  input  wire               rvalid            ,
  input  wire [9-1:0]       raddr             ,
  
  //输入axis
  input  wire [width*4-1:0] s_axis_tdata      ,
  input  wire               s_axis_tlast      ,
  input  wire               s_axis_tvalid     ,
  output reg                s_axis_tready     ,
  
  output reg                ram_receive_done  ,
  output reg  [width-1:0]   rdata         
);

wire  [width*4-1:0] datain;//ram输入数据
wire                wvalid;//ram写有效
reg   [9-1:0]       waddr;//ram写地址
reg   [9-1:0]       width_cnt;//记录读取像素的位置
reg   [9-1:0]       height_cnt;
wire  [width*4-1:0] dataout;//ram读出数据
reg   [1:0]         dchannel;//与ram读取数据对齐

assign datain = s_axis_tdata;
assign wvalid = s_axis_tready&&s_axis_tvalid;

always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    width_cnt<='d0;
  end
  else if(wvalid&&(width_cnt==tile_width-1))begin
    width_cnt<='d0;
  end
  else if(wvalid) begin
    width_cnt<=width_cnt+1;
  end
end

always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    height_cnt<='d0;
  end
  else if(wvalid&&(width_cnt==tile_width-1)&&(height_cnt==tile_height-1))begin
    height_cnt<='d0;
  end
  else if(wvalid&&(width_cnt==tile_width-1)) begin
    height_cnt<=height_cnt+1;
  end
end

always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    waddr<='d0;
  end
  else if(wvalid&&(width_cnt==tile_width-1)&&(height_cnt==tile_height-1))begin
    waddr<='d0;
  end
  else if (wvalid) begin
    waddr<=waddr+1;
  end
end

always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    s_axis_tready<=1'b1;
  end
  else if(ram_start_receive)begin
    s_axis_tready<=1'b1;
  end
  else if(wvalid&&(width_cnt==tile_width-1)&&(height_cnt==tile_height-1))begin
    s_axis_tready<=1'b0;
  end
end

always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    ram_receive_done<=1'b0;
  end
  else if((width_cnt==tile_width-1)&&(height_cnt==tile_height-1)&&wvalid)begin
    ram_receive_done<=1'b1;
  end
  else begin
    ram_receive_done<=1'b0;
  end
end

ram_32x256 ram_in32x256 (
  //写端口
  .clka   (clk    ),// input wire clka
  .ena    (1'b1   ),// input wire ena
  .wea    (wvalid ),// input wire [0 : 0] wea
  .addra  (waddr  ),// input wire [7 : 0] addra
  .dina   (datain ),// input wire [31 : 0] dina
  //读端口
  .clkb   (clk    ),// input wire clkb
  .enb    (rvalid ),// input wire enb
  .addrb  (raddr  ),// input wire [7 : 0] addrb
  .doutb  (dataout) // output wire [31 : 0] doutb
);

always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    dchannel<=2'd0;
  end
  else begin
    dchannel<=rchannel;
  end
end

always @(*) begin
  case (dchannel)
    2'd0: rdata=dataout[1*width-1:0*width];
    2'd1: rdata=dataout[2*width-1:1*width];
    2'd2: rdata=dataout[3*width-1:2*width];
    2'd3: rdata=dataout[4*width-1:3*width];
    default:rdata=dataout[1*width-1:0*width]; 
  endcase
end

endmodule //GetNextSample
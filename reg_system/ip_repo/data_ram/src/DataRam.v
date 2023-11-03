  // Author : ZhuTao
  // Date   : 2023.7.10
  // Version: v1.0

module DataRam#(
  parameter width   = 8
)
(
  input  wire                     clk               ,
  input  wire                     rstn              ,
  
  input  wire [width*4-1:0]       s_axis_tdata      ,
  input  wire                     s_axis_tlast      ,
  input  wire                     s_axis_tvalid     ,
  output reg                      s_axis_tready     ,
  
  input  wire [8-1:0]             tile_width        ,
  input  wire [8-1:0]             tile_height       ,
  input  wire                     ram_start_receive ,
  output reg                      ram_receive_done  ,
   
  input  wire [1:0]               rchannel          ,
  input  wire                     rvalid            ,
  input  wire [8-1:0]             raddr             ,
  output reg  [width-1:0]         rdata         
);

//ram输入数据
wire[width*4-1:0] datain;
//ram写有效
wire wvalid;
//ram写地址
reg[8-1:0]  waddr;
//记录读取像素的位置
reg[8-1:0]  width_cnt;
reg[8-1:0]  height_cnt;
//ram读出数据
wire[width*4-1:0] dataout;
//与ram读取数据对齐
reg[1:0] dchannel;


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

blk_mem_gen_0 ram32x256 (
  //写端口
  .clka (clk),   // input wire clka
  .ena  (1'b1),    // input wire ena
  .wea  (wvalid),    // input wire [0 : 0] wea
  .addra(waddr),  // input wire [7 : 0] addra
  .dina (datain),   // input wire [31 : 0] dina
  //读端口
  .clkb(clk),    // input wire clkb
  .enb(rvalid),      // input wire enb
  .addrb(raddr),  // input wire [7 : 0] addrb
  .doutb(dataout)  // output wire [31 : 0] doutb
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
    2'd0: rdata=dataout[4*width-1:3*width];
    2'd1: rdata=dataout[3*width-1:2*width];
    2'd2: rdata=dataout[4*width-1:1*width];
    2'd3: rdata=dataout[1*width-1:0*width];
    default:rdata=dataout[4*width-1:3*width]; 
  endcase
end

endmodule //GetNextSample
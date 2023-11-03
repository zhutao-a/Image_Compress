// Author : ZhuTao
// Date   : 2023.7.27
// Version: v2.0
module apb_reg#(
    parameter data_width = 32,
    parameter addr_width = 32,
    parameter base_addr  = 32'h43C00000
)
(
    input  wire                     clk             ,
    input  wire                     rstn            ,

    //s_apb接口
    input  wire [addr_width-1:0]    s_apb_paddr     ,
    input  wire                     s_apb_penable   ,
    input  wire [2:0]               s_apb_pprot     ,
    output reg  [data_width-1:0]    s_apb_prdata    ,
    output wire                     s_apb_pready    ,
    input  wire                     s_apb_psel      ,
    output wire                     s_apb_pslverr   ,
    input  wire [3:0]               s_apb_pstrb     ,
    input  wire [data_width-1:0]    s_apb_pwdata    ,
    input  wire                     s_apb_pwrite    ,
    //编码输入结果
    input  wire                     encode_done     ,
    input  wire [8:0]               byte_len        ,

    output wire [9-1:0]             tile_width      ,
    output wire [9-1:0]             tile_height     ,
    output wire                     en_or_de        

);

//control_reg[0]判断是编码还是解码
//control_reg[1]判断编码后比特流长度是否写入成功
//control_reg[13:2]为编码后比特流长度
//control_reg[22:14]为tile_height
//control_reg[31:23]为tile_width
reg [data_width-1:0] control_reg;

wire read_valid;//读写有效标志位
wire[addr_width-1:0] addr;//读写地址
wire write_valid;

assign s_apb_pready = 1'b1;
assign s_apb_pslverr = 1'b0;

assign tile_width  = control_reg[31:23];
assign tile_height = control_reg[22:14];
assign en_or_de    = control_reg[0];

assign read_valid  = s_apb_psel&&~s_apb_pwrite;
assign addr        = s_apb_paddr-base_addr;
assign write_valid = s_apb_psel&&~s_apb_penable&&s_apb_pwrite;

//写控制寄存器
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        control_reg<='d0;
    end
    else if (write_valid&&addr==0) begin
        control_reg<=s_apb_pwdata;
    end
    else if (encode_done) begin
        control_reg[1]<=1'b1;
        control_reg[13:2]<=byte_len;
    end
end

//读寄存器，此处仅有控制寄存器
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        s_apb_prdata<='d0;
    end
    else if (read_valid) begin
        case (addr)
            32'd0:s_apb_prdata<=control_reg;
            default: s_apb_prdata<='d0;
        endcase
    end
end


endmodule

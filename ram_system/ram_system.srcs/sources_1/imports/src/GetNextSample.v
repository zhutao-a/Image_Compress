// Author : ZhuTao
// Date   : 2023.7.27
// Version: v2.0
module GetNextSample#(
    parameter width = 8
)
(
    input  wire             clk             ,
    input  wire             rstn            ,
    input  wire [9-1:0]     tile_width      ,
    input  wire [9-1:0]     tile_height     ,
    input  wire             read_start      ,//开启读取数据
    input  wire             ready           ,//stream_concat传来的是否可以接收数据标志位
    input  wire [width-1:0] rdata           , 

    output wire             rvalid          ,
    output reg  [1:0]       rchannel        ,//0表示B通道1表示G通道2表示R通道3表示A通道
    output wire [9-1:0]     raddr           ,
    output reg              read_done       ,
    output wire             sample_valid    ,//得到因果模板
    output reg  [9-1:0]     sample_width    ,
    output reg  [9-1:0]     sample_height   ,
    output reg  [1:0]       sample_channel  ,
    output reg              sample_eoline   ,
	output reg  [width-1:0] Ix              ,
	output reg  [width-1:0] Ra			    ,
	output reg  [width-1:0] Rb		        ,
	output reg  [width-1:0] Rc			    ,
	output reg  [width-1:0] Rd			
);

localparam buffer_depth=16+1;

reg [width-1:0]  row_bufferB[buffer_depth-1:0];//用来存储某一分量的一行，最低位row_buffer[0]表示左扩展
reg [width-1:0]  row_bufferG[buffer_depth-1:0];
reg [width-1:0]  row_bufferR[buffer_depth-1:0];
reg [width-1:0]  row_bufferA[buffer_depth-1:0];

reg             read_lasting;//读持续标志位
reg [9-1:0]     rwidth;//利用行列生成当前读ram地址
reg [9-1:0]     rheight;
reg [9-1:0]     base_raddr;
reg             reoline;

reg             dlasting;
wire            dvalid;//与rdata对齐(ram读取延迟一拍)
reg [9-1:0]     dwidth;
reg [9-1:0]     dheight;
reg [1:0]       dchannel;
reg             deoline; 

reg             samplelasting;

assign rvalid       = read_lasting&&ready;
assign raddr        = base_raddr+rwidth;
assign dvalid       = dlasting&&ready;
assign sample_valid = samplelasting&&ready;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        read_lasting<=1'b0;
    end
    else if (read_start) begin
        read_lasting<=1'b1;
    end
    else if (rvalid&&(rwidth==tile_width-1)&&(rchannel==2'd3)&&(rheight==tile_height-1)) begin
        read_lasting<=1'b0;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rwidth<='d0;
    end
    else if (rvalid) begin
        if (rwidth==tile_width-1) begin
            rwidth<='d0;
        end
        else begin
            rwidth<=rwidth+1;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rchannel<=2'd0;
    end
    else if (rvalid&&(rwidth==tile_width-1)) begin
        rchannel<=rchannel+1;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rheight<='d0;
    end
    else if (rvalid) begin
        if ((rwidth==tile_width-1)&&(rchannel==2'd3)&&(rheight==tile_height-1)) begin
            rheight<='d0;
        end
        else if ((rwidth==tile_width-1)&&(rchannel==2'd3)) begin
            rheight<=rheight+1;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        base_raddr<='d0;
    end
    else if (rvalid) begin
        if ((rwidth==tile_width-1)&&(rchannel==2'd3)&&(rheight==tile_height-1)) begin
            base_raddr<='d0;
        end
        else if ((rwidth==tile_width-1)&&(rchannel==2'd3)) begin
            base_raddr<=base_raddr+tile_width;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        reoline<=1'b0;
    end
    else if (rvalid&&(rwidth==tile_width-2)) begin
        reoline<=1'b1;
    end
    else if (rvalid&&(rwidth==tile_width-1)) begin
        reoline<=1'b0;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        read_done<=1'b0;
    end
    else if (rvalid&&(rwidth==tile_width-1)&&(rchannel==2'd3)&&(rheight==tile_height-1)) begin
        read_done<=1'b1;
    end
    else begin
        read_done<=1'b0;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        dlasting<=1'b0;
    end
    else if (read_lasting) begin
        dlasting<=1'b1;
    end
    else if (read_lasting==0&&ready==1) begin
        dlasting<=1'b0;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        dwidth<='d0;
    end
    else if (dvalid) begin
        dwidth<=rwidth;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        dheight<='d0;
    end
    else if (dvalid) begin
        dheight<=rheight;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        dchannel<='d0;
    end
    else if (dvalid) begin
        dchannel<=rchannel;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        deoline<='d0;
    end
    else if (dvalid) begin
        deoline<=reoline;
    end
end

integer i;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for (i = 0;i<buffer_depth ;i=i+1 ) begin:init_buffer1
            row_bufferB[i]<='d0;
            row_bufferG[i]<='d0;
            row_bufferR[i]<='d0;
            row_bufferA[i]<='d0;
        end
    end
    else if (read_start) begin
        for (i = 0;i<buffer_depth ;i=i+1 ) begin: init_buffer2
            row_bufferB[i]<='d0;
            row_bufferG[i]<='d0;
            row_bufferR[i]<='d0;
            row_bufferA[i]<='d0;
        end 
    end
    else if (dvalid&&(tile_height!=1)) begin
        if (dwidth=='d0) begin
            case (dchannel)
                2'd0: row_bufferB[0]<=row_bufferB[1];
                2'd1: row_bufferG[0]<=row_bufferG[1];
                2'd2: row_bufferR[0]<=row_bufferR[1];
                2'd3: row_bufferA[0]<=row_bufferA[1];
            endcase
        end
        case (dchannel)
            2'd0: row_bufferB[dwidth+1]<=rdata;
            2'd1: row_bufferG[dwidth+1]<=rdata;
            2'd2: row_bufferR[dwidth+1]<=rdata;
            2'd3: row_bufferA[dwidth+1]<=rdata;
        endcase
    end 
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        Ix<='d0;
    end
    else if (dvalid) begin
        Ix<=rdata; 
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        Ra<='d0;
    end
    else if (dvalid) begin
        if(dwidth=='d0) begin
            case (dchannel)
                2'd0: Ra<=row_bufferB[1];
                2'd1: Ra<=row_bufferG[1];
                2'd2: Ra<=row_bufferR[1];
                2'd3: Ra<=row_bufferA[1];
            endcase
        end
        else begin
            Ra<=Ix;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        Rc<='d0;
    end
    else if (dvalid) begin
        if (dwidth=='d0) begin
            case (dchannel)
                2'd0: Rc<=row_bufferB[0];
                2'd1: Rc<=row_bufferG[0];
                2'd2: Rc<=row_bufferR[0];
                2'd3: Rc<=row_bufferA[0];
            endcase
        end
        else begin
            Rc<=Rb;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        Rb<='d0;
    end
    else if (dvalid) begin
        if (dwidth=='d0) begin
            case (dchannel)
                2'd0: Rb<=row_bufferB[1];
                2'd1: Rb<=row_bufferG[1];
                2'd2: Rb<=row_bufferR[1];
                2'd3: Rb<=row_bufferA[1];
            endcase
        end
        else begin
            Rb<=Rd;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        Rd<='d0;
    end
    else if (dvalid&&(tile_height==1)) begin
        Rd<='d0;
    end
    else if (dvalid) begin
        if (dwidth==tile_width-1) begin
            case (dchannel)
                2'd0: Rd<=row_bufferB[tile_width];
                2'd1: Rd<=row_bufferG[tile_width];
                2'd2: Rd<=row_bufferR[tile_width];
                2'd3: Rd<=row_bufferA[tile_width];
            endcase
        end
        else begin
            case (dchannel)
                2'd0: Rd<=row_bufferB[dwidth+2];
                2'd1: Rd<=row_bufferG[dwidth+2];
                2'd2: Rd<=row_bufferR[dwidth+2];
                2'd3: Rd<=row_bufferA[dwidth+2];
            endcase
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        samplelasting<=1'b0;
    end
    else if (dlasting) begin
        samplelasting<=1'b1;
    end
    else if (dlasting==0&&ready==1) begin
        samplelasting<=1'b0;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        sample_width<='d0;
    end
    else if (sample_valid) begin
        sample_width<=dwidth;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        sample_height<='d0;
    end
    else if (sample_valid) begin
        sample_height<=dheight;
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        sample_channel<='d0;
    end
    else if (sample_valid) begin
        sample_channel<=dchannel;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        sample_eoline<=1'b0;
    end
    else if (sample_valid) begin
        sample_eoline<=deoline;
    end
end

endmodule //GetNextSample
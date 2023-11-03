// Author : ZhuTao
// Date   : 2023.7.27
// Version: v2.0
module stream_concat#(
	parameter width = 8,
	parameter limit = 32
)
(
	input  wire					clk					,
	input  wire					rstn				,
	input  wire                 start_encode		,
	input  wire [9-1:0]         tile_width      	,
    input  wire [9-1:0]         tile_height     	,
	input  wire 				sample_valid		,
	input  wire [9-1:0]         sample_width    	,
    input  wire [9-1:0]         sample_height   	,
    input  wire [1:0]           sample_channel  	,

	input wire                  regular_stream_valid,
	input wire [5:0]            regular_stream_len  ,
	input wire [limit-1:0]      regular_stream		,

	input wire                  run_stream_valid	,
	input wire [6:0]            run_stream_len  	,
	input wire [2*limit-1:0]    run_stream			,   	
	
	output wire 				ready				,
	output reg 					stream_valid		,
	output reg  [limit-1:0] 	stream				,
	output wire 				stream_last			,
	output reg 				    encode_done			,
	output reg  [8:0] 			byte_count			
);

reg		     		tile_last;
reg			 		lasting;

wire	[96-1:0] 	LastBitstream;
wire	[5:0]    	LastLen;

reg		[6:0]  		CombineLen;
reg		[96-1:0] 	CombineBitstream;

reg		[96-1:0] 	NextBitstream;
reg		[5:0]    	NextLen;

assign ready         = (LastLen<=32)?1'b1:1'b0;
assign LastLen       = NextLen;
assign LastBitstream = NextBitstream;
assign stream_last   = (lasting&&CombineLen<=32)?1'b1:1'b0;

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		CombineLen<='d0;
	end
	else if (start_encode) begin
		CombineLen<='d0;
	end
	else if (regular_stream_valid) begin
		CombineLen<=LastLen+regular_stream_len;
	end
	else if (run_stream_valid) begin
		CombineLen<=LastLen+run_stream_len;
	end
	else begin
		CombineLen<=LastLen;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		CombineBitstream<='d0;
	end
	else if (start_encode) begin
		CombineBitstream<='d0;
	end
	else if (regular_stream_valid) begin
		case (LastLen)
			6'd0 : CombineBitstream<={regular_stream,64'd0};
			6'd1 : CombineBitstream<={LastBitstream[95],regular_stream,63'd0};
			6'd2 : CombineBitstream<={LastBitstream[95:94],regular_stream,62'd0};
			6'd3 : CombineBitstream<={LastBitstream[95:93],regular_stream,61'd0};
			6'd4 : CombineBitstream<={LastBitstream[95:92],regular_stream,60'd0};
			6'd5 : CombineBitstream<={LastBitstream[95:91],regular_stream,59'd0};
			6'd6 : CombineBitstream<={LastBitstream[95:90],regular_stream,58'd0};
			6'd7 : CombineBitstream<={LastBitstream[95:89],regular_stream,57'd0};
			6'd8 : CombineBitstream<={LastBitstream[95:88],regular_stream,56'd0};
			6'd9 : CombineBitstream<={LastBitstream[95:87],regular_stream,55'd0};
			6'd10: CombineBitstream<={LastBitstream[95:86],regular_stream,54'd0};
			6'd11: CombineBitstream<={LastBitstream[95:85],regular_stream,53'd0};
			6'd12: CombineBitstream<={LastBitstream[95:84],regular_stream,52'd0};
			6'd13: CombineBitstream<={LastBitstream[95:83],regular_stream,51'd0};
			6'd14: CombineBitstream<={LastBitstream[95:82],regular_stream,50'd0};
			6'd15: CombineBitstream<={LastBitstream[95:81],regular_stream,49'd0};
			6'd16: CombineBitstream<={LastBitstream[95:80],regular_stream,48'd0};
			6'd17: CombineBitstream<={LastBitstream[95:79],regular_stream,47'd0};
			6'd18: CombineBitstream<={LastBitstream[95:78],regular_stream,46'd0};
			6'd19: CombineBitstream<={LastBitstream[95:77],regular_stream,45'd0};
			6'd20: CombineBitstream<={LastBitstream[95:76],regular_stream,44'd0};
			6'd21: CombineBitstream<={LastBitstream[95:75],regular_stream,43'd0};
			6'd22: CombineBitstream<={LastBitstream[95:74],regular_stream,42'd0};
			6'd23: CombineBitstream<={LastBitstream[95:73],regular_stream,41'd0};
			6'd24: CombineBitstream<={LastBitstream[95:72],regular_stream,40'd0};
			6'd25: CombineBitstream<={LastBitstream[95:71],regular_stream,39'd0};
			6'd26: CombineBitstream<={LastBitstream[95:70],regular_stream,38'd0};
			6'd27: CombineBitstream<={LastBitstream[95:69],regular_stream,37'd0};
			6'd28: CombineBitstream<={LastBitstream[95:68],regular_stream,36'd0};
			6'd29: CombineBitstream<={LastBitstream[95:67],regular_stream,35'd0};
			6'd30: CombineBitstream<={LastBitstream[95:66],regular_stream,34'd0};
			6'd31: CombineBitstream<={LastBitstream[95:65],regular_stream,33'd0};
			6'd32: CombineBitstream<={LastBitstream[95:64],regular_stream,32'd0};
			default:CombineBitstream<='d0; 
		endcase
	end
	else if (run_stream_valid) begin
		case (LastLen)
			6'd0 : CombineBitstream<={run_stream,32'd0};
			6'd1 : CombineBitstream<={LastBitstream[95],run_stream,31'd0};
			6'd2 : CombineBitstream<={LastBitstream[95:94],run_stream,30'd0};
			6'd3 : CombineBitstream<={LastBitstream[95:93],run_stream,29'd0};
			6'd4 : CombineBitstream<={LastBitstream[95:92],run_stream,28'd0};
			6'd5 : CombineBitstream<={LastBitstream[95:91],run_stream,27'd0};
			6'd6 : CombineBitstream<={LastBitstream[95:90],run_stream,26'd0};
			6'd7 : CombineBitstream<={LastBitstream[95:89],run_stream,25'd0};
			6'd8 : CombineBitstream<={LastBitstream[95:88],run_stream,24'd0};
			6'd9 : CombineBitstream<={LastBitstream[95:87],run_stream,23'd0};
			6'd10: CombineBitstream<={LastBitstream[95:86],run_stream,22'd0};
			6'd11: CombineBitstream<={LastBitstream[95:85],run_stream,21'd0};
			6'd12: CombineBitstream<={LastBitstream[95:84],run_stream,20'd0};
			6'd13: CombineBitstream<={LastBitstream[95:83],run_stream,19'd0};
			6'd14: CombineBitstream<={LastBitstream[95:82],run_stream,18'd0};
			6'd15: CombineBitstream<={LastBitstream[95:81],run_stream,17'd0};
			6'd16: CombineBitstream<={LastBitstream[95:80],run_stream,16'd0};
			6'd17: CombineBitstream<={LastBitstream[95:79],run_stream,15'd0};
			6'd18: CombineBitstream<={LastBitstream[95:78],run_stream,14'd0};
			6'd19: CombineBitstream<={LastBitstream[95:77],run_stream,13'd0};
			6'd20: CombineBitstream<={LastBitstream[95:76],run_stream,12'd0};
			6'd21: CombineBitstream<={LastBitstream[95:75],run_stream,11'd0};
			6'd22: CombineBitstream<={LastBitstream[95:74],run_stream,10'd0};
			6'd23: CombineBitstream<={LastBitstream[95:73],run_stream,9'd0};
			6'd24: CombineBitstream<={LastBitstream[95:72],run_stream,8'd0};
			6'd25: CombineBitstream<={LastBitstream[95:71],run_stream,7'd0};
			6'd26: CombineBitstream<={LastBitstream[95:70],run_stream,6'd0};
			6'd27: CombineBitstream<={LastBitstream[95:69],run_stream,5'd0};
			6'd28: CombineBitstream<={LastBitstream[95:68],run_stream,4'd0};
			6'd29: CombineBitstream<={LastBitstream[95:67],run_stream,3'd0};
			6'd30: CombineBitstream<={LastBitstream[95:66],run_stream,2'd0};
			6'd31: CombineBitstream<={LastBitstream[95:65],run_stream,1'd0};
			6'd32: CombineBitstream<={LastBitstream[95:64],run_stream};
			default:CombineBitstream<='d0; 
		endcase
	end
	else begin
		CombineBitstream<=LastBitstream;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		tile_last<=1'b0;
	end
	else if (sample_valid&&sample_width==(tile_width-1)&&sample_height==(tile_height-1)&&sample_channel==3) begin
		tile_last<=1'b1;
	end
	else begin
		tile_last<=1'b0;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		lasting<=1'b0;
	end
	else if (tile_last) begin
		lasting<=1'b1;
	end
	else if (lasting&&CombineLen<=32) begin
		lasting<=1'b0;
	end
end

always @(*) begin
	if (CombineLen>=32) begin
		stream_valid=1'd1;
	end
	else if (lasting&&CombineLen!=0) begin
		stream_valid=1'd1;
	end
	else begin
		stream_valid=1'd0;
	end
end

always @(*) begin
	if (stream_valid) begin
		stream=CombineBitstream[95:64];
	end
	else begin
		stream='d0;
	end
end

always @(*) begin
	if (stream_valid) begin
		NextBitstream=CombineBitstream<<32;
	end
	else begin
		NextBitstream=CombineBitstream;
	end
end

always @(*) begin
	if (stream_valid) begin
		if (CombineLen>=32) begin
			NextLen=CombineLen-32;
		end
		else begin
			NextLen='d0;
		end
	end
	else begin
		NextLen=CombineLen;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		encode_done<=1'b0;
	end
	else if (stream_last) begin
		encode_done<=1'b1;
	end
	else begin
		encode_done<=1'b0;
	end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		byte_count<='d0;
	end
	else if (encode_done) begin
		byte_count<='d0;
	end
	else if (stream_valid) begin
		if (CombineLen>24) begin
			byte_count<=byte_count+4;
		end
		else begin
			case ({CombineLen>8,CombineLen>16})
				2'b00: byte_count<=byte_count+1;
				2'b10: byte_count<=byte_count+2;
				2'b11: byte_count<=byte_count+3;
				default: byte_count<=byte_count;
			endcase
		end
	end 
end



endmodule
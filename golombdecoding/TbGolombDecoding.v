module GolombDecoding_tb;

reg  clk;
reg  rstn;
reg [31:0] Bitstream;
reg  validin;
reg [2:0] m;
wire ready;
wire [8:0] n;

always#5 clk = ! clk ;
  
initial begin
    clk<=1'b0;
    rstn<=1'b0;
    m<=3'd0;
    validin<=1'b0;
    Bitstream<=32'd0;
    #20
    rstn<=1'b1;
    m<=3'd3;
    Bitstream<=32'b0001101_00001110_000001000_00001001;
    #20
    validin<=1'b1;
    #10
    validin<=1'b0;
    #1000
    $finish;
end


GolombDecoding GolombDecoding_dut (
    .clk        (clk        ),
    .rstn       (rstn       ),
    .Bitstream  (Bitstream  ),
    .validin    (validin    ),
    .m          (m          ),

    .ready      (ready      ),
    .n          (n          )
);




endmodule

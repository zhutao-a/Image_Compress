`timescale 1ns / 1ps
module tb_test();


wire  [9:0] Bq1=-1;//[-128,255+128]
wire [6:0]    Nq_updated=32;

wire a;


assign a=($signed(Bq1)<=$signed(-Nq_updated))?1'b1:1'b0;

endmodule

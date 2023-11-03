`timescale 1ns / 1ps

module test(
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [7:0] c,
    
    output wire [31:0] out
);

assign out=a+b+0;

endmodule

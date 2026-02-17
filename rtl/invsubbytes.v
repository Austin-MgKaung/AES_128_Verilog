`timescale 1ns/1ps

module invsubbytes (
    input  wire       clk,
    input  wire [7:0]  in_byte,
    output wire [7:0]  out_byte
);

wire [7:0] inv_aff_out;
wire [7:0] inv_gf_out;

invaffine u_inv_aff (
    .clk      (clk),
    .in_byte  (in_byte),
    .out_byte (inv_aff_out)
);

inverse_gfm_byte u_inv_gf (
    .clk      (clk),
    .byte_in  (inv_aff_out),
    .byte_out (inv_gf_out)
);

assign out_byte = inv_gf_out;

endmodule




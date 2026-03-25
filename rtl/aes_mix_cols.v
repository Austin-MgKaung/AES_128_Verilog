`timescale 1ns/1ps
  `default_nettype none

  module aes_mix_cols (
      input  wire [31:0] col_in,
      output wire [31:0] col_out
  );
      wire [7:0] b0=col_in[31:24], b1=col_in[23:16], b2=col_in[15:8], b3=col_in[7:0];

      wire [7:0] xb0 = b0[7] ? ((b0<<1)^8'h1b) : (b0<<1);
      wire [7:0] xb1 = b1[7] ? ((b1<<1)^8'h1b) : (b1<<1);
      wire [7:0] xb2 = b2[7] ? ((b2<<1)^8'h1b) : (b2<<1);
      wire [7:0] xb3 = b3[7] ? ((b3<<1)^8'h1b) : (b3<<1);

      wire [7:0] d0 = xb0 ^ (xb1^b1) ^ b2       ^ b3;
      wire [7:0] d1 = b0  ^ xb1      ^ (xb2^b2) ^ b3;
      wire [7:0] d2 = b0  ^ b1       ^ xb2       ^ (xb3^b3);
      wire [7:0] d3 = (xb0^b0) ^ b1  ^ b2        ^ xb3;

      assign col_out = {d0, d1, d2, d3};

  endmodule
  `default_nettype wire

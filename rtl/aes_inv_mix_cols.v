
  `timescale 1ns/1ps
  `default_nettype none

  module aes_inv_mix_cols (
      input  wire [31:0] col_in,
      output wire [31:0] col_out
  );
      wire [7:0] a=col_in[31:24], b=col_in[23:16], c=col_in[15:8], d=col_in[7:0];

      function automatic [7:0] xtime(input [7:0] x);
          xtime = {x[6:0],1'b0} ^ (8'h1b & {8{x[7]}});
      endfunction

      wire [7:0] a2=xtime(a), a4=xtime(a2), a8=xtime(a4);
      wire [7:0] b2=xtime(b), b4=xtime(b2), b8=xtime(b4);
      wire [7:0] c2=xtime(c), c4=xtime(c2), c8=xtime(c4);
      wire [7:0] d2=xtime(d), d4=xtime(d2), d8=xtime(d4);

      wire [7:0] a9=a8^a, ab=a8^a2^a, ad=a8^a4^a, ae=a8^a4^a2;
      wire [7:0] b9=b8^b, bb=b8^b2^b, bd=b8^b4^b, be=b8^b4^b2;
      wire [7:0] c9=c8^c, cb=c8^c2^c, cd=c8^c4^c, ce=c8^c4^c2;
      wire [7:0] d9=d8^d, db=d8^d2^d, dd=d8^d4^d, de=d8^d4^d2;

      wire [7:0] o0 = ae^bb^cd^d9;
      wire [7:0] o1 = a9^be^cb^dd;
      wire [7:0] o2 = ad^b9^ce^db;
      wire [7:0] o3 = ab^bd^c9^de;

      assign col_out = {o0, o1, o2, o3};

  endmodule
  `default_nettype wire
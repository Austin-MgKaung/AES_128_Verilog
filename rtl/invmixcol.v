`timescale 1ns/1ps

module invmixcol (
    input  wire [31:0] col_in,
    output wire [31:0] col_out
);

    wire [7:0] a = col_in[31:24];
    wire [7:0] b = col_in[23:16];
    wire [7:0] c = col_in[15:8];
    wire [7:0] d = col_in[7:0];

    function automatic [7:0] xtime(input [7:0] x);
        begin
            xtime = {x[6:0],1'b0} ^ (8'h1B & {8{x[7]}});
        end
    endfunction

    wire [7:0] a2 = xtime(a);
    wire [7:0] a4 = xtime(a2);
    wire [7:0] a8 = xtime(a4);

    wire [7:0] b2 = xtime(b);
    wire [7:0] b4 = xtime(b2);
    wire [7:0] b8 = xtime(b4);

    wire [7:0] c2 = xtime(c);
    wire [7:0] c4 = xtime(c2);
    wire [7:0] c8 = xtime(c4);

    wire [7:0] d2 = xtime(d);
    wire [7:0] d4 = xtime(d2);
    wire [7:0] d8 = xtime(d4);

    wire [7:0] a9 = a8 ^ a;
    wire [7:0] aB = a8 ^ a2 ^ a;
    wire [7:0] aD = a8 ^ a4 ^ a;
    wire [7:0] aE = a8 ^ a4 ^ a2;

    wire [7:0] b9 = b8 ^ b;
    wire [7:0] bB = b8 ^ b2 ^ b;
    wire [7:0] bD = b8 ^ b4 ^ b;
    wire [7:0] bE = b8 ^ b4 ^ b2;

    wire [7:0] c9 = c8 ^ c;
    wire [7:0] cB = c8 ^ c2 ^ c;
    wire [7:0] cD = c8 ^ c4 ^ c;
    wire [7:0] cE = c8 ^ c4 ^ c2;

    wire [7:0] d9 = d8 ^ d;
    wire [7:0] dB = d8 ^ d2 ^ d;
    wire [7:0] dD = d8 ^ d4 ^ d;
    wire [7:0] dE = d8 ^ d4 ^ d2;

    wire [7:0] o0 = aE ^ bB ^ cD ^ d9;
    wire [7:0] o1 = a9 ^ bE ^ cB ^ dD;
    wire [7:0] o2 = aD ^ b9 ^ cE ^ dB;
    wire [7:0] o3 = aB ^ bD ^ c9 ^ dE;

    assign col_out = {o0, o1, o2, o3};

endmodule

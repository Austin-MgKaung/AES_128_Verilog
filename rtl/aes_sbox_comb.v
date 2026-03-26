`timescale 1ns/1ps
`default_nettype none

// Combinational AES S-box using GF(2^8) arithmetic.
// No ROM — computes the inverse via Fermat's little theorem (a^254)
// then applies the AES affine transformation.
// Irreducible polynomial: x^8 + x^4 + x^3 + x + 1 (0x11B)
//
// WHY: A ROM S-box synthesises to a deep MUX tree (~8 MUX levels).
//      This GF circuit uses XOR gates with shallower logic depth,
//      making it the dominant critical-path improvement.

module aes_sbox_comb (
    input  wire [7:0] in_byte,
    output wire [7:0] out_byte
);

    // ------------------------------------------------------------------
    // GF(2^8) multiply  a * b  mod  x^8+x^4+x^3+x+1
    // Implemented as: precompute a*x^0..a*x^7 (via xtime),
    //                 then select and XOR based on bits of b.
    // ------------------------------------------------------------------
    function [7:0] gf_mul;
        input [7:0] a, b;
        reg [7:0] p0,p1,p2,p3,p4,p5,p6,p7;
        begin
            p0 = a;
            p1 = p0[7] ? ({p0[6:0],1'b0} ^ 8'h1b) : {p0[6:0],1'b0};
            p2 = p1[7] ? ({p1[6:0],1'b0} ^ 8'h1b) : {p1[6:0],1'b0};
            p3 = p2[7] ? ({p2[6:0],1'b0} ^ 8'h1b) : {p2[6:0],1'b0};
            p4 = p3[7] ? ({p3[6:0],1'b0} ^ 8'h1b) : {p3[6:0],1'b0};
            p5 = p4[7] ? ({p4[6:0],1'b0} ^ 8'h1b) : {p4[6:0],1'b0};
            p6 = p5[7] ? ({p5[6:0],1'b0} ^ 8'h1b) : {p5[6:0],1'b0};
            p7 = p6[7] ? ({p6[6:0],1'b0} ^ 8'h1b) : {p6[6:0],1'b0};
            gf_mul = (b[0] ? p0 : 8'h0)
                   ^ (b[1] ? p1 : 8'h0)
                   ^ (b[2] ? p2 : 8'h0)
                   ^ (b[3] ? p3 : 8'h0)
                   ^ (b[4] ? p4 : 8'h0)
                   ^ (b[5] ? p5 : 8'h0)
                   ^ (b[6] ? p6 : 8'h0)
                   ^ (b[7] ? p7 : 8'h0);
        end
    endfunction

    // ------------------------------------------------------------------
    // Multiplicative inverse via Fermat's little theorem:
    //   a^(-1) = a^254  in GF(2^8)*    (and 0^254 = 0, handled naturally)
    //   a^254 = a^128 * a^64 * a^32 * a^16 * a^8 * a^4 * a^2
    //
    // Build powers by repeated squaring (squaring = gf_mul(x,x))
    // ------------------------------------------------------------------
    wire [7:0] a2   = gf_mul(in_byte, in_byte);
    wire [7:0] a4   = gf_mul(a2,      a2);
    wire [7:0] a8   = gf_mul(a4,      a4);
    wire [7:0] a16  = gf_mul(a8,      a8);
    wire [7:0] a32  = gf_mul(a16,     a16);
    wire [7:0] a64  = gf_mul(a32,     a32);
    wire [7:0] a128 = gf_mul(a64,     a64);

    wire [7:0] t1  = gf_mul(a128, a64);
    wire [7:0] t2  = gf_mul(t1,   a32);
    wire [7:0] t3  = gf_mul(t2,   a16);
    wire [7:0] t4  = gf_mul(t3,   a8);
    wire [7:0] t5  = gf_mul(t4,   a4);
    wire [7:0] inv = gf_mul(t5,   a2);   // = in_byte^254 = in_byte^(-1)

    // ------------------------------------------------------------------
    // Affine transformation (FIPS 197 §5.1.1):
    //   b[i] = inv[i] ^ inv[(i+4)%8] ^ inv[(i+5)%8]
    //                ^ inv[(i+6)%8] ^ inv[(i+7)%8] ^ c[i]
    //   c = 0x63 = 0110_0011  =>  c[0]=1, c[1]=1, c[5]=1, c[6]=1
    // ------------------------------------------------------------------
    assign out_byte[0] = inv[0]^inv[4]^inv[5]^inv[6]^inv[7]^1'b1;
    assign out_byte[1] = inv[1]^inv[5]^inv[6]^inv[7]^inv[0]^1'b1;
    assign out_byte[2] = inv[2]^inv[6]^inv[7]^inv[0]^inv[1];
    assign out_byte[3] = inv[3]^inv[7]^inv[0]^inv[1]^inv[2];
    assign out_byte[4] = inv[4]^inv[0]^inv[1]^inv[2]^inv[3];
    assign out_byte[5] = inv[5]^inv[1]^inv[2]^inv[3]^inv[4]^1'b1;
    assign out_byte[6] = inv[6]^inv[2]^inv[3]^inv[4]^inv[5]^1'b1;
    assign out_byte[7] = inv[7]^inv[3]^inv[4]^inv[5]^inv[6];

endmodule
`default_nettype wire

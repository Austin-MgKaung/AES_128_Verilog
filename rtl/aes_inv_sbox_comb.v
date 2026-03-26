`timescale 1ns/1ps
`default_nettype none

// Combinational AES Inverse S-box using GF(2^8) arithmetic.
// Mirrors aes_sbox_comb.v but for decryption.
//
// InvSubBytes(x) = GFInverse( InvAffine(x) )
//
// Step 1 — Inverse affine transformation (FIPS 197):
//   a_i = b_{(i+2)%8} XOR b_{(i+5)%8} XOR b_{(i+7)%8} XOR d_i
//   d = 0x05 = 0000_0101  (bits 0 and 2 set)
//
// Step 2 — Multiplicative inverse in GF(2^8) via a^254 (same as forward sbox)

module aes_inv_sbox_comb (
    input  wire [7:0] in_byte,
    output wire [7:0] out_byte
);

    // ------------------------------------------------------------------
    // GF(2^8) multiply — identical to aes_sbox_comb
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
            gf_mul = (b[0] ? p0 : 8'h0) ^ (b[1] ? p1 : 8'h0)
                   ^ (b[2] ? p2 : 8'h0) ^ (b[3] ? p3 : 8'h0)
                   ^ (b[4] ? p4 : 8'h0) ^ (b[5] ? p5 : 8'h0)
                   ^ (b[6] ? p6 : 8'h0) ^ (b[7] ? p7 : 8'h0);
        end
    endfunction

    // ------------------------------------------------------------------
    // Step 1: Inverse affine transformation
    //   a_i = b_{(i+2)%8} XOR b_{(i+5)%8} XOR b_{(i+7)%8} XOR d_i
    //   d = 0x05 => d[0]=1, d[2]=1, rest 0
    // ------------------------------------------------------------------
    wire [7:0] b = in_byte;
    wire [7:0] a;
    assign a[0] = b[2]^b[5]^b[7]^1'b1;
    assign a[1] = b[3]^b[6]^b[0]^1'b0;
    assign a[2] = b[4]^b[7]^b[1]^1'b1;
    assign a[3] = b[5]^b[0]^b[2]^1'b0;
    assign a[4] = b[6]^b[1]^b[3]^1'b0;
    assign a[5] = b[7]^b[2]^b[4]^1'b0;
    assign a[6] = b[0]^b[3]^b[5]^1'b0;
    assign a[7] = b[1]^b[4]^b[6]^1'b0;

    // ------------------------------------------------------------------
    // Step 2: Multiplicative inverse via a^254 (same as forward sbox)
    // ------------------------------------------------------------------
    wire [7:0] a2   = gf_mul(a,  a);
    wire [7:0] a4   = gf_mul(a2, a2);
    wire [7:0] a8   = gf_mul(a4, a4);
    wire [7:0] a16  = gf_mul(a8, a8);
    wire [7:0] a32  = gf_mul(a16,a16);
    wire [7:0] a64  = gf_mul(a32,a32);
    wire [7:0] a128 = gf_mul(a64,a64);

    wire [7:0] t1 = gf_mul(a128,a64);
    wire [7:0] t2 = gf_mul(t1,  a32);
    wire [7:0] t3 = gf_mul(t2,  a16);
    wire [7:0] t4 = gf_mul(t3,  a8);
    wire [7:0] t5 = gf_mul(t4,  a4);
    assign out_byte = gf_mul(t5, a2);

endmodule
`default_nettype wire

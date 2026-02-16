`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// AES inverse S-box (InvSubBytes) - algorithmic
// Pipeline: 1) inverse affine, 2) GF inverse (reuse inverse_gfm_byte)
// -----------------------------------------------------------------------------
module invsubbytes (
    input  wire           clk,  
    input  wire [7:0] byte_in,   // S-box output byte (ciphertext state)
    output reg [7:0] byte_out   // original state byte (before SubBytes)
);

    reg  [7:0] byte_in_r;
    wire [7:0] inv_aff_w;
    reg  [7:0] inv_aff_r;
    wire [7:0] inv_gf_w;
    reg  [7:0] inv_gf_r;

    always @(posedge clk) begin
        byte_in_r <= byte_in;
    end


    // Step 1: inverse affine transform
    invaffine u_inv_aff (
        .in_byte  (byte_in_r),
        .out_byte (inv_aff_w)
    );

    always @(posedge clk) begin
        inv_aff_r <= inv_aff_w;
    end

    // Step 2: inverse in GF(2^8)
    inverse_gfm_byte u_inv_gf (
        .byte_in  (after_inv_affine),
        .byte_out (after_gf_inv)
    );

    always @(posedge clk) begin
        inv_gf_r  <= inv_gf_w;
        byte_out  <= inv_gf_r;
    end


endmodule




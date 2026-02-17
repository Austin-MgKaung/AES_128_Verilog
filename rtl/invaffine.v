`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// AES inverse affine transform (for InvSubBytes)
// b = (s <<< 1) ^ (s <<< 3) ^ (s <<< 6) ^ 8'h05
// where s is the S-box output byte, and b is the multiplicative inverse.
// -----------------------------------------------------------------------------
module invaffine (
    input  wire       clk,
    input  wire [7:0] in_byte,
    output reg  [7:0] out_byte
);

    wire [7:0] r1 = {in_byte[6:0], in_byte[7]};
    wire [7:0] r3 = {in_byte[4:0], in_byte[7:5]};
    wire [7:0] r6 = {in_byte[1:0], in_byte[7:2]};

    wire [7:0] comb = in_byte ^ r1 ^ r3 ^ r6 ^ 8'h05;
    
    always @(posedge clk)
        out_byte <= comb;       
    
endmodule




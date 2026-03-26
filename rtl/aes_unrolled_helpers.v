`timescale 1ns/1ps
`default_nettype none

// =====================================================================
// Modular Helper Modules for Unrolled Architecture
// =====================================================================
// These are the building blocks used by aes128_encrypt_unrolled and
// aes128_decrypt_unrolled. They exist to show the modular design while
// maintaining friend's unrolled philosophy.
// =====================================================================

// AddRoundKey - XOR state with round key
module aes_add_round_key (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output wire [127:0] state_out
);
    assign state_out = state_in ^ round_key;
endmodule

// MixColumns - apply MixColumns to entire state (4 words)
module aes_mix_columns_full (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    wire [31:0] col0, col1, col2, col3;
    
    aes_mix_columns_word mc0 (.word_in(state_in[127:96]), .word_out(col0));
    aes_mix_columns_word mc1 (.word_in(state_in[95:64]),   .word_out(col1));
    aes_mix_columns_word mc2 (.word_in(state_in[63:32]),   .word_out(col2));
    aes_mix_columns_word mc3 (.word_in(state_in[31:0]),    .word_out(col3));
    
    assign state_out = {col0, col1, col2, col3};
endmodule

// MixColumns on a single 32-bit word
module aes_mix_columns_word (
    input  wire [31:0] word_in,
    output wire [31:0] word_out
);
    wire [7:0] b0 = word_in[31:24];
    wire [7:0] b1 = word_in[23:16];
    wire [7:0] b2 = word_in[15:8];
    wire [7:0] b3 = word_in[7:0];
    
    function [7:0] gmul2(input [7:0] x);
        gmul2 = (x[7] == 1'b1) ? ((x << 1) ^ 8'h1b) : (x << 1);
    endfunction
    
    wire [7:0] b0_2 = gmul2(b0);
    wire [7:0] b1_2 = gmul2(b1);
    wire [7:0] b2_2 = gmul2(b2);
    wire [7:0] b3_2 = gmul2(b3);
    
    wire [7:0] d0 = b0_2 ^ (b1_2 ^ b1) ^ b2 ^ b3;
    wire [7:0] d1 = b0 ^ b1_2 ^ (b2_2 ^ b2) ^ b3;
    wire [7:0] d2 = b0 ^ b1 ^ b2_2 ^ (b3_2 ^ b3);
    wire [7:0] d3 = (b0_2 ^ b0) ^ b1 ^ b2 ^ b3_2;
    
    assign word_out = {d0, d1, d2, d3};
endmodule

// InvMixColumns - apply InvMixColumns to entire state
module aes_inv_mix_columns_full (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    wire [31:0] col0, col1, col2, col3;
    
    aes_inv_mix_columns_word imc0 (.word_in(state_in[127:96]), .word_out(col0));
    aes_inv_mix_columns_word imc1 (.word_in(state_in[95:64]),   .word_out(col1));
    aes_inv_mix_columns_word imc2 (.word_in(state_in[63:32]),   .word_out(col2));
    aes_inv_mix_columns_word imc3 (.word_in(state_in[31:0]),    .word_out(col3));
    
    assign state_out = {col0, col1, col2, col3};
endmodule

// InvMixColumns on a single 32-bit word
module aes_inv_mix_columns_word (
    input  wire [31:0] word_in,
    output wire [31:0] word_out
);
    wire [7:0] b0 = word_in[31:24];
    wire [7:0] b1 = word_in[23:16];
    wire [7:0] b2 = word_in[15:8];
    wire [7:0] b3 = word_in[7:0];
    
    function [7:0] gmul(input [7:0] x, input [7:0] y);
        reg [15:0] result;
        integer i;
        begin
            result = 16'h0;
            for (i = 0; i < 8; i = i + 1) begin
                if (y[i]) result = result ^ (x << i);
                x = (x[7] == 1'b1) ? ((x << 1) ^ 8'h1b) : (x << 1);
            end
            gmul = result[7:0];
        end
    endfunction
    
    wire [7:0] d0 = gmul(b0, 8'h0e) ^ gmul(b1, 8'h0b) ^ gmul(b2, 8'h0d) ^ gmul(b3, 8'h09);
    wire [7:0] d1 = gmul(b0, 8'h09) ^ gmul(b1, 8'h0e) ^ gmul(b2, 8'h0b) ^ gmul(b3, 8'h0d);
    wire [7:0] d2 = gmul(b0, 8'h0d) ^ gmul(b1, 8'h09) ^ gmul(b2, 8'h0e) ^ gmul(b3, 8'h0b);
    wire [7:0] d3 = gmul(b0, 8'h0b) ^ gmul(b1, 8'h0d) ^ gmul(b2, 8'h09) ^ gmul(b3, 8'h0e);
    
    assign word_out = {d0, d1, d2, d3};
endmodule

`default_nettype wire

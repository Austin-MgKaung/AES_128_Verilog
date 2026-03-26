`timescale 1ns/1ps
`default_nettype none

// Optimised encryption round — 2 pipeline stages per round.
//
// Original aes_enc_round (1 stage):
//   state_in → [SubBytes → ShiftRows → MixColumns → XOR key] → register
//
// This module (2 stages):
//   Stage 1:  state_in → [SubBytes (GF comb)] → sb_reg
//   Stage 2:  sb_reg   → [ShiftRows → MixColumns → XOR key] → state_out
//
// WHY TWO STAGES:
//   SubBytes is the deepest part of the combinational path.
//   Adding a register after SubBytes cuts the critical path roughly in half.
//   The clock can then run ~2x faster at the cost of 2x pipeline latency.

module aes_enc_round_fast (
    input  wire        clk,
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output reg  [127:0] state_out
);

    // ------------------------------------------------------------------
    // STAGE 1 — SubBytes using GF arithmetic S-box (no ROM)
    // ------------------------------------------------------------------
    wire [7:0] sb0,sb1,sb2,sb3,sb4,sb5,sb6,sb7;
    wire [7:0] sb8,sb9,sb10,sb11,sb12,sb13,sb14,sb15;

    aes_sbox_comb s0  (.in_byte(state_in[127:120]),.out_byte(sb0));
    aes_sbox_comb s1  (.in_byte(state_in[119:112]),.out_byte(sb1));
    aes_sbox_comb s2  (.in_byte(state_in[111:104]),.out_byte(sb2));
    aes_sbox_comb s3  (.in_byte(state_in[103:96]), .out_byte(sb3));
    aes_sbox_comb s4  (.in_byte(state_in[95:88]),  .out_byte(sb4));
    aes_sbox_comb s5  (.in_byte(state_in[87:80]),  .out_byte(sb5));
    aes_sbox_comb s6  (.in_byte(state_in[79:72]),  .out_byte(sb6));
    aes_sbox_comb s7  (.in_byte(state_in[71:64]),  .out_byte(sb7));
    aes_sbox_comb s8  (.in_byte(state_in[63:56]),  .out_byte(sb8));
    aes_sbox_comb s9  (.in_byte(state_in[55:48]),  .out_byte(sb9));
    aes_sbox_comb s10 (.in_byte(state_in[47:40]),  .out_byte(sb10));
    aes_sbox_comb s11 (.in_byte(state_in[39:32]),  .out_byte(sb11));
    aes_sbox_comb s12 (.in_byte(state_in[31:24]),  .out_byte(sb12));
    aes_sbox_comb s13 (.in_byte(state_in[23:16]),  .out_byte(sb13));
    aes_sbox_comb s14 (.in_byte(state_in[15:8]),   .out_byte(sb14));
    aes_sbox_comb s15 (.in_byte(state_in[7:0]),    .out_byte(sb15));

    // Pipeline register between Stage 1 and Stage 2
    reg [127:0] sb_reg;
    always @(posedge clk)
        sb_reg <= {sb0,sb1,sb2,sb3,sb4,sb5,sb6,sb7,
                   sb8,sb9,sb10,sb11,sb12,sb13,sb14,sb15};

    // ------------------------------------------------------------------
    // STAGE 2 — ShiftRows + MixColumns + AddRoundKey
    // (identical combinational logic to original, but now has shallower
    //  critical path because SubBytes is in a separate stage)
    // ------------------------------------------------------------------
    wire [127:0] shifted;
    aes_shift_rows sr (
        .state_in(sb_reg),
        .state_out(shifted)
    );

    wire [31:0] mc0, mc1, mc2, mc3;
    aes_mix_cols mc_0 (.col_in(shifted[127:96]), .col_out(mc0));
    aes_mix_cols mc_1 (.col_in(shifted[95:64]),  .col_out(mc1));
    aes_mix_cols mc_2 (.col_in(shifted[63:32]),  .col_out(mc2));
    aes_mix_cols mc_3 (.col_in(shifted[31:0]),   .col_out(mc3));

    always @(posedge clk)
        state_out <= {mc0,mc1,mc2,mc3} ^ round_key;

endmodule
`default_nettype wire

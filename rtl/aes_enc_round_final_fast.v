`timescale 1ns/1ps
`default_nettype none

// Optimised final encryption round (round 10) — no MixColumns.
// Same 2-stage split as aes_enc_round_fast.
//
// Stage 1: SubBytes (GF comb S-box) → sb_reg
// Stage 2: ShiftRows → XOR round_key → state_out  (no MixColumns in round 10)

module aes_enc_round_final_fast (
    input  wire        clk,
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output reg  [127:0] state_out
);

    // ------------------------------------------------------------------
    // STAGE 1 — SubBytes
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

    reg [127:0] sb_reg;
    always @(posedge clk)
        sb_reg <= {sb0,sb1,sb2,sb3,sb4,sb5,sb6,sb7,
                   sb8,sb9,sb10,sb11,sb12,sb13,sb14,sb15};

    // ------------------------------------------------------------------
    // STAGE 2 — ShiftRows + AddRoundKey (no MixColumns in round 10)
    // ------------------------------------------------------------------
    wire [127:0] shifted;
    aes_shift_rows sr (
        .state_in(sb_reg),
        .state_out(shifted)
    );

    always @(posedge clk)
        state_out <= shifted ^ round_key;

endmodule
`default_nettype wire

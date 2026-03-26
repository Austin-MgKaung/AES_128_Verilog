`timescale 1ns/1ps
`default_nettype none

// =====================================================================
// AES-128 Encrypt — Unrolled Modular (stream-fast style)
// =====================================================================
//
// Architecture matches throughput-stream-fast but keeps every pipeline
// stage explicitly visible in this top-level module (unrolled style).
//
// STAGE SPLIT per round (same as aes_enc_round_fast):
//   Stage 1: SubBytes (GF arithmetic, no ROM)     → sb register
//   Stage 2: ShiftRows + MixColumns + AddRoundKey → state register
//
// Round 10 (final): Stage 2 has no MixColumns.
//
// PIPELINE:
//   Initial AddRoundKey : combinational (0 cycles)
//   Rounds 1-9          : 2 pipeline registers each (18 cycles)
//   Round 10            : 2 pipeline registers       (2 cycles)
//   Total latency       : 20 cycles
//
// CONTROL: 20-bit valid shift register — II = 1 cycle
// INTERFACE: valid_in / valid_out  (matches stream-fast)
// =====================================================================

module aes128_encrypt_unrolled (
    input  wire         clk,
    input  wire         rst,
    input  wire         valid_in,
    input  wire [127:0] key,
    input  wire [127:0] block_in,
    output wire         valid_out,
    output wire [127:0] block_out
);

    // ------------------------------------------------------------------
    // Key expansion chain
    // ------------------------------------------------------------------
    reg  [127:0] key_reg;
    always @(posedge clk) key_reg <= key;

    wire [127:0] rk1,  rk2,  rk3,  rk4,  rk5;
    wire [127:0] rk6,  rk7,  rk8,  rk9,  rk10;
    reg  [127:0] rk1r, rk2r, rk3r, rk4r, rk5r;
    reg  [127:0] rk6r, rk7r, rk8r, rk9r, rk10r;

    aes_key_exp ke1  (.clk(clk), .round(4'd1),  .key_in(key_reg), .key_out(rk1));
    aes_key_exp ke2  (.clk(clk), .round(4'd2),  .key_in(rk1r),   .key_out(rk2));
    aes_key_exp ke3  (.clk(clk), .round(4'd3),  .key_in(rk2r),   .key_out(rk3));
    aes_key_exp ke4  (.clk(clk), .round(4'd4),  .key_in(rk3r),   .key_out(rk4));
    aes_key_exp ke5  (.clk(clk), .round(4'd5),  .key_in(rk4r),   .key_out(rk5));
    aes_key_exp ke6  (.clk(clk), .round(4'd6),  .key_in(rk5r),   .key_out(rk6));
    aes_key_exp ke7  (.clk(clk), .round(4'd7),  .key_in(rk6r),   .key_out(rk7));
    aes_key_exp ke8  (.clk(clk), .round(4'd8),  .key_in(rk7r),   .key_out(rk8));
    aes_key_exp ke9  (.clk(clk), .round(4'd9),  .key_in(rk8r),   .key_out(rk9));
    aes_key_exp ke10 (.clk(clk), .round(4'd10), .key_in(rk9r),   .key_out(rk10));

    always @(posedge clk) begin
        rk1r  <= rk1;  rk2r  <= rk2;  rk3r  <= rk3;
        rk4r  <= rk4;  rk5r  <= rk5;  rk6r  <= rk6;
        rk7r  <= rk7;  rk8r  <= rk8;  rk9r  <= rk9;
        rk10r <= rk10;
    end

    // ------------------------------------------------------------------
    // Initial AddRoundKey (combinational — no pipeline register)
    // ------------------------------------------------------------------
    wire [127:0] s0;
    aes_add_round_key ark0 (.state_in(block_in), .round_key(key_reg), .state_out(s0));

    // ------------------------------------------------------------------
    // Round 1
    // Stage 1: SubBytes
    wire [127:0] s1a_sb; aes_subbytes_unrolled sb1  (.state_in(s0),    .state_out(s1a_sb));
    reg  [127:0] s1a;    always @(posedge clk) s1a <= s1a_sb;
    // Stage 2: ShiftRows + MixColumns + AddRoundKey
    wire [127:0] s1b_sr; aes_shift_rows        sr1  (.state_in(s1a),   .state_out(s1b_sr));
    wire [127:0] s1b_mc; aes_mix_columns_full  mc1  (.state_in(s1b_sr),.state_out(s1b_mc));
    wire [127:0] s1b_ak; aes_add_round_key     ark1 (.state_in(s1b_mc),.round_key(rk1r),.state_out(s1b_ak));
    reg  [127:0] s1b;    always @(posedge clk) s1b <= s1b_ak;

    // ------------------------------------------------------------------
    // Round 2
    wire [127:0] s2a_sb; aes_subbytes_unrolled sb2  (.state_in(s1b),   .state_out(s2a_sb));
    reg  [127:0] s2a;    always @(posedge clk) s2a <= s2a_sb;
    wire [127:0] s2b_sr; aes_shift_rows        sr2  (.state_in(s2a),   .state_out(s2b_sr));
    wire [127:0] s2b_mc; aes_mix_columns_full  mc2  (.state_in(s2b_sr),.state_out(s2b_mc));
    wire [127:0] s2b_ak; aes_add_round_key     ark2 (.state_in(s2b_mc),.round_key(rk2r),.state_out(s2b_ak));
    reg  [127:0] s2b;    always @(posedge clk) s2b <= s2b_ak;

    // ------------------------------------------------------------------
    // Round 3
    wire [127:0] s3a_sb; aes_subbytes_unrolled sb3  (.state_in(s2b),   .state_out(s3a_sb));
    reg  [127:0] s3a;    always @(posedge clk) s3a <= s3a_sb;
    wire [127:0] s3b_sr; aes_shift_rows        sr3  (.state_in(s3a),   .state_out(s3b_sr));
    wire [127:0] s3b_mc; aes_mix_columns_full  mc3  (.state_in(s3b_sr),.state_out(s3b_mc));
    wire [127:0] s3b_ak; aes_add_round_key     ark3 (.state_in(s3b_mc),.round_key(rk3r),.state_out(s3b_ak));
    reg  [127:0] s3b;    always @(posedge clk) s3b <= s3b_ak;

    // ------------------------------------------------------------------
    // Round 4
    wire [127:0] s4a_sb; aes_subbytes_unrolled sb4  (.state_in(s3b),   .state_out(s4a_sb));
    reg  [127:0] s4a;    always @(posedge clk) s4a <= s4a_sb;
    wire [127:0] s4b_sr; aes_shift_rows        sr4  (.state_in(s4a),   .state_out(s4b_sr));
    wire [127:0] s4b_mc; aes_mix_columns_full  mc4  (.state_in(s4b_sr),.state_out(s4b_mc));
    wire [127:0] s4b_ak; aes_add_round_key     ark4 (.state_in(s4b_mc),.round_key(rk4r),.state_out(s4b_ak));
    reg  [127:0] s4b;    always @(posedge clk) s4b <= s4b_ak;

    // ------------------------------------------------------------------
    // Round 5
    wire [127:0] s5a_sb; aes_subbytes_unrolled sb5  (.state_in(s4b),   .state_out(s5a_sb));
    reg  [127:0] s5a;    always @(posedge clk) s5a <= s5a_sb;
    wire [127:0] s5b_sr; aes_shift_rows        sr5  (.state_in(s5a),   .state_out(s5b_sr));
    wire [127:0] s5b_mc; aes_mix_columns_full  mc5  (.state_in(s5b_sr),.state_out(s5b_mc));
    wire [127:0] s5b_ak; aes_add_round_key     ark5 (.state_in(s5b_mc),.round_key(rk5r),.state_out(s5b_ak));
    reg  [127:0] s5b;    always @(posedge clk) s5b <= s5b_ak;

    // ------------------------------------------------------------------
    // Round 6
    wire [127:0] s6a_sb; aes_subbytes_unrolled sb6  (.state_in(s5b),   .state_out(s6a_sb));
    reg  [127:0] s6a;    always @(posedge clk) s6a <= s6a_sb;
    wire [127:0] s6b_sr; aes_shift_rows        sr6  (.state_in(s6a),   .state_out(s6b_sr));
    wire [127:0] s6b_mc; aes_mix_columns_full  mc6  (.state_in(s6b_sr),.state_out(s6b_mc));
    wire [127:0] s6b_ak; aes_add_round_key     ark6 (.state_in(s6b_mc),.round_key(rk6r),.state_out(s6b_ak));
    reg  [127:0] s6b;    always @(posedge clk) s6b <= s6b_ak;

    // ------------------------------------------------------------------
    // Round 7
    wire [127:0] s7a_sb; aes_subbytes_unrolled sb7  (.state_in(s6b),   .state_out(s7a_sb));
    reg  [127:0] s7a;    always @(posedge clk) s7a <= s7a_sb;
    wire [127:0] s7b_sr; aes_shift_rows        sr7  (.state_in(s7a),   .state_out(s7b_sr));
    wire [127:0] s7b_mc; aes_mix_columns_full  mc7  (.state_in(s7b_sr),.state_out(s7b_mc));
    wire [127:0] s7b_ak; aes_add_round_key     ark7 (.state_in(s7b_mc),.round_key(rk7r),.state_out(s7b_ak));
    reg  [127:0] s7b;    always @(posedge clk) s7b <= s7b_ak;

    // ------------------------------------------------------------------
    // Round 8
    wire [127:0] s8a_sb; aes_subbytes_unrolled sb8  (.state_in(s7b),   .state_out(s8a_sb));
    reg  [127:0] s8a;    always @(posedge clk) s8a <= s8a_sb;
    wire [127:0] s8b_sr; aes_shift_rows        sr8  (.state_in(s8a),   .state_out(s8b_sr));
    wire [127:0] s8b_mc; aes_mix_columns_full  mc8  (.state_in(s8b_sr),.state_out(s8b_mc));
    wire [127:0] s8b_ak; aes_add_round_key     ark8 (.state_in(s8b_mc),.round_key(rk8r),.state_out(s8b_ak));
    reg  [127:0] s8b;    always @(posedge clk) s8b <= s8b_ak;

    // ------------------------------------------------------------------
    // Round 9
    wire [127:0] s9a_sb; aes_subbytes_unrolled sb9  (.state_in(s8b),   .state_out(s9a_sb));
    reg  [127:0] s9a;    always @(posedge clk) s9a <= s9a_sb;
    wire [127:0] s9b_sr; aes_shift_rows        sr9  (.state_in(s9a),   .state_out(s9b_sr));
    wire [127:0] s9b_mc; aes_mix_columns_full  mc9  (.state_in(s9b_sr),.state_out(s9b_mc));
    wire [127:0] s9b_ak; aes_add_round_key     ark9 (.state_in(s9b_mc),.round_key(rk9r),.state_out(s9b_ak));
    reg  [127:0] s9b;    always @(posedge clk) s9b <= s9b_ak;

    // ------------------------------------------------------------------
    // Round 10 (final — no MixColumns)
    // Stage 1: SubBytes
    wire [127:0] s10a_sb; aes_subbytes_unrolled sb10  (.state_in(s9b),    .state_out(s10a_sb));
    reg  [127:0] s10a;    always @(posedge clk) s10a <= s10a_sb;
    // Stage 2: ShiftRows + AddRoundKey only
    wire [127:0] s10b_sr; aes_shift_rows        sr10  (.state_in(s10a),   .state_out(s10b_sr));
    wire [127:0] s10b_ak; aes_add_round_key     ark10 (.state_in(s10b_sr),.round_key(rk10r),.state_out(s10b_ak));
    reg  [127:0] s10b;    always @(posedge clk) s10b <= s10b_ak;

    // ------------------------------------------------------------------
    // Valid pipeline — 20-bit shift register (II = 1)
    // ------------------------------------------------------------------
    reg [19:0] valid_pipe;
    always @(posedge clk) begin
        if (rst) valid_pipe <= 20'b0;
        else     valid_pipe <= {valid_pipe[18:0], valid_in};
    end

    assign valid_out = valid_pipe[19];
    assign block_out = s10b;

`ifndef SYNTHESIS
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, aes128_encrypt_unrolled);
    end
`endif

endmodule
`default_nettype wire

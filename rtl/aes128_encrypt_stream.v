`timescale 1ns/1ps
`default_nettype none

// =====================================================================
// AES-128 Encryptor — STREAMING / MAX THROUGHPUT version
// =====================================================================
//
// THE ONE ARCHITECTURE CHANGE:
//   Remove the blocking FSM (IDLE→BUSY→IDLE) and replace it with a
//   valid-in / valid-out handshake that propagates through the pipeline.
//
// WHY THIS IS THE BIGGEST THROUGHPUT WIN:
//
//   Original design:
//     The physical round pipeline (r1→r2→...→r10) CAN accept new data
//     every clock — it is already a proper pipeline. But the FSM wrapping
//     it forces the caller to wait 12 cycles before submitting the next
//     block. This means:
//
//       Initiation Interval (II) = 12 cycles   ← the bottleneck
//       Throughput = 1 block per 12 cycles
//
//   This design:
//     Remove the FSM gating. Feed block_in directly into the pipeline
//     every clock cycle. Track which cycles carry valid data using a
//     10-bit shift register (one bit per pipeline stage).
//
//       Initiation Interval (II) = 1 cycle     ← 12× improvement
//       Throughput = 1 block per 1 cycle
//
// TRADE-OFF (there always is one):
//   - Caller must track latency themselves (valid_out fires 10 cycles
//     after valid_in — no done pulse with a counter).
//   - Key must be STABLE during streaming. If key changes, the
//     round-key pipeline takes ~10 cycles to stabilise before outputs
//     are valid again.
//   - No backpressure — this is a "fire and forget" pipeline.
//
// INTERFACE CHANGE vs aes128_encrypt:
//   start / done  →  valid_in / valid_out
//   (drop-in for streaming use-cases, not for one-shot use)
//
// =====================================================================

module aes128_encrypt_stream (
    input  wire         clk,
    input  wire         rst,

    // INPUT SIDE
    input  wire         valid_in,    // pulse high every cycle a new block is ready
    input  wire [127:0] key,         // must be stable across all in-flight blocks
    input  wire [127:0] block_in,

    // OUTPUT SIDE — result appears exactly 10 cycles after valid_in
    output wire         valid_out,
    output wire [127:0] block_out
);

    // ------------------------------------------------------------------
    // Key register + expansion chain (identical to aes128_encrypt)
    // Key is registered once; must be stable before streaming begins.
    // ------------------------------------------------------------------
    reg  [127:0] key0;
    always @(posedge clk)
        key0 <= key;

    wire [127:0] rk1, rk2, rk3, rk4, rk5;
    wire [127:0] rk6, rk7, rk8, rk9, rk10;

    reg  [127:0] rk1r, rk2r, rk3r, rk4r, rk5r;
    reg  [127:0] rk6r, rk7r, rk8r, rk9r, rk10r;

    aes_key_exp ke1  (.clk(clk), .round(4'd1),  .key_in(key0),  .key_out(rk1));
    aes_key_exp ke2  (.clk(clk), .round(4'd2),  .key_in(rk1r),  .key_out(rk2));
    aes_key_exp ke3  (.clk(clk), .round(4'd3),  .key_in(rk2r),  .key_out(rk3));
    aes_key_exp ke4  (.clk(clk), .round(4'd4),  .key_in(rk3r),  .key_out(rk4));
    aes_key_exp ke5  (.clk(clk), .round(4'd5),  .key_in(rk4r),  .key_out(rk5));
    aes_key_exp ke6  (.clk(clk), .round(4'd6),  .key_in(rk5r),  .key_out(rk6));
    aes_key_exp ke7  (.clk(clk), .round(4'd7),  .key_in(rk6r),  .key_out(rk7));
    aes_key_exp ke8  (.clk(clk), .round(4'd8),  .key_in(rk7r),  .key_out(rk8));
    aes_key_exp ke9  (.clk(clk), .round(4'd9),  .key_in(rk8r),  .key_out(rk9));
    aes_key_exp ke10 (.clk(clk), .round(4'd10), .key_in(rk9r),  .key_out(rk10));

    always @(posedge clk) begin
        rk1r  <= rk1;  rk2r  <= rk2;  rk3r  <= rk3;
        rk4r  <= rk4;  rk5r  <= rk5;  rk6r  <= rk6;
        rk7r  <= rk7;  rk8r  <= rk8;  rk9r  <= rk9;
        rk10r <= rk10;
    end

    // ------------------------------------------------------------------
    // DATA PIPELINE — fed directly every cycle, no FSM gating
    //
    // block_in is sampled by r1 on every posedge clk.
    // Each round module has its own output register, so:
    //   cycle N+0: block_in ^ key0 enters r1 combinational logic
    //   cycle N+1: r1 registers → st1 valid
    //   cycle N+2: r2 registers → st2 valid
    //   ...
    //   cycle N+10: r10 registers → st10 valid = block_out
    // ------------------------------------------------------------------
    wire [127:0] st1, st2, st3, st4, st5;
    wire [127:0] st6, st7, st8, st9, st10;

    aes_enc_round       r1  (.clk(clk), .state_in(block_in ^ key0), .round_key(rk1r),  .state_out(st1));
    aes_enc_round       r2  (.clk(clk), .state_in(st1),             .round_key(rk2r),  .state_out(st2));
    aes_enc_round       r3  (.clk(clk), .state_in(st2),             .round_key(rk3r),  .state_out(st3));
    aes_enc_round       r4  (.clk(clk), .state_in(st3),             .round_key(rk4r),  .state_out(st4));
    aes_enc_round       r5  (.clk(clk), .state_in(st4),             .round_key(rk5r),  .state_out(st5));
    aes_enc_round       r6  (.clk(clk), .state_in(st5),             .round_key(rk6r),  .state_out(st6));
    aes_enc_round       r7  (.clk(clk), .state_in(st6),             .round_key(rk7r),  .state_out(st7));
    aes_enc_round       r8  (.clk(clk), .state_in(st7),             .round_key(rk8r),  .state_out(st8));
    aes_enc_round       r9  (.clk(clk), .state_in(st8),             .round_key(rk9r),  .state_out(st9));
    aes_enc_round_final r10 (.clk(clk), .state_in(st9),             .round_key(rk10r), .state_out(st10));

    // ------------------------------------------------------------------
    // VALID PIPELINE — a 10-bit shift register, one bit per stage.
    //
    // This is the entire "control logic" replacing the old FSM.
    // valid_in enters bit 0 every cycle.
    // After 10 shifts, it exits at bit 9 = valid_out.
    // When valid_out=1, block_out holds the correct ciphertext.
    //
    //   old FSM:  ~40 lines, 4-bit counter, IDLE/BUSY states
    //   new ctrl: 3 lines, 10-bit shift register
    // ------------------------------------------------------------------
    reg [9:0] valid_pipe;

    always @(posedge clk) begin
        if (rst) valid_pipe <= 10'b0;
        else     valid_pipe <= {valid_pipe[8:0], valid_in};
    end

    assign valid_out = valid_pipe[9];
    assign block_out = st10;

`ifndef SYNTHESIS
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, aes128_encrypt_stream);
    end
`endif

endmodule
`default_nettype wire

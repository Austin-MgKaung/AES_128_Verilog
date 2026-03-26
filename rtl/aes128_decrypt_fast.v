`timescale 1ns/1ps
`default_nettype none

// =====================================================================
// AES-128 Decryptor — FAST (GF S-box + 2-stage pipeline)
// =====================================================================
//
// Mirrors aes128_decrypt.v but uses aes_dec_round_fast in place of
// aes_dec_round, giving two internal pipeline stages per round:
//
//   Stage 1: InvShiftRows (free) + InvSubBytes (GF arithmetic, no ROM)
//   Stage 2: AddRoundKey + InvMixColumns
//
// Critical path per stage ≈ half that of the original single-stage round.
//
// Latency: 10 rounds × 2 stages = 20 cycles  (was 10 in aes128_decrypt)
// Initiation Interval: still 12 (FSM; use decrypt_stream_fast for II=1)
//
// KEY ORDER (AES decrypt reverses the key schedule):
//   Initial AddRoundKey : rk10 (last expand key)
//   Rounds 9 down to 1  : rk9r ... rk1r
//   Final round (r0)    : key0 (original master key)
// =====================================================================

module aes128_decrypt_fast (
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [127:0] key,
    input  wire [127:0] block_in,
    output wire         done,
    output reg  [127:0] block_out
);

    // ------------------------------------------------------------------
    // FSM states
    // ------------------------------------------------------------------
    localparam IDLE = 1'd0, BUSY = 1'd1;
    reg        state;
    reg [4:0]  lat;      // counts to 20 (10 rounds × 2 stages)
    reg        donereg;

    // ------------------------------------------------------------------
    // Latched inputs
    // ------------------------------------------------------------------
    reg [127:0] key0;
    reg [127:0] stage0;

    // ------------------------------------------------------------------
    // Round key wires + pipeline registers
    // ------------------------------------------------------------------
    wire [127:0] rk1, rk2, rk3, rk4, rk5;
    wire [127:0] rk6, rk7, rk8, rk9, rk10;

    reg  [127:0] rk1r, rk2r, rk3r, rk4r, rk5r;
    reg  [127:0] rk6r, rk7r, rk8r, rk9r, rk10r;

    // ------------------------------------------------------------------
    // Data pipeline wires
    // ------------------------------------------------------------------
    wire [127:0] st1, st2, st3, st4, st5;
    wire [127:0] st6, st7, st8, st9, st10;

    // ------------------------------------------------------------------
    // Key expansion (same order as encrypt; used in reverse for decrypt)
    // ------------------------------------------------------------------
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

    // ------------------------------------------------------------------
    // Decryption pipeline — 2-stage fast rounds
    // Keys used in REVERSE order: rk10 first, key0 last
    // ------------------------------------------------------------------
    aes_dec_round_fast       r9  (.clk(clk), .state_in(stage0 ^ rk10r), .round_key(rk9r),  .state_out(st1));
    aes_dec_round_fast       r8  (.clk(clk), .state_in(st1),            .round_key(rk8r),  .state_out(st2));
    aes_dec_round_fast       r7  (.clk(clk), .state_in(st2),            .round_key(rk7r),  .state_out(st3));
    aes_dec_round_fast       r6  (.clk(clk), .state_in(st3),            .round_key(rk6r),  .state_out(st4));
    aes_dec_round_fast       r5  (.clk(clk), .state_in(st4),            .round_key(rk5r),  .state_out(st5));
    aes_dec_round_fast       r4  (.clk(clk), .state_in(st5),            .round_key(rk4r),  .state_out(st6));
    aes_dec_round_fast       r3  (.clk(clk), .state_in(st6),            .round_key(rk3r),  .state_out(st7));
    aes_dec_round_fast       r2  (.clk(clk), .state_in(st7),            .round_key(rk2r),  .state_out(st8));
    aes_dec_round_fast       r1  (.clk(clk), .state_in(st8),            .round_key(rk1r),  .state_out(st9));
    aes_dec_round_final_fast r0  (.clk(clk), .state_in(st9),            .round_key(key0),  .state_out(st10));

    // ------------------------------------------------------------------
    // FSM + output latch
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            state   <= IDLE;
            lat     <= 5'd0;
            donereg <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    donereg <= 1'b0;
                    lat     <= 5'd0;
                    if (start) begin
                        key0   <= key;
                        stage0 <= block_in;
                        state  <= BUSY;
                    end
                end
                BUSY: begin
                    if (lat == 5'd20) begin
                        donereg   <= 1'b1;
                        block_out <= st10;
                        state     <= IDLE;
                        lat       <= 5'd0;
                    end else begin
                        lat <= lat + 5'd1;
                    end
                end
                default: state <= IDLE;
            endcase
        end

        // Key pipeline — runs every clock regardless of FSM state
        rk1r  <= rk1;  rk2r  <= rk2;  rk3r  <= rk3;
        rk4r  <= rk4;  rk5r  <= rk5;  rk6r  <= rk6;
        rk7r  <= rk7;  rk8r  <= rk8;  rk9r  <= rk9;
        rk10r <= rk10;
    end

    assign done = donereg;

`ifndef SYNTHESIS
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, aes128_decrypt_fast);
    end
`endif

endmodule
`default_nettype wire

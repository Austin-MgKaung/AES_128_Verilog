`timescale 1ns/1ps
`default_nettype none

// =====================================================================
// AES-128 Encryptor — FAST version
// =====================================================================
// Differences from aes128_encrypt.v:
//
//  1. Uses aes_enc_round_fast / aes_enc_round_final_fast
//     Each round has 2 internal pipeline stages instead of 1:
//       Stage 1: SubBytes (GF arithmetic, no ROM)
//       Stage 2: ShiftRows + MixColumns + AddRoundKey
//
//  2. Latency counter extended to 5 bits, threshold raised to 22
//     (10 rounds × 2 cycles each = 20, plus 2 cycles overhead)
//
//  3. Same external interface as aes128_encrypt — drop-in comparable.
//
// Critical path comparison (per round):
//   Original:  SubBytes(ROM MUX)→ShiftRows→MixColumns→AddRoundKey  [long]
//   Fast:      MixColumns→AddRoundKey   (Stage 2 only)              [~half]
//              SubBytes(GF XOR)         (Stage 1 only)              [~half]
// =====================================================================

module aes128_encrypt_fast (
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [127:0] key,
    input  wire [127:0] block_in,
    output wire         done,
    output reg  [127:0] block_out
);
    localparam IDLE = 1'd0, BUSY = 1'd1;
    reg        state;
    reg  [4:0] lat;      // 5-bit: needs to count to 22
    reg        donereg;

    reg [127:0] key0;
    reg [127:0] stage0;

    // Round key wires (combinational from aes_key_exp)
    wire [127:0] rk1, rk2, rk3, rk4, rk5;
    wire [127:0] rk6, rk7, rk8, rk9, rk10;

    // Round key pipeline registers (1-cycle delay, same as original)
    // The key schedule stabilises before the data pipeline needs it,
    // so no extra delay is required despite the 2-stage rounds.
    reg [127:0] rk1r, rk2r, rk3r, rk4r, rk5r;
    reg [127:0] rk6r, rk7r, rk8r, rk9r, rk10r;

    // Data pipeline wires
    wire [127:0] st1, st2, st3, st4, st5;
    wire [127:0] st6, st7, st8, st9, st10;

    // Key expansion (identical to original)
    aes_key_exp ke1  (.clk(clk),.round(4'd1), .key_in(key0),  .key_out(rk1));
    aes_key_exp ke2  (.clk(clk),.round(4'd2), .key_in(rk1r),  .key_out(rk2));
    aes_key_exp ke3  (.clk(clk),.round(4'd3), .key_in(rk2r),  .key_out(rk3));
    aes_key_exp ke4  (.clk(clk),.round(4'd4), .key_in(rk3r),  .key_out(rk4));
    aes_key_exp ke5  (.clk(clk),.round(4'd5), .key_in(rk4r),  .key_out(rk5));
    aes_key_exp ke6  (.clk(clk),.round(4'd6), .key_in(rk5r),  .key_out(rk6));
    aes_key_exp ke7  (.clk(clk),.round(4'd7), .key_in(rk6r),  .key_out(rk7));
    aes_key_exp ke8  (.clk(clk),.round(4'd8), .key_in(rk7r),  .key_out(rk8));
    aes_key_exp ke9  (.clk(clk),.round(4'd9), .key_in(rk8r),  .key_out(rk9));
    aes_key_exp ke10 (.clk(clk),.round(4'd10),.key_in(rk9r),  .key_out(rk10));

    // Encryption pipeline — 2-stage fast rounds
    aes_enc_round_fast       r1  (.clk(clk),.state_in(stage0 ^ key0),.round_key(rk1r), .state_out(st1));
    aes_enc_round_fast       r2  (.clk(clk),.state_in(st1),          .round_key(rk2r), .state_out(st2));
    aes_enc_round_fast       r3  (.clk(clk),.state_in(st2),          .round_key(rk3r), .state_out(st3));
    aes_enc_round_fast       r4  (.clk(clk),.state_in(st3),          .round_key(rk4r), .state_out(st4));
    aes_enc_round_fast       r5  (.clk(clk),.state_in(st4),          .round_key(rk5r), .state_out(st5));
    aes_enc_round_fast       r6  (.clk(clk),.state_in(st5),          .round_key(rk6r), .state_out(st6));
    aes_enc_round_fast       r7  (.clk(clk),.state_in(st6),          .round_key(rk7r), .state_out(st7));
    aes_enc_round_fast       r8  (.clk(clk),.state_in(st7),          .round_key(rk8r), .state_out(st8));
    aes_enc_round_fast       r9  (.clk(clk),.state_in(st8),          .round_key(rk9r), .state_out(st9));
    aes_enc_round_final_fast r10 (.clk(clk),.state_in(st9),          .round_key(rk10r),.state_out(st10));

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
                    // 10 rounds × 2 stages = 20 pipeline cycles + 2 overhead
                    if (lat == 5'd22) begin
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

        // Key pipeline — runs every clock (same as original)
        rk1r  <= rk1;
        rk2r  <= rk2;
        rk3r  <= rk3;
        rk4r  <= rk4;
        rk5r  <= rk5;
        rk6r  <= rk6;
        rk7r  <= rk7;
        rk8r  <= rk8;
        rk9r  <= rk9;
        rk10r <= rk10;
    end

    assign done = donereg;

`ifndef SYNTHESIS
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, aes128_encrypt_fast);
    end
`endif

endmodule
`default_nettype wire

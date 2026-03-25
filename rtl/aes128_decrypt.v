
  `timescale 1ns/1ps
  `default_nettype none

  module aes128_decrypt (
      input  wire         clk,
      input  wire         rst,
      input  wire         start,
      input  wire [127:0] key,
      input  wire [127:0] block_in,
      output wire         done,
      output reg  [127:0] block_out
  );
      // ----------------------------------------------------------------
      // FSM states
      // ----------------------------------------------------------------
      localparam IDLE = 1'd0, BUSY = 1'd1;
      reg state;
      reg [4:0] lat;      // 5-bit to count up to 20
      reg donereg;

      // ----------------------------------------------------------------
      // Latched inputs
      // ----------------------------------------------------------------
      reg [127:0] key0;       // master key latched on start
      reg [127:0] stage0;     // block_in latched on start

      // ----------------------------------------------------------------
      // Round key wires
      // ----------------------------------------------------------------
      wire [127:0] rk1, rk2, rk3, rk4, rk5;
      wire [127:0] rk6, rk7, rk8, rk9, rk10;

      // ----------------------------------------------------------------
      // Round key pipeline registers
      // ----------------------------------------------------------------
      reg [127:0] rk1r, rk2r, rk3r, rk4r, rk5r;
      reg [127:0] rk6r, rk7r, rk8r, rk9r, rk10r;

      // ----------------------------------------------------------------
      // Data pipeline wires
      // ----------------------------------------------------------------
      wire [127:0] st1, st2, st3, st4, st5;
      wire [127:0] st6, st7, st8, st9, st10;

      // ----------------------------------------------------------------
      // Key expansion - same as encrypt, same order
      // ----------------------------------------------------------------
      aes_key_exp ke1  (.clk(clk),.round(4'd1), .key_in(key0), .key_out(rk1));
      aes_key_exp ke2  (.clk(clk),.round(4'd2), .key_in(rk1r), .key_out(rk2));
      aes_key_exp ke3  (.clk(clk),.round(4'd3), .key_in(rk2r), .key_out(rk3));
      aes_key_exp ke4  (.clk(clk),.round(4'd4), .key_in(rk3r), .key_out(rk4));
      aes_key_exp ke5  (.clk(clk),.round(4'd5), .key_in(rk4r), .key_out(rk5));
      aes_key_exp ke6  (.clk(clk),.round(4'd6), .key_in(rk5r), .key_out(rk6));
      aes_key_exp ke7  (.clk(clk),.round(4'd7), .key_in(rk6r), .key_out(rk7));
      aes_key_exp ke8  (.clk(clk),.round(4'd8), .key_in(rk7r), .key_out(rk8));
      aes_key_exp ke9  (.clk(clk),.round(4'd9), .key_in(rk8r), .key_out(rk9));
      aes_key_exp ke10 (.clk(clk),.round(4'd10),.key_in(rk9r), .key_out(rk10));

      // ----------------------------------------------------------------
      // Decryption pipeline
      // Keys used in REVERSE order: rk10 first, rk0 last
      // First input = stage0 XOR rk10 (initial AddRoundKey with last key)
      // Rounds r9 down to r1 = normal inverse rounds
      // r0 = final inverse round (no InvMixColumns)
      // ----------------------------------------------------------------
      aes_dec_round       r9  (.clk(clk),.state_in(stage0 ^ rk10r),.round_key(rk9r), .state_out(st1));
      aes_dec_round       r8  (.clk(clk),.state_in(st1),            .round_key(rk8r), .state_out(st2));
      aes_dec_round       r7  (.clk(clk),.state_in(st2),            .round_key(rk7r), .state_out(st3));
      aes_dec_round       r6  (.clk(clk),.state_in(st3),            .round_key(rk6r), .state_out(st4));
      aes_dec_round       r5  (.clk(clk),.state_in(st4),            .round_key(rk5r), .state_out(st5));
      aes_dec_round       r4  (.clk(clk),.state_in(st5),            .round_key(rk4r), .state_out(st6));
      aes_dec_round       r3  (.clk(clk),.state_in(st6),            .round_key(rk3r), .state_out(st7));
      aes_dec_round       r2  (.clk(clk),.state_in(st7),            .round_key(rk2r), .state_out(st8));
      aes_dec_round       r1  (.clk(clk),.state_in(st8),            .round_key(rk1r), .state_out(st9));
      aes_dec_round_final r0  (.clk(clk),.state_in(st9),            .round_key(key0), .state_out(st10));

      // ----------------------------------------------------------------
      // FSM + output latch
      // ----------------------------------------------------------------
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

          // Key pipeline - runs every clock regardless of FSM state
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
          $dumpvars(0, aes128_decrypt);
      end
  `endif

  endmodule
  `default_nettype wire
  
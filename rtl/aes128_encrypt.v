`timescale 1ns/1ps
`default_nettype none

// -----------------------------------------------------------------------------
// AES-128 encryptor core (student implementation)
//
// IMPORTANT:
//   - You must implement AES-128 *encryption* only (no decryption here).
//   - Interface is fixed; do not rename ports or change widths.
//   - Behaviour:
//       * Pulse 'start' high for one clock in IDLE.
//       * After a fixed latency, assert 'done' high for exactly one clock.
//       * On that 'done' cycle, 'block_out' must hold the ciphertext.
//   - Your design will be checked against the Python model in model/aes128.py.
// -----------------------------------------------------------------------------
module aes128_encrypt (
    input  wire         clk,
    input  wire         rst,       // synchronous, active high
    input  wire         start,     // 1-cycle pulse when IDLE
    input  wire [127:0] key,
    input  wire [127:0] block_in,
    output wire         done,      // 1-cycle pulse when block_out valid
    output reg  [127:0] block_out
);

    // TODO: implement your AES-128 encryption datapath and control here.
    //
    // You will probably want:
    //   - A state register for the AES state (128-bit).
    //   - A register for the current round key (128-bit).
    //   - A round counter (1..10).
    //   - A small FSM: IDLE -> INIT -> ROUND(S) -> FINAL -> DONE.
    //   - Helper functions/tasks for:
    //       * SubBytes, ShiftRows, MixColumns, AddRoundKey
    //       * Key schedule (next round key).
    //
    // There is more guidance in rtl/README.md and in the assignment handout.

    // For now, provide a placeholder so the design elaborates.
    // REMOVE these placeholder assignments once you start implementing.

    assign done = 1'b0;

    always @(*) begin
        block_out = 128'h0;
    end

`ifndef SYNTHESIS
    // Simple waveform dump for simulators (ignored for synthesis)
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, aes128_encrypt);
    end
`endif

endmodule

`default_nettype wire
`timescale 1ns/1ps
`default_nettype none

// =====================================================================
// AES-128 Top Module - Hybrid Mode Support
// =====================================================================
//
// This wrapper allows switching between:
//   - STREAMING mode (low latency, enc & dec can overlap)
//   - UNROLLED mode (higher latency, lower critical path, friend's style)
//
// Default: STREAMING_MODE = 1
// Set to 0 to use unrolled architecture
// =====================================================================

module aes128_top_hybrid (
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [127:0] key,
    input  wire [127:0] plaintext,
    output wire         done,
    output wire [127:0] cipher_text,
    output wire [127:0] decrypted_text
);

    // Select architecture mode
    parameter STREAMING_MODE = 1;  // 1=streaming (default), 0=unrolled (friend's style)
    
    generate
        if (STREAMING_MODE == 1) begin : streaming_mode
            // =========================================================
            // STREAMING ARCHITECTURE (Original Your Code)
            // Latency: 10 cycles enc + 10 cycles dec = 20 total
            // Throughput: 1 block per cycle
            // Lower critical path
            // =========================================================
            
            wire enc_done;
            
            aes128_encrypt_stream u_enc (
                .clk      (clk),
                .rst      (rst),
                .valid_in (start),
                .key      (key),
                .block_in (plaintext),
                .valid_out(enc_done),
                .block_out(cipher_text)
            );
            
            aes128_decrypt_stream u_dec (
                .clk      (clk),
                .rst      (rst),
                .valid_in (enc_done),
                .key      (key),
                .block_in (cipher_text),
                .valid_out(done),
                .block_out(decrypted_text)
            );
            
        end else begin : unrolled_mode
            // =========================================================
            // UNROLLED ARCHITECTURE (Friend's Style - Modularized)
            // Latency: 20 cycles enc + 20 cycles dec = 40 total
            // Throughput: 1 block per cycle (after warmup)
            // Lower critical path per round (2-stage pipeline)
            // Higher area (fully unrolled rounds)
            // =========================================================
            
            wire enc_done;
            
            aes128_encrypt_unrolled u_enc_unr (
                .clk      (clk),
                .rst      (rst),
                .start    (start),
                .key      (key),
                .block_in (plaintext),
                .done     (enc_done),
                .block_out(cipher_text)
            );
            
            aes128_decrypt_unrolled u_dec_unr (
                .clk      (clk),
                .rst      (rst),
                .start    (enc_done),
                .key      (key),
                .block_in (cipher_text),
                .done     (done),
                .block_out(decrypted_text)
            );
            
        end
    endgenerate

endmodule

`default_nettype wire

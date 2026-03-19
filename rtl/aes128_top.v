`timescale 1ns/1ps
  `default_nettype none

  module aes128_top (
      input  wire         clk,
      input  wire         rst,
      input  wire         start,
      input  wire [127:0] key,
      input  wire [127:0] plaintext,
      output wire         done,
      output wire [127:0] cipher_text,
      output wire [127:0] decrypted_text
  );
      // enc_done wires encrypt → decrypt automatically
      wire enc_done;

      aes128_encrypt u_enc (
          .clk      (clk),
          .rst      (rst),
          .start    (start),
          .key      (key),
          .block_in (plaintext),
          .done     (enc_done),
          .block_out(cipher_text)
      );

      aes128_decrypt u_dec (
          .clk      (clk),
          .rst      (rst),
          .start    (enc_done),       // triggered automatically when encrypt finishes
          .key      (key),
          .block_in (cipher_text),
          .done     (done),
          .block_out(decrypted_text)
      );

  endmodule
  `default_nettype wire

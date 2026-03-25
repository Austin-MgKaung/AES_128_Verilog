`timescale 1ns/1ps
  `default_nettype none

  module aes_dec_round (
      input  wire        clk,
      input  wire [127:0] state_in,
      input  wire [127:0] round_key,
      output reg  [127:0] state_out
  );
      wire [127:0] shifted, subbed, addkey_out;
      wire [31:0]  mc0, mc1, mc2, mc3;

      aes_inv_shift_rows isr (.state_in(state_in), .state_out(shifted));

      aes_inv_sbox sb0  (.in_byte(shifted[127:120]),.out_byte(subbed[127:120]));
      aes_inv_sbox sb1  (.in_byte(shifted[119:112]),.out_byte(subbed[119:112]));
      aes_inv_sbox sb2  (.in_byte(shifted[111:104]),.out_byte(subbed[111:104]));
      aes_inv_sbox sb3  (.in_byte(shifted[103:96]), .out_byte(subbed[103:96]));
      aes_inv_sbox sb4  (.in_byte(shifted[95:88]),  .out_byte(subbed[95:88]));
      aes_inv_sbox sb5  (.in_byte(shifted[87:80]),  .out_byte(subbed[87:80]));
      aes_inv_sbox sb6  (.in_byte(shifted[79:72]),  .out_byte(subbed[79:72]));
      aes_inv_sbox sb7  (.in_byte(shifted[71:64]),  .out_byte(subbed[71:64]));
      aes_inv_sbox sb8  (.in_byte(shifted[63:56]),  .out_byte(subbed[63:56]));
      aes_inv_sbox sb9  (.in_byte(shifted[55:48]),  .out_byte(subbed[55:48]));
      aes_inv_sbox sb10 (.in_byte(shifted[47:40]),  .out_byte(subbed[47:40]));
      aes_inv_sbox sb11 (.in_byte(shifted[39:32]),  .out_byte(subbed[39:32]));
      aes_inv_sbox sb12 (.in_byte(shifted[31:24]),  .out_byte(subbed[31:24]));
      aes_inv_sbox sb13 (.in_byte(shifted[23:16]),  .out_byte(subbed[23:16]));
      aes_inv_sbox sb14 (.in_byte(shifted[15:8]),   .out_byte(subbed[15:8]));
      aes_inv_sbox sb15 (.in_byte(shifted[7:0]),    .out_byte(subbed[7:0]));

      assign addkey_out = subbed ^ round_key;

      aes_inv_mix_cols mc_0 (.col_in(addkey_out[127:96]),.col_out(mc0));
      aes_inv_mix_cols mc_1 (.col_in(addkey_out[95:64]), .col_out(mc1));
      aes_inv_mix_cols mc_2 (.col_in(addkey_out[63:32]), .col_out(mc2));
      aes_inv_mix_cols mc_3 (.col_in(addkey_out[31:0]),  .col_out(mc3));

      always @(posedge clk)
          state_out <= {mc0, mc1, mc2, mc3};

  endmodule
  `default_nettype wire

`timescale 1ns/1ps
`default_nettype none

// =====================================================================
// AES Inverse SubBytes Module - Fully Combinational (16 GF S-boxes)
// =====================================================================
// Applies Inverse S-box substitution to all 16 bytes in parallel.
// Uses aes_inv_sbox_comb (GF arithmetic, no ROM) matching stream-fast style.
// =====================================================================

module aes_inv_subbytes_unrolled (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    aes_inv_sbox_comb sb0  (.in_byte(state_in[127:120]), .out_byte(state_out[127:120]));
    aes_inv_sbox_comb sb1  (.in_byte(state_in[119:112]), .out_byte(state_out[119:112]));
    aes_inv_sbox_comb sb2  (.in_byte(state_in[111:104]), .out_byte(state_out[111:104]));
    aes_inv_sbox_comb sb3  (.in_byte(state_in[103:96]),  .out_byte(state_out[103:96]));
    aes_inv_sbox_comb sb4  (.in_byte(state_in[95:88]),   .out_byte(state_out[95:88]));
    aes_inv_sbox_comb sb5  (.in_byte(state_in[87:80]),   .out_byte(state_out[87:80]));
    aes_inv_sbox_comb sb6  (.in_byte(state_in[79:72]),   .out_byte(state_out[79:72]));
    aes_inv_sbox_comb sb7  (.in_byte(state_in[71:64]),   .out_byte(state_out[71:64]));
    aes_inv_sbox_comb sb8  (.in_byte(state_in[63:56]),   .out_byte(state_out[63:56]));
    aes_inv_sbox_comb sb9  (.in_byte(state_in[55:48]),   .out_byte(state_out[55:48]));
    aes_inv_sbox_comb sb10 (.in_byte(state_in[47:40]),   .out_byte(state_out[47:40]));
    aes_inv_sbox_comb sb11 (.in_byte(state_in[39:32]),   .out_byte(state_out[39:32]));
    aes_inv_sbox_comb sb12 (.in_byte(state_in[31:24]),   .out_byte(state_out[31:24]));
    aes_inv_sbox_comb sb13 (.in_byte(state_in[23:16]),   .out_byte(state_out[23:16]));
    aes_inv_sbox_comb sb14 (.in_byte(state_in[15:8]),    .out_byte(state_out[15:8]));
    aes_inv_sbox_comb sb15 (.in_byte(state_in[7:0]),     .out_byte(state_out[7:0]));

endmodule

`default_nettype wire

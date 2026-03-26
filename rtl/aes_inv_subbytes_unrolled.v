`timescale 1ns/1ps
`default_nettype none

// =====================================================================
// AES Inverse SubBytes Module (Decryption)
// =====================================================================
// Applies Inverse S-box substitution to all 16 bytes in parallel
// Fully combinational for use in unrolled pipeline
// =====================================================================

module aes_inv_subbytes_unrolled (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    wire [7:0] s_out[15:0];
    
    // Instantiate 16 Inverse S-boxes
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : inv_sbox_gen
            aes_inv_sbox_rom inv_sbox_inst (
                .addr(state_in[((15-i)*8 + 7):(15-i)*8]),
                .out(s_out[i])
            );
        end
    endgenerate
    
    // Pack output bytes
    assign state_out = {
        s_out[0],  s_out[1],  s_out[2],  s_out[3],
        s_out[4],  s_out[5],  s_out[6],  s_out[7],
        s_out[8],  s_out[9],  s_out[10], s_out[11],
        s_out[12], s_out[13], s_out[14], s_out[15]
    };

endmodule

`default_nettype wire

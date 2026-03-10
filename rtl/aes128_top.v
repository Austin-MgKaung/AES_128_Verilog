`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.03.2026 15:33:37
// Design Name: 
// Module Name: aes128_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module aes128_top (

    input  wire        clk,
    input  wire        rst,             // synchronous, active high
    input  wire        start,           // 1-cycle pulse when IDLE

    input  wire [127:0] key,
    input  wire [127:0] plaintext,      

    output wire        done,            // 1-cycle pulse when block_out valid
    output wire [127:0] cipher_text,    
    output wire [127:0] decrypted_text  

);

    // Internal signal
    wire enc_done;

    //--------------------------------
    // AES Encrypt
    //--------------------------------
    aes128_encrypt u_encrypt (

        .clk       (clk),
        .rst       (rst),
        .start     (start),
        .key       (key),
        .block_in  (plaintext),

        .done      (enc_done),
        .block_out (cipher_text)

    );


    //--------------------------------
    // AES Decrypt
    //--------------------------------
    aes128_decrypt u_decrypt (

        .clk       (clk),
        .rst       (rst),

        // Start decryption when encryption completes
        .start     (enc_done),

        .key       (key),

        // Ciphertext from encryption module
        .block_in  (cipher_text),

        .done      (done),

        .block_out (decrypted_text)

    );

endmodule

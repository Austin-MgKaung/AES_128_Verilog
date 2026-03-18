`timescale 1ns/1ps

module aes128_top (
    input  wire clk,
    input  wire rst,
    output wire done
);

    // Hard coded test vectors 
    reg [127:0] key       = 128'h2b7e151628aed2a6abf7158809cf4f3c;
    reg [127:0] block_in  = 128'h4b2e3546187e92665b372598294f8f2c;

    reg start;

    wire [127:0] cipher_text;
    wire [127:0] decrypted_text;
    wire enc_done;

    //--------------------------------
    // Start pulse generator (1 cycle)
    //--------------------------------
    always @(posedge clk) begin
        if (rst)
            start <= 1'b1;
        else
            start <= 1'b0;
    end

    //--------------------------------
    // AES Encrypt
    //--------------------------------
    aes128_encrypt u_encrypt (
        .clk       (clk),
        .rst       (rst),
        .start     (start),
        .key       (key),
        .block_in  (block_in),
        .done      (enc_done),
        .block_out (cipher_text)
    );

    //--------------------------------
    // AES Decrypt
    //--------------------------------
    aes128_decrypt u_decrypt (
        .clk       (clk),
        .rst       (rst),
        .start     (enc_done),
        .key       (key),
        .block_in  (cipher_text),
        .done      (done),
        .block_out (decrypted_text)
    );

`ifndef SYNTHESIS
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, aes128_top);
    end
`endif

endmodule

`default_nettype wire

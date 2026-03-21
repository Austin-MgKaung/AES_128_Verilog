`timescale 1ns/1ps

module aes_decrypt_round_final (
    input clk,
    input [3:0] round,
    input [127:0] decrypt_i,
    input [127:0] key_in,
    output reg [127:0] decrypt_o,
    output reg [127:0] key_out
    );
    
    wire [127:0] inv_s_out;
    wire [127:0] inv_shift_o;
    wire [127:0] next_key;
    
    invshift inv_shift(.state_in(decrypt_i), .state_out(inv_shift_o));   
       
    invsubbytes sbox5  (.in_byte(inv_shift_o[127:120]), .out_byte(inv_s_out[127:120]));
    invsubbytes sbox6  (.in_byte(inv_shift_o[119:112]), .out_byte(inv_s_out[119:112]));
    invsubbytes sbox7  (.in_byte(inv_shift_o[111:104]), .out_byte(inv_s_out[111:104]));
    invsubbytes sbox8  (.in_byte(inv_shift_o[103:96]),  .out_byte(inv_s_out[103:96]));
    invsubbytes sbox9  (.in_byte(inv_shift_o[95:88]),   .out_byte(inv_s_out[95:88]));
    invsubbytes sbox10 (.in_byte(inv_shift_o[87:80]),   .out_byte(inv_s_out[87:80]));
    invsubbytes sbox11 (.in_byte(inv_shift_o[79:72]),   .out_byte(inv_s_out[79:72]));
    invsubbytes sbox12 (.in_byte(inv_shift_o[71:64]),   .out_byte(inv_s_out[71:64]));
    invsubbytes sbox13 (.in_byte(inv_shift_o[63:56]),   .out_byte(inv_s_out[63:56]));
    invsubbytes sbox14 (.in_byte(inv_shift_o[55:48]),   .out_byte(inv_s_out[55:48]));
    invsubbytes sbox15 (.in_byte(inv_shift_o[47:40]),   .out_byte(inv_s_out[47:40]));
    invsubbytes sbox16 (.in_byte(inv_shift_o[39:32]),   .out_byte(inv_s_out[39:32]));
    invsubbytes sbox17 (.in_byte(inv_shift_o[31:24]),   .out_byte(inv_s_out[31:24]));
    invsubbytes sbox18 (.in_byte(inv_shift_o[23:16]),   .out_byte(inv_s_out[23:16]));
    invsubbytes sbox19 (.in_byte(inv_shift_o[15:8]),    .out_byte(inv_s_out[15:8]));
    invsubbytes sbox20 (.in_byte(inv_shift_o[7:0]),     .out_byte(inv_s_out[7:0]));
    
    inv_roundkeycreate rkexp_round (.clk(clk), .round(round), .key_in(key_in), .key_out(next_key));

    always @(posedge clk) begin
        decrypt_o <= inv_s_out ^ next_key;
        key_out   <= next_key;
    end
 
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        (fill in if needed)
// Engineer:       Wilf
//
// Create Date:    02.12.2025 11:18:36
// Design Name:    AES-128 (partial round datapath demonstration)
// Module Name:    EEE_455_AES128_topmod
// Project Name:   (fill in if needed)
// Target Devices: (fill in if needed)
// Tool Versions:  (fill in if needed)
//
// Description:
// -----------------------------------------------------------------------------
// This module implements a *combinational SubBytes + ShiftRows* datapath for a
// 128-bit AES state, followed by a registered XOR with a 128-bit key.
// In other words, the dataflow is:
//
//   ENCRYP_i (128-bit state)
//        -> 16x S-Box (SubBytes, bytewise)
//        -> ShiftRows (byte permutation)
//        -> (registered) AddRoundKey style XOR with "key"
//        -> ENCRYP_o (128-bit output, updated on rising edge)
//
// Author: Wilf 
//
//////////////////////////////////////////////////////////////////////////////////


module EEE_455_AES128_topmod (

    input clk,
    input [3:0] round,
    input [127:0] ENCRYP_i,
    input [127:0] key_in,
    output reg [127:0] ENCRYP_o,
    output reg [127:0] key_out
    );
    

    wire [7:0] s_out5, s_out6, s_out7, s_out8, s_out9, s_out10, s_out11, s_out12, s_out13, s_out14, s_out15, s_out16, s_out17, s_out18, s_out19, s_out20; 
    wire [127:0] shift_o;
    wire [127:0] addrnd;
    wire [127:0] next_key;
    wire [31:0] mixcols0_o, mixcols1_o, mixcols2_o, mixcols3_o;
    
    ELE_455_AES128_RKEXP rkexp_round (.clk(clk),.round(round),.key_in(key_in),.key_out(next_key));
    
    
    ELE_455_AES128_SBOX sbox5 (.in_byte(ENCRYP_i[127:120]),.out_byte(s_out5));
    ELE_455_AES128_SBOX sbox6 (.in_byte(ENCRYP_i[119:112]),.out_byte(s_out6));
    ELE_455_AES128_SBOX sbox7 (.in_byte(ENCRYP_i[111:104]),.out_byte(s_out7));
    ELE_455_AES128_SBOX sbox8 (.in_byte(ENCRYP_i[103:96]),.out_byte(s_out8));
    ELE_455_AES128_SBOX sbox9 (.in_byte(ENCRYP_i[95:88]),.out_byte(s_out9));
    ELE_455_AES128_SBOX sbox10 (.in_byte(ENCRYP_i[87:80]),.out_byte(s_out10));
    ELE_455_AES128_SBOX sbox11 (.in_byte(ENCRYP_i[79:72]),.out_byte(s_out11));
    ELE_455_AES128_SBOX sbox12 (.in_byte(ENCRYP_i[71:64]),.out_byte(s_out12));
    ELE_455_AES128_SBOX sbox13 (.in_byte(ENCRYP_i[63:56]),.out_byte(s_out13));
    ELE_455_AES128_SBOX sbox14 (.in_byte(ENCRYP_i[55:48]),.out_byte(s_out14));
    ELE_455_AES128_SBOX sbox15 (.in_byte(ENCRYP_i[47:40]),.out_byte(s_out15));
    ELE_455_AES128_SBOX sbox16 (.in_byte(ENCRYP_i[39:32]),.out_byte(s_out16));
    ELE_455_AES128_SBOX sbox17 (.in_byte(ENCRYP_i[31:24]),.out_byte(s_out17));
    ELE_455_AES128_SBOX sbox18 (.in_byte(ENCRYP_i[23:16]),.out_byte(s_out18));
    ELE_455_AES128_SBOX sbox19 (.in_byte(ENCRYP_i[15:8]),.out_byte(s_out19));
    ELE_455_AES128_SBOX sbox20 (.in_byte(ENCRYP_i[7:0]),.out_byte(s_out20));
    
    ELE_455_AES128_SHFTROWS shftrows(
        .state_in({s_out5,  s_out6,  s_out7,  s_out8, s_out9,  s_out10, s_out11, s_out12,s_out13, s_out14, s_out15, s_out16, s_out17, s_out18, s_out19, s_out20}),   // 128-bit AES state input
        .state_out(shift_o)   
    );   

    always @(posedge clk) begin
        ENCRYP_o <= shift_o ^ next_key;
        key_out  <= next_key;
    end
    
endmodule

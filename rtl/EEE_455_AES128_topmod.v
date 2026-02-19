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

    input         CLK,        // System clock
    input  [127:0] ENCRYP_i,    // 128-bit input AES state (16 bytes)
    input  [127:0] key,         // 128-bit key (used here as a simple XOR mask)
    output reg [127:0] ENCRYP_o // 128-bit registered output
    
    );
    
    // -------------------------------------------------------------------------
    // Internal wires for S-Box outputs (bytewise SubBytes results).
    // Each s_outX is 8 bits = 1 byte.
    //
    // Naming note:
    // These are labelled s_out5..s_out20. Functionally, they represent the 16
    // bytes of the AES state after SubBytes.
    // -------------------------------------------------------------------------
    wire [7:0] s_out5;
    wire [7:0] s_out6;
    wire [7:0] s_out7;
    wire [7:0] s_out8;
    wire [7:0] s_out9;
    wire [7:0] s_out10;
    wire [7:0] s_out11;
    wire [7:0] s_out12;
    wire [7:0] s_out13;
    wire [7:0] s_out14;
    wire [7:0] s_out15;
    wire [7:0] s_out16;
    wire [7:0] s_out17;
    wire [7:0] s_out18;
    wire [7:0] s_out19;
    wire [7:0] s_out20; 
    wire [127:0] shift_o;
    wire [127:0] addrnd;
    wire [31:0] mixcols0_o;
    wire [31:0] mixcols1_o;
    wire [31:0] mixcols2_o;
    wire [31:0] mixcols3_o;
    
    initial begin

              
    end
    
    // -------------------------------------------------------------------------
    // SubBytes stage (16 parallel S-Boxes)
    //
    // AES state is 16 bytes. Here we slice ENCRYP_i into bytes:
    //   ENCRYP_i[127:120] is byte 15 (MSB byte)
    //   ...
    //   ENCRYP_i[7:0]     is byte 0  (LSB byte)
    //
    // Each byte is passed through an AES S-Box module to produce out_byte.
    // -------------------------------------------------------------------------

    
    ELE_455_AES128_SBOX sbox5 (
        .in_byte(ENCRYP_i[127:120]),
        .out_byte(s_out5)  
    );

    ELE_455_AES128_SBOX sbox6 (
        .in_byte(ENCRYP_i[119:112]),
        .out_byte(s_out6)
    );

    ELE_455_AES128_SBOX sbox7 (
        .in_byte(ENCRYP_i[111:104]),
        .out_byte(s_out7)  
    );

    ELE_455_AES128_SBOX sbox8 (
        .in_byte(ENCRYP_i[103:96]),
        .out_byte(s_out8) 
    );

    ELE_455_AES128_SBOX sbox9 (
        .in_byte(ENCRYP_i[95:88]),
        .out_byte(s_out9) 
    );

    ELE_455_AES128_SBOX sbox10 (
        .in_byte(ENCRYP_i[87:80]),
        .out_byte(s_out10)  
    );

    ELE_455_AES128_SBOX sbox11 (
        .in_byte(ENCRYP_i[79:72]),
        .out_byte(s_out11)  
    );

    ELE_455_AES128_SBOX sbox12 (
        .in_byte(ENCRYP_i[71:64]),
        .out_byte(s_out12)  
    );

    ELE_455_AES128_SBOX sbox13 (
        .in_byte(ENCRYP_i[63:56]),
        .out_byte(s_out13)
    );

    ELE_455_AES128_SBOX sbox14 (
        .in_byte(ENCRYP_i[55:48]),
        .out_byte(s_out14)
    );

    ELE_455_AES128_SBOX sbox15 (
        .in_byte(ENCRYP_i[47:40]),
        .out_byte(s_out15)
    );

    ELE_455_AES128_SBOX sbox16 (
        .in_byte(ENCRYP_i[39:32]),
        .out_byte(s_out16)  
    );

    ELE_455_AES128_SBOX sbox17 (
        .in_byte(ENCRYP_i[31:24]),
        .out_byte(s_out17)  
    );

    ELE_455_AES128_SBOX sbox18 (
        .in_byte(ENCRYP_i[23:16]),
        .out_byte(s_out18)  
    );

    ELE_455_AES128_SBOX sbox19 (
        .in_byte(ENCRYP_i[15:8]),
        .out_byte(s_out19)  
    );

    ELE_455_AES128_SBOX sbox20 (
        .in_byte(ENCRYP_i[7:0]),
        .out_byte(s_out20)  
    );
    
    // -------------------------------------------------------------------------
    // ShiftRows stage
    //
    // ShiftRows is a fixed permutation of the AES state bytes:
    // - Row 0: no shift
    // - Row 1: shift left by 1 byte
    // - Row 2: shift left by 2 bytes
    // - Row 3: shift left by 3 bytes
    //
    // IMPORTANT:
    // The correctness depends on the assumed byte ordering inside the 128-bit
    // "state_in". Here, the state is assembled as:
    //   {s_out5, s_out6, ..., s_out20}
    // which matches the same MSB-to-LSB byte order used when slicing ENCRYP_i.
    // -------------------------------------------------------------------------
    
    ELE_455_AES128_SHFTROWS shftrows(
        .state_in({s_out5,  s_out6,  s_out7,  s_out8, s_out9,  s_out10, s_out11, s_out12,s_out13, s_out14, s_out15, s_out16, s_out17, s_out18, s_out19, s_out20}),   // 128-bit AES state input
        .state_out(shift_o)   
    );   

    always @(posedge CLK) begin
        ENCRYP_o <= shift_o ^ key;
    end
    
endmodule

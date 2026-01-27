`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.11.2025 11:46:24
// Design Name: 
// Module Name: ELE_455_AES128_RKEXP
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


module ELE_455_AES128_RKEXP(

    input CLK,
    input [3:0] round,
    input [127:0] key_i,
    output wire [127:0] key//,
    //output reg signal

    );
    //reg [127:0] key_i2;
    reg [7:0] RCON [0:9];
    //reg [127:0] key;
    //reg [127:0] round_key [12:0];
    //reg [3:0] round;
    //reg [5:0] var;
    wire [7:0] s_out0_w, s_out1_w, s_out2_w, s_out3_w;
    
    reg [7:0] RCON_o; // Simple reg, NOT an array

    // 1. ROBUST RCON (Combinational Case Statement)
    // This fixes the "XX" issue by removing the memory array initialization risk.
    always @(*) begin
        case (round)
            4'd1:  RCON_o = 8'h01;
            4'd2:  RCON_o = 8'h02;
            4'd3:  RCON_o = 8'h04;
            4'd4:  RCON_o = 8'h08;
            4'd5:  RCON_o = 8'h10;
            4'd6:  RCON_o = 8'h20;
            4'd7:  RCON_o = 8'h40;
            4'd8:  RCON_o = 8'h80;
            4'd9:  RCON_o = 8'h1B;
            4'd10: RCON_o = 8'h36;
            default: RCON_o = 8'h00; 
        endcase
    end
    
    
    ELE_455_AES128_SBOX sbox1 (
            .in_byte(key_i[23:16]),
            .out_byte(s_out0_w)
        );
        
    ELE_455_AES128_SBOX sbox2 (
            .in_byte(key_i[15:8]),   
            .out_byte(s_out1_w)
        );
        
    ELE_455_AES128_SBOX sbox3 (
            .in_byte(key_i[7:0]),   
            .out_byte(s_out2_w)
        );
        
    ELE_455_AES128_SBOX sbox4 (
            .in_byte(key_i[31:24]),  
            .out_byte(s_out3_w)
        );
    
    
    
    
    
    
    
    
    
    
    
    //ELE_455_AES128_SBOX sbox1 (
    //    .in_byte(round_key[round-1][23:16]),
    //    .out_byte(s_out0_w)
    //);
    //
    //ELE_455_AES128_SBOX sbox2 (
    //    .in_byte(round_key[round-1][15:8]),   
    //    .out_byte(s_out1_w)
    //);
    //
    //ELE_455_AES128_SBOX sbox3 (
    //    .in_byte(round_key[round-1][7:0]),   
    //    .out_byte(s_out2_w)
    //);
    //
    //ELE_455_AES128_SBOX sbox4 (
    //    .in_byte(round_key[round-1][31:24]),  
    //    .out_byte(s_out3_w)
    //);
    
    //ELE_455_AES128_SBOX sbox1 (
    //    .in_byte(round_key[(var-4)+3][23:16]),
    //    .out_byte(s_out0_w)
    //);
    //
    //ELE_455_AES128_SBOX sbox2 (
    //    .in_byte(round_key[(var-4)+3][15:8]),   
    //    .out_byte(s_out1_w)
    //);
    //
    //ELE_455_AES128_SBOX sbox3 (
    //    .in_byte(round_key[(var-4)+3][7:0]),   
    //    .out_byte(s_out2_w)
    //);
    //
    //ELE_455_AES128_SBOX sbox4 (
    //    .in_byte(round_key[(var-4)+3][31:24]),  
    //    .out_byte(s_out3_w)
    //);
    
    assign key = {{s_out0_w ^ RCON_o, s_out1_w, s_out2_w, s_out3_w} ^ key_i[127:96], {s_out0_w ^ RCON_o, s_out1_w, s_out2_w, s_out3_w} ^ key_i[127:96] ^ key_i[95:64], {s_out0_w ^ RCON_o, s_out1_w, s_out2_w, s_out3_w} ^ key_i[127:96] ^ key_i[95:64] ^ key_i[63:32], {s_out0_w ^ RCON_o, s_out1_w, s_out2_w, s_out3_w} ^ key_i[127:96] ^ key_i[95:64] ^ key_i[63:32] ^ key_i[31:0]};
    
    //always @(posedge CLK) begin
    //    if (round != 11) begin
    //        if (round == 10) begin
    //            signal <= 1;
    //        end
    //        
    //        //round_key[round] <= {{s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[var-4], {s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[var-4] ^ round_key[var-3], {s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[var-4] ^ round_key[var-3] ^ round_key[var-2], {s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[var-4] ^ round_key[var-3] ^ round_key[var-2] ^ round_key[var-1]}; 
    //        round_key[round] <= {{s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[round-1][127:96], {s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[round-1][127:96] ^ round_key[round-1][95:64], {s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[round-1][127:96] ^ round_key[round-1][95:64] ^ round_key[round-1][63:32], {s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[round-1][127:96] ^ round_key[round-1][95:64] ^ round_key[round-1][63:32] ^ round_key[round-1][31:0]};
    //        key <= {{s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[round-1][127:96], {s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[round-1][127:96] ^ round_key[round-1][95:64], {s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[round-1][127:96] ^ round_key[round-1][95:64] ^ round_key[round-1][63:32], {s_out0_w ^ RCON[round-1'b1], s_out1_w, s_out2_w, s_out3_w} ^ round_key[round-1][127:96] ^ round_key[round-1][95:64] ^ round_key[round-1][63:32] ^ round_key[round-1][31:0]};
    //        
    //
    //        round <= round + 1'b1;
    //        //var <= (round << 2) + 4;
    //
    //   end
    //end
    //assign key2 = key;
endmodule

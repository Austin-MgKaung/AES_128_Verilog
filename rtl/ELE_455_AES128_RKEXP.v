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

    input clk,
    input [3:0] round,
    input [127:0] key_in,
    output wire [127:0] key_out

    );
    
    reg [7:0] RCON [0:9];
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
    
    
    ELE_455_AES128_SBOX sbox1 (.in_byte(key_in[23:16]),.out_byte(s_out0_w));        
    ELE_455_AES128_SBOX sbox2 (.in_byte(key_in[15:8]),.out_byte(s_out1_w));       
    ELE_455_AES128_SBOX sbox3 (.in_byte(key_in[7:0]),.out_byte(s_out2_w));      
    ELE_455_AES128_SBOX sbox4 (.in_byte(key_in[31:24]),.out_byte(s_out3_w));

    assign key_out = {{s_out0_w ^ RCON_o, s_out1_w, s_out2_w, s_out3_w} ^ key_in[127:96], {s_out0_w ^ RCON_o, s_out1_w, s_out2_w, s_out3_w} ^ key_in[127:96] ^ key_in[95:64], {s_out0_w ^ RCON_o, s_out1_w, s_out2_w, s_out3_w} ^ key_in[127:96] ^ key_in[95:64] ^ key_in[63:32], {s_out0_w ^ RCON_o, s_out1_w, s_out2_w, s_out3_w} ^ key_in[127:96] ^ key_in[95:64] ^ key_in[63:32] ^ key_in[31:0]};
   
endmodule

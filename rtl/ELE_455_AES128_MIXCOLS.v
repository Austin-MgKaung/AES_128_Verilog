`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2025 17:20:23
// Design Name: 
// Module Name: ELE_455_AES128_MIXCOLS
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


module ELE_455_AES128_MIXCOLS(

    input [31:0] word_in,   // 128-bit AES state input
    output wire [31:0] word_out
    
);

    wire [7:0] d0;
    wire [7:0] d1;
    wire [7:0] d2;
    wire [7:0] d3;
    wire [7:0] b0;
    wire [7:0] b1;
    wire [7:0] b2;
    wire [7:0] b3;
    
    assign b0 = {word_in[31:24]};
    assign b1 = {word_in[23:16]};
    assign b2 = {word_in[15:8]};
    assign b3 = {word_in[7:0]};
    
    assign d0 = ((b0[7] == 1'b1) ? ((b0 << 1) ^ 8'h1b) : (b0 << 1))^((b1[7] == 1'b1) ? ((b1 << 1) ^ 8'h1b ^b1) : ((b1 << 1)^b1))^b2^b3;
    assign d1 = b0^((b1[7] == 1'b1) ? ((b1 << 1) ^ 8'h1b) : (b1 << 1))^((b2[7] == 1'b1) ? ((b2 << 1) ^ 8'h1b ^b2) : ((b2 << 1)^b2))^b3;
    assign d2 = b0^b1^ ((b2[7] == 1'b1) ? ((b2 << 1) ^ 8'h1b) : (b2 << 1)) ^ ((b3[7] == 1'b1) ? ((b3 << 1) ^ 8'h1b ^b3) : ((b3 << 1)^b3));
    assign d3 = ((b0[7] == 1'b1) ? ((b0 << 1) ^ 8'h1b ^b0) : ((b0 << 1)^b0))^b1^b2^((b3[7] == 1'b1) ? ((b3 << 1) ^ 8'h1b) : (b3 << 1));
    
    assign word_out = {d0, d1, d2, d3};
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.11.2025 11:40:30
// Design Name: 
// Module Name: ELE_455_AES128_top
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


module ELE_455_AES128_top(

    input CLK,
    input [127:0] ENCRYP_i,
    //input [127:0] plain_text,
    input [127:0] key,
    output reg [127:0] ENCRYP_o
    //output wire [127:0] key
    //output wire [127:0] thing1
    
    );
    
    //reg [127:0] plain_text;
    //reg [127:0] key_i;    
    //reg [127:0] TXT_ENCRYP;
    //reg [127:0] RKEXP_BRAM [43:0];
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
    //wire [127:0] key;
    //reg [2:0] state;
    //wire signal;
    
    initial begin
        //key_i  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        //plain_text  = 128'h3243f6a8885a308d313198a2e0370734;
        //state = 0;
        //plain_text  = 128'h3243f6a8885a308d313198a2e0370734; 
              
    end
    
    
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
    
    ELE_455_AES128_SHFTROWS shftrows(
        .state_in({s_out5,  s_out6,  s_out7,  s_out8, s_out9,  s_out10, s_out11, s_out12,s_out13, s_out14, s_out15, s_out16, s_out17, s_out18, s_out19, s_out20}),   // 128-bit AES state input
        .state_out(shift_o)   
    );  
    
    ELE_455_AES128_MIXCOLS mixcols0(
        .word_in(shift_o[127:96]),  
        .word_out(mixcols0_o)
    );
    
     ELE_455_AES128_MIXCOLS mixcols1(
        .word_in(shift_o[95 : 64]),  
        .word_out(mixcols1_o)
    );
    
    ELE_455_AES128_MIXCOLS mixcols2(
        .word_in(shift_o[63 : 32]),   
        .word_out(mixcols2_o)
    );
    
     ELE_455_AES128_MIXCOLS mixcols3(
        .word_in(shift_o[31 : 0]),
        .word_out(mixcols3_o)
    );
    
    assign addrnd = {mixcols0_o, mixcols1_o, mixcols2_o, mixcols3_o};

    always @(posedge CLK) begin
        ENCRYP_o <= addrnd ^ key;// something wrong with key;
    end
    
    //always @(posedge CLK) begin
    //    if (state == 2) begin
    //    end else begin
    //        if (state == 0) begin
    //            TXT_ENCRYP <= plain_text ^ key;    
    //            state <= state + 1;
    //        end else begin 
    //            //plain_text <= addrnd ^ key;
    //            if (signal == 1) begin
    //                ENCRYP_o <= shift_o ^ key;
    //                state <= state + 1;
    //            end else begin
    //                TXT_ENCRYP <= addrnd ^ key;
    //            end
    //        end  
    //    end
    //end
    //assign thing1 = ENCRYP_o;
endmodule

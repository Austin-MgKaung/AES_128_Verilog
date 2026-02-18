`timescale 1ns/1ps

module aes_decrypt_round(

    input wire clk,
    input  wire [127:0] decrypt_i,
    input  wire [127:0] key,
    output reg [127:0] decrypt_o
    );

    wire [127:0] inv_s_out;
    wire [127:0] inv_shift_o;
    wire [31:0] inv_mixcols0_o;
    wire [31:0] inv_mixcols1_o;
    wire [31:0] inv_mixcols2_o;
    wire [31:0] inv_mixcols3_o;

    initial begin          
    end
    
    invshift invshiftrows(
        .state_in(decrypt_i),   
        .state_out(inv_shift_o)   
    );  
    
    invsubbytes invsubbytes_5 (
        .in_byte(inv_shift_o[127:120]),
        .out_byte(inv_s_out[127:120])  
    );

    invsubbytes invsubbytes_6 (
        .in_byte(inv_shift_o[119:112]),
        .out_byte(inv_s_out[119:112])
    );

    invsubbytes invsubbytes_7 (
        .in_byte(inv_shift_o[111:104]),
        .out_byte(inv_s_out[111:104])  
    );

    invsubbytes invsubbytes_8 (
        .in_byte(inv_shift_o[103:96]),
        .out_byte(inv_s_out[103:96]) 
    );

    invsubbytes invsubbytes_9 (
        .in_byte(inv_shift_o[95:88]),
        .out_byte(inv_s_out[95:88]) 
    );

    invsubbytes invsubbytes_10 (
        .in_byte(inv_shift_o[87:80]),
        .out_byte(inv_s_out[87:80])  
    );

    invsubbytes invsubbytes_11 (
        .in_byte(inv_shift_o[79:72]),
        .out_byte(inv_s_out[79:72])  
    );

    invsubbytes invsubbytes_12 (
        .in_byte(inv_shift_o[71:64]),
        .out_byte(inv_s_out[71:64])  
    );

    invsubbytes invsubbytes_13 (
        .in_byte(inv_shift_o[63:56]),
        .out_byte(inv_s_out[63:56])
    );

    invsubbytes invsubbytes_14 (
        .in_byte(inv_shift_o[55:48]),
        .out_byte(inv_s_out[55:48])
    );

    invsubbytes invsubbytes_15 (
        .in_byte(inv_shift_o[47:40]),
        .out_byte(inv_s_out[47:40])
    );

    invsubbytes invsubbytes_16 (
        .in_byte(inv_shift_o[39:32]),
        .out_byte(inv_s_out[39:32])  
    );

    invsubbytes invsubbytes_17 (
        .in_byte(inv_shift_o[31:24]),
        .out_byte(inv_s_out[31:24])  
    );

    invsubbytes invsubbytes_18 (
        .in_byte(inv_shift_o[23:16]),
        .out_byte(inv_s_out[23:16])  
    );

    invsubbytes invsubbytes_19 (
        .in_byte(inv_shift_o[15:8]),
        .out_byte(inv_s_out[15:8])  
    );

    invsubbytes invsubbytes_20 (
        .in_byte(inv_shift_o[7:0]),
        .out_byte(inv_s_out[7:0])  
    );
    
invmixcol invmixcols0(.clk(clk), .col_in(inv_s_out[31:0]),    .col_out(inv_mixcols0_o));
invmixcol invmixcols1(.clk(clk), .col_in(inv_s_out[63:32]),   .col_out(inv_mixcols1_o));
invmixcol invmixcols2(.clk(clk), .col_in(inv_s_out[95:64]),   .col_out(inv_mixcols2_o));
invmixcol invmixcols3(.clk(clk), .col_in(inv_s_out[127:96]),  .col_out(inv_mixcols3_o));
    
    wire [127:0] inv_addrnd = {inv_mixcols3_o, inv_mixcols2_o, inv_mixcols1_o, inv_mixcols0_o};

    always @(posedge clk) begin
        decrypt_o <= inv_addrnd ^ key;
    end

endmodule

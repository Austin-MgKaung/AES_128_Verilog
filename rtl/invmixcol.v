`timescale 1ns/1ps

module invmixcol  (
    input  wire           clk,       
    input  wire [31:0]    col_in,
    output wire [31:0]    col_out
);

wire [7:0] a = col_in[31:24];
wire [7:0] b = col_in[23:16];
wire [7:0] c = col_in[15:8];
wire [7:0] d = col_in[7:0];

function [7:0] xtime;
    input [7:0] x;
    begin
        xtime = {x[6:0],1'b0} ^ (8'h1B & {8{x[7]}});
    end
endfunction

//Start pipelining

reg [7:0] a2, a4, a8, b2, b4, b8, c2, c4, c8, d2, d4, d8;

always @(posedge clk) begin 

    a2 <= xtime(a);
    a4 <= xtime(a2);
    a8 <= xtime(a4);

    b2 <= xtime(b);
    b4 <= xtime(b2);
    b8 <= xtime(b4);

    c2 <= xtime(c);
    c4 <= xtime(c2);
    c8 <= xtime(c4);

    d2 <= xtime(d);
    d4 <= xtime(d2);
    d8 <= xtime(d4);

end

reg [7:0] a_e_init, a_e, b_bi_init, b_bi, c_di_init, c_di, d_9, a_9, b_e_init, b_e, c_bi, c_bi_init, d_di, d_di_init, a_di, a_di_init, b_9, c_e, c_e_init, d_bi, d_bi_init, a_bi, a_bi_init, b_di, b_di_init, c_9, d_e_init, d_e;

always @(posedge clk) begin

    a_e_init  <= a8 ^ a4;
    a_e  <= a_e_init ^ a2;
    b_bi_init <= b8 ^ b2;
    b_bi <= b_bi_init ^ b;
    c_di_init <= c8 ^ c4;
    c_di <= c_di_init ^ c;
    d_9  <= d8 ^ d;

    a_9  <= a8 ^ a;
    b_e_init  <= b8 ^ b4;
    b_e  <= b_e_init ^ b2;
    c_bi_init <= c8 ^ c2;
    c_bi <= c_bi_init ^ c;
    d_di_init <= d8 ^ d4;
    d_di <= d_di_init ^ d;


    a_di_init <= a8 ^ a4;
    a_di <= a_di_init ^ a;
    b_9  <= b8 ^ b;
    c_e_init  <= c8 ^ c4;
    c_e  <= c_e_init ^ c2;
    d_bi_init <= d8 ^ d2;
    d_bi <= d_bi_init ^ d;

    a_bi_init <= a8 ^ a2;
    a_bi <= a_bi_init ^ a;
    b_di_init <= b8 ^ b4;
    b_di <= b_di_init ^ b;
    c_9  <= c8 ^ c;
    d_e_init  <= d8 ^ d4;
    d_e  <= d_e_init ^ d2;

end

reg [7:0] out0_comb, out0_comb_a, out0_comb_b, out1_comb, out1_comb_a, out1_comb_b, out2_comb_a, out2_comb_b, out2_comb, out3_comb_a, out3_comb_b, out3_comb;

always @(posedge clk) begin

    out0_comb_a <= a_e  ^ b_bi;  
    out0_comb_b <= c_di ^ d_9;
    out0_comb <= out0_comb_a ^ out0_comb_b;

    out1_comb_a <= a_9  ^ b_e;
    out1_comb_b <= c_bi ^ d_di;
    out1_comb <= out1_comb_a   ^ out1_comb_b;
    
    out2_comb_a <= a_di ^ b_9; 
    out2_comb_b <= c_e  ^ d_bi;
    out2_comb <= out2_comb_a   ^ out2_comb_b;
    
    out3_comb_a <= a_bi ^ b_di;  
    out3_comb_b <= c_9  ^ d_e;
    out3_comb <= out3_comb_a  ^ out3_comb_b;

end

assign col_out = {out0_comb, out1_comb, out2_comb, out3_comb};

endmodule




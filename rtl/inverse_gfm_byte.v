`timescale 1ns / 1ps

module inverse_gfm_byte (
    input  wire       clk,
    input  wire [7:0]  byte_in,
    output reg  [7:0]  byte_out
);

function [7:0] xtime;
    input [7:0] x;
    begin
        xtime = {x[6:0], 1'b0} ^ (8'h1B & {8{x[7]}});
    end
endfunction
    
function [7:0] gf_mul;
        input [7:0] aa;
        input [7:0] bb;
        integer i;
        reg [7:0] a_tmp;
        reg [7:0] b_tmp;
        reg [7:0] res;
        begin
            a_tmp = aa;
            b_tmp = bb;
            res   = 8'h00;
            for (i = 0; i < 8; i = i + 1) begin
                if (b_tmp[0]) res = res ^ a_tmp;
                b_tmp = {1'b0, b_tmp[7:1]};
                a_tmp = xtime(a_tmp);
            end
            gf_mul = res;
        end
endfunction

function [7:0] gf_square;
    input [7:0] a;
    begin
        gf_square[0] = a[0] ^ a[4] ^ a[6];
        gf_square[1] = a[4] ^ a[7];
        gf_square[2] = a[1] ^ a[5] ^ a[7];
        gf_square[3] = a[4];
        gf_square[4] = a[2] ^ a[4] ^ a[6];
        gf_square[5] = a[5] ^ a[6];
        gf_square[6] = a[3] ^ a[5] ^ a[7];
        gf_square[7] = a[6];
    end
endfunction

    reg [7:0] a1_r;
    reg [7:0] a2_r, a4_r, a8_r, a16_r, a32_r, a64_r, a128_r;

    wire [7:0] a2_c   = gf_square(a1_r);
    wire [7:0] a4_c   = gf_square(a2_r);
    wire [7:0] a8_c   = gf_square(a4_r);
    wire [7:0] a16_c  = gf_square(a8_r);
    wire [7:0] a32_c  = gf_square(a16_r);
    wire [7:0] a64_c  = gf_square(a32_r);
    wire [7:0] a128_c = gf_square(a64_r);

    reg [7:0] a32_d0;
    reg [7:0] a16_d0, a16_d1;
    reg [7:0] a8_d0,  a8_d1,  a8_d2;
    reg [7:0] a4_d0,  a4_d1,  a4_d2,  a4_d3;
    reg [7:0] a2_d0,  a2_d1,  a2_d2,  a2_d3,  a2_d4;

    reg [7:0] a192_r, a224_r, a240_r, a248_r, a252_r, a254_r;
    
    wire [7:0] a192_w = gf_mul(a128_r, a64_r);
    wire [7:0] a224_w = gf_mul(a192_r, a32_d0);
    wire [7:0] a240_w = gf_mul(a224_r, a16_d1);
    wire [7:0] a248_w = gf_mul(a240_r, a8_d2);
    wire [7:0] a252_w = gf_mul(a248_r, a4_d3);
    wire [7:0] a254_w = gf_mul(a252_r, a2_d4);

    reg [14:0] zero_sr;
    initial zero_sr = 15'd0; 

    always @(posedge clk) begin
    
    
    
        a1_r <= byte_in;

        a2_r   <= a2_c;
        a4_r   <= a4_c;
        a8_r   <= a8_c;
        a16_r  <= a16_c;
        a32_r  <= a32_c;
        a64_r  <= a64_c;
        a128_r <= a128_c;

        a32_d0 <= a32_r;

        a16_d0 <= a16_r;
        a16_d1 <= a16_d0;

        a8_d0  <= a8_r;
        a8_d1  <= a8_d0;
        a8_d2  <= a8_d1;

        a4_d0  <= a4_r;
        a4_d1  <= a4_d0;
        a4_d2  <= a4_d1;
        a4_d3  <= a4_d2;

        a2_d0  <= a2_r;
        a2_d1  <= a2_d0;
        a2_d2  <= a2_d1;
        a2_d3  <= a2_d2;
        a2_d4  <= a2_d3;

        a192_r <= a192_w;
        a224_r <= a224_w;
        a240_r <= a240_w;
        a248_r <= a248_w;
        a252_r <= a252_w;
        a254_r <= a254_w;

        zero_sr <= {zero_sr[13:0], (byte_in == 8'h00)};

        byte_out <= zero_sr[14] ? 8'h00 : a254_r;
    end

endmodule

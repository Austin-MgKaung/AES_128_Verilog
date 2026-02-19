`timescale 1ns/1ps

module invmixcol (
    input  wire        clk,
    input  wire [31:0] col_in,
    output wire [31:0] col_out
);

    wire [7:0] a = col_in[31:24];
    wire [7:0] b = col_in[23:16];
    wire [7:0] c = col_in[15:8];
    wire [7:0] d = col_in[7:0];

    function automatic [7:0] xtime(input [7:0] x);
        begin
            xtime = {x[6:0],1'b0} ^ (8'h1B & {8{x[7]}});
        end
    endfunction


    reg [7:0] a2, a4, a8;
    reg [7:0] b2, b4, b8;
    reg [7:0] c2, c4, c8;
    reg [7:0] d2, d4, d8;

    wire [7:0] a2_n = xtime(a);
    wire [7:0] a4_n = xtime(a2_n);
    wire [7:0] a8_n = xtime(a4_n);

    wire [7:0] b2_n = xtime(b);
    wire [7:0] b4_n = xtime(b2_n);
    wire [7:0] b8_n = xtime(b4_n);

    wire [7:0] c2_n = xtime(c);
    wire [7:0] c4_n = xtime(c2_n);
    wire [7:0] c8_n = xtime(c4_n);

    wire [7:0] d2_n = xtime(d);
    wire [7:0] d4_n = xtime(d2_n);
    wire [7:0] d8_n = xtime(d4_n);


    reg [7:0] a_s1, b_s1, c_s1, d_s1;

    always @(posedge clk) begin
        a2 <= a2_n; a4 <= a4_n; a8 <= a8_n;
        b2 <= b2_n; b4 <= b4_n; b8 <= b8_n;
        c2 <= c2_n; c4 <= c4_n; c8 <= c8_n;
        d2 <= d2_n; d4 <= d4_n; d8 <= d8_n;

        a_s1 <= a; b_s1 <= b; c_s1 <= c; d_s1 <= d;
    end

    reg [7:0] aE, aB, aD, a9;
    reg [7:0] bE, bB, bD, b9;
    reg [7:0] cE, cB, cD, c9;
    reg [7:0] dE, dB, dD, d9;

    always @(posedge clk) begin

        aE <= a8 ^ a4 ^ a2;      
        aB <= a8 ^ a2 ^ a_s1;   
        aD <= a8 ^ a4 ^ a_s1;    
        a9 <= a8 ^ a_s1;         

        bE <= b8 ^ b4 ^ b2;
        bB <= b8 ^ b2 ^ b_s1;
        bD <= b8 ^ b4 ^ b_s1;
        b9 <= b8 ^ b_s1;

        cE <= c8 ^ c4 ^ c2;
        cB <= c8 ^ c2 ^ c_s1;
        cD <= c8 ^ c4 ^ c_s1;
        c9 <= c8 ^ c_s1;

        dE <= d8 ^ d4 ^ d2;
        dB <= d8 ^ d2 ^ d_s1;
        dD <= d8 ^ d4 ^ d_s1;
        d9 <= d8 ^ d_s1;
    end

    reg [7:0] o0, o1, o2, o3;

    always @(posedge clk) begin
        o0 <= aE ^ bB ^ cD ^ d9;
        o1 <= a9 ^ bE ^ cB ^ dD;
        o2 <= aD ^ b9 ^ cE ^ dB;
        o3 <= aB ^ bD ^ c9 ^ dE;
    end

    assign col_out = {o0, o1, o2, o3};

endmodule

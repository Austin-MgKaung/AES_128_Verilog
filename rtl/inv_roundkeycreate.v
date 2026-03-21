`timescale 1ns / 1ps

module inv_roundkeycreate (

    input clk,
    input [3:0] round,
    input [127:0] key_in,
    output wire [127:0] key_out

);

    wire [31:0] w0, w1, w2, w3;
    wire [31:0] p0, p1, p2, p3;
    wire [31:0] g_out;
    wire [31:0] rotword;
    wire [7:0]  s0, s1, s2, s3;
    reg  [7:0]  rcon;

    assign w0 = key_in[127:96];
    assign w1 = key_in[95:64];
    assign w2 = key_in[63:32];
    assign w3 = key_in[31:0];
    assign p3 = w3 ^ w2;
    assign p2 = w2 ^ w1;
    assign p1 = w1 ^ w0;

    assign rotword = {p3[23:0], p3[31:24]};

    ELE_455_AES128_SBOX sbox0 (.in_byte(rotword[31:24]),.out_byte(s0));
    ELE_455_AES128_SBOX sbox1 (.in_byte(rotword[23:16]),.out_byte(s1));
    ELE_455_AES128_SBOX sbox2 (.in_byte(rotword[15:8]),.out_byte(s2));
    ELE_455_AES128_SBOX sbox3 (.in_byte(rotword[7:0]),.out_byte(s3));

    always @(*) begin
        case (round)
            4'd1:  rcon = 8'h01;
            4'd2:  rcon = 8'h02;
            4'd3:  rcon = 8'h04;
            4'd4:  rcon = 8'h08;
            4'd5:  rcon = 8'h10;
            4'd6:  rcon = 8'h20;
            4'd7:  rcon = 8'h40;
            4'd8:  rcon = 8'h80;
            4'd9:  rcon = 8'h1B;
            4'd10: rcon = 8'h36;
            default: rcon = 8'h00;
        endcase
    end

    assign g_out = {s0 ^ rcon, s1, s2, s3};
    assign p0 = w0 ^ g_out;
    assign key_out = {p0, p1, p2, p3};

endmodule

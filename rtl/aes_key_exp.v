 `timescale 1ns/1ps
  `default_nettype none

  module aes_key_exp (
      input  wire        clk,
      input  wire [3:0]  round,
      input  wire [127:0] key_in,
      output wire [127:0] key_out
  );
      reg [7:0] rcon;
      always @(*) begin
          case (round)
              4'd1:  rcon = 8'h01; 4'd2:  rcon = 8'h02;
              4'd3:  rcon = 8'h04; 4'd4:  rcon = 8'h08;
              4'd5:  rcon = 8'h10; 4'd6:  rcon = 8'h20;
              4'd7:  rcon = 8'h40; 4'd8:  rcon = 8'h80;
              4'd9:  rcon = 8'h1b; 4'd10: rcon = 8'h36;
              default: rcon = 8'h00;
          endcase
      end

      wire [7:0] s0, s1, s2, s3;
      aes_sbox sb0 (.in_byte(key_in[23:16]), .out_byte(s0));
      aes_sbox sb1 (.in_byte(key_in[15:8]),  .out_byte(s1));
      aes_sbox sb2 (.in_byte(key_in[7:0]),   .out_byte(s2));
      aes_sbox sb3 (.in_byte(key_in[31:24]), .out_byte(s3));

      wire [31:0] w0 = {s0^rcon, s1, s2, s3} ^ key_in[127:96];
      wire [31:0] w1 = w0 ^ key_in[95:64];
      wire [31:0] w2 = w1 ^ key_in[63:32];
      wire [31:0] w3 = w2 ^ key_in[31:0];

      assign key_out = {w0, w1, w2, w3};

  endmodule
  `default_nettype wire
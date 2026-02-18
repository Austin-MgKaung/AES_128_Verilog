`timescale 1ns/1ps

module aes128_decrypt (
    input  wire         clk,
    input  wire         rst,        // synchronous, active high
    input  wire         start,      // 1-cycle pulse when IDLE
    input  wire [127:0] key,
    input  wire [127:0] block_in,
    output wire         done,       // 1-cycle pulse when block_out valid
    output reg  [127:0] block_out
);

    reg [3:0] Cnt ;
    reg [1:0] state = 2'b00;
    reg       donereg;
    
    
    reg [127:0] round_key0;
    wire [127:0] round_key1;
    wire [127:0] round_key2;
    wire [127:0] round_key3;
    wire [127:0] round_key4;
    wire [127:0] round_key5;
    wire [127:0] round_key6;
    wire [127:0] round_key7;
    wire [127:0] round_key8;
    wire [127:0] round_key9;
    wire [127:0] round_key10;

    reg [127:0] round_key1reg;
    reg [127:0] round_key2reg; 
    reg [127:0] round_key3reg; 
    reg [127:0] round_key4reg; 
    reg [127:0] round_key5reg; 
    reg [127:0] round_key6reg; 
    reg [127:0] round_key7reg; 
    reg [127:0] round_key8reg; 
    reg [127:0] round_key9reg; 
    reg [127:0] round_key10reg; 

    ELE_455_AES128_RKEXP rkexp1 (.CLK(clk),.round(1),.key_i(round_key0),.key(round_key1));
    ELE_455_AES128_RKEXP rkexp2 (.CLK(clk),.round(2),.key_i(round_key1reg),.key(round_key2));
    ELE_455_AES128_RKEXP rkexp3 (.CLK(clk),.round(3),.key_i(round_key2reg),.key(round_key3));
    ELE_455_AES128_RKEXP rkexp4 (.CLK(clk),.round(4),.key_i(round_key3reg),.key(round_key4));
    ELE_455_AES128_RKEXP rkexp5 (.CLK(clk),.round(5),.key_i(round_key4reg),.key(round_key5));
    ELE_455_AES128_RKEXP rkexp6 (.CLK(clk),.round(6),.key_i(round_key5reg),.key(round_key6));
    ELE_455_AES128_RKEXP rkexp7 (.CLK(clk),.round(7),.key_i(round_key6reg),.key(round_key7));
    ELE_455_AES128_RKEXP rkexp8 (.CLK(clk),.round(8),.key_i(round_key7reg),.key(round_key8));
    ELE_455_AES128_RKEXP rkexp9 (.CLK(clk),.round(9),.key_i(round_key8reg),.key(round_key9));
    ELE_455_AES128_RKEXP rkexp10 (.CLK(clk),.round(10),.key_i(round_key9reg),.key(round_key10));

    reg  [127:0] st0;          
    wire [127:0] st1, st2, st3, st4, st5, st6, st7, st8, st9, st10;
        
    aes_decrypt_round r9  (.clk(clk), .decrypt_i(st0 ^ round_key10reg ), .key(round_key9reg), .decrypt_o(st1));
    aes_decrypt_round r8  (.clk(clk), .decrypt_i(st1), .key(round_key8reg), .decrypt_o(st2));
    aes_decrypt_round r7  (.clk(clk), .decrypt_i(st2), .key(round_key7reg), .decrypt_o(st3));
    aes_decrypt_round r6  (.clk(clk), .decrypt_i(st3), .key(round_key6reg), .decrypt_o(st4));
    aes_decrypt_round r5  (.clk(clk), .decrypt_i(st4), .key(round_key5reg), .decrypt_o(st5));
    aes_decrypt_round r4  (.clk(clk), .decrypt_i(st5), .key(round_key4reg), .decrypt_o(st6));
    aes_decrypt_round r3  (.clk(clk), .decrypt_i(st6), .key(round_key3reg), .decrypt_o(st7));
    aes_decrypt_round r2  (.clk(clk), .decrypt_i(st7), .key(round_key2reg), .decrypt_o(st8));
    aes_decrypt_round r1  (.clk(clk), .decrypt_i(st8), .key(round_key1reg), .decrypt_o(st9));

    aes_decrypt_round_final r0 (.clk(clk), .decrypt_i(st9), .key(round_key0), .decrypt_o(st10));
 
always @(posedge clk) begin
        
        case (state)
            2'b00: begin
                donereg <= 0;
                if (start == 1) begin
                    state <= 2'b01;
                end
            end
            2'b01: begin
                round_key0 <= key;
                st0 <= block_in;
                Cnt <= Cnt + 1;
                if (Cnt == 11) begin
                    state <= 2'b10;
                    Cnt <= 0;
                end
                
            end
            2'b10: begin
                donereg <= 1;
                block_out <= st10;
                state <= 2'b00;
            end

            default: state <= 2'b00;
        endcase

        round_key1reg <= round_key1;
        round_key2reg <= round_key2;
        round_key3reg <= round_key3;
        round_key4reg <= round_key4;
        round_key5reg <= round_key5;
        round_key6reg <= round_key6;
        round_key7reg <= round_key7;
        round_key8reg <= round_key8;
        round_key9reg <= round_key9;
        round_key10reg <= round_key10;
         
    end
    
    assign done = donereg;
        
        
`ifndef SYNTHESIS
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, aes128_decrypt);
    end
`endif

endmodule

module aes_decrypt_round(
    input  wire        clk,
    input  wire [127:0] decrypt_i,
    input  wire [127:0] key,
    output wire [127:0] decrypt_o
);

    wire [127:0] inv_shift_o;
    wire [127:0] inv_s_out;

    invshift u_invshift (.state_in(decrypt_i), .state_out(inv_shift_o));

    invsubbytes s0  (.clk(clk), .in_byte(inv_shift_o[127:120]), .out_byte(inv_s_out[127:120]));
    invsubbytes s1  (.clk(clk), .in_byte(inv_shift_o[119:112]), .out_byte(inv_s_out[119:112]));
    invsubbytes s2  (.clk(clk), .in_byte(inv_shift_o[111:104]), .out_byte(inv_s_out[111:104]));
    invsubbytes s3  (.clk(clk), .in_byte(inv_shift_o[103:96]),  .out_byte(inv_s_out[103:96]));
    invsubbytes s4  (.clk(clk), .in_byte(inv_shift_o[95:88]),   .out_byte(inv_s_out[95:88]));
    invsubbytes s5  (.clk(clk), .in_byte(inv_shift_o[87:80]),   .out_byte(inv_s_out[87:80]));
    invsubbytes s6  (.clk(clk), .in_byte(inv_shift_o[79:72]),   .out_byte(inv_s_out[79:72]));
    invsubbytes s7  (.clk(clk), .in_byte(inv_shift_o[71:64]),   .out_byte(inv_s_out[71:64]));
    invsubbytes s8  (.clk(clk), .in_byte(inv_shift_o[63:56]),   .out_byte(inv_s_out[63:56]));
    invsubbytes s9  (.clk(clk), .in_byte(inv_shift_o[55:48]),   .out_byte(inv_s_out[55:48]));
    invsubbytes s10 (.clk(clk), .in_byte(inv_shift_o[47:40]),   .out_byte(inv_s_out[47:40]));
    invsubbytes s11 (.clk(clk), .in_byte(inv_shift_o[39:32]),   .out_byte(inv_s_out[39:32]));
    invsubbytes s12 (.clk(clk), .in_byte(inv_shift_o[31:24]),   .out_byte(inv_s_out[31:24]));
    invsubbytes s13 (.clk(clk), .in_byte(inv_shift_o[23:16]),   .out_byte(inv_s_out[23:16]));
    invsubbytes s14 (.clk(clk), .in_byte(inv_shift_o[15:8]),    .out_byte(inv_s_out[15:8]));
    invsubbytes s15 (.clk(clk), .in_byte(inv_shift_o[7:0]),     .out_byte(inv_s_out[7:0]));

    wire [127:0] ark = inv_s_out ^ key;

    wire [31:0] mc0, mc1, mc2, mc3;
    invmixcol m0 (.clk(clk), .col_in(ark[31:0]),    .col_out(mc0));
    invmixcol m1 (.clk(clk), .col_in(ark[63:32]),   .col_out(mc1));
    invmixcol m2 (.clk(clk), .col_in(ark[95:64]),   .col_out(mc2));
    invmixcol m3 (.clk(clk), .col_in(ark[127:96]),  .col_out(mc3));

    assign decrypt_o = {mc3, mc2, mc1, mc0};

endmodule

module aes_decrypt_round_final (
    input  wire        clk,
    input  wire [127:0] decrypt_i,
    input  wire [127:0] key,
    output reg  [127:0] decrypt_o
);

    wire [127:0] inv_shift_o;
    wire [127:0] inv_s_out;

    invshift u_invshift (.state_in(decrypt_i), .state_out(inv_shift_o));

    invsubbytes s0  (.clk(clk), .in_byte(inv_shift_o[127:120]), .out_byte(inv_s_out[127:120]));
    invsubbytes s1  (.clk(clk), .in_byte(inv_shift_o[119:112]), .out_byte(inv_s_out[119:112]));
    invsubbytes s2  (.clk(clk), .in_byte(inv_shift_o[111:104]), .out_byte(inv_s_out[111:104]));
    invsubbytes s3  (.clk(clk), .in_byte(inv_shift_o[103:96]),  .out_byte(inv_s_out[103:96]));
    invsubbytes s4  (.clk(clk), .in_byte(inv_shift_o[95:88]),   .out_byte(inv_s_out[95:88]));
    invsubbytes s5  (.clk(clk), .in_byte(inv_shift_o[87:80]),   .out_byte(inv_s_out[87:80]));
    invsubbytes s6  (.clk(clk), .in_byte(inv_shift_o[79:72]),   .out_byte(inv_s_out[79:72]));
    invsubbytes s7  (.clk(clk), .in_byte(inv_shift_o[71:64]),   .out_byte(inv_s_out[71:64]));
    invsubbytes s8  (.clk(clk), .in_byte(inv_shift_o[63:56]),   .out_byte(inv_s_out[63:56]));
    invsubbytes s9  (.clk(clk), .in_byte(inv_shift_o[55:48]),   .out_byte(inv_s_out[55:48]));
    invsubbytes s10 (.clk(clk), .in_byte(inv_shift_o[47:40]),   .out_byte(inv_s_out[47:40]));
    invsubbytes s11 (.clk(clk), .in_byte(inv_shift_o[39:32]),   .out_byte(inv_s_out[39:32]));
    invsubbytes s12 (.clk(clk), .in_byte(inv_shift_o[31:24]),   .out_byte(inv_s_out[31:24]));
    invsubbytes s13 (.clk(clk), .in_byte(inv_shift_o[23:16]),   .out_byte(inv_s_out[23:16]));
    invsubbytes s14 (.clk(clk), .in_byte(inv_shift_o[15:8]),    .out_byte(inv_s_out[15:8]));
    invsubbytes s15 (.clk(clk), .in_byte(inv_shift_o[7:0]),     .out_byte(inv_s_out[7:0]));

    wire [127:0] ark1 = inv_s_out ^ key;
     
     always @(posedge clk) begin
         decrypt_o = ark1;
      end

endmodule


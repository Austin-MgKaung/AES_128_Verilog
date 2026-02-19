`timescale 1ns/1ps

module aes_decrypt_round(
    input  wire         clk,
    input  wire [127:0]  decrypt_i,
    input  wire [127:0]  key,
    output reg  [127:0]  decrypt_o
);

    wire [127:0] inv_shift_o;
    wire [127:0] inv_s_out;
    wire [127:0] addkey_out;

    wire [31:0] inv_mixcols0_o, inv_mixcols1_o, inv_mixcols2_o, inv_mixcols3_o;
    wire [127:0] inv_mix_out;

    invshift invshiftrows(
        .state_in (decrypt_i),
        .state_out(inv_shift_o)
    );


    invsubbytes s0  (.in_byte(inv_shift_o[127:120]), .out_byte(inv_s_out[127:120]));
    invsubbytes s1  (.in_byte(inv_shift_o[119:112]), .out_byte(inv_s_out[119:112]));
    invsubbytes s2  (.in_byte(inv_shift_o[111:104]), .out_byte(inv_s_out[111:104]));
    invsubbytes s3  (.in_byte(inv_shift_o[103:96 ]), .out_byte(inv_s_out[103:96 ]));
    invsubbytes s4  (.in_byte(inv_shift_o[95 :88 ]), .out_byte(inv_s_out[95 :88 ]));
    invsubbytes s5  (.in_byte(inv_shift_o[87 :80 ]), .out_byte(inv_s_out[87 :80 ]));
    invsubbytes s6  (.in_byte(inv_shift_o[79 :72 ]), .out_byte(inv_s_out[79 :72 ]));
    invsubbytes s7  (.in_byte(inv_shift_o[71 :64 ]), .out_byte(inv_s_out[71 :64 ]));
    invsubbytes s8  (.in_byte(inv_shift_o[63 :56 ]), .out_byte(inv_s_out[63 :56 ]));
    invsubbytes s9  (.in_byte(inv_shift_o[55 :48 ]), .out_byte(inv_s_out[55 :48 ]));
    invsubbytes s10 (.in_byte(inv_shift_o[47 :40 ]), .out_byte(inv_s_out[47 :40 ]));
    invsubbytes s11 (.in_byte(inv_shift_o[39 :32 ]), .out_byte(inv_s_out[39 :32 ]));
    invsubbytes s12 (.in_byte(inv_shift_o[31 :24 ]), .out_byte(inv_s_out[31 :24 ]));
    invsubbytes s13 (.in_byte(inv_shift_o[23 :16 ]), .out_byte(inv_s_out[23 :16 ]));
    invsubbytes s14 (.in_byte(inv_shift_o[15 :8  ]), .out_byte(inv_s_out[15 :8  ]));
    invsubbytes s15 (.in_byte(inv_shift_o[7  :0  ]), .out_byte(inv_s_out[7  :0  ]));

    assign addkey_out = inv_s_out ^ key;

    invmixcol invmixcols0(.col_in(addkey_out[31:0]),    .col_out(inv_mixcols0_o));
    invmixcol invmixcols1(.col_in(addkey_out[63:32]),   .col_out(inv_mixcols1_o));
    invmixcol invmixcols2(.col_in(addkey_out[95:64]),   .col_out(inv_mixcols2_o));
    invmixcol invmixcols3(.col_in(addkey_out[127:96]),  .col_out(inv_mixcols3_o));

    assign inv_mix_out = {inv_mixcols3_o, inv_mixcols2_o, inv_mixcols1_o, inv_mixcols0_o};

    always @(posedge clk) begin
        decrypt_o <= inv_mix_out;
    end

endmodule

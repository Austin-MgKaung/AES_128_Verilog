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

    localparam [1:0] S_IDLE = 2'd0;
    localparam [1:0] S_LOAD = 2'd1;
    localparam [1:0] S_RUN  = 2'd2;
    localparam [1:0] S_DONE = 2'd3;

    reg [1:0] state;
    reg [8:0] cnt;
    reg       donereg;
    assign done = donereg;

    // Registered inputs
    reg [127:0] base_key;
    reg [127:0] ct_reg;

    // RKEXP (unchanged) => pure wire cascade from registered base_key
    wire [127:0] rk1_w, rk2_w, rk3_w, rk4_w, rk5_w, rk6_w, rk7_w, rk8_w, rk9_w, rk10_w;

    ELE_455_AES128_RKEXP rkexp1  (.CLK(clk), .round(4'd1),  .key_i(base_key), .key(rk1_w));
    ELE_455_AES128_RKEXP rkexp2  (.CLK(clk), .round(4'd2),  .key_i(rk1_w),    .key(rk2_w));
    ELE_455_AES128_RKEXP rkexp3  (.CLK(clk), .round(4'd3),  .key_i(rk2_w),    .key(rk3_w));
    ELE_455_AES128_RKEXP rkexp4  (.CLK(clk), .round(4'd4),  .key_i(rk3_w),    .key(rk4_w));
    ELE_455_AES128_RKEXP rkexp5  (.CLK(clk), .round(4'd5),  .key_i(rk4_w),    .key(rk5_w));
    ELE_455_AES128_RKEXP rkexp6  (.CLK(clk), .round(4'd6),  .key_i(rk5_w),    .key(rk6_w));
    ELE_455_AES128_RKEXP rkexp7  (.CLK(clk), .round(4'd7),  .key_i(rk6_w),    .key(rk7_w));
    ELE_455_AES128_RKEXP rkexp8  (.CLK(clk), .round(4'd8),  .key_i(rk7_w),    .key(rk8_w));
    ELE_455_AES128_RKEXP rkexp9  (.CLK(clk), .round(4'd9),  .key_i(rk8_w),    .key(rk9_w));
    ELE_455_AES128_RKEXP rkexp10 (.CLK(clk), .round(4'd10), .key_i(rk9_w),    .key(rk10_w));

    // Datapath
    reg  [127:0] st0;          // CT ^ RK10 registered
    wire [127:0] st1, st2, st3, st4, st5, st6, st7, st8, st9, st10;

    aes_decrypt_round r9  (.clk(clk), .decrypt_i(st0), .key(rk9_w), .decrypt_o(st1));
    aes_decrypt_round r8  (.clk(clk), .decrypt_i(st1), .key(rk8_w), .decrypt_o(st2));
    aes_decrypt_round r7  (.clk(clk), .decrypt_i(st2), .key(rk7_w), .decrypt_o(st3));
    aes_decrypt_round r6  (.clk(clk), .decrypt_i(st3), .key(rk6_w), .decrypt_o(st4));
    aes_decrypt_round r5  (.clk(clk), .decrypt_i(st4), .key(rk5_w), .decrypt_o(st5));
    aes_decrypt_round r4  (.clk(clk), .decrypt_i(st5), .key(rk4_w), .decrypt_o(st6));
    aes_decrypt_round r3  (.clk(clk), .decrypt_i(st6), .key(rk3_w), .decrypt_o(st7));
    aes_decrypt_round r2  (.clk(clk), .decrypt_i(st7), .key(rk2_w), .decrypt_o(st8));
    aes_decrypt_round r1  (.clk(clk), .decrypt_i(st8), .key(rk1_w), .decrypt_o(st9));

    aes_decrypt_round_final r0 (.clk(clk), .decrypt_i(st9), .key(base_key), .decrypt_o(st10));

    // Capture st10 one more time so top never samples "old" st10 in same edge
    reg [127:0] st10_q;
    always @(posedge clk) begin
        st10_q <= st10;
    end

    // ---- Latency model (UPDATED) ----
    localparam integer ISB_LAT = 17;  // <-- FIXED (was 16)
    localparam integer IMC_LAT = 3;
    localparam integer MID_LAT = ISB_LAT + IMC_LAT; // 20
    localparam integer FIN_LAT = ISB_LAT + 1;       // 18


    localparam integer RUN_LAT = 1 + (9*MID_LAT) + FIN_LAT + 1; // 1 + 180 + 18 + 1 = 200

    // Control
    always @(posedge clk) begin
        if (rst) begin
            state     <= S_IDLE;
            cnt       <= 9'd0;
            donereg   <= 1'b0;
            block_out <= 128'd0;

            base_key  <= 128'd0;
            ct_reg    <= 128'd0;
            st0       <= 128'd0;
        end else begin
            donereg <= 1'b0;

            case (state)
                S_IDLE: begin
                    cnt <= 9'd0;
                    if (start) begin
                        base_key <= key;
                        ct_reg   <= block_in;
                        state    <= S_LOAD;
                    end
                end

                S_LOAD: begin
                    // initial AddRoundKey with RK10
                    st0   <= ct_reg ^ rk10_w;
                    cnt   <= 9'd0;
                    state <= S_RUN;
                end

                S_RUN: begin
                    cnt <= cnt + 9'd1;
                    if (cnt == RUN_LAT) begin
                        block_out <= st10_q;
                        donereg   <= 1'b1;
                        state     <= S_DONE;
                        cnt       <= 9'd0;
                    end
                end

                S_DONE: begin
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

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

    localparam integer ISB_LAT = 17;  // <-- match top

    wire [127:0] inv_shift_o;
    wire [127:0] inv_s_out;

    // Delay key by ISB_LAT to align with inv_s_out
    reg [127:0] key_pipe [0:ISB_LAT-1];
    integer k;
    always @(posedge clk) begin
        key_pipe[0] <= key;
        for (k=1; k<ISB_LAT; k=k+1)
            key_pipe[k] <= key_pipe[k-1];
    end
    wire [127:0] key_aligned = key_pipe[ISB_LAT-1];

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

    wire [127:0] ark = inv_s_out ^ key_aligned;

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

    localparam integer ISB_LAT = 17;  // <-- match top

    wire [127:0] inv_shift_o;
    wire [127:0] inv_s_out;

    // Delay key by ISB_LAT to align with inv_s_out
    reg [127:0] key_pipe [0:ISB_LAT-1];
    integer k;
    always @(posedge clk) begin
        key_pipe[0] <= key;
        for (k=1; k<ISB_LAT; k=k+1)
            key_pipe[k] <= key_pipe[k-1];
    end
    wire [127:0] key_aligned = key_pipe[ISB_LAT-1];

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

    always @(*) begin
      decrypt_o <= inv_s_out ^ key_aligned;
     end

     
endmodule


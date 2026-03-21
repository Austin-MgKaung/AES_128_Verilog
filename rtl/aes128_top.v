// Uses LFSR for Key and user input for PT

`timescale 1ns/1ps

module aes128_top (

    input  wire         clk,
    input  wire         rst,       // synchronous, active high
    input  wire         start,     // 1-cycle pulse when IDLE
    //input  wire [127:0] key,
    input  wire [127:0] block_in,
    output wire         done,      // 1-cycle pulse when block_out valid
    output reg  [127:0] block_out
);

    // Encryption registers
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
    
    reg [127:0] ENCRYP_o1;
    wire [127:0] ENCRYP_o2;
    wire [127:0] ENCRYP_o3;
    wire [127:0] ENCRYP_o4;
    wire [127:0] ENCRYP_o5;
    wire [127:0] ENCRYP_o6;
    wire [127:0] ENCRYP_o7;
    wire [127:0] ENCRYP_o8;
    wire [127:0] ENCRYP_o9;
    wire [127:0] ENCRYP_o10;

    // LFSR for key generation
    reg [31:0] lfsr_key;

    // ENCRYPTION ROUNDS
    ELE_455_AES128_top top1  (.clk(clk), .round(1),  .ENCRYP_i(ENCRYP_o1 ^ round_key0), .ENCRYP_o(ENCRYP_o2),  .key_in(round_key0), .key_out(round_key1));
    ELE_455_AES128_top top2  (.clk(clk), .round(2),  .ENCRYP_i(ENCRYP_o2),              .ENCRYP_o(ENCRYP_o3),  .key_in(round_key1), .key_out(round_key2));
    ELE_455_AES128_top top3  (.clk(clk), .round(3),  .ENCRYP_i(ENCRYP_o3),              .ENCRYP_o(ENCRYP_o4),  .key_in(round_key2), .key_out(round_key3));
    ELE_455_AES128_top top4  (.clk(clk), .round(4),  .ENCRYP_i(ENCRYP_o4),              .ENCRYP_o(ENCRYP_o5),  .key_in(round_key3), .key_out(round_key4));
    ELE_455_AES128_top top5  (.clk(clk), .round(5),  .ENCRYP_i(ENCRYP_o5),              .ENCRYP_o(ENCRYP_o6),  .key_in(round_key4), .key_out(round_key5));
    ELE_455_AES128_top top6  (.clk(clk), .round(6),  .ENCRYP_i(ENCRYP_o6),              .ENCRYP_o(ENCRYP_o7),  .key_in(round_key5), .key_out(round_key6));
    ELE_455_AES128_top top7  (.clk(clk), .round(7),  .ENCRYP_i(ENCRYP_o7),              .ENCRYP_o(ENCRYP_o8),  .key_in(round_key6), .key_out(round_key7));
    ELE_455_AES128_top top8  (.clk(clk), .round(8),  .ENCRYP_i(ENCRYP_o8),              .ENCRYP_o(ENCRYP_o9),  .key_in(round_key7), .key_out(round_key8));
    ELE_455_AES128_top top9  (.clk(clk), .round(9),  .ENCRYP_i(ENCRYP_o9),              .ENCRYP_o(ENCRYP_o10), .key_in(round_key8), .key_out(round_key9));
    EEE_455_AES128_topmod top10 (.clk(clk), .round(10), .ENCRYP_i(ENCRYP_o10),          .ENCRYP_o(st0),        .key_in(round_key9), .key_out(round_key10));

    // Decryption registers
    wire [127:0] st0;
    wire [127:0] st1;
    wire [127:0] st2;
    wire [127:0] st3;
    wire [127:0] st4;
    wire [127:0] st5;
    wire [127:0] st6;
    wire [127:0] st7;
    wire [127:0] st8;
    wire [127:0] st9;
    wire [127:0] st10;

    wire [127:0] round_key11;
    wire [127:0] round_key12;
    wire [127:0] round_key13;
    wire [127:0] round_key14;
    wire [127:0] round_key15;
    wire [127:0] round_key16;
    wire [127:0] round_key17;
    wire [127:0] round_key18;
    wire [127:0] round_key19;
    wire [127:0] round_key20;

    // DECRYPTION ROUNDS
    aes_decrypt_round       r9 (.clk(clk), .round(10), .decrypt_i(st0 ^ round_key10), .key_in(round_key10), .decrypt_o(st1),  .key_out(round_key11));
    aes_decrypt_round       r8 (.clk(clk), .round(9),  .decrypt_i(st1),               .key_in(round_key11), .decrypt_o(st2),  .key_out(round_key12));
    aes_decrypt_round       r7 (.clk(clk), .round(8),  .decrypt_i(st2),               .key_in(round_key12), .decrypt_o(st3),  .key_out(round_key13));
    aes_decrypt_round       r6 (.clk(clk), .round(7),  .decrypt_i(st3),               .key_in(round_key13), .decrypt_o(st4),  .key_out(round_key14));
    aes_decrypt_round       r5 (.clk(clk), .round(6),  .decrypt_i(st4),               .key_in(round_key14), .decrypt_o(st5),  .key_out(round_key15));
    aes_decrypt_round       r4 (.clk(clk), .round(5),  .decrypt_i(st5),               .key_in(round_key15), .decrypt_o(st6),  .key_out(round_key16));
    aes_decrypt_round       r3 (.clk(clk), .round(4),  .decrypt_i(st6),               .key_in(round_key16), .decrypt_o(st7),  .key_out(round_key17));
    aes_decrypt_round       r2 (.clk(clk), .round(3),  .decrypt_i(st7),               .key_in(round_key17), .decrypt_o(st8),  .key_out(round_key18));
    aes_decrypt_round       r1 (.clk(clk), .round(2),  .decrypt_i(st8),               .key_in(round_key18), .decrypt_o(st9),  .key_out(round_key19));
    aes_decrypt_round_final r0 (.clk(clk), .round(1),  .decrypt_i(st9),               .key_in(round_key19), .decrypt_o(st10), .key_out(round_key20));

    reg [31:0] seed_val = 32'hDEBCEFFF;

    always @(posedge clk) begin
    seed_val <= seed_val + 1;
    
        if (rst) begin
            lfsr_key <= seed_val;
            //round_key0 <= 128'd0;
            //ENCRYP_o1  <= 128'd0;
            //block_out  <= 128'd0;
        end else begin
            if (start) begin
                ENCRYP_o1  <= block_in;
                round_key0 <= {4{lfsr_key}};
                lfsr_key   <= {lfsr_key[30:0], lfsr_key[31] ^ lfsr_key[21] ^ lfsr_key[1] ^ lfsr_key[0]};
            end
    
            block_out <= st10;
        end
    end

    // Valid pipeline
    reg [20:0] valid_pipe;
    always @(posedge clk) begin
        if (rst)
            valid_pipe <= 21'd0;
        else
            valid_pipe <= {valid_pipe[19:0], start};
    end

    assign done = valid_pipe[20];

`ifndef SYNTHESIS
    // Simple waveform dump for simulators (ignored for synthesis)
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, aes128_top);
    end
`endif

endmodule

`default_nettype wire

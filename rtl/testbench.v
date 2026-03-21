`timescale 1ns/1ps
`default_nettype none

module tb_aes128_top;

    reg          clk;
    reg          rst;
    reg          start;
    reg  [127:0] key;
    reg  [127:0] block_in;
    wire         done;
    wire [127:0] block_out;

    integer i;
    integer out_idx;
    integer pass_count;
    integer fail_count;

    // DUT
    aes128_top dut (
        .clk       (clk),
        .rst       (rst),
        .start     (start),
        //.key       (key),
        .block_in  (block_in),
        .done      (done),
        .block_out (block_out)
    );

    // Clock: 10 ns period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Store 10 test vectors
    reg [127:0] keys [0:9];
    reg [127:0] pts  [0:9];

    initial begin
        //keys[0] = 128'h000102030405060708090a0b0c0d0e0f;
        pts [0] = 128'h00112233445566778899aabbccddeeff;

        //keys[1] = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        pts [1] = 128'h6bc1bee22e409f96e93d7e117393172a;

        //keys[2] = 128'h00000000000000000000000000000000;
        pts [2] = 128'h00000000000000000000000000000000;

        //keys[3] = 128'hffffffffffffffffffffffffffffffff;
        pts [3] = 128'hffffffffffffffffffffffffffffffff;

        //keys[4] = 128'h0123456789abcdeffedcba9876543210;
        pts [4] = 128'h0011aabbccddeeff1122334455667788;

        //keys[5] = 128'h0f0e0d0c0b0a09080706050403020100;
        pts [5] = 128'hffeeddccbbaa99887766554433221100;

        //keys[6] = 128'h1f1e1d1c1b1a19181716151413121110;
        pts [6] = 128'h102132435465768798a9babbdcddedef;

        //keys[7] = 128'haa55aa55aa55aa55aa55aa55aa55aa55;
        pts [7] = 128'h55aa55aa55aa55aa55aa55aa55aa55aa;

        //keys[8] = 128'h13579bdf2468ace013579bdf2468ace0;
        pts [8] = 128'hfedcba98765432100123456789abcdef;

        //keys[9] = 128'hdeadbeefcafebabe1122334455667788;
        pts [9] = 128'h8899aabbccddeeff0011223344556677;
    end

    // Drive a new input every clock cycle
    initial begin
        rst        = 1'b1;
        start      = 1'b0;
        key        = 128'd0;
        block_in   = 128'd0;
        out_idx    = 0;
        pass_count = 0;
        fail_count = 0;

        // Reset for a few cycles
        repeat (3) @(posedge clk);
        rst <= 1'b0;

        // Feed 10 inputs in 10 consecutive cycles
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            start    <= 1'b1;
            //key      <= keys[i];
            block_in <= pts[i];

            //$display("INPUT  %0d @ %0t | KEY=%032h | PT=%032h",
                     //i, $time, keys[i], pts[i]);
        end

        // Deassert start after final input
        @(posedge clk);
        start    <= 1'b0;
        key      <= 128'd0;
        block_in <= 128'd0;
    end

    // Capture outputs as done pulses appear
    always @(posedge clk) begin
        if (!rst && done) begin
            $display("OUTPUT %0d @ %0t | OUT=%032h",
                     out_idx, $time, block_out);

            // Since your top does encrypt followed by decrypt,
            // expected final output should match original plaintext.
            if (out_idx < 10) begin
                if (block_out == pts[out_idx]) begin
                    $display("RESULT %0d: PASS", out_idx);
                    pass_count = pass_count + 1;
                end else begin
                    $display("RESULT %0d: FAIL | expected %032h",
                             out_idx, pts[out_idx]);
                    fail_count = fail_count + 1;
                end
            end

            out_idx = out_idx + 1;

            if (out_idx == 10) begin
                $display("============================================================");
                $display("Completed 10 outputs");
                $display("PASS = %0d", pass_count);
                $display("FAIL = %0d", fail_count);
                $display("============================================================");
                #20;
                $finish;
            end
        end
    end

endmodule

`default_nettype wire


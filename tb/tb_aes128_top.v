`timescale 1ns/1ps
`default_nettype none

// =============================================================================
// Testbench for aes128_top
//
// Tests the encrypt-then-decrypt roundtrip:
//   - Feed plaintext + key into DUT
//   - Wait for done (encrypt ~13 cycles + decrypt ~21 cycles = ~34 cycles)
//   - Check:  decrypted_text == original plaintext  (roundtrip test)
//   - Check:  cipher_text    == known ciphertext     (where provided)
//
// One block is processed at a time (FSM-based, not pipelined).
// =============================================================================

module tb_aes128_top;

    // -------------------------------------------------------------------------
    // DUT signals
    // -------------------------------------------------------------------------
    reg          clk;
    reg          rst;
    reg          start;
    reg  [127:0] key;
    reg  [127:0] plaintext;
    wire         done;
    wire [127:0] cipher_text;
    wire [127:0] decrypted_text;

    // -------------------------------------------------------------------------
    // Instantiate DUT
    // -------------------------------------------------------------------------
    aes128_top dut (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .key            (key),
        .plaintext      (plaintext),
        .done           (done),
        .cipher_text    (cipher_text),
        .decrypted_text (decrypted_text)
    );

    // -------------------------------------------------------------------------
    // Clock: 10 ns period (100 MHz)
    // -------------------------------------------------------------------------
    initial clk = 1'b0;
    always  #5 clk = ~clk;

    // -------------------------------------------------------------------------
    // Test counters
    // -------------------------------------------------------------------------
    integer pass_count;
    integer fail_count;

    // =========================================================================
    // Task: run_one_test
    //   Apply one key+plaintext, pulse start for one cycle, wait for done,
    //   then check decrypted_text == in_pt and (optionally) cipher_text == exp_ct.
    //   Pass check_ct = 0 to skip the ciphertext check.
    // =========================================================================
    task automatic run_one_test;
        input [127:0] in_key;
        input [127:0] in_pt;
        input [127:0] exp_ct;   // set to 0 to skip ciphertext check
        input         check_ct; // 1 = verify cipher_text against exp_ct
        input [31:0]  tn;       // test index for display

        integer timeout;
        reg     timed_out;

        begin
            timed_out = 1'b0;

            @(negedge clk);
            key       = in_key;
            plaintext = in_pt;
            start     = 1'b1;

            @(negedge clk);
            start = 1'b0;

            timeout = 0;
            while (!done && timeout < 200) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 200) begin
                $display("TIMEOUT  test %0d - done never asserted!", tn);
                fail_count = fail_count + 1;
                timed_out  = 1'b1;
            end

            if (!timed_out) begin
                @(posedge clk); #1;

                $display("------------------------------------------------------------");
                $display("TEST     %0d", tn);
                $display("KEY      = %032h", in_key);
                $display("PLAIN    = %032h", in_pt);
                $display("CIPHER   = %032h", cipher_text);
                $display("DECRYPT  = %032h", decrypted_text);

                if (decrypted_text === in_pt) begin
                    $display("ROUNDTRIP test %0d: PASS", tn);
                    pass_count = pass_count + 1;
                end else begin
                    $display("ROUNDTRIP test %0d: FAIL", tn);
                    $display("  expected decrypt = %032h", in_pt);
                    $display("  got              = %032h", decrypted_text);
                    fail_count = fail_count + 1;
                end

                if (check_ct) begin
                    if (cipher_text === exp_ct) begin
                        $display("CIPHERTEXT test %0d: PASS", tn);
                        pass_count = pass_count + 1;
                    end else begin
                        $display("CIPHERTEXT test %0d: FAIL", tn);
                        $display("  expected cipher  = %032h", exp_ct);
                        $display("  got              = %032h", cipher_text);
                        fail_count = fail_count + 1;
                    end
                end
            end
        end
    endtask

    // =========================================================================
    // Main stimulus
    // =========================================================================
    initial begin
        pass_count = 0;
        fail_count = 0;
        start      = 1'b0;
        key        = 128'h0;
        plaintext  = 128'h0;

        // Reset
        rst = 1'b1;
        repeat (4) @(posedge clk);
        rst = 1'b0;
        @(posedge clk);

        // =====================================================================
        // Test vectors
        // =====================================================================

        // -----------------------------------------------------------------
        // Test 0: NIST FIPS-197 Appendix C.1
        //   Key : 000102030405060708090a0b0c0d0e0f
        //   PT  : 00112233445566778899aabbccddeeff
        //   CT  : 69c4e0d86a7b0430d8cdb78070b4c55a
        // -----------------------------------------------------------------
        run_one_test(
            128'h000102030405060708090a0b0c0d0e0f,
            128'h00112233445566778899aabbccddeeff,
            128'h69c4e0d86a7b0430d8cdb78070b4c55a,
            1'b1,
            32'd0
        );

        // -----------------------------------------------------------------
        // Test 1: NIST SP800-38A Block 1 (AES-128-ECB)
        //   Key : 2b7e151628aed2a6abf7158809cf4f3c
        //   PT  : 6bc1bee22e409f96e93d7e117393172a
        //   CT  : 3ad77bb40d7a3660a89ecaf32466ef97
        // -----------------------------------------------------------------
        run_one_test(
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h6bc1bee22e409f96e93d7e117393172a,
            128'h3ad77bb40d7a3660a89ecaf32466ef97,
            1'b1,
            32'd1
        );

        // -----------------------------------------------------------------
        // Test 2: NIST SP800-38A Block 2
        //   Key : 2b7e151628aed2a6abf7158809cf4f3c
        //   PT  : ae2d8a571e03ac9c9eb76fac45af8e51
        //   CT  : f5d3d58503b9699de785895a96fdbaaf
        // -----------------------------------------------------------------
        run_one_test(
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'hae2d8a571e03ac9c9eb76fac45af8e51,
            128'hf5d3d58503b9699de785895a96fdbaaf,
            1'b1,
            32'd2
        );

        // -----------------------------------------------------------------
        // Test 3: NIST SP800-38A Block 3
        //   Key : 2b7e151628aed2a6abf7158809cf4f3c
        //   PT  : 30c81c46a35ce411e5fbc1191a0a52ef
        //   CT  : 43b1cd7f598ece23881b00e3ed030688
        // -----------------------------------------------------------------
        run_one_test(
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h30c81c46a35ce411e5fbc1191a0a52ef,
            128'h43b1cd7f598ece23881b00e3ed030688,
            1'b1,
            32'd3
        );

        // -----------------------------------------------------------------
        // Test 4: All-zero key, all-zero plaintext
        //   CT  : 66e94bd4ef8a2c3b884cfa59ca342b2e
        // -----------------------------------------------------------------
        run_one_test(
            128'h00000000000000000000000000000000,
            128'h00000000000000000000000000000000,
            128'h66e94bd4ef8a2c3b884cfa59ca342b2e,
            1'b1,
            32'd4
        );

        // -----------------------------------------------------------------
        // Test 5: All-ones key, all-ones plaintext (roundtrip only)
        // -----------------------------------------------------------------
        run_one_test(
            128'hffffffffffffffffffffffffffffffff,
            128'hffffffffffffffffffffffffffffffff,
            128'h0,
            1'b0,
            32'd5
        );

        // -----------------------------------------------------------------
        // Test 6: Alternating 0x55/0xAA pattern (roundtrip only)
        // -----------------------------------------------------------------
        run_one_test(
            128'haa55aa55aa55aa55aa55aa55aa55aa55,
            128'h55aa55aa55aa55aa55aa55aa55aa55aa,
            128'h0,
            1'b0,
            32'd6
        );

        // -----------------------------------------------------------------
        // Test 7: Incrementing bytes key, decrementing bytes plaintext
        // -----------------------------------------------------------------
        run_one_test(
            128'h0123456789abcdeffedcba9876543210,
            128'hfedcba9876543210123456789abcdef0,
            128'h0,
            1'b0,
            32'd7
        );

        // -----------------------------------------------------------------
        // Test 8: Single bit set in plaintext (roundtrip only)
        // -----------------------------------------------------------------
        run_one_test(
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h80000000000000000000000000000000,
            128'h0,
            1'b0,
            32'd8
        );

        // -----------------------------------------------------------------
        // Test 9: Single bit set in key (roundtrip only)
        // -----------------------------------------------------------------
        run_one_test(
            128'h80000000000000000000000000000000,
            128'h00000000000000000000000000000000,
            128'h0,
            1'b0,
            32'd9
        );

        // =====================================================================
        // Summary
        // =====================================================================
        $display("============================================================");
        $display("All tests done.");
        $display("PASS = %0d  |  FAIL = %0d", pass_count, fail_count);
        $display("============================================================");
        #20;
        $finish;
    end

endmodule

`default_nettype wire

`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// AES inverse affine transform (for InvSubBytes)
// b = (s <<< 1) ^ (s <<< 3) ^ (s <<< 6) ^ 8'h05
// where s is the S-box output byte, and b is the multiplicative inverse.
// -----------------------------------------------------------------------------
module invaffine (
    input  wire        clk,
    input  wire [7:0]  in_byte,
    output reg  [7:0]  out_byte
);

    reg [7:0] s0;
    reg [7:0] r1_1, r3_1, r6_1;
    reg [7:0] x2;
    reg [7:0] x3;

    always @(posedge clk) begin
        s0   <= in_byte;

        r1_1 <= {s0[6:0], s0[7]};
        r3_1 <= {s0[4:0], s0[7:5]};
        r6_1 <= {s0[1:0], s0[7:2]};

        x2   <= r1_1 ^ r3_1;

        x3   <= x2 ^ r6_1;

        out_byte <= x3 ^ 8'h05;
    end

endmodule




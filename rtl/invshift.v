`timescale 1ns / 1ps

module invshift (
    input  wire [127:0] state_in,   // 128-bit AES state input
    output wire [127:0] state_out   // 128-bit AES state output
);

    // Unpack 128-bit input into 16 bytes
    wire [7:0] b0  = state_in[127:120];
    wire [7:0] b1  = state_in[119:112];
    wire [7:0] b2  = state_in[111:104];
    wire [7:0] b3  = state_in[103:96];
    wire [7:0] b4  = state_in[95:88];
    wire [7:0] b5  = state_in[87:80];
    wire [7:0] b6  = state_in[79:72];
    wire [7:0] b7  = state_in[71:64];
    wire [7:0] b8  = state_in[63:56];
    wire [7:0] b9  = state_in[55:48];
    wire [7:0] b10 = state_in[47:40];
    wire [7:0] b11 = state_in[39:32];
    wire [7:0] b12 = state_in[31:24];
    wire [7:0] b13 = state_in[23:16];
    wire [7:0] b14 = state_in[15:8];
    wire [7:0] b15 = state_in[7:0];

    // Apply Inverse ShiftRows rotation (shift right)
    wire [7:0] o0  = b0;
    wire [7:0] o1  = b13;  // row 1 right by 1
    wire [7:0] o2  = b10;  // row 2 right by 2
    wire [7:0] o3  = b7;   // row 3 right by 3

    wire [7:0] o4  = b4;
    wire [7:0] o5  = b1;
    wire [7:0] o6  = b14;
    wire [7:0] o7  = b11;

    wire [7:0] o8  = b8;
    wire [7:0] o9  = b5;
    wire [7:0] o10 = b2;
    wire [7:0] o11 = b15;

    wire [7:0] o12 = b12;
    wire [7:0] o13 = b9;
    wire [7:0] o14 = b6;
    wire [7:0] o15 = b3;

    // Pack output bytes back into 128-bit state
    assign state_out = {
        o0,  o1,  o2,  o3,
        o4,  o5,  o6,  o7,
        o8,  o9,  o10, o11,
        o12, o13, o14, o15
    };

endmodule

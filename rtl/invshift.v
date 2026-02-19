`timescale 1ns/1ps

// ===============================================================
// AES Inverse ShiftRows Transformation (for Decryption)
//
// Matches the exact byte ordering convention used in aes_shift_rows:
//   state_in[127:120] -> b0, ... , state_in[7:0] -> b15
//
// AES state is column-major:
//   [b0  b4  b8  b12]
//   [b1  b5  b9  b13]
//   [b2  b6  b10 b14]
//   [b3  b7  b11 b15]
//
// InvShiftRows performs a cyclic RIGHT rotation:
//   Row 0: no shift
//   Row 1: shift right by 1 byte
//   Row 2: shift right by 2 bytes
//   Row 3: shift right by 3 bytes
// ===============================================================


module invshift (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

// Unpack (same as shift_rows)
wire [7:0] b0;
wire [7:0] b1;
wire [7:0] b2;
wire [7:0] b3;
wire [7:0] b4;
wire [7:0] b5;
wire [7:0] b6;
wire [7:0] b7;
wire [7:0] b8;
wire [7:0] b9;
wire [7:0] b10;
wire [7:0] b11;
wire [7:0] b12;
wire [7:0] b13;
wire [7:0] b14;
wire [7:0] b15;

assign b0  = state_in[127:120];
assign b1  = state_in[119:112];
assign b2  = state_in[111:104];
assign b3  = state_in[103:96];
assign b4  = state_in[95:88];
assign b5  = state_in[87:80];
assign b6  = state_in[79:72];
assign b7  = state_in[71:64];
assign b8  = state_in[63:56];
assign b9  = state_in[55:48];
assign b10 = state_in[47:40];
assign b11 = state_in[39:32];
assign b12 = state_in[31:24];
assign b13 = state_in[23:16];
assign b14 = state_in[15:8];
assign b15 = state_in[7:0];

wire [7:0] o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15;
    
    // Apply InvShiftRows (right rotations)
    //
    // Row 0: [b0, b4, b8,  b12]  -> [b0,  b4,  b8,  b12]
    // Row 1: [b1, b5, b9,  b13]  -> [b13, b1,  b5,  b9 ]
    // Row 2: [b2, b6, b10, b14]  -> [b10, b14, b2,  b6 ]
    // Row 3: [b3, b7, b11, b15]  -> [b7,  b11, b15, b3 ]

    // Repack into column-major order (o0..o15 are column-major bytes)

    
assign o0  = b0;
assign o1  = b13;
assign o2  = b10;
assign o3  = b7;
assign o4  = b4;
assign o5  = b1;
assign o6  = b14;
assign o7  = b11;
assign o8  = b8;
assign o9  = b5;
assign o10 = b2;
assign o11 = b15;
assign o12 = b12;
assign o13 = b9;
assign o14 = b6;
assign o15 = b3;

// Pack output (same ordering convention)
assign state_out = {
    o0,o1,o2,o3,
    o4,o5,o6,o7,
    o8,o9,o10,o11,
    o12,o13,o14,o15
};

endmodule

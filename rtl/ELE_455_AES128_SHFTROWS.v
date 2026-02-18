`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2025 16:42:57
// Design Name: 
// Module Name: ELE_455_AES128_SHFTROWS
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ELE_455_AES128_SHFTROWS(
    input  wire [127:0] state_in,   // 128-bit AES state input
    output wire [127:0] state_out   // 128-bit AES state output
);

    // -----------------------------------------------------------
    // Unpack 128-bit input into 16 bytes (b0..b15)
    // This matches the Python implementation exactly:
    //   state_in[127:120] corresponds to state[0]
    //   state_in[119:112] corresponds to state[1]
    //   ...
    //   state_in[7:0]     corresponds to state[15]
    // -----------------------------------------------------------
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

    // -----------------------------------------------------------
    // Apply ShiftRows rotation
    //
    // Row 0 (no shift)
    //   [b0, b4, b8, b12]
    //
    // Row 1 (shift left by 1)
    //   [b1, b5, b9, b13] -> [b5, b9, b13, b1]
    //
    // Row 2 (shift left by 2)
    //   [b2, b6, b10, b14] -> [b10, b14, b2, b6]
    //
    // Row 3 (shift left by 3)
    //   [b3, b7, b11, b15] -> [b15, b3, b7, b11]
    //
    // After shifting, repack into column-major order:
    //
    //   Column 0: [o0,  o1,  o2,  o3 ]
    //   Column 1: [o4,  o5,  o6,  o7 ]
    //   Column 2: [o8,  o9,  o10, o11]
    //   Column 3: [o12, o13, o14, o15]
    // -----------------------------------------------------------

    wire [7:0] o0  = b0;
    wire [7:0] o1  = b5;
    wire [7:0] o2  = b10;
    wire [7:0] o3  = b15;

    wire [7:0] o4  = b4;
    wire [7:0] o5  = b9;
    wire [7:0] o6  = b14;
    wire [7:0] o7  = b3;

    wire [7:0] o8  = b8;
    wire [7:0] o9  = b13;
    wire [7:0] o10 = b2;
    wire [7:0] o11 = b7;

    wire [7:0] o12 = b12;
    wire [7:0] o13 = b1;
    wire [7:0] o14 = b6;
    wire [7:0] o15 = b11;

    // -----------------------------------------------------------
    // Pack output bytes back into 128-bit state
    // (maintains the same byte ordering convention as the input)
    // -----------------------------------------------------------
    assign state_out = {
        o0,  o1,  o2,  o3,
        o4,  o5,  o6,  o7,
        o8,  o9,  o10, o11,
        o12, o13, o14, o15
    };

endmodule



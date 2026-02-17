module invshift (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

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

assign state_out = {
    o0,o1,o2,o3,
    o4,o5,o6,o7,
    o8,o9,o10,o11,
    o12,o13,o14,o15
};

endmodule

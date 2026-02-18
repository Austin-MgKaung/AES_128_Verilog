`timescale 1ns/1ps

module invsubbytes (
    input  wire        clk,
    input  wire [7:0] in_byte,
    output wire [7:0] out_byte
);

    reg [7:0] s;

    always @(*) begin
        case (in_byte)
            8'h00: s = 8'h52;  8'h01: s = 8'h09;  8'h02: s = 8'h6A;  8'h03: s = 8'hD5;
            8'h04: s = 8'h30;  8'h05: s = 8'h36;  8'h06: s = 8'hA5;  8'h07: s = 8'h38;
            8'h08: s = 8'hBF;  8'h09: s = 8'h40;  8'h0A: s = 8'hA3;  8'h0B: s = 8'h9E;
            8'h0C: s = 8'h81;  8'h0D: s = 8'hF3;  8'h0E: s = 8'hD7;  8'h0F: s = 8'hFB;

            8'h10: s = 8'h7C;  8'h11: s = 8'hE3;  8'h12: s = 8'h39;  8'h13: s = 8'h82;
            8'h14: s = 8'h9B;  8'h15: s = 8'h2F;  8'h16: s = 8'hFF;  8'h17: s = 8'h87;
            8'h18: s = 8'h34;  8'h19: s = 8'h8E;  8'h1A: s = 8'h43;  8'h1B: s = 8'h44;
            8'h1C: s = 8'hC4;  8'h1D: s = 8'hDE;  8'h1E: s = 8'hE9;  8'h1F: s = 8'hCB;

            8'h20: s = 8'h54;  8'h21: s = 8'h7B;  8'h22: s = 8'h94;  8'h23: s = 8'h32;
            8'h24: s = 8'hA6;  8'h25: s = 8'hC2;  8'h26: s = 8'h23;  8'h27: s = 8'h3D;
            8'h28: s = 8'hEE;  8'h29: s = 8'h4C;  8'h2A: s = 8'h95;  8'h2B: s = 8'h0B;
            8'h2C: s = 8'h42;  8'h2D: s = 8'hFA;  8'h2E: s = 8'hC3;  8'h2F: s = 8'h4E;

            8'h30: s = 8'h08;  8'h31: s = 8'h2E;  8'h32: s = 8'hA1;  8'h33: s = 8'h66;
            8'h34: s = 8'h28;  8'h35: s = 8'hD9;  8'h36: s = 8'h24;  8'h37: s = 8'hB2;
            8'h38: s = 8'h76;  8'h39: s = 8'h5B;  8'h3A: s = 8'hA2;  8'h3B: s = 8'h49;
            8'h3C: s = 8'h6D;  8'h3D: s = 8'h8B;  8'h3E: s = 8'hD1;  8'h3F: s = 8'h25;

            8'h40: s = 8'h72;  8'h41: s = 8'hF8;  8'h42: s = 8'hF6;  8'h43: s = 8'h64;
            8'h44: s = 8'h86;  8'h45: s = 8'h68;  8'h46: s = 8'h98;  8'h47: s = 8'h16;
            8'h48: s = 8'hD4;  8'h49: s = 8'hA4;  8'h4A: s = 8'h5C;  8'h4B: s = 8'hCC;
            8'h4C: s = 8'h5D;  8'h4D: s = 8'h65;  8'h4E: s = 8'hB6;  8'h4F: s = 8'h92;

            8'h50: s = 8'h6C;  8'h51: s = 8'h70;  8'h52: s = 8'h48;  8'h53: s = 8'h50;
            8'h54: s = 8'hFD;  8'h55: s = 8'hED;  8'h56: s = 8'hB9;  8'h57: s = 8'hDA;
            8'h58: s = 8'h5E;  8'h59: s = 8'h15;  8'h5A: s = 8'h46;  8'h5B: s = 8'h57;
            8'h5C: s = 8'hA7;  8'h5D: s = 8'h8D;  8'h5E: s = 8'h9D;  8'h5F: s = 8'h84;

            8'h60: s = 8'h90;  8'h61: s = 8'hD8;  8'h62: s = 8'hAB;  8'h63: s = 8'h00;
            8'h64: s = 8'h8C;  8'h65: s = 8'hBC;  8'h66: s = 8'hD3;  8'h67: s = 8'h0A;
            8'h68: s = 8'hF7;  8'h69: s = 8'hE4;  8'h6A: s = 8'h58;  8'h6B: s = 8'h05;
            8'h6C: s = 8'hB8;  8'h6D: s = 8'hB3;  8'h6E: s = 8'h45;  8'h6F: s = 8'h06;

            8'h70: s = 8'hD0;  8'h71: s = 8'h2C;  8'h72: s = 8'h1E;  8'h73: s = 8'h8F;
            8'h74: s = 8'hCA;  8'h75: s = 8'h3F;  8'h76: s = 8'h0F;  8'h77: s = 8'h02;
            8'h78: s = 8'hC1;  8'h79: s = 8'hAF;  8'h7A: s = 8'hBD;  8'h7B: s = 8'h03;
            8'h7C: s = 8'h01;  8'h7D: s = 8'h13;  8'h7E: s = 8'h8A;  8'h7F: s = 8'h6B;

            8'h80: s = 8'h3A;  8'h81: s = 8'h91;  8'h82: s = 8'h11;  8'h83: s = 8'h41;
            8'h84: s = 8'h4F;  8'h85: s = 8'h67;  8'h86: s = 8'hDC;  8'h87: s = 8'hEA;
            8'h88: s = 8'h97;  8'h89: s = 8'hF2;  8'h8A: s = 8'hCF;  8'h8B: s = 8'hCE;
            8'h8C: s = 8'hF0;  8'h8D: s = 8'hB4;  8'h8E: s = 8'hE6;  8'h8F: s = 8'h73;

            8'h90: s = 8'h96;  8'h91: s = 8'hAC;  8'h92: s = 8'h74;  8'h93: s = 8'h22;
            8'h94: s = 8'hE7;  8'h95: s = 8'hAD;  8'h96: s = 8'h35;  8'h97: s = 8'h85;
            8'h98: s = 8'hE2;  8'h99: s = 8'hF9;  8'h9A: s = 8'h37;  8'h9B: s = 8'hE8;
            8'h9C: s = 8'h1C;  8'h9D: s = 8'h75;  8'h9E: s = 8'hDF;  8'h9F: s = 8'h6E;

            8'hA0: s = 8'h47;  8'hA1: s = 8'hF1;  8'hA2: s = 8'h1A;  8'hA3: s = 8'h71;
            8'hA4: s = 8'h1D;  8'hA5: s = 8'h29;  8'hA6: s = 8'hC5;  8'hA7: s = 8'h89;
            8'hA8: s = 8'h6F;  8'hA9: s = 8'hB7;  8'hAA: s = 8'h62;  8'hAB: s = 8'h0E;
            8'hAC: s = 8'hAA;  8'hAD: s = 8'h18;  8'hAE: s = 8'hBE;  8'hAF: s = 8'h1B;

            8'hB0: s = 8'hFC;  8'hB1: s = 8'h56;  8'hB2: s = 8'h3E;  8'hB3: s = 8'h4B;
            8'hB4: s = 8'hC6;  8'hB5: s = 8'hD2;  8'hB6: s = 8'h79;  8'hB7: s = 8'h20;
            8'hB8: s = 8'h9A;  8'hB9: s = 8'hDB;  8'hBA: s = 8'hC0;  8'hBB: s = 8'hFE;
            8'hBC: s = 8'h78;  8'hBD: s = 8'hCD;  8'hBE: s = 8'h5A;  8'hBF: s = 8'hF4;

            8'hC0: s = 8'h1F;  8'hC1: s = 8'hDD;  8'hC2: s = 8'hA8;  8'hC3: s = 8'h33;
            8'hC4: s = 8'h88;  8'hC5: s = 8'h07;  8'hC6: s = 8'hC7;  8'hC7: s = 8'h31;
            8'hC8: s = 8'hB1;  8'hC9: s = 8'h12;  8'hCA: s = 8'h10;  8'hCB: s = 8'h59;
            8'hCC: s = 8'h27;  8'hCD: s = 8'h80;  8'hCE: s = 8'hEC;  8'hCF: s = 8'h5F;

            8'hD0: s = 8'h60;  8'hD1: s = 8'h51;  8'hD2: s = 8'h7F;  8'hD3: s = 8'hA9;
            8'hD4: s = 8'h19;  8'hD5: s = 8'hB5;  8'hD6: s = 8'h4A;  8'hD7: s = 8'h0D;
            8'hD8: s = 8'h2D;  8'hD9: s = 8'hE5;  8'hDA: s = 8'h7A;  8'hDB: s = 8'h9F;
            8'hDC: s = 8'h93;  8'hDD: s = 8'hC9;  8'hDE: s = 8'h9C;  8'hDF: s = 8'hEF;

            8'hE0: s = 8'hA0;  8'hE1: s = 8'hE0;  8'hE2: s = 8'h3B;  8'hE3: s = 8'h4D;
            8'hE4: s = 8'hAE;  8'hE5: s = 8'h2A;  8'hE6: s = 8'hF5;  8'hE7: s = 8'hB0;
            8'hE8: s = 8'hC8;  8'hE9: s = 8'hEB;  8'hEA: s = 8'hBB;  8'hEB: s = 8'h3C;
            8'hEC: s = 8'h83;  8'hED: s = 8'h53;  8'hEE: s = 8'h99;  8'hEF: s = 8'h61;

            8'hF0: s = 8'h17;  8'hF1: s = 8'h2B;  8'hF2: s = 8'h04;  8'hF3: s = 8'h7E;
            8'hF4: s = 8'hBA;  8'hF5: s = 8'h77;  8'hF6: s = 8'hD6;  8'hF7: s = 8'h26;
            8'hF8: s = 8'hE1;  8'hF9: s = 8'h69;  8'hFA: s = 8'h14;  8'hFB: s = 8'h63;
            8'hFC: s = 8'h55;  8'hFD: s = 8'h21;  8'hFE: s = 8'h0C;  8'hFF: s = 8'h7D;

            default: s = 8'h00;
        endcase
    end

    assign out_byte = s;

endmodule



`timescale 1ns/1ps
`default_nettype none

// -----------------------------------------------------------------------------
// AES-128 encryptor core (student implementation)
//
// IMPORTANT:
//   - You must implement AES-128 *encryption* only (no decryption here).
//   - Interface is fixed; do not rename ports or change widths.
//   - Behaviour:
//       * Pulse 'start' high for one clock in IDLE.
//       * After a fixed latency, assert 'done' high for exactly one clock.
//       * On that 'done' cycle, 'block_out' must hold the ciphertext.
//   - Your design will be checked against the Python model in model/aes128.py.
// -----------------------------------------------------------------------------
module aes128_encrypt (
    input  wire         clk,
    input  wire         rst,       // synchronous, active high
    input  wire         start,     // 1-cycle pulse when IDLE
    input  wire [127:0] key,
    input  wire [127:0] block_in,
    output wire         done,      // 1-cycle pulse when block_out valid
    output reg  [127:0] block_out
);
    reg [1:0] state = 2'b00;
    reg [3:0] Cnt;

    reg [127:0] ENCRYP_o1;
    reg [127:0] round_key0;
    wire [127:0] round_key1;
    reg [127:0] round_key1reg;
    wire [127:0] round_key2;
    wire [127:0] round_key3;
    wire [127:0] round_key4;
    wire [127:0] round_key5;
    wire [127:0] round_key6;
    wire [127:0] round_key7;
    wire [127:0] round_key8;
    wire [127:0] round_key9;
    wire [127:0] round_key10;

    
    reg [127:0] clk_out1del;
    reg clk_out2del;
    reg clk_out3del;
    reg clk_out4del;
    reg clk_out5del;
    reg clk_out6del;
    reg clk_out7del;
    reg clk_out8del;
    reg clk_out9del;
    reg clk_out10del;
    reg donereg;
    reg [127:0] round_key2reg; 
    reg [127:0] round_key3reg; 
    reg [127:0] round_key4reg; 
    reg [127:0] round_key5reg; 
    reg [127:0] round_key6reg; 
    reg [127:0] round_key7reg; 
    reg [127:0] round_key8reg; 
    reg [127:0] round_key9reg; 
    reg [127:0] round_key10reg; 

    wire clk_out1;
    wire [127:0] ENCRYP_o2;
    wire [127:0] ENCRYP_o3;
    wire [127:0] ENCRYP_o4;
    wire [127:0] ENCRYP_o5;
    wire [127:0] ENCRYP_o6;
    wire [127:0] ENCRYP_o7;
    wire [127:0] ENCRYP_o8;
    wire [127:0] ENCRYP_o9;
    wire [127:0] ENCRYP_o10;
    wire [127:0] ENCRYP_o11;

    ELE_455_AES128_RKEXP rkexp1 (
     
        .CLK(clk),//clk_out1), 
        .round(1),
        .key_i(round_key0),
        .key(round_key1)
        
    );
    
    ELE_455_AES128_RKEXP rkexp2 (
     
        .CLK(clk),//clk_out1),
        .round(2),
        .key_i(round_key1reg),
        .key(round_key2)
        
    );
    
    ELE_455_AES128_RKEXP rkexp3 (
     
        .CLK(clk),//clk_out1),
        .round(3),
        .key_i(round_key2reg),
        .key(round_key3)
        
    );
    
    ELE_455_AES128_RKEXP rkexp4 (
     
        .CLK(clk),//clk_out1),
        .round(4),
        .key_i(round_key3reg),
        .key(round_key4)
        
    );
    
    ELE_455_AES128_RKEXP rkexp5 (
     
        .CLK(clk),//clk_out1),
        .round(5),
        .key_i(round_key4reg),
        .key(round_key5)
        
    );
    
    ELE_455_AES128_RKEXP rkexp6 (
     
        .CLK(clk),//clk_out1),
        .round(6),
        .key_i(round_key5reg),
        .key(round_key6)
        
    );
    
    ELE_455_AES128_RKEXP rkexp7 (
     
        .CLK(clk),//clk_out1),
        .round(7),
        .key_i(round_key6reg),
        .key(round_key7)
        
    );
    
    ELE_455_AES128_RKEXP rkexp8 (
     
        .CLK(clk),//clk_out1),
        .round(8),
        .key_i(round_key7reg),
        .key(round_key8)
        
    );
    
    ELE_455_AES128_RKEXP rkexp9 (
     
        .CLK(clk),//clk_out1),
        .round(9),
        .key_i(round_key8reg),
        .key(round_key9)
        
    );
    
    ELE_455_AES128_RKEXP rkexp10 (
     
        .CLK(clk),//clk_out1),
        .round(10),
        .key_i(round_key9reg),
        .key(round_key10)
        
    );

    ELE_455_AES128_top top1 (
        .CLK(clk),//clk_out1),
        .ENCRYP_i(ENCRYP_o1 ^ round_key0),
        .ENCRYP_o(ENCRYP_o2),
        .key(round_key1reg)//,
        //.key(thing1)  
    );
    
    ELE_455_AES128_top top2 (
        .CLK(clk),//clk_out1),
        .ENCRYP_i(ENCRYP_o2),
        .ENCRYP_o(ENCRYP_o3),
        .key(round_key2reg)//,
        //.key(thing1)  
    );
    
    ELE_455_AES128_top top3 (
        .CLK(clk),//clk_out1),
        .ENCRYP_i(ENCRYP_o3),
        .ENCRYP_o(ENCRYP_o4),
        .key(round_key3reg)//,
        //.key(thing1)  
    );
    
    ELE_455_AES128_top top4 (
        .CLK(clk),//clk_out1),
        .ENCRYP_i(ENCRYP_o4),
        .ENCRYP_o(ENCRYP_o5),
        .key(round_key4reg)//,
        //.key(thing1)  
    );
    
    ELE_455_AES128_top top5 (
        .CLK(clk),//clk_out1),
        .ENCRYP_i(ENCRYP_o5),
        .ENCRYP_o(ENCRYP_o6),
        .key(round_key5reg)//,
        //.key(thing1)  
    );
    
    ELE_455_AES128_top top6 (
        .CLK(clk),//clk_out1),
        .ENCRYP_i(ENCRYP_o6),
        .ENCRYP_o(ENCRYP_o7),
        .key(round_key6reg)//,
        //.key(thing1)  
    );
    
    ELE_455_AES128_top top7 (
        .CLK(clk),//clk_out1),
        .ENCRYP_i(ENCRYP_o7),
        .ENCRYP_o(ENCRYP_o8),
        .key(round_key7reg)//,
        //.key(thing1)  
    );
    
    ELE_455_AES128_top top8 (
        .CLK(clk),//clk_out1),
        .ENCRYP_i(ENCRYP_o8),
        .ENCRYP_o(ENCRYP_o9),
        .key(round_key8reg)//,
        //.key(thing1)  
    );
    
    ELE_455_AES128_top top9 (
        .CLK(clk),//clk_out1),
        .ENCRYP_i(ENCRYP_o9),
        .ENCRYP_o(ENCRYP_o10),
        .key(round_key9reg)//,
        //.key(thing1)  
    );
    
    EEE_455_AES128_topmod top10 (
        .CLK(clk),//clk_out1),
        .ENCRYP_i(ENCRYP_o10),
        .ENCRYP_o(ENCRYP_o11),
        .key(round_key10reg)//,
        //.key(thing1)  
    );
    
    
    
    always @(posedge clk) begin
        
        case (state)
            2'b00: begin
                donereg <= 0;
                if (start == 1) begin
                    state <= 2'b01;
                end
            end
            2'b01: begin
                round_key0 <= key;
                ENCRYP_o1 <= block_in;
                Cnt <= Cnt + 1;
                if (Cnt == 11) begin
                    state <= 2'b10;
                    Cnt <= 0;
                end
                
            end
            2'b10: begin
                donereg <= 1;
                block_out <= ENCRYP_o11;
                state <= 2'b00;
            end

            default: state <= 2'b00;


        
        endcase
        
        round_key1reg <= round_key1;
        round_key2reg <= round_key2;
        round_key3reg <= round_key3;
        round_key4reg <= round_key4;
        round_key5reg <= round_key5;
        round_key6reg <= round_key6;
        round_key7reg <= round_key7;
        round_key8reg <= round_key8;
        round_key9reg <= round_key9;
        round_key10reg <= round_key10;
         
        
    end
    
    
    assign done = donereg;
   
    
`ifndef SYNTHESIS
    // Simple waveform dump for simulators (ignored for synthesis)
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, aes128_encrypt);
    end
`endif

endmodule


`default_nettype wire

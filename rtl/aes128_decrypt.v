`timescale 1ns/1ps

module aes128_decrypt (
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

reg [127:0] round_key1reg;
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

reg [127:0] decrypt_o1;
wire [127:0] decrypt_o2;
wire [127:0] decrypt_o3;
wire [127:0] decrypt_o4;
wire [127:0] decrypt_o5;
wire [127:0] decrypt_o6;
wire [127:0] decrypt_o7;
wire [127:0] decrypt_o8;
wire [127:0] decrypt_o9;
wire [127:0] decrypt_o10;
wire [127:0] decrypt_o11;

ELE_455_AES128_RKEXP rkexp1 (
 
    .CLK(clk),
    .round(1),
    .key_i(round_key0),
    .key(round_key1)
    
);

ELE_455_AES128_RKEXP rkexp2 (
 
    .CLK(clk),
    .round(2),
    .key_i(round_key1reg),
    .key(round_key2)
    
);

ELE_455_AES128_RKEXP rkexp3 (
 
    .CLK(clk),
    .round(3),
    .key_i(round_key2reg),
    .key(round_key3)
    
);

ELE_455_AES128_RKEXP rkexp4 (
 
    .CLK(clk),
    .round(4),
    .key_i(round_key3reg),
    .key(round_key4)
    
);

ELE_455_AES128_RKEXP rkexp5 (
 
    .CLK(clk),
    .round(5),
    .key_i(round_key4reg),
    .key(round_key5)
    
);

ELE_455_AES128_RKEXP rkexp6 (
 
    .CLK(clk),
    .round(6),
    .key_i(round_key5reg),
    .key(round_key6)
    
);

ELE_455_AES128_RKEXP rkexp7 (
 
    .CLK(clk),
    .round(7),
    .key_i(round_key6reg),
    .key(round_key7)
    
);

ELE_455_AES128_RKEXP rkexp8 (
 
    .CLK(clk),
    .round(8),
    .key_i(round_key7reg),
    .key(round_key8)
    
);

ELE_455_AES128_RKEXP rkexp9 (
 
    .CLK(clk),
    .round(9),
    .key_i(round_key8reg),
    .key(round_key9)
    
);

ELE_455_AES128_RKEXP rkexp10 (
 
    .CLK(clk),
    .round(10),
    .key_i(round_key9reg),
    .key(round_key10)
    
);



aes_decrypt_round top1 (
    .clk(clk),
    .decrypt_i(decrypt_o1),
    .decrypt_o(decrypt_o2),
    .key(round_key10reg)
);

    
    aes_decrypt_round top2 (
        .clk(clk),
        .decrypt_i(decrypt_o2),
        .decrypt_o(decrypt_o3),
        .key(round_key9reg)
    );
    
    aes_decrypt_round top3 (
        .clk(clk),
        .decrypt_i(decrypt_o3),
        .decrypt_o(decrypt_o4),
        .key(round_key8reg)
    );
    
    aes_decrypt_round top4 (
        .clk(clk),
        .decrypt_i(decrypt_o4),
        .decrypt_o(decrypt_o5),
        .key(round_key7reg) 
    );
    
    aes_decrypt_round top5 (
        .clk(clk),
        .decrypt_i(decrypt_o5),
        .decrypt_o(decrypt_o6),
        .key(round_key6reg) 
    );
    
    aes_decrypt_round top6 (
        .clk(clk),
        .decrypt_i(decrypt_o6),
        .decrypt_o(decrypt_o7),
        .key(round_key5reg)
    );
    
    aes_decrypt_round top7 (
        .clk(clk),
        .decrypt_i(decrypt_o7),
        .decrypt_o(decrypt_o8),
        .key(round_key4reg) 
    );
    
    aes_decrypt_round top8 (
        .clk(clk),
        .decrypt_i(decrypt_o8),
        .decrypt_o(decrypt_o9),
        .key(round_key3reg)
    );
    
    aes_decrypt_round top9 (
        .clk(clk),
        .decrypt_i(decrypt_o9),
        .decrypt_o(decrypt_o10),
        .key(round_key2reg)
    );
    
    aes_decrypt_round_final top10 (
        .clk(clk),
        .decrypt_i(decrypt_o10),
        .decrypt_o(decrypt_o11),
        .key(round_key1reg)  
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
                decrypt_o1 <= block_in;
                Cnt <= Cnt + 1;
                if (Cnt == 11) begin
                    state <= 2'b10;
                    Cnt <= 0;
                end
                
            end
            2'b10: begin
                donereg <= 1;
                block_out <= decrypt_o11;
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
        $dumpvars(0, aes128_decrypt);
    end
`endif

endmodule

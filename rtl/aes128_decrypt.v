`timescale 1ns/1ps

module aes128_decrypt (
    input  wire         clk,
    input  wire         rst,        // synchronous, active high
    input  wire         start,      // 1-cycle pulse when IDLE
    input  wire [127:0] key,
    input  wire [127:0] block_in,
    output wire         done,       // 1-cycle pulse when block_out valid
    output reg  [127:0] block_out
);

    reg [1:0] state = 2'b00;
    
    
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

    ELE_455_AES128_RKEXP rkexp1 (.CLK(clk),.round(1),.key_i(round_key0),.key(round_key1));
    ELE_455_AES128_RKEXP rkexp2 (.CLK(clk),.round(2),.key_i(round_key1reg),.key(round_key2));
    ELE_455_AES128_RKEXP rkexp3 (.CLK(clk),.round(3),.key_i(round_key2reg),.key(round_key3));
    ELE_455_AES128_RKEXP rkexp4 (.CLK(clk),.round(4),.key_i(round_key3reg),.key(round_key4));
    ELE_455_AES128_RKEXP rkexp5 (.CLK(clk),.round(5),.key_i(round_key4reg),.key(round_key5));
    ELE_455_AES128_RKEXP rkexp6 (.CLK(clk),.round(6),.key_i(round_key5reg),.key(round_key6));
    ELE_455_AES128_RKEXP rkexp7 (.CLK(clk),.round(7),.key_i(round_key6reg),.key(round_key7));
    ELE_455_AES128_RKEXP rkexp8 (.CLK(clk),.round(8),.key_i(round_key7reg),.key(round_key8));
    ELE_455_AES128_RKEXP rkexp9 (.CLK(clk),.round(9),.key_i(round_key8reg),.key(round_key9));
    ELE_455_AES128_RKEXP rkexp10 (.CLK(clk),.round(10),.key_i(round_key9reg),.key(round_key10));

    reg  [127:0] st0;          
    wire [127:0] st1, st2, st3, st4, st5, st6, st7, st8, st9, st10;
        
    aes_decrypt_round r9  (.clk(clk), .decrypt_i(st0 ^ round_key10reg ), .key(round_key9reg), .decrypt_o(st1));
    aes_decrypt_round r8  (.clk(clk), .decrypt_i(st1), .key(round_key8reg), .decrypt_o(st2));
    aes_decrypt_round r7  (.clk(clk), .decrypt_i(st2), .key(round_key7reg), .decrypt_o(st3));
    aes_decrypt_round r6  (.clk(clk), .decrypt_i(st3), .key(round_key6reg), .decrypt_o(st4));
    aes_decrypt_round r5  (.clk(clk), .decrypt_i(st4), .key(round_key5reg), .decrypt_o(st5));
    aes_decrypt_round r4  (.clk(clk), .decrypt_i(st5), .key(round_key4reg), .decrypt_o(st6));
    aes_decrypt_round r3  (.clk(clk), .decrypt_i(st6), .key(round_key3reg), .decrypt_o(st7));
    aes_decrypt_round r2  (.clk(clk), .decrypt_i(st7), .key(round_key2reg), .decrypt_o(st8));
    aes_decrypt_round r1  (.clk(clk), .decrypt_i(st8), .key(round_key1reg), .decrypt_o(st9));

    aes_decrypt_round_final r0 (.clk(clk), .decrypt_i(st9), .key(round_key0), .decrypt_o(st10));
 
  reg donereg;

    localparam IDLE = 2'd0, BUSY = 2'd1;
    reg [7:0] LAT;
   
always @(posedge clk) begin
      if (rst) begin
        donereg <= 0;
        state   <= IDLE;
        LAT     <= 8'd0;
      end else begin
        case (state)
    
          IDLE: begin
            LAT     <= 8'd0;
            donereg <= 0;
    
            if (start == 1'b1) begin
              round_key0 <= key;
              st0  <= block_in;
              state      <= BUSY;
            end
          end
    
          BUSY: begin
            if (LAT == 8'd20) begin
              donereg   <= 1;
              block_out <= st10;
              state     <= IDLE;
              LAT       <= 8'd0;
            end else begin
              LAT <= LAT + 8'd1;
            end
          end
    
          default: begin
            state <= IDLE;
            LAT   <= 8'd0;
          end
    
        endcase
      end

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
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, aes128_decrypt);
    end
`endif

endmodule

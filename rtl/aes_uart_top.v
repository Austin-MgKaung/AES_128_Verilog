// Wrapper module to allow serial communication
// Wrapper module to allow serial communication

`timescale 1ns / 1ps

module aes_uart_top #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire clk,
    input  wire rst,
    input  wire uart_rx,
    output wire uart_tx
);

    // UART RX/TX signals
    wire [7:0] rx_data;
    wire       rx_valid;

    reg  [7:0] tx_data;
    reg        tx_start;
    wire       tx_busy;

    // AES interface
    reg         aes_start;
    reg  [127:0] aes_din;
    wire [127:0] aes_dout;
    wire        aes_done;

    // Hex decode/encode
    wire [3:0] rx_nibble;
    wire       rx_hex_valid;

    hex_to_nibble u_hex_to_nibble (
        .ascii (rx_data),
        .nibble(rx_nibble),
        .valid (rx_hex_valid)
    );

    wire [3:0] tx_nibble_wire;
    wire [7:0] tx_ascii_wire;

    assign tx_nibble_wire = out_reg[127:124];

    nibble_to_hex u_nibble_to_hex (
        .nibble(tx_nibble_wire),
        .ascii (tx_ascii_wire)
    );

    // UART instances
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) u_uart_rx (
        .clk(clk),
        .rst(rst),
        .rx(uart_rx),
        .data_out(rx_data),
        .data_valid(rx_valid)
    );

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) u_uart_tx (
        .clk(clk),
        .rst(rst),
        .data_in(tx_data),
        .start(tx_start),
        .tx(uart_tx),
        .busy(tx_busy)
    );

    // AES CORE
    aes128_top u_aes (
        .clk(clk),
        .rst(rst),
        .start(aes_start),
        .key(128'd0),        // unused by your modified aes128_top
        .block_in(aes_din),
        .block_out(aes_dout),
        .done(aes_done)
    );

    // Wrapper FSM
    localparam S_IDLE      = 3'd0;
    localparam S_GET_DATA  = 3'd1;
    localparam S_START_AES = 3'd2;
    localparam S_WAIT_AES  = 3'd3;
    localparam S_SEND_C    = 3'd4;
    localparam S_SEND_HEX  = 3'd5;
    localparam S_SEND_CR   = 3'd6;
    localparam S_SEND_LF   = 3'd7;

    reg [2:0]   state;
    reg [5:0]   nibble_count;
    reg [127:0] shift_reg;
    reg [127:0] out_reg;
    reg [5:0]   tx_count;

    always @(posedge clk) begin
        if (rst) begin
            state        <= S_IDLE;
            nibble_count <= 6'd0;
            shift_reg    <= 128'd0;
            out_reg      <= 128'd0;
            tx_count     <= 6'd0;
            aes_start    <= 1'b0;
            aes_din      <= 128'd0;
            tx_data      <= 8'd0;
            tx_start     <= 1'b0;
        end else begin
            aes_start <= 1'b0;
            tx_start  <= 1'b0;

            case (state)

                // Wait for 'D'
                S_IDLE: begin
                    nibble_count <= 6'd0;
                    shift_reg    <= 128'd0;

                    if (rx_valid) begin
                        if (rx_data == "D" || rx_data == "d") begin
                            state <= S_GET_DATA;
                        end
                    end
                end

                // Get 32 hex chars for plaintext
                S_GET_DATA: begin
                    if (rx_valid) begin
                        if (rx_data == 8'h0D || rx_data == 8'h0A) begin
                            // ignore CR/LF
                        end else if (rx_hex_valid) begin
                            shift_reg    <= {shift_reg[123:0], rx_nibble};
                            nibble_count <= nibble_count + 1'b1;

                            if (nibble_count == 6'd31) begin
                                aes_din      <= {shift_reg[123:0], rx_nibble};
                                nibble_count <= 6'd0;
                                shift_reg    <= 128'd0;
                                state        <= S_START_AES;
                            end
                        end
                    end
                end

                // Pulse AES start
                S_START_AES: begin
                    aes_start <= 1'b1;
                    state     <= S_WAIT_AES;
                end

                // Wait for AES done
                S_WAIT_AES: begin
                    if (aes_done) begin
                        out_reg  <= aes_dout;
                        tx_count <= 6'd0;
                        state    <= S_SEND_C;
                    end
                end

                // Send 'C'
                S_SEND_C: begin
                    if (!tx_busy) begin
                        tx_data  <= "C";
                        tx_start <= 1'b1;
                        state    <= S_SEND_HEX;
                    end
                end

                // Send 32 hex chars
                S_SEND_HEX: begin
                    if (!tx_busy) begin
                        tx_data  <= tx_ascii_wire;
                        tx_start <= 1'b1;
                        out_reg  <= {out_reg[123:0], 4'h0};
                        tx_count <= tx_count + 1'b1;

                        if (tx_count == 6'd31)
                            state <= S_SEND_CR;
                    end
                end

                // Send CR
                S_SEND_CR: begin
                    if (!tx_busy) begin
                        tx_data  <= 8'h0D;
                        tx_start <= 1'b1;
                        state    <= S_SEND_LF;
                    end
                end

                // Send LF, then go back
                S_SEND_LF: begin
                    if (!tx_busy) begin
                        tx_data  <= 8'h0A;
                        tx_start <= 1'b1;
                        state    <= S_IDLE;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule

// UART Receiver

module uart_rx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,
    output reg  [7:0] data_out,
    output reg        data_valid
);
    localparam integer CLKS_PER_BIT  = CLK_FREQ / BAUD;
    localparam integer HALF_BIT_CLKS = CLKS_PER_BIT / 2;

    reg [15:0] clk_count;
    reg [3:0]  bit_index;
    reg [7:0]  rx_shift;
    reg [2:0]  state;

    localparam RX_IDLE   = 3'd0;
    localparam RX_START  = 3'd1;
    localparam RX_DATA   = 3'd2;
    localparam RX_STOP   = 3'd3;
    localparam RX_CLEAN  = 3'd4;

    always @(posedge clk) begin
        if (rst) begin
            state      <= RX_IDLE;
            clk_count  <= 16'd0;
            bit_index  <= 4'd0;
            rx_shift   <= 8'd0;
            data_out   <= 8'd0;
            data_valid <= 1'b0;
        end else begin
            data_valid <= 1'b0;

            case (state)
                RX_IDLE: begin
                    clk_count <= 16'd0;
                    bit_index <= 4'd0;
                    if (rx == 1'b0)
                        state <= RX_START;
                end

                RX_START: begin
                    if (clk_count == HALF_BIT_CLKS - 1) begin
                        clk_count <= 16'd0;
                        if (rx == 1'b0)
                            state <= RX_DATA;
                        else
                            state <= RX_IDLE;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                RX_DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        rx_shift[bit_index] <= rx;

                        if (bit_index == 4'd7) begin
                            bit_index <= 4'd0;
                            state <= RX_STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                RX_STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count  <= 16'd0;
                        data_out   <= rx_shift;
                        data_valid <= 1'b1;
                        state      <= RX_CLEAN;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                RX_CLEAN: begin
                    state <= RX_IDLE;
                end

                default: state <= RX_IDLE;
            endcase
        end
    end
endmodule

// UART Transmitter

module uart_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire clk,
    input  wire rst,
    input  wire [7:0] data_in,
    input  wire start,
    output reg  tx,
    output reg  busy
);
    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;

    reg [15:0] clk_count;
    reg [3:0]  bit_index;
    reg [7:0]  tx_shift;
    reg [2:0]  state;

    localparam TX_IDLE  = 3'd0;
    localparam TX_START = 3'd1;
    localparam TX_DATA  = 3'd2;
    localparam TX_STOP  = 3'd3;
    localparam TX_DONE  = 3'd4;

    always @(posedge clk) begin
        if (rst) begin
            state     <= TX_IDLE;
            clk_count <= 16'd0;
            bit_index <= 4'd0;
            tx_shift  <= 8'd0;
            tx        <= 1'b1;
            busy      <= 1'b0;
        end else begin
            case (state)
                TX_IDLE: begin
                    tx        <= 1'b1;
                    busy      <= 1'b0;
                    clk_count <= 16'd0;
                    bit_index <= 4'd0;

                    if (start) begin
                        busy     <= 1'b1;
                        tx_shift <= data_in;
                        state    <= TX_START;
                    end
                end

                TX_START: begin
                    tx <= 1'b0;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        state     <= TX_DATA;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                TX_DATA: begin
                    tx <= tx_shift[bit_index];
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;

                        if (bit_index == 4'd7) begin
                            bit_index <= 4'd0;
                            state <= TX_STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                TX_STOP: begin
                    tx <= 1'b1;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        state     <= TX_DONE;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                TX_DONE: begin
                    tx   <= 1'b1;
                    busy <= 1'b0;
                    state <= TX_IDLE;
                end

                default: state <= TX_IDLE;
            endcase
        end
    end
endmodule

// ASCII hex -> nibble

module hex_to_nibble(
    input  wire [7:0] ascii,
    output reg  [3:0] nibble,
    output reg        valid
);
    always @* begin
        valid = 1'b1;
        case (ascii)
            "0": nibble = 4'h0;
            "1": nibble = 4'h1;
            "2": nibble = 4'h2;
            "3": nibble = 4'h3;
            "4": nibble = 4'h4;
            "5": nibble = 4'h5;
            "6": nibble = 4'h6;
            "7": nibble = 4'h7;
            "8": nibble = 4'h8;
            "9": nibble = 4'h9;
            "A","a": nibble = 4'hA;
            "B","b": nibble = 4'hB;
            "C","c": nibble = 4'hC;
            "D","d": nibble = 4'hD;
            "E","e": nibble = 4'hE;
            "F","f": nibble = 4'hF;
            default: begin
                nibble = 4'h0;
                valid  = 1'b0;
            end
        endcase
    end
endmodule

// nibble -> ASCII hex

module nibble_to_hex(
    input  wire [3:0] nibble,
    output reg  [7:0] ascii
);
    always @* begin
        case (nibble)
            4'h0: ascii = "0";
            4'h1: ascii = "1";
            4'h2: ascii = "2";
            4'h3: ascii = "3";
            4'h4: ascii = "4";
            4'h5: ascii = "5";
            4'h6: ascii = "6";
            4'h7: ascii = "7";
            4'h8: ascii = "8";
            4'h9: ascii = "9";
            4'hA: ascii = "A";
            4'hB: ascii = "B";
            4'hC: ascii = "C";
            4'hD: ascii = "D";
            4'hE: ascii = "E";
            4'hF: ascii = "F";
            default: ascii = "0";
        endcase
    end
endmodule


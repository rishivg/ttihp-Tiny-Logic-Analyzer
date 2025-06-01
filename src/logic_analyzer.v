/*
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_logic_analyzer_combo (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  wire _unused = ena | &uio_in[6:1]; // Acknowledge unused uio_in[6:1]
  assign uio_out[6:0] = 7'b0;
  assign uio_oe[6:0]  = 7'b0;

  wire [3:0] mode = ui_in[7:4];
  wire arm = ui_in[4];
  wire [3:0] channels = ui_in[3:0];
  wire replay_en = (mode == 4'b1100);
  wire autodetect_mode = (mode == 4'b1010);

  // --- Protocol Selection FSM ---
  reg [1:0] proto_sel;  // 00 = none, 01 = UART, 10 = SPI, 11 = I2C
  wire uart_detected, spi_detected, i2c_detected;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      proto_sel <= 2'b00;
    else if (!autodetect_mode)
      proto_sel <= 2'b00;
    else if (proto_sel == 2'b00) begin
      if (uart_detected)
        proto_sel <= 2'b01;
      else if (spi_detected)
        proto_sel <= 2'b10;
      else if (i2c_detected)
        proto_sel <= 2'b11;
    end
  end

  wire detect_only = autodetect_mode && (proto_sel == 2'b00);

  wire raw_en    = (mode == 4'b0000);
  wire trig_en   = (mode == 4'b0001);
  wire ts_en     = (mode == 4'b0010);
  wire glitch_en = (mode == 4'b0011);
  wire pulse_en  = (mode == 4'b0100);
  wire patt_en   = (mode == 4'b0101);
  wire auto_en   = (mode == 4'b1010);

  wire [7:0] out_raw, out_trigger, out_timestamp, out_glitch, out_pulse, out_pattern;

  // --- Shared Decoders ---
  wire [7:0] uart_out, spi_out, i2c_out;
  wire uart_valid, spi_valid, i2c_valid;

  uart_decoder uart (
    .clk(clk), .rst_n(rst_n),
    .rx(channels[0]),
    .detect_only(detect_only),
    .out_data(uart_out),
    .valid(uart_valid),
    .detected(uart_detected)
  );

  spi_decoder spi (
    .clk(clk), .rst_n(rst_n),
    .sclk(channels[0]), .mosi(channels[1]), .csn(channels[2]),
    .detect_only(detect_only),
    .data_out(spi_out),
    .valid(spi_valid),
    .detected(spi_detected)
  );

  i2c_decoder i2c (
    .clk(clk), .rst_n(rst_n),
    .scl(channels[0]), .sda(channels[1]),
    .detect_only(detect_only),
    .data_out(i2c_out),
    .valid(i2c_valid),
    .detected(i2c_detected)
  );

  // --- FIFO Integration ---
  wire [15:0] fifo_word;
  wire fifo_valid;
  wire dummy_overflow;

  wire uart_mode = auto_en && proto_sel == 2'b01;
  wire spi_mode  = auto_en && proto_sel == 2'b10;
  wire i2c_mode  = auto_en && proto_sel == 2'b11;

  wire [1:0] proto_id =
    (uart_mode) ? 2'b00 :
    (spi_mode)  ? 2'b01 :
    (i2c_mode)  ? 2'b10 :
                  2'b11;

  fifo buffer (
    .clk(clk),
    .rst_n(rst_n),
    .proto_id(proto_id),
    .data_in(uart_mode ? uart_out :
             spi_mode  ? spi_out  :
             i2c_mode  ? i2c_out  : 8'h00),
    .write_en((uart_mode && uart_valid) ||
              (spi_mode  && spi_valid) ||
              (i2c_mode  && i2c_valid)),
    .read_en((uio_in[0]) || (replay_en && !replay_active && fifo_valid)),
    .read_data(fifo_word),
    .valid(fifo_valid),
    .overflow(dummy_overflow)
  );

  // --- Logic Analyzer Submodules ---
  raw_capture raw (
    .clk(clk), .rst_n(rst_n), .arm(arm),
    .in_data(channels), .out_data(out_raw)
  );

  trigger_capture trig (
  .clk(clk),
  .rst_n(rst_n),
  .arm(arm),
  .in_data(channels),
  .pattern(ui_in[3:0]),
  .mask(uio_in[3:0]),
  .out_data(out_trigger)
  );

  edge_timestamper ts (
    .clk(clk), .rst_n(rst_n),
    .in_data(channels), .out_data(out_timestamp)
  );

  glitch_detector glitch (
    .clk(clk), .rst_n(rst_n),
    .in_data(channels), .out_data(out_glitch)
  );

  pulse_width pw (
    .clk(clk), .rst_n(rst_n),
    .in_data(channels[0]), .out_data(out_pulse)
  );

  pattern_detector patt (
  .clk(clk),
  .rst_n(rst_n),
  .in_data(channels),
  .pattern(ui_in[3:0]),
  .mask(uio_in[3:0]),
  .out_data(out_pattern)
  );


  // --- Replay Mode Logic ---
  reg [2:0] bit_cnt;
  reg [7:0] shift_reg;
  reg [7:0] replay_byte;
  reg [3:0] clk_div;
  reg replay_bit;
  reg replay_active;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bit_cnt <= 0;
      shift_reg <= 0;
      replay_byte <= 0;
      clk_div <= 0;
      replay_bit <= 0;
      replay_active <= 0;
    end else if (replay_en) begin
      clk_div <= clk_div + 1;

      if (!replay_active && fifo_valid) begin
        replay_byte <= fifo_word[7:0];
        shift_reg <= fifo_word[7:0];
        bit_cnt <= 0;
        replay_active <= 1;
      end

      if (replay_active && clk_div == 4'b1111) begin
        replay_bit <= shift_reg[7];
        shift_reg <= {shift_reg[6:0], 1'b0};
        bit_cnt <= bit_cnt + 1;
        if (bit_cnt == 3'd7) begin
          replay_active <= 0;
        end
      end
    end else begin
      clk_div <= 0;
      replay_bit <= 0;
      replay_active <= 0;
    end
  end

  assign uio_out[7] = replay_en ? replay_bit : 1'b0;
  assign uio_oe[7]  = replay_en ? 1'b1       : 1'b0;

  // --- Output Mux ---
  wire [7:0] selected_output =
    (auto_en && proto_sel == 2'b00) ? {5'b00000, i2c_detected, spi_detected, uart_detected} :
    (uart_mode || spi_mode || i2c_mode) ? {fifo_word[15:14], fifo_word[7:0]} :
    raw_en    ? out_raw :
    trig_en   ? out_trigger :
    ts_en     ? out_timestamp :
    glitch_en ? out_glitch :
    pulse_en  ? out_pulse :
    patt_en   ? out_pattern :
    8'h00;

  assign uo_out = selected_output;

  // Silence unused
  wire _unused2 = fifo_valid | &fifo_word[13:8];

endmodule

/*
 * Tiny Tapeout Logic Analyzer Combo
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_logic_analyzer_combo (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // Design enable
    input  wire       clk,      // System clock
    input  wire       rst_n     // System reset (active low)
);

  // === Configuration and Channel Assignment ===
  wire        auto_en      = ui_in[7];       // Use auto-detect
  wire        raw_en       = ui_in[6];
  wire        trig_en      = ui_in[5];
  wire        ts_en        = ui_in[4];
  wire        glitch_en    = ui_in[3];
  wire        pulse_en     = ui_in[2];
  wire        patt_en      = ui_in[1];
  wire [1:0]  proto_sel    = ui_in[0] ? 2'b10 : 2'b00; // UART if set, SPI otherwise

  wire [7:0] channels = uio_in;

  // === Auto-Detect Flags ===
  wire spi_detected, i2c_detected, uart_detected;

  // === Decoder Outputs ===
  wire [7:0] uart_out, spi_out, i2c_out;
  wire       uart_valid, spi_valid, i2c_valid;

  // === Pattern Detector Outputs ===
  wire [7:0] out_pattern;
  wire       patt_flag;
  wire [7:0] patt_mask     = 8'hFF;
  wire [7:0] patt_pattern  = 8'hA5;
  wire       patt_edge     = 1'b0;

  // === Trigger Outputs ===
  wire [7:0] out_trigger;
  wire [7:0] out_timestamp;
  wire [7:0] out_glitch;
  wire [7:0] out_pulse;
  wire [7:0] out_raw;

  // === Protocol Decoders ===

  uart_decoder uart (
    .clk(clk),
    .rst_n(rst_n),
    .rx(channels[3]),
    .data_out(uart_out),
    .out_valid(uart_valid),
    .detect_only(!(auto_en || proto_sel == 2'b10))
  );

  spi_decoder spi (
    .clk(clk),
    .rst_n(rst_n),
    .sck(channels[0]),
    .mosi(channels[1]),
    .cs_n(channels[2]),
    .out_data(spi_out),
    .out_valid(spi_valid),
    .detect_only(!(auto_en || proto_sel == 2'b00))
  );

  i2c_decoder i2c (
    .clk(clk),
    .rst_n(rst_n),
    .scl(channels[4]),
    .sda(channels[5]),
    .out_data(i2c_out),
    .out_valid(i2c_valid),
    .detect_only(!(auto_en || proto_sel == 2'b01))
  );

  pattern_detector patt (
    .clk(clk),
    .rst_n(rst_n),
    .in_data(channels),
    .pattern(patt_pattern),
    .mask(patt_mask),
    .edge_only(patt_edge),
    .detect_only(!patt_en),
    .detected(patt_flag),
    .out_data(out_pattern)
  );

  // === Data Outputs (examples only) ===
  assign out_trigger   = 8'h01;
  assign out_timestamp = 8'h02;
  assign out_glitch    = 8'h03;
  assign out_pulse     = 8'h04;
  assign out_raw       = channels;

  // === Output Selection Logic ===
  wire [9:0] full_output = 
    (auto_en && proto_sel == 2'b00) ? {5'b00000, i2c_detected, spi_detected, uart_detected} :
    raw_en    ? {2'b00, out_raw} :
    trig_en   ? {2'b00, out_trigger} :
    ts_en     ? {2'b00, out_timestamp} :
    glitch_en ? {2'b00, out_glitch} :
    pulse_en  ? {2'b00, out_pulse} :
    patt_en   ? {2'b00, out_pattern} :
    10'b0;

  assign uo_out  = full_output[7:0];
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

endmodule

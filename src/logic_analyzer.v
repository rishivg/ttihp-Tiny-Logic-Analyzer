/*
 * Copyright (c) 2024
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_logic_analyzer_combo (
    input  wire [7:0] ui_in,    // [7:4]=mode, [3:0]=input channels
    output wire [7:0] uo_out,   // output data
    input  wire [7:0] uio_in,   // uio[0] = FIFO read strobe
    output wire [7:0] uio_out,  // not used
    output wire [7:0] uio_oe,   // not used
    input  wire       ena,      // always high when enabled
    input  wire       clk,      // system clock
    input  wire       rst_n     // reset (active low)
);

  // Prevent unused signal warnings
  wire _unused = ena;

  // Tie off unused IO
  assign uio_out = 8'h00;
  assign uio_oe  = 8'h00;

  // Decode mode and inputs
  wire [3:0] mode = ui_in[7:4];
  wire arm = ui_in[4];
  wire [3:0] channels = ui_in[3:0];
  wire read_en = uio_in[0];  // used to read from FIFO

  // Submodule outputs
  wire [7:0] out_raw;
  wire [7:0] out_trigger;
  wire [7:0] out_uart;
  wire [7:0] out_timestamp;
  wire [7:0] out_glitch;
  wire [7:0] out_pulse;
  wire [7:0] out_pattern;

  // SPI/I2C decoder outputs + FIFO
  wire [7:0] spi_out, i2c_out;
  wire spi_valid, i2c_valid;
  wire [7:0] fifo_data_out;
  wire fifo_valid;

  // Submodules
  raw_capture raw (
    .clk(clk), .rst_n(rst_n), .arm(arm),
    .in_data(channels), .out_data(out_raw)
  );

  trigger_capture trig (
    .clk(clk), .rst_n(rst_n), .arm(arm),
    .in_data(channels), .out_data(out_trigger)
  );

  uart_decoder uart (
    .clk(clk), .rst_n(rst_n),
    .rx(channels[0]), .out_data(out_uart)
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
    .clk(clk), .rst_n(rst_n),
    .in_data(channels), .out_data(out_pattern)
  );

  spi_decoder spi (
    .clk(clk), .rst_n(rst_n),
    .sclk(channels[0]), .mosi(channels[1]), .csn(channels[2]),
    .data_out(spi_out), .valid(spi_valid)
  );

  i2c_decoder i2c (
    .clk(clk), .rst_n(rst_n),
    .scl(channels[0]), .sda(channels[1]),
    .data_out(i2c_out), .valid(i2c_valid)
  );

  fifo buffer (
    .clk(clk), .rst_n(rst_n),
    .write_data((mode == 4'b1000) ? spi_out :
                (mode == 4'b1001) ? i2c_out : 8'h00),
    .write_en((mode == 4'b1000 && spi_valid) || (mode == 4'b1001 && i2c_valid)),
    .read_en(read_en),
    .read_data(fifo_data_out),
    .valid(fifo_valid)
  );

  // Output multiplexer
  assign uo_out = (mode == 4'b1000 || mode == 4'b1001) ? fifo_data_out :
                  (mode == 4'b0000) ? out_raw :
                  (mode == 4'b0001) ? out_trigger :
                  (mode == 4'b0010) ? out_uart :
                  (mode == 4'b0011) ? out_timestamp :
                  (mode == 4'b0100) ? out_glitch :
                  (mode == 4'b0101) ? out_pulse :
                  (mode == 4'b0110) ? out_pattern :
                  8'h00;

endmodule

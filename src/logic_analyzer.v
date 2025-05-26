/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_logic_analyzer_combo (
    input  wire [7:0] ui_in,    // [7:5]=mode, [4]=arm, [3:0]=inputs
    output wire [7:0] uo_out,   // output data
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,      // design enable
    input  wire       clk,      // clock
    input  wire       rst_n     // reset (active low)
);

  wire [2:0] mode = ui_in[7:5];
  wire arm = ui_in[4];
  wire [3:0] channels = ui_in[3:0];

  wire [7:0] out_raw;
  wire [7:0] out_trigger;
  wire [7:0] out_uart;
  wire [7:0] out_timestamp;
  wire [7:0] out_glitch;
  wire [7:0] out_pulse;
  wire [7:0] out_pattern;

  // Submodule instances
  raw_capture raw (
    .clk(clk), .rst_n(rst_n), .arm(arm), .in_data(channels), .out_data(out_raw)
  );

  trigger_capture trig (
    .clk(clk), .rst_n(rst_n), .arm(arm), .in_data(channels), .out_data(out_trigger)
  );

  uart_decoder uart (
    .clk(clk), .rst_n(rst_n), .rx(channels[0]), .out_data(out_uart)
  );

  edge_timestamper ts (
    .clk(clk), .rst_n(rst_n), .in_data(channels), .out_data(out_timestamp)
  );

  glitch_detector glitch (
    .clk(clk), .rst_n(rst_n), .in_data(channels), .out_data(out_glitch)
  );

  pulse_width pw (
    .clk(clk), .rst_n(rst_n), .in_data(channels[0]), .out_data(out_pulse)
  );

  pattern_detector patt (
    .clk(clk), .rst_n(rst_n), .in_data(channels), .out_data(out_pattern)
  );

  // Output multiplexer based on mode
  assign uo_out = (mode == 3'b000) ? out_raw :
                  (mode == 3'b001) ? out_trigger :
                  (mode == 3'b010) ? out_uart :
                  (mode == 3'b011) ? out_timestamp :
                  (mode == 3'b100) ? out_glitch :
                  (mode == 3'b101) ? out_pulse :
                  (mode == 3'b110) ? out_pattern : 8'h00;

  assign uio_out = 8'h00;
  assign uio_oe  = 8'h00;

endmodule


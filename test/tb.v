`timescale 1ns/1ps

module tb;

  reg [7:0] ui_in;
  wire [7:0] uo_out;
  reg [7:0] uio_in;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
  reg clk;
  reg rst_n;
  reg ena;

  // Instantiate DUT
  tt_um_logic_analyzer_combo dut (
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .clk(clk),
    .rst_n(rst_n),
    .ena(ena)
  );

  initial begin
    // Just basic init — doesn't do anything.
    ui_in = 0;
    uio_in = 0;
    clk = 0;
    rst_n = 0;
    ena = 1;

    #10;
    rst_n = 1;

    #100;
    $finish;
  end

  always #5 clk = ~clk;

endmodule

// SPDX-License-Identifier: Apache-2.0
// Configurable trigger with edge-detected match

module trigger_capture (
<<<<<<< HEAD
    input  wire       clk,
    input  wire       rst_n,
    input  wire       arm,
    input  wire [3:0] in_data,   // from channels
    input  wire [3:0] pattern,   // from ui_in[3:0]
    input  wire [3:0] mask,      // from uio_in[3:0]
    output reg  [7:0] out_data
);

  wire [3:0] now, prev;
  wire [3:0] masked_now, masked_prev;

  // Integrate shift sampler
  shift_sampler #(
    .WIDTH(4),
    .DEPTH(2)
  ) sample_inst (
    .clk(clk),
    .rst_n(rst_n),
    .in_data(in_data),
    .now(now),
    .prev(prev)
  );

  assign masked_now  = now  & mask;
  assign masked_prev = prev & mask;

  wire match_now  = (masked_now  == (pattern & mask));
  wire match_prev = (masked_prev == (pattern & mask));
  wire match_edge = match_now && !match_prev;

  reg triggered;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      triggered <= 1'b0;
      out_data  <= 8'h00;
    end else begin
      if (!triggered && arm && match_edge) begin
        triggered <= 1'b1;
        out_data  <= {4'b0000, now};  // capture current input
      end
      if (!arm) triggered <= 1'b0;
    end
=======
  input wire clk,
  input wire rst_n,
  input wire arm,
  input wire [3:0] in_data,
  output reg [7:0] out_data
);
  reg triggered;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      triggered <= 0;
    else if (arm && in_data == 4'b1010) // example pattern
      triggered <= 1;
    else if (!arm)
      triggered <= 0;
  end

  always @(*) begin
    out_data = {7'b0, triggered};
>>>>>>> parent of 82241d6 (modded pattern detector with configurable trigger)
  end

endmodule

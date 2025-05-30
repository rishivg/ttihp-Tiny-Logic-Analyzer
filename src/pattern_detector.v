// SPDX-License-Identifier: Apache-2.0

module pattern_detector (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       detect_only,
    input  wire [3:0] in_data,
    input  wire [3:0] pattern,
    input  wire [3:0] mask,
    input  wire       edge_only,
    output reg  [7:0] out_data,
    output reg        detected
);

  wire [3:0] now, prev;
  wire [3:0] masked_now, masked_prev;

  shift_sampler #(
    .WIDTH(4),
    .DEPTH(2)
  ) pattern_sampler (
    .clk(clk),
    .rst_n(rst_n),
    .in_data(in_data),
    .now(now),
    .prev(prev)
  );

  assign masked_now  = now & mask;
  assign masked_prev = prev & mask;

  wire match_now  = (masked_now  == (pattern & mask));
  wire match_prev = (masked_prev == (pattern & mask));

  wire match = edge_only ? (match_now && !match_prev) : match_now;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      out_data <= 0;
      detected <= 0;
    end else begin
      detected <= 0;
      if (match) begin
        if (!detect_only) out_data <= {4'b0000, now};
        detected <= 1;
      end
    end
  end

endmodule

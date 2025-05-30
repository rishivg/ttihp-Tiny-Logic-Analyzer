// SPDX-License-Identifier: Apache-2.0

module glitch_detector (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] in_data,
    output reg  [7:0] out_data
);

  wire [3:0] now, prev;

  shift_sampler #(
    .WIDTH(4),
    .DEPTH(2)
  ) sampler (
    .clk(clk),
    .rst_n(rst_n),
    .in_data(in_data),
    .now(now),
    .prev(prev)
  );

  wire [3:0] glitch_detected = now ^ prev;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      out_data <= 8'h00;
    end else begin
      if (|glitch_detected)
        out_data <= {4'b0000, glitch_detected};
    end
  end

endmodule

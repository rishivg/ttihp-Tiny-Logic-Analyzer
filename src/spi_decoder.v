// SPDX-License-Identifier: Apache-2.0

module spi_decoder (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       detect_only,
    input  wire       sck,
    input  wire       mosi,
    input  wire       cs_n,
    output reg  [7:0] out_data,
    output reg        detected
);

  wire sck_now, sck_prev, mosi_now;
  wire sck_rising = ~sck_prev & sck_now;

  shift_sampler #(.WIDTH(1), .DEPTH(2)) sck_sampler (
    .clk(clk), .rst_n(rst_n),
    .in_data(sck),
    .now(sck_now), .prev(sck_prev)
  );

  shift_sampler #(.WIDTH(1), .DEPTH(2)) mosi_sampler (
    .clk(clk), .rst_n(rst_n),
    .in_data(mosi),
    .now(mosi_now), .prev()
  );

  reg [2:0] bit_cnt;
  reg [7:0] shift;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift    <= 0;
      bit_cnt  <= 0;
      detected <= 0;
    end else begin
      detected <= 0;
      if (!cs_n && sck_rising) begin
        shift <= {shift[6:0], mosi_now};
        bit_cnt <= bit_cnt + 1;
        if (bit_cnt == 3'd7) begin
          if (!detect_only) out_data <= {shift[6:0], mosi_now};
          detected <= 1;
        end
      end
    end
  end

endmodule

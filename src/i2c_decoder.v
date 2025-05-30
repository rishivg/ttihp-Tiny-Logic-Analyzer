// SPDX-License-Identifier: Apache-2.0

module i2c_decoder (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       detect_only,
    input  wire       scl,
    input  wire       sda,
    output reg  [7:0] out_data,
    output reg        detected
);

  wire scl_now, scl_prev;
  wire sda_now, sda_prev;

  shift_sampler #(.WIDTH(1), .DEPTH(2)) scl_sampler (
    .clk(clk), .rst_n(rst_n),
    .in_data(scl),
    .now(scl_now), .prev(scl_prev)
  );

  shift_sampler #(.WIDTH(1), .DEPTH(2)) sda_sampler (
    .clk(clk), .rst_n(rst_n),
    .in_data(sda),
    .now(sda_now), .prev(sda_prev)
  );

  wire start_cond = scl_now & sda_prev & ~sda_now;
  wire stop_cond  = scl_now & ~sda_prev & sda_now;
  wire scl_rise   = ~scl_prev & scl_now;

  reg [2:0] bit_cnt;
  reg [7:0] shift;
  reg       reading;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      out_data <= 8'h00;
      detected <= 1'b0;
      bit_cnt  <= 0;
      reading  <= 0;
    end else begin
      detected <= 0;

      if (start_cond) begin
        reading <= 1;
        bit_cnt <= 0;
      end else if (stop_cond) begin
        reading <= 0;
      end else if (reading && scl_rise) begin
        shift <= {shift[6:0], sda_now};
        bit_cnt <= bit_cnt + 1;

        if (bit_cnt == 3'd7) begin
          if (!detect_only) out_data <= {shift[6:0], sda_now};
          detected <= 1;
        end
      end
    end
  end

endmodule

// SPDX-License-Identifier: Apache-2.0

module uart_decoder (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       detect_only,
    input  wire       rx,               // async input
    output reg  [7:0] out_data,
    output reg        detected
);

  wire rx_now, rx_prev;
  wire rx_falling = rx_prev & ~rx_now; // detect start bit

  shift_sampler #(
    .WIDTH(1),
    .DEPTH(2)
  ) uart_sampler (
    .clk(clk),
    .rst_n(rst_n),
    .in_data(rx),
    .now(rx_now),
    .prev(rx_prev)
  );

  reg [3:0] bit_cnt;
  reg [7:0] shift;
  reg [7:0] baud_cnt;
  reg       active;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      active   <= 0;
      bit_cnt  <= 0;
      shift    <= 0;
      baud_cnt <= 0;
      out_data <= 0;
      detected <= 0;
    end else begin
      detected <= 0;

      if (!active && rx_falling) begin
        active   <= 1;
        bit_cnt  <= 0;
        baud_cnt <= 0;
      end

      if (active) begin
        baud_cnt <= baud_cnt + 1;
        if (baud_cnt == 104) begin  // ~9600 baud at 1 MHz
          baud_cnt <= 0;
          shift <= {rx_now, shift[7:1]};
          bit_cnt <= bit_cnt + 1;
          if (bit_cnt == 8) begin
            active <= 0;
            if (!detect_only) out_data <= {rx_now, shift[7:1]};
            detected <= 1;
          end
        end
      end
    end
  end

endmodule

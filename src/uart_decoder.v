module uart_decoder (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    input  wire       detect_only,
    output reg  [7:0] data_out,
    output reg        out_valid
);

  parameter CLK_PER_BIT = 10;
  reg [3:0] bit_cnt;
  reg [7:0] shift;
  reg [3:0] clk_cnt;
  reg       sampling;
  reg       rx_prev;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bit_cnt     <= 0;
      clk_cnt     <= 0;
      sampling    <= 0;
      shift       <= 0;
      out_valid   <= 0;
      rx_prev     <= 1;
    end else if (detect_only) begin
      out_valid <= 0;
    end else begin
      rx_prev <= rx;
      if (!sampling && rx_prev && !rx) begin
        sampling <= 1;
        bit_cnt  <= 0;
        clk_cnt  <= CLK_PER_BIT / 2;
      end else if (sampling) begin
        if (clk_cnt == 0) begin
          clk_cnt <= CLK_PER_BIT - 1;
          shift   <= {rx, shift[7:1]};
          bit_cnt <= bit_cnt + 1;
          if (bit_cnt == 7) begin
            data_out  <= {rx, shift[7:1]};
            out_valid <= 1;
            sampling  <= 0;
          end else begin
            out_valid <= 0;
          end
        end else begin
          clk_cnt <= clk_cnt - 1;
        end
      end else begin
        out_valid <= 0;
      end
    end
  end

endmodule

module spi_decoder (
  input wire clk,
  input wire rst_n,
  input wire sclk,
  input wire mosi,
  input wire csn,
  input wire detect_only,

  output reg [7:0] data_out,
  output reg valid,
  output reg detected
);
  reg [2:0] bit_cnt;
  reg [7:0] shift_reg;
  reg prev_sclk;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift_reg <= 0;
      bit_cnt <= 0;
      valid <= 0;
      detected <= 0;
      prev_sclk <= 0;
    end else begin
      prev_sclk <= sclk;
      valid <= 0;
      detected <= 0;

      if (!csn) begin
        if (prev_sclk == 0 && sclk == 1) begin
          shift_reg <= {shift_reg[6:0], mosi};
          bit_cnt <= bit_cnt + 1;

          if (bit_cnt == 3'd7) begin
            detected <= 1;
            if (!detect_only) begin
              data_out <= {shift_reg[6:0], mosi};
              valid <= 1;
            end
            bit_cnt <= 0;
          end
        end
      end else begin
        bit_cnt <= 0;
      end
    end
  end
endmodule
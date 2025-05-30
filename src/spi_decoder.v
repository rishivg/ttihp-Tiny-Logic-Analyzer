module spi_decoder (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       sck,
    input  wire       mosi,
    input  wire       cs_n,
    input  wire       detect_only,  // Disable decoding logic if high
    output reg  [7:0] out_data,
    output reg        out_valid
);

  reg [2:0] bit_cnt;
  reg [7:0] shift_reg;

  always @(posedge sck or negedge rst_n) begin
    if (!rst_n) begin
      shift_reg <= 0;
      bit_cnt   <= 0;
    end else if (!detect_only && !cs_n) begin
      shift_reg <= {shift_reg[6:0], mosi};
      bit_cnt   <= bit_cnt + 1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      out_data  <= 0;
      out_valid <= 0;
    end else if (!detect_only && bit_cnt == 3'd7 && !cs_n) begin
      out_data  <= {shift_reg[6:0], mosi};
      out_valid <= 1;
    end else begin
      out_valid <= 0;
    end
  end

endmodule

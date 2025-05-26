module i2c_decoder (
  input wire clk,
  input wire rst_n,
  input wire scl,
  input wire sda,

  output reg [7:0] data_out,
  output reg valid
);
  reg [7:0] shift_reg;
  reg [2:0] bit_cnt;
  reg prev_scl, prev_sda;
  reg start_detected;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift_reg <= 0;
      bit_cnt <= 0;
      valid <= 0;
      prev_scl <= 1;
      prev_sda <= 1;
      start_detected <= 0;
    end else begin
      prev_scl <= scl;
      prev_sda <= sda;
      valid <= 0;

      // Detect START condition (SDA falls while SCL high)
      if (prev_sda == 1 && sda == 0 && scl == 1) begin
        start_detected <= 1;
        bit_cnt <= 0;
      end

      // Sample on rising SCL edge
      if (start_detected && prev_scl == 0 && scl == 1) begin
        shift_reg <= {shift_reg[6:0], sda};
        bit_cnt <= bit_cnt + 1;

        if (bit_cnt == 3'd7) begin
          data_out <= {shift_reg[6:0], sda};
          valid <= 1;
          bit_cnt <= 0;
        end
      end
    end
  end
endmodule

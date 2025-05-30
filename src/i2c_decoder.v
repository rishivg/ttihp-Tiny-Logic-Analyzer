module i2c_decoder (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       scl,
    input  wire       sda,
    input  wire       detect_only,
    output reg  [7:0] out_data,
    output reg        out_valid
);

  reg [7:0] shift_reg;
  reg [2:0] bit_cnt;
  reg       sda_prev;

  wire start_cond = (sda_prev == 1) && (sda == 0);
  wire stop_cond  = (sda_prev == 0) && (sda == 1);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift_reg <= 0;
      bit_cnt   <= 0;
      out_valid <= 0;
      sda_prev  <= 1;
    end else begin
      sda_prev <= sda;
      if (detect_only)
        out_valid <= 0;
      else if (start_cond) begin
        shift_reg <= 0;
        bit_cnt   <= 0;
      end else if (scl && !start_cond && !stop_cond) begin
        shift_reg <= {shift_reg[6:0], sda};
        bit_cnt   <= bit_cnt + 1;
        if (bit_cnt == 3'd7) begin
          out_data  <= {shift_reg[6:0], sda};
          out_valid <= 1;
        end else begin
          out_valid <= 0;
        end
      end
    end
  end

endmodule

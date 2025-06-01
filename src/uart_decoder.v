module uart_decoder (
  input wire clk,
  input wire rst_n,
  input wire rx,
  input wire detect_only,

  output reg [7:0] out_data,
  output reg valid,
  output reg detected
);
  reg [3:0] bit_count;
  reg [7:0] shift;
  reg [15:0] clk_count;
  reg state;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bit_count <= 0;
      shift <= 0;
      clk_count <= 0;
      valid <= 0;
      detected <= 0;
      state <= 0;
    end else begin
      valid <= 0;
      detected <= 0;

      if (rx == 0 && state == 0) begin
        clk_count <= 0;
        state <= 1;
      end

      if (state == 1) begin
        clk_count <= clk_count + 1;

        if (clk_count == 8) begin
          shift <= {rx, shift[7:1]};
          bit_count <= bit_count + 1;
          clk_count <= 0;

          if (bit_count == 7) begin
            detected <= 1;
            if (!detect_only) begin
              out_data <= {rx, shift[7:1]};
              valid <= 1;
            end
            bit_count <= 0;
            state <= 0;
          end
        end
      end
    end
  end
endmodule
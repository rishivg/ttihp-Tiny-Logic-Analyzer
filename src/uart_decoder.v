module uart_decoder (
  input wire clk,
  input wire rst_n,
  input wire rx,
  output reg [7:0] out_data
);
  // VERY simple 1-byte sampler (assumes mid-bit sampling at fixed baud)
  reg [3:0] bit_count;
  reg [7:0] shift;
  reg [15:0] clk_div;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clk_div <= 0;
      bit_count <= 0;
      shift <= 0;
    end else begin
      clk_div <= clk_div + 1;
      if (clk_div == 5000) begin // simulate ~9600 baud
        clk_div <= 0;
        shift <= {rx, shift[7:1]};
        bit_count <= bit_count + 1;
        if (bit_count == 8) begin
          out_data <= shift;
          bit_count <= 0;
        end
      end
    end
  end

endmodule

module pulse_width (
  input wire clk,
  input wire rst_n,
  input wire in_data,
  output reg [7:0] out_data
);
  reg [7:0] width;
  reg state;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      width <= 0;
      out_data <= 0;
      state <= 0;
    end else begin
      if (in_data) begin
        width <= width + 1;
        state <= 1;
      end else if (state) begin
        out_data <= width;
        width <= 0;
        state <= 0;
      end
    end
  end

endmodule

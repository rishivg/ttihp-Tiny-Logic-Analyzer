module pattern_detector (
  input wire clk,
  input wire rst_n,
  input wire [3:0] in_data,
  output reg [7:0] out_data
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      out_data <= 0;
    else if (in_data == 4'b1101)
      out_data <= out_data + 1;
  end
endmodule

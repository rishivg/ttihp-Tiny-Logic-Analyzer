module glitch_detector (
  input wire clk,
  input wire rst_n,
  input wire [3:0] in_data,
  output reg [7:0] out_data
);
  reg [3:0] prev1, prev2;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      prev1 <= 0;
      prev2 <= 0;
      out_data <= 0;
    end else begin
      if (in_data != prev1 && prev1 != prev2)
        out_data <= out_data + 1; // count glitches
      prev2 <= prev1;
      prev1 <= in_data;
    end
  end

endmodule
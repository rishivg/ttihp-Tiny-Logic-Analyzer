module trigger_capture (
  input wire clk,
  input wire rst_n,
  input wire arm,
  input wire [3:0] in_data,
  output reg [7:0] out_data
);
  reg triggered;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      triggered <= 0;
    else if (arm && in_data == 4'b1010) // example pattern
      triggered <= 1;
    else if (!arm)
      triggered <= 0;
  end

  always @(*) begin
    out_data = {7'b0, triggered};
  end

endmodule

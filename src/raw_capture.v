module raw_capture (
  input wire clk,
  input wire rst_n,
  input wire arm,
  input wire [3:0] in_data,
  output reg [7:0] out_data
);
  reg [3:0] sample;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      sample <= 0;
    else if (arm)
      sample <= in_data;
  end

  always @(*) begin
    out_data = {4'b0000, sample};
  end
endmodule

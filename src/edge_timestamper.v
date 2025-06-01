module edge_timestamper (
  input wire clk,
  input wire rst_n,
  input wire [3:0] in_data,
  output reg [7:0] out_data
);
  reg [3:0] prev;
  reg [7:0] timestamp;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      timestamp <= 0;
      prev <= 0;
    end else begin
      timestamp <= timestamp + 1;
      if (in_data != prev)
        out_data <= timestamp;
      prev <= in_data;
    end
  end

endmodule

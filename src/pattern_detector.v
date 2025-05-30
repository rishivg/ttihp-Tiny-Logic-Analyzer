module pattern_detector (
<<<<<<< HEAD
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] in_data,
    input  wire [7:0] pattern,
    input  wire [7:0] mask,
    input  wire       edge_only,
    input  wire       detect_only,
    output reg        detected,
    output reg  [7:0] out_data
);

  reg [7:0] prev_data;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      detected  <= 0;
      out_data  <= 0;
      prev_data <= 0;
    end else if (detect_only) begin
      detected <= 0;
    end else begin
      prev_data <= in_data;
      if (((in_data & mask) == (pattern & mask)) &&
          (!edge_only || (in_data != prev_data))) begin
        detected <= 1;
        out_data <= in_data;
      end else begin
        detected <= 0;
      end
    end
=======
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
>>>>>>> parent of 82241d6 (modded pattern detector with configurable trigger)
  end
endmodule

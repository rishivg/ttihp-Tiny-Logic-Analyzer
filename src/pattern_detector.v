module pattern_detector (
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
  end

endmodule

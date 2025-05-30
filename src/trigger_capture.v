module trigger_capture (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       arm,
    input  wire [3:0] in_data,
    input  wire [3:0] pattern,
    input  wire [3:0] mask,
    output reg  [7:0] out_data
);

  wire match = ((in_data & mask) == (pattern & mask));

  reg triggered;
  reg match_prev;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      triggered  <= 1'b0;
      out_data   <= 8'h00;
      match_prev <= 1'b0;
    end else begin
      match_prev <= match;

      if (arm && !triggered && match && !match_prev) begin
        triggered <= 1'b1;
        out_data <= {4'b0000, in_data};
      end

      if (!arm)
        triggered <= 1'b0;
    end
  end

endmodule

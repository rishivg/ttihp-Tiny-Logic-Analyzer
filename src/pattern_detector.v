module pattern_detector (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] in_data,     // Observed channels
    input  wire [3:0] pattern,     // Expected pattern (from ui_in[3:0])
    input  wire [3:0] mask,        // Bitmask (from uio_in[3:0])
    output reg  [7:0] out_data     // Output matched pattern
);

  wire match = ((in_data & mask) == (pattern & mask));

  reg match_prev;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      match_prev <= 1'b0;
      out_data   <= 8'h00;
    end else begin
      match_prev <= match;
      if (match && !match_prev) begin
        // Rising edge of pattern match
        out_data <= {4'b0000, in_data};  // or optionally include match flag
      end else begin
        out_data <= 8'h00;  // Only pulse when match occurs
      end
    end
  end

endmodule

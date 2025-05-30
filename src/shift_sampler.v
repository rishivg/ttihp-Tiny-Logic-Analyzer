// SPDX-License-Identifier: Apache-2.0
// Shift sampler with edge-safe input capture

module shift_sampler #(
    parameter WIDTH = 1,              // Number of input bits
    parameter DEPTH = 2               // Length of shift register
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire [WIDTH-1:0]  in_data,
    output wire [WIDTH-1:0]  now,
    output wire [WIDTH-1:0]  prev
);

  reg [WIDTH-1:0] shift_reg [DEPTH-1:0];

  integer i;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < DEPTH; i = i + 1)
        shift_reg[i] <= {WIDTH{1'b0}};
    end else begin
      shift_reg[0] <= in_data;
      for (i = 1; i < DEPTH; i = i + 1)
        shift_reg[i] <= shift_reg[i-1];
    end
  end

  assign now  = shift_reg[0];
  assign prev = shift_reg[1];

endmodule

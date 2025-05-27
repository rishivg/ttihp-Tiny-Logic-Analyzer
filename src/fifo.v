module fifo (
  input wire clk,
  input wire rst_n,
  input wire [7:0] write_data,
  input wire write_en,
  input wire read_en,
  output reg [7:0] read_data,
  output wire valid
);

  reg [7:0] shift[3:0];
  reg [2:0] count;

  assign valid = (count != 0);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 0;
      read_data <= 0;
    end else begin
      if (write_en && count < 4) begin
        shift[count] <= write_data;
        count <= count + 1;
      end

      if (read_en && count > 0) begin
        read_data <= shift[0];
        shift[0] <= shift[1];
        shift[1] <= shift[2];
        shift[2] <= shift[3];
        count <= count - 1;
      end
    end
  end
endmodule

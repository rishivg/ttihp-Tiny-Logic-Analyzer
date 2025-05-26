module fifo (
  input wire clk,
  input wire rst_n,
  input wire [7:0] write_data,
  input wire write_en,
  input wire read_en,
  output reg [7:0] read_data,
  output reg valid
);
  reg [7:0] mem [7:0];
  reg [2:0] wr_ptr, rd_ptr;
  reg [3:0] count;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      count <= 0;
      read_data <= 0;
      valid <= 0;
    end else begin
      valid <= 0;

      if (write_en && count < 8) begin
        mem[wr_ptr] <= write_data;
        wr_ptr <= wr_ptr + 1;
        count <= count + 1;
      end

      if (read_en && count > 0) begin
        read_data <= mem[rd_ptr];
        rd_ptr <= rd_ptr + 1;
        count <= count - 1;
        valid <= 1;
      end
    end
  end
endmodule

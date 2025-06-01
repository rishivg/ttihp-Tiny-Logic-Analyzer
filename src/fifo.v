module fifo (
  input  wire        clk,
  input  wire        rst_n,
  input  wire [1:0]  proto_id,    // Protocol ID: 00 = UART, 01 = SPI, 10 = I2C
  input  wire [7:0]  data_in,     // Payload
  input  wire        write_en,
  input  wire        read_en,
  output reg  [15:0] read_data,
  output wire        valid,
  output reg         overflow
);

  reg [15:0] mem [15:0];  // 16-entry circular buffer
  reg [3:0] wr_ptr, rd_ptr;
  reg [4:0] count;         // 5-bit counter (max 16)
  reg [7:0] timestamp;

  assign valid = (count != 0);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      count <= 0;
      read_data <= 0;
      timestamp <= 0;
      overflow <= 0;
    end else begin
      timestamp <= timestamp + 1;
      overflow <= 0;

      // Write logic
      if (write_en) begin
        if (count < 16) begin
          mem[wr_ptr] <= {proto_id, timestamp, data_in};
          wr_ptr <= wr_ptr + 1;
          count <= count + 1;
        end else begin
          overflow <= 1;  // overflow signal
        end
      end

      // Read logic
      if (read_en && count > 0) begin
        read_data <= mem[rd_ptr];
        rd_ptr <= rd_ptr + 1;
        count <= count - 1;
      end
    end
  end
endmodule

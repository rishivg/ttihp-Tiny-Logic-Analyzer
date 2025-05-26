`timescale 1ns/1ps

module testbench;

  reg [7:0] ui_in;
  wire [7:0] uo_out;
  reg [7:0] uio_in;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
  reg clk;
  reg rst_n;
  reg ena;

  // Instantiate DUT
  tt_um_logic_analyzer_combo dut (
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .clk(clk),
    .rst_n(rst_n),
    .ena(ena)
  );

  // Clock generation
  always #5 clk = ~clk;  // 100MHz clock

  initial begin
    $dumpfile("testbench.vcd");
    $dumpvars(0, testbench);

    // Initialize signals
    clk = 0;
    rst_n = 0;
    ena = 1;
    ui_in = 0;
    uio_in = 0;

    // Reset
    #20;
    rst_n = 1;

    // === Test raw_capture (mode 000)
    $display("Testing raw capture...");
    #10;
    ui_in = 8'b000_1_1010; // mode=000, arm=1, input=1010
    #10;
    if (uo_out !== 8'b00001010) $display("FAIL: Raw capture wrong value: %b", uo_out);
    else                        $display("PASS: Raw capture correct.");

    // === Test trigger_capture (mode 001, pattern 1010)
    $display("Testing trigger capture...");
    ui_in = 8'b001_1_1010; // mode=001, arm=1, input=1010
    #10;
    if (uo_out !== 8'b00000001) $display("FAIL: Trigger not detected");
    else                        $display("PASS: Trigger detected.");

    // === Test UART decoder (mode 010)
    $display("Testing UART decoder...");
    ui_in = 8'b010_0_0000; // mode=010, RX=ui_in[0]
    #10;

    // Send UART: start(0), 0xA5 = 10100101, stop(1)
    send_uart_byte(8'hA5);
    #10000;  // Wait for decoder

    if (uo_out !== 8'hA5) $display("FAIL: UART decode wrong: %h", uo_out);
    else                  $display("PASS: UART decode OK.");

    $display("Simulation complete.");
    #100;
    $finish;
  end

  // UART transmitter helper (1 start, 8 data, 1 stop)
  task send_uart_byte(input [7:0] data);
    integer i;
    begin
      ui_in[0] = 0; // Start bit
      #8680;

      for (i = 0; i < 8; i = i + 1) begin
        ui_in[0] = data[i];
        #8680;
      end

      ui_in[0] = 1; // Stop bit
      #8680;
    end
  endtask

endmodule

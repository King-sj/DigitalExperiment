`timescale 1ns / 1ps
`include "../counter.v"
module tb_counter;
  reg clk;
  reg reset;
  reg enable;
  reg set;
  reg [31:0] set_count;
  wire [31:0] count;
  wire carry_out;

  defparam UUT.MAX_COUNT = 8;
  // Instantiate the counter module
  counter UUT (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .set(set),
    .set_count(set_count),
    .count(count),
    .carry_out(carry_out)
  );

  // Clock generation
  always #5 clk = ~clk; // Generate a clock with a period of 10 ns

  // Test stimulus
  initial begin
    // Initialize Inputs
    clk = 0;
    reset = 0;
    enable = 0;
    set = 0;
    set_count = 0;

    // Reset the counter
    #10;
    reset = 1;  // Assert reset
    #10;
    reset = 0;  // Deassert reset

    // Test counter enable
    #10;
    enable = 1; // Enable counting
    #1000;       // Observe counting for a while
    enable = 0; // Disable counting
    #10;

    // Test setting the counter
    #10;
    set = 1;
    set_count = 32'd25;  // Set counter to 25
    #10;
    set = 0;
    #50; // Let it count from 25

    // Test carry out and max count
    #10;
    enable = 1;
    #500; // Long run to test carry out and wrap around

    // End simulation
    #10;
    $stop;
  end

  /*iverilog */
  initial
  begin
      $dumpfile("counter_wave.vcd");        //生成的vcd文件名称
      $dumpvars(0, tb_counter);    //tb模块名称
  end
  /*iverilog */

endmodule

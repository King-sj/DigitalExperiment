`timescale 1ns / 1ps
`include "../counter.v"
`include "../clock.v"
`include "../frequency_divider.v"
`include "../seven_segment_display.v"
module tb_clock;

  reg clk;
  reg reset;
  reg set_mod;
  reg [5:0] set_hours;
  reg [5:0] set_minutes;
  reg [5:0] set_seconds;
  wire [5:0] hours;
  wire [5:0] minutes;
  wire [5:0] seconds;
  wire [6:0] hours_display_high;
  wire [6:0] hours_display_low;
  wire [6:0] minutes_display_low;
  wire [6:0] minutes_display_high;
  wire [6:0] seconds_display_high;
  wire [6:0] seconds_display_low;
  wire beep;
  wire [3:0] seconds_high, seconds_low;

  // Instantiate the Clock module
  clock UUT (
    .clk(clk),
    .reset(reset),
    .set_mod(set_mod),
    .set_hours(set_hours),
    .set_minutes(set_minutes),
    .set_seconds(set_seconds),
    .hours(hours),
    .minutes(minutes),
    .seconds(seconds),
    .hours_display_high(hours_display_high),
    .hours_display_low(hours_display_low),
    .minutes_display_low(minutes_display_low),
    .minutes_display_high(minutes_display_high),
    .seconds_display_high(seconds_display_high),
    .seconds_display_low(seconds_display_low),
    .beep(beep),
    .seconds_high(seconds_high),
    .seconds_low(seconds_low)
  );

  // Clock generation (20ms period for 50 Hz)
  always #10 clk = ~clk; // Toggle every 10 ms

  // Test stimulus
  initial begin
    // Initialize Inputs
    clk = 0;
    reset = 0;
    set_mod = 0;
    set_hours = 0;
    set_minutes = 0;
    set_seconds = 0;

    // Apply reset
    #20;
    reset = 1;
    // Set time to 12:34:56
    #20;
    reset = 0;
    set_mod = 1;
    set_hours = 6'd12;
    set_minutes = 6'd34;
    set_seconds = 6'd56;
    #20;

    set_mod=0;
    // Let clock run
    #10000; // Run for a few seconds

    // Reset the clock again to test reset functionality
    #20;
    reset = 1;
    #20;
    reset = 0;
    // End simulation
    #20;
    $finish;
  end

  // Monitor Outputs
  // initial begin
  //   $monitor("Time: %02d:%02d:%02d | High Hours: %b Low Hours: %b | High Minutes: %b Low Minutes: %b | High Seconds: %b Low Seconds: %b",
  //            set_hours, set_minutes, set_seconds,
  //            hours_display_high, hours_display_low,
  //            minutes_display_high, minutes_display_low,
  //            seconds_display_high, seconds_display_low);
  // end

  /*iverilog */
  initial
  begin
      $dumpfile("clock_wave.vcd");        //生成的vcd文件名称
      $dumpvars(0, tb_clock);    //tb模块名称
  end
  /*iverilog */
endmodule

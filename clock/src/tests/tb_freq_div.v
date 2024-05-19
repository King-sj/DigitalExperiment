`timescale 1ns / 1ps
`include "../frequency_divider.v"
module tb_freq_div;
reg clk;
reg reset;
wire one_hz_clk;
// Clock generation
always #20 clk = ~clk; // Generate a clock with a period of 20 ns
initial begin
  $dumpfile("fd_wave.vcd");        //生成的vcd文件名称
  $dumpvars(0, tb_freq_div);    //tb模块名称
end
frequency_divider fd(
  .clk(clk),
  .reset(reset),
  .one_hz_clk(one_hz_clk)
);
initial begin
  clk = 0;
  reset = 1;
  #20;
  reset = 0;
  #10000;
  $stop;
end
endmodule
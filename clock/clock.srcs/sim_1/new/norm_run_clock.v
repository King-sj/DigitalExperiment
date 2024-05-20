`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: SongJian
//
// Create Date: 2024/05/20 00:16:39
// Design Name:
// Module Name: norm_run_clock
// Project Name:
// Target Devices:
// Tool Versions:
// Description:  clk=100MHz, T=1/(100*10^6)=10*10^-9s=10ns
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module norm_run_clock;
  reg clk, reset;
  wire [3:0] sm_left_wei;  // 左边的数码管
  wire [7:0] sm_left_duan;  //
  wire [3:0] sm_right_wei;  //
  wire [7:0] sm_right_duan;  //
  always #5 clk = ~clk;  // generate 100MHz
  clock clocker(
    .clk(clk),  // 100MHz
    .reset(reset),
    .set_mod(0),  // ????
    .left(0),  //
    .right(0),
    .up(0),
    .down(0),
    .sm_left_wei(sm_left_wei),  // 左边的数码管
    .sm_left_duan(sm_left_duan),  //
    .sm_right_wei(sm_right_wei),  //
    .sm_right_duan(sm_right_wei)
  );
  initial begin
    clk = 0;
    # 10;  // wait T
    reset=1;
    # 10;
    reset=0;
    #10;

    #100000000;  // just run 0.1s（for test, speed will be more fast）
    $stop;
  end
endmodule

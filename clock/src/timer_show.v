module timer_show(
  input clk,
  input [5:0]hours,
  input [5:0]minutes,
  input [5:0]seconds,
  output [3:0] sm_left_wei,  // 左边的数码管
  output [7:0] sm_left_duan,  //
  output [3:0] sm_right_wei,  //
  output [7:0] sm_right_duan  //
);
  reg [15:0] left_data, right_data;
  wire [3:0] hours_high, hours_low, minutes_high, minutes_low, seconds_high, seconds_low;

  assign hours_high = hours/10;
  assign hours_low = hours%10;
  assign minutes_high = minutes/10;
  assign minutes_low = minutes%10;
  assign seconds_high = seconds/10;
  assign seconds_low = seconds%10;

  always @(posedge clk) begin
    left_data <= {hours_low,hours_high,4'hf,4'hf};
    right_data <= {seconds_low,seconds_high,minutes_low,minutes_high};
  end
  smg_ip_model smg_left(
    .clk(clk), .data(left_data),
    .sm_wei(sm_left_wei), .sm_duan(sm_left_duan)
  );
  smg_ip_model smg_right(
    .clk(clk), .data(right_data),
    .sm_wei(sm_right_wei), .sm_duan(sm_right_duan)
  );
endmodule
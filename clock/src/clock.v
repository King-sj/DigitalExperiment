module clock(
  input clk,  // 100MHz
  input reset,
  input set_mod,  // ????
  input left,  //
  input right,
  input up,
  input down,
  output [3:0] sm_left_wei,  // 左边的数码管
  output [7:0] sm_left_duan,  //
  output [3:0] sm_right_wei,  //
  output [7:0] sm_right_duan
);
//---------------------分频(1HZ)-------------------------------------------
  reg one_hz_clk = 0;  // 1HZ
  reg [32:0] one_hz_counter;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      one_hz_clk<=0;
      one_hz_counter<=0;
    end else begin
      if (one_hz_counter == 100000000/2-1) begin //TODO(SJ): change to 100000000/2-1
        one_hz_counter<=0;
        one_hz_clk<=~one_hz_clk;
      end else one_hz_counter <= one_hz_counter+1;
    end
  end
//---------------------计时-------------------------------------------
  wire [5:0] seconds, minutes, hours;
  Ktime timer(
    .one_hz_clk(one_hz_clk), .reset(reset), .set_mod(set_mod),
    .set_hours(set_hours), .set_minutes(set_minutes), .set_seconds(set_seconds),
    .seconds(seconds), .minutes(minutes),.hours(hours)  // 输出
  );
//---------------------设置-------------------------------------------
wire [5:0] set_seconds, set_minutes, set_hours;
wire [2:0] pos;
timer_setting timer_setter(
  .clk(clk), .reset(reset), .set_mod(set_mod), .left(left), .right(right),
  .up(up), .down(down), .hours(hours), .minutes(minutes), .seconds(seconds),
  .set_hours(set_hours), .set_minutes(set_minutes), .set_seconds(set_seconds),  // out
  .pos(pos)
);

//---------------------显示-------------------------------------------
timer_show timer_shower(
  .clk(clk), .hours(hours), .minutes(minutes), .seconds(seconds),
  .pos(pos),
  .left_wei(sm_left_wei),  // 输出
  .left_duan(sm_left_duan),
  .right_wei(sm_right_wei),
  .right_duan(sm_right_duan)
);
endmodule

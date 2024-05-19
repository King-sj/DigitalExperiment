module clock(
  input clk,  // 100MHz
  input reset,
  input set_mod,  // ????
  input left,  //
  input right,
  input up,
  input down,
<<<<<<< HEAD
  output [3:0] sm_left_wei,  // ??????
=======
  output [3:0] sm_left_wei,  // 左边的数码管
>>>>>>> 32ebf23303922a783cabaa80baabb4c7e3afb5bd
  output [7:0] sm_left_duan,  //
  output [3:0] sm_right_wei,  //
  output [7:0] sm_right_duan  //
);
//---------------------??(1HZ)-------------------------------------------
  reg one_hz_clk;  // 1HZ??
  reg [32:0] one_hz_counter;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      one_hz_clk<=0;
    end else begin
      if (one_hz_counter == 100/2-1) begin
        one_hz_counter<=0;
        one_hz_clk<=~one_hz_clk;
      end
    end
  end
//---------------------??-------------------------------------------
  wire [5:0] seconds, minutes, hours;
  Ktime timer(
    .one_hz_clk(one_hz_clk), .reset(reset), .set_mod(set_mod),
    .set_hours(set_hours), .set_minutes(set_minutes), .set_seconds(set_seconds),
    .seconds(seconds), .minutes(minutes),.hours(hours)  // 输出
  );
//---------------------设置-------------------------------------------
reg [5:0] set_hours, set_minutes, set_seconds;  //
reg [2:0] pos;  // ??
always @(posedge set_mod) begin
  set_hours <= hours;
  set_minutes <= minutes;
  set_seconds <= seconds;
end
always @(posedge left) begin
  if (set_mod) begin
    if (pos == 5) pos = 0;
    else pos <= pos+1;
  end
end
always @(posedge right) begin
  if (set_mod) begin
    if (pos == 0) pos = 5;
    else pos <= pos-1;
  end
end
//---------------------显示-------------------------------------------
  timer_show timer_shower(
    .clk(clk), .hours(hours), .minutes(minutes), .seconds(seconds),
    .sm_left_wei(sm_left_wei),  // 输出
    .sm_left_duan(sm_left_duan),
    .sm_right_wei(sm_right_wei),
    .sm_right_duan(sm_right_duan)
  );
endmodule

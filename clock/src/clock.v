/**
 * @copyright ==================================================================
 *  Copyright (c) 2024-05-29.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the
 *  distribution.
 *  3. All advertising materials mentioning features or use of this software
 *  must display the following acknowledgement:
 *  This product includes software developed by the SJ Group. and
 *  its contributors.
 *  4. Neither the name of the Group nor the names of its contributors may
 *  be used to endorse or promote products derived from this software
 *  without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY SongJian, GROUP AND CONTRIBUTORS
 *  ===================================================================
 * @file clock.v
 * @author KSJ
 * @date 2024-05-29
 * @version 0.0.0
 * @brief 24制计时器, 有设置时间、整点报时、闪烁等功能
*/
module clock(
  input clk,  // 100MHz
  input reset,
  input set_mod,  // ????
  input left,  // 按钮输入
  input right,
  input up,
  input down,
  output [3:0] sm_left_wei,  // 左边的数码管
  output [7:0] sm_left_duan,  //
  output [3:0] sm_right_wei,  //
  output [7:0] sm_right_duan,
  output beep,
  output sd
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
//---------------------去抖动---------------------------------------------
  wire left_clean, right_clean, up_clean, down_clean;
  debounce db_left(
    .clk(clk),
    .reset(reset),
    .noisy_signal(left),
    .clean_signal(left_clean)
  );
  debounce db_right(
    .clk(clk),
    .reset(reset),
    .noisy_signal(right),
    .clean_signal(right_clean)
  );
  debounce db_up(
    .clk(clk),
    .reset(reset),
    .noisy_signal(up),
    .clean_signal(up_clean)
  );
  debounce db_down(
    .clk(clk),
    .reset(reset),
    .noisy_signal(down),
    .clean_signal(down_clean)
  );
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
  .clk(clk), .reset(reset), .set_mod(set_mod), .left(left_clean), .right(right_clean),
  .up(up_clean), .down(down_clean), .hours(hours), .minutes(minutes), .seconds(seconds),
  .set_hours(set_hours), .set_minutes(set_minutes), .set_seconds(set_seconds),  // out
  .pos(pos)
);

//---------------------显示-------------------------------------------
timer_show timer_shower(
  .clk(clk), .hours(hours), .minutes(minutes), .seconds(seconds),
  .pos(pos), .set_mod(set_mod),
  .left_wei(sm_left_wei),  // 输出
  .left_duan(sm_left_duan),
  .right_wei(sm_right_wei),
  .right_duan(sm_right_duan)
);
//---------------------------音频-------------------------------------------
wire beep_w;
assign beep = (minutes == 0) & beep_w;
audio_player audio(
  .clk(clk),
  .beep(beep_w),
  .sd(sd)
);
endmodule

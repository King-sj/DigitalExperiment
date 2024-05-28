/**
 * @copyright ==================================================================
 *  Copyright (c) 2024-05-20.
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
 * @file timer_setting.v
 * @author KSJ
 * @date 2024-05-20
 * @version 0.0.1
 * @brief 设置时间的模块
 * 真的好想优化下面的代码呀qAq(使用取余怕对电路消耗太大)
*/
module timer_setting(
  input clk,  // 100MHz
  input reset,
  input set_mod,
  input left,
  input right,
  input up,
  input down,
  input [5:0] seconds,
  input [5:0] minutes,
  input [5:0] hours,
  output reg signed [32:0] set_hours,
  output reg signed [32:0] set_minutes,
  output reg signed [32:0] set_seconds,
  output reg [2:0] pos
);
// 定义保存前一个状态的寄存器
reg left_prev;
reg right_prev;
always @(posedge clk or posedge reset) begin
  if (reset) begin
    pos <= 0;
    left_prev <= 0;
    right_prev <= 0;
  end else begin
    // 更新前一个状态的寄存器
    left_prev <= left;
    right_prev <= right;
    // 检测left的上升沿
    if (left && !left_prev && !right) begin
      if (pos == 5)
        pos <= 0;
      else
        pos <= pos + 1;
    end
    // 检测right的上升沿
    if (right && !right_prev && !left) begin
      if (pos == 0)
        pos <= 5;
      else
        pos <= pos - 1;
    end
  end
end
//-----------------------------------------------------------
reg copy_source_time=0;
// 定义保存前一个状态的寄存器
reg up_prev;
reg down_prev;

always @(posedge clk, posedge reset) begin
  if (reset) begin
    set_seconds <= 0;
    set_minutes <= 0;
    set_hours <= 0;
  end else if (set_mod) begin
    up_prev <= up;
    down_prev <= down;
    if (up && !up_prev && !down) begin
      case (pos)
        3'd0: set_seconds <= (set_seconds + 1) % 60;
        3'd1: set_seconds <= (set_seconds + 10) % 60;
        3'd2: set_minutes <= (set_minutes + 1) % 60;
        3'd3: set_minutes <= (set_minutes + 10) % 60;
        3'd4: set_hours   <= (set_hours + 1) % 24;
        3'd5: set_hours   <= (set_hours + 10) % 24;
      endcase
    end else if (down && !down_prev && !up) begin
      case (pos)
        3'd0: set_seconds <= (set_seconds - 1+60) % 60;
        3'd1: set_seconds <= (set_seconds - 10+60) % 60;
        3'd2: set_minutes <= (set_minutes - 1+60) % 60;
        3'd3: set_minutes <= (set_minutes - 10+60) % 60;
        3'd4: set_hours   <= (set_hours - 1+24) % 24;
        3'd5: set_hours   <= (set_hours - 10+24) % 24;
      endcase
    end
  end else if (~set_mod) begin
    set_hours <= hours;
    set_minutes <= minutes;
    set_seconds <= seconds;
  end
end
endmodule
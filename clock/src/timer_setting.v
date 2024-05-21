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
always @(posedge left or posedge right or posedge reset) begin
  if (reset) begin
    pos <= 0;
  end else if (left) begin
    if (pos == 5) begin
      pos <= 0;
    end else begin
      pos <= pos+1;
    end
  end else if (right) begin
    if (pos == 0) begin
      pos <= 5;
    end else begin
      pos <= pos-1;
    end
  end
end
//-----------------------------------------------------------
reg copy_source_time=0;
always @(posedge clk) begin
  if (reset) begin
    set_seconds <= 0;
    set_minutes <= 0;
    set_hours <= 0;
  end else if (set_mod) begin
    if (up) begin
      case (pos)
        3'd0: set_seconds <= (set_seconds + 1) % 60;
        3'd1: set_seconds <= (set_seconds + 10) % 60;
        3'd2: set_minutes <= (set_minutes + 1) % 60;
        3'd3: set_minutes <= (set_minutes + 10) % 60;
        3'd4: set_hours   <= (set_hours + 1) % 24;
        3'd5: set_hours   <= (set_hours + 10) % 24;
      endcase
    end else if (down) begin
      case (pos)
        3'd0: set_seconds <= (set_seconds - 1+60) % 60;
        3'd1: set_seconds <= (set_seconds - 10+60) % 60;
        3'd2: set_minutes <= (set_minutes - 1+60) % 60;
        3'd3: set_minutes <= (set_minutes - 10+60) % 60;
        3'd4: set_hours   <= (set_hours - 1+60) % 24;
        3'd5: set_hours   <= (set_hours - 10+60) % 24;
      endcase
    end else begin
      if (~copy_source_time) begin
        set_hours <= hours;
        set_minutes <= minutes;
        set_seconds <= seconds;
        copy_source_time <= 1;
      end
    end
  end else if (~set_mod) begin
    copy_source_time <= 0;
  end
end
endmodule
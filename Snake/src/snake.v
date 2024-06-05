/**
 * @copyright ==================================================================
 *  Copyright (c) 2024-05-30.
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
 * @file snake.v
 * @date 2024-05-30
 * @version 0.0.1
 * @brief 贪吃蛇
*/
module snake (
  input clk,
  input reset,
  input left,  // 按钮输入
  input right,
  input up,
  input down,
  output [3:0] red,
  output [3:0] green,
  output [3:0] blue,
  output hsync,
  output vsync,
  output [3:0] left_wei,  // 左边的数码管
  output [7:0] left_duan,  //
  output [3:0] right_wei,  //
  output [7:0] right_duan,
  inout ps2_clk,
  inout ps2_data,
  output beep,
  output sd,
  input enfast
);
wire [11:0]color;
wire [9:0]x,y;  // 640x480
//---------------------去抖动---------------------------------------------
  wire left_clean, right_clean, up_clean, down_clean,enfast_clean;
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
  debounce db_enfast(
    .clk(clk),
    .reset(reset),
    .noisy_signal(enfast),
    .clean_signal(enfast_clean)
  );
//-----------------------------VGA--------------------------------------------
vga vga_shower(
  .clk(clk),
  .new_data(color),
  .red(red),
  .green(green),
  .blue(blue),
  .hsync(hsync),
  .vsync(vsync),
  .pos_x(x),
  .pos_y(y)
);
//------------------keyboard-------------------
wire valid;
wire [7:0] ascii_code;
ps2 ps(clk, reset,ps2_clk,ps2_data,valid,ascii_code);
wire right_p,left_p,up_p,down_p;
assign right_p = right_clean || ascii_code == 8'h44;
assign left_p = left_clean || ascii_code == 8'h41;
assign up_p = up_clean || ascii_code == 8'h57;
assign down_p = down_clean || ascii_code == 8'h53;
//---------------------------------------------------
wire [15:0] score;
wire game_over;
snake_model snaker(
  .clk(clk),.reset(reset),
  .left(left_p),.right(right_p),.up(up_p),.down(down_p),
  .pix_x(x),.pix_y(y),
  .color(color),.score(score),.game_over(game_over)
);
//----------------------------------------------------------
score_show score_shower(
  .clk(clk),
  .lcnt(0),
  .rcnt(score),
  .game_over(game_over),
  .left_wei(left_wei),  // 左边的数码管
  .left_duan(left_duan),  //
  .right_wei(right_wei),  //
  .right_duan(right_duan)
);
//-------------------------------------------
//---------------------------音频-------------------------------------------
wire beep_w;
assign beep = game_over & beep_w;
audio_player audio(
  .clk(clk),
  .beep(beep_w),
  .sd(sd)
);
endmodule
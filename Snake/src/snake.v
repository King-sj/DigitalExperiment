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
 * @author KSJ
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
  output [7:0] right_duan
);
wire [11:0]color;
wire [9:0]x,y;  // 640x480
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
//-------------------------------------------------------------------------
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

//---------------------------------------------------
wire [15:0] food_x, food_y;
snake_model snaker(
  .clk(clk),.reset(reset),
  .left(left_clean),.right(right_clean),.up(up_clean),.down(down_clean),
  .pix_x(x),.pix_y(y),
  .color(color),.food_x(food_x),.food_y(food_y)
);
//----------------------------------------------------------
score_show score_shower(
  .clk(clk),
  .lcnt(food_x),
  .rcnt(food_y),
  .game_over(1'b0),
  .left_wei(left_wei),  // 左边的数码管
  .left_duan(left_duan),  //
  .right_wei(right_wei),  //
  .right_duan(right_duan)
);
endmodule
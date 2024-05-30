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
 * @file vga.v
 * @author KSJ
 * @date 2024-05-30
 * @version 0.0.1
 * @brief vga for 640x480 60Hz
*/
module vga(
  input clk,          // 100MHz 时钟输入
  input [11:0]new_data,  // 下一个(r,g,b)
  output [3:0] red,   // 4位红色信号
  output [3:0] green, // 4位绿色信号
  output [3:0] blue,  // 4位蓝色信号
  output hsync,       // 水平同步信号
  output vsync,        // 垂直同步信号
  output [9:0] pos_x,  // 当前横坐标
  output [9:0] pos_y
);
reg [9:0] hcount; //VGA 行扫描计数器
reg [9:0] vcount; //VGA 场扫描计数器
wire [11:0] data;  // (r,g,b)
reg [1:0]cnt;
wire hcount_ov;
wire vcount_ov;
wire dat_act;
reg vga_clk;

//VGA 行、场扫描时序参数表
parameter
  hsync_end = 10'd95,   // 水平同步结束的像素位置，即HSYNC信号的宽度为95个像素
  hdat_begin = 10'd143, // 水平显示数据开始的像素位置，HSYNC结束后还有一段背景色区域，到第143个像素位置开始显示数据
  hdat_end = 10'd783,   // 水平显示数据结束的像素位置，第783个像素位置数据显示结束
  hpixel_end = 10'd799, // 水平一行的结束像素位置，总宽度为800个像素（0到799）

  vsync_end = 10'd1,    // 垂直同步结束的行位置，即VSYNC信号的高度为1行
  vdat_begin = 10'd34,  // 垂直显示数据开始的行位置，在一些前置的非显示行后，从第34行开始显示数据
  vdat_end = 10'd514,   // 垂直显示数据结束的行位置，第514行数据显示结束
  vline_end = 10'd524;  // 垂直一帧的结束行位置，总高度为525行（0到524）

always @(posedge clk) begin
  if(cnt==3)
    cnt <= 0;
  else
    cnt <= cnt + 1;
end

always @(posedge clk) begin
  if(cnt < 2)
    vga_clk <= 1;
  else
    vga_clk <= 0;
end
//************************VGA 驱动部分*******************************
//行扫描
always @(posedge vga_clk) begin
  if (hcount_ov)
    hcount <= 10'd0;
  else
    hcount <= hcount + 10'd1;
end
assign hcount_ov = (hcount == hpixel_end);
//场扫描
always @(posedge vga_clk) begin
  if (hcount_ov) begin
    if (vcount_ov)
      vcount <= 10'd0;
    else
      vcount <= vcount + 10'd1;
  end
end
assign vcount_ov = (vcount == vline_end);


//数据、同步信号输
assign dat_act = ((hcount >= hdat_begin) && (hcount < hdat_end))
&& ((vcount >= vdat_begin) && (vcount < vdat_end));

assign hsync = (hcount > hsync_end);
assign vsync = (vcount > vsync_end);

assign red = (dat_act) ? data[11:8] : 3'h00;
assign green = (dat_act) ? data[7:4] : 3'h00;
assign blue = (dat_act) ? data[3:0] : 3'h00;

//************************显示数据处理部分*******************************//
assign pos_x = hcount-hdat_begin;
assign pos_y = vcount-vdat_begin;
assign data = new_data;
endmodule
